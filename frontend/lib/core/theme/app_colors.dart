import 'package:flutter/material.dart';

/// Palet warna resmi Isyaratify berdasarkan token desain Stitch.
abstract final class AppColors {
  // Brand & Primary
  static const Color primary = Color(0xFF453FD6);
  static const Color primaryContainer = Color(0xFF5F5BF0);
  static const Color headerIndigo = Color(0xFF5F5BF0);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFF7F3FF);
  static const Color primaryFixed = Color(0xFFE2DFFF);
  static const Color primaryFixedDim = Color(0xFFC2C1FF);
  static const Color onPrimaryFixed = Color(0xFF0D006A);
  static const Color onPrimaryFixedVariant = Color(0xFF3228C5);

  // Secondary & Accent Yellow
  static const Color secondary = Color(0xFF775A00);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFDC73A);
  static const Color onSecondaryContainer = Color(0xFF6F5400);
  static const Color secondaryFixed = Color(0xFFFFDF9A);
  static const Color secondaryFixedDim = Color(0xFFF4BF32);
  static const Color accentYellow = Color(0xFFFFC93C);
  static const Color accentYellowLight = Color(0xFFFFF7DF);

  // Tertiary & Feedback Success
  static const Color tertiary = Color(0xFF00662B);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF008239);
  static const Color onTertiaryContainer = Color(0xFFDBFFDA);
  static const Color tertiaryFixed = Color(0xFF6BFF8F);
  static const Color feedbackSuccess = Color(0xFF22C55E);
  static const Color feedbackSuccessLight = Color(0xFFE8F8EE);

  // Error & Feedback Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color feedbackError = Color(0xFFEF4444);
  static const Color feedbackErrorLight = Color(0xFFFEE2E2);

  // Surface & Neutrals
  static const Color surface = Color(0xFFFBF8FF);
  static const Color surfaceCanvas = Color(0xFFF7F8FC);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF4F2FD);
  static const Color surfaceContainer = Color(0xFFEEEDF7);
  static const Color surfaceContainerHigh = Color(0xFFE8E7F1);
  static const Color surfaceContainerHighest = Color(0xFFE3E1EC);
  static const Color onSurface = Color(0xFF1A1B22);
  static const Color onSurfaceVariant = Color(0xFF464555);
  static const Color outline = Color(0xFF777586);
  static const Color outlineVariant = Color(0xFFC7C4D7);
  static const Color borderSubtle = Color(0xFFEDEEF6);
  static const Color cameraBackdrop = Color(0xFF1E1E2E);
  static const Color inverseSurface = Color(0xFF2F3038);
  static const Color inverseOnSurface = Color(0xFFF1EFFA);
  static const Color inversePrimary = Color(0xFFC2C1FF);
}

/// Ekstensi tema untuk warna semantik kustom Isyaratify di luar [ColorScheme].
@immutable
class IsyaratifyColors extends ThemeExtension<IsyaratifyColors> {
  const IsyaratifyColors({
    required this.headerIndigo,
    required this.accentYellow,
    required this.accentYellowLight,
    required this.onAccentYellowContainer,
    required this.primaryFixed,
    required this.onPrimaryFixed,
    required this.success,
    required this.successLight,
    required this.onSuccessContainer,
    required this.feedbackError,
    required this.feedbackErrorLight,
    required this.surfaceCanvas,
    required this.surfaceCard,
    required this.borderSubtle,
    required this.cameraBackdrop,
  });

  final Color headerIndigo;
  final Color accentYellow;
  final Color accentYellowLight;
  final Color onAccentYellowContainer;
  final Color primaryFixed;
  final Color onPrimaryFixed;
  final Color success;
  final Color successLight;
  final Color onSuccessContainer;
  final Color feedbackError;
  final Color feedbackErrorLight;
  final Color surfaceCanvas;
  final Color surfaceCard;
  final Color borderSubtle;
  final Color cameraBackdrop;

  static const light = IsyaratifyColors(
    headerIndigo: AppColors.headerIndigo,
    accentYellow: AppColors.accentYellow,
    accentYellowLight: AppColors.accentYellowLight,
    onAccentYellowContainer: AppColors.onSecondaryContainer,
    primaryFixed: AppColors.primaryFixed,
    onPrimaryFixed: AppColors.onPrimaryFixed,
    success: AppColors.feedbackSuccess,
    successLight: AppColors.feedbackSuccessLight,
    onSuccessContainer: AppColors.tertiary,
    feedbackError: AppColors.feedbackError,
    feedbackErrorLight: AppColors.feedbackErrorLight,
    surfaceCanvas: AppColors.surfaceCanvas,
    surfaceCard: AppColors.surfaceCard,
    borderSubtle: AppColors.borderSubtle,
    cameraBackdrop: AppColors.cameraBackdrop,
  );

  static const dark = IsyaratifyColors(
    headerIndigo: AppColors.primaryContainer,
    accentYellow: AppColors.accentYellow,
    accentYellowLight: Color(0xFF3B3014),
    onAccentYellowContainer: Color(0xFFFFDF9A),
    primaryFixed: Color(0xFF2D2A66),
    onPrimaryFixed: Color(0xFFE2DFFF),
    success: AppColors.feedbackSuccess,
    successLight: Color(0xFF133320),
    onSuccessContainer: Color(0xFF6BFF8F),
    feedbackError: AppColors.feedbackError,
    feedbackErrorLight: Color(0xFF3E1818),
    surfaceCanvas: Color(0xFF12131A),
    surfaceCard: Color(0xFF1A1C26),
    borderSubtle: Color(0xFF2A2C3B),
    cameraBackdrop: AppColors.cameraBackdrop,
  );

  /// Mengambil [IsyaratifyColors] dari [BuildContext] dengan fallback aman ke [light].
  static IsyaratifyColors of(BuildContext context) {
    return Theme.of(context).extension<IsyaratifyColors>() ?? light;
  }

  @override
  IsyaratifyColors copyWith({
    Color? headerIndigo,
    Color? accentYellow,
    Color? accentYellowLight,
    Color? onAccentYellowContainer,
    Color? primaryFixed,
    Color? onPrimaryFixed,
    Color? success,
    Color? successLight,
    Color? onSuccessContainer,
    Color? feedbackError,
    Color? feedbackErrorLight,
    Color? surfaceCanvas,
    Color? surfaceCard,
    Color? borderSubtle,
    Color? cameraBackdrop,
  }) {
    return IsyaratifyColors(
      headerIndigo: headerIndigo ?? this.headerIndigo,
      accentYellow: accentYellow ?? this.accentYellow,
      accentYellowLight: accentYellowLight ?? this.accentYellowLight,
      onAccentYellowContainer:
          onAccentYellowContainer ?? this.onAccentYellowContainer,
      primaryFixed: primaryFixed ?? this.primaryFixed,
      onPrimaryFixed: onPrimaryFixed ?? this.onPrimaryFixed,
      success: success ?? this.success,
      successLight: successLight ?? this.successLight,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      feedbackError: feedbackError ?? this.feedbackError,
      feedbackErrorLight: feedbackErrorLight ?? this.feedbackErrorLight,
      surfaceCanvas: surfaceCanvas ?? this.surfaceCanvas,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      cameraBackdrop: cameraBackdrop ?? this.cameraBackdrop,
    );
  }

  @override
  IsyaratifyColors lerp(ThemeExtension<IsyaratifyColors>? other, double t) {
    if (other is! IsyaratifyColors) return this;
    return IsyaratifyColors(
      headerIndigo: Color.lerp(headerIndigo, other.headerIndigo, t)!,
      accentYellow: Color.lerp(accentYellow, other.accentYellow, t)!,
      accentYellowLight: Color.lerp(
        accentYellowLight,
        other.accentYellowLight,
        t,
      )!,
      onAccentYellowContainer: Color.lerp(
        onAccentYellowContainer,
        other.onAccentYellowContainer,
        t,
      )!,
      primaryFixed: Color.lerp(primaryFixed, other.primaryFixed, t)!,
      onPrimaryFixed: Color.lerp(onPrimaryFixed, other.onPrimaryFixed, t)!,
      success: Color.lerp(success, other.success, t)!,
      successLight: Color.lerp(successLight, other.successLight, t)!,
      onSuccessContainer: Color.lerp(
        onSuccessContainer,
        other.onSuccessContainer,
        t,
      )!,
      feedbackError: Color.lerp(feedbackError, other.feedbackError, t)!,
      feedbackErrorLight: Color.lerp(
        feedbackErrorLight,
        other.feedbackErrorLight,
        t,
      )!,
      surfaceCanvas: Color.lerp(surfaceCanvas, other.surfaceCanvas, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      cameraBackdrop: Color.lerp(cameraBackdrop, other.cameraBackdrop, t)!,
    );
  }
}
