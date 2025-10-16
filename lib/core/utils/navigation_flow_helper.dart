import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NavigationFlowHelper {
  /// Navigate to a route directly (no ad screen)
  static Future<void> navigateWithAd({
    required BuildContext context,
    required WidgetRef ref,
    required String destinationRoute,
    required String fortuneType,
    Map<String, dynamic>? extra,
    bool canSkipAd = false}) async {
    // Direct navigation for all users
    if (extra != null) {
      context.pushNamed(destinationRoute, extra: extra);
    } else {
      context.pushNamed(destinationRoute);
    }
  }

  /// Replace current route with a new route (no ad screen)
  static Future<void> replaceWithAd({
    required BuildContext context,
    required WidgetRef ref,
    required String destinationRoute,
    required String fortuneType,
    Map<String, dynamic>? extra,
    bool canSkipAd = false}) async {
    // Direct navigation for all users
    if (extra != null) {
      context.goNamed(destinationRoute, extra: extra);
    } else {
      context.goNamed(destinationRoute);
    }
  }

  /// Execute callback directly (no ad screen)
  static Future<void> showAdWithCallback({
    required BuildContext context,
    required WidgetRef ref,
    required String fortuneType,
    required VoidCallback onComplete,
    bool canSkipAd = false}) async {
    // Execute callback directly for all users
    onComplete();
  }
}
