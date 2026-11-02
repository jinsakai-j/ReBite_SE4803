import 'package:flutter_test/flutter_test.dart';

import 'package:rebite_mobile/data/smart_features_dummy_data.dart';
import 'package:rebite_mobile/models/discount_recommendation_model.dart';
import 'package:rebite_mobile/services/dynamic_discount_service.dart';

void main() {
  test('Nasi Ayam mendapat rekomendasi diskon 15 persen', () {
    final product = SmartFeaturesDummyData.discountProducts.first;

    final result = DynamicDiscountService.calculate(product);

    expect(result.isAvailable, true);
    expect(result.discountPercentage, 15);
    expect(result.discountedPrice, 17000);
    expect(result.salesPerHour, closeTo(1.25, 0.001));
  });

  test('Produk tanpa stok tidak mendapat rekomendasi', () {
    final product = DiscountRecommendationModel(
      productName: 'Nasi Ayam',
      originalPrice: 20000,
      remainingStock: 0,
      minutesUntilClosing: 60,
      soldToday: 5,
      minutesSellingToday: 240,
    );

    final result = DynamicDiscountService.calculate(product);

    expect(result.isAvailable, false);
  });

  test('Diskon tidak melebihi 30 persen', () {
    final product = DiscountRecommendationModel(
      productName: 'Roti Cokelat',
      originalPrice: 12000,
      remainingStock: 20,
      minutesUntilClosing: 20,
      soldToday: 2,
      minutesSellingToday: 240,
    );

    final result = DynamicDiscountService.calculate(product);

    expect(result.discountPercentage, 30);
    expect(result.discountedPrice, 8400);
  });
}
