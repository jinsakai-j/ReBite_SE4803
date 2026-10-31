class DiscountRecommendationModel {
  final String productName;
  final double originalPrice;
  final int remainingStock;
  final int minutesUntilClosing;
  final int soldToday;

  DiscountRecommendationModel({
    required this.productName,
    required this.originalPrice,
    required this.remainingStock,
    required this.minutesUntilClosing,
    required this.soldToday,
  });
}
