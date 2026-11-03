import 'dart:typed_data';

import '../models/cart_item_model.dart';
import '../models/order_model.dart';

class TransactionService {
  TransactionService._();

  static final TransactionService instance = TransactionService._();

  final List<OrderModel> _orders = [];

  final Map<String, int> _remainingStocks = {};

  int _orderSequence = 0;

  List<OrderModel> get orders => List<OrderModel>.unmodifiable(_orders);

  OrderModel? findOrder(String orderId) {
    for (final order in _orders) {
      if (order.orderId == orderId) {
        return order;
      }
    }
    return null;
  }

  int remainingStock(CartItemModel item) {
    return _remainingStocks[item.productId] ?? item.stock;
  }

  OrderModel createOrder({
    required String consumerId,
    required List<CartItemModel> cartItems,
    required PaymentMethod paymentMethod,
  }) {
    if (consumerId.trim().isEmpty) {
      throw StateError('ID consumer tidak boleh kosong.');
    }

    if (cartItems.isEmpty) {
      throw StateError('Keranjang masih kosong.');
    }

    final tenantId = cartItems.first.tenantId;
    final Set<String> productIds = {};

    for (final item in cartItems) {
      if (item.productId.isEmpty ||
          item.tenantId.isEmpty ||
          item.price < 0 ||
          item.stock < 0 ||
          item.quantity < 1) {
        throw StateError('Data produk tidak valid.');
      }

      if (item.tenantId != tenantId) {
        throw StateError(
          'Satu pesanan hanya boleh berisi produk '
          'dari tenant yang sama.',
        );
      }

      if (!productIds.add(item.productId)) {
        throw StateError('Produk yang sama tidak boleh tercatat dua kali.');
      }

      if (item.quantity > remainingStock(item)) {
        throw StateError('Stok ${item.productName} tidak mencukupi.');
      }
    }

    final List<CartItemModel> orderItems = cartItems.map((item) {
      return CartItemModel(
        productId: item.productId,
        productName: item.productName,
        tenantId: item.tenantId,
        price: item.price,
        stock: item.stock,
        quantity: item.quantity,
      );
    }).toList();

    final int totalQuantity = orderItems.fold<int>(
      0,
      (total, item) => total + item.quantity,
    );

    final int totalPrice = orderItems.fold<int>(
      0,
      (total, item) => total + item.subtotal,
    );

    final OrderStatus initialStatus = paymentMethod == PaymentMethod.cash
        ? OrderStatus.waitingConfirmation
        : OrderStatus.waitingPayment;

    _orderSequence++;

    final String orderId =
        'ORD-${DateTime.now().microsecondsSinceEpoch}-$_orderSequence';

    final OrderModel newOrder = OrderModel(
      orderId: orderId,
      consumerId: consumerId,
      tenantId: tenantId,
      productName: orderItems.map((item) => item.productName).join(', '),
      quantity: totalQuantity,
      totalPrice: totalPrice,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
      items: orderItems,
      status: initialStatus,
    );

    for (final item in orderItems) {
      final currentStock = remainingStock(item);

      _remainingStocks[item.productId] = currentStock - item.quantity;
    }

    _orders.add(newOrder);

    return newOrder;
  }

  OrderModel submitPaymentProof({
    required String orderId,
    required String fileName,
    required Uint8List proofBytes,
  }) {
    final OrderModel? order = findOrder(orderId);

    if (order == null) {
      throw StateError('Pesanan tidak ditemukan.');
    }

    if (order.paymentMethod == PaymentMethod.cash) {
      throw StateError('Pembayaran Cash tidak membutuhkan bukti transfer.');
    }

    if (order.status != OrderStatus.waitingPayment) {
      throw StateError(
        'Bukti pembayaran tidak dapat dikirim '
        'untuk status pesanan ini.',
      );
    }

    if (fileName.trim().isEmpty || proofBytes.isEmpty) {
      throw StateError('Bukti pembayaran tidak valid.');
    }

    order.paymentProofName = fileName;
    order.paymentProofBytes = Uint8List.fromList(proofBytes);
    order.status = OrderStatus.waitingConfirmation;

    return order;
  }
}
