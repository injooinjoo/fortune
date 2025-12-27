import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// Helper class to determine navigation visibility based on GoRouter state
class NavigationHelper {
  /// Determines if the navigation bar should be visible for a given route
  static bool shouldShowNavigationBar(GoRouterState state) {
    final location = state.matchedLocation;

    // 홈(/chat)에서는 네비게이션 바 숨김
    if (location == '/chat') {
      return false;
    }

    // Main routes that should show navigation bar
    // Chat-First 4탭 구조: Home/Chat(숨김), 인사이트, 탐구, 트렌드
    // 프로필은 각 페이지 상단 ProfileHeaderIcon → 바텀시트로 접근
    const mainRoutes = [
      '/home',
      '/fortune',
      '/trend'];

    // Check if current location is exactly a main route
    if (mainRoutes.contains(location)) {
      if (kDebugMode) {
        debugPrint('Fortune cached');
      }
      return true;
    }

    // Settings and other nested routes should hide navigation
    if (location.startsWith('/settings')) {
      if (kDebugMode) {
        debugPrint('Fortune cached');
      }
      return false;
    }

    // Fortune sub-routes should SHOW navigation bar by default
    // This allows fortune pages to have navigation bar visible when no bottom sheet is present
    if (location.startsWith('/fortune/')) {
      // Add specific routes that should hide navigation if needed
      const hideNavigationRoutes = [
        // Add specific fortune routes that should hide navigation here if needed
      ];
      
      if (hideNavigationRoutes.contains(location)) {
        if (kDebugMode) {
          debugPrint('Fortune cached');
        }
        return false;
      }
      
      // Default: show navigation for fortune sub-routes
      if (kDebugMode) {
        debugPrint('Fortune cached');
      }
      return true;
    }

    // Profile sub-routes (except history which should show navigation,
    if (location.startsWith('/profile/')) {
      // History is accessible from profile but should show navigation
      if (location == '/profile/history') {
        return false;
      }
      return false;
    }

    // Trend sub-routes should hide navigation
    if (location.startsWith('/trend/') && location != '/trend') {
      return false;
    }

    // All other routes hide navigation bar
    if (kDebugMode) {
      debugPrint('Fortune cached');
    }
    return false;
  }

  /// Get route depth from location
  static int getRouteDepth(String location) {
    if (location.isEmpty || location == '/') return 0;
    
    final segments = location.split('/').where((s) => s.isNotEmpty).toList();
    return segments.length;
  }

  /// Check if this is a first-depth route
  static bool isFirstDepthRoute(String location) {
    // Chat-First 4탭 구조 (프로필은 바텀시트로 접근)
    const mainRoutes = [
      '/chat',
      '/home',
      '/fortune',
      '/trend'];

    return mainRoutes.contains(location);
  }
}