import 'package:flutter/material.dart';

import '../../models/cart_item_model.dart';
import '../../models/order_model.dart';
import '../../services/transaction_service.dart';
import 'order_rules_page.dart';
import 'pickup_qr_page.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
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
        return 'Selesaikan pembayaran digital '
            'dan lampirkan bukti pembayaran.';
      case OrderStatus.waitingConfirmation:
        return 'Pesanan sedang menunggu konfirmasi tenant.';
      case OrderStatus.readyForPickup:
        return 'Pesanan siap diambil. '
            'Tunjukkan QR Code kepada tenant.';
      case OrderStatus.completed:
        return 'Pesanan telah selesai dan makanan sudah diambil.';
      case OrderStatus.cancelled:
        return 'Pesanan ini telah dibatalkan.';
      case OrderStatus.late:
        return 'Batas waktu pengambilan telah terlewati. '
            'Hubungi tenant untuk tindak lanjut.';
    }
  }

  Widget _buildCard(Widget child) {
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
                fontWeight: FontWeight.w600,
                color: textColor,
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
      Column(
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
      Column(
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
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            'Rp${_formatPrice(price * quantity)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsCard(OrderModel order) {
    return _buildCard(
      Column(
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
            Text('${order.productName} (${order.quantity} porsi)'),
          const Divider(),
          const SizedBox(height: 12),
          _buildInfoRow('Total Porsi', '${order.quantity} porsi'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pembayaran',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Rp${_formatPrice(order.totalPrice)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                  fontSize: 20,
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
      Column(
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
          const Text(
            'Konfirmasi pembayaran dilakukan oleh tenant.',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _openQr(OrderModel order) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => PickupQrPage(orderId: order.orderId),
      ),
    );

    if (!mounted) return;

    setState(() {});
  }

  Future<void> _openOrderRules(OrderModel order) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => OrderRulesPage(
          orderId: order.orderId,
          actor: CancellationActor.consumer,
          actorId: order.consumerId,
        ),
      ),
    );

    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final OrderModel? order = TransactionService.instance.findOrder(
      widget.orderId,
    );

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pesanan')),
        body: const Center(child: Text('Pesanan tidak ditemukan.')),
      );
    }

    final bool canShowQr = order.status == OrderStatus.readyForPickup;

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
          const SizedBox(height: 16),

          if (canShowQr)
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _openQr(order),
                icon: const Icon(Icons.qr_code),
                label: const Text('Lihat QR Pengambilan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            )
          else if (order.status == OrderStatus.waitingPayment ||
              order.status == OrderStatus.waitingConfirmation)
            const Text(
              'QR Code akan tersedia setelah '
              'tenant mengonfirmasi pesanan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),

          const SizedBox(height: 12),

          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _openOrderRules(order),
              icon: const Icon(Icons.rule_outlined),
              label: const Text('Aturan & Status Transaksi'),
              style: OutlinedButton.styleFrom(foregroundColor: primaryGreen),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
