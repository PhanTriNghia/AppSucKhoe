
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:healthylife/model/UserHealthy.dart';
import 'package:healthylife/page/account/auth_page.dart';
import 'package:healthylife/page/account/register.dart';
import 'package:healthylife/page/account/first_screen.dart';
import 'package:healthylife/page/add_info/addinfo.dart';
import 'package:healthylife/page/auth.dart';
import 'package:healthylife/page/home/home_page.dart';
import 'package:healthylife/util/color_theme.dart';
import 'package:healthylife/util/snack_bar_error_mess.dart';
import 'package:healthylife/widget/home/home_bottom_navigation.dart';

class LoginPage extends StatefulWidget{
  const LoginPage ({super.key});

  @override
  State<LoginPage> createState() => _LoginState();
}

class _LoginState extends State<LoginPage>{
  bool _obscureText = true;
  bool _isInputEmpty = true;
  //bool isLogin = true;
  //bool _showErrorMess = false;
  //String? errorMessage = '';

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> signInWithEmailAndPassword() async{
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
      } else{
        await Auth().signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
      Navigator.pop(context);
      //print('Login success');
    } on FirebaseAuthException catch(e){
      //print("Error1: " + e.code.toString());
      Navigator.pop(context);
      // Thông báo nếu email sai
      if(e.code == 'invalid-email'){
        SnackBarErrorMess.show(context, 'Email không tồn tại');
      // Thông báo nếu mật khẩu sai
      } else if(e.code == 'invalid-credential'){
        SnackBarErrorMess.show(context, 'Mật khẩu không chính xác');
      }

    }
    //Navigator.push(context, MaterialPageRoute(builder: (context) => AuthPage()));
    //Navigator.pop(context);
  }

  Future<UserCredential?> signInWithGoogle() async{
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: [
        'https://www.googleapis.com/auth/drive',
      ],
    );

    // Lấy thông tin đăng nhập từ Google
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    // kiểm tra có thông tin đăng nhập không
    if(googleSignInAccount != null){
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      final OAuthCredential googleAuthCredential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken:  googleSignInAuthentication.idToken,
      );
      UserCredential? userCredential = await FirebaseAuth.instance.signInWithCredential(googleAuthCredential);
      return userCredential;
    }
    return null;
  }

  void initState(){
    super.initState();
    _passwordController.addListener(_checkInput);
  }

  // hàm kiểm tra TextFormField đã nhập hay chưa nhập
  void _checkInput(){
    setState(() {
      _isInputEmpty = _passwordController.text.isEmpty;
    });
  }

  void errorEmailMess() {
    showDialog(
        context: context,
        builder: (context){
          return const AlertDialog(
            title: Text('Email không tồn tại'),
          );
        });
}

  @override
  Widget build(BuildContext context) {
    // final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;

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
                    Text('Email',
                      style: GoogleFonts.getFont(
                        'Montserrat',
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                          filled: true,
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 15)
                      ),
                      validator: (value){
                        if(value!.isEmpty){
                          return 'Vui lòng nhập địa chỉ email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    // Hiển thị errorMessage
                    //_buildErrorMessage(),
                    // errorMessage != '' ? Text(errorMessage!,
                    //   style: TextStyle(color: Colors.red),
                    // ) : SizedBox(),

                    Text('Mật khẩu',
                      style: GoogleFonts.getFont(
                        'Montserrat',
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return 'Vui lòng nhập thông tin';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          filled: true,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: _isInputEmpty
                              ? null
                              : IconButton(
                            onPressed: (){
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                            icon: Icon(
                              _obscureText ? Icons.visibility_off : Icons.visibility,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15)
                      ),
                    ),
                    // Hiển thị errorMessage
                    // errorMessage != '' ? Text(errorMessage!,
                    //   style: TextStyle(color: Colors.red),
                    // ) : SizedBox(),
                    const SizedBox(
                      height: 16,
                    ),
                    //_buildErrorMessage(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          child: Text('Quên mật khẩu?',
                            style: GoogleFonts.getFont(
                              'Montserrat',
                              decoration: TextDecoration.underline,
                              decorationThickness: 2.0,
                              color: ColorTheme.backgroundColor,
                              decorationColor: ColorTheme.backgroundColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
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
                          signInWithEmailAndPassword();
                          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeBottomNavigation(userHealthy: UserHealthy('rAPOP7jnV5GSYTio7zdS', 'nguyenkhai1470@gmail.com', 'Nam', 'Nguyễn Khải', '14/11/2003'))));
                        },
                        child: Text('Đăng nhập'.toUpperCase(),
                          style: GoogleFonts.getFont(
                            'Montserrat',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16,),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 15),
                            height: 2,
                            color: Colors.grey,
                          ),
                        ),
                        Text('Hoặc' .toUpperCase(),
                          style: GoogleFonts.getFont(
                              'Montserrat',
                              color: Colors.grey),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 15),
                            height: 2,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16,),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        onPressed: () {

                          signInWithGoogle();
                          //Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset('assets/images/google_img.png'),
                            SizedBox(width: MediaQuery.of(context).size.width * 0.06),
                            Text('Đăng nhập bằng Google'.toUpperCase(),
                              style: GoogleFonts.getFont(
                                'Montserrat',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: ColorTheme.backgroundColor,
                              ),
                            ),
                          ],
                        )
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
  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}

