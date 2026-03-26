import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system/design_system.dart';
import '../../core/widgets/paper_runtime_chrome.dart';
import '../../features/character/presentation/utils/fortune_chat_navigation.dart';

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: '뒤로 가기',
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          '프리미엄',
          style: context.heading3.copyWith(
            color: colors.textPrimary,
          ),
        ),
      ),
      body: PaperRuntimeBackground(
        ringAlignment: Alignment.topCenter,
        padding: const EdgeInsets.fromLTRB(
          DSSpacing.pageHorizontal,
          DSSpacing.md,
          DSSpacing.pageHorizontal,
          DSSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PaperRuntimePill(
              label: 'Premium insight',
              icon: Icons.diamond_outlined,
              emphasize: true,
            ),
            const SizedBox(height: DSSpacing.md),
            Text(
              '더 깊고 선명한\n프리미엄 리딩',
              style: typography.headingLarge.copyWith(
                color: colors.textPrimary,
                height: 1.04,
                letterSpacing: -0.7,
              ),
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              '만화형 스토리텔링과 확장 해석으로, 한 번 더 깊게 읽는 사주 인사이트를 준비했습니다.',
              style: typography.bodyMedium.copyWith(
                color: colors.textSecondary,
                height: 1.55,
              ),
            ),
            const SizedBox(height: DSSpacing.xl),
            _PremiumSajuCard(
              onStart: () => openFortuneChat(
                context,
                'premium-saju',
                entrySource: 'premium_screen',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumSajuCard extends StatelessWidget {
  final VoidCallback onStart;

  const _PremiumSajuCard({required this.onStart});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PaperRuntimePanel(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PaperRuntimePill(
            label: 'Premium saju',
            icon: Icons.auto_stories_outlined,
          ),
          const SizedBox(height: DSSpacing.lg),
          Text(
            '프리미엄 사주',
            style: context.headingLarge.copyWith(
              color: colors.textPrimary,
              height: 1.06,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            '만화로 보는 재미있는 사주 풀이',
            style: context.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: DSSpacing.xl),
          const _FeatureRow(
            icon: Icons.edit_outlined,
            title: '아름다운 일러스트',
            description: '전문 작가의 손길로 그려진 당신만의 이야기',
          ),
          const SizedBox(height: DSSpacing.md),
          const _FeatureRow(
            icon: Icons.menu_book_outlined,
            title: '스토리텔링',
            description: '지루하지 않은 재미있는 사주 해석',
          ),
          const SizedBox(height: DSSpacing.md),
          const _FeatureRow(
            icon: Icons.auto_awesome_outlined,
            title: '심층 분석',
            description: '더 깊이 있는 인사이트 분석 제공',
          ),
          const SizedBox(height: DSSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: DSButton.primary(
              text: '프리미엄 사주 시작하기',
              onPressed: onStart,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colors.backgroundSecondary.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border.withValues(alpha: 0.72)),
          ),
          child: Icon(icon, size: 22, color: colors.textPrimary),
        ),
        const SizedBox(width: DSSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.bodyLarge.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: context.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
