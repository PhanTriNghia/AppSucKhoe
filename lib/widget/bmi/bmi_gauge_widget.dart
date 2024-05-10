import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthylife/util/color_theme.dart';
import 'package:intl/intl.dart';

class BMIGaugeWidget extends StatefulWidget {
  String userID;

  BMIGaugeWidget({super.key, required this.userID});

  @override
  State<BMIGaugeWidget> createState() => _BMIGaugeWidgetState();
}

class _BMIGaugeWidgetState extends State<BMIGaugeWidget> {
  DateTime _selectedDate = DateTime.now();

  num userBMI = 0;

  num userWeight = 0;
  num userHeight = 0;

  bool isExistValue = false;

  Future<void>? _dataLoadingFuture;

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
        _dataLoadingFuture = fetchData();
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
      return '${difference} ngày trước';
    }
  }

  String checkStatus(num bmi) {
    return bmi < 18.5 ? "Gầy"
        : bmi < 25 ? "Bình thường"
        : bmi < 30 ? "Thừa cân"
        : bmi < 35 ? "Béo phì cấp độ 1"
        : bmi < 40 ? "Béo phì cấp độ 2"
        : ""; // Rỗng
  }

  Future<void> fetchData() async {
    setState(() {
      userWeight = 0;
      userHeight = 0;

      isExistValue = false;
    });

    // Lấy dữ liệu từ Exercise History
    await getUserDetail(widget.userID, getDate(_selectedDate));
  }

  Future<void> getUserDetail(String userID, String dateHistory) async {
    try {
      // lấy dữ liệu CaloHistory thông qua userID và date history
      final userDetailQuerySnapshot = await FirebaseFirestore.instance
          .collection('UserDetail')
          .where('UserID', isEqualTo: userID)
          .where('DateHistory', isEqualTo: dateHistory)
          .get();

      // Nếu dữ liệu tồn tại
      if (userDetailQuerySnapshot.docs.isNotEmpty) {
        // lấy id document
        final document = userDetailQuerySnapshot.docs.first;

        final height = document['UserHeight'];
        final weight = document['UserWeight'];
        final BMI = document['UserBMI'];

        setState(() {
          userHeight = height;
          userWeight = weight;
          userBMI = BMI;

          isExistValue = true;
        });
      } else {
        setState(() {
          userBMI = 0;

          isExistValue = false;
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
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
                            horizontal:
                                MediaQuery.of(context).size.width * 0.02),
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: MediaQuery.sizeOf(context).height * 0.01,
                            ),
                            AnimatedRadialGauge(
                              duration: const Duration(milliseconds: 2000),
                              builder: (context, _, value) => RadialGaugeLabel(
                                labelProvider: const GaugeLabelProvider.value(
                                    fractionDigits: 1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                                value: value,
                              ),
                              value: userBMI.toDouble(),
                              radius: 150,
                              // Chỉnh độ to nhỏ của gauge
                              curve: Curves.elasticOut,
                              axis: GaugeAxis(
                                min: 0,
                                max: 40,
                                degrees: 180,
                                pointer: GaugePointer.triangle(
                                  width: 35,
                                  height: 35,
                                  borderRadius: 35 * 0.125,
                                  color: Colors.white,
                                  position: const GaugePointerPosition.surface(
                                    offset: Offset(0, 35 * 0.6),
                                  ),
                                  border: GaugePointerBorder(
                                    color: ColorTheme.darkGreenColor,
                                    width: 35 * 0.125,
                                  ),
                                ),
                                // progressBar: const GaugeProgressBar.basic(
                                //   color: Colors.white,
                                // ),
                                transformer:
                                    const GaugeAxisTransformer.colorFadeIn(
                                  interval: Interval(0.0, 0.3),
                                  background: Color(0xFFD9DEEB),
                                ),
                                style: const GaugeAxisStyle(
                                  thickness: 35,
                                  background: Colors.grey,
                                  blendColors: false,
                                  cornerRadius: Radius.circular(0.0),
                                ),
                                progressBar: null,
                                segments: [
                                  GaugeSegment(
                                    from: 0,
                                    to: 18.5,
                                    color: ColorTheme.gaugeColor1,
                                    cornerRadius: Radius.zero,
                                  ),
                                  GaugeSegment(
                                    from: 18.5,
                                    to: 25.0,
                                    color: ColorTheme.gaugeColor2,
                                    cornerRadius: Radius.zero,
                                  ),
                                  GaugeSegment(
                                    from: 25.0,
                                    to: 30.0,
                                    color: ColorTheme.gaugeColor3,
                                    cornerRadius: Radius.zero,
                                  ),
                                  GaugeSegment(
                                    from: 30.0,
                                    to: 35.0,
                                    color: ColorTheme.gaugeColor4,
                                    cornerRadius: Radius.zero,
                                  ),
                                  GaugeSegment(
                                    from: 35.0,
                                    to: 40,
                                    color: ColorTheme.gaugeColor5,
                                    cornerRadius: Radius.zero,
                                  ),
                                ],
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
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
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
            } else if (!isExistValue) {
              return Center(
                child: Text(
                  'Không tìm thấy dữ liệu của bạn',
                  style: GoogleFonts.getFont(
                    'Montserrat',
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              );
            } else {
              return ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
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
                      checkStatus(userBMI),
                      style: GoogleFonts.getFont(
                        'Montserrat',
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    // trailing: Icon(Icons.more_vert),
                  ),
                  Divider(height: 0, thickness: 2, color: Colors.grey),
                  ListTile(
                    leading: Icon(Icons.fitness_center),
                    title: Text(
                      'Cân nặng',
                      style: GoogleFonts.getFont(
                        'Montserrat',
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      "${userWeight} kg",
                      style: GoogleFonts.getFont(
                        'Montserrat',
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    // trailing: Icon(Icons.more_vert),
                  ),
                  Divider(height: 0, thickness: 2, color: Colors.grey),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text(
                      'Chiều cao',
                      style: GoogleFonts.getFont(
                        'Montserrat',
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      "${userHeight} cm",
                      style: GoogleFonts.getFont(
                        'Montserrat',
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    // trailing: Icon(Icons.more_vert),
                  ),
                  Divider(height: 0, thickness: 2, color: Colors.grey),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                ],
              );
            }
          },
        ),
      ],
    );
  }
}
