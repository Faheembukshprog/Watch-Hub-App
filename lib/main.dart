import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/router/app_router.dart';

void main() async {
  // 1. Ensure Flutter bindings are initialized before async calls
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Await Firebase initialization across all platforms (Web & Mobile)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Mount Riverpod Scope at the absolute root
  runApp(
    const ProviderScope(
      child: AppWatchHub(),
    ),
  );
}

class AppWatchHub extends ConsumerWidget {
  const AppWatchHub({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'App-WatchHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E), // Luxury Boutique Deep Navy Blue
          brightness: Brightness.light,
        ),
      ),
      routerConfig: router,
    );
  }
}