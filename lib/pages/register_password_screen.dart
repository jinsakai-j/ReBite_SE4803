
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPasswordScreen extends StatefulWidget {
  final String fullName;
  final String email;

  const RegisterPasswordScreen({
    super.key,
    required this.fullName,
    required this.email,
  });

  @override
  State<RegisterPasswordScreen> createState() =>
      _RegisterPasswordScreenState();
}

class _RegisterPasswordScreenState
    extends State<RegisterPasswordScreen> {
  String password = '';
  String confirmPassword = '';

  bool hasMinimumLength = false;
  bool hasLetterAndNumber = false;
  bool hasNoSpace = false;
  bool passwordMatch = false;

  void checkPassword(String value) {
    bool hasLetter = false;
    bool hasNumber = false;

    for (int i = 0; i < value.length; i++) {
      String character = value[i];

      if (character.toLowerCase() != character.toUpperCase()) {
        hasLetter = true;
      }

      if (int.tryParse(character) != null) {
        hasNumber = true;
      }
    }

    setState(() {
      password = value;

      hasMinimumLength = password.length >= 8;
      hasLetterAndNumber = hasLetter && hasNumber;
      hasNoSpace = !password.contains(' ');
      passwordMatch = password == confirmPassword &&
          confirmPassword.isNotEmpty;
    });
  }

  void checkConfirmPassword(String value) {
    setState(() {
      confirmPassword = value;
      passwordMatch = password == confirmPassword &&
          confirmPassword.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isPasswordValid = hasMinimumLength &&
        hasLetterAndNumber &&
        hasNoSpace &&
        passwordMatch;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Create Password',
          style: GoogleFonts.poppins(
            color: const Color(0xFF242B26),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create your Password',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF242B26),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Buat password yang aman untuk akun ReBite kamu.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  'Password',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  obscureText: true,
                  onChanged: checkPassword,
                  decoration: InputDecoration(
                    hintText: 'Masukkan password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Confirm Password',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  obscureText: true,
                  onChanged: checkConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Masukkan ulang password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  'Password Requirements',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                passwordRequirement(
                  'Minimal 8 karakter',
                  hasMinimumLength,
                ),

                passwordRequirement(
                  'Mengandung huruf dan angka',
                  hasLetterAndNumber,
                ),

                passwordRequirement(
                  'Tidak mengandung spasi',
                  hasNoSpace,
                ),

                passwordRequirement(
                  'Password harus sama',
                  passwordMatch,
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isPasswordValid
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Password berhasil divalidasi!',
                                ),
                              ),
                            );
                          }
                        : null,
                    child: const Text('Sign Up'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget passwordRequirement(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.circle_outlined,
            size: 18,
            color: isValid
                ? const Color(0xFF27AE60)
                : Colors.grey,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isValid ? const Color(0xFF27AE60) : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
