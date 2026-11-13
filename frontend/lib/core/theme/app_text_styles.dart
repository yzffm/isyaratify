import 'package:flutter/material.dart';

/// Skala tipografi Plus Jakarta Sans berdasarkan design token Stitch.
abstract final class AppTextStyles {
  static const String fontFamily = 'PlusJakartaSans';

  static const TextStyle displayLetter = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    height: 52 / 48,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineXl = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    letterSpacing: -0.4,
  );

  static const TextStyle headlineXlMobile = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 34 / 26,
    letterSpacing: -0.3,
  );

  static const TextStyle headlineLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    letterSpacing: -0.2,
  );

  static const TextStyle headlineMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
  );

  static const TextStyle headlineSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 18 / 12,
  );

  static const TextStyle labelLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
  );

  static const TextStyle labelMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 14 / 10,
    letterSpacing: 0.4,
  );

  /// Membangun [TextTheme] Material 3 dengan font [fontFamily].
  static TextTheme buildTextTheme(Color primaryText, Color secondaryText) {
    return TextTheme(
      displayLarge: displayLetter.copyWith(color: primaryText),
      displayMedium: headlineXl.copyWith(color: primaryText),
      displaySmall: headlineXlMobile.copyWith(color: primaryText),
      headlineLarge: headlineXl.copyWith(color: primaryText),
      headlineMedium: headlineLg.copyWith(color: primaryText),
      headlineSmall: headlineMd.copyWith(color: primaryText),
      titleLarge: headlineMd.copyWith(color: primaryText),
      titleMedium: headlineSm.copyWith(color: primaryText),
      titleSmall: labelLg.copyWith(color: primaryText),
      bodyLarge: bodyLg.copyWith(color: primaryText),
      bodyMedium: bodyMd.copyWith(color: primaryText),
      bodySmall: bodySm.copyWith(color: secondaryText),
      labelLarge: labelLg.copyWith(color: primaryText),
      labelMedium: labelMd.copyWith(color: secondaryText),
      labelSmall: labelSm.copyWith(color: secondaryText),
    );
  }
}
