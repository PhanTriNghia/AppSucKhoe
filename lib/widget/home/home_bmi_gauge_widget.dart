import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthylife/util/color_theme.dart';
import 'package:intl/intl.dart';

import '../../page/bmi/bmi_page.dart';

class HomeBMIGaugeWidget extends StatefulWidget {

  String userID;

  HomeBMIGaugeWidget({super.key, required this.userID});

  @override
  State<HomeBMIGaugeWidget> createState() => _HomeBMIGaugeWidgetState();
}

class _HomeBMIGaugeWidgetState extends State<HomeBMIGaugeWidget> {

  num userBMI = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {

    setState(() {
      userBMI = 0;
    });

    String currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    await getUserDetail(widget.userID, currentDate);

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
        final BMI = document['UserBMI'];

        setState(() {
          userBMI = BMI;
        });
      } else {
        await Future.delayed(Duration(seconds: 1));
        await getUserDetail(userID, dateHistory);
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  String checkStatus(num bmi) {
    return bmi > 0 && bmi < 18.5 ? "GẦY"
        : bmi < 25 ? "BÌNH THƯỜNG"
        : bmi < 30 ? "THỪA CÂN"
        : bmi < 35 ? "BÉO PHÌ CẤP ĐỘ 1"
        : bmi < 40 ? "BÉO PHÌ CẤP ĐỘ 2"
        : ""; // Rỗng
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => BMIPage(userID: widget.userID)));
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
                          value: userBMI.toDouble(),
                          radius: 70,
                          // Chỉnh độ to nhỏ của gauge
                          curve: Curves.elasticOut,
                          axis: GaugeAxis(
                            min: 0,
                            max: 40,
                            degrees: 180,
                            pointer: GaugePointer.triangle(
                              width: 20,
                              height: 20,
                              borderRadius: 20 * 0.125,
                              color: ColorTheme.darkGreenColor,
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
                            style: const GaugeAxisStyle(
                              thickness: 20,
                              background: Colors.grey,
                              blendColors: false,
                              cornerRadius:
                              Radius.circular(0.0),
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
                        SizedBox(height: MediaQuery.of(context).size.height *0.02),
                        Text(
                          checkStatus(userBMI),
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
