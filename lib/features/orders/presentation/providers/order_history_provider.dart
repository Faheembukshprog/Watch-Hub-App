import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:app_watchhub/shared/providers/firebase_provider.dart';
import '../../data/local/order_history_box.dart';
import '../../domain/models/order_model.dart';

part 'order_history_provider.g.dart';

@riverpod
class OrderHistory extends _$OrderHistory {
  String? _syncedForUid;

  @override
  List<OrderModel> build() {
    ref.listen(authStateProvider, (previous, next) {
      final user = next.value;
      if (user != null) {
        unawaited(_hydrateFromFirestore(user.uid));
      } else {
        _syncedForUid = null;
      }
    }, fireImmediately: true);

    return OrderHistoryBox.load();
  }

  Future<void> _hydrateFromFirestore(String uid) async {
    if (_syncedForUid == uid) {
      return;
    }

    try {
      final snapshot = await ref
          .read(firebaseFirestoreProvider)
          .collection('users')
          .doc(uid)
          .collection('orders')
          .get();

      if (snapshot.docs.isEmpty) {
        _syncedForUid = uid;
        return;
      }

      final remoteOrders = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return OrderModel.fromMap(data);
      }).toList();

      final merged = _mergeOrders(OrderHistoryBox.load(), remoteOrders);
      state = merged;
      _syncedForUid = uid;
      unawaited(OrderHistoryBox.save(merged));
    } catch (e) {
      debugPrint('Failed to hydrate orders from Firestore: $e');
    }
  }

  List<OrderModel> _mergeOrders(
    List<OrderModel> local,
    List<OrderModel> remote,
  ) {
    final byId = {for (final order in local) order.id: order};
    for (final order in remote) {
      byId[order.id] = order;
    }

    return byId.values.toList()
      ..sort((a, b) => b.orderDate.compareTo(a.orderDate));
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
