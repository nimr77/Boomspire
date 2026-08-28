import 'package:flutter/widgets.dart';

/// Named [EdgeInsets] presets - one getter per distinct padding/margin
/// literal already used across the app's presentation layer. Naming
/// mirrors the value itself (`hXvY` = symmetric horizontal X / vertical Y,
/// `allN` = `EdgeInsets.all(N)`, `bottomN`/`topN` = `EdgeInsets.only(...)`,
/// `ltrbA_B_C_D` = `EdgeInsets.fromLTRB(...)`) so a call site's existing
/// pixel values are preserved exactly while removing magic numbers.
abstract final class AppThemePaddings {
  static const EdgeInsets all4 = EdgeInsets.all(4);
  static const EdgeInsets all12 = EdgeInsets.all(12);
  static const EdgeInsets all14 = EdgeInsets.all(14);
  static const EdgeInsets all16 = EdgeInsets.all(16);
  static const EdgeInsets all24 = EdgeInsets.all(24);
  static const EdgeInsets all28 = EdgeInsets.all(28);

  static const EdgeInsets ltrb0_16_16_16 = EdgeInsets.fromLTRB(0, 16, 16, 16);
  static const EdgeInsets ltrb16_16_16_96 = EdgeInsets.fromLTRB(
    16,
    16,
    16,
    96,
  );
  static const EdgeInsets ltrb16_8_16_0 = EdgeInsets.fromLTRB(16, 8, 16, 0);

  static const EdgeInsets top5 = EdgeInsets.only(top: 5);
  static const EdgeInsets bottom6 = EdgeInsets.only(bottom: 6);
  static const EdgeInsets bottom8 = EdgeInsets.only(bottom: 8);
  static const EdgeInsets bottom12 = EdgeInsets.only(bottom: 12);
  static const EdgeInsets bottom18 = EdgeInsets.only(bottom: 18);

  static const EdgeInsets h4 = EdgeInsets.symmetric(horizontal: 4);
  static const EdgeInsets h12 = EdgeInsets.symmetric(horizontal: 12);
  static const EdgeInsets h16 = EdgeInsets.symmetric(horizontal: 16);

  static const EdgeInsets v2 = EdgeInsets.symmetric(vertical: 2);
  static const EdgeInsets v6 = EdgeInsets.symmetric(vertical: 6);
  static const EdgeInsets v12 = EdgeInsets.symmetric(vertical: 12);
  static const EdgeInsets v14 = EdgeInsets.symmetric(vertical: 14);
  static const EdgeInsets v24 = EdgeInsets.symmetric(vertical: 24);

  static const EdgeInsets h4v4 = EdgeInsets.symmetric(
    horizontal: 4,
    vertical: 4,
  );
  static const EdgeInsets h4v12 = EdgeInsets.symmetric(
    horizontal: 4,
    vertical: 12,
  );
  static const EdgeInsets h8v2 = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 2,
  );
  static const EdgeInsets h8v3 = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 3,
  );
  static const EdgeInsets h8v5 = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 5,
  );
  static const EdgeInsets h10v5 = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 5,
  );
  static const EdgeInsets h10v6 = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 6,
  );
  static const EdgeInsets h12v4 = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 4,
  );
  static const EdgeInsets h12v6 = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  );
  static const EdgeInsets h12v8 = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
  );
  static const EdgeInsets h12v10 = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 10,
  );
  static const EdgeInsets h14v8 = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 8,
  );
  static const EdgeInsets h14v10 = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 10,
  );
  static const EdgeInsets h16v24 = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 24,
  );
  static const EdgeInsets h22v10 = EdgeInsets.symmetric(
    horizontal: 22,
    vertical: 10,
  );
  static const EdgeInsets h24v22 = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 22,
  );
  static const EdgeInsets h24v14 = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 14,
  );
  static const EdgeInsets h4v1 = EdgeInsets.symmetric(
    horizontal: 4,
    vertical: 1,
  );
  static const EdgeInsets h5v1 = EdgeInsets.symmetric(
    horizontal: 5,
    vertical: 1,
  );
  static const EdgeInsets h10v12 = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 12,
  );
  static const EdgeInsets h16v12 = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );
  static const EdgeInsets h16v14 = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 14,
  );
  static const EdgeInsets h20v14 = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 14,
  );
  static const EdgeInsets h28v14 = EdgeInsets.symmetric(
    horizontal: 28,
    vertical: 14,
  );
  static const EdgeInsets h40v32 = EdgeInsets.symmetric(
    horizontal: 40,
    vertical: 32,
  );
}
