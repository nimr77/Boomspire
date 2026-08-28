/// Named gap sizes (in logical pixels) used for spacing between widgets -
/// e.g. `SizedBox(height: AppThemeSpacing.space12)` inside a `Column`, or a
/// `Column`/`Row`'s own `spacing:` argument. Each getter is named after the
/// literal value it holds so existing pixel-perfect layouts are preserved
/// exactly while removing scattered magic numbers.
abstract final class AppThemeSpacing {
  static const double space2 = 2;
  static const double space3 = 3;
  static const double space4 = 4;
  static const double space6 = 6;
  static const double space8 = 8;
  static const double space10 = 10;
  static const double space12 = 12;
  static const double space14 = 14;
  static const double space16 = 16;
  static const double space18 = 18;
  static const double space20 = 20;
  static const double space22 = 22;
  static const double space28 = 28;
  static const double space32 = 32;
  static const double space40 = 40;
}
