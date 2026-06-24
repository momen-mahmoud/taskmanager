import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';

/// Initializes Hive and opens the boxes used across the app.
///
/// We store cached domain data as JSON strings in plain `Box<String>`s, which
/// keeps the project free of generated TypeAdapters (no build_runner step) and
/// makes the repo trivial to clone-and-run.
class HiveBoxes {
  HiveBoxes._();

  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<String>(AppConstants.usersBox),
      Hive.openBox<String>(AppConstants.cacheBox),
      Hive.openBox<String>(AppConstants.settingsBox),
    ]);
  }

  static Box<String> get users => Hive.box<String>(AppConstants.usersBox);
  static Box<String> get cache => Hive.box<String>(AppConstants.cacheBox);
  static Box<String> get settings => Hive.box<String>(AppConstants.settingsBox);
}
