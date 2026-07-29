import 'package:flutter/foundation.dart';

class RemoteConfigService {
  static Future<void> initialize() async {
    // Stub for Firebase Remote Config initialization
    debugPrint('RemoteConfigService initialized');
  }

  static bool isFeatureEnabled(String featureKey) {
    // Default feature flags
    return true;
  }

  static String get minRequiredAppVersion => '1.0.0';
}
