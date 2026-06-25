import 'package:flutter/material.dart';

/// Playful brand palette + a rotating set of bright accent colors used to give
/// each project/task card its own personality.
class AppColors {
  AppColors._();

  /// Primary brand seed — a friendly violet.
  static const Color seed = Color(0xFF6C5CE7);

  /// Soft tinted backgrounds.
  static const Color lightBackground = Color(0xFFF5F4FF);
  static const Color darkBackground = Color(0xFF16151F);

  /// Bright, cheerful accents cycled by id.
  static const List<Color> accents = [
    Color(0xFFFF6B6B), // coral
    Color(0xFF4ECDC4), // teal
    Color(0xFFFFC93C), // sunny yellow
    Color(0xFF6C5CE7), // violet
    Color(0xFFFF9F1C), // orange
    Color(0xFF4D96FF), // blue
    Color(0xFFA66CFF), // purple
    Color(0xFF2ED573), // green
    Color(0xFFFF6BCB), // pink
  ];

  /// Stable accent color for a given id.
  static Color accentFor(int id) => accents[id.abs() % accents.length];
}
