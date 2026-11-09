/// Spacing, radii and sizing tokens.
///
/// Every screen in every DusRel app must use these constants instead of
/// ad-hoc numbers, so spacing stays consistent across the suite.
class AppSpacing {
  AppSpacing._();

  /// Base unit: 4pt scale.
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Default screen edge padding.
  static const double screenEdge = 16;
}

/// Corner radii tokens.
class AppRadii {
  AppRadii._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double full = 999;
}

/// Sizing tokens.
class AppSizes {
  AppSizes._();

  /// Minimum touch target (WCAG 2.1 AA).
  static const double minTouchTarget = 44;

  /// Standard avatar sizes.
  static const double avatarSm = 32;
  static const double avatarMd = 40;
  static const double avatarLg = 56;

  /// Width at which the app shell switches from a bottom navigation bar
  /// to a side navigation rail.
  static const double railBreakpoint = 768;
}
