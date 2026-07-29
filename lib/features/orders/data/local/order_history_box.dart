import 'package:app_watchhub/features/orders/domain/models/order_model.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class OrderHistoryBox {
  static const name = 'ordersBox';

  static Box<OrderModel>? get _box {
    if (!Hive.isBoxOpen(name)) {
      return null;
    }

    return Hive.box<OrderModel>(name);
  }

  static List<OrderModel> load() {
    return _box?.values.toList(growable: false) ?? [];
  }

  static Future<void> save(List<OrderModel> orders) async {
    final box = _box;
    if (box == null) {
      return;
    }

    await box.clear();
    await box.putAll({for (final order in orders) order.id: order});
  }
}
