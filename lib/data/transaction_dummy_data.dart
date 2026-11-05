import 'package:flutter/foundation.dart';

import '../models/cart_item_model.dart';
import '../models/order_model.dart';

class TransactionDummyData {
  // Data contoh untuk halaman keranjang.
  static List<CartItemModel> get cartItems => [
    CartItemModel(
      productId: 'PRD001',
      productName: 'Nasi Ayam',
      tenantId: 'TNT001',
      price: 20000,
      stock: 10,
      quantity: 2,
    ),
    CartItemModel(
      productId: 'PRD002',
      productName: 'Roti Cokelat',
      tenantId: 'TNT001',
      price: 8000,
      stock: 15,
      quantity: 1,
    ),
    CartItemModel(
      productId: 'PRD003',
      productName: 'Donat Gula',
      tenantId: 'TNT001',
      price: 5000,
      stock: 8,
      quantity: 3,
    ),
  ];

  // Data contoh untuk riwayat pesanan.
  static List<OrderModel> get orders => [
    OrderModel(
      orderId: 'ORD001',
      consumerId: 'CNS001',
      tenantId: 'TNT001',
      productName: 'Nasi Ayam',
      quantity: 2,
      totalPrice: 40000,
      paymentMethod: PaymentMethod.eWallet,
      createdAt: DateTime(2026, 11, 3, 12, 30),
      status: OrderStatus.completed,
    ),
    OrderModel(
      orderId: 'ORD002',
      consumerId: 'CNS001',
      tenantId: 'TNT001',
      productName: 'Roti Cokelat',
      quantity: 1,
      totalPrice: 8000,
      paymentMethod: PaymentMethod.cash,
      createdAt: DateTime(2026, 11, 4, 10, 15),
      status: OrderStatus.readyForPickup,
    ),
    OrderModel(
      orderId: 'ORD003',
      consumerId: 'CNS001',
      tenantId: 'TNT001',
      productName: 'Donat Gula',
      quantity: 3,
      totalPrice: 15000,
      paymentMethod: PaymentMethod.mobileBanking,
      createdAt: DateTime(2026, 11, 4, 13, 0),
      status: OrderStatus.waitingConfirmation,
    ),
  ];

  // Total harga semua item dalam keranjang.
  static int calculateCartTotal(List<CartItemModel> items) {
    return items.fold<int>(0, (total, item) => total + item.subtotal);
  }

  // Menampilkan contoh hasil perhitungan saat debugging.
  static void printCartSummary() {
    final items = cartItems;

    for (final item in items) {
      debugPrint(
        '${item.productName}: '
        '${item.quantity} x Rp${item.price} '
        '= Rp${item.subtotal}',
      );
    }

    debugPrint('Total Keranjang: Rp${calculateCartTotal(items)}');
  }
}
