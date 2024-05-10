
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthylife/page/account/auth_page.dart';
import 'package:healthylife/page/account/first_screen.dart';
import 'package:healthylife/page/add_info/addinfo.dart';
import 'package:healthylife/page/auth.dart';
import 'package:healthylife/util/color_theme.dart';
import 'package:healthylife/util/snack_bar_error_mess.dart';

class RegisterPage extends StatefulWidget{
  const RegisterPage ({super.key});

  @override
  State<RegisterPage> createState() => _RegisterState();
}

class _RegisterState extends State<RegisterPage>{
  String? errorMessage = '';
  bool isLogin = true;
  bool _obscureText = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> createUserWithEmailAndPassword() async{
    showDialog(
        context: context,
        builder: (context){
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
    try{
      if(_emailController.text.isEmpty){
        SnackBarErrorMess.show(context, 'Email không được bỏ trống');
      } else if(_passwordController.text.isEmpty){
        SnackBarErrorMess.show(context, 'Mật khẩu không được bỏ trống');
      } else if(_confirmPasswordController.text.isEmpty){
        SnackBarErrorMess.show(context, 'Nhập lại mật khẩu');
      }
      else if(_passwordController.text == _confirmPasswordController.text){
        await Auth().createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text);

        Navigator.pop(context);
      } else{
        SnackBarErrorMess.show(context, 'Mật khẩu không trùng nhau');
      }
      Navigator.pop(context);
      //Navigator.push(context, MaterialPageRoute(builder: (context) => AddInfo()));
    } on FirebaseAuthException catch(e){
      //print("Error2: " + e.code.toString());
      Navigator.pop(context);
      if (e.code == 'weak-password') {
        SnackBarErrorMess.show(context, 'Mật khẩu yếu');
      } else if (e.code == 'email-already-in-use') {
        SnackBarErrorMess.show(context, 'Email đã tồn tại');
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.backgroundColor,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              child: Align(
                alignment: Alignment.topCenter,
                child: Image.asset('assets/images/Vector3.png',
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 150,
              right: 0,
              left: 0,
              child: Center(
                child: Text('Healthy life'.toUpperCase(),
                  style: TextStyle(
                    fontSize: 40,
                    color: ColorTheme.backgroundColor,
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
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: ColorTheme.backgroundColor
                  //padding: const EdgeInsets.all(1),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                  size: 42,
                  color: Colors.white,
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
                        children:[
                          Container(
                            child: Center(
                              child: Text('Đăng ký'.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          const Text('Email',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                                filled: true,
                                //fillColor: ,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 15)
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          const Text('Mật khẩu',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            decoration: const InputDecoration(
                                filled: true,
                                //fillColor: ,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 15)
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          const Text('Nhập lại mật khẩu',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureText,
                            decoration: const InputDecoration(
                                filled: true,
                                //fillColor: ,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 15)
                            ),
                          ),
                          //const SizedBox(height: 16,),
                          Row(
                            //crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: CheckboxListTile(
                                  controlAffinity: ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                  activeColor: Colors.white,
                                  checkColor: ColorTheme.backgroundColor,
                                  tileColor: Colors.transparent,
                                  title: const Text('Hiển thị mật khẩu',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  value: !_obscureText,
                                  onChanged: (value){
                                    setState(() {
                                      _obscureText = !value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                              onPressed: () {
                                createUserWithEmailAndPassword();
                              },
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all(const EdgeInsets.all(16)),
                                side: MaterialStateProperty.all(BorderSide(width: 2,color: ColorTheme.backgroundColor)),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              child: Text('Đăng ký'.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: ColorTheme.backgroundColor,
                                ),
                              ),
                            ),
                          ),
                        ]
                    )
                )
            ),
          ],
        ),
      ),
    );
  }

}