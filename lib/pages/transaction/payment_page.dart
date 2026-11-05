import 'package:flutter/material.dart';

import '../../models/cart_item_model.dart';
import '../../models/order_model.dart';
import '../../services/transaction_service.dart';

import 'order_detail_page.dart';
import 'payment_proof_page.dart';

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
  OrderModel? createdOrder;

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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _continuePayment() async {
    final PaymentMethod? method = selectedMethod;

    if (method == null) {
      _showMessage('Pilih metode pembayaran terlebih dahulu.');
      return;
    }

    try {
      final OrderModel order =
          createdOrder ??
          TransactionService.instance.createOrder(
            consumerId: 'CNS001',
            cartItems: widget.cartItems,
            paymentMethod: method,
          );

      if (createdOrder == null) {
        setState(() {
          createdOrder = order;
        });
      }

      if (!mounted) return;

      if (method == PaymentMethod.cash ||
          order.status != OrderStatus.waitingPayment) {
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => OrderDetailPage(orderId: order.orderId),
          ),
        );
      } else {
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => PaymentProofPage(orderId: order.orderId),
          ),
        );
      }

      if (mounted) {
        setState(() {});
      }
    } on StateError catch (error) {
      if (mounted) {
        _showMessage(error.message);
      }
    }
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
          'Pilih metode pembayaran untuk pesananmu.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 20),
        RadioGroup<PaymentMethod>(
          groupValue: selectedMethod,
          onChanged: (PaymentMethod? value) {
            if (createdOrder != null) {
              _showMessage(
                'Metode pembayaran tidak dapat diubah '
                'setelah pesanan dibuat.',
              );
              return;
            }

            setState(() {
              selectedMethod = value;
            });
          },
          child: Column(
            children: [
              _buildPaymentOption(
                method: PaymentMethod.cash,
                title: 'Cash',
                description: 'Bayar tunai kepada tenant saat pengambilan.',
                icon: Icons.payments_outlined,
              ),
              _buildPaymentOption(
                method: PaymentMethod.mobileBanking,
                title: 'Mobile Banking',
                description:
                    'Transfer melalui mobile banking '
                    'dan lampirkan bukti pembayaran.',
                icon: Icons.account_balance_outlined,
              ),
              _buildPaymentOption(
                method: PaymentMethod.eWallet,
                title: 'E-Wallet',
                description:
                    'Bayar dengan e-wallet '
                    'dan lampirkan bukti pembayaran.',
                icon: Icons.account_balance_wallet_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSummary() {
    final OrderModel? order = createdOrder;

    String buttonText = 'Buat Pesanan';

    if (order != null) {
      if (order.paymentMethod == PaymentMethod.cash ||
          order.status != OrderStatus.waitingPayment) {
        buttonText = 'Lihat Detail Pesanan';
      } else {
        buttonText = 'Lanjut Upload Bukti';
      }
    }

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
            if (order != null) ...[
              Text(
                'ID Pesanan: ${order.orderId}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 6),
              Text(
                'Status: ${order.statusLabel}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
            ],
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
                child: Text(
                  buttonText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
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
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
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
