// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:gauge_indicator/gauge_indicator.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:healthylife/util/color_theme.dart';
// import 'package:healthylife/widget/calo/calo_history_widget.dart';
// import 'package:intl/intl.dart';
//
// import '../../model/CaloHistory.dart';
//
// class CaloGaugeWidget extends StatefulWidget {
//   String userID;
//
//   CaloGaugeWidget({super.key, required this.userID});
//
//   @override
//   State<CaloGaugeWidget> createState() => _CaloGaugeWidgetState();
// }
//
// class _CaloGaugeWidgetState extends State<CaloGaugeWidget> {
//
//   num exercise_calo = 0;
//   num food_calo = 0;
//
//   DateTime _selectedDate = DateTime.now();
//
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime(2015, 8),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: ColorTheme.darkGreenColor,
//               onPrimary: Colors.white,
//               surface: Colors.white,
//               onSurface: Colors.black
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: ColorTheme.darkGreenColor, // Màu cho các nút TextButton
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null && picked != _selectedDate)
//       setState(() {
//         _selectedDate = picked;
//       });
//   }
//
//   String getDate(DateTime _selectedDate) {
//     return DateFormat('dd/MM/yyyy').format(_selectedDate);
//   }
//
//   String getRelativeDay(DateTime selectedDate) {
//     DateTime today = DateTime.now();
//     int difference = today.difference(selectedDate).inDays;
//
//     if (difference == 0) {
//       return 'Hôm nay';
//     } else if (difference == 1) {
//       return 'Hôm qua';
//     } else {
//       return '${difference} ngày sau';
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(15),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.5),
//                 spreadRadius: 5,
//                 blurRadius: 7,
//                 offset: Offset(0, 3), // changes position of shadow
//               ),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(15.0),
//             child: Container(
//               color: ColorTheme.darkGreenColor,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.symmetric(
//                             horizontal: MediaQuery.of(context).size.width * 0.02),
//                         child: Text(
//                           getRelativeDay(_selectedDate),
//                           style: GoogleFonts.getFont(
//                             'Montserrat',
//                             color: Colors.white,
//                             fontWeight: FontWeight.w400,
//                             fontSize: 20,
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             Text(
//                               DateFormat('dd/MM/yyyy').format(_selectedDate),
//                               style: GoogleFonts.getFont(
//                                 'Montserrat',
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.normal,
//                                 fontSize: 20,
//                               ),
//                             ),
//                             IconButton(
//                               icon: Icon(
//                                 Icons.calendar_today,
//                                 color: Colors.white,
//                               ),
//                               onPressed: () => _selectDate(context),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Expanded(
//                         child: Column(
//                           children: [
//                             Text(
//                               '110',
//                               textAlign: TextAlign.center,
//                               style: GoogleFonts.getFont(
//                                 'Montserrat',
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 24,
//                               ),
//                             ),
//                             Text(
//                               'Đã nạp',
//                               textAlign: TextAlign.center,
//                               style: GoogleFonts.getFont(
//                                 'Montserrat',
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.normal,
//                                 fontSize: 18,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               'Cần nạp',
//                               style: GoogleFonts.getFont(
//                                 'Montserrat',
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: 20,
//                               ),
//                             ),
//                             SizedBox(
//                               height: MediaQuery.sizeOf(context).height * 0.01,
//                             ),
//                             AnimatedRadialGauge(
//                               duration: const Duration(milliseconds: 2000),
//                               builder: (context, _, value) => RadialGaugeLabel(
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 24,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                                 value: 1500 - value,
//                               ),
//                               value: 110,
//                               radius: 60,
//                               // Chỉnh độ to nhỏ của gauge
//                               curve: Curves.elasticOut,
//                               axis: const GaugeAxis(
//                                 min: 0,
//                                 max: 1500,
//                                 degrees: 360,
//                                 pointer: null,
//                                 progressBar: GaugeProgressBar.basic(
//                                   color: Colors.white,
//                                 ),
//                                 transformer: GaugeAxisTransformer.colorFadeIn(
//                                   interval: Interval(0.0, 0.3),
//                                   background: Color(0xFFD9DEEB),
//                                 ),
//                                 style: GaugeAxisStyle(
//                                   thickness: 15,
//                                   background: Colors.grey,
//                                   blendColors: false,
//                                   cornerRadius: Radius.circular(0.0),
//                                 ),
//                                 // segments: _controller.segments
//                                 //     .map((e) => e.copyWith(
//                                 //     cornerRadius:
//                                 //     Radius.circular(_controller.segmentsRadius)))
//                                 //     .toList(),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         child: Column(
//                           children: [
//                             Text(
//                               '0',
//                               textAlign: TextAlign.center,
//                               style: GoogleFonts.getFont(
//                                 'Montserrat',
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 24,
//                               ),
//                             ),
//                             Text(
//                               'Tiêu hao',
//                               textAlign: TextAlign.center,
//                               style: GoogleFonts.getFont(
//                                 'Montserrat',
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.normal,
//                                 fontSize: 18,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(
//                     height: MediaQuery.of(context).size.height * 0.02,
//                   ),
//
//                 ],
//               ),
//             ),
//           ),
//         ),
//         SizedBox(
//           height: MediaQuery.of(context).size.height * 0.02,
//         ),
//         // CaloHistoryWidget(
//         //     userID: widget.userID, dateHistory: getDate(_selectedDate)),
//       ],
//     );
//   }
// }
