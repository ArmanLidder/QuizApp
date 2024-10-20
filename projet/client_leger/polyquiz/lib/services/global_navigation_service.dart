import 'package:flutter/material.dart';

class GlobalNavigationService {
  static final GlobalNavigationService _instance =
      GlobalNavigationService._internal();

  GlobalNavigationService._internal();

  factory GlobalNavigationService() {
    return _instance;
  }

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic>? navigateTo(String route, {dynamic arguments}) {
    return navigatorKey.currentState
        ?.pushReplacementNamed(route, arguments: arguments);
  }
}
