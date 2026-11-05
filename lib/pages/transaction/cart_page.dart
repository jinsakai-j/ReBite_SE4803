import 'package:flutter/material.dart';

import '../../data/cart_session.dart';
import '../../models/cart_item_model.dart';
import '../../services/transaction_service.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  static const Color primaryGreen = Color(0xFF176B45);
  static const Color backgroundColor = Color(0xFFF7FAF7);
  static const Color textColor = Color(0xFF242B26);

  final TransactionService _transactionService = TransactionService.instance;

  List<CartItemModel> get cartItems => CartSession.items;

  int get totalQuantity {
    return cartItems.fold<int>(0, (total, item) => total + item.quantity);
  }

  int get totalPrice {
    return cartItems.fold<int>(0, (total, item) => total + item.subtotal);
  }

  int _remainingStock(CartItemModel item) {
    return _transactionService.remainingStock(item);
  }

  void _increaseQuantity(CartItemModel item) {
    final available = _remainingStock(item);

    if (item.quantity >= available) {
      _showMessage('Jumlah tidak boleh melebihi stok tersedia');
      return;
    }

    setState(() {
      item.quantity++;
    });
  }

  void _decreaseQuantity(CartItemModel item) {
    if (item.quantity <= 1) {
      _showMessage(
        'Jumlah minimal 1. Gunakan tombol hapus untuk menghapus produk.',
      );
      return;
    }

    setState(() {
      item.quantity--;
    });
  }

  void _removeItem(CartItemModel item) {
    setState(() {
      CartSession.removeItem(item.productId);
    });

    _showMessage('${item.productName} dihapus dari keranjang');
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
  }

  bool _validateCart() {
    if (cartItems.isEmpty) {
      _showMessage('Keranjang masih kosong');
      return false;
    }

    for (final item in cartItems) {
      final available = _remainingStock(item);

      if (available <= 0) {
        _showMessage('${item.productName} sudah habis. Hapus dari keranjang.');
        return false;
      }

      if (item.quantity > available) {
        _showMessage(
          'Stok ${item.productName} tinggal $available porsi. '
          'Kurangi jumlah sebelum checkout.',
        );
        return false;
      }
    }

    return true;
  }

  Future<void> _openCheckout() async {
    if (!_validateCart()) return;

    final checkoutItems = cartItems.map((item) {
      return CartItemModel(
        productId: item.productId,
        productName: item.productName,
        tenantId: item.tenantId,
        price: item.price,
        stock: item.stock,
        quantity: item.quantity,
      );
    }).toList();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(cartItems: checkoutItems),
      ),
    );

    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Keranjang Saya',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        backgroundColor: backgroundColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? _buildEmptyCart()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _buildCartItem(item);
                    },
                  ),
          ),
          _buildCartSummary(),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItemModel item) {
    final available = _remainingStock(item);
    final hasStockProblem = item.quantity > available;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasStockProblem
              ? Colors.red.shade300
              : const Color(0xFFD9E3DC),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F2E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.fastfood_outlined,
              color: primaryGreen,
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Hapus produk',
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _removeItem(item),
                    ),
                  ],
                ),
                Text(
                  'Rp${_formatPrice(item.price)} / porsi',
                  style: const TextStyle(
                    color: primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Stok tersedia: $available',
                  style: TextStyle(
                    fontSize: 12,
                    color: hasStockProblem ? Colors.red : Colors.black54,
                  ),
                ),
                if (hasStockProblem) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Jumlah melebihi stok. Silakan kurangi.',
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconButton.outlined(
                      tooltip: 'Kurangi jumlah',
                      onPressed: () => _decreaseQuantity(item),
                      icon: const Icon(Icons.remove),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton.outlined(
                      tooltip: 'Tambah jumlah',
                      onPressed: item.quantity >= available
                          ? null
                          : () => _increaseQuantity(item),
                      icon: const Icon(Icons.add),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Subtotal: Rp${_formatPrice(item.subtotal)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, color: primaryGreen, size: 72),
          SizedBox(height: 16),
          Text(
            'Keranjang masih kosong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Belum ada makanan yang ditambahkan.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFD9E3DC))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Porsi'),
                Text(
                  '$totalQuantity porsi',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Belanja',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Rp${_formatPrice(totalPrice)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: cartItems.isEmpty ? null : _openCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Lanjut ke Checkout',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
