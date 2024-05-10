import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthylife/model/UserHealthy.dart';
import 'package:healthylife/util/color_theme.dart';
import 'package:healthylife/widget/fat/fat_chart_widget.dart';
import 'package:healthylife/widget/fat/fat_gauge_widget.dart';

class FatPage extends StatefulWidget {
  UserHealthy userHealthy;
  FatPage({super.key, required this.userHealthy});

  @override
  State<FatPage> createState() => _FatPageState();
}

class _FatPageState extends State<FatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          color: Colors.white,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onPressed: () => Navigator.pop(context),
        ),
        title: Center(
          child: Text(
            'Tỷ lệ mỡ',
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
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.width * 0.03,
            horizontal: MediaQuery.of(context).size.height * 0.02,
          ),
          child: Column(
            children: [
              FatGaugeWidget(userID: widget.userHealthy.UserID, userGender: 'Nam', userBirthday: widget.userHealthy.UserBirthday),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Text(
                'Thống kê tỷ lệ mỡ trong 7 ngày qua',
                style: GoogleFonts.getFont(
                  'Montserrat',
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              FatChartWidget(userID: widget.userHealthy.UserID),
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            ],
          ),
        ),
      ),
    );
  }
}
