import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Hitha design tokens.
abstract final class HithaColors {
  static const cream = Color(0xFFE8F6F1);
  static const creamLight = Color(0xFFF3FBF8);
  static const creamDark = Color(0xFFEDF1F0);
  static const hairline = Color(0xFFD3EAE4);
  static const forest = Color(0xFF0D3B66);
  static const forestDark = Color(0xFF082641);
  static const forestDeep = Color(0xFF061B30);
  static const forestHover = Color(0xFF0F4573);
  static const mint = Color(0xFF00A8B5);
  static const mintDark = Color(0xFF00838D);
  static const moss = Color(0xFF4CAF50);
  static const sprout = Color(0xFFD4ECD1);
  static const saffron = Color(0xFFD4A24C);
  static const saffronLight = Color(0xFFFEF3C7);
  static const clay = Color(0xFFB5533C);
  static const clayTint = Color(0xFFF4E2DD);
  static const ink = Color(0xFF0D3B66);
  static const inkSoft = Color(0xFF375D82);
  static const inkFaint = Color(0xFF7C97AF);
  static const slate300 = Color(0xFFCBD5E1);
  static const slate400 = Color(0xFF94A3B8);
}

abstract final class HithaSpacing {
  static const page = 16.0;
  static const pageBottom = 80.0;
}

abstract final class HithaRadius {
  static const card = 24.0;
  static const cardLg = 32.0;
  static const sub = 16.0;
  static const badge = 8.0;
}

/// Typography scale: Plus Jakarta Sans for UI text,
/// JetBrains Mono for SLMC codes, prices and timestamps.
abstract final class HithaText {
  static TextStyle get _base => GoogleFonts.plusJakartaSans();

  static TextStyle get hero => _base.copyWith(
      fontSize: 32, fontWeight: FontWeight.w800, height: 1.15, letterSpacing: -0.68, color: HithaColors.forest);
  static TextStyle get h1 => _base.copyWith(
      fontSize: 26, fontWeight: FontWeight.w800, height: 1.25, letterSpacing: -0.39, color: HithaColors.forest);
  static TextStyle get h2 => _base.copyWith(
      fontSize: 20, fontWeight: FontWeight.w700, height: 1.3, letterSpacing: -0.2, color: HithaColors.forest);
  static TextStyle get h3 =>
      _base.copyWith(fontSize: 16, fontWeight: FontWeight.w700, height: 1.4, color: HithaColors.forest);
  static TextStyle get body =>
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w400, height: 1.6, color: HithaColors.inkSoft);
  static TextStyle get bodyMedium =>
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w500, height: 1.6, color: HithaColors.inkSoft);
  static TextStyle get bodySmall =>
      _base.copyWith(fontSize: 12.5, fontWeight: FontWeight.w400, height: 1.45, color: HithaColors.inkSoft);
  static TextStyle get caption => _base.copyWith(
      fontSize: 11, fontWeight: FontWeight.w600, height: 1.4, letterSpacing: 0.5, color: HithaColors.inkFaint);
  static TextStyle get mono => GoogleFonts.jetBrainsMono(
      fontSize: 13, fontWeight: FontWeight.w700, height: 1.4, letterSpacing: 0.65, color: HithaColors.forest);
}

abstract final class HithaShadows {
  static const resting = [BoxShadow(color: Color(0x140D3B66), blurRadius: 4, offset: Offset(0, 2))];
  static const elevated = [BoxShadow(color: Color(0x1F0D3B66), blurRadius: 20, offset: Offset(0, 8))];
}

/// Serene clinical light palette matching the Hitha Platform
ThemeData buildHithaTheme() {
  final scheme = const ColorScheme.light(
    primary: HithaColors.forest,
    onPrimary: Colors.white,
    primaryContainer: HithaColors.sprout,
    onPrimaryContainer: HithaColors.forest,
    secondary: HithaColors.mint,
    onSecondary: Colors.white,
    secondaryContainer: HithaColors.creamDark,
    onSecondaryContainer: HithaColors.forest,
    tertiary: HithaColors.moss,
    surface: Colors.white,
    onSurface: HithaColors.ink,
    onSurfaceVariant: HithaColors.inkSoft,
    outline: HithaColors.hairline,
    outlineVariant: HithaColors.hairline,
    error: HithaColors.clay,
    errorContainer: HithaColors.clayTint,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: HithaColors.cream,
    textTheme: GoogleFonts.plusJakartaSansTextTheme().apply(
      bodyColor: HithaColors.inkSoft,
      displayColor: HithaColors.forest,
    ),
    dividerTheme: const DividerThemeData(color: HithaColors.hairline, thickness: 1, space: 1),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? HithaColors.forest : Colors.transparent),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),
  );
}
