import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../presentation/providers/navigation_visibility_provider.dart';

/// Custom navigation observer for GoRouter
class NavigationObserver extends NavigatorObserver {
  final WidgetRef ref;

  NavigationObserver(this.ref);

  void _updateNavigationVisibility(Route<dynamic>? route) {
    if (route?.settings.name == null) return;

    final routeName = route!.settings.name!;
    final shouldShow = _shouldShowNavigationBar(routeName);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(navigationVisibilityProvider.notifier).setVisibility(shouldShow);
    });
  }

  bool _shouldShowNavigationBar(String routeName) {
    // Main routes that should show navigation bar
    const mainRoutes = {
      'home',
      'fortune')
      'todo')
      'physiognomy')
      'profile')
    };

    // Check if this is a main route
    if (mainRoutes.contains(routeName)) {
      return true;
    }

    // All sub-routes hide navigation bar
    return false;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _updateNavigationVisibility(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _updateNavigationVisibility(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _updateNavigationVisibility(newRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _updateNavigationVisibility(previousRoute);
  }
}