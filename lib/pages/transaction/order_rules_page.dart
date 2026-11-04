import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../services/transaction_service.dart';

class OrderRulesPage extends StatefulWidget {
  final String orderId;
  final CancellationActor actor;
  final String actorId;

  const OrderRulesPage({
    super.key,
    required this.orderId,
    required this.actor,
    required this.actorId,
  });

  @override
  State<OrderRulesPage> createState() => _OrderRulesPageState();
}

class _OrderRulesPageState extends State<OrderRulesPage> {
  static const Color primaryGreen = Color(0xFF176B45);
  static const Color backgroundColor = Color(0xFFF7FAF7);
  static const Color borderColor = Color(0xFFD9E3DC);

  Timer? _timer;
  OrderStatus? _lastStatus;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();

    _lastStatus = TransactionService.instance.findOrder(widget.orderId)?.status;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      final OrderModel? order = TransactionService.instance.findOrder(
        widget.orderId,
      );

      if (order != null && _lastStatus != null && order.status != _lastStatus) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Status pesanan berubah menjadi '
              '${order.statusLabel}.',
            ),
          ),
        );
      }

      setState(() {
        _now = DateTime.now();
        _lastStatus = order?.status;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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

  String _remainingTime(DateTime deadline) {
    final Duration difference = deadline.difference(_now);

    if (difference <= Duration.zero) {
      return 'Waktu habis';
    }

    final int totalSeconds = difference.inSeconds;
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;

    return '${_twoDigits(minutes)}:'
        '${_twoDigits(seconds)}';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  bool _canCancel(OrderModel order) {
    if (order.isFinalStatus) return false;

    if (widget.actor == CancellationActor.consumer) {
      return order.consumerId == widget.actorId &&
          (order.status == OrderStatus.waitingPayment ||
              order.status == OrderStatus.waitingConfirmation);
    }

    if (widget.actor == CancellationActor.tenant) {
      return order.tenantId == widget.actorId &&
          (order.status == OrderStatus.waitingPayment ||
              order.status == OrderStatus.waitingConfirmation ||
              order.status == OrderStatus.late);
    }

    return false;
  }

  Future<void> _confirmCancellation(OrderModel order) async {
    bool stillSellable = true;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, updateDialog) {
            return AlertDialog(
              title: const Text('Batalkan Pesanan?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Pesanan yang dibatalkan tidak '
                    'dapat diaktifkan kembali.',
                  ),
                  if (widget.actor == CancellationActor.tenant) ...[
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Produk masih layak dijual'),
                      subtitle: const Text(
                        'Aktifkan jika stok boleh '
                        'dikembalikan.',
                      ),
                      value: stillSellable,
                      onChanged: (value) {
                        updateDialog(() {
                          stillSellable = value;
                        });
                      },
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Kembali'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, stillSellable);
                  },
                  child: const Text(
                    'Batalkan Pesanan',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted || confirmed == null) return;

    try {
      final updated = TransactionService.instance.cancelOrder(
        orderId: order.orderId,
        actor: widget.actor,
        actorId: widget.actorId,
        stockStillSellable: confirmed,
        reason: widget.actor == CancellationActor.consumer
            ? 'Dibatalkan oleh consumer.'
            : 'Dibatalkan oleh tenant.',
      );

      setState(() {
        _lastStatus = updated.status;
        _now = DateTime.now();
      });

      _showMessage('Pesanan berhasil dibatalkan.');
    } on StateError catch (error) {
      _showMessage(error.message);
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

  Widget _buildDeadlineCard(OrderModel order) {
    DateTime? deadline;
    String title = 'Informasi Waktu';

    if (order.status == OrderStatus.waitingPayment &&
        order.paymentDeadline != null) {
      deadline = order.paymentDeadline;
      title = 'Batas Pembayaran';
    } else if (order.status == OrderStatus.readyForPickup &&
        order.pickupDeadline != null) {
      deadline = order.pickupDeadline;
      title = 'Batas Pengambilan';
    }

    return _buildCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.access_time, color: primaryGreen, size: 36),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (deadline != null) ...[
            Text(
              _remainingTime(deadline),
              style: const TextStyle(
                fontSize: 28,
                color: primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Tenggat: ${_formatDate(deadline)}'),
          ] else
            Text(
              order.status == OrderStatus.late
                  ? 'Batas pengambilan sudah terlewati. '
                        'Tenant dapat memproses pesanan '
                        'menjadi Selesai atau Dibatalkan.'
                  : 'Tidak ada hitung mundur aktif '
                        'untuk status pesanan ini.',
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(OrderModel order) {
    return _buildCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status Transaksi',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
          SelectableText(order.orderId, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 12),
          Text(
            order.statusLabel,
            style: const TextStyle(
              color: primaryGreen,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text('Metode: ${order.paymentMethodLabel}'),
          if (order.cancelledAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'Dibatalkan: '
              '${_formatDate(order.cancelledAt!)}',
            ),
          ],
          if (order.cancellationReason != null) ...[
            const SizedBox(height: 8),
            Text('Alasan: ${order.cancellationReason}'),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final OrderModel? order = TransactionService.instance.findOrder(
      widget.orderId,
    );

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Aturan Transaksi')),
        body: const Center(child: Text('Pesanan tidak ditemukan.')),
      );
    }

    final bool canCancel = _canCancel(order);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Aturan Transaksi'),
        backgroundColor: backgroundColor,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatusCard(order),
          const SizedBox(height: 16),
          _buildDeadlineCard(order),
          const SizedBox(height: 16),

          if (canCancel)
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  _confirmCancellation(order);
                },
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Batalkan Pesanan'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              ),
            ),

          const SizedBox(height: 16),

          const Text(
            'Catatan: status dan stok pada halaman '
            'ini merupakan simulasi lokal. '
            'Tenggat diperiksa saat data diakses '
            'atau selama halaman ini aktif.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
