import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthylife/model/UserHealthy.dart';
import 'package:healthylife/page/fat/fat_page.dart';
import 'package:intl/intl.dart';

import '../../util/color_theme.dart';
import '../../util/fat_gauge_check.dart';

class HomeFatGaugeWidget extends StatefulWidget {
  UserHealthy userHealthy;

  HomeFatGaugeWidget({super.key, required this.userHealthy});

  @override
  State<HomeFatGaugeWidget> createState() => _HomeFatGaugeWidgetState();
}

class _HomeFatGaugeWidgetState extends State<HomeFatGaugeWidget> {

  num userFat = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {

    setState(() {
      userFat = 0;
    });

    String currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    await getUserDetail(widget.userHealthy.UserID, currentDate);

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
        final Fat = document['UserFat'];

        setState(() {
          userFat = Fat;
        });
      } else {
        await Future.delayed(Duration(seconds: 1));
        await getUserDetail(userID, dateHistory);
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  String checkStatus(num fat, int age, String gender) {
    int fatThreshold;

    if (gender == 'Nam') {
      if (age >= 18 && age <= 39)
        fatThreshold = 11;
      else if (age >= 40 && age <= 59)
        fatThreshold = 12;
      else if (age >= 60)
        fatThreshold = 14;
      else
        return "";
    } else {
      if (age >= 18 && age <= 39)
        fatThreshold = 21;
      else if (age >= 40 && age <= 59)
        fatThreshold = 22;
      else if (age >= 60)
        fatThreshold = 23;
      else
        return "";
    }

    if (fat < fatThreshold)
      return "DƯỚI MỨC TIÊU CHUẨN";
    else if (fat < fatThreshold + 13)
      return "MỨC TIÊU CHUẨN";
    else if (fat < fatThreshold + 18)
      return "CAO HƠN MỨC TIÊU CHUẨN";
    else
      return "THỪA MỠ NHIỀU";
  }

  int getAge() {
    DateTime birthDate = DateFormat('dd/MM/yyyy').parse(widget.userHealthy.UserBirthday);
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month && currentDate.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => FatPage(userHealthy: widget.userHealthy)));
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
                width: MediaQuery.of(context).size.width / 2 * 0.8,
                color: Colors.white,
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.02),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AnimatedRadialGauge(
                          duration: const Duration(
                              milliseconds: 2000),
                          builder: (context, _, value) =>
                              RadialGaugeLabel(
                                labelProvider:
                                const GaugeLabelProvider.value(
                                    fractionDigits: 1),
                                style: const TextStyle(
                                  color: Color(0xFFDE5044),
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                                value: value,
                              ),
                          value: userFat.toDouble(),
                          radius: 70,
                          // Chỉnh độ to nhỏ của gauge
                          curve: Curves.elasticOut,
                          axis: GaugeAxis(
                            min: 0,
                            max: 45,
                            degrees: 180,
                            pointer: GaugePointer.triangle(
                              width: 20,
                              height: 20,
                              borderRadius: 20 * 0.125,
                              color: Color(0xFFDE5044),
                              position:
                              GaugePointerPosition.surface(
                                offset: Offset(0, 20 * 0.6),
                              ),
                              border: GaugePointerBorder(
                                color: Colors.white,
                                width: 20 * 0.125,
                              ),
                            ),
                            // progressBar: const GaugeProgressBar.basic(
                            //   color: Colors.white,
                            // ),
                            transformer:
                            const GaugeAxisTransformer
                                .colorFadeIn(
                              interval: Interval(0.0, 0.3),
                              background: Color(0xFFD9DEEB),
                            ),
                            style: GaugeAxisStyle(
                              thickness: 20,
                              background: Colors.grey,
                              blendColors: false,
                              cornerRadius:
                              Radius.circular(0.0),
                            ),
                            progressBar: null,
                            segments: FatGaugeCheck('Nam', getAge()).fatGagugeSegment(),
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height *0.02),
                        Text(
                          checkStatus(userFat, getAge(), 'Nam'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.getFont(
                            'Montserrat',
                            color: ColorTheme.darkGreenColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
