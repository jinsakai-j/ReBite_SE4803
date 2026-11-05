
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routes/app_routes.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.welcome,
          );
        },
        child: Center(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Re',
                  style: GoogleFonts.montserrat(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: 'Bite',
                  style: GoogleFonts.montserrat(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF27AE60),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
