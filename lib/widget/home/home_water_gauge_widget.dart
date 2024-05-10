import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthylife/page/water/water.dart';
import 'package:intl/intl.dart';

import '../../util/color_theme.dart';

class HomeWaterGaugeWidget extends StatefulWidget {
  String userID;
  HomeWaterGaugeWidget({super.key, required this.userID});

  @override
  State<HomeWaterGaugeWidget> createState() => _HomeWaterGaugeWidgetState();
}

class _HomeWaterGaugeWidgetState extends State<HomeWaterGaugeWidget> {

  num totalWater = 0;

  double minGaugeValue = 0;
  double maxGaugeValue = 2000;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getWaterHistory(widget.userID, DateFormat('dd/MM/yyyy').format(DateTime.now()));
  }

  Future<void> getWaterHistory(String userID, String dateHistory) async {
    try {

      final waterHistoryCollection =
      FirebaseFirestore.instance.collection('WaterHistory');

      final waterHistoryQuerySnapshot = await waterHistoryCollection
          .where('UserID', isEqualTo: userID)
          .where('DateHistory', isEqualTo: dateHistory)
          .get();

      if (waterHistoryQuerySnapshot.docs.isNotEmpty) {
        final document = waterHistoryQuerySnapshot.docs.first;

        final _capacity = document['Capacity'];

        setState(() {
          totalWater = _capacity;
        });

        // Nếu dữ liệu chưa có sẽ tạo dữ liệu mới
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WaterPage(userID: widget.userID),
          ),
        ).then((data) {
          // Update the state or perform actions based on the returned data
          if (data != null) {
            getWaterHistory(widget.userID, DateFormat('dd/MM/yyyy').format(DateTime.now()));
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
            color: ColorTheme.gaugeColor1,
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
                            height: MediaQuery.sizeOf(context).height * 0.01,
                          ),
                          AnimatedRadialGauge(
                            duration: const Duration(milliseconds: 2000),
                            builder: (context, _, value) => RadialGaugeLabel(
                              style: TextStyle(
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
                              progressBar: GaugeProgressBar.basic(
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
    );
  }
}
