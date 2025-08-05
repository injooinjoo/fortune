import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State for managing navigation bar visibility
class NavigationVisibilityState {
  final bool isVisible;
  final bool isAnimating;

  const NavigationVisibilityState({
    this.isVisible = true,
    this.isAnimating = false});

  NavigationVisibilityState copyWith({
    bool? isVisible,
    bool? isAnimating}) {
    return NavigationVisibilityState(
      isVisible: isVisible ?? this.isVisible,
      isAnimating: isAnimating ?? this.isAnimating);
  }
}

/// Provider for managing navigation bar visibility
class NavigationVisibilityNotifier extends StateNotifier<NavigationVisibilityState> {
  NavigationVisibilityNotifier() : super(const NavigationVisibilityState());

  void show() {
    if (!state.isVisible && !state.isAnimating) {
      state = state.copyWith(isAnimating: true);
      // Add a small delay before showing to ensure smooth transition
      Future.delayed(const Duration(milliseconds: 50), () {
        state = state.copyWith(isVisible: true);
        // Reset animating state after animation completes
        Future.delayed(const Duration(milliseconds: 300), () {
          state = state.copyWith(isAnimating: false);
        });
      });
    }
  }

  void hide() {
    if (state.isVisible && !state.isAnimating) {
      state = state.copyWith(isAnimating: true);
      state = state.copyWith(isVisible: false);
      // Reset animating state after animation completes
      Future.delayed(const Duration(milliseconds: 300), () {
        state = state.copyWith(isAnimating: false);
      });
    }
  }

  void setVisibility(bool isVisible) {
    if (state.isVisible != isVisible) {
      if (isVisible) {
        show();
      } else {
        hide();
      }
    }
  }
}

final navigationVisibilityProvider = StateNotifierProvider<NavigationVisibilityNotifier, NavigationVisibilityState>((ref) => NavigationVisibilityNotifier());

/// Extension to determine if a route should show navigation bar
extension RouteNavigationVisibility on String {
  bool get shouldShowNavigationBar {
    // Main tab routes that should show navigation bar
    const mainRoutes = [
      '/home',
      '/fortune',
      '/todo',
      '/physiognomy',
      '/profile'];

    // Check if current route exactly matches or starts with a main route
    for (final mainRoute in mainRoutes) {
      if (this == mainRoute || (startsWith(mainRoute) && !_isDeepRoute(mainRoute))) {
        return true;
      }
    }

    // All other routes hide navigation bar
    return false;
  }

  /// Check if this is a deep route (more than 1 level deep,
  bool _isDeepRoute(String baseRoute) {
    // If the path is exactly the base route, it's not deep
    if (this == baseRoute) return false;
    
    // Get the path after the base route
    final remainingPath = substring(baseRoute.length);
    
    // If there's more than just a trailing slash, it's a deep route
    if (remainingPath.isEmpty || remainingPath == '/') return false;
    
    // Count slashes in the remaining path (excluding leading slash,
    final cleanPath = remainingPath.startsWith('/') ? remainingPath.substring(1) : remainingPath;
    return cleanPath.contains('/') || cleanPath.isNotEmpty;
  }

  /// Get the depth of the current route
  int get routeDepth {
    if (isEmpty) return 0;
    
    // Count the number of segments in the path
    final segments = split('/').where((s) => s.isNotEmpty).toList();
    
    return segments.length;
  }

  /// Check if this is a first-depth route
  bool get isFirstDepthRoute {
    // Special handling for main routes
    const mainRoutes = [
      '/home',
      '/fortune',
      '/todo',
      '/physiognomy',
      '/profile'];

    // Check if this is exactly a main route
    if (mainRoutes.contains(this)) {
      return true;
    }

    // For sub-routes, check if they're only one level deep
    for (final mainRoute in mainRoutes) {
      if (startsWith(mainRoute)) {
        final segments = split('/').where((s) => s.isNotEmpty).toList();
        // Main route + one segment = first depth sub-route
        return segments.length <= 2;
      }
    }

    return false;
  }
}