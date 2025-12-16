import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/design_system.dart';
import '../../../../../core/components/app_card.dart';
import '../../pages/biorhythm_result_page.dart';

class TodayRecommendationCard extends StatelessWidget {
  final BiorhythmData biorhythmData;
  
  const TodayRecommendationCard({
    super.key,
    required this.biorhythmData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 점수에 따른 추천 활동
    List<String> recommendations = _getRecommendations();

    return AppCard(
      style: AppCardStyle.filled,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_rounded,
                color: DSColors.accent,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                '오늘의 추천',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : DSColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...recommendations.asMap().entries.map((entry) {
            final index = entry.key;
            final recommendation = entry.value;

            return Padding(
              padding: EdgeInsets.only(bottom: index < recommendations.length - 1 ? 8 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 8, right: 12),
                    decoration: BoxDecoration(
                      color: DSColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  List<String> _getRecommendations() {
    final physicalScore = biorhythmData.physicalScore;
    final emotionalScore = biorhythmData.emotionalScore;
    final intellectualScore = biorhythmData.intellectualScore;
    
    final recommendations = <String>[];
    
    if (physicalScore >= 70) {
      recommendations.add('운동이나 활발한 활동에 좋은 날이에요');
    } else if (physicalScore <= 30) {
      recommendations.add('충분한 휴식과 수면을 취하세요');
    }
    
    if (emotionalScore >= 70) {
      recommendations.add('사람들과의 만남이나 소통을 즐겨보세요');
    } else if (emotionalScore <= 30) {
      recommendations.add('감정적으로 민감할 수 있으니 여유를 가지세요');
    }
    
    if (intellectualScore >= 70) {
      recommendations.add('중요한 결정이나 학습에 집중하기 좋은 시간');
    } else if (intellectualScore <= 30) {
      recommendations.add('복잡한 업무는 피하고 단순한 일에 집중하세요');
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('균형 잡힌 하루를 보내세요');
      recommendations.add('자신의 컨디션을 잘 살펴보며 행동하세요');
    }
    
    return recommendations;
  }
}

// 주간 전망 헤더

class WeeklyActivityGuide extends StatelessWidget {
  final BiorhythmData biorhythmData;
  
  const WeeklyActivityGuide({
    super.key,
    required this.biorhythmData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activities = _getWeeklyActivities();

    return AppCard(
      style: AppCardStyle.outlined,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이번 주 활동 가이드',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : DSColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          ...activities.asMap().entries.map((entry) {
            final activity = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: (activity['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      activity['icon'] as IconData,
                      color: activity['color'] as Color,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['title'] as String,
                          style: DSTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : DSColors.textPrimary,
                          ),
                        ),
                        Text(
                          activity['description'] as String,
                          style: DSTypography.bodySmall.copyWith(
                            color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getWeeklyActivities() {
    return [
      {
        'title': '운동 및 활동',
        'description': '신체 리듬이 높은 날에 운동하세요',
        'icon': Icons.directions_run_rounded,
        'color': const Color(0xFFFF5A5F),
      },
      {
        'title': '인간관계 및 소통',
        'description': '감정 리듬이 좋은 날에 중요한 대화를 나누세요',
        'icon': Icons.people_rounded,
        'color': const Color(0xFF00C896),
      },
      {
        'title': '학습 및 업무',
        'description': '지적 리듬이 높은 날에 집중이 필요한 일을 하세요',
        'icon': Icons.work_rounded,
        'color': const Color(0xFF0068FF),
      },
    ];
  }
}

// 개인 맞춤 분석 카드
