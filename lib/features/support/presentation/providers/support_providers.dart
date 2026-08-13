import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:app_watchhub/shared/providers/firebase_provider.dart';

part 'support_providers.g.dart';

@riverpod
Stream<List<Map<String, dynamic>>> userTickets(Ref ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value([]);
  }

  return ref
      .watch(firebaseFirestoreProvider)
      .collection('support_tickets')
      .where('userId', isEqualTo: user.uid)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
}

@riverpod
Stream<List<Map<String, dynamic>>> allTickets(Ref ref) {
  return ref
      .watch(firebaseFirestoreProvider)
      .collection('support_tickets')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
}
