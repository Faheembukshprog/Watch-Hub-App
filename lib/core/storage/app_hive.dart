import 'package:app_watchhub/features/cart/data/local/cart_adapter.dart';
import 'package:app_watchhub/features/cart/data/local/cart_box.dart';
import 'package:app_watchhub/features/cart/domain/models/cart_item_model.dart';
import 'package:app_watchhub/features/catalog/data/local/wishlist_box.dart';
import 'package:app_watchhub/features/orders/data/local/order_history_adapter.dart';
import 'package:app_watchhub/features/orders/data/local/order_history_box.dart';
import 'package:app_watchhub/features/orders/domain/models/order_model.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class AppHive {
  const AppHive._();

  static Future<void> init() async {
    await Hive.initFlutter();
    _registerAdapter(CartAdapter());
    _registerAdapter(OrderHistoryAdapter());

    await Future.wait([
      Hive.openBox<CartItemModel>(CartBox.name),
      Hive.openBox<String>(WishlistBox.name),
      Hive.openBox<OrderModel>(OrderHistoryBox.name),
      Hive.openBox<String>('settings'),
    ]);
  }

  static void _registerAdapter<T>(TypeAdapter<T> adapter) {
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
  }
}
