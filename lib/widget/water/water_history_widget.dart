import 'dart:core';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthylife/util/color_theme.dart';
import 'package:intl/intl.dart';

import '../../model/WaterHistory.dart';
import '../../util/snack_bar_error_mess.dart';

class WaterHistoryWidget extends StatefulWidget {
  String userID;

  WaterHistoryWidget({required this.userID});

  @override
  State<WaterHistoryWidget> createState() => _WaterHistoryWidgetState();
}

class _WaterHistoryWidgetState extends State<WaterHistoryWidget> {
  num totalWater = 0;

  int defaultWater = 200;

  double minGaugeValue = 0;
  double maxGaugeValue = 2000;

  bool isLoading = true;

  List<bool> imageStates = List.generate(11, (index) => true);
  final String image1 = 'assets/images/empty_glass.png';
  final String image2 = 'assets/images/water_glass.png';


  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void CalculateWater(int index, num _capacity) {
    if (!imageStates[index]) {
      totalWater += _capacity;
    } else {
      totalWater -= _capacity;
    }

    print(totalWater);
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    await getWaterHistory(widget.userID, getDate(_selectedDate));

    setState(() {
      isLoading = false;
    });
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
                onSurface: Colors.black),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    ColorTheme.darkGreenColor, // Màu cho các nút TextButton
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
        fetchData();
      });
    }
  }

  String getDate(DateTime _selectedDate) {
    return DateFormat('dd/MM/yyyy').format(_selectedDate);
  }

  String getRelativeDay(DateTime selectedDate) {
    DateTime today = DateTime.now();
    int difference = today.difference(selectedDate).inDays;

    if (difference == 0) {
      return 'Hôm nay';
    } else if (difference == 1) {
      return 'Hôm qua';
    } else {
      return '${difference} ngày sau';
    }
  }

  Future<void> getWaterHistory(String userID, String dateHistory) async {
    try {
      setState(() {
        totalWater = 0;
        imageStates = List.generate(11, (index) => true);
      });

      final waterHistoryCollection =
          FirebaseFirestore.instance.collection('WaterHistory');

      final waterHistoryQuerySnapshot = await waterHistoryCollection
          .where('UserID', isEqualTo: userID)
          .where('DateHistory', isEqualTo: dateHistory)
          .get();

      if (waterHistoryQuerySnapshot.docs.isNotEmpty) {
        final document = waterHistoryQuerySnapshot.docs.first;

        final _capacity = document['Capacity'];

        double _isFilled = _capacity / defaultWater;

        if (_isFilled > 11) _isFilled = 11;

        for (int i = 0; i < _isFilled; i++) {
          setState(() {
            imageStates[i] = false;
          });
        }

        setState(() {
          totalWater = _capacity;
        });

        // Nếu dữ liệu chưa có sẽ tạo dữ liệu mới
      } else {
        final uid = waterHistoryCollection.doc().id;

        WaterHistory waterHistory = WaterHistory(uid, userID, dateHistory, 0);

        await waterHistoryCollection
            .doc(waterHistory.WaterHistoryID)
            .set(waterHistory.toJson());
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<void> updateCapacity(String userID, String dateHistory) async {
    final waterHistoryCollection =
        FirebaseFirestore.instance.collection('WaterHistory');

    final waterHistoryQuerySnapshot = await waterHistoryCollection
        .where('UserID', isEqualTo: userID)
        .where('DateHistory', isEqualTo: dateHistory)
        .get();

    if (waterHistoryQuerySnapshot.docs.isNotEmpty) {
      final document = waterHistoryQuerySnapshot.docs.first;

      await waterHistoryCollection
          .doc(document.id)
          .update({'Capacity': totalWater});

      // Nếu dữ liệu chưa có sẽ tạo rỗng
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                            totalWater.toString(),
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
                            value: totalWater.toDouble(),
                            radius: 60,
                            // Chỉnh độ to nhỏ của gauge
                            curve: Curves.elasticOut,
                            axis: GaugeAxis(
                              min: minGaugeValue,
                              max: maxGaugeValue,
                              degrees: 360,
                              pointer: null,
                              progressBar: const GaugeProgressBar.basic(
                                color: Colors.white,
                              ),
                              transformer:
                                  const GaugeAxisTransformer.colorFadeIn(
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
                            (maxGaugeValue - totalWater) >= 0
                                ? (maxGaugeValue - totalWater)
                                    .toStringAsFixed(0)
                                : "0",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.getFont(
                              'Montserrat',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          Text(
                            'Cần nạp',
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
      Container(
        child: Row(
          children: List.generate(
              11,
              (index) => GestureDetector(
                    onTap: () {
                      setState(() {
                        imageStates[index] = !imageStates[index];
                        CalculateWater(index, defaultWater);
                        updateCapacity(
                            widget.userID, getDate(_selectedDate));
                      });
                    },
                    child: Image.asset(
                      imageStates[index]
                          ? image1 // Replace with your first image asset
                          : image2, // Replace with your second image asset
                      height: MediaQuery.of(context).size.height * (1 / 12),
                      width: MediaQuery.of(context).size.width * (1 / 12),
                    ),
                  )),
        ),
      ),
      Divider(height: 0, thickness: 2, color: Colors.grey),
      ListTile(
        leading: Icon(Icons.healing),
        title: Text(
          'Tình trạng',
          style: GoogleFonts.getFont(
            'Montserrat',
            color: Colors.grey,
            fontWeight: FontWeight.normal,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          totalWater > 2000
              ? "Thừa nước"
              : totalWater == 2000
                  ? "Đủ nước"
                  : "Thiếu nước",
          style: GoogleFonts.getFont(
            'Montserrat',
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      Divider(height: 0, thickness: 2, color: Colors.grey),
    ]);
  }
}
