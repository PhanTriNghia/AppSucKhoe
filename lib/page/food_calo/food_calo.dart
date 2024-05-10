import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthylife/model/CaloHistory.dart';
import 'package:healthylife/page/calo/calo_page.dart';
import 'package:healthylife/util/color_theme.dart';
import 'package:intl/intl.dart';
import 'package:input_quantity/input_quantity.dart';

import '../../model/Food.dart';
import '../../model/FoodCategory.dart';
import '../../util/snack_bar_error_mess.dart';

class FoodCaloPage extends StatefulWidget {
  final String userID;
  final String dateHistory;
  final num userCalo;

  const FoodCaloPage({super.key, required this.userID, required this.dateHistory, required this.userCalo});

  @override
  State<FoodCaloPage> createState() => _FoodCaloState();
}

class _FoodCaloState extends State<FoodCaloPage> {
  int _selectIndex = 0;

  bool _isLoading = false;

  late List<FoodCategory> categories = [];
  late List<Food> foods = [];
  late List<bool> _selectStates = [];

  late List<Food> filteredFoods = [];

  late List<FoodDetailHistory> foodHistoryList = [];

  late List<ExerciseDetailHistory> exerciseHistoryList = [];

  num value = 0;

  int defaultNetWeight = 100;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  bool isChecked() {
    return _selectStates.contains(true);
  }

  void fetchData() async {
    setState(() {
      _isLoading = true;
    });
    await getFoodCategory();
    await getFood();
    _selectStates = List.generate(foods.length, (index) => false);

    setState(() {
      _isLoading = false;
    });

    _searchController.clear();

    _selectIndex = 0;
    value = 0;
  }

  // hàm lấy dữ liệu loại thức ăn từ firebase
  Future<void> getFoodCategory() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('FoodCategory').get();
    setState(() {
      categories = querySnapshot.docs
          .map((doc) => FoodCategory.fromFirestore(doc))
          .toList();
    });
  }

  // hàm lấy dữ liệu Food từ firebase
  Future<void> getFood() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Food')
        // .orderBy("FoodName")
        .get();
    setState(() {
      foods = querySnapshot.docs.map((doc) => Food.fromFirestore(doc)).toList();
    });
  }

  Future<void> searchFoodByName(String name) async {
    setState(() {
      filteredFoods = foods
          .where((food) =>
              food.FoodName.toLowerCase().contains(name.toLowerCase()))
          .toList();
      _selectStates = List.generate(filteredFoods.length, (index) => false);
    });
  }

  void getFoodsForCategory(String categoryFood) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Food')
        .where('FoodCategoryID', isEqualTo: categoryFood)
        .get();
    setState(() {
      foods = querySnapshot.docs.map((doc) => Food.fromFirestore(doc)).toList();
    });
  }

  Future<void> addCaloHistory(List<FoodDetailHistory> foodHistory) async {
    try {

      final caloHistoryCollection =
          FirebaseFirestore.instance.collection('CaloHistory');

      final querySnapshot = await caloHistoryCollection
          .where('UserID', isEqualTo: widget.userID)
          .where('DateHistory', isEqualTo: widget.dateHistory)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final document = querySnapshot.docs.first;

        CaloHistory caloHistory = CaloHistory(
            document.id, widget.userID, widget.dateHistory, foodHistoryList, exerciseHistoryList);

        final existingFoodHistory = List<FoodDetailHistory>.from(
            document.data()['FoodDetailHistory']?.map((e) => FoodDetailHistory(
                      e['FoodID'] ?? '',
                      e['NetWeight'] ?? 0,
                    )) ??
                []);

        existingFoodHistory.addAll(foodHistoryList);

        print(existingFoodHistory.length);

        await caloHistoryCollection.doc(document.id).update({
          'FoodDetailHistory':
              existingFoodHistory.map((history) => history.toJson()).toList(),
        }).then((value) {
          print("Calo history update\nUID:${caloHistory.CaloHistoryID}");
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => CaloPage(userID: widget.userID, userCalo: widget.userCalo)));
        }).catchError(
            (error) => print("Failed to update calo history: $error"));
      } else {
        final uid = caloHistoryCollection.doc().id;

        CaloHistory caloHistory =
            CaloHistory(uid, widget.userID, widget.dateHistory, foodHistory, exerciseHistoryList);

        await caloHistoryCollection
            .doc(caloHistory.CaloHistoryID)
            .set(caloHistory.toJson())
            .then((value) {
          print("Calo history Added\nUID:${caloHistory.CaloHistoryID}");
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => CaloPage(userID: widget.userID, userCalo: widget.userCalo)));
        }).catchError((error) => print("Failed to add calo history: $error"));
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> addCustomCaloHistory(List<FoodDetailHistory> foodHistory) async {
    try {

      final caloHistoryCollection =
      FirebaseFirestore.instance.collection('CaloHistory');

      final querySnapshot = await caloHistoryCollection
          .where('UserID', isEqualTo: widget.userID)
          .where('DateHistory', isEqualTo: widget.dateHistory)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final document = querySnapshot.docs.first;

        CaloHistory caloHistory = CaloHistory(
            document.id, widget.userID, widget.dateHistory, foodHistoryList, exerciseHistoryList);

        final existingFoodHistory = List<FoodDetailHistory>.from(
            document.data()['FoodDetailHistory']?.map((e) => FoodDetailHistory(
              e['FoodID'] ?? '',
              e['NetWeight'] ?? 0,
            )) ??
                []);

        existingFoodHistory.addAll(foodHistoryList);

        print(existingFoodHistory.length);

        await caloHistoryCollection.doc(document.id).update({
          'FoodDetailHistory':
          existingFoodHistory.map((history) => history.toJson()).toList(),
        }).then((value) {
          print("Calo history update\nUID:${caloHistory.CaloHistoryID}");
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => CaloPage(userID: widget.userID, userCalo: widget.userCalo)));
        }).catchError(
                (error) => print("Failed to update calo history: $error"));
      } else {
        final uid = caloHistoryCollection.doc().id;

        CaloHistory caloHistory =
        CaloHistory(uid, widget.userID, widget.dateHistory, foodHistory, exerciseHistoryList);

        await caloHistoryCollection
            .doc(caloHistory.CaloHistoryID)
            .set(caloHistory.toJson())
            .then((value) {
          print("Calo history Added\nUID:${caloHistory.CaloHistoryID}");
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => CaloPage(userID: widget.userID, userCalo: widget.userCalo)));
        }).catchError((error) => print("Failed to add calo history: $error"));
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          color: Colors.white,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => CaloPage(userID: widget.userID, userCalo: widget.userCalo)));
          }
        ),
        title: Text('Món ăn của bạn'),
        titleTextStyle: GoogleFonts.getFont(
          'Montserrat',
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        backgroundColor: ColorTheme.lightGreenColor,
        bottom: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.of(context).size.height * 0.06),
          child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Tìm kiếm...',
                        hintStyle: GoogleFonts.getFont(
                          'Montserrat',
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.normal,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.zero,
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onPressed: _searchController.clear,
                                icon: Icon(Icons.clear)),
                      ),
                      onChanged: (value) {
                        // Khi nội dung thanh tìm kiếm thay đổi
                        // Thực hiện hành động tìm kiếm ở đây
                        searchFoodByName(value);
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    color: Colors.white,
                    onPressed: () {

                      num _customCalo = 100;

                      showDialog(
                        context: context,
                        builder: (context) {
                          int netWeight = defaultNetWeight;
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                // backgroundColor: ColorTheme.lightGreenColor,
                                content: Stack(
                                  clipBehavior: Clip.none,
                                  children: <Widget>[
                                    Positioned(
                                      right: -40,
                                      top: -40,
                                      child: InkResponse(
                                        onTap: () {
                                          Navigator.pushReplacement(context,
                                              MaterialPageRoute(builder: (context) => CaloPage(userID: widget.userID, userCalo: widget.userCalo)));
                                        },
                                        child: CircleAvatar(
                                          backgroundColor:
                                          ColorTheme.lightGreenColor,
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                          Text(
                                            "Thêm calo đã nạp",
                                            style: GoogleFonts.getFont('Montserrat',
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                        Text(
                                          "${_customCalo} calo",
                                          style: GoogleFonts.getFont(
                                            'Montserrat',
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                        InputQty.int(
                                          initVal: _customCalo,
                                          minVal: 1,
                                          decoration: const QtyDecorationProps(
                                              isBordered: false,
                                              borderShape: BorderShapeBtn.circle,
                                              width: 50,
                                              constraints: BoxConstraints()),
                                          onQtyChanged: (val) {
                                            setState(() {
                                              _customCalo = val;
                                            });
                                          },
                                        ),
                                        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.all(15),
                                            backgroundColor:
                                            ColorTheme.backgroundColor,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                          ),
                                          child: const Text(
                                            'Thêm ngay',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          onPressed: () {
                                            // Navigator.pop(context);
                                            // foodHistoryList.clear();
                                            // foodHistoryList.add(FoodDetailHistory(foods[index].FoodID, netWeight));
                                            // addCaloHistory(foodHistoryList);
                                            // SnackBarErrorMess.show(
                                            //     context, 'Thêm ${foods[index].FoodName} thành công!');
                                          },
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              )),
        ),
      ),
      body: _isLoading
          ? Center(
              child:
                  CircularProgressIndicator(), // Show loading indicator while fetching data
            )
          : RefreshIndicator(
              onRefresh: () async => fetchData(),
              child: Container(
                color: Colors.grey.shade100,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.08,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                          itemCount: categories.length + 1,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (index == 0) {
                                    //  hiển thị tất cả sản phẩm
                                    _selectIndex = 0;
                                    getFood();
                                  } else {
                                    _selectIndex = index;
                                    getFoodsForCategory(
                                        categories[index - 1].FoodCategoryID ??
                                            '');
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(microseconds: 300),
                                margin: EdgeInsets.all(5),
                                width: MediaQuery.of(context).size.width * 0.25,
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                decoration: BoxDecoration(
                                  color: _selectIndex == index
                                      ? Colors.grey.shade50
                                      : Colors.white,
                                  border: _selectIndex == index
                                      ? Border.all(
                                          color: Colors.redAccent, width: 3)
                                      : null,
                                  borderRadius: _selectIndex == index
                                      ? BorderRadius.circular(15)
                                      : BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    index == 0
                                        ? "Tất cả"
                                        : categories[index - 1]
                                                .FoodCategoryName ??
                                            "",
                                    style: GoogleFonts.getFont('Montserrat',
                                        fontWeight: FontWeight.bold,
                                        color: _selectIndex == index
                                            ? Colors.black
                                            : Colors.grey),
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          _searchController.text.isEmpty
                              ? listItem(foods)
                              : listItem(filteredFoods),
                          if (isChecked())
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).size.height *
                                      0.025),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 2 / 3,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.all(15),
                                      backgroundColor:
                                          ColorTheme.backgroundColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    onPressed: () {
                                      addCaloHistory(foodHistoryList);
                                    },
                                    child: Text(
                                      'Thêm ngay - $value calo',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget listItem(List<Food> foods) {
    return Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(6),
        alignment: Alignment.center,
        child: ListView.builder(
            itemCount: foods.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      int netWeight = defaultNetWeight;
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            // backgroundColor: ColorTheme.lightGreenColor,
                            content: Stack(
                              clipBehavior: Clip.none,
                              children: <Widget>[
                                Positioned(
                                  right: -40,
                                  top: -40,
                                  child: InkResponse(
                                    onTap: () {
                                      Navigator.pushReplacement(context,
                                          MaterialPageRoute(builder: (context) => CaloPage(userID: widget.userID, userCalo: widget.userCalo)));
                                    },
                                    child: CircleAvatar(
                                      backgroundColor:
                                      ColorTheme.lightGreenColor,
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image.network(
                                      width: 200,
                                      height: 200,
                                      foods[index].FoodImage ?? "",
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                      const Icon(Icons.image),
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                    Text(
                                      foods[index].FoodName ?? "",
                                      style: GoogleFonts.getFont('Montserrat',
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "${netWeight}g - ${(netWeight * foods[index].FoodCalo) / defaultNetWeight} calo",
                                      style: GoogleFonts.getFont(
                                        'Montserrat',
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                    InputQty.int(
                                      initVal: netWeight,
                                      minVal: 1,
                                      decoration: const QtyDecorationProps(
                                          isBordered: false,
                                          borderShape: BorderShapeBtn.circle,
                                          width: 50,
                                          constraints: BoxConstraints()),
                                      onQtyChanged: (val) {
                                        setState(() {
                                          netWeight = val;
                                        });
                                      },
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.all(15),
                                        backgroundColor:
                                        ColorTheme.backgroundColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: const Text(
                                        'Thêm ngay',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        foodHistoryList.clear();
                                        foodHistoryList.add(FoodDetailHistory(foods[index].FoodID, netWeight));
                                        addCaloHistory(foodHistoryList);
                                        SnackBarErrorMess.show(
                                            context, 'Thêm ${foods[index].FoodName} thành công!');
                                      },
                                    )
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                child: Container(
                    padding: const EdgeInsets.all(6),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.network(
                          width: 50,
                          height: 50,
                          foods[index].FoodImage ?? "",
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.sizeOf(context).width * 0.1),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  foods[index].FoodName ?? "",
                                  style: GoogleFonts.getFont('Montserrat',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "${defaultNetWeight}g - ${foods[index].FoodCalo} calo",
                                  style: GoogleFonts.getFont(
                                    'Montserrat',
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              print(_selectStates[index]);
                              _selectStates[index] = !_selectStates[
                                  index]; // chuyển đồi trạng thái khi chọn icon

                              value += !_selectStates[index]
                                  ? -foods[index].FoodCalo
                                  : foods[index].FoodCalo;



                              _selectStates[index]
                                  ? foodHistoryList.add(FoodDetailHistory(
                                      foods[index].FoodID, defaultNetWeight))
                                  : foodHistoryList.removeWhere((item) =>
                              item.FoodID == foods[index].FoodID && item.NetWeight == defaultNetWeight);

                              print(_selectStates[index]);
                              // print()
                              print(foodHistoryList);
                            });
                            print("Value: " + value.toString());
                          },
                          icon: Icon(
                            _selectStates[index]
                                ? Icons.check_circle_rounded
                                : Icons.add_circle_outline,
                            color: _selectStates[index]
                                ? Colors.green
                                : Colors.grey,
                            size: 30,
                          ),
                        ),
                      ],
                    )),
              );
            }));
  }
}
