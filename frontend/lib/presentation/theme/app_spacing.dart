import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Spacing token scale.
///
/// Values are in logical pixels. Use the [.h] and [.w] extensions from
/// flutter_screenutil for responsive variants: `AppSpacing.lg.h`.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xl2 = 24;
  static const double xl3 = 32;
  static const double xl4 = 48;
  static const double xl5 = 64;

  /// Standard horizontal screen padding, responsive.
  static double get screenH => 20.w;

  /// Standard vertical screen padding, responsive.
  static double get screenV => 20.h;
}
