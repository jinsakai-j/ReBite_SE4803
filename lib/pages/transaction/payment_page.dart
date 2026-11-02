import 'package:flutter/material.dart';

import '../../models/cart_item_model.dart';
import '../../models/order_model.dart';

class PaymentPage extends StatefulWidget {
  final List<CartItemModel> cartItems;

  const PaymentPage({super.key, required this.cartItems});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  static const Color primaryGreen = Color(0xFF176B45);
  static const Color backgroundColor = Color(0xFFF7FAF7);
  static const Color textColor = Color(0xFF242B26);
  static const Color borderColor = Color(0xFFD9E3DC);

  PaymentMethod? selectedMethod;

  int get totalPrice {
    return widget.cartItems.fold<int>(
      0,
      (total, item) => total + item.subtotal,
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
  }

  String _methodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.mobileBanking:
        return 'Mobile Banking';
      case PaymentMethod.eWallet:
        return 'E-Wallet';
    }
  }

  void _continuePayment() {
    if (selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih metode pembayaran terlebih dahulu.'),
        ),
      );
      return;
    }

    final method = selectedMethod!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Metode ${_methodName(method)} dipilih. '
          'Proses pembayaran dilanjutkan pada commit berikutnya.',
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required PaymentMethod method,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final bool isSelected = selectedMethod == method;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? primaryGreen : borderColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: RadioListTile<PaymentMethod>(
        value: method,
        activeColor: primaryGreen,
        title: Row(
          children: [
            Icon(icon, color: primaryGreen),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(description),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Metode Pembayaran',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pilih salah satu metode pembayaran untuk pesananmu.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 20),

        // RadioGroup menggantikan groupValue dan onChanged
        // yang sebelumnya ada pada RadioListTile.
        RadioGroup<PaymentMethod>(
          groupValue: selectedMethod,
          onChanged: (PaymentMethod? value) {
            setState(() {
              selectedMethod = value;
            });
          },
          child: Column(
            children: [
              _buildPaymentOption(
                method: PaymentMethod.cash,
                title: 'Cash',
                description:
                    'Bayar tunai langsung kepada tenant saat pengambilan.',
                icon: Icons.payments_outlined,
              ),
              _buildPaymentOption(
                method: PaymentMethod.mobileBanking,
                title: 'Mobile Banking',
                description: 'Transfer melalui mobile banking dan unggah bukti pembayaran.',
                icon: Icons.account_balance_outlined,
              ),
              _buildPaymentOption(
                method: PaymentMethod.eWallet,
                title: 'E-Wallet',
                description:
                    'Bayar menggunakan e-wallet dan unggah bukti pembayaran.',
                icon: Icons.account_balance_wallet_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Pembayaran',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Rp${_formatPrice(totalPrice)}',
                  style: const TextStyle(
                    color: primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: selectedMethod == null ? null : _continuePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Lanjutkan Pembayaran',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Metode Pembayaran',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: backgroundColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [_buildPaymentMethods()],
            ),
          ),
          _buildBottomSummary(),
        ],
      ),
    );
  }
}
