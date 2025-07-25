import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:fortune/routes/navigation_helper.dart';

void main() {
  group('NavigationHelper', () {
    test('should show navigation bar for main routes', () {
      // Test main routes
      final mainRoutes = [
        '/home',
        '/fortune',
        '/todo',
        '/physiognomy',
        '/profile',
      ];

      for (final route in mainRoutes) {
        final state = GoRouterState(
          location: route,
          matchedLocation: route,
          name: route.substring(1), // Remove leading slash for name
          path: route,
          fullPath: route,
          pathParameters: const {},
          queryParameters: const {},
          queryParametersAll: const {},
          extra: null,
          pageKey: const ValueKey('test'),
        );

        expect(
          NavigationHelper.shouldShowNavigationBar(state),
          true,
          reason: 'Navigation bar should be visible for $route',
        );
      }
    });

    test('should show navigation bar for fortune sub-routes', () {
      // Test fortune sub-routes - should show navigation
      final fortuneSubRoutes = [
        '/fortune/daily',
        '/fortune/saju',
        '/fortune/time',
        '/fortune/love',
        '/fortune/career',
      ];

      for (final route in fortuneSubRoutes) {
        final state = GoRouterState(
          location: route,
          matchedLocation: route,
          name: route.substring(route.lastIndexOf('/') + 1),
          path: route,
          fullPath: route,
          pathParameters: const {},
          queryParameters: const {},
          queryParametersAll: const {},
          extra: null,
          pageKey: const ValueKey('test'),
        );

        expect(
          NavigationHelper.shouldShowNavigationBar(state),
          true,
          reason: 'Navigation bar should be visible for fortune sub-route: $route',
        );
      }
    });

    test('should hide navigation bar for non-fortune sub-routes', () {
      // Test non-fortune sub-routes
      final subRoutes = [
        '/profile/edit',
        '/profile/statistics',
        '/settings',
        '/settings/social-accounts',
        '/trend/detail',
        '/premium/subscribe',
      ];

      for (final route in subRoutes) {
        final state = GoRouterState(
          location: route,
          matchedLocation: route,
          name: route.substring(route.lastIndexOf('/') + 1),
          path: route,
          fullPath: route,
          pathParameters: const {},
          queryParameters: const {},
          queryParametersAll: const {},
          extra: null,
          pageKey: const ValueKey('test'),
        );

        expect(
          NavigationHelper.shouldShowNavigationBar(state),
          false,
          reason: 'Navigation bar should be hidden for $route',
        );
      }
    });

    test('should calculate route depth correctly', () {
      expect(NavigationHelper.getRouteDepth('/'), 0);
      expect(NavigationHelper.getRouteDepth('/home'), 1);
      expect(NavigationHelper.getRouteDepth('/fortune/daily'), 2);
      expect(NavigationHelper.getRouteDepth('/profile/edit/details'), 3);
    });

    test('should identify first-depth routes correctly', () {
      expect(NavigationHelper.isFirstDepthRoute('/home'), true);
      expect(NavigationHelper.isFirstDepthRoute('/fortune'), true);
      expect(NavigationHelper.isFirstDepthRoute('/fortune/daily'), false);
      expect(NavigationHelper.isFirstDepthRoute('/settings'), false);
    });
  });
}