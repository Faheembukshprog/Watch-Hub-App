import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  static const _boxName = 'settings';
  static const _key = 'themeMode';

  Box<String>? get _box {
    if (!Hive.isBoxOpen(_boxName)) return null;
    return Hive.box<String>(_boxName);
  }

  @override
  ThemeMode build() {
    final savedMode = _box?.get(_key);
    if (savedMode == 'dark') return ThemeMode.dark;
    if (savedMode == 'light') return ThemeMode.light;
    return ThemeMode.dark; // Default to dark obsidian theme for luxury vibe
  }

  void toggleTheme() {
    final nextMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = nextMode;
    _box?.put(_key, nextMode.name);
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    _box?.put(_key, mode.name);
  }
}
