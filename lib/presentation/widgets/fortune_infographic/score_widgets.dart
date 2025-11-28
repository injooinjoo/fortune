import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/toss_design_system.dart';
import '../../../core/theme/typography_unified.dart';
import 'helpers.dart';

/// Score display widgets for fortune infographic
class ScoreWidgets {
  ScoreWidgets._();

  /// 토스 스타일 메인 점수 표시 (깔끔한 흰 배경)
  static Widget buildTossStyleMainScore({
    required int score,
    required String message,
    String? subtitle,
    double size = 280,
  }) {
    return Builder(
      builder: (context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? TossDesignSystem.grayDark200
              : TossDesignSystem.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? TossDesignSystem.grayDark300
                : const Color(0xFFF2F4F6),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // 토스 스타일 점수 표시 (큰 숫자만)
            Text(
              '$score',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? TossDesignSystem.white
                    : TossDesignSystem.gray900,
                fontSize: size * 0.3,
                fontWeight: FontWeight.w300,
                letterSpacing: -4,
                height: 1.0,
              ),
            ).animate()
              .scale(begin: const Offset(0.8, 0.8), duration: 800.ms, curve: Curves.elasticOut)
              .fadeIn(duration: 600.ms),

            const SizedBox(height: 24),

            // 메시지 (사자성어)
            Text(
              message,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? TossDesignSystem.grayDark100
                    : TossDesignSystem.gray700,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ).animate()
              .fadeIn(duration: 800.ms, delay: 400.ms)
              .slideY(begin: 0.3, curve: Curves.easeOut),

            // 사자성어 설명 (있을 경우)
            if (subtitle != null) ...[
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? TossDesignSystem.grayDark600
                      : TossDesignSystem.gray600,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ).animate()
                .fadeIn(duration: 800.ms, delay: 600.ms)
                .slideY(begin: 0.3, curve: Curves.easeOut),
            ],
          ],
        ),
      ),
    );
  }

  /// Hero-style score chart (원형 점수 차트)
  static Widget buildHeroScoreChart({
    required int score,
    required String title,
    double size = 200,
    Color? color,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final chartColor = color ?? TossDesignSystem.tossBlue;

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: score / 100.0,
                  strokeWidth: 8,
                  backgroundColor: isDark
                      ? TossDesignSystem.grayDark300
                      : TossDesignSystem.gray200,
                  valueColor: AlwaysStoppedAnimation<Color>(chartColor),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$score',
                    style: TextStyle(
                      fontSize: size * 0.2,
                      fontWeight: FontWeight.bold,
                      color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: size * 0.08,
                      color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate()
          .scale(begin: const Offset(0.8, 0.8), duration: 800.ms, curve: Curves.elasticOut)
          .fadeIn(duration: 600.ms);
      },
    );
  }

  /// Mini statistics dashboard (토스 스타일)
  static Widget buildMiniStatsDashboard({
    required Map<String, dynamic> stats,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? TossDesignSystem.grayDark200
            : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? TossDesignSystem.grayDark300
              : TossDesignSystem.gray200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  title: '총 점수',
                  value: '${stats['totalScore'] ?? 0}',
                  context: context,
                ),
              ),
              Container(width: 1, height: 40, color: TossDesignSystem.gray200),
              Expanded(
                child: _buildStatItem(
                  title: '등급',
                  value: FortuneInfographicHelpers.getScoreGrade(stats['totalScore'] ?? 0),
                  context: context,
                ),
              ),
              Container(width: 1, height: 40, color: TossDesignSystem.gray200),
              Expanded(
                child: _buildStatItem(
                  title: '랭킹',
                  value: '${stats['ranking'] ?? '-'}위',
                  context: context,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 800.ms, delay: 700.ms)
      .slideY(begin: 0.1, curve: Curves.easeOut);
  }

  static Widget _buildStatItem({
    required String title,
    required String value,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          value,
          style: TypographyUnified.displaySmall.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TypographyUnified.labelMedium.copyWith(
            color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
          ),
        ),
      ],
    );
  }
}
