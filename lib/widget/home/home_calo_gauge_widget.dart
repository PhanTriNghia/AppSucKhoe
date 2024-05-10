import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthylife/util/color_theme.dart';
import 'package:intl/intl.dart';

import '../../model/CaloHistory.dart';
import '../../model/CustomExercise.dart';
import '../../model/Exercise.dart';
import '../../model/Food.dart';
import '../../page/calo/calo_page.dart';

class HomeCaloGaugeWidget extends StatefulWidget {
  String userID;
  num userCalo;
  HomeCaloGaugeWidget({super.key, required this.userID, required this.userCalo});

  @override
  State<HomeCaloGaugeWidget> createState() => _HomeCaloGaugeWidgetState();
}

class _HomeCaloGaugeWidgetState extends State<HomeCaloGaugeWidget> {

  // num _userCalo = 0;

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchData();
  }

  Future<void> fetchData() async {

    setState(() {
      maxGaugeValue = widget.userCalo.toDouble();

      totalExerciseCalo = 0;
      totalFoodCalo = 0;

      isLoading = true;

      exerciseHistories.clear();
      exercises.clear();

      foodHistories.clear();
      foods.clear();
    });

    await getCustomExercise(widget.userID, getDate(DateTime.now()));

    // Lấy dữ liệu từ Exercise History
    await getCaloHistory(widget.userID, getDate(DateTime.now()));


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

  String getDate(DateTime _selectedDate) {
    return DateFormat('dd/MM/yyyy').format(_selectedDate);
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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigator.push(context,
        //     MaterialPageRoute(builder: (context) => CaloPage(firstfetch: firstfetch)));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CaloPage(userID: widget.userID, userCalo: widget.userCalo),
          ),
        ).then((data) {
          // Update the state or perform actions based on the returned data
          if (data != null) {
            fetchData();
            // Perform actions based on the returned data
          }
        });
      },
      child: Container(
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
                          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
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
                            height:
                            MediaQuery.sizeOf(context).height *
                                0.01,
                          ),
                          AnimatedRadialGauge(
                            duration:
                            const Duration(milliseconds: 2000),
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
                              progressBar:
                              GaugeProgressBar.basic(
                                color: Colors.white,
                              ),
                              transformer: GaugeAxisTransformer
                                  .colorFadeIn(
                                interval: Interval(0.0, 0.3),
                                background: Color(0xFFD9DEEB),
                              ),
                              style: GaugeAxisStyle(
                                thickness: 15,
                                background: Colors.grey,
                                blendColors: false,
                                cornerRadius: Radius.circular(0.0),
                              ),
                              // segments: _controller.segments
                              //     .map((e) => e.copyWith(
                              //     cornerRadius:
                              //     Radius.circular(_controller.segmentsRadius)))
                              //     .toList(),
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
    );
  }
}
