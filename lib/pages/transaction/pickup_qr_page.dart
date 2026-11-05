import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/order_model.dart';
import '../../services/transaction_service.dart';

class PickupQrPage extends StatelessWidget {
  final String orderId;

  const PickupQrPage({super.key, required this.orderId});

  static const Color primaryGreen = Color(0xFF176B45);
  static const Color backgroundColor = Color(0xFFF7FAF7);
  static const Color borderColor = Color(0xFFD9E3DC);

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final OrderModel? order = TransactionService.instance.findOrder(orderId);

    if (order == null || order.status != OrderStatus.readyForPickup) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text('QR Pengambilan'),
          backgroundColor: backgroundColor,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'QR Code belum tersedia.\n'
              'Pesanan harus berstatus Siap Diambil.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    final String qrData = 'REBITE|PICKUP|${order.orderId}|${order.tenantId}';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('QR Pengambilan'),
        backgroundColor: backgroundColor,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: primaryGreen,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Pesanan Siap Diambil',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tunjukkan QR Code ini kepada tenant '
                  'ketika mengambil makanan.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 240,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Colors.black,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Colors.black,
                    ),
                    errorStateBuilder: (context, error) {
                      return const SizedBox(
                        width: 240,
                        height: 240,
                        child: Center(
                          child: Text(
                            'QR Code gagal ditampilkan.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                SelectableText(
                  order.orderId,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),

                _buildInfoRow('Tenant', order.tenantId),
                _buildInfoRow('Jumlah', '${order.quantity} porsi'),
                _buildInfoRow('Total', 'Rp${_formatPrice(order.totalPrice)}'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Pastikan QR Code terlihat jelas saat '
            'ditunjukkan kepada tenant. '
            'Setiap pesanan hanya dapat diverifikasi satu kali.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
