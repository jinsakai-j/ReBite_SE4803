import '../models/food_rescue_impact_model.dart';

class FoodRescueImpactResult {
  final int totalRescuedPortions;
  final int completedOrders;

  FoodRescueImpactResult({
    required this.totalRescuedPortions,
    required this.completedOrders,
  });
}

class FoodRescueImpactService {
  static FoodRescueImpactResult calculate(List<FoodRescueImpactModel> orders) {
    final Set<String> countedOrderIds = {};

    int totalRescuedPortions = 0;
    int completedOrders = 0;

    for (final order in orders) {
      if (!order.isPickedUp) {
        continue;
      }

      if (countedOrderIds.contains(order.orderId)) {
        continue;
      }

      countedOrderIds.add(order.orderId);

      totalRescuedPortions += order.quantity;
      completedOrders++;
    }

    return FoodRescueImpactResult(
      totalRescuedPortions: totalRescuedPortions,
      completedOrders: completedOrders,
    );
  }
}
