import 'package:flutter_test/flutter_test.dart';

import 'package:rebite_mobile/data/smart_features_dummy_data.dart';
import 'package:rebite_mobile/models/food_rescue_impact_model.dart';
import 'package:rebite_mobile/services/food_rescue_impact_service.dart';

void main() {
  test('Menghitung hanya pesanan yang selesai diambil', () {
    final result = FoodRescueImpactService.calculate(
      SmartFeaturesDummyData.rescueOrders,
    );

    expect(result.totalRescuedPortions, 5);
    expect(result.completedOrders, 2);
  });

  test('Order ID yang sama tidak dihitung dua kali', () {
    final orders = [
      FoodRescueImpactModel(
        orderId: 'ORD001',
        tenantId: 'TEN001',
        consumerId: 'CON001',
        productName: 'Nasi Ayam',
        quantity: 3,
        isPickedUp: true,
      ),
      FoodRescueImpactModel(
        orderId: 'ORD001',
        tenantId: 'TEN001',
        consumerId: 'CON001',
        productName: 'Nasi Ayam',
        quantity: 3,
        isPickedUp: true,
      ),
    ];

    final result = FoodRescueImpactService.calculate(orders);

    expect(result.totalRescuedPortions, 3);
    expect(result.completedOrders, 1);
  });
}
