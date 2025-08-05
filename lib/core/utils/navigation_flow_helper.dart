import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../shared/components/ad_loading_screen.dart';

class NavigationFlowHelper {
  /// Navigate to a route with an ad screen if the user is not premium
  static Future<void> navigateWithAd({
    required BuildContext context,
    required WidgetRef ref,
    required String destinationRoute,
    required String fortuneType,
    Map<String, dynamic>? extra,
    bool canSkipAd = false}) async {
    final user = ref.read(userProvider).value;
    final isPremium = user?.userMetadata?['isPremium'] ?? false;

    // If premium user, navigate directly
    if (isPremium) {
      if (extra != null) {
        context.pushNamed(destinationRoute, extra: extra);
      } else {
        context.pushNamed(destinationRoute);
      }
      return;
    }

    // Show ad screen for non-premium users
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AdLoadingScreen(
          fortuneType: fortuneType,
          canSkip: canSkipAd,
          onComplete: () {
            Navigator.of(context).pop();
            // Navigate to destination after ad
            if (extra != null) {
              context.pushNamed(destinationRoute, extra: extra);
            } else {
              context.pushNamed(destinationRoute);
            }
          }),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child);
        },
        transitionDuration: const Duration(milliseconds: 300)));
  }

  /// Replace current route with a new route after showing an ad
  static Future<void> replaceWithAd({
    required BuildContext context,
    required WidgetRef ref,
    required String destinationRoute,
    required String fortuneType,
    Map<String, dynamic>? extra,
    bool canSkipAd = false}) async {
    final user = ref.read(userProvider).value;
    final isPremium = user?.userMetadata?['isPremium'] ?? false;

    // If premium user, replace directly
    if (isPremium) {
      if (extra != null) {
        context.goNamed(destinationRoute, extra: extra);
      } else {
        context.goNamed(destinationRoute);
      }
      return;
    }

    // Show ad screen for non-premium users
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AdLoadingScreen(
          fortuneType: fortuneType,
          canSkip: canSkipAd,
          onComplete: () {
            Navigator.of(context).pop();
            // Replace route after ad
            if (extra != null) {
              context.goNamed(destinationRoute, extra: extra);
            } else {
              context.goNamed(destinationRoute);
            }
          }),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child);
        },
        transitionDuration: const Duration(milliseconds: 300)));
  }

  /// Show an interstitial ad and execute a callback
  static Future<void> showAdWithCallback({
    required BuildContext context,
    required WidgetRef ref,
    required String fortuneType,
    required VoidCallback onComplete,
    bool canSkipAd = false}) async {
    final user = ref.read(userProvider).value;
    final isPremium = user?.userMetadata?['isPremium'] ?? false;

    // If premium user, execute callback directly
    if (isPremium) {
      onComplete();
      return;
    }

    // Show ad screen for non-premium users
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AdLoadingScreen(
          fortuneType: fortuneType,
          canSkip: canSkipAd,
          onComplete: () {
            Navigator.of(context).pop();
            onComplete();
          }),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child);
        },
        transitionDuration: const Duration(milliseconds: 300)));
  }
}
