import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:app_watchhub/shared/providers/firebase_provider.dart';

part 'admin_providers.g.dart';

@riverpod
Stream<List<Map<String, dynamic>>> allOrders(Ref ref) {
  return ref
      .watch(firebaseFirestoreProvider)
      .collectionGroup('orders')
      .orderBy('orderDate', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
}
