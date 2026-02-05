import 'package:flutter/material.dart';

class AppTheme {
  static const _seedGold = Color(0xFFD4A23A);
  static const _darkBackground = Color(0xFF0F1115);
  static const _darkSurface = Color(0xFF151A21);
  static const _darkSurfaceVariant = Color(0xFF1C2430);
  static const _darkOutline = Color(0xFF2A3442);
  static const _darkOnSurface = Color(0xFFE9EEF5);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedGold,
      brightness: Brightness.light,
      background: const Color(0xFFF6F2EA),
      surface: const Color(0xFFFFFFFF),
      surfaceVariant: const Color(0xFFEDE5D6),
      outline: const Color(0xFFB9A67E),
    );
    final base = ThemeData(useMaterial3: true, colorScheme: colorScheme);
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.background,
        foregroundColor: colorScheme.onBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      textTheme: _textTheme(base.textTheme),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        color: colorScheme.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      chipTheme: _chipTheme(colorScheme),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
        fillColor: colorScheme.surfaceVariant,
      ),
      navigationBarTheme: _navigationBarTheme(colorScheme),
      filledButtonTheme: _filledButtonTheme(colorScheme),
      outlinedButtonTheme: _outlinedButtonTheme(colorScheme),
      textButtonTheme: _textButtonTheme(colorScheme),
      segmentedButtonTheme: _segmentedButtonTheme(colorScheme),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
      ),
      dividerColor: colorScheme.outline.withOpacity(0.5),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.surfaceVariant,
        contentTextStyle: TextStyle(color: colorScheme.onSurface),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData dark() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: _seedGold,
      onPrimary: Color(0xFF1B1406),
      primaryContainer: Color(0xFF3A2B09),
      onPrimaryContainer: _darkOnSurface,
      secondary: Color(0xFFB88B2C),
      onSecondary: Color(0xFF1B1406),
      secondaryContainer: Color(0xFF2B2312),
      onSecondaryContainer: _darkOnSurface,
      tertiary: Color(0xFF9C7A2A),
      onTertiary: Color(0xFF1B1406),
      background: _darkBackground,
      onBackground: _darkOnSurface,
      surface: _darkSurface,
      onSurface: _darkOnSurface,
      surfaceVariant: _darkSurfaceVariant,
      onSurfaceVariant: Color(0xFFC9D3DE),
      outline: _darkOutline,
      outlineVariant: Color(0xFF364252),
      error: Color(0xFFF2B8B5),
      onError: Color(0xFF3F1E1E),
    );
    final base = ThemeData(useMaterial3: true, colorScheme: colorScheme);
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.background,
        foregroundColor: colorScheme.onBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      textTheme: _textTheme(base.textTheme),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        color: colorScheme.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      chipTheme: _chipTheme(colorScheme),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
        fillColor: colorScheme.surfaceVariant,
      ),
      navigationBarTheme: _navigationBarTheme(colorScheme),
      filledButtonTheme: _filledButtonTheme(colorScheme),
      outlinedButtonTheme: _outlinedButtonTheme(colorScheme),
      textButtonTheme: _textButtonTheme(colorScheme),
      segmentedButtonTheme: _segmentedButtonTheme(colorScheme),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
      ),
      dividerColor: colorScheme.outline.withOpacity(0.6),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.surfaceVariant,
        contentTextStyle: TextStyle(color: colorScheme.onSurface),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      headlineSmall: base.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: base.bodyLarge?.copyWith(height: 1.4),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.5),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  static ChipThemeData _chipTheme(ColorScheme scheme) {
    return ChipThemeData(
      shape: StadiumBorder(
        side: BorderSide(color: scheme.outline),
      ),
      selectedColor: scheme.primary.withOpacity(0.18),
      secondarySelectedColor: scheme.primary.withOpacity(0.18),
      backgroundColor: scheme.surface,
      checkmarkColor: scheme.primary,
      labelStyle: TextStyle(color: scheme.onSurface),
      secondaryLabelStyle: TextStyle(color: scheme.onSurface),
    );
  }

  static NavigationBarThemeData _navigationBarTheme(ColorScheme scheme) {
    return NavigationBarThemeData(
      indicatorColor: scheme.primary.withOpacity(0.2),
      backgroundColor: scheme.surface,
      labelTextStyle: MaterialStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(MaterialState.selected)
              ? scheme.primary
              : scheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
      iconTheme: MaterialStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(MaterialState.selected)
              ? scheme.primary
              : scheme.onSurfaceVariant,
        ),
      ),
    );
  }

  static FilledButtonThemeData _filledButtonTheme(ColorScheme scheme) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme scheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        side: BorderSide(color: scheme.primary.withOpacity(0.7)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme(ColorScheme scheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  static SegmentedButtonThemeData _segmentedButtonTheme(ColorScheme scheme) {
    return SegmentedButtonThemeData(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        backgroundColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? scheme.primary.withOpacity(0.2)
              : scheme.surface,
        ),
        foregroundColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? scheme.primary
              : scheme.onSurface,
        ),
        side: MaterialStateProperty.all(
          BorderSide(color: scheme.outline),
        ),
      ),
    );
  }
}
