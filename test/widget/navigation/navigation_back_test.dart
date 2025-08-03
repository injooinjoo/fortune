import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fortune/routes/navigation_helper.dart';
import 'package:fortune/presentation/providers/navigation_visibility_provider.dart';

void main() {
  group('Navigation Back Button Tests', () {
    testWidgets('NavigationHelper shows navigation on fortune list page', (tester) async {
      // Create a test GoRouter
      final router = GoRouter(
        routes: [
          GoRoute(path: '/'),
          GoRoute(path: '/fortune'),
        ],
      );
      
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );
      
      router.go('/fortune');
      await tester.pumpAndSettle();
      
      // Get the current state from router
      final currentRoute = router.routerDelegate.currentConfiguration.uri.toString();
      expect(currentRoute, '/fortune');
    });
    
    test('NavigationHelper route depth calculation', () {
      expect(NavigationHelper.getRouteDepth('/'), 0);
      expect(NavigationHelper.getRouteDepth('/home'), 1);
      expect(NavigationHelper.getRouteDepth('/fortune'), 1);
      expect(NavigationHelper.getRouteDepth('/fortune/time'), 2);
      expect(NavigationHelper.getRouteDepth('/fortune/time/detail'), 3);
    });
    
    test('NavigationHelper first depth route detection', () {
      expect(NavigationHelper.isFirstDepthRoute('/home'), true);
      expect(NavigationHelper.isFirstDepthRoute('/fortune'), true);
      expect(NavigationHelper.isFirstDepthRoute('/trend'), true);
      expect(NavigationHelper.isFirstDepthRoute('/fortune/time'), false);
      expect(NavigationHelper.isFirstDepthRoute('/settings/notifications'), false);
    });
    
    testWidgets('Navigation visibility provider animates correctly', (tester) async {
      final container = ProviderContainer();
      
      // Initial state should be visible
      expect(container.read(navigationVisibilityProvider).isVisible, true);
      expect(container.read(navigationVisibilityProvider).isAnimating, false);
      
      // Hide navigation
      container.read(navigationVisibilityProvider.notifier).hide();
      
      // Should start animating
      expect(container.read(navigationVisibilityProvider).isAnimating, true);
      expect(container.read(navigationVisibilityProvider).isVisible, false);
      
      // Wait for animation to complete
      await tester.pump(const Duration(milliseconds: 350));
      
      // Animation should be complete
      expect(container.read(navigationVisibilityProvider).isAnimating, false);
      expect(container.read(navigationVisibilityProvider).isVisible, false);
      
      // Show navigation
      container.read(navigationVisibilityProvider.notifier).show();
      
      // Should start animating with delay
      expect(container.read(navigationVisibilityProvider).isAnimating, true);
      
      // Wait for delay
      await tester.pump(const Duration(milliseconds: 100));
      
      // Should now be visible
      expect(container.read(navigationVisibilityProvider).isVisible, true);
      
      // Wait for animation to complete
      await tester.pump(const Duration(milliseconds: 350));
      
      // Animation should be complete
      expect(container.read(navigationVisibilityProvider).isAnimating, false);
      expect(container.read(navigationVisibilityProvider).isVisible, true);
      
      container.dispose();
    });
    
    test('Route depth calculation', () {
      expect(NavigationHelper.getRouteDepth('/'), 0);
      expect(NavigationHelper.getRouteDepth('/home'), 1);
      expect(NavigationHelper.getRouteDepth('/fortune'), 1);
      expect(NavigationHelper.getRouteDepth('/fortune/time'), 2);
      expect(NavigationHelper.getRouteDepth('/fortune/time/detail'), 3);
    });
    
    test('First depth route detection', () {
      expect(NavigationHelper.isFirstDepthRoute('/home'), true);
      expect(NavigationHelper.isFirstDepthRoute('/fortune'), true);
      expect(NavigationHelper.isFirstDepthRoute('/trend'), true);
      expect(NavigationHelper.isFirstDepthRoute('/fortune/time'), false);
      expect(NavigationHelper.isFirstDepthRoute('/settings/notifications'), false);
    });
  });
}