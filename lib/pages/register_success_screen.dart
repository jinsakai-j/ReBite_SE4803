
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rebite_mobile/routes/app_routes.dart';

class RegisterSuccessScreen extends StatelessWidget {
  const RegisterSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 100,
                color: Color(0xFF27AE60),
              ),

              const SizedBox(height: 30),

              Text(
                'Registration Successful!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF242B26),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Akun ReBite kamu berhasil dibuat. '
                'Sekarang kamu sudah bisa mulai menggunakan ReBite!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  },
                  child: const Text('Go to Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
