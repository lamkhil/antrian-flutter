import 'package:flutter/material.dart';

extension ScreenSize on BuildContext {
  static const double sm = 640;
  static const double md = 768;
  static const double lg = 1024;
  static const double xl = 1280;
  static const double x2l = 1536;

  double get width => MediaQuery.of(this).size.width;

  bool get smUp => width >= sm;
  bool get mdUp => width >= md;
  bool get lgUp => width >= lg;
  bool get xlUp => width >= xl;
  bool get x2lUp => width >= x2l;

  bool get isMobile => width < sm;
  bool get isTablet => width >= sm && width < lg;
  bool get isDesktop => width >= lg;
}
