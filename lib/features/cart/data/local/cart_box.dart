import 'package:app_watchhub/features/cart/domain/models/cart_item_model.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class CartBox {
  static const name = 'cartBox';

  static Box<CartItemModel>? get _box {
    if (!Hive.isBoxOpen(name)) {
      return null;
    }

    return Hive.box<CartItemModel>(name);
  }

  static List<CartItemModel> load() {
    return _box?.values.toList(growable: false) ?? [];
  }

  static Future<void> save(List<CartItemModel> items) async {
    final box = _box;
    if (box == null) {
      return;
    }

    await box.clear();
    await box.putAll({for (final item in items) item.product.id: item});
  }

  static Future<void> clear() async {
    await _box?.clear();
  }
}
