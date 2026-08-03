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
import 'features/catalog/data/repositories/product_repository.dart';

void main() async {
  // 1. Ensure Flutter bindings are initialized before async calls
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Await Firebase initialization across all platforms (Web & Mobile)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 3. Auto-seed luxury watch catalog into Firestore if it is currently empty
  try {
    await ProductRepository(FirebaseFirestore.instance).seedIfEmpty();
  } catch (_) {
    // Gracefully handle seed exceptions (e.g. offline startup)
  }

  // 4. Open local persistence before providers hydrate state
  await AppHive.init();

  // 5. Mount Riverpod Scope at the absolute root
  runApp(const ProviderScope(child: AppWatchHub()));
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
