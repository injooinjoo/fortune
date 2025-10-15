import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../../../core/components/toss_card.dart';
import '../../../../core/theme/toss_theme.dart';
import '../pages/biorhythm_result_page.dart';
import '../../../../core/theme/toss_design_system.dart';

// 오늘의 전체 컨디션 카드
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
                    fontSize: 36,
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
          const SizedBox(height: 20),

          Text(
            biorhythmData.statusMessage,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
            ),
          ),
          const SizedBox(height: 8),

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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 14,
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
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Text(
                    '점',
                    style: TextStyle(
                      fontSize: 12,
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

    return TossCard(
      style: TossCardStyle.filled,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_rounded,
                color: TossTheme.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '오늘의 추천',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
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
                      color: TossTheme.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark ? TossDesignSystem.grayDark400 : TossTheme.textGray600,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
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
class WeeklyForecastHeader extends StatelessWidget {
  final BiorhythmData biorhythmData;
  
  const WeeklyForecastHeader({
    super.key,
    required this.biorhythmData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TossCard(
      style: TossCardStyle.elevated,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            '이번 주 바이오리듬 전망',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${DateTime.now().month}월 ${DateTime.now().day}일 ~ ${DateTime.now().add(const Duration(days: 6)).month}월 ${DateTime.now().add(const Duration(days: 6)).day}일',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? TossDesignSystem.grayDark400 : TossTheme.textGray600,
            ),
          ),
        ],
      ),
    );
  }
}

// 주간 리듬 차트
class WeeklyRhythmChart extends StatelessWidget {
  final BiorhythmData biorhythmData;
  
  const WeeklyRhythmChart({
    super.key,
    required this.biorhythmData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TossCard(
      style: TossCardStyle.outlined,
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 50,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: isDark ? TossDesignSystem.grayDark500 : TossTheme.borderGray300,
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}',
                      style: TextStyle(
                        color: isDark ? TossDesignSystem.grayDark400 : TossTheme.textGray600,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final days = ['오늘', '내일', '모레', '3일후', '4일후', '5일후', '6일후'];
                    if (value.toInt() < days.length) {
                      return Text(
                        days[value.toInt()],
                        style: TextStyle(
                          color: isDark ? TossDesignSystem.grayDark400 : TossTheme.textGray600,
                          fontSize: 11,
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: 6,
            minY: 0,
            maxY: 100,
            lineBarsData: [
              // 신체 리듬
              LineChartBarData(
                spots: biorhythmData.physicalWeek.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), (entry.value + 100) / 2);
                }).toList(),
                isCurved: true,
                color: const Color(0xFFFF5A5F),
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: const Color(0xFFFF5A5F),
                      strokeWidth: 2,
                      strokeColor: TossDesignSystem.white,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: const Color(0xFFFF5A5F).withValues(alpha: 0.1),
                ),
              ),
              // 감정 리듬
              LineChartBarData(
                spots: biorhythmData.emotionalWeek.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), (entry.value + 100) / 2);
                }).toList(),
                isCurved: true,
                color: const Color(0xFF00C896),
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: const Color(0xFF00C896),
                      strokeWidth: 2,
                      strokeColor: TossDesignSystem.white,
                    );
                  },
                ),
              ),
              // 지적 리듬
              LineChartBarData(
                spots: biorhythmData.intellectualWeek.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), (entry.value + 100) / 2);
                }).toList(),
                isCurved: true,
                color: const Color(0xFF0068FF),
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: const Color(0xFF0068FF),
                      strokeWidth: 2,
                      strokeColor: TossDesignSystem.white,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 주요 날짜들
class ImportantDatesCard extends StatelessWidget {
  final BiorhythmData biorhythmData;
  
  const ImportantDatesCard({
    super.key,
    required this.biorhythmData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 최고/최저 날짜 찾기
    final bestDay = _findBestDay();
    final worstDay = _findWorstDay();

    return TossCard(
      style: TossCardStyle.filled,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이번 주 주요 날짜',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
            ),
          ),
          const SizedBox(height: 16),

          // 최고의 날
          _buildDateItem(
            context,
            '최고의 날',
            bestDay['date'] as String,
            bestDay['description'] as String,
            Icons.trending_up_rounded,
            const Color(0xFF00C851),
          ),
          const SizedBox(height: 12),

          // 주의가 필요한 날
          _buildDateItem(
            context,
            '주의가 필요한 날',
            worstDay['date'] as String,
            worstDay['description'] as String,
            Icons.warning_rounded,
            const Color(0xFFFF9500),
          ),
        ],
      ),
    );
  }

  Widget _buildDateItem(
    BuildContext context,
    String title,
    String date,
    String description,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$title - $date',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? TossDesignSystem.grayDark400 : TossTheme.textGray600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, String> _findBestDay() {
    double bestScore = -1;
    int bestDayIndex = 0;
    
    for (int i = 0; i < 7; i++) {
      final avgScore = (biorhythmData.physicalWeek[i] + 
                       biorhythmData.emotionalWeek[i] + 
                       biorhythmData.intellectualWeek[i]) / 3;
      if (avgScore > bestScore) {
        bestScore = avgScore;
        bestDayIndex = i;
      }
    }
    
    final date = DateTime.now().add(Duration(days: bestDayIndex));
    final dayNames = ['오늘', '내일', '모레'];
    final dateStr = bestDayIndex < 3 
        ? dayNames[bestDayIndex]
        : '${date.month}/${date.day}';
    
    return {
      'date': dateStr,
      'description': '모든 리듬이 높아 활동하기 좋은 날이에요',
    };
  }

  Map<String, String> _findWorstDay() {
    double worstScore = 101;
    int worstDayIndex = 0;
    
    for (int i = 0; i < 7; i++) {
      final avgScore = (biorhythmData.physicalWeek[i] + 
                       biorhythmData.emotionalWeek[i] + 
                       biorhythmData.intellectualWeek[i]) / 3;
      if (avgScore < worstScore) {
        worstScore = avgScore;
        worstDayIndex = i;
      }
    }
    
    final date = DateTime.now().add(Duration(days: worstDayIndex));
    final dayNames = ['오늘', '내일', '모레'];
    final dateStr = worstDayIndex < 3 
        ? dayNames[worstDayIndex]
        : '${date.month}/${date.day}';
    
    return {
      'date': dateStr,
      'description': '컨디션 관리에 신경 써야 하는 날이에요',
    };
  }
}

// 주간 활동 가이드
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

    return TossCard(
      style: TossCardStyle.outlined,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이번 주 활동 가이드',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
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
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                          ),
                        ),
                        Text(
                          activity['description'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? TossDesignSystem.grayDark400 : TossTheme.textGray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
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

    return TossCard(
      style: TossCardStyle.elevated,
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
          const SizedBox(height: 16),

          Text(
            '${age}세의 당신은 지금까지 ${biorhythmData.totalDays}일을 살아오셨네요.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? TossDesignSystem.grayDark400 : TossTheme.textGray600,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),

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

    return TossCard(
      style: TossCardStyle.filled,
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
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          advice['description'] as String,
                          style: TextStyle(
                            fontSize: 14,
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
          }).toList(),
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

    return TossCard(
      style: TossCardStyle.outlined,
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
              const SizedBox(width: 8),
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
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                tip,
                style: TextStyle(
                  fontSize: 13,
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

    return TossCard(
      style: TossCardStyle.filled,
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
                const SizedBox(height: 4),
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