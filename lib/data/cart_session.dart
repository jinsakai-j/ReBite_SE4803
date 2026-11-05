import '../models/cart_item_model.dart';
import '../models/product.dart';
import '../services/transaction_service.dart';

class CartSession {
  CartSession._();

  static final List<CartItemModel> items = [];

  static final TransactionService _transactionService =
      TransactionService.instance;

  static String productIdFor(Product product) {
    return 'CAT${product.id.toString().padLeft(3, '0')}';
  }

  static CartItemModel itemFor(Product product) {
    return CartItemModel(
      productId: productIdFor(product),
      productName: product.name,
      tenantId: 'TNT001',
      price: product.discountPrice,
      stock: product.stock,
      quantity: 1,
    );
  }

  static bool addProduct(Product product) {
    final newItem = itemFor(product);

    final availableStock = _transactionService.remainingStock(newItem);

    final index = items.indexWhere(
      (item) => item.productId == newItem.productId,
    );

    if (index != -1) {
      final existingItem = items[index];

      if (existingItem.quantity >= availableStock) {
        return false;
      }

      existingItem.quantity++;
      return true;
    }

    if (availableStock < 1) {
      return false;
    }

    items.add(newItem);
    return true;
  }

  static void removeItem(String productId) {
    items.removeWhere((item) => item.productId == productId);
  }

  static void clear() {
    items.clear();
  }
}
