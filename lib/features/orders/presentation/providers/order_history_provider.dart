import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:app_watchhub/shared/providers/firebase_provider.dart';
import '../../data/local/order_history_box.dart';
import '../../domain/models/order_model.dart';

part 'order_history_provider.g.dart';

@riverpod
class OrderHistory extends _$OrderHistory {
  @override
  List<OrderModel> build() {
    return OrderHistoryBox.load();
  }

  void addOrder(OrderModel newOrder) {
    // Prepend new order so latest purchases appear at the top
    state = [newOrder, ...state];
    unawaited(OrderHistoryBox.save(state));

    // Sync to Firestore
    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user != null) {
        final firestore = ref.read(firebaseFirestoreProvider);
        unawaited(
          firestore
              .collection('users')
              .doc(user.uid)
              .collection('orders')
              .doc(newOrder.id)
              .set(newOrder.toMap())
              .catchError((e) {
                // Gracefully log error
                debugPrint('Error syncing order to Firestore: $e');
              }),
        );
      }
    } catch (e) {
      // Catch any Firebase initialization errors in unit tests
      debugPrint('Firebase not initialized for order sync: $e');
    }
  }
}
