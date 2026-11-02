import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/cart_item_model.dart';
import '../../models/order_model.dart';

class PaymentProofPage extends StatefulWidget {
  final List<CartItemModel> cartItems;
  final PaymentMethod paymentMethod;

  const PaymentProofPage({
    super.key,
    required this.cartItems,
    required this.paymentMethod,
  });

  @override
  State<PaymentProofPage> createState() => _PaymentProofPageState();
}

class _PaymentProofPageState extends State<PaymentProofPage> {
  static const Color primaryGreen = Color(0xFF176B45);
  static const Color backgroundColor = Color(0xFFF7FAF7);
  static const Color borderColor = Color(0xFFD9E3DC);

  final ImagePicker _picker = ImagePicker();

  Uint8List? _proofBytes;
  String? _proofName;
  bool _isLoading = false;

  int get totalPrice {
    return widget.cartItems.fold<int>(
      0,
      (total, item) => total + item.subtotal,
    );
  }

  String get methodName {
    switch (widget.paymentMethod) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.mobileBanking:
        return 'Mobile Banking';
      case PaymentMethod.eWallet:
        return 'E-Wallet';
    }
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

  Future<void> _pickProof() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1600,
        requestFullMetadata: false,
      );

      if (image == null) {
        return;
      }

      final int fileSize = await image.length();
      const int maxFileSize = 5 * 1024 * 1024;

      if (fileSize > maxFileSize) {
        if (mounted) {
          _showMessage('Ukuran gambar maksimal 5 MB.');
        }
        return;
      }

      final Uint8List bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        _proofBytes = bytes;
        _proofName = image.name;
      });

      _showMessage('Bukti pembayaran berhasil dipilih.');
    } catch (error) {
      if (mounted) {
        _showMessage('Gagal memilih gambar. Silakan coba lagi.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _removeProof() {
    setState(() {
      _proofBytes = null;
      _proofName = null;
    });

    _showMessage('Bukti pembayaran dihapus.');
  }

  void _submitProof() {
    if (_proofBytes == null) {
      _showMessage('Pilih bukti pembayaran terlebih dahulu.');
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Bukti Pembayaran Siap'),
          content: const Text(
            'Gambar berhasil dipilih dan ditampilkan. '
            'Pengiriman serta verifikasi pembayaran '
            'akan disimulasikan pada commit berikutnya. '
            'Belum ada file yang diunggah ke server.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Mengerti'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProofCard() {
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
            'Bukti Pembayaran',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pilih screenshot atau foto bukti transfer '
            'dari galeri perangkat.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),

          if (_proofBytes == null)
            Container(
              height: 190,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined, size: 56, color: primaryGreen),
                  SizedBox(height: 12),
                  Text('Belum ada bukti pembayaran'),
                ],
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                _proofBytes!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    height: 120,
                    child: Center(
                      child: Text('Gambar tidak dapat ditampilkan.'),
                    ),
                  );
                },
              ),
            ),

          if (_proofName != null) ...[
            const SizedBox(height: 12),
            Text(
              'File: $_proofName',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],

          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: _isLoading ? null : _pickProof,
            icon: Icon(
              _proofBytes == null
                  ? Icons.photo_library_outlined
                  : Icons.change_circle_outlined,
            ),
            label: Text(
              _proofBytes == null ? 'Pilih dari Galeri' : 'Ganti Gambar',
            ),
            style: OutlinedButton.styleFrom(foregroundColor: primaryGreen),
          ),

          if (_proofBytes != null)
            TextButton.icon(
              onPressed: _removeProof,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Hapus Gambar'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Metode'),
              Text(
                methodName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Pembayaran'),
              Text(
                'Rp${_formatPrice(totalPrice)}',
                style: const TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Bukti Pembayaran'),
        backgroundColor: backgroundColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildPaymentInfo(),
                const SizedBox(height: 16),
                _buildProofCard(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _proofBytes == null || _isLoading
                      ? null
                      : _submitProof,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Konfirmasi Bukti Pembayaran',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
