import 'package:flutter/material.dart';
import '../../../../../core/components/toss_card.dart';
import '../../../../../core/theme/toss_theme.dart';
import '../../pages/biorhythm_result_page.dart';
import '../../../../../core/theme/toss_design_system.dart';
import '../../../../../core/theme/typography_unified.dart';

class TodayOverallStatusCard extends StatelessWidget {
  final BiorhythmData biorhythmData;
  
  const TodayOverallStatusCard({
    super.key,
    required this.biorhythmData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TossCard(
      style: TossCardStyle.elevated,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 메인 점수
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  biorhythmData.statusColor,
                  biorhythmData.statusColor.withValues(alpha: 0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: biorhythmData.statusColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${biorhythmData.overallScore}',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: TossDesignSystem.white,
                    fontWeight: FontWeight.w900,
                    
                  ),
                ),
                Text(
                  '점',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: TossDesignSystem.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          Text(
            biorhythmData.statusMessage,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
            ),
          ),
          SizedBox(height: 8),

          Text(
            '오늘 ${DateTime.now().month}월 ${DateTime.now().day}일 컨디션',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? TossDesignSystem.grayDark400 : TossTheme.textGray600,
            ),
          ),
        ],
      ),
    );
  }
}

// 3가지 리듬 상세 카드들
class RhythmDetailCards extends StatelessWidget {
  final BiorhythmData biorhythmData;
  
  const RhythmDetailCards({
    super.key,
    required this.biorhythmData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRhythmCard(
          '신체 리듬',
          biorhythmData.physicalScore,
          biorhythmData.physicalStatus,
          Icons.fitness_center_rounded,
          const Color(0xFFFF5A5F),
        ),
        const SizedBox(height: 12),
        _buildRhythmCard(
          '감정 리듬',
          biorhythmData.emotionalScore,
          biorhythmData.emotionalStatus,
          Icons.favorite_rounded,
          const Color(0xFF00C896),
        ),
        const SizedBox(height: 12),
        _buildRhythmCard(
          '지적 리듬',
          biorhythmData.intellectualScore,
          biorhythmData.intellectualStatus,
          Icons.psychology_rounded,
          const Color(0xFF0068FF),
        ),
      ],
    );
  }

  Widget _buildRhythmCard(
    String title,
    int score,
    String status,
    IconData icon,
    Color color,
  ) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return TossCard(
          style: TossCardStyle.outlined,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
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
                      style: TypographyUnified.buttonMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      status,
                      style: TypographyUnified.bodySmall.copyWith(
                        color: isDark ? TossDesignSystem.grayDark400 : TossTheme.textGray600,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                children: [
                  Text(
                    '$score',
                    style: TypographyUnified.displaySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Text(
                    '점',
                    style: TypographyUnified.labelMedium.copyWith(
                      color: isDark ? TossDesignSystem.grayDark400 : TossTheme.textGray600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }
}

// 오늘의 추천 카드
