import '../models/surplus_prediction_model.dart';

class SurplusPredictionResult {
  final bool isAvailable;
  final int estimatedDemand;
  final int potentialSurplus;
  final int recommendedProduction;
  final String message;

  SurplusPredictionResult({
    required this.isAvailable,
    required this.estimatedDemand,
    required this.potentialSurplus,
    required this.recommendedProduction,
    required this.message,
  });
}

class SurplusPredictionService {
  static SurplusPredictionResult calculate(SurplusPredictionModel product) {
    // Memerlukan minimal 3 catatan penjualan.
    if (product.salesHistory.length < 3) {
      return SurplusPredictionResult(
        isAvailable: false,
        estimatedDemand: 0,
        potentialSurplus: 0,
        recommendedProduction: 0,
        message: 'Data penjualan belum cukup untuk membuat prediksi.',
      );
    }

    // Data tidak valid tidak boleh dipakai.
    if (product.salesHistory.any((sales) => sales < 0) ||
        product.producedQuantity < 0 ||
        product.currentStock < 0) {
      return SurplusPredictionResult(
        isAvailable: false,
        estimatedDemand: 0,
        potentialSurplus: 0,
        recommendedProduction: 0,
        message: 'Data produksi, stok, atau penjualan tidak valid.',
      );
    }

    // Menjumlahkan seluruh histori penjualan.
    int totalSales = 0;

    for (int sales in product.salesHistory) {
      totalSales += sales;
    }

    // Menghitung rata-rata penjualan.
    final double averageSales = totalSales / product.salesHistory.length;

    // Membulatkan estimasi permintaan ke atas.
    final int estimatedDemand = averageSales.ceil();

    // Potensi surplus berdasarkan rencana jumlah produksi.
    int potentialSurplus = product.producedQuantity - estimatedDemand;

    // Surplus tidak boleh negatif.
    if (potentialSurplus < 0) {
      potentialSurplus = 0;
    }

    return SurplusPredictionResult(
      isAvailable: true,
      estimatedDemand: estimatedDemand,
      potentialSurplus: potentialSurplus,
      recommendedProduction: estimatedDemand,
      message: 'Hasil merupakan estimasi berdasarkan riwayat penjualan.',
    );
  }
}
