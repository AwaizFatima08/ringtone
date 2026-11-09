import 'package:flutter/material.dart';

/// Design tokens: large type, strong contrast, one colour per home-screen job.
abstract final class AppColors {
  static const navy = Color(0xFF16325C);
  static const call = Color(0xFF1B7F3B);
  static const message = Color(0xFF1565C0);
  static const alarm = Color(0xFFB45309);
  static const apps = Color(0xFF00796B);
  static const volume = Color(0xFF6A1B9A);
  static const loud = Color(0xFFC62828);
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;

  /// Height of every main button: easy to hit with an unsteady finger.
  static const buttonHeight = 64.0;
}

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.navy, brightness: brightness);
    final base = ThemeData(colorScheme: scheme, useMaterial3: true).textTheme;
    final text = base.copyWith(
      headlineSmall: base.headlineSmall?.copyWith(fontSize: 28, fontWeight: FontWeight.w700),
      titleLarge: base.titleLarge?.copyWith(fontSize: 25, fontWeight: FontWeight.w700),
      titleMedium: base.titleMedium?.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 21, height: 1.4),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 19, height: 1.4),
      labelLarge: base.labelLarge?.copyWith(fontSize: 21, fontWeight: FontWeight.w700),
    );
    const buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)));
    const buttonSize = Size(64, AppSpacing.buttonHeight);
    const buttonPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 12);
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      textTheme: text,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: brightness == Brightness.light ? AppColors.navy : scheme.surface,
        foregroundColor: brightness == Brightness.light ? Colors.white : scheme.onSurface,
        titleTextStyle: text.titleLarge?.copyWith(
          color: brightness == Brightness.light ? Colors.white : scheme.onSurface,
        ),
        toolbarHeight: 68,
        // The colour must be set here too, or the back arrow turns dark grey on navy.
        iconTheme: IconThemeData(
          size: 32,
          color: brightness == Brightness.light ? Colors.white : scheme.onSurface,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: text.labelLarge,
          iconSize: 30,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: text.labelLarge,
          iconSize: 30,
          side: BorderSide(color: scheme.outline, width: 2),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: const Size(48, 56), textStyle: text.titleMedium),
      ),
      cardTheme: const CardThemeData(
        margin: EdgeInsetsDirectional.only(bottom: AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        contentTextStyle: text.bodyLarge?.copyWith(color: scheme.onInverseSurface),
      ),
      dialogTheme: DialogThemeData(
        titleTextStyle: text.titleLarge?.copyWith(color: scheme.onSurface),
        contentTextStyle: text.bodyLarge?.copyWith(color: scheme.onSurface),
      ),
    );
  }
}
