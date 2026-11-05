class Product {
  String name;
  String price;
  String originalPrice;
  String stock;
  String imagePath;
  String category;

  Product({
    required this.name,
    required this.price,
    this.originalPrice = '',
    required this.stock,
    required this.imagePath,
    this.category = 'Makanan',
  });
}
