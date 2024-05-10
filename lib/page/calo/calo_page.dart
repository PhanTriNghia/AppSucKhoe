import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthylife/model/UserHealthy.dart';
import 'package:healthylife/page/exercise/exercise_page.dart';
import 'package:healthylife/page/food_calo/food_calo.dart';
import 'package:healthylife/page/home/home_page.dart';
import 'package:healthylife/page/walking/walking_page.dart';
import 'package:healthylife/util/color_theme.dart';
import 'package:healthylife/widget/calo/calo_chart_widget.dart';
import 'package:healthylife/widget/calo/calo_gauge_widget.dart';
import 'package:intl/intl.dart';

import '../../widget/calo/calo_history_widget.dart';

class CaloPage extends StatefulWidget {
  String userID;
  num userCalo;

  CaloPage({super.key, required this.userID, required this.userCalo});

  @override
  State<CaloPage> createState() => _CaloPageState();
}

class _CaloPageState extends State<CaloPage> {

  String _selectedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

  void updateDate(String newDate) {
    setState(() {
      _selectedDate = newDate;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
          onPressed: () => Navigator.pop(context, 'refresh'),
        ),
        title: Center(
          child: Text(
            'Calories',
            style: GoogleFonts.getFont(
              'Montserrat',
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
        ),
        actions: [
          IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: () {},
            icon: Icon(
              Icons.settings,
              color: ColorTheme.lightGreenColor,
            ),
          ),
        ],
        backgroundColor: ColorTheme.lightGreenColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.width * 0.03,
          horizontal: MediaQuery.of(context).size.height * 0.02,
        ),
        child: Column(
          children: [
            // CaloGaugeWidget(userID: 'lCIdlGoR2V2HPOEOFkF9'),
            CaloHistoryWidget(userID: widget.userID, userCalo: widget.userCalo, onDateChanged: updateDate),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),

            Text(
              'Thống kê lượng Calorie tiêu thụ trong 7 ngày qua',
              style: GoogleFonts.getFont(
                'Montserrat',
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            CaloChartWidget(userID: widget.userID),
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        spacing: 10,
        backgroundColor: ColorTheme.darkGreenColor,
        foregroundColor: Colors.white,
        spaceBetweenChildren: 10,
        children: [
          SpeedDialChild(
            child: Icon(Icons.local_fire_department_outlined),
            backgroundColor: ColorTheme.lightGreenColor,
            foregroundColor: Colors.white,
            labelBackgroundColor: ColorTheme.lightGreenColor,
            label: 'Nạp calo',
            labelStyle: GoogleFonts.getFont(
              'Montserrat',
              color: Colors.white,
              fontWeight: FontWeight.normal,
              fontSize: 20,
            ),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => FoodCaloPage(userID: widget.userID, dateHistory: _selectedDate, userCalo: widget.userCalo)));
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.directions_run_outlined),
            backgroundColor: ColorTheme.gaugeColor1,
            foregroundColor: Colors.white,
            labelBackgroundColor: ColorTheme.gaugeColor1,
            label: 'Tiêu calo',
            labelStyle: GoogleFonts.getFont(
              'Montserrat',
              color: Colors.white,
              fontWeight: FontWeight.normal,
              fontSize: 20,
            ),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ExercisePage(userID: widget.userID, dateHistory: _selectedDate, userCalo: widget.userCalo)));
            },
          ),
        ],
      ),
    );
  }
}
