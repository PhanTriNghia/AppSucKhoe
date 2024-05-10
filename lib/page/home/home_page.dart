import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthylife/util/color_theme.dart';
import 'package:healthylife/widget/home/home_bmi_gauge_widget.dart';
import 'package:healthylife/widget/home/home_exercise_widget.dart';
import 'package:healthylife/widget/home/home_fat_gauge_widget.dart';
import 'package:healthylife/widget/home/home_water_gauge_widget.dart';
import 'package:intl/intl.dart';

import '../../model/UserDetail.dart';
import '../../model/UserHealthy.dart';
import '../../widget/home/home_calo_gauge_widget.dart';
import '../exercise/exercise_page.dart';

import '../home/test.dart';

class HomePage extends StatefulWidget {
  UserHealthy userHealthy;
  UserDetail userDetail;

  HomePage({required this.userHealthy, required this.userDetail});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void refresh() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            "Xin chào, ${widget.userHealthy.UserName}",
            style: GoogleFonts.getFont(
              'Montserrat',
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
        ),
        backgroundColor: ColorTheme.lightGreenColor,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.025),
                child: Text(
                  'Chỉ số Calories',
                  style: GoogleFonts.getFont(
                    'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              HomeCaloGaugeWidget(userID: widget.userHealthy.UserID, userCalo: widget.userDetail.UserCalo),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Chỉ số BMI
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.025),
                        child: Text(
                          'Chỉ số BMI',
                          style: GoogleFonts.getFont(
                            'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      HomeBMIGaugeWidget(userID: widget.userHealthy.UserID),
                    ],
                  ),
                  //-----------

                  // Chỉ số Fat
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.025),
                        child: Text(
                          'Chỉ số Fat',
                          style: GoogleFonts.getFont(
                            'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      HomeFatGaugeWidget(userHealthy: widget.userHealthy),
                    ],
                  ),
                  //-----------
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.025),
                child: Text(
                  'Bạn nên uống bao nhiêu nước',
                  style: GoogleFonts.getFont(
                    'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              HomeWaterGaugeWidget(userID: widget.userHealthy.UserID),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    'Bài tập gợi ý hôm nay',
                    style: GoogleFonts.getFont(
                      'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ExercisePage(
                                    userID: widget.userHealthy.UserID, dateHistory: DateFormat('dd/MM/yyyy').format(DateTime.now()), userCalo: widget.userDetail.UserCalo)));
                      },
                      child: Text(
                        'Xem tất cả',
                        textAlign: TextAlign.end,
                        style: GoogleFonts.getFont(
                          'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              HomeExerciseWidget(),
              // Container(
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(15),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.grey.withOpacity(0.5),
              //         spreadRadius: 5,
              //         blurRadius: 7,
              //         offset: Offset(0, 3), // changes position of shadow
              //       ),
              //     ],
              //   ),
              //   child: ClipRRect(
              //     borderRadius: BorderRadius.circular(15.0),
              //     child: Container(
              //       height: 150,
              //       color: Colors.white,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
