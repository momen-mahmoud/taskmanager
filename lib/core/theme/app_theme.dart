import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Centralized light & dark themes with a **playful, rounded** design language:
/// chunky radii, a friendly violet palette, the rounded Nunito/Fredoka fonts,
/// and soft tinted surfaces.
class AppTheme {
  AppTheme._();

  static const String _bodyFont = 'Nunito';
  static const String _displayFont = 'Fredoka';

  // Rounded shape tokens reused across components.
  static const double rCard = 24;
  static const double rField = 18;
  static const double rButton = 18;
  static const double rPill = 40;

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: brightness,
    );
    final background =
        isLight ? AppColors.lightBackground : AppColors.darkBackground;

    final base = ThemeData(brightness: brightness, useMaterial3: true);
    final textTheme = _textTheme(base.textTheme, scheme);

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: background,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontFamily: _displayFont,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? Colors.white : scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rField),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rField),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rField),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rButton),
          ),
          textStyle: const TextStyle(
            fontFamily: _displayFont,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rButton),
          ),
          textStyle: const TextStyle(
            fontFamily: _displayFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isLight ? Colors.white : scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rCard),
        ),
        margin: EdgeInsets.zero,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 3,
        highlightElevation: 1,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rPill),
        ),
        extendedTextStyle: const TextStyle(
          fontFamily: _displayFont,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isLight ? Colors.white : scheme.surfaceContainerHigh,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.4),
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, ColorScheme scheme) {
    // Body/labels in Nunito (bumped weight for a friendlier feel),
    // large headings in the chunky rounded Fredoka.
    final body = base.apply(
      fontFamily: _bodyFont,
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
    TextStyle? display(TextStyle? s) =>
        s?.copyWith(fontFamily: _displayFont, fontWeight: FontWeight.w600);
    return body.copyWith(
      displayLarge: display(body.displayLarge),
      displayMedium: display(body.displayMedium),
      displaySmall: display(body.displaySmall),
      headlineLarge: display(body.headlineLarge),
      headlineMedium: display(body.headlineMedium),
      headlineSmall: display(body.headlineSmall),
      titleLarge: display(body.titleLarge),
      bodyLarge: body.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      bodyMedium: body.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: body.labelLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}
