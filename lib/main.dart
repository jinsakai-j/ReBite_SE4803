
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'pages/splash_screen.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const ReBiteApp());
}

class ReBiteApp extends StatelessWidget {
  const ReBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReBite',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      initialRoute: AppRoutes.splash,

      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
      },
    );
  }
}
