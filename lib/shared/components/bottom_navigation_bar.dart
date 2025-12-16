import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';

class FortuneBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const FortuneBottomNavigationBar({
    super.key,
    required this.currentIndex});

  static const List<_NavItem> _items = [
    _NavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: '홈',
      route: '/home'),
    _NavItem(
      icon: Icons.auto_awesome_outlined,
      selectedIcon: Icons.auto_awesome,
      label: '운세',
      route: '/fortune'),
    _NavItem(
      icon: Icons.trending_up_outlined,
      selectedIcon: Icons.trending_up,
      label: '트렌드',
      route: '/trend'),
    _NavItem(
      icon: Icons.workspace_premium_outlined,
      selectedIcon: Icons.workspace_premium,
      label: '프리미엄',
      route: '/premium'),
    _NavItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: '프로필',
      route: '/profile')];

  int _getIndexFromPath(String path) {
    for (int i = 0; i < _items.length; i++) {
      if (path.startsWith(_items[i].route)) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final activeIndex = _getIndexFromPath(currentPath);
    final colors = context.colors;

    // Korean Traditional navigation bar with ink-wash top border
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        // Ink-wash effect: subtle top border instead of drop shadow
        border: Border(
          top: BorderSide(
            color: colors.textPrimary.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _items.length,
              (index) => _NavItemWidget(
                item: _items[index],
                isSelected: index == activeIndex,
                onTap: () {
                  DSHaptics.light();
                  // Only navigate if not already on the same route
                  if (currentPath != _items[index].route && !currentPath.startsWith(_items[index].route)) {
                    context.go(_items[index].route);
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route});
}

class _NavItemWidget extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    // Korean Traditional navigation item with vermilion seal indicator
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: colors.accentSecondary.withValues(alpha: 0.1),
        highlightColor: colors.accentSecondary.withValues(alpha: 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with traditional ink color
            Icon(
              isSelected ? item.selectedIcon : item.icon,
              size: 24,
              color: isSelected ? colors.textPrimary : colors.textTertiary,
            ),
            const SizedBox(height: 2),
            // Label with traditional typography
            Text(
              item.label,
              style: typography.labelSmall.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? colors.textPrimary : colors.textTertiary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 2),
            // Vermilion seal dot indicator (Korean traditional 인장 style)
            AnimatedContainer(
              duration: DSAnimation.durationFast,
              width: isSelected ? 4 : 0,
              height: isSelected ? 4 : 0,
              decoration: BoxDecoration(
                color: colors.accentSecondary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}