import 'package:flutter/material.dart';

import '../../models/cart_item_model.dart';
import '../../models/order_model.dart';
import '../../services/transaction_service.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  static const Color primaryGreen = Color(0xFF176B45);
  static const Color backgroundColor = Color(0xFFF7FAF7);
  static const Color textColor = Color(0xFF242B26);
  static const Color borderColor = Color(0xFFD9E3DC);

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }

  String _formatDate(DateTime date) {
    return '${_twoDigits(date.day)}/'
        '${_twoDigits(date.month)}/${date.year} '
        '${_twoDigits(date.hour)}:'
        '${_twoDigits(date.minute)}';
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.waitingPayment:
        return Colors.orange.shade800;
      case OrderStatus.waitingConfirmation:
        return Colors.blue.shade700;
      case OrderStatus.readyForPickup:
        return primaryGreen;
      case OrderStatus.completed:
        return primaryGreen;
      case OrderStatus.cancelled:
        return Colors.red.shade700;
      case OrderStatus.late:
        return Colors.deepOrange.shade700;
    }
  }

  IconData _statusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.waitingPayment:
        return Icons.access_time;
      case OrderStatus.waitingConfirmation:
        return Icons.hourglass_top;
      case OrderStatus.readyForPickup:
        return Icons.shopping_bag_outlined;
      case OrderStatus.completed:
        return Icons.check_circle_outline;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
      case OrderStatus.late:
        return Icons.warning_amber_outlined;
    }
  }

  String _statusDescription(OrderModel order) {
    switch (order.status) {
      case OrderStatus.waitingPayment:
        return 'Silakan selesaikan pembayaran digital '
            'dan lampirkan bukti pembayaran.';
      case OrderStatus.waitingConfirmation:
        return 'Pesanan sedang menunggu konfirmasi tenant.';
      case OrderStatus.readyForPickup:
        return 'Pesanan sudah siap. Silakan ambil makanan '
            'di lokasi tenant.';
      case OrderStatus.completed:
        return 'Pesanan telah selesai dan makanan '
            'sudah diambil.';
      case OrderStatus.cancelled:
        return 'Pesanan ini telah dibatalkan.';
      case OrderStatus.late:
        return 'Batas waktu pengambilan telah terlewati. '
            'Hubungi tenant untuk tindak lanjut.';
    }
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(OrderModel order) {
    final Color statusColor = _statusColor(order.status);

    return _buildCard(
      child: Column(
        children: [
          Icon(_statusIcon(order.status), size: 52, color: statusColor),
          const SizedBox(height: 12),
          Text(
            order.statusLabel,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _statusDescription(order),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo(OrderModel order) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Pesanan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('ID Pesanan', order.orderId),
          _buildInfoRow('Tanggal', _formatDate(order.createdAt)),
          _buildInfoRow('ID Tenant', order.tenantId),
          _buildInfoRow('Metode Pembayaran', order.paymentMethodLabel),
          _buildInfoRow('Status', order.statusLabel),
        ],
      ),
    );
  }

  Widget _buildItemRow({
    required String name,
    required int price,
    required int quantity,
  }) {
    final int subtotal = price * quantity;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.fastfood_outlined, color: primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  '$quantity x Rp${_formatPrice(price)}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          Text(
            'Rp${_formatPrice(subtotal)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsCard(OrderModel order) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Produk',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),

          if (order.items.isNotEmpty)
            for (final CartItemModel item in order.items)
              _buildItemRow(
                name: item.productName,
                price: item.price,
                quantity: item.quantity,
              )
          else
            Text(
              '${order.productName} (${order.quantity} porsi)',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),

          const Divider(),
          const SizedBox(height: 12),

          _buildInfoRow('Total Porsi', '${order.quantity} porsi'),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pembayaran',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                'Rp${_formatPrice(order.totalPrice)}',
                style: const TextStyle(
                  color: primaryGreen,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(OrderModel order) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Pembayaran',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Metode', order.paymentMethodLabel),
          _buildInfoRow(
            'Bukti Pembayaran',
            order.paymentMethod == PaymentMethod.cash
                ? 'Tidak diperlukan'
                : order.hasPaymentProof
                ? 'Sudah dilampirkan'
                : 'Belum dilampirkan',
          ),
          if (order.paymentProofName != null)
            _buildInfoRow('Nama File', order.paymentProofName!),
          const SizedBox(height: 4),
          const Text(
            'Pembayaran dan verifikasi pada tahap ini '
            'masih menggunakan simulasi data lokal.',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final OrderModel? order = TransactionService.instance.findOrder(orderId);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Pesanan'),
          backgroundColor: backgroundColor,
        ),
        body: const Center(child: Text('Pesanan tidak ditemukan.')),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        backgroundColor: backgroundColor,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatusCard(order),
          const SizedBox(height: 16),
          _buildOrderInfo(order),
          const SizedBox(height: 16),
          _buildProductsCard(order),
          const SizedBox(height: 16),
          _buildPaymentCard(order),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
