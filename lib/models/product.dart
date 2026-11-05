class Product {
  final int id;
  final String name;
  final String image;
  final int originalPrice;
  final int discountPrice;
  final int stock;
  final String category;
  final String description;
  final String tenantName;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.originalPrice,
    required this.discountPrice,
    required this.stock,
    required this.category,
    required this.description,
    required this.tenantName,
  });
}
