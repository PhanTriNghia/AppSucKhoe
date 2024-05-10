import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthylife/util/color_theme.dart';

import '../../widget/water/water_chart_widget.dart';
import '../../widget/water/water_history_widget.dart';

class WaterPage extends StatefulWidget {
  final String userID;
  WaterPage({super.key, required this.userID});

  @override
  State<WaterPage> createState() => _WaterPageState();
}

class _WaterPageState extends State<WaterPage> {
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
            'Lượng nước uống',
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

        child: Container(
          child: Column(
          children: [
            WaterHistoryWidget(userID: widget.userID),

            SizedBox(height: MediaQuery.of(context).size.height * 0.02),

            Text(
              'Thống kê lượng nước tiêu thụ trong 7 ngày qua',
              style: GoogleFonts.getFont(
                'Montserrat',
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),

            WaterChartWidget(userID: widget.userID),

            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          ],
        ),
       )
      )
    );
  }
}
