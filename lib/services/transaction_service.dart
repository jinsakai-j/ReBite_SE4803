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

  List<OrderModel> ordersForTenant(String tenantId) {
    return _orders.where((order) => order.tenantId == tenantId).toList();
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

    final String tenantId = cartItems.first.tenantId;
    final Set<String> productIds = {};

    for (final item in cartItems) {
      if (item.productId.trim().isEmpty ||
          item.tenantId.trim().isEmpty ||
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
        'ORD-${DateTime.now().microsecondsSinceEpoch}'
        '-$_orderSequence';

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
      _remainingStocks[item.productId] = remainingStock(item) - item.quantity;
    }

    _orders.add(newOrder);

    return newOrder;
  }

  OrderModel submitPaymentProof({
    required String orderId,
    required String fileName,
    required Uint8List proofBytes,
  }) {
    final OrderModel order = _requireOrder(orderId);

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

  OrderModel confirmPayment({
    required String orderId,
    required String tenantId,
  }) {
    final OrderModel order = _requireTenantOrder(
      orderId: orderId,
      tenantId: tenantId,
    );

    if (order.status != OrderStatus.waitingConfirmation) {
      throw StateError('Pesanan belum dalam status Menunggu Konfirmasi.');
    }

    if (order.paymentMethod != PaymentMethod.cash && !order.hasPaymentProof) {
      throw StateError('Bukti pembayaran digital belum tersedia.');
    }

    order.status = OrderStatus.readyForPickup;

    return order;
  }

  OrderModel rejectPaymentProof({
    required String orderId,
    required String tenantId,
  }) {
    final OrderModel order = _requireTenantOrder(
      orderId: orderId,
      tenantId: tenantId,
    );

    if (order.paymentMethod == PaymentMethod.cash) {
      throw StateError('Pesanan Cash tidak memiliki bukti transfer.');
    }

    if (order.status != OrderStatus.waitingConfirmation ||
        !order.hasPaymentProof) {
      throw StateError('Tidak ada bukti pembayaran yang bisa ditolak.');
    }

    order.paymentProofName = null;
    order.paymentProofBytes = null;
    order.status = OrderStatus.waitingPayment;

    return order;
  }

  String pickupQrData(OrderModel order) {
    return 'REBITE|PICKUP|${order.orderId}|${order.tenantId}';
  }

  OrderModel verifyPickupQr({
    required String qrData,
    required String tenantId,
  }) {
    final List<String> parts = qrData.split('|');

    if (parts.length != 4 ||
        parts[0] != 'REBITE' ||
        parts[1] != 'PICKUP' ||
        parts[2].isEmpty ||
        parts[3].isEmpty) {
      throw StateError('Format QR Code tidak valid.');
    }

    final String orderId = parts[2];
    final String qrTenantId = parts[3];

    if (qrTenantId != tenantId) {
      throw StateError('QR Code bukan milik tenant yang sedang login.');
    }

    final OrderModel order = _requireTenantOrder(
      orderId: orderId,
      tenantId: tenantId,
    );

    if (pickupQrData(order) != qrData) {
      throw StateError('Data QR Code tidak sesuai.');
    }

    if (order.status == OrderStatus.completed) {
      throw StateError('QR Code sudah digunakan. Pesanan telah selesai.');
    }

    if (order.status != OrderStatus.readyForPickup &&
        order.status != OrderStatus.late) {
      throw StateError('Pesanan belum siap untuk diambil.');
    }

    order.status = OrderStatus.completed;

    return order;
  }

  OrderModel _requireOrder(String orderId) {
    final OrderModel? order = findOrder(orderId);

    if (order == null) {
      throw StateError('Pesanan tidak ditemukan.');
    }

    return order;
  }

  OrderModel _requireTenantOrder({
    required String orderId,
    required String tenantId,
  }) {
    if (tenantId.trim().isEmpty) {
      throw StateError('ID tenant tidak valid.');
    }

    final OrderModel order = _requireOrder(orderId);

    if (order.tenantId != tenantId) {
      throw StateError('Tenant tidak memiliki akses ke pesanan ini.');
    }

    return order;
  }
}
