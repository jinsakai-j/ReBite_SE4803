class CartItemModel {
  final String productId;
  final String productName;
  final String tenantId;
  final int price;
  final int stock;
  int quantity;

  CartItemModel({
    required this.productId,
    required this.productName,
    required this.tenantId,
    required this.price,
    required this.stock,
    this.quantity = 1,
  });

  int get subtotal => price * quantity;
}
