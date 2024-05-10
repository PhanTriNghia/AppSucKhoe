import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthylife/model/CaloHistory.dart';
import 'package:healthylife/model/CustomExercise.dart';
import 'package:healthylife/model/Exercise.dart';
import 'package:healthylife/util/color_theme.dart';
import 'package:intl/intl.dart';

import '../../model/Food.dart';
import '../../util/snack_bar_error_mess.dart';

class CaloHistoryWidget extends StatefulWidget {
  String userID;
  num userCalo;
  Function(String) onDateChanged;

  CaloHistoryWidget({required this.userID, required this.userCalo, required this.onDateChanged});

  @override
  State<CaloHistoryWidget> createState() => _CaloHistoryWidgetState();
}

class _CaloHistoryWidgetState extends State<CaloHistoryWidget> {

  num totalExerciseCalo = 0;
  num totalFoodCalo = 0;

  int defaultDuration = 30;
  int defaultNetWeight = 100;

  double minGaugeValue = 0;
  double maxGaugeValue = 1500;

  List<CustomExercise> customExercises = [];

  List<ExerciseDetailHistory> exerciseHistories = [];
  List<Exercise> exercises = [];

  List<FoodDetailHistory> foodHistories = [];
  List<Food> foods = [];

  bool isLoading = true;
  Future<void>? _dataLoadingFuture;

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dataLoadingFuture = fetchData();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
                primary: ColorTheme.darkGreenColor,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: ColorTheme.darkGreenColor, // Màu cho các nút TextButton
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dataLoadingFuture = fetchData();
        widget.onDateChanged(getDate(_selectedDate));
      });
    }
  }

  String getDate(DateTime _selectedDate) {
    return DateFormat('dd/MM/yyyy').format(_selectedDate);
  }

  String getFormatDuration(num minutes) {
    if(minutes == 0) {
      return '';
    } else {
      int totalSeconds = (minutes * 60).floor();
      int minutesPart = totalSeconds ~/ 60;
      int secondsPart = totalSeconds % 60;
      String formattedDuration = '$minutesPart phút ';

      if (secondsPart > 0) {
        formattedDuration += '$secondsPart giây';
      }

      return formattedDuration + " - ";
    }
  }

  String getRelativeDay(DateTime selectedDate) {
    DateTime today = DateTime.now();
    int difference = today.difference(selectedDate).inDays;

    if (difference == 0) {
      return 'Hôm nay';
    } else if (difference == 1) {
      return 'Hôm qua';
    } else {
      return '${difference} ngày trước';
    }
  }

  // @override
  // void didUpdateWidget(CaloHistoryWidget oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (widget.userID != oldWidget.userID ||
  //       _selectedDate != _selectedDate) {
  //     _dataLoadingFuture =
  //         fetchData(); // Fetch data again if userID or dateHistory changes
  //   }
  // }

  Future<void> fetchData() async {
    setState(() {
      maxGaugeValue = widget.userCalo.toDouble();

      totalExerciseCalo = 0;
      totalFoodCalo = 0;

      isLoading = true;

      customExercises.clear();

      exerciseHistories.clear();
      exercises.clear();

      foodHistories.clear();
      foods.clear();
    });

    await getUserCalo(widget.userID, getDate(_selectedDate));

    await getCustomExercise(widget.userID, getDate(_selectedDate));

    // Lấy dữ liệu từ Exercise History
    await getCaloHistory(widget.userID, getDate(_selectedDate));


    if (exerciseHistories.isNotEmpty || foodHistories.isNotEmpty) {
      await getExerciseAndFood();
    }

    // Tính tổng calo nạp
    for(var i = 0; i < foodHistories.length; i++) {
      totalFoodCalo += (foodHistories[i].NetWeight * foods[i].FoodCalo) / defaultNetWeight;
    }

    // Tính tổng calo tiêu hao
    for(var i = 0; i < exerciseHistories.length; i++) {
      totalExerciseCalo += (exerciseHistories[i].Duration * exercises[i].ExerciseCalo) / defaultDuration;
    }

    // Tính tổng calo tiêu hao (custom)
    for(var i = 0; i < customExercises.length; i++) {
      totalExerciseCalo += customExercises[i].CustomExerciseCalo;
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> getUserCalo(String userID, String dateHistory) async {
    final userDetailQuerySnapshot = await FirebaseFirestore.instance
        .collection('UserDetail')
        .where('UserID', isEqualTo: userID)
        .where('DateHistory', isEqualTo: dateHistory)
        .get();

    if (userDetailQuerySnapshot.docs.isNotEmpty) {
      final document = userDetailQuerySnapshot.docs.first;

      // lấy id document
      final _userCalo = document['UserCalo'];

      setState(() {
        maxGaugeValue = _userCalo;
      });

      // Nếu dữ liệu chưa có sẽ tạo rỗng
    } else {
      setState(() {
        maxGaugeValue = widget.userCalo.toDouble();
      });
    }
  }

  Future<void> getCustomExercise(String userID, String dateHistory) async {
    try {
      // lấy dữ liệu CaloHistory thông qua userID và date history
      final customExerciseQuerySnapshot = await FirebaseFirestore.instance
          .collection('CustomExercise')
          .where('UserID', isEqualTo: userID)
          .where('DateHistory', isEqualTo: dateHistory)
          .get();

      // Nếu dữ liệu tồn tại
      if (customExerciseQuerySnapshot.docs.isNotEmpty) {

        customExercises = customExerciseQuerySnapshot.docs.map((doc) {
          return CustomExercise.fromFirestore(doc);
        }).toList();

        // Nếu dữ liệu chưa có sẽ tạo rỗng
      } else {



      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<void> getCaloHistory(String userID, String dateHistory) async {
    try {
      // lấy dữ liệu CaloHistory thông qua userID và date history
      final caloHistoryQuerySnapshot = await FirebaseFirestore.instance
          .collection('CaloHistory')
          .where('UserID', isEqualTo: userID)
          .where('DateHistory', isEqualTo: dateHistory)
          .get();

      // Nếu dữ liệu tồn tại
      if (caloHistoryQuerySnapshot.docs.isNotEmpty) {
        // lấy id document
        final document = caloHistoryQuerySnapshot.docs.first;

        exerciseHistories = List<ExerciseDetailHistory>.from(
            document.data()['ExerciseDetailHistory']?.map((e) => ExerciseDetailHistory(
              e['ExerciseID'] ?? '',
              e['Duration'] ?? 0,
            )) ??
                []);

        // lấy List dữ liệu FoodID và truyền vào tham số foodHistories
        foodHistories = List<FoodDetailHistory>.from(
            document.data()['FoodDetailHistory']?.map((e) => FoodDetailHistory(
              e['FoodID'] ?? '',
              e['NetWeight'] ?? 0,
            )) ??
                []);

        // Nếu dữ liệu chưa có sẽ tạo rỗng
      } else {
        exerciseHistories = [];
        foodHistories = [];
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<void> getExerciseAndFood() async {
    List<Exercise> fetchedExercises = [];
    List<Food> fetchedFoods = [];

    for (ExerciseDetailHistory exerciseID in exerciseHistories) {
      final exerciseDocSnapshot = await FirebaseFirestore.instance
          .collection('Exercise')
          .doc(exerciseID.ExerciseID)
          .get();

      if (exerciseDocSnapshot.exists) {
        Exercise exerciseItem = Exercise.fromFirestore(exerciseDocSnapshot);
        fetchedExercises.add(exerciseItem);
      }
    }

    for (FoodDetailHistory foodID in foodHistories) {
      final foodDocSnapshot = await FirebaseFirestore.instance
          .collection('Food')
          .doc(foodID.FoodID)
          .get();

      if (foodDocSnapshot.exists) {
        Food foodItem = Food.fromFirestore(foodDocSnapshot);
        fetchedFoods.add(foodItem);
      }
    }
    setState(() {
      exercises = fetchedExercises;
      foods = fetchedFoods;
    });
  }

  Future<void> removeCustomExercises(String customExerciseID, int index) async {
    final customExerciseQuerySnapshot = await FirebaseFirestore.instance
        .collection('CustomExercise')
        .where('CustomExerciseID', isEqualTo: customExerciseID)
        .get();

    if (customExerciseQuerySnapshot.docs.isNotEmpty) {
      final document = customExerciseQuerySnapshot.docs.first;

      String itemName = '';

        CustomExercise removedCustomExercise = customExercises[index];

        await FirebaseFirestore.instance
            .collection('CustomExercise')
            .doc(document.id)
            .delete();

        itemName = removedCustomExercise.CustomExerciseName;

        totalExerciseCalo -= removedCustomExercise.CustomExerciseCalo;

        setState(() {
          customExercises.removeAt(index);
        });

      SnackBarErrorMess.show(
          context, 'Xóa ${itemName} thành công!');


    } else {
      SnackBarErrorMess.show(context, 'Không thể tìm thấy lịch sử calo.');
    }
  }

  Future<void> removeExerciseAndFood(int index, bool itemSelected) async {
    final caloHistoryQuerySnapshot = await FirebaseFirestore.instance
        .collection('CaloHistory')
        .where('UserID', isEqualTo: widget.userID)
        .where('DateHistory', isEqualTo: getDate(_selectedDate))
        .get();

    if (caloHistoryQuerySnapshot.docs.isNotEmpty) {
      final document = caloHistoryQuerySnapshot.docs.first;

      String itemName = '';
      // itemSelected = true (Exercise)
      if (itemSelected) {
        ExerciseDetailHistory removedExercise = exerciseHistories[index];

        await FirebaseFirestore.instance
            .collection('CaloHistory')
            .doc(document.id)
            .update({
          'ExerciseDetailHistory': FieldValue.arrayRemove([
            {'ExerciseID': removedExercise.ExerciseID, 'Duration': removedExercise.Duration}
          ])
        });

        itemName = exercises[index].ExerciseName;

        totalExerciseCalo -= (exerciseHistories[index].Duration * exercises[index].ExerciseCalo) / defaultDuration;

        setState(() {
          exerciseHistories.removeAt(index);
          exercises.removeAt(index);
        });
      } else {
        FoodDetailHistory removedFood = foodHistories[index];

        await FirebaseFirestore.instance
            .collection('CaloHistory')
            .doc(document.id)
            .update({
          'FoodDetailHistory': FieldValue.arrayRemove([
            {'FoodID': removedFood.FoodID, 'NetWeight': removedFood.NetWeight}
          ])
        });

        itemName = foods[index].FoodName;

        totalFoodCalo -= (foodHistories[index].NetWeight * foods[index].FoodCalo) / defaultNetWeight;


        setState(() {
          foodHistories.removeAt(index);
          foods.removeAt(index);
        });
      }

      SnackBarErrorMess.show(
          context, 'Xóa ${itemName} thành công!');


    } else {
      SnackBarErrorMess.show(context, 'Không thể tìm thấy lịch sử calo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Container(
              color: ColorTheme.darkGreenColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * 0.02),
                        child: Text(
                          getRelativeDay(_selectedDate),
                          style: GoogleFonts.getFont(
                            'Montserrat',
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy').format(_selectedDate),
                              style: GoogleFonts.getFont(
                                'Montserrat',
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 20,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                              ),
                              onPressed: () => _selectDate(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              totalFoodCalo.toStringAsFixed(0),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.getFont(
                                'Montserrat',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                            Text(
                              'Đã nạp',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.getFont(
                                'Montserrat',
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Cần nạp',
                              style: GoogleFonts.getFont(
                                'Montserrat',
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.sizeOf(context).height * 0.01,
                            ),
                            AnimatedRadialGauge(
                              duration: const Duration(milliseconds: 2000),
                              builder: (context, _, value) => RadialGaugeLabel(
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                value: maxGaugeValue - value,
                              ),
                              value: totalFoodCalo.toDouble() - totalExerciseCalo.toDouble(),
                              radius: 60,
                              // Chỉnh độ to nhỏ của gauge
                              curve: Curves.elasticOut,
                              axis: GaugeAxis(
                                min: totalFoodCalo.toDouble() - totalExerciseCalo.toDouble() < 0 ? minGaugeValue : 0,
                                max: totalFoodCalo.toDouble() - totalExerciseCalo.toDouble() > maxGaugeValue ? totalFoodCalo.toDouble() - totalExerciseCalo.toDouble() : maxGaugeValue,
                                degrees: 360,
                                pointer: null,
                                progressBar: const GaugeProgressBar.basic(
                                  color: Colors.white,
                                ),
                                transformer: const GaugeAxisTransformer.colorFadeIn(
                                  interval: Interval(0.0, 0.3),
                                  background: Color(0xFFD9DEEB),
                                ),
                                style: const GaugeAxisStyle(
                                  thickness: 15,
                                  background: Colors.grey,
                                  blendColors: false,
                                  cornerRadius: Radius.circular(0.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              totalExerciseCalo.toStringAsFixed(0),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.getFont(
                                'Montserrat',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                            Text(
                              'Tiêu hao',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.getFont(
                                'Montserrat',
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),

                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        FutureBuilder<void>(
          future: _dataLoadingFuture,
          builder: (context, snapshot) {
            // Check dữ liệu đã nạp xong chưa
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Lỗi dữ liệu, vui lòng thử lại',
                  style: GoogleFonts.getFont(
                    'Montserrat',
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tiêu calo",
                    style: GoogleFonts.getFont('Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  if(exercises.isEmpty && customExercises.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
                    child: Center(
                      child: Text(
                        'Bạn đã tập gì? Hãy tiêu hao calo ngay!',
                        style: GoogleFonts.getFont(
                          'Montserrat',
                          color: Colors.grey,
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                  else

                    // Custom calo
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: customExercises.length,
                      itemBuilder: (context, index) {
                        if (index >= customExercises.length) {
                          // Trả về empty widget khi index > range
                          return SizedBox.shrink();
                        }

                        final customExercise = customExercises[index];

                        return Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.endToStart,
                          // Kéo sang phải đề remove dữ liệu
                          onDismissed: (direction) {
                            removeCustomExercises(customExercise.CustomExerciseID, index);
                          },
                          background: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                colors: [
                                  ColorTheme.darkGreenColor,
                                  ColorTheme.lightGreenColor
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            alignment: Alignment.centerRight,
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          child: buildCustomExerciseItem(
                              customExercise, index), // Widget hiển thị các item food
                        );
                      },
                    ),

                    // Calo thường
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      if (index >= exercises.length) {
                        // Trả về empty widget khi index > range
                        return SizedBox.shrink();
                      }

                      final exercise = exercises[index];

                      return Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.endToStart,
                        // Kéo sang phải đề remove dữ liệu
                        onDismissed: (direction) {
                          removeExerciseAndFood(index, true);
                        },
                        background: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(
                              colors: [
                                ColorTheme.darkGreenColor,
                                ColorTheme.lightGreenColor
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          alignment: Alignment.centerRight,
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        child: buildExerciseItem(
                            exercise, index), // Widget hiển thị các item food
                      );
                    },
                  ),
                  Text(
                    "Nạp calo",
                    style: GoogleFonts.getFont('Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  if(foods.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
                      child: Center(
                        child: Text(
                          'Bạn đã ăn gì? Hãy bổ sung calo ngay!',
                          style: GoogleFonts.getFont(
                            'Montserrat',
                            color: Colors.grey,
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: foods.length,
                    itemBuilder: (context, index) {
                      if (index >= foods.length) {
                        // Trả về empty widget khi index > range
                        return SizedBox.shrink();
                      }

                      final food = foods[index];
                      return Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.endToStart,
                        // Kéo sang phải đề remove dữ liệu
                        onDismissed: (direction) {
                          removeExerciseAndFood(index, false);
                        },
                        background: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(
                              colors: [
                                ColorTheme.darkGreenColor,
                                ColorTheme.lightGreenColor
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          alignment: Alignment.centerRight,
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        child: buildFoodItem(
                            food, index), // Widget hiển thị các item food
                      );
                    },
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget buildCustomExerciseItem(CustomExercise customExercise, int index) {
    return Container(
      padding: const EdgeInsets.all(6),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Image.network(
          //   exercise.ExerciseImage ?? "",
          //   width: 50,
          //   height: 50,
          //   errorBuilder: (context, error, stackTrace) =>
          //   const Icon(Icons.image),
          // ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customExercise.CustomExerciseName ?? "",
                  style: GoogleFonts.getFont('Montserrat',
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${getFormatDuration(customExercise.CustomExerciseDuration)}${customExercise.CustomExerciseCalo.toStringAsFixed(0)} calo",
                  style: GoogleFonts.getFont('Montserrat',
                      fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                removeCustomExercises(customExercise.CustomExerciseID, index);
              });
            },
            icon: Icon(
              Icons.remove_circle_outline,
              color: Colors.grey,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildExerciseItem(Exercise exercise, int index) {
    return Container(
      padding: const EdgeInsets.all(6),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Image.network(
          //   exercise.ExerciseImage ?? "",
          //   width: 50,
          //   height: 50,
          //   errorBuilder: (context, error, stackTrace) =>
          //   const Icon(Icons.image),
          // ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.ExerciseName ?? "",
                  style: GoogleFonts.getFont('Montserrat',
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${exerciseHistories[index].Duration} phút - ${((exerciseHistories[index].Duration * exercise.ExerciseCalo) / 30).toStringAsFixed(0)} calo",
                  style: GoogleFonts.getFont('Montserrat',
                      fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                removeExerciseAndFood(index, true);
              });
            },
            icon: Icon(
              Icons.remove_circle_outline,
              color: Colors.grey,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFoodItem(Food food, int index) {
    return Container(
      padding: const EdgeInsets.all(6),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.network(
            food.FoodImage ?? "",
            width: 50,
            height: 50,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.image),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                food.FoodName ?? "",
                style: GoogleFonts.getFont('Montserrat',
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "${foodHistories[index].NetWeight}g - ${((foodHistories[index].NetWeight * food.FoodCalo) / 100).toStringAsFixed(0)} calo",
                style: GoogleFonts.getFont('Montserrat',
                    fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              setState(() {
                removeExerciseAndFood(index, false);
              });
            },
            icon: Icon(
              Icons.remove_circle_outline,
              color: Colors.grey,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}
