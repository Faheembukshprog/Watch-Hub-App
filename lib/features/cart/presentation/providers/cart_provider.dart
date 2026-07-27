import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:app_watchhub/features/cart/domain/models/cart_item_model.dart';
import 'package:app_watchhub/features/catalog/domain/models/product_model.dart';

part 'cart_provider.g.dart';

@riverpod
class CartNotifier extends _$CartNotifier {
  @override
  List<CartItemModel> build() {
    return [];
  }

  /// Add product to cart or increment quantity if already present
  void addToCart(ProductModel product) {
    final existingIndex = state.indexWhere((item) => item.product.id == product.id);

    if (existingIndex != -1) {
      final updatedList = List<CartItemModel>.from(state);
      final currentItem = updatedList[existingIndex];
      updatedList[existingIndex] = currentItem.copyWith(
        quantity: currentItem.quantity + 1,
      );
      state = updatedList;
    } else {
      state = [...state, CartItemModel(product: product, quantity: 1)];
    }
  }

  /// Remove item completely from cart
  void removeFromCart(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  /// Increment or decrement item quantity
  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    state = [
      for (final item in state)
        if (item.product.id == productId)
          item.copyWith(quantity: quantity)
        else
          item,
    ];
  }

  /// Clear all items
  void clearCart() {
    state = [];
  }

  /// Total price calculation
  double get totalAmount {
    return state.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  /// Total items count
  int get totalItemCount {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }
}