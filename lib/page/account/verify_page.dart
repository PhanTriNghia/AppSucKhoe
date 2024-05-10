import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthylife/page/account/auth_page.dart';
import 'package:healthylife/page/add_info/addinfo.dart';
import 'package:healthylife/page/auth.dart';
import 'package:healthylife/util/snack_bar_error_mess.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../../util/color_theme.dart';

class VerifyPage extends StatefulWidget{
  final String verificationId;
  final TextEditingController phoneNumber;
  const VerifyPage({Key? key, required this.verificationId, required this.phoneNumber}) : super(key:key);

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage>{
  //late final TextEditingController verifyCode = TextEditingController();
  //String? otpCode;

  late final TextEditingController _otpController;

  Future<void> signInWithPhoneNumber(String smsCode) async {
    try {
      AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Đăng nhập thành công
      Navigator.push(context, MaterialPageRoute(builder: (context) => AuthPage()));
    } on FirebaseAuthException catch (e) {
      // Xử lý lỗi đăng nhập
      //print('Lỗi đăng nhập: ' + e.code);
      if(e.code == "invalid-verification-code"){
        SnackBarErrorMess.show(context, "Mã xác Otp không trùng khớp");
      }
    }
  }


  Future<void> resendOtp(String phoneNumber) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "+84" + widget.phoneNumber.text,
        timeout: Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential){},
        verificationFailed: (FirebaseAuthException e){
          print("Lỗi xác thực: ${e.message}");
        },
        codeSent: (String verificationId, int? resendToken){},
        codeAutoRetrievalTimeout: (String verificationId){}
    );

  }

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     body: Padding(
       padding: EdgeInsets.all(6),
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Text("Nhập mã xác thực",
           style: GoogleFonts.getFont(
             'Montserrat',
             fontSize: 34,
             fontWeight: FontWeight.bold,
              ),
           ),
           SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
           Text("Nhập mã xác thực đã gửi vào số điện thoại của bạn",
               textAlign: TextAlign.center,
               style: GoogleFonts.getFont(
                 'Montserrat',
                 fontSize: 20,
                 fontWeight: FontWeight.w500,
                 color: Colors.grey.shade500
               ),
           ),
           SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
           Pinput(
             controller: _otpController,
             length: 6,
             showCursor: true,
             defaultPinTheme: PinTheme(
               width: 60,
               height: 60,
               decoration: BoxDecoration(
                 borderRadius: BorderRadius.circular(10),
                 border: Border.all(
                   color: ColorTheme.backgroundColor
                 ),
               ),
               textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
             ),
             onSubmitted: (value){
               setState(() {
                 _otpController.text = value;
               });
             },
           ),
           SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
           GestureDetector(
             onTap: (){
               resendOtp(widget.phoneNumber.text);
             },
             child: Text("Gửi lại mã xác nhận",
               style: GoogleFonts.getFont(
                 'Montserrat',
                 fontWeight: FontWeight.bold,
                 fontSize: 18,
                 color: Colors.red
               ),
             ),
           ),
           SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
           Container(
             width: MediaQuery.of(context).size.width * 0.8,
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
                 //print("Number phone: " + phoneController.text);
                 //print("Verify Code: " + otpCode!.toString());
                 if(_otpController != null){
                   signInWithPhoneNumber(_otpController.text);
                   print("Verify Code: " + _otpController.text);
                   print("PHONE: " + widget.phoneNumber.text);
                 } else{
                   SnackBarErrorMess.show(context, "Mã OTP gồm 6 ký tự");
                 }
               },
               child: Text('Xác thực'.toUpperCase(),
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
   );
  }
}