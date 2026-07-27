import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/product_model.dart';

part 'wishlist_provider.g.dart';

@riverpod
class Wishlist extends _$Wishlist {
  @override
  List<ProductModel> build() {
    return [];
  }

  void toggleWishlist(ProductModel product) {
    if (isInWishlist(product.id)) {
      state = state.where((p) => p.id != product.id).toList();
    } else {
      state = [...state, product];
    }
  }

  bool isInWishlist(String productId) {
    return state.any((p) => p.id == productId);
  }
}
