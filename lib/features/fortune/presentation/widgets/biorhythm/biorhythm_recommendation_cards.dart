import 'package:flutter/material.dart';
import '../../../../../core/design_system/tokens/ds_biorhythm_colors.dart';
import '../../../../../core/theme/typography_unified.dart';
import '../../../../../core/theme/font_config.dart';
import '../../pages/biorhythm_result_page.dart';
import 'components/biorhythm_hanji_card.dart';
import 'components/biorhythm_score_badge.dart';

/// Today's recommendation card with traditional Korean style
///
/// Design Philosophy:
/// - Hanji card with subtle decorations
/// - Traditional advice format
/// - Obangsaek color accents based on rhythm type
class TodayRecommendationCard extends StatelessWidget {
  final BiorhythmData biorhythmData;

  const TodayRecommendationCard({
    super.key,
    required this.biorhythmData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = DSBiorhythmColors.getInkBleed(isDark);

    // 점수에 따른 추천 활동
    List<Map<String, dynamic>> recommendations = _getRecommendations(isDark);

    return BiorhythmHanjiCard(
      style: HanjiCardStyle.standard,
      showCornerDecorations: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with traditional styling
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: DSBiorhythmColors.goldAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '오늘의 지침 (指針)',
                style: context.bodyMedium.copyWith(
                  fontFamily: FontConfig.primary,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const Spacer(),
              // Seal-style indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DSBiorhythmColors.goldAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: DSBiorhythmColors.goldAccent.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '吉',
                  style: context.labelMedium.copyWith(
                    fontFamily: FontConfig.primary,
                    fontWeight: FontWeight.w700,
                    color: DSBiorhythmColors.goldAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Recommendations list
          ...recommendations.asMap().entries.map((entry) {
            final index = entry.key;
            final recommendation = entry.value;
            final rhythmType = recommendation['type'] as BiorhythmType?;
            final color = rhythmType != null
                ? _getTypeColor(rhythmType, isDark)
                : DSBiorhythmColors.goldAccent;

            return Padding(
              padding: EdgeInsets.only(
                  bottom: index < recommendations.length - 1 ? 16 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Traditional bullet with element symbol
                  Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        recommendation['hanja'] as String,
                        style: context.labelMedium.copyWith(
                          fontFamily: FontConfig.primary,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recommendation['title'] as String,
                          style: context.bodySmall.copyWith(
                            fontFamily: FontConfig.primary,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          recommendation['text'] as String,
                          style: context.labelMedium.copyWith(
                            color: textColor.withValues(alpha: 0.7),
                            height: 1.5,
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

  List<Map<String, dynamic>> _getRecommendations(bool isDark) {
    final physicalScore = biorhythmData.physicalScore;
    final emotionalScore = biorhythmData.emotionalScore;
    final intellectualScore = biorhythmData.intellectualScore;

    final recommendations = <Map<String, dynamic>>[];

    if (physicalScore >= 70) {
      recommendations.add({
        'title': '신체 활동 권장',
        'text': '화기(火氣)가 왕성하니 운동이나 활발한 활동에 좋은 날입니다',
        'hanja': '火',
        'type': BiorhythmType.physical,
      });
    } else if (physicalScore <= 30) {
      recommendations.add({
        'title': '휴식 권장',
        'text': '화기(火氣)가 약하니 충분한 휴식과 수면을 취하세요',
        'hanja': '休',
        'type': BiorhythmType.physical,
      });
    }

    if (emotionalScore >= 70) {
      recommendations.add({
        'title': '교류 권장',
        'text': '목기(木氣)가 왕성하니 사람들과의 만남이나 소통을 즐기시기 바랍니다',
        'hanja': '木',
        'type': BiorhythmType.emotional,
      });
    } else if (emotionalScore <= 30) {
      recommendations.add({
        'title': '정서 관리',
        'text': '목기(木氣)가 약하니 감정적으로 민감할 수 있으니 여유를 가지세요',
        'hanja': '靜',
        'type': BiorhythmType.emotional,
      });
    }

    if (intellectualScore >= 70) {
      recommendations.add({
        'title': '집중 권장',
        'text': '수기(水氣)가 왕성하니 중요한 결정이나 학습에 집중하기 좋은 시간입니다',
        'hanja': '水',
        'type': BiorhythmType.intellectual,
      });
    } else if (intellectualScore <= 30) {
      recommendations.add({
        'title': '단순 업무 권장',
        'text': '수기(水氣)가 약하니 복잡한 업무는 피하고 단순한 일에 집중하세요',
        'hanja': '簡',
        'type': BiorhythmType.intellectual,
      });
    }

    if (recommendations.isEmpty) {
      recommendations.add({
        'title': '균형의 날',
        'text': '삼기(三氣)가 조화롭게 흐르니 균형 잡힌 하루를 보내시기 바랍니다',
        'hanja': '和',
        'type': null,
      });
      recommendations.add({
        'title': '자기 관찰',
        'text': '자신의 컨디션을 잘 살펴보며 행동하세요',
        'hanja': '觀',
        'type': null,
      });
    }

    return recommendations;
  }

  Color _getTypeColor(BiorhythmType type, bool isDark) {
    switch (type) {
      case BiorhythmType.physical:
        return DSBiorhythmColors.getPhysical(isDark);
      case BiorhythmType.emotional:
        return DSBiorhythmColors.getEmotional(isDark);
      case BiorhythmType.intellectual:
        return DSBiorhythmColors.getIntellectual(isDark);
    }
  }
}

/// Weekly activity guide with traditional Korean style
///
/// Design Philosophy:
/// - Hanji scroll card style
/// - Traditional activity icons with Five Elements
/// - Obangsaek color coding
class WeeklyActivityGuide extends StatelessWidget {
  final BiorhythmData biorhythmData;

  const WeeklyActivityGuide({
    super.key,
    required this.biorhythmData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = DSBiorhythmColors.getInkBleed(isDark);

    final activities = _getWeeklyActivities(isDark);

    return BiorhythmHanjiCard(
      style: HanjiCardStyle.scroll,
      showSealStamp: true,
      sealText: '活',
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            '주간 활동 지침',
            style: context.heading4.copyWith(
              fontFamily: FontConfig.primary,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '삼기(三氣)에 맞춘 활동 안내',
            style: context.labelMedium.copyWith(
              color: textColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),

          // Activities list
          ...activities.asMap().entries.map((entry) {
            final index = entry.key;
            final activity = entry.value;
            final color = activity['color'] as Color;

            return Padding(
              padding: EdgeInsets.only(
                  bottom: index < activities.length - 1 ? 16 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Traditional style icon container
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: color.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          activity['hanja'] as String,
                          style: context.heading4.copyWith(
                            fontFamily: FontConfig.primary,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['title'] as String,
                          style: context.bodyMedium.copyWith(
                            fontFamily: FontConfig.primary,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activity['description'] as String,
                          style: context.labelMedium.copyWith(
                            color: textColor.withValues(alpha: 0.6),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Best days indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            activity['bestDays'] as String,
                            style: context.labelTiny.copyWith(
                              fontFamily: FontConfig.primary,
                              color: color,
                            ),
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

  List<Map<String, dynamic>> _getWeeklyActivities(bool isDark) {
    // Find best days for each rhythm
    final physicalBestDay = _findBestDay(biorhythmData.physicalWeek);
    final emotionalBestDay = _findBestDay(biorhythmData.emotionalWeek);
    final intellectualBestDay = _findBestDay(biorhythmData.intellectualWeek);

    return [
      {
        'title': '신체 활동 (火)',
        'description': '화기(火氣)가 왕성한 날에 운동이나 육체 활동을 권합니다',
        'hanja': '火',
        'color': DSBiorhythmColors.getPhysical(isDark),
        'bestDays': '최적: ${_formatDayName(physicalBestDay)}',
      },
      {
        'title': '교류 및 소통 (木)',
        'description': '목기(木氣)가 좋은 날에 중요한 대화나 만남을 가지세요',
        'hanja': '木',
        'color': DSBiorhythmColors.getEmotional(isDark),
        'bestDays': '최적: ${_formatDayName(emotionalBestDay)}',
      },
      {
        'title': '학습 및 업무 (水)',
        'description': '수기(水氣)가 높은 날에 집중이 필요한 일을 처리하세요',
        'hanja': '水',
        'color': DSBiorhythmColors.getIntellectual(isDark),
        'bestDays': '최적: ${_formatDayName(intellectualBestDay)}',
      },
    ];
  }

  int _findBestDay(List<double> weekData) {
    int bestDay = 0;
    double bestScore = weekData[0];
    for (int i = 1; i < weekData.length; i++) {
      if (weekData[i] > bestScore) {
        bestScore = weekData[i];
        bestDay = i;
      }
    }
    return bestDay;
  }

  String _formatDayName(int dayIndex) {
    final dayNames = ['오늘', '내일', '모레', '3일후', '4일후', '5일후', '6일후'];
    return dayNames[dayIndex];
  }
}

/// Balance indicator card showing harmony of Three Energies
class ThreeEnergiesBalanceCard extends StatelessWidget {
  final BiorhythmData biorhythmData;

  const ThreeEnergiesBalanceCard({
    super.key,
    required this.biorhythmData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = DSBiorhythmColors.getInkBleed(isDark);

    final balance = _calculateBalance();
    final balanceStatus = _getBalanceStatus(balance);

    return BiorhythmHanjiCard(
      style: HanjiCardStyle.minimal,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '삼기(三氣)의 조화',
                style: context.bodyMedium.copyWith(
                  fontFamily: FontConfig.primary,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Balance visualization
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildEnergyDot(context, BiorhythmType.physical, isDark),
              _buildConnectionLine(isDark),
              _buildEnergyDot(context, BiorhythmType.emotional, isDark),
              _buildConnectionLine(isDark),
              _buildEnergyDot(context, BiorhythmType.intellectual, isDark),
            ],
          ),
          const SizedBox(height: 16),

          // Balance status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: balanceStatus['color'].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: balanceStatus['color'].withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  balanceStatus['hanja'] as String,
                  style: context.bodySmall.copyWith(
                    fontFamily: FontConfig.primary,
                    fontWeight: FontWeight.w700,
                    color: balanceStatus['color'],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  balanceStatus['text'] as String,
                  style: context.labelMedium.copyWith(
                    fontFamily: FontConfig.primary,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyDot(BuildContext context, BiorhythmType type, bool isDark) {
    final color = _getTypeColor(type, isDark);
    final score = _getTypeScore(type);
    final hanja = _getTypeHanja(type);

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              hanja,
              style: context.bodyMedium.copyWith(
                fontFamily: FontConfig.primary,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$score',
          style: context.labelMedium.copyWith(
            fontFamily: FontConfig.primary,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionLine(bool isDark) {
    return Container(
      width: 30,
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DSBiorhythmColors.getInkBleed(isDark).withValues(alpha: 0.1),
            DSBiorhythmColors.getInkBleed(isDark).withValues(alpha: 0.3),
            DSBiorhythmColors.getInkBleed(isDark).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  double _calculateBalance() {
    final scores = [
      biorhythmData.physicalScore,
      biorhythmData.emotionalScore,
      biorhythmData.intellectualScore,
    ];
    final avg = scores.reduce((a, b) => a + b) / 3;
    final variance = scores
            .map((s) => (s - avg) * (s - avg))
            .reduce((a, b) => a + b) /
        3;
    return 100 - variance.clamp(0, 100);
  }

  Map<String, dynamic> _getBalanceStatus(double balance) {
    if (balance >= 80) {
      return {
        'hanja': '和',
        'text': '삼기가 조화롭습니다',
        'color': DSBiorhythmColors.statusExcellent,
      };
    } else if (balance >= 60) {
      return {
        'hanja': '中',
        'text': '삼기가 보통입니다',
        'color': DSBiorhythmColors.statusGood,
      };
    } else if (balance >= 40) {
      return {
        'hanja': '不',
        'text': '삼기의 균형이 필요합니다',
        'color': DSBiorhythmColors.statusAverage,
      };
    } else {
      return {
        'hanja': '亂',
        'text': '삼기의 조화가 흐트러졌습니다',
        'color': DSBiorhythmColors.statusCritical,
      };
    }
  }

  Color _getTypeColor(BiorhythmType type, bool isDark) {
    switch (type) {
      case BiorhythmType.physical:
        return DSBiorhythmColors.getPhysical(isDark);
      case BiorhythmType.emotional:
        return DSBiorhythmColors.getEmotional(isDark);
      case BiorhythmType.intellectual:
        return DSBiorhythmColors.getIntellectual(isDark);
    }
  }

  int _getTypeScore(BiorhythmType type) {
    switch (type) {
      case BiorhythmType.physical:
        return biorhythmData.physicalScore;
      case BiorhythmType.emotional:
        return biorhythmData.emotionalScore;
      case BiorhythmType.intellectual:
        return biorhythmData.intellectualScore;
    }
  }

  String _getTypeHanja(BiorhythmType type) {
    switch (type) {
      case BiorhythmType.physical:
        return '火';
      case BiorhythmType.emotional:
        return '木';
      case BiorhythmType.intellectual:
        return '水';
    }
  }
}
