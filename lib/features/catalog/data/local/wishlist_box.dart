import 'package:hive_ce_flutter/hive_flutter.dart';

class WishlistBox {
  static const name = 'wishlistBox';

  static Box<String>? get _box {
    if (!Hive.isBoxOpen(name)) {
      return null;
    }

    return Hive.box<String>(name);
  }

  static List<String> loadIds() {
    return _box?.values.toList(growable: false) ?? [];
  }

  static Future<void> saveIds(List<String> productIds) async {
    final box = _box;
    if (box == null) {
      return;
    }

    await box.clear();
    await box.putAll({
      for (final productId in productIds) productId: productId,
    });
  }
}
