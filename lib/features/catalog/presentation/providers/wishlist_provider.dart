import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/local/wishlist_box.dart';
import '../../domain/models/product_model.dart';

part 'wishlist_provider.g.dart';

@riverpod
class Wishlist extends _$Wishlist {
  @override
  List<String> build() {
    return WishlistBox.loadIds();
  }

  void toggleWishlist(ProductModel product) {
    if (isInWishlist(product.id)) {
      state = state.where((productId) => productId != product.id).toList();
    } else {
      state = [...state, product.id];
    }

    unawaited(WishlistBox.saveIds(state));
  }

  bool isInWishlist(String productId) {
    return state.contains(productId);
  }
}
