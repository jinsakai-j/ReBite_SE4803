class FoodRescueImpactModel {
  final String orderId;
  final String tenantId;
  final String consumerId;
  final String productName;
  final int quantity;
  final bool isPickedUp;

  FoodRescueImpactModel({
    required this.orderId,
    required this.tenantId,
    required this.consumerId,
    required this.productName,
    required this.quantity,
    required this.isPickedUp,
  });
}
