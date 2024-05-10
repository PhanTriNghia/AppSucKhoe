import 'dart:async';

import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthylife/page/account/first_screen.dart';
import 'package:healthylife/page/account/verify_page.dart';
import 'package:healthylife/util/snack_bar_error_mess.dart';

import '../../util/color_theme.dart';

class LoginWithNumberPhone extends StatefulWidget{
  const LoginWithNumberPhone({super.key});

  @override
  State<LoginWithNumberPhone> createState() => _LoginWithNumberPhoneState();
}

class _LoginWithNumberPhoneState extends State<LoginWithNumberPhone> {
  final TextEditingController phoneController = TextEditingController();

  String _verificationId = "";

  Future<void> verifyPhone() async{
    if(phoneController.text.isNotEmpty){

      print('hello 1');
      // Xác thực thành công
      verificationCompleted(PhoneAuthCredential phoneAuthCredential) async{
        await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
      }

      // Xác thực thất bại
      verificationFailed(FirebaseAuthException authException){
        print('Lỗi xác thực: ${authException.message}');
      }

      // Gửi mã OTP
      codeSent(String verificationId, int? resendToken) async{
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => VerifyPage(verificationId: verificationId, phoneNumber: phoneController,)));
        //_verificationId = verificationId;
      }

      // Thời gian chờ tự động nhận mã OTP
      codeAutoRetrievalTimeout(String verificationId) {
        _verificationId = verificationId;
      }

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "+84" + phoneController.text,
        timeout: Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );

      print('hello 2');

    } else{
      SnackBarErrorMess.show(context, "Nhập số điện thoại");
    }
  }

  Country country = Country(
      phoneCode: "84",
      countryCode: "VN",
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: "VietNam",
      example: "VietNam",
      displayName: "VietNam",
      displayNameNoCountryCode: "VN",
      e164Key: "");

  @override
  Widget build(BuildContext context) {
    phoneController.selection = TextSelection.fromPosition(
      TextPosition(offset: phoneController.text.length),
    );
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              child: Align(
                alignment: Alignment.topCenter,
                child: Image.asset('assets/images/Vector2.png',
                  width: MediaQuery.of(context).size.width,
                  //height: MediaQuery.of(context).size.height,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 150,
              left: 0,
              right: 0,
              child: Center(
                child: Text("HEALTHY LIFE",
                  style: GoogleFonts.getFont(
                    'Montserrat',
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              left: -10,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FirstScreenPage()));
                  //Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  //padding: const EdgeInsets.all(1),
                ),
                child: Icon(Icons.arrow_back_rounded,
                  size: 42,
                  color: ColorTheme.backgroundColor,
                ),
              ),
            ),
            Positioned(
              top: 300,
              left: 30,
              right: 30,
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Center(
                        child: Text('Đăng nhập'.toUpperCase(),
                          style: GoogleFonts.getFont(
                              'Montserrat',
                              color: ColorTheme.backgroundColor,
                              fontSize: 32,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    // Text('Số điện thoại',
                    //   style: GoogleFonts.getFont(
                    //     'Montserrat',
                    //     color: Colors.black,
                    //     fontSize: 14,
                    //   ),
                    // ),
                    //const SizedBox(height: 10,),
                    TextFormField(
                      controller: phoneController,
                      cursorColor: ColorTheme.backgroundColor,
                      style: TextStyle(fontSize: 16 ,fontWeight: FontWeight.bold),
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      onChanged: (value){
                        setState(() {
                          phoneController.text = value;
                        });
                      },
                      decoration:  InputDecoration(
                          counterText: "",
                          //filled: true,
                          hintText: "Nhập số điện thoại",
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.black12),
                          ),
                          focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.black12),
                        ),
                          prefixIcon: Container(
                            padding: EdgeInsets.all(14),
                            child: Text(
                              "${country.flagEmoji} + ${country.phoneCode}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          suffixIcon: phoneController.text.length > 9
                              ? Container(
                                  child: const Icon(Icons.check,
                                    color: Colors.green,
                                  ),
                              )
                              : null
                          //contentPadding: EdgeInsets.symmetric(horizontal: 15)
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(15),
                          backgroundColor: ColorTheme.backgroundColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          verifyPhone();
                          //print("Number phone: " + phoneController.text);
                        },
                        child: Text('Gửi mã'.toUpperCase(),
                          style: GoogleFonts.getFont(
                            'Montserrat',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}