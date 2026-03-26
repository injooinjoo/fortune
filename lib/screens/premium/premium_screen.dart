import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system/design_system.dart';
import '../../core/widgets/paper_runtime_chrome.dart';
import '../../core/widgets/paper_runtime_surface_kit.dart';
import '../../features/character/presentation/utils/fortune_chat_navigation.dart';

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const PaperRuntimeAppBar(title: '프리미엄 인사이트'),
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
            SizedBox(
              width: double.infinity,
              child: _PremiumSajuCard(
                onStart: () => openFortuneChat(
                  context,
                  'premium-saju',
                  entrySource: 'premium_screen',
                ),
              ),
            ),
            const SizedBox(height: DSSpacing.lg),
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
              icon: Icons.star_border_rounded,
              title: '심층 분석',
              description: '더 깊이 있는 인사이트 분석 제공',
            ),
            const Spacer(),
            PaperRuntimeButton(
              label: '프리미엄 사주 시작하기',
              onPressed: () => openFortuneChat(
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
      padding: const EdgeInsets.fromLTRB(
        DSSpacing.lg,
        DSSpacing.xl,
        DSSpacing.lg,
        DSSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Icon(
              Icons.bookmark_outline_rounded,
              size: 42,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: DSSpacing.lg),
          Center(
            child: Text(
              '프리미엄 사주',
              textAlign: TextAlign.center,
              style: context.heading3.copyWith(
                color: colors.textPrimary,
                height: 1.06,
              ),
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Center(
            child: Text(
              '만화로 보는 재미있는 사주 풀이',
              textAlign: TextAlign.center,
              style: context.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
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
                style: context.bodyMedium.copyWith(
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
