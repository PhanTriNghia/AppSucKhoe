import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthylife/model/UserHealthy.dart';
import 'package:healthylife/page/account/login.dart';
import 'package:healthylife/page/account/register.dart';
import 'package:healthylife/page/add_info/addinfo.dart';
import 'package:healthylife/widget/home/home_bottom_navigation.dart';


class AuthPage extends StatelessWidget{
  const AuthPage({Key? key}) : super(key:key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.active){
            User? user = snapshot.data;
            if(user !=null){
              String? userCredential;
              print("phone num: " + user.phoneNumber.toString());
              if(user.email == '') {
                userCredential = user.phoneNumber;
              } else {
                userCredential = user.email;
              }
              FirebaseFirestore.instance
                    .collection('User')
                    .where('UserCredential', isEqualTo: userCredential)
                    .get()
                    .then((querySnapshot) {
                  if(querySnapshot.docs.isNotEmpty) {
                    // Dữ liệu đã tồn tại, chuyển hướng đến trang home
                    DocumentSnapshot docSnapshot = querySnapshot.docs.first;
                    // if(docSnapshot['UserCredential'] == 'test@gmail.com'){
                      UserHealthy userHealthy = UserHealthy(
                          docSnapshot['UserID'],
                          docSnapshot['UserCredential'],
                          docSnapshot['UserGender'],
                          docSnapshot['UserName'],
                          docSnapshot['UserBirthday']
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeBottomNavigation(userHealthy: userHealthy),
                        ),
                      );
                    }
                  else{
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddInfo(),
                      ),
                    );
                  }
                });

            } else{
              return LoginPage();
            }
          }
          return Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.2,
              height: MediaQuery.of(context).size.width * 0.2,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                ),
              ),
            ), // Use the custom loader widget
          );
        }
      )
    );
  }
}