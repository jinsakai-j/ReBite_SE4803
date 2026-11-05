import 'dart:typed_data';

import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../data/transaction_dummy_data.dart';

class TransactionService {
  TransactionService._();

  static final TransactionService instance = TransactionService._();

  final List<OrderModel> _orders = TransactionDummyData.orders;
  final Map<String, int> _remainingStocks = {};

  final Set<String> _refundedOrderIds = {};

  int _orderSequence = 0;

  List<OrderModel> get orders {
    refreshDeadlines();
    return List<OrderModel>.unmodifiable(_orders);
  }

  OrderModel? findOrder(String orderId) {
    refreshDeadlines();

    for (final order in _orders) {
      if (order.orderId == orderId) {
        return order;
      }
    }

    return null;
  }

  List<OrderModel> ordersForTenant(String tenantId) {
    refreshDeadlines();

    return _orders.where((order) => order.tenantId == tenantId).toList();
  }

  int remainingStock(CartItemModel item) {
    refreshDeadlines();

    return _remainingStocks[item.productId] ?? item.stock;
  }

  OrderModel createOrder({
    required String consumerId,
    required List<CartItemModel> cartItems,
    required PaymentMethod paymentMethod,
  }) {
    refreshDeadlines();

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
          'Satu pesanan hanya boleh berisi '
          'produk dari tenant yang sama.',
        );
      }

      if (!productIds.add(item.productId)) {
        throw StateError('Produk yang sama tidak boleh tercatat dua kali.');
      }

      final int available = _remainingStocks[item.productId] ?? item.stock;

      if (item.quantity > available) {
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
      final int available = _remainingStocks[item.productId] ?? item.stock;

      _remainingStocks[item.productId] = available - item.quantity;
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
      throw StateError('Cash tidak membutuhkan bukti transfer.');
    }

    if (order.status != OrderStatus.waitingPayment) {
      throw StateError('Pesanan tidak sedang menunggu pembayaran.');
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
      throw StateError('Bukti pembayaran belum tersedia.');
    }

    order.status = OrderStatus.readyForPickup;
    order.readyForPickupAt = DateTime.now();

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

    refreshDeadlines();

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
      throw StateError('QR Code bukan milik tenant ini.');
    }

    final OrderModel order = _requireTenantOrder(
      orderId: orderId,
      tenantId: tenantId,
    );

    if (pickupQrData(order) != qrData) {
      throw StateError('Data QR Code tidak sesuai.');
    }

    if (order.status == OrderStatus.completed) {
      throw StateError('QR Code sudah digunakan.');
    }

    if (order.status != OrderStatus.readyForPickup &&
        order.status != OrderStatus.late) {
      throw StateError('Pesanan belum siap untuk diambil.');
    }

    order.status = OrderStatus.completed;
    order.completedAt = DateTime.now();

    return order;
  }

  void refreshDeadlines({DateTime? now}) {
    final DateTime currentTime = now ?? DateTime.now();

    for (final order in _orders) {
      if (order.status == OrderStatus.waitingPayment &&
          order.paymentMethod != PaymentMethod.cash) {
        final DateTime? deadline = order.paymentDeadline;

        if (deadline != null && !currentTime.isBefore(deadline)) {
          _cancelInternal(
            order,
            reason: 'Batas pembayaran 15 menit terlewati.',
            now: currentTime,
            stockStillSellable: true,
          );
        }
      }

      if (order.status == OrderStatus.readyForPickup) {
        final DateTime? deadline = order.pickupDeadline;

        if (deadline != null && !currentTime.isBefore(deadline)) {
          order.status = OrderStatus.late;
        }
      }
    }
  }

  OrderModel cancelOrder({
    required String orderId,
    required CancellationActor actor,
    required String actorId,
    required bool stockStillSellable,
    String reason = 'Pesanan dibatalkan.',
  }) {
    final OrderModel order = _requireOrder(orderId);

    if (actorId.trim().isEmpty) {
      throw StateError('ID pengguna tidak valid.');
    }

    if (actor == CancellationActor.system) {
      throw StateError('Pembatalan sistem tidak dapat dipanggil dari UI.');
    }

    if (order.isFinalStatus) {
      throw StateError(
        'Pesanan selesai atau dibatalkan '
        'tidak dapat dibatalkan kembali.',
      );
    }

    if (actor == CancellationActor.consumer) {
      if (actorId != order.consumerId) {
        throw StateError('Consumer tidak memiliki akses ke pesanan ini.');
      }

      if (order.status != OrderStatus.waitingPayment &&
          order.status != OrderStatus.waitingConfirmation) {
        throw StateError(
          'Pesanan sudah dikonfirmasi tenant '
          'dan tidak dapat dibatalkan oleh consumer.',
        );
      }
    } else if (actor == CancellationActor.tenant) {
      if (actorId != order.tenantId) {
        throw StateError('Tenant tidak memiliki akses ke pesanan ini.');
      }

      if (order.status != OrderStatus.waitingPayment &&
          order.status != OrderStatus.waitingConfirmation &&
          order.status != OrderStatus.late) {
        throw StateError(
          'Pesanan tidak dapat dibatalkan '
          'dalam status saat ini.',
        );
      }
    }

    _cancelInternal(
      order,
      reason: reason,
      now: DateTime.now(),
      stockStillSellable: stockStillSellable,
    );

    return order;
  }

  void _cancelInternal(
    OrderModel order, {
    required String reason,
    required DateTime now,
    required bool stockStillSellable,
  }) {
    if (order.isFinalStatus) return;

    order.status = OrderStatus.cancelled;
    order.cancelledAt = now;
    order.cancellationReason = reason;

    if (stockStillSellable && !_refundedOrderIds.contains(order.orderId)) {
      for (final item in order.items) {
        final int current = _remainingStocks[item.productId] ?? item.stock;

        _remainingStocks[item.productId] = current + item.quantity;
      }

      _refundedOrderIds.add(order.orderId);
    }
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
