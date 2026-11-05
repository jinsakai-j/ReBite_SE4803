import '../models/product.dart' as buyer;
import '../models/product_model.dart' as tenant;
import 'dummy_products.dart';

class SharedProductCatalog {
  SharedProductCatalog._();

  static final List<int> _buyerProductIds = [
    for (final product in dummyProducts) product.id,
  ];

  static final List<tenant.Product> tenantProducts = [
    for (final product in dummyProducts)
      tenant.Product(
        name: product.name,
        price: 'Rp ${_formatPrice(product.discountPrice)}',
        originalPrice: 'Rp ${_formatPrice(product.originalPrice)}',
        stock: '${product.stock} porsi',
        imagePath: product.image,
        category: product.category,
      ),
  ];

  static void save(int index, tenant.Product product) {
    final id = index < _buyerProductIds.length
        ? _buyerProductIds[index]
        : _nextId();
    final price = _parsePrice(product.price);
    final stock =
        int.tryParse(product.stock.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final old = dummyProducts.where((item) => item.id == id);
    final oldProduct = old.isEmpty ? null : old.first;
    final updated = buyer.Product(
      id: id,
      name: product.name,
      image: product.imagePath,
      originalPrice: _parsePrice(product.originalPrice) > 0
          ? _parsePrice(product.originalPrice)
          : oldProduct?.originalPrice ?? price,
      discountPrice: price,
      stock: stock,
      category: product.category,
      description:
          oldProduct?.description ?? 'Produk surplus dari tenant ReBite.',
      tenantName: oldProduct?.tenantName ?? 'Tenant ReBite',
    );

    if (oldProduct == null) {
      dummyProducts.add(updated);
      _buyerProductIds.add(id);
      tenantProducts.add(product);
    } else {
      final buyerIndex = dummyProducts.indexOf(oldProduct);
      dummyProducts[buyerIndex] = updated;
      tenantProducts[index] = product;
    }
  }

  static void delete(int index) {
    if (index < 0 || index >= tenantProducts.length) return;
    final id = _buyerProductIds.removeAt(index);
    tenantProducts.removeAt(index);
    dummyProducts.removeWhere((product) => product.id == id);
  }

  static int _nextId() =>
      dummyProducts.fold<int>(0, (highest, product) {
        return product.id > highest ? product.id : highest;
      }) +
      1;

  static int _parsePrice(String value) =>
      int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  static String _formatPrice(int value) => value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  );
}
