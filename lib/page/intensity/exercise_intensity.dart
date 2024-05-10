

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthylife/model/UserHealthy.dart';
import 'package:healthylife/util/color_theme.dart';
import 'package:healthylife/widget/home/home_bottom_navigation.dart';

class ExcerciseIntensity extends StatefulWidget{
  final UserHealthy? userHealthy;
  final String? userDetailID;
  final double? bmr;

  const ExcerciseIntensity({Key? key, required this.userHealthy, required this.userDetailID, required this.bmr}) : super(key:key);
  @override
  State<ExcerciseIntensity> createState() => _ExcerciseIntensityState();
}

class _ExcerciseIntensityState extends State<ExcerciseIntensity>{
  bool _selectedBtn1 = false;
  bool _selectedBtn2 = false;
  bool _selectedBtn3 = false;
  bool _selectedBtn4 = false;
  bool _selectedBtn5 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cường độ luyện tập',
          style: GoogleFonts.getFont(
              'Montserrat',
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: ColorTheme.backgroundColor,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.77,
              child: ElevatedButton(
                  onPressed: (){
                    setState(() {
                      _selectedBtn1 = true;
                      _selectedBtn2 = false;
                      _selectedBtn3 = false;
                      _selectedBtn4 = false;
                      _selectedBtn5 = false;

                      // print('UserID: '+ widget.userID.toString());
                      // print('UserDetailID: '+ widget.userDetailID.toString());
                      double R = 1.2;
                      double calo = widget.bmr! * R;
                      FirebaseFirestore.instance
                          .collection('UserDetail')
                          .where('UserID', isEqualTo: widget.userHealthy?.UserID).get().then((querrySnapshot) {
                            querrySnapshot.docs.forEach((doc) {
                              //String userDetailID = doc.id;
                              FirebaseFirestore.instance
                                  .collection('UserDetail').doc(widget.userDetailID).update({
                                'UserR':R,
                                'UserCalo': calo
                              });
                            });
                      });
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeBottomNavigation(userHealthy: UserHealthy(widget.userHealthy!.UserID, widget.userHealthy!.UserCredential, widget.userHealthy!.UserGender, widget.userHealthy!.UserName, widget.userHealthy!.UserBirthday))));
                    });
                  },
                  style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(100, 100)),
                      //maximumSize: MaterialStateProperty.all(Size(300,100)),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                            side: BorderSide(
                                color: _selectedBtn1 ? ColorTheme.backgroundColor : Colors.grey.shade100,
                                width: 2.0)
                        )
                      ),
                  ),
                  child: Column(children: [
                    Text('Rất ít',
                      style: GoogleFonts.getFont(
                          'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _selectedBtn1 ? ColorTheme.backgroundColor : Colors.black
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.05,),
                    Text('Ít hoạt động, chỉ ăn đi làm về ngủ',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.getFont(
                        'Montserrat',
                          fontWeight: FontWeight.w600,
                          color: Colors.grey
                      ),
                    ),
                  ], )
              ),
            ),
            //SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.77,
              child: ElevatedButton(
                  onPressed: (){
                    setState(() {
                      _selectedBtn1 = false;
                      _selectedBtn2 = true;
                      _selectedBtn3 = false;
                      _selectedBtn4 = false;
                      _selectedBtn5 = false;

                      double R = 1.375;
                      double calo = widget.bmr! * R;
                      FirebaseFirestore.instance
                          .collection('UserDetail')
                          .where('UserID', isEqualTo: widget.userHealthy?.UserID).get().then((querrySnapshot) {
                        querrySnapshot.docs.forEach((doc) {
                          //String userDetailID = doc.id;
                          FirebaseFirestore.instance
                              .collection('UserDetail').doc(widget.userDetailID).update({
                            'UserR':R,
                            'UserCalo': calo
                          });
                        });
                      });
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeBottomNavigation(userHealthy: UserHealthy(widget.userHealthy!.UserID, widget.userHealthy!.UserCredential, widget.userHealthy!.UserGender, widget.userHealthy!.UserName, widget.userHealthy!.UserBirthday))));
                    });
                    // print('State: $_selectedState');
                  },
                  style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(100, 100)),
                      //maximumSize: MaterialStateProperty.all(Size(300,100)),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                            side: BorderSide(
                                color: _selectedBtn2 ? ColorTheme.backgroundColor : Colors.grey.shade100,
                                width: 2.0)
                        )
                    ),
                  ),
                  child: Column(children: [
                    Text('Ít',
                      style: GoogleFonts.getFont(
                          'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _selectedBtn2 ? ColorTheme.backgroundColor : Colors.black
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.05,),
                    Text('Có tập nhẹ nhàng, tuần 1 - 3 buổi',
                      style: GoogleFonts.getFont(
                          'Montserrat',
                          fontWeight: FontWeight.w600,
                          color: Colors.grey
                      ),
                    ),
                  ], )
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.77,
              child: ElevatedButton(
                  onPressed: (){
                    setState(() {
                      _selectedBtn1 = false;
                      _selectedBtn2 = false;
                      _selectedBtn3 = true;
                      _selectedBtn4 = false;
                      _selectedBtn5 = false;

                      double R = 1.55;
                      double calo = widget.bmr! * R;
                      FirebaseFirestore.instance
                          .collection('UserDetail')
                          .where('UserID', isEqualTo: widget.userHealthy?.UserID).get().then((querrySnapshot) {
                        querrySnapshot.docs.forEach((doc) {
                          //String userDetailID = doc.id;
                          FirebaseFirestore.instance
                              .collection('UserDetail').doc(widget.userDetailID).update({
                            'UserR':R,
                            'UserCalo': calo
                          });
                        });
                      });
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeBottomNavigation(userHealthy: UserHealthy(widget.userHealthy!.UserID, widget.userHealthy!.UserCredential, widget.userHealthy!.UserGender, widget.userHealthy!.UserName, widget.userHealthy!.UserBirthday))));
                    });
                  },
                  style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(100, 100)),
                      //maximumSize: MaterialStateProperty.all(Size(300,100)),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                            side: BorderSide(
                                color: _selectedBtn3 ? ColorTheme.backgroundColor : Colors.grey.shade100,
                                width: 2.0)
                        )
                    ),
                  ),
                  child: Column(children: [
                    Text('Trung bình',
                      style: GoogleFonts.getFont(
                          'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _selectedBtn3 ? ColorTheme.backgroundColor : Colors.black
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.05,),
                    Text('Có vận động vừa 4-5 buổi',
                      style: GoogleFonts.getFont(
                          'Montserrat',
                          fontWeight: FontWeight.w600,
                          color: Colors.grey
                      ),
                    ),
                  ], )
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.77,
              child: ElevatedButton(
                  onPressed: (){
                    setState(() {
                      _selectedBtn1 = false;
                      _selectedBtn2 = false;
                      _selectedBtn3 = false;
                      _selectedBtn4 = true;
                      _selectedBtn5 = false;

                      double R = 1.725;
                      double calo = widget.bmr! * R;
                      FirebaseFirestore.instance
                          .collection('UserDetail')
                          .where('UserID', isEqualTo: widget.userHealthy?.UserID).get().then((querrySnapshot) {
                        querrySnapshot.docs.forEach((doc) {
                          //String userDetailID = doc.id;
                          FirebaseFirestore.instance
                              .collection('UserDetail').doc(widget.userDetailID).update({
                            'UserR':R,
                            'UserCalo': calo
                          });
                        });
                      });
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeBottomNavigation(userHealthy: UserHealthy(widget.userHealthy!.UserID, widget.userHealthy!.UserCredential, widget.userHealthy!.UserGender, widget.userHealthy!.UserName, widget.userHealthy!.UserBirthday))));
                    });
                  },
                  style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(100, 100)),
                      //maximumSize: MaterialStateProperty.all(Size(300,100)),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                            side: BorderSide(
                                color: _selectedBtn4 ? ColorTheme.backgroundColor : Colors.grey.shade100,
                                width: 2.0)
                        )
                    ),
                  ),
                  child: Column(children: [
                    Text('Cao',
                      style: GoogleFonts.getFont(
                          'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _selectedBtn4 ? ColorTheme.backgroundColor : Colors.black
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.05,),
                    Text('Vận động nhiều 6-7 buổi',
                      style: GoogleFonts.getFont(
                          'Montserrat',
                          fontWeight: FontWeight.w600,
                          color: Colors.grey
                      ),
                    ),
                  ], )
              ),
            ),
            SizedBox(
              child: ElevatedButton(
                  onPressed: (){
                    setState(() {
                      _selectedBtn1 = false;
                      _selectedBtn2 = false;
                      _selectedBtn3 = false;
                      _selectedBtn4 = false;
                      _selectedBtn5 = true;

                      double R = 1.9;
                      double calo = widget.bmr! * R;
                      FirebaseFirestore.instance
                          .collection('UserDetail')
                          .where('UserID', isEqualTo: widget.userHealthy?.UserID).get().then((querrySnapshot) {
                        querrySnapshot.docs.forEach((doc) {
                          //String userDetailID = doc.id;
                          FirebaseFirestore.instance
                              .collection('UserDetail').doc(widget.userDetailID).update({
                            'UserR':R,
                            'UserCalo': calo
                          });
                        });
                      });
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeBottomNavigation(userHealthy: UserHealthy(widget.userHealthy!.UserID, widget.userHealthy!.UserCredential, widget.userHealthy!.UserGender, widget.userHealthy!.UserName, widget.userHealthy!.UserBirthday))));
                    });
                  },
                  style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(100, 100)),
                      //maximumSize: MaterialStateProperty.all(Size(300,100)),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                            side: BorderSide(
                                color: _selectedBtn5 ? ColorTheme.backgroundColor : Colors.grey.shade100,
                                width: 2.0)
                        )
                    ),
                  ),
                  child: Column(children: [
                    Text('Rất cao',
                      style: GoogleFonts.getFont(
                          'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _selectedBtn5 ? ColorTheme.backgroundColor : Colors.black
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.05,),
                    Text('Vận động rất nhiều ngày tập 2 lần',
                      style: GoogleFonts.getFont(
                          'Montserrat',
                          fontWeight: FontWeight.w600,
                          color: Colors.grey
                      ),
                    ),
                  ], )
              ),
            ),
          ],
        ),
      ),
    );
  }


  
}