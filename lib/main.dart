import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'core/storage/app_hive.dart';
import 'core/constants/app_colors.dart';
import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/providers/theme_provider.dart';
import 'shared/providers/connectivity_provider.dart';
import 'shared/providers/firebase_provider.dart';
import 'features/catalog/data/repositories/product_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeFirebase();

  try {
    await AppHive.init();
  } catch (e) {
    debugPrint('Hive initialization failed: $e');
  }

  runApp(
    ProviderScope(
      child: firebaseInitFailed
          ? const FirebaseInitErrorApp()
          : const AppWatchHub(),
    ),
  );

  if (Firebase.apps.isNotEmpty && !firebaseInitFailed) {
    unawaited(_safeSeedDatabase());
  }
}

Future<void> _initializeFirebase() async {
  firebaseInitFailed = false;
  firebaseInitError = null;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, st) {
    firebaseInitFailed = true;
    firebaseInitError = e.toString();
    debugPrint('Firebase initialization failed: $firebaseInitError');
    debugPrint('$st');
  }
}

Future<void> _safeSeedDatabase() async {
  if (Firebase.apps.isEmpty || firebaseInitFailed) {
    return;
  }

  try {
    await ProductRepository(FirebaseFirestore.instance).seedIfEmpty();
  } catch (e) {
    debugPrint('Database seeding failed: $e');
  }
}

class FirebaseInitErrorApp extends StatelessWidget {
  const FirebaseInitErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App-WatchHub',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Firebase failed to initialize.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  firebaseInitError ??
                      'Please check your Firebase configuration and try again.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppWatchHub extends ConsumerWidget {
  const AppWatchHub({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'App-WatchHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        return Consumer(
          builder: (context, ref, _) {
            final connectivity = ref.watch(connectivityProvider).asData?.value;
            final isOffline =
                connectivity != null &&
                connectivity.isNotEmpty &&
                connectivity.every(
                  (result) => result == ConnectivityResult.none,
                );

            if (isOffline) {
              return Stack(
                children: [
                  child ?? const SizedBox.shrink(),
                  Positioned(
                    top: MediaQuery.of(context).padding.top,
                    left: 0,
                    right: 0,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        color: AppColors.error,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.wifi_off_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Connection lost. Running in offline mode.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return child ?? const SizedBox.shrink();
          },
        );
      },
    );
  }
}
