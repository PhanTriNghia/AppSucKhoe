import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthylife/page/account/first_screen.dart';
import 'package:healthylife/page/auth.dart';
import 'package:healthylife/page/updateBMR/updateBMR.dart';
import 'package:healthylife/util/color_theme.dart';
import 'package:healthylife/widget/setting/height_chart_widget.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../model/UserDetail.dart';
import '../../model/UserHealthy.dart';
import '../../widget/setting/weight_chart_widget.dart';

class InfoPage extends StatefulWidget {
  final UserHealthy userHealthy;
  const InfoPage({Key? key, required this.userHealthy}) : super(key:key);
  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  bool showChart = false;
  late List<UserDetail> userDetails = [];
  num? userWeight;
  num? userHeight;

  // late SharedPreferences logindata;
  //
  // String avatar = "";
  // String username = "";
  // String dob = "";
  // String address = "";
  // String phone = "";
  // String gender = "";
  // String email = "";
  //
  // bool login = false;
  //
  // //switch
  // bool _nofication = false;

  //

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<List<UserDetail>?> getUserDetailByUserID(String userId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('UserDetail')
          .where('UserID', isEqualTo: userId)
          .get();
      //List<Map<String, dynamic>> userDetails = [];
      if (querySnapshot.docs.isNotEmpty) {
        userDetails = querySnapshot.docs.map((doc) => UserDetail.fromFirestore(doc)).toList();
      }
      return userDetails;
    } catch (error) {
      print('Không lấy được liệu: $error');
      return null;
    }
  }

  void fetchData() async {
    // Thực hiện lấy dữ liệu UserWeight từ Firebase
    List<UserDetail>? userDetailData = await getUserDetailByUserID(
        widget.userHealthy.UserID);
    if (userDetailData != null && userDetailData.isNotEmpty) {
      setState(() {
        userWeight = userDetailData[0].UserWeight;
        userHeight = userDetailData[0].UserHeight;
      });
    }
  }

  _showDialog(BuildContext context, Widget widget) {
    showDialog(
      context: context,
      builder: (context) {
        // int duration = defaultDuration;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              // backgroundColor: ColorTheme.lightGreenColor,
              content: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned(
                    right: -40,
                    top: -40,
                    child: InkResponse(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: CircleAvatar(
                        backgroundColor:
                        ColorTheme.lightGreenColor,
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      widget
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * (1 / 10),
                ),
                child: Center(
                  child: Text("HEALTHY LIFE",
                    style: GoogleFonts.getFont(
                      'Montserrat',
                      fontSize: 40,
                      color: ColorTheme.backgroundColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * (1 / 64)),
                child: Container(
                  child: Text(
                    '${widget.userHealthy.UserName}',
                    //'${utf8.decode(username.codeUnits)}',
                    style: GoogleFonts.getFont(
                      'Montserrat',
                      color: ColorTheme.darkGreenColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              Container(
                child: Text(
                  '${widget.userHealthy.UserCredential}',
                  style: GoogleFonts.getFont(
                    'Montserrat',
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),

              InkWell(
                onTap: () {
                  _showDialog(context, HeightChartWidget(userID: widget.userHealthy.UserID));
                },
                child: Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * (1 / 25)),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.95,
                    // height: MediaQuery.of(context).size.height * 0.08,
                    decoration: BoxDecoration(
                      color: Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.05,
                          vertical: MediaQuery.of(context).size.height * 0.03),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Chiều cao',
                            style: GoogleFonts.getFont(
                              'Montserrat',
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${userHeight} cm',
                            style: GoogleFonts.getFont(
                              'Montserrat',
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              InkWell(
                onTap: () {
                  _showDialog(context, WeightChartWidget(userID: widget.userHealthy.UserID));
                },
                child: Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * (1 / 25)),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.95,
                    // height: MediaQuery.of(context).size.height * 0.08,
                    decoration: BoxDecoration(
                      color: Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.05,
                          vertical: MediaQuery.of(context).size.height * 0.03),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Cân nặng',
                            style: GoogleFonts.getFont(
                              'Montserrat',
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${userWeight} kg',
                            style: GoogleFonts.getFont(
                              'Montserrat',
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * (1 / 25)),
                child: InkWell(
                  onTap: () {
                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) {
                    //   return Transcript();
                    // }));
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.95,
                    // height: MediaQuery.of(context).size.height * 0.08,
                    decoration: BoxDecoration(
                      color: Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal:
                              MediaQuery.of(context).size.width * 0.05,
                          vertical:
                              MediaQuery.of(context).size.height * 0.03),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ngày sinh',
                            style: GoogleFonts.getFont(
                              'Montserrat',
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${widget.userHealthy.UserBirthday}',
                            style: GoogleFonts.getFont(
                              'Montserrat',
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * (1 / 25)),
                child: InkWell(
                  onTap: () {
                    // Navigator.push(context, MaterialPageRoute(builder: (context)=> UpdateBMR(
                    //     userHealthy: UserHealthy(widget.userHealthy.UserID, widget.userHealthy.UserCredential, widget.userHealthy.UserGender, widget.userHealthy.UserName, widget.userHealthy.UserBirthday))));
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => UpdateBMR(
                    //         userHealthy: UserHealthy(widget.userHealthy.UserID, widget.userHealthy.UserCredential, widget.userHealthy.UserGender, widget.userHealthy.UserName, widget.userHealthy.UserBirthday),
                    //   ),
                    // ).then((data) {
                    //   // Update the state or perform actions based on the returned data
                    //   if (data != null) {
                    //     fetchData();
                    //     // Perform actions based on the returned data
                    //   }
                    // });

                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateBMR(userHealthy: widget.userHealthy),
                      ),
                    ).then((data) {
                      // Update the state or perform actions based on the returned data
                      if (data != null) {
                        fetchData();
                        // Perform actions based on the returned data
                      }
                    });
                    },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.95,
                    // height: MediaQuery.of(context).size.height * 0.08,
                    decoration: BoxDecoration(
                      color: Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal:
                          MediaQuery.of(context).size.width * 0.05,
                          vertical:
                          MediaQuery.of(context).size.height * 0.03),
                      child:Text(
                        'Cập nhật chỉ số',
                        style: GoogleFonts.getFont(
                          'Montserrat',
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.transparent),
                  ),
                  onPressed: () {
                    Auth().signOut();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FirstScreenPage()));
                  },
                  child: Text(
                    'Đăng xuất',
                    style: GoogleFonts.getFont(
                      'Montserrat',
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
