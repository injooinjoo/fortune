import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';
import '../../shared/glassmorphism/glass_container.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          '프리미엄',
          style: DSTypography.headingSmall.copyWith(
            color: colors.textPrimary,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 프리미엄 사주 카드만 표시
                _buildPremiumSajuCard(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSajuCard(BuildContext context) {
    final colors = context.colors;
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.auto_stories_rounded,
            size: 64,
            color: colors.accent,
          ),
          const SizedBox(height: 16),
          Text(
            '프리미엄 사주',
            style: DSTypography.headingMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '만화로 보는 재미있는 사주 풀이',
            style: DSTypography.bodyLarge.copyWith(
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Feature list
          _buildFeatureItem(
            context,
            icon: Icons.brush,
            title: '아름다운 일러스트',
            description: '전문 작가의 손길로 그려진 당신만의 이야기',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            context,
            icon: Icons.book,
            title: '스토리텔링',
            description: '지루하지 않은 재미있는 사주 해석',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            context,
            icon: Icons.insights,
            title: '심층 분석',
            description: '더 깊이 있는 운세 분석 제공',
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Navigate to premium saju content
                // 프리미엄 사주 콘텐츠 페이지로 연결 예정
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: colors.ctaBackground,
                foregroundColor: colors.ctaForeground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DSRadius.md),
                ),
                elevation: 0,
              ),
              child: Text(
                '프리미엄 사주 시작하기',
                style: DSTypography.buttonMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.ctaForeground,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final colors = context.colors;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(DSSpacing.sm),
          decoration: BoxDecoration(
            color: colors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DSRadius.md),
          ),
          child: Icon(
            icon,
            color: colors.accent,
            size: 24,
          ),
        ),
        const SizedBox(width: DSSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: DSTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: DSTypography.labelSmall.copyWith(
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
