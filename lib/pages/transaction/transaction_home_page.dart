import 'package:flutter/material.dart';

class TransactionHomePage extends StatelessWidget {
  const TransactionHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: AppBar(
        title: const Text('Transaksi ReBite'),
        backgroundColor: const Color(0xFFF7FAF7),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Color(0xFF176B45),
            ),
            SizedBox(height: 16),
            Text(
              'Modul Transaksi ReBite',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF242B26),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Keranjang, Checkout, dan Pembayaran',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
