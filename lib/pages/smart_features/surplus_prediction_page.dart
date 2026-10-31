import 'package:flutter/material.dart';

class SurplusPredictionPage extends StatelessWidget {
  const SurplusPredictionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Surplus Prediction'),
      ),
      body: const Center(
        child: Text('Halaman Prediksi Surplus ReBite'),
      ),
    );
  }
}