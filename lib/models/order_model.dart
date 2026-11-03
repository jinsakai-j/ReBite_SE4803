import 'dart:typed_data';

import 'cart_item_model.dart';

enum OrderStatus {
  waitingPayment,
  waitingConfirmation,
  readyForPickup,
  completed,
  cancelled,
  late,
}

enum PaymentMethod { cash, mobileBanking, eWallet }

class OrderModel {
  final String orderId;
  final String consumerId;
  final String tenantId;
  final String productName;
  final int quantity;
  final int totalPrice;
  final PaymentMethod paymentMethod;
  final DateTime createdAt;

  final List<CartItemModel> items;

  OrderStatus status;

  String? paymentProofName;
  Uint8List? paymentProofBytes;

  OrderModel({
    required this.orderId,
    required this.consumerId,
    required this.tenantId,
    required this.productName,
    required this.quantity,
    required this.totalPrice,
    required this.paymentMethod,
    required this.createdAt,
    this.items = const [],
    this.status = OrderStatus.waitingPayment,
    this.paymentProofName,
    this.paymentProofBytes,
  });

  bool get hasPaymentProof =>
      paymentProofName != null && paymentProofBytes != null;

  String get statusLabel {
    switch (status) {
      case OrderStatus.waitingPayment:
        return 'Menunggu Pembayaran';
      case OrderStatus.waitingConfirmation:
        return 'Menunggu Konfirmasi';
      case OrderStatus.readyForPickup:
        return 'Siap Diambil';
      case OrderStatus.completed:
        return 'Selesai';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
      case OrderStatus.late:
        return 'Terlambat';
    }
  }

  String get paymentMethodLabel {
    switch (paymentMethod) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.mobileBanking:
        return 'Mobile Banking';
      case PaymentMethod.eWallet:
        return 'E-Wallet';
    }
  }
}
