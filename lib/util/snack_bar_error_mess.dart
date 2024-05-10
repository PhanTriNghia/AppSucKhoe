import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthylife/util/color_theme.dart';

class SnackBarErrorMess {
  static void show(
      BuildContext context,
      String mess, {
        Duration duration = const Duration(seconds: 3),
        double elevation = 4.0,
        double borderRadius = 12.0,
        Icon? leadingIcon,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (leadingIcon != null) ...[
              leadingIcon,
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                mess,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: ColorTheme.lightGreenColor,
        duration: duration,
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
        ),
        behavior: SnackBarBehavior.fixed, // Set behavior to 'fixed' for bottom placement
      ),
    );
  }
}
