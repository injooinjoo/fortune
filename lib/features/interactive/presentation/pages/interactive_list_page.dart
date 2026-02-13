import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../core/services/fortune_haptic_service.dart';

class InteractiveListPage extends ConsumerWidget {
  const InteractiveListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interactiveFeatures = [
      const _InteractiveFeature(
        title: '포춘 쿠키',
        subtitle: '오늘의 행운 메시지를 확인해보세요',
        icon: Icons.cookie_outlined,
        route: '/chat', // Chat에서 포춘쿠키 칩 선택
        isAvailable: true,
      ),
      const _InteractiveFeature(
        title: '꿈 해몽',
        subtitle: '꿈에 숨겨진 의미를 해석해드립니다',
        icon: Icons.bedtime_outlined,
        route: '/interactive/dream',
        isAvailable: true,
      ),
      const _InteractiveFeature(
        title: '관상',
        subtitle: '얼굴을 분석해 운세를 알려드려요',
        icon: Icons.face_retouching_natural,
        route: '/interactive/face-reading',
        isAvailable: false,
      ),
      const _InteractiveFeature(
        title: '심리 테스트',
        subtitle: '다양한 심리 테스트로 자신을 알아보세요',
        icon: Icons.psychology_outlined,
        route: '/interactive/psychology-test',
        isAvailable: true,
      ),
      const _InteractiveFeature(
        title: '태몽',
        subtitle: '태몽의 의미를 해석해드립니다',
        icon: Icons.child_care_outlined,
        route: '/interactive/taemong',
        isAvailable: false,
      ),
      const _InteractiveFeature(
        title: '타로카드',
        subtitle: '타로카드로 보는 오늘의 운세',
        icon: Icons.style_outlined,
        route: '/interactive/tarot',
        isAvailable: true,
      ),
      const _InteractiveFeature(
        title: '걱정 염주',
        subtitle: '고민을 털어놓고 마음의 평화를 찾으세요',
        icon: Icons.radio_button_checked_outlined,
        route: '/interactive/worry-bead',
        isAvailable: true,
      ),
      const _InteractiveFeature(
        title: '꿈 일기',
        subtitle: '꿈을 기록하고 영험한 해몽을 받아보세요',
        icon: Icons.nights_stay_outlined,
        route: '/interactive/dream-journal',
        isAvailable: true,
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: '인터랙티브',
              showBackButton: true,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: interactiveFeatures.length,
                  itemBuilder: (context, index) {
                    final feature = interactiveFeatures[index];
                    return _InteractiveFeatureCard(
                      feature: feature,
                      onTap: feature.isAvailable
                          ? () {
                              ref
                                  .read(fortuneHapticServiceProvider)
                                  .selection();
                              context.go(feature.route);
                            }
                          : null,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractiveFeature {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final bool isAvailable;

  const _InteractiveFeature({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.isAvailable,
  });
}

class _InteractiveFeatureCard extends StatelessWidget {
  final _InteractiveFeature feature;
  final VoidCallback? onTap;

  const _InteractiveFeatureCard({
    required this.feature,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassButton(
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              feature.icon,
              size: 36,
              color: feature.isAvailable
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              feature.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: feature.isAvailable
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              feature.subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: feature.isAvailable
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!feature.isAvailable) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '준비중',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
