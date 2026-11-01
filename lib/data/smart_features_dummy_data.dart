import '../models/surplus_prediction_model.dart';
import '../models/discount_recommendation_model.dart';
import '../models/food_rescue_impact_model.dart';

class SmartFeaturesDummyData {
  static final List<SurplusPredictionModel> surplusProducts = [
    SurplusPredictionModel(
      productName: 'Nasi Ayam',
      category: 'Makanan Berat',
      producedQuantity: 20,
      currentStock: 8,
      salesHistory: [12, 10, 14, 11, 13],
      salesDay: 'Senin',
      salesTime: 'Siang',
    ),
    SurplusPredictionModel(
      productName: 'Roti Cokelat',
      category: 'Roti',
      producedQuantity: 15,
      currentStock: 7,
      salesHistory: [8, 9, 7, 10, 6],
      salesDay: 'Selasa',
      salesTime: 'Sore',
    ),
    SurplusPredictionModel(
      productName: 'Donat Gula',
      category: 'Roti',
      producedQuantity: 15,
      currentStock: 12,
      salesHistory: [3],
      salesDay: 'Rabu',
      salesTime: 'Sore',
    ),
  ];

  static final List<DiscountRecommendationModel> discountProducts = [
    DiscountRecommendationModel(
      productName: 'Nasi Ayam',
      originalPrice: 20000,
      remainingStock: 10,
      minutesUntilClosing: 60,
      soldToday: 5,
    ),
    DiscountRecommendationModel(
      productName: 'Roti Cokelat',
      originalPrice: 12000,
      remainingStock: 8,
      minutesUntilClosing: 120,
      soldToday: 12,
    ),
  ];

  static final List<FoodRescueImpactModel> rescueOrders = [
    FoodRescueImpactModel(
      orderId: 'ORD001',
      tenantId: 'TEN001',
      consumerId: 'CON001',
      productName: 'Nasi Ayam',
      quantity: 3,
      isPickedUp: true,
    ),
    FoodRescueImpactModel(
      orderId: 'ORD002',
      tenantId: 'TEN001',
      consumerId: 'CON002',
      productName: 'Roti Cokelat',
      quantity: 2,
      isPickedUp: true,
    ),
    FoodRescueImpactModel(
      orderId: 'ORD003',
      tenantId: 'TEN001',
      consumerId: 'CON001',
      productName: 'Nasi Ayam',
      quantity: 4,
      isPickedUp: false,
    ),
  ];
}
