import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:healthylife/page/account/first_screen.dart';
import 'package:healthylife/util/color_theme.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      backgroundColor: ColorTheme.backgroundColor,
      splash: Column(
        children: [
          Center(
            child: LottieBuilder.asset("assets/logo/logo.json"),
          )
        ],
      ),
      nextScreen: FirstScreenPage(),
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade, // Đang bị lỗi
      duration: 3500,
      splashIconSize: 400,
      // backgroundColor: Colors.blue,
    );
  }
}
