import 'package:flutter/widgets.dart';

/// Centralised responsive breakpoints used across the entire app.
///
/// Always use these helpers instead of hardcoding `MediaQuery` width checks
/// inside individual widgets.
class AppBreakpoints {
  AppBreakpoints._();

  static const double mobileMax = 600;
  static const double tabletMax = 1200;

  static double width(BuildContext ctx) => MediaQuery.of(ctx).size.width;

  static bool isMobile(BuildContext ctx) => width(ctx) < mobileMax;
  static bool isTablet(BuildContext ctx) =>
      width(ctx) >= mobileMax && width(ctx) < tabletMax;
  static bool isDesktop(BuildContext ctx) => width(ctx) >= tabletMax;

  /// Returns one of [mobile], [tablet] or [desktop] depending on width.
  static T value<T>(
    BuildContext ctx, {
    required T mobile,
    required T tablet,
    required T desktop,
  }) {
    if (isDesktop(ctx)) return desktop;
    if (isTablet(ctx)) return tablet;
    return mobile;
  }
}
