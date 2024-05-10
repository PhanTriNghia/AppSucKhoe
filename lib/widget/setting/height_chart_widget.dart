import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d_chart/commons/axis.dart';
import 'package:d_chart/commons/config_render.dart';
import 'package:d_chart/commons/enums.dart';
import 'package:d_chart/commons/layout_margin.dart';
import 'package:d_chart/commons/style.dart';
import 'package:d_chart/commons/viewport.dart';
import 'package:d_chart/time/line.dart';
import 'package:flutter/material.dart';
import 'package:d_chart/commons/data_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HeightChartWidget extends StatefulWidget {
  String userID;

  HeightChartWidget({super.key, required this.userID});

  @override
  State<HeightChartWidget> createState() => _HeightChartWidgetState();
}

class _HeightChartWidgetState extends State<HeightChartWidget> {
  late List<TimeData> timeDataList = [];

  final List<TimeGroup> timeGroupList = [];

  List<num> HeightList = [];

  @override
  void initState() {
    super.initState();
    getTimeDataHistory();
  }

  Future<void> getTimeDataHistory() async {
    final now = DateTime.now();

    for(int i = 0; i < 7; i++) {
      await getUserDetail(widget.userID, DateTime(now.year, now.month, now.day - i));
      timeDataList.add(TimeData(domain: DateTime(now.year, now.month, now.day - i), measure: HeightList[i]));
    }

    timeGroupList.add(
      TimeGroup(
        id: '1',
        data: timeDataList,
      ),
    );
  }

  Future<void> getUserDetail(String userID, DateTime dateTime) async {
    try {
      String dateHistory = DateFormat('dd/MM/yyyy').format(dateTime);

      final userDetailQuerySnapshot = await FirebaseFirestore.instance
          .collection('UserDetail')
          .where('UserID', isEqualTo: userID)
          .where('DateHistory', isEqualTo: dateHistory)
          .get();

      // Nếu dữ liệu tồn tại
      if (userDetailQuerySnapshot.docs.isNotEmpty) {
        // lấy id document
        final document = userDetailQuerySnapshot.docs.first;

        final Height = document['UserHeight'];

        setState(() {
          HeightList.add(Height);
        });
      } else {
        setState(() {
          HeightList.add(0);

        });
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Thống kê chiều cao trong 7 ngày qua',
          style: GoogleFonts.getFont(
            'Montserrat',
            color: Colors.grey,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.25,
            child: DChartLineT(
              allowSliding: true,
              domainAxis: DomainAxis(
                labelAnchor: LabelAnchor.centered,
              ),
              measureAxis: MeasureAxis(desiredTickCount: 5),
              configRenderLine: ConfigRenderLine(
                areaOpacity: 0.3,
                includeArea: true,
                includePoints: true,
              ),
              groupList: timeGroupList,
            ),
          ),
        ),
      ],
    );
  }
}
