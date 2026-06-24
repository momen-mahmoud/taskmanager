import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../storage/hive_boxes.dart';

/// Holds the current [ThemeMode], persisted to Hive so the user's dark-mode
/// choice survives app restarts (bonus: dark mode support).
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final stored = HiveBoxes.settings.get(AppConstants.themeModeKey);
    return _decode(stored);
  }

  void toggle() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setMode(next);
  }

  void setMode(ThemeMode mode) {
    state = mode;
    HiveBoxes.settings.put(AppConstants.themeModeKey, mode.name);
  }

  ThemeMode _decode(String? value) {
    return switch (value) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }
}

final themeModeProvider =
    NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);
