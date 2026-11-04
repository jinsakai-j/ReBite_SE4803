import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../models/order_model.dart';
import '../../services/transaction_service.dart';
import 'order_rules_page.dart';

class TenantVerificationPage extends StatefulWidget {
  final String tenantId;

  const TenantVerificationPage({super.key, required this.tenantId});

  @override
  State<TenantVerificationPage> createState() => _TenantVerificationPageState();
}

class _TenantVerificationPageState extends State<TenantVerificationPage> {
  static const Color primaryGreen = Color(0xFF176B45);
  static const Color backgroundColor = Color(0xFFF7FAF7);
  static const Color borderColor = Color(0xFFD9E3DC);

  final TextEditingController _qrController = TextEditingController();

  @override
  void dispose() {
    _qrController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _confirmOrder(OrderModel order) {
    try {
      final updated = TransactionService.instance.confirmPayment(
        orderId: order.orderId,
        tenantId: widget.tenantId,
      );

      setState(() {});

      _showMessage('Pesanan ${updated.orderId} siap diambil.');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _rejectProof(OrderModel order) {
    try {
      TransactionService.instance.rejectPaymentProof(
        orderId: order.orderId,
        tenantId: widget.tenantId,
      );

      setState(() {});

      _showMessage(
        'Bukti pembayaran ditolak. '
        'Pelanggan perlu mengirim ulang.',
      );
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _verifyQr(String qrData) {
    try {
      final OrderModel updated = TransactionService.instance.verifyPickupQr(
        qrData: qrData.trim(),
        tenantId: widget.tenantId,
      );

      setState(() {
        _qrController.clear();
      });

      _showMessage(
        'Pengambilan berhasil! '
        'Pesanan ${updated.orderId} selesai.',
      );
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  Future<void> _openScanner() async {
    final String? result = await Navigator.push<String>(
      context,
      MaterialPageRoute<String>(builder: (context) => const _QrScannerPage()),
    );

    if (!mounted || result == null) return;

    _qrController.text = result;
    _verifyQr(result);
  }

  Future<void> _openRules(OrderModel order) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => OrderRulesPage(
          orderId: order.orderId,
          actor: CancellationActor.tenant,
          actorId: widget.tenantId,
        ),
      ),
    );

    if (!mounted) return;

    setState(() {});
  }

  Widget _buildProofPreview(Uint8List bytes) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.memory(
        bytes,
        height: 160,
        width: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Text('Bukti pembayaran tidak dapat ditampilkan.');
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final bool canConfirm = order.status == OrderStatus.waitingConfirmation;

    final bool canReject =
        canConfirm &&
        order.paymentMethod != PaymentMethod.cash &&
        order.hasPaymentProof;

    final bool canOpenRules = !order.isFinalStatus;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.productName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const SizedBox(height: 8),

          SelectableText(
            'ID: ${order.orderId}',
            style: const TextStyle(fontSize: 12),
          ),

          const SizedBox(height: 6),

          Text('Pelanggan: ${order.consumerId}'),
          Text('Metode: ${order.paymentMethodLabel}'),
          Text('Jumlah: ${order.quantity} porsi'),

          const SizedBox(height: 8),

          Text(
            'Status: ${order.statusLabel}',
            style: const TextStyle(
              color: primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),

          if (order.hasPaymentProof) ...[
            const SizedBox(height: 12),

            const Text(
              'Bukti Pembayaran',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(order.paymentProofName ?? '-'),

            const SizedBox(height: 8),

            _buildProofPreview(order.paymentProofBytes!),
          ],

          if (canConfirm) ...[
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _confirmOrder(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Konfirmasi'),
                  ),
                ),

                if (canReject) ...[
                  const SizedBox(width: 8),

                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _rejectProof(order),
                      child: const Text('Tolak Bukti'),
                    ),
                  ),
                ],
              ],
            ),
          ],

          if (order.status == OrderStatus.readyForPickup)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Menunggu pelanggan mengambil makanan '
                'dan menunjukkan QR Code.',
                style: TextStyle(color: Colors.black54),
              ),
            ),

          if (canOpenRules) ...[
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openRules(order),
                icon: const Icon(Icons.rule_outlined),
                label: const Text('Aturan & Pembatalan'),
                style: OutlinedButton.styleFrom(foregroundColor: primaryGreen),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScannerSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Verifikasi Pengambilan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),

          const SizedBox(height: 8),

          const Text(
            'Pindai QR Code pelanggan atau masukkan '
            'kode pengambilan untuk verifikasi pesanan.',
          ),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: _openScanner,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan QR dengan Kamera'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _qrController,
            decoration: const InputDecoration(
              labelText: 'Kode Pengambilan',
              hintText: 'Masukkan kode dari QR pelanggan',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 8),

          OutlinedButton(
            onPressed: () => _verifyQr(_qrController.text),
            child: const Text('Verifikasi Kode Pengambilan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<OrderModel> orders = TransactionService.instance
        .ordersForTenant(widget.tenantId)
        .reversed
        .toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Verifikasi Pesanan Tenant'),
        backgroundColor: backgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Tenant: ${widget.tenantId}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          _buildScannerSection(),

          const SizedBox(height: 24),

          const Text(
            'Daftar Pesanan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),

          const SizedBox(height: 12),

          if (orders.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text('Belum ada pesanan untuk tenant ini.')),
            )
          else
            for (final order in orders) _buildOrderCard(order),
        ],
      ),
    );
  }
}

class _QrScannerPage extends StatefulWidget {
  const _QrScannerPage();

  @override
  State<_QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<_QrScannerPage> {
  bool _detected = false;

  void _onDetect(BarcodeCapture capture) {
    if (_detected) return;

    for (final barcode in capture.barcodes) {
      final String? value = barcode.rawValue;

      if (value != null && value.isNotEmpty) {
        _detected = true;
        Navigator.pop(context, value);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Pengambilan')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Arahkan kamera ke QR Code yang '
              'ditampilkan oleh pelanggan.',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(child: MobileScanner(onDetect: _onDetect)),
        ],
      ),
    );
  }
}
