import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NavigationFlowHelper {
  /// Navigate to a route directly
  static Future<void> navigate({
    required BuildContext context,
    required String destinationRoute,
    Map<String, dynamic>? extra,
  }) async {
    if (extra != null) {
      context.pushNamed(destinationRoute, extra: extra);
    } else {
      context.pushNamed(destinationRoute);
    }
  }

  /// Replace current route with a new route
  static Future<void> replace({
    required BuildContext context,
    required String destinationRoute,
    Map<String, dynamic>? extra,
  }) async {
    if (extra != null) {
      context.goNamed(destinationRoute, extra: extra);
    } else {
      context.goNamed(destinationRoute);
    }
  }

  /// Execute callback directly
  static Future<void> executeCallback({
    required VoidCallback onComplete,
  }) async {
    onComplete();
  }

  // Legacy method names for backward compatibility
  @Deprecated('Use navigate() instead')
  static Future<void> navigateWithAd({
    required BuildContext context,
    required WidgetRef ref,
    required String destinationRoute,
    required String fortuneType,
    Map<String, dynamic>? extra,
    bool canSkipAd = false,
  }) async {
    await navigate(
        context: context, destinationRoute: destinationRoute, extra: extra);
  }

  @Deprecated('Use replace() instead')
  static Future<void> replaceWithAd({
    required BuildContext context,
    required WidgetRef ref,
    required String destinationRoute,
    required String fortuneType,
    Map<String, dynamic>? extra,
    bool canSkipAd = false,
  }) async {
    await replace(
        context: context, destinationRoute: destinationRoute, extra: extra);
  }

  @Deprecated('Use executeCallback() instead')
  static Future<void> showAdWithCallback({
    required BuildContext context,
    required WidgetRef ref,
    required String fortuneType,
    required VoidCallback onComplete,
    bool canSkipAd = false,
  }) async {
    await executeCallback(onComplete: onComplete);
  }
}
