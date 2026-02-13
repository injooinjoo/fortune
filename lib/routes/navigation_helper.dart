import 'package:go_router/go_router.dart';

/// Helper class to determine navigation visibility based on GoRouter state
/// 4탭 스마트 구조: 홈(Chat) / 운세 / 기록 / 더보기
class NavigationHelper {
  /// Determines if the navigation bar should be visible for a given route
  /// StatefulShellRoute handles nav visibility automatically,
  /// but this helper is kept for compatibility with other checks.
  static bool shouldShowNavigationBar(GoRouterState state) {
    final location = state.matchedLocation;

    // 4탭 메인 라우트에서 바 표시
    const mainRoutes = [
      '/chat',
      '/home',
      '/fortune',
      '/history',
      '/more',
    ];

    if (mainRoutes.contains(location)) {
      return true;
    }

    // Sub-routes under /more (profile, premium, trend) hide nav
    if (location.startsWith('/more/')) {
      return false;
    }

    // Fortune sub-routes (interactive) hide nav
    if (location.startsWith('/fortune/')) {
      return false;
    }

    // All other routes hide navigation bar
    return false;
  }

  /// Get route depth from location
  static int getRouteDepth(String location) {
    if (location.isEmpty || location == '/') return 0;

    final segments = location.split('/').where((s) => s.isNotEmpty).toList();
    return segments.length;
  }

  /// Check if this is a first-depth route (main tab)
  static bool isFirstDepthRoute(String location) {
    const mainRoutes = [
      '/chat',
      '/home',
      '/fortune',
      '/history',
      '/more',
    ];

    return mainRoutes.contains(location);
  }
}
