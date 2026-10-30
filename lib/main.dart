
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

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
      home: const Scaffold(
        body: Center(
          child: Text('ReBite'),
        ),
      ),
    );
  }
}
