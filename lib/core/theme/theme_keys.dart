import 'package:flutter/material.dart';

/// Global navigator key for theme-aware helpers and deep links.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Resolve current brightness from the active navigator context.
Brightness get currentAppBrightness {
  final context = appNavigatorKey.currentContext;
  if (context != null) {
    return Theme.of(context).brightness;
  }
  return WidgetsBinding.instance.platformDispatcher.platformBrightness;
}
