import 'package:fortune/core/theme/toss_theme.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

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
    final theme = Theme.of(context);
    final currentPath = GoRouterState.of(context).uri.path;
    final activeIndex = _getIndexFromPath(currentPath);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? TossDesignSystem.grayDark100
            : TossDesignSystem.white,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? TossDesignSystem.white.withValues(alpha: 0.1)
                : TossDesignSystem.black.withValues(alpha: 0.04),
            offset: const Offset(0, -1),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
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
                  HapticFeedback.lightImpact();
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
    final theme = Theme.of(context);
    
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? item.selectedIcon : item.icon,
              size: 24,
              color: isSelected 
                ? TossTheme.textBlack 
                : TossTheme.textGray600),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected 
                  ? TossTheme.textBlack 
                  : TossTheme.textGray600,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}