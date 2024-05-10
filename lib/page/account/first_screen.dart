
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthylife/page/account/auth_page.dart';
import 'package:healthylife/page/account/login.dart';
import 'package:healthylife/page/account/login_number_phone.dart';
import 'package:healthylife/page/account/register.dart';
import 'package:healthylife/util/color_theme.dart';

class FirstScreenPage extends StatelessWidget{
  const FirstScreenPage({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            child: Center(
              child: Text("HEALTHY LIFE",
                style: GoogleFonts.getFont(
                  'Montserrat',
                  fontSize: 40,
                  color: ColorTheme.backgroundColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset('assets/images/Vector.png',
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover
              ,
            ),
          ),

          Align(
            //alignment: Alignment.bottomRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              //crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width * 5/6,
                  height: MediaQuery.of(context).size.width * 0.12,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTheme.backgroundColor,  // màu nền của button
                      foregroundColor: Colors.white,  // màu chữ của button
                      shape: RoundedRectangleBorder(  // border radius của button
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.white, width: 2),

                      ),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                    },
                    child: Text('Đăng ký'.toUpperCase(),
                      style: GoogleFonts.getFont(
                        'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16,),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 5/6,
                  height: MediaQuery.of(context).size.width * 0.12,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: ColorTheme.backgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      //Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AuthPage()));
                    },
                    child:  Text('Đăng nhập'.toUpperCase(),
                      style: GoogleFonts.getFont(
                        'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 5/6,
                  height: MediaQuery.of(context).size.width * 0.12,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: ColorTheme.backgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginWithNumberPhone()));
                    },
                    child:  Text('Đăng nhập bằng số điện thoại'.toUpperCase(),
                      style: GoogleFonts.getFont(
                        'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                //SizedBox(height: ,)
              ],
            ),
          ),

        ],
      ),
    );
  }
}


