import 'package:flutter/widgets.dart';

/// Kategori ukuran layar responsif aplikasi.
enum AppLayoutSize {
  /// Layar sempit / mobile (`< 700 px`).
  compact,

  /// Layar tablet / jendela sedang (`700 .. < 1100 px`).
  medium,

  /// Layar desktop web (`>= 1100 px`).
  expanded,
}

/// Breakpoint responsif terpusat untuk shell dan grid layout.
abstract final class AppBreakpoints {
  static const double compactMax = 700;
  static const double mediumMax = 1100;
  static const double contentMaxWidth = 1360;

  static AppLayoutSize fromWidth(double width) {
    if (width < compactMax) return AppLayoutSize.compact;
    if (width < mediumMax) return AppLayoutSize.medium;
    return AppLayoutSize.expanded;
  }

  static AppLayoutSize of(BuildContext context) {
    return fromWidth(MediaQuery.sizeOf(context).width);
  }
}
