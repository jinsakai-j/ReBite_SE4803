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

  OrderStatus status;

  OrderModel({
    required this.orderId,
    required this.consumerId,
    required this.tenantId,
    required this.productName,
    required this.quantity,
    required this.totalPrice,
    required this.paymentMethod,
    required this.createdAt,
    this.status = OrderStatus.waitingPayment,
  });
}
