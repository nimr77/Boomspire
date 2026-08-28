import 'package:flutter/material.dart';

/// Named border stroke widths (in logical pixels) used by `Border.all`/
/// `BorderSide`, and named corner radii used by `BoxDecoration.borderRadius`/
/// `ClipRRect.borderRadius`. Each getter is named after the literal value it
/// holds so existing pixel-perfect layouts are preserved exactly while
/// removing scattered magic numbers.
abstract final class AppThemeBorders {
  static const double width1 = 1;
  static const double width1_2 = 1.2;
  static const double width1_5 = 1.5;
  static const double width2 = 2;
  static const double width2_5 = 2.5;
  static const double width3 = 3;

  static const BorderRadius radius6 = BorderRadius.all(Radius.circular(6));
  static const BorderRadius radius8 = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radius10 = BorderRadius.all(Radius.circular(10));
  static const BorderRadius radius12 = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radius14 = BorderRadius.all(Radius.circular(14));
  static const BorderRadius radius16 = BorderRadius.all(Radius.circular(16));
  static const BorderRadius radius20 = BorderRadius.all(Radius.circular(20));
  static const BorderRadius radius24 = BorderRadius.all(Radius.circular(24));
}
