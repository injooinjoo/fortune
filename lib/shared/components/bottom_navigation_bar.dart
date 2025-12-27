import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../presentation/providers/fortune_badge_provider.dart';

class FortuneBottomNavigationBar extends ConsumerWidget {
  final int currentIndex;

  const FortuneBottomNavigationBar({
    super.key,
    required this.currentIndex});

  // Chat-First 4탭 구조: Home(채팅) | 인사이트 | 탐구 | 트렌드
  // 프로필은 각 페이지 상단의 ProfileHeaderIcon을 통해 바텀시트로 접근
  static const List<_NavItem> _items = [
    _NavItem(
      icon: Icons.chat_bubble_outline,
      selectedIcon: Icons.chat_bubble,
      label: 'Home',
      route: '/chat'),
    _NavItem(
      icon: Icons.auto_awesome_outlined,
      selectedIcon: Icons.auto_awesome,
      label: '인사이트',
      route: '/home'),
    _NavItem(
      icon: Icons.explore_outlined,
      selectedIcon: Icons.explore,
      label: '탐구',
      route: '/fortune'),
    _NavItem(
      icon: Icons.trending_up_outlined,
      selectedIcon: Icons.trending_up,
      label: '트렌드',
      route: '/trend')];

  int _getIndexFromPath(String path) {
    for (int i = 0; i < _items.length; i++) {
      if (path.startsWith(_items[i].route)) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).uri.path;
    final activeIndex = _getIndexFromPath(currentPath);
    final colors = context.colors;
    final showFortuneBadge = ref.watch(fortuneBadgeProvider);

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
                showBadge: index == 2 && showFortuneBadge, // 탐구 탭(index 2)에만 배지 표시
                onTap: () {
                  DSHaptics.light();
                  // 탐구 탭 클릭 시 배지 제거
                  if (index == 2) {
                    ref.read(fortuneBadgeProvider.notifier).markAsRead();
                  }
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
  final bool showBadge;
  final VoidCallback onTap;

  const _NavItemWidget({
    required this.item,
    required this.isSelected,
    this.showBadge = false,
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
            // Icon with traditional ink color + badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  size: 24,
                  color: isSelected ? colors.textPrimary : colors.textTertiary,
                ),
                // 안읽음 배지 (빨간 점)
                if (showBadge)
                  Positioned(
                    right: -4,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors.accentSecondary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.surface,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
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