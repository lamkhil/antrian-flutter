import 'package:flutter/material.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => key.currentState;
  static BuildContext? get context => key.currentContext;
}
