import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

bool firebaseInitFailed = false;
String? firebaseInitError;

/// Exposes the FirebaseAuth instance lazily through Riverpod.
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Exposes the FirebaseFirestore instance lazily through Riverpod.
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Exposes the auth state stream for the user.
///
/// Do not fall back to emitting `null` via timeout, because that can create
/// a false unauthenticated state while Firebase is still initializing or
/// refreshing credentials.
final authStateStreamProvider = Provider<Stream<User?>>((ref) {
  if (Firebase.apps.isEmpty) {
    return Stream.value(null);
  }

  return ref.watch(firebaseAuthProvider).authStateChanges().asBroadcastStream();
});

/// Exposes auth state as an `AsyncValue<User?>`.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authStateStreamProvider);
});
