import 'package:flutter_test/flutter_test.dart';
import 'package:rebite_mobile/data/smart_features_dummy_data.dart';
import 'package:rebite_mobile/services/surplus_prediction_service.dart';

void main() {
  test('Prediksi Nasi Ayam menghasilkan 12 permintaan dan 8 surplus', () {
    final product = SmartFeaturesDummyData.surplusProducts.first;
    final result = SurplusPredictionService.calculate(product);

    expect(result.isAvailable, true);
    expect(result.estimatedDemand, 12);
    expect(result.potentialSurplus, 8);
    expect(result.recommendedProduction, 12);
  });

  test('Prediksi tidak tersedia jika histori kurang dari 3', () {
    final product = SmartFeaturesDummyData.surplusProducts.last;
    final result = SurplusPredictionService.calculate(product);

    expect(result.isAvailable, false);
  });
}
