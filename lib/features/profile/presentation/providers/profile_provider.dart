import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:app_watchhub/shared/providers/firebase_provider.dart';

part 'profile_provider.g.dart';

@riverpod
Stream<Map<String, dynamic>?> userProfile(Ref ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;

  if (user == null) {
    return Stream.value(null);
  }

  return ref
      .watch(firebaseFirestoreProvider)
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) => doc.data());
}
