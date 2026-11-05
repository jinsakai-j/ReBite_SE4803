import 'package:flutter/material.dart';

import 'cart_page.dart';
import 'order_history_page.dart';
import 'tenant_verification_page.dart';

class TransactionHomePage extends StatelessWidget {
  const TransactionHomePage({super.key});

  static const Color primaryGreen = Color(0xFF176B45);
  static const Color backgroundColor = Color(0xFFF7FAF7);
  static const Color textColor = Color(0xFF242B26);
  static const Color borderColor = Color(0xFFD9E3DC);

  static const String demoConsumerId = 'CNS001';
  static const String demoTenantId = 'TNT001';

  void _openPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => page),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F2E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: primaryGreen, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: primaryGreen),
            ],
          ),
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
          'Transaksi ReBite',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        backgroundColor: backgroundColor,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 38,
                  color: Colors.white,
                ),
                SizedBox(height: 12),
                Text(
                  'Pesanan & Pembayaran',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Kelola keranjang, lakukan pembayaran, '
                  'dan pantau status pesananmu.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Menu Consumer',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),

          _buildMenuCard(
            context: context,
            icon: Icons.shopping_cart_outlined,
            title: 'Keranjang Belanja',
            subtitle: 'Atur produk dan lanjutkan checkout.',
            onTap: () {
              _openPage(context, const CartPage());
            },
          ),

          _buildMenuCard(
            context: context,
            icon: Icons.history,
            title: 'Riwayat Transaksi',
            subtitle: 'Lihat status dan detail pesananmu.',
            onTap: () {
              _openPage(
                context,
                const OrderHistoryPage(consumerId: demoConsumerId),
              );
            },
          ),

          const SizedBox(height: 20),

          const Text(
            'Menu Tenant',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),

          _buildMenuCard(
            context: context,
            icon: Icons.qr_code_scanner,
            title: 'Verifikasi Pesanan',
            subtitle: 'Konfirmasi pembayaran dan verifikasi QR pengambilan.',
            onTap: () {
              _openPage(
                context,
                const TenantVerificationPage(tenantId: demoTenantId),
              );
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
