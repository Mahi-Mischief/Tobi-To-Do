import 'package:flutter/material.dart';

/// Central spacing scale to keep vertical and horizontal rhythm consistent.
class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}

/// Layout breakpoints for responsive layouts.
class AppBreakpoints {
  static const double mobile = 600;
  static const double tablet = 1100;

  static bool isMobile(BoxConstraints constraints) => constraints.maxWidth < mobile;
  static bool isTablet(BoxConstraints constraints) =>
      constraints.maxWidth >= mobile && constraints.maxWidth <= tablet;
  static bool isDesktop(BoxConstraints constraints) => constraints.maxWidth > tablet;
}
