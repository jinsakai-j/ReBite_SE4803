class SurplusPredictionModel {
  final String productName;
  final String category;
  final int producedQuantity;
  final int currentStock;
  final List<int> salesHistory;
  final String salesDay;
  final String salesTime;

  SurplusPredictionModel({
    required this.productName,
    required this.category,
    required this.producedQuantity,
    required this.currentStock,
    required this.salesHistory,
    required this.salesDay,
    required this.salesTime,
  });
}
