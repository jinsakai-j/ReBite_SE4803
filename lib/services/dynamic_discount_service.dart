import '../models/discount_recommendation_model.dart';

class DynamicDiscountResult {
  final bool isAvailable;
  final int discountPercentage;
  final double discountedPrice;
  final double salesPerHour;
  final String message;

  DynamicDiscountResult({
    required this.isAvailable,
    required this.discountPercentage,
    required this.discountedPrice,
    required this.salesPerHour,
    required this.message,
  });
}

class DynamicDiscountService {
  static DynamicDiscountResult calculate(DiscountRecommendationModel product) {
    // Validasi data sebelum dihitung.
    if (product.originalPrice <= 0 ||
        product.remainingStock < 0 ||
        product.minutesUntilClosing < 0 ||
        product.soldToday < 0 ||
        product.minutesSellingToday <= 0) {
      return DynamicDiscountResult(
        isAvailable: false,
        discountPercentage: 0,
        discountedPrice: product.originalPrice,
        salesPerHour: 0,
        message: 'Data produk tidak valid.',
      );
    }

    // Jika stok habis, tidak perlu rekomendasi diskon.
    if (product.remainingStock == 0) {
      return DynamicDiscountResult(
        isAvailable: false,
        discountPercentage: 0,
        discountedPrice: product.originalPrice,
        salesPerHour: 0,
        message: 'Stok produk sudah habis.',
      );
    }

    // Jika toko sudah tutup, diskon tidak direkomendasikan.
    if (product.minutesUntilClosing == 0) {
      return DynamicDiscountResult(
        isAvailable: false,
        discountPercentage: 0,
        discountedPrice: product.originalPrice,
        salesPerHour: 0,
        message: 'Waktu penjualan sudah berakhir.',
      );
    }

    // Menghitung kecepatan penjualan per jam.
    final double salesPerHour =
        product.soldToday / product.minutesSellingToday * 60;

    // Memperkirakan berapa porsi yang masih mungkin terjual.
    final double estimatedRemainingSales =
        salesPerHour * product.minutesUntilClosing / 60;

    // Risiko stok tersisa jika penjualan berjalan pada laju yang sama.
    final bool highSurplusRisk =
        product.remainingStock > estimatedRemainingSales;

    // Aturan awal berdasarkan waktu penutupan.
    // Risiko surplus menentukan apakah memakai batas atas rentang.
    int discountPercentage;

    if (product.minutesUntilClosing > 120) {
      discountPercentage = highSurplusRisk ? 10 : 5;
    } else if (product.minutesUntilClosing >= 60) {
      discountPercentage = highSurplusRisk ? 15 : 10;
    } else if (product.minutesUntilClosing >= 30) {
      discountPercentage = highSurplusRisk ? 25 : 20;
    } else {
      discountPercentage = highSurplusRisk ? 30 : 25;
    }

    final double discountedPrice =
        product.originalPrice * (100 - discountPercentage) / 100;

    return DynamicDiscountResult(
      isAvailable: true,
      discountPercentage: discountPercentage,
      discountedPrice: discountedPrice,
      salesPerHour: salesPerHour,
      message: 'Rekomendasi diskon menunggu persetujuan tenant.',
    );
  }
}
