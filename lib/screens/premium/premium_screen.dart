import 'package:flutter/material.dart';
import '../../core/theme/toss_design_system.dart';
import '../../shared/glassmorphism/glass_container.dart';
import '../../core/theme/typography_unified.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: isDark ? TossDesignSystem.grayDark50 : TossDesignSystem.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          '프리미엄',
          style: TypographyUnified.heading3.copyWith(
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
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
                _buildPremiumSajuCard(context, theme, isDark),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSajuCard(BuildContext context, ThemeData theme, bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.auto_stories_rounded,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            '프리미엄 사주',
            style: TypographyUnified.heading2.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '만화로 보는 재미있는 사주 풀이',
            style: TypographyUnified.body1.copyWith(
              color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
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
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            context,
            icon: Icons.book,
            title: '스토리텔링',
            description: '지루하지 않은 재미있는 사주 해석',
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            context,
            icon: Icons.insights,
            title: '심층 분석',
            description: '더 깊이 있는 운세 분석 제공',
            isDark: isDark,
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
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: TossDesignSystem.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                '프리미엄 사주 시작하기',
                style: TypographyUnified.buttonMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: TossDesignSystem.white,
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
    required bool isDark,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TypographyUnified.body1.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TypographyUnified.caption.copyWith(
                  color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
