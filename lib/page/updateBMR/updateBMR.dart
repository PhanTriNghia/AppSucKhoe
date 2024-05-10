import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthylife/model/UserDetail.dart';
import 'package:healthylife/model/UserHealthy.dart';
import 'package:healthylife/util/color_theme.dart';
import 'package:intl/intl.dart';

class UpdateBMR extends StatefulWidget{
  final UserHealthy userHealthy;
  //final UserDetail userDetail;

  const UpdateBMR({Key? key, required this.userHealthy}) : super(key:key);

  @override
  State<UpdateBMR> createState() => _UpdateBMRState();

}

class _UpdateBMRState extends State<UpdateBMR>{
  num? newWeight;
  num? newHeight;
  num? newAge;
  num? newR;
  double? newFat;
  double? newCalo;
  double? newBMR;
  String? birthday;
  late List<UserDetail> userDetails = [];

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

    setState(() {
      newWeight = 0;
      newHeight = 0;
      newAge = 0;
      newR = 0;
    });

    // Thực hiện lấy dữ liệu UserWeight từ Firebase
    List<UserDetail>? userDetailData = await getUserDetailByUserID(
        widget.userHealthy.UserID);
    //List<UserHealthy>? userHealthyData = await getUser();

    if (userDetailData != null && userDetailData.isNotEmpty) {
      setState(() {
        newWeight = userDetailData[0].UserWeight;
        newHeight = userDetailData[0].UserHeight;
        newR = userDetailData[0].UserR;
        //birthday = userHealthyData?[0].UserBirthday;
        //print('Birthday: ${birthday}');
      });
    }
  }

  // Tính tuổi
  num Age(){
    DateTime userBirthday = DateFormat("dd/MM/yyyy").parse(widget.userHealthy.UserBirthday);
    newAge = DateTime.now().year - userBirthday.year;
    return newAge!;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉ số BMR',
            style: GoogleFonts.getFont(
                'Montserrat',
                color: Colors.white,
                fontWeight: FontWeight.bold
            )),
        backgroundColor: ColorTheme.backgroundColor,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context, 'refresh');
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.08,
              child: ElevatedButton(
                  onPressed: (){
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context){
                          return StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState) {
                              return Container(
                                height: 220,
                                color: Colors.white,
                                child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        Text('Cập nhật cân nặng',
                                          style: GoogleFonts.getFont(
                                              'Montserrat',
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600
                                          ),
                                        ),
                                        SizedBox(height: MediaQuery.of(context).size.height *0.04,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100, // Màu nền của button
                                                shape: BoxShape.circle, // Hình dạng của button (ví dụ: hình tròn)
                                              ),
                                              child: IconButton(
                                                  onPressed: (){
                                                    setState(() {
                                                      newWeight = newWeight! - 1;
                                                    });
                                                  },
                                                  icon: Icon(Icons.remove)),
                                            ),
                                            Text('${newWeight} kg',
                                              style: GoogleFonts.getFont(
                                                  'Montserrat',
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100, // Màu nền của button
                                                shape: BoxShape.circle, // Hình dạng của button (ví dụ: hình tròn)
                                              ),
                                              child: IconButton(
                                                  onPressed: (){
                                                    setState(() {
                                                      newWeight = newWeight! + 1;
                                                    });
                                                  },
                                                  icon: Icon(Icons.add)),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: MediaQuery.of(context).size.height *0.04),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.5,
                                          child: ElevatedButton(
                                            onPressed: (){
                                              FirebaseFirestore.instance
                                                  .collection('UserDetail')
                                                  .where('UserID', isEqualTo: widget.userHealthy.UserID).get()
                                                  .then((QuerySnapshot querySnapshot) {
                                                querySnapshot.docs.forEach((doc) {
                                                  doc.reference.update({
                                                    'UserWeight': newWeight,
                                                  }).then((value) {
                                                    // cập nhật lại Bmi mới
                                                    double? newBMI = newWeight!/((newHeight!/100*newHeight!/100));
                                                    if(widget.userHealthy.UserGender.toString() == 'Nam'){
                                                      newFat = 1.2 * newBMI + 0.23 * newAge! - 5.4 - 10.8;
                                                      //newBMR = 66 + (13.7 * newWeight!) + (5 * newHeight!) - (6.8 * newAge!);
                                                    }
                                                    else{
                                                      newFat = 1.2 * newBMI + 0.23 * newAge! - 5.4;
                                                      //newBMR = 655 + (9.6 * newWeight!) + (1.8 * newHeight!) - (4.7 * newAge!);
                                                    }
                                                    doc.reference.update({
                                                      'UserBMI': newBMI,
                                                      'UserFat': newFat,
                                                      //'UserCalo': newCalo,
                                                    });
                                                    // setState((){
                                                    //   newBMR = newBMR;
                                                    // });
                                                    Navigator.pop(context, 'refresh');
                                                  });
                                                });
                                                //.doc(widget.userHealthy.UserID)
                                                //   .update({
                                                // 'UserWeight': newWeight,
                                              });
                                            },
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(ColorTheme.backgroundColor),
                                            ),
                                            child: Text('Cập nhật',
                                              style: GoogleFonts.getFont(
                                                'Montserrat',
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                ),
                              );
                            },
                          );
                        });
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(Size(100, 100)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Cân nặng',
                        style: GoogleFonts.getFont(
                            'Montserrat',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.black
                        ),
                      ),
                      Text('${newWeight} kg',
                        style: GoogleFonts.getFont(
                            'Montserrat',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.grey
                        ),
                      ),
                    ],
                  )
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.08,
              child: ElevatedButton(
                  onPressed: (){
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context){
                          return StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState) {
                              return Container(
                                height: 220,
                                color: Colors.white,
                                child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        Text('Cập nhật chiều cao',
                                          style: GoogleFonts.getFont(
                                              'Montserrat',
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600
                                          ),
                                        ),
                                        SizedBox(height: MediaQuery.of(context).size.height *0.04,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100, // Màu nền của button
                                                shape: BoxShape.circle, // Hình dạng của button (ví dụ: hình tròn)
                                              ),
                                              child: IconButton(
                                                  onPressed: (){
                                                    setState(() {
                                                      newHeight = newHeight! - 1;
                                                    });
                                                  },
                                                  icon: Icon(Icons.remove)),
                                            ),
                                            Text('${newHeight} cm',
                                              style: GoogleFonts.getFont(
                                                  'Montserrat',
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100, // Màu nền của button
                                                shape: BoxShape.circle, // Hình dạng của button (ví dụ: hình tròn)
                                              ),
                                              child: IconButton(
                                                  onPressed: (){
                                                    setState(() {
                                                      newHeight = newHeight! + 1;
                                                    });
                                                  },
                                                  icon: Icon(Icons.add)),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: MediaQuery.of(context).size.height *0.04),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.5,
                                          child: ElevatedButton(
                                            onPressed: (){
                                              FirebaseFirestore.instance
                                                  .collection('UserDetail')
                                                  .where('UserID', isEqualTo: widget.userHealthy.UserID).get()
                                                  .then((QuerySnapshot querySnapshot) {
                                                querySnapshot.docs.forEach((doc) {
                                                  doc.reference.update({
                                                    'UserHeight': newHeight,
                                                  }).then((value) {
                                                    // cập nhật lại Bmi mới
                                                    double? newBMI = newWeight!/((newHeight!/100*newHeight!/100));
                                                    if(widget.userHealthy.UserGender.toString() == 'Nam'){
                                                      newFat = 1.2 * newBMI + 0.23 * newAge! - 5.4 - 10.8;
                                                      //newBMR = 66 + (13.7 * newWeight!) + (5 * newHeight!) - (6.8 * newAge!);
                                                    }
                                                    else{
                                                      newFat = 1.2 * newBMI + 0.23 * newAge! - 5.4;
                                                      //newBMR = 655 + (9.6 * newWeight!) + (1.8 * newHeight!) - (4.7 * newAge!);
                                                    }
                                                    doc.reference.update({
                                                      'UserBMI': newBMI,
                                                      'UserFat': newFat,
                                                      //'UserCalo': newCalo,
                                                    });
                                                    // setState((){
                                                    //   newBMR = newBMR;
                                                    // });
                                                    Navigator.pop(context, 'refresh');
                                                  });
                                                });
                                                //.doc(widget.userHealthy.UserID)
                                                //   .update({
                                                // 'UserWeight': newWeight,
                                              });
                                            },
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(ColorTheme.backgroundColor),
                                            ),
                                            child: Text('Cập nhật',
                                              style: GoogleFonts.getFont(
                                                'Montserrat',
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                ),
                              );
                            },
                          );
                        });
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(Size(100, 100)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Chiều cao',
                        style: GoogleFonts.getFont(
                            'Montserrat',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.black
                        ),
                      ),
                      Text('${newHeight} cm',
                        style: GoogleFonts.getFont(
                            'Montserrat',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.grey
                        ),
                      ),
                    ],
                  )
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.08,
              child: ElevatedButton(
                  onPressed: (){
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                              builder: (BuildContext context, StateSetter setState) {
                                return AlertDialog(
                                  title: Text('Cường độ tập luyện'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        title: Text('Ít (ít hoạt động)'),
                                        leading: Radio(
                                          value: 1.2,
                                          groupValue: newR,
                                          onChanged: (value) {
                                            setState((){
                                              newR = value as num?;
                                            });
                                          },
                                        ),
                                      ),
                                      ListTile(
                                        title: Text('Rất ít (tuần tập 1 -3 buổi)'),
                                        leading: Radio(
                                          value: 1.375,
                                          groupValue: newR,
                                          onChanged: (value) {
                                            setState((){
                                              newR = value as num?;
                                            });
                                          },
                                        ),
                                      ),
                                      ListTile(
                                        title: Text('Trung bình (tuần tập 4 -5 buổi)'),
                                        leading: Radio(
                                          value: 1.55,
                                          groupValue: newR,
                                          onChanged: (value) {
                                            setState((){
                                              newR = value as num?;
                                            });
                                          },
                                        ),
                                      ),
                                      ListTile(
                                        title: Text('Cao (tuần tập 6 -7 buổi)'),
                                        leading: Radio(
                                          value: 1.725,
                                          groupValue: newR,
                                          onChanged: (value) {
                                            setState((){
                                              newR = value as num?;
                                            });
                                          },
                                        ),
                                      ),
                                      ListTile(
                                        title: Text('Rất cao (nhiều ngày tập 2 lần)'),
                                        leading: Radio(
                                          value: 1.9,
                                          groupValue: newR,
                                          onChanged: (value) {
                                            setState((){
                                              newR = value as num?;
                                            });
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, 'refresh');
                                      },
                                      child: Text('Bỏ qua'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection('UserDetail')
                                            .where('UserID',
                                            isEqualTo: widget.userHealthy.UserID)
                                            .get()
                                            .then((QuerySnapshot querySnapshot) {
                                          querySnapshot.docs.forEach((doc) {
                                            doc.reference.update({
                                              'UserR': newR
                                            }).then((value) {
                                              // cập nhật lại Calo mới
                                              if(widget.userHealthy.UserGender.toString() == 'Nam'){
                                                newCalo = (66 + (13.7 * doc['UserWeight']) + (5 * doc['UserHeight']) - (6.8 * newAge!)) * newR!;
                                              } else{
                                                newCalo = (655 + (9.6 * doc['UserWeight']) + (1.8 * doc['UserHeight']) - (4.7 * newAge!)) * newR!;
                                              }
                                              doc.reference.update({
                                                'UserCalo': newCalo
                                              }).then((value){
                                                Navigator.pop(context, 'refresh');
                                              });
                                              // if(newBMR != null){
                                              //   newCalo = newBMR! * newR!;
                                              //   doc.reference.update({
                                              //     'UserCalo': newCalo
                                              //   }).then((value){
                                              //     Navigator.pop(context);
                                              //   });
                                              // } else{
                                              //   print('BMR null');
                                              // }

                                            });

                                          });
                                        });
                                      },
                                      child: Text('Xong'),
                                    ),
                                  ],
                                );
                              });
                        });
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(Size(100, 100)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Cường độ luyện tập',
                        style: GoogleFonts.getFont(
                            'Montserrat',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.black
                        ),
                      ),
                      Text('${newR}',
                        style: GoogleFonts.getFont(
                            'Montserrat',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.grey
                        ),
                      ),
                    ],
                  )
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.08,
              child: ElevatedButton(
                onPressed: (){},
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(Size(100, 100)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tuổi',
                        style: GoogleFonts.getFont(
                            'Montserrat',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.black
                        ),
                      ),
                      Text('${Age()}',
                        style: GoogleFonts.getFont(
                            'Montserrat',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.grey
                        ),
                      ),
                    ],
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }


}