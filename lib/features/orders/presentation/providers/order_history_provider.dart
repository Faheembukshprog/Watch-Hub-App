import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/order_model.dart';

part 'order_history_provider.g.dart';

@riverpod
class OrderHistory extends _$OrderHistory {
  @override
  List<OrderModel> build() {
    return []; // Starts with an empty order list
  }

  void addOrder(OrderModel newOrder) {
    // Prepend new order so latest purchases appear at the top
    state = [newOrder, ...state];
  }
}