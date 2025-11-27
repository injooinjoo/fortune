import 'package:flutter/material.dart';
import '../../../../../core/components/app_card.dart';
import '../../../../../core/theme/toss_theme.dart';
import '../../pages/biorhythm_result_page.dart';
import '../../../../../core/theme/toss_design_system.dart';
import '../../../../../core/theme/typography_unified.dart';

class PersonalAnalysisCard extends StatelessWidget {
  final BiorhythmData biorhythmData;
  
  const PersonalAnalysisCard({
    super.key,
    required this.biorhythmData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final age = DateTime.now().difference(biorhythmData.birthDate).inDays ~/ 365;

    return AppCard(
      style: AppCardStyle.elevated,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '당신의 바이오리듬 특성',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
            ),
          ),
          SizedBox(height: 16),

          Text(
            '$age세의 당신은 지금까지 ${biorhythmData.totalDays}일을 살아오셨네요.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? TossDesignSystem.grayDark400 : TossTheme.textGray600,
              height: 1.6,
            ),
          ),
          SizedBox(height: 12),

          Text(
            _getPersonalAnalysis(),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? TossDesignSystem.grayDark400 : TossTheme.textGray600,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  String _getPersonalAnalysis() {
    final physicalCycle = biorhythmData.totalDays % 23;
    final emotionalCycle = biorhythmData.totalDays % 28;
    final intellectualCycle = biorhythmData.totalDays % 33;
    
    String dominantRhythm;
    if (biorhythmData.physicalScore > biorhythmData.emotionalScore && 
        biorhythmData.physicalScore > biorhythmData.intellectualScore) {
      dominantRhythm = '신체적 활동력이 뛰어난 시기';
    } else if (biorhythmData.emotionalScore > biorhythmData.intellectualScore) {
      dominantRhythm = '감정적으로 풍부하고 사교적인 시기';
    } else {
      dominantRhythm = '지적 능력이 활발한 창조적 시기';
    }
    
    return '''현재 $dominantRhythm입니다.

신체 리듬은 23일 주기 중 ${physicalCycle + 1}일째,
감정 리듬은 28일 주기 중 ${emotionalCycle + 1}일째,
지적 리듬은 33일 주기 중 ${intellectualCycle + 1}일째에 있어요.

이러한 리듬의 조화를 통해 자신만의 최적의 타이밍을 찾아보세요.''';
  }
}

// 라이프 스타일 조언 카드
class LifestyleAdviceCard extends StatelessWidget {
  final BiorhythmData biorhythmData;
  
  const LifestyleAdviceCard({
    super.key,
    required this.biorhythmData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final advices = _getLifestyleAdvices();

    return AppCard(
      style: AppCardStyle.filled,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '맞춤형 라이프 스타일 조언',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
            ),
          ),
          const SizedBox(height: 16),

          ...advices.asMap().entries.map((entry) {
            final advice = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: TossTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      advice['icon'] as IconData,
                      color: TossTheme.primaryBlue,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          advice['title'] as String,
                          style: TypographyUnified.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                            color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          advice['description'] as String,
                          style: TypographyUnified.bodySmall.copyWith(
                            color: isDark ? TossDesignSystem.grayDark400 : TossTheme.textGray600,
                            height: 1.4,
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

  List<Map<String, dynamic>> _getLifestyleAdvices() {
    final advices = <Map<String, dynamic>>[];
    
    // 신체 리듬 기반 조언
    if (biorhythmData.physicalScore >= 70) {
      advices.add({
        'title': '활동적인 시간 활용',
        'description': '에너지가 높은 시기이니 새로운 운동을 시작해보세요',
        'icon': Icons.directions_run_rounded,
      });
    } else if (biorhythmData.physicalScore <= 30) {
      advices.add({
        'title': '충분한 휴식',
        'description': '몸이 피곤할 수 있으니 일찍 잠자리에 드세요',
        'icon': Icons.bedtime_rounded,
      });
    }
    
    // 감정 리듬 기반 조언
    if (biorhythmData.emotionalScore >= 70) {
      advices.add({
        'title': '사회적 활동 늘리기',
        'description': '감정이 안정적이니 친구들과의 시간을 늘려보세요',
        'icon': Icons.people_rounded,
      });
    } else if (biorhythmData.emotionalScore <= 30) {
      advices.add({
        'title': '감정 관리',
        'description': '스트레스 관리와 명상으로 마음의 평화를 찾으세요',
        'icon': Icons.self_improvement_rounded,
      });
    }
    
    // 지적 리듬 기반 조언
    if (biorhythmData.intellectualScore >= 70) {
      advices.add({
        'title': '학습 시간 확보',
        'description': '집중력이 좋은 시기이니 새로운 것을 배워보세요',
        'icon': Icons.school_rounded,
      });
    } else if (biorhythmData.intellectualScore <= 30) {
      advices.add({
        'title': '단순한 일 집중',
        'description': '복잡한 결정은 피하고 단순한 업무에 집중하세요',
        'icon': Icons.task_rounded,
      });
    }
    
    // 기본 조언들
    if (advices.isEmpty) {
      advices.addAll([
        {
          'title': '균형 잡힌 생활',
          'description': '규칙적인 생활 패턴을 유지해보세요',
          'icon': Icons.balance_rounded,
        },
        {
          'title': '자기 관찰',
          'description': '자신의 컨디션 변화를 주의 깊게 관찰해보세요',
          'icon': Icons.visibility_rounded,
        },
      ]);
    }
    
    return advices;
  }
}

// 건강 관리 팁 카드
class HealthTipsCard extends StatelessWidget {
  final BiorhythmData biorhythmData;
  
  const HealthTipsCard({
    super.key,
    required this.biorhythmData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      style: AppCardStyle.outlined,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.health_and_safety_rounded,
                color: const Color(0xFF00C896),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                '건강 관리 팁',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildHealthTip(
            context,
            '수면',
            _getSleepTip(),
            Icons.bedtime_rounded,
            const Color(0xFF6B73FF),
          ),
          const SizedBox(height: 12),

          _buildHealthTip(
            context,
            '영양',
            _getNutritionTip(),
            Icons.restaurant_rounded,
            const Color(0xFF00C896),
          ),
          const SizedBox(height: 12),

          _buildHealthTip(
            context,
            '운동',
            _getExerciseTip(),
            Icons.fitness_center_rounded,
            const Color(0xFFFF5A5F),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTip(BuildContext context, String title, String tip, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TypographyUnified.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                ),
              ),
              SizedBox(height: 2),
              Text(
                tip,
                style: TypographyUnified.bodySmall.copyWith(
                  color: isDark ? TossDesignSystem.grayDark400 : TossTheme.textGray600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getSleepTip() {
    if (biorhythmData.physicalScore <= 30) {
      return '체력이 낮은 상태이니 평소보다 1시간 일찍 잠자리에 드세요';
    } else if (biorhythmData.physicalScore >= 70) {
      return '에너지가 높아 잠들기 어려울 수 있으니 취침 전 이완 운동을 해보세요';
    }
    return '규칙적인 수면 패턴을 유지하며 하루 7-8시간 숙면을 취하세요';
  }

  String _getNutritionTip() {
    if (biorhythmData.physicalScore <= 30) {
      return '비타민과 미네랄이 풍부한 음식으로 에너지를 보충하세요';
    } else if (biorhythmData.emotionalScore <= 30) {
      return '오메가3와 마그네슘이 풍부한 음식으로 스트레스를 완화하세요';
    }
    return '균형 잡힌 식단으로 건강한 컨디션을 유지하세요';
  }

  String _getExerciseTip() {
    if (biorhythmData.physicalScore >= 70) {
      return '에너지가 높은 시기이니 평소보다 강도 높은 운동을 시도해보세요';
    } else if (biorhythmData.physicalScore <= 30) {
      return '가벼운 산책이나 스트레칭으로 몸을 부드럽게 움직여주세요';
    }
    return '꾸준한 중강도 운동으로 체력을 관리하세요';
  }
}

// 다음 분석 예약 카드
class NextAnalysisCard extends StatelessWidget {
  const NextAnalysisCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      style: AppCardStyle.filled,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TossTheme.primaryBlue,
                  const Color(0xFF00C896),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.schedule_rounded,
              color: TossDesignSystem.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1주일 후 다시 확인해보세요',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '바이오리듬은 매일 변화해요',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? TossDesignSystem.grayDark400 : TossTheme.textGray600,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.arrow_forward_ios_rounded,
            color: isDark ? TossDesignSystem.grayDark400 : TossTheme.textGray600,
            size: 16,
          ),
        ],
      ),
    );
  }
}