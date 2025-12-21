import 'package:flutter/material.dart';
import '../../../../../core/design_system/tokens/ds_biorhythm_colors.dart';
import '../../../../../core/theme/typography_unified.dart';
import '../../../../../core/theme/font_config.dart';
import '../../pages/biorhythm_result_page.dart';
import 'components/biorhythm_hanji_card.dart';

/// Personal analysis card with traditional Korean style
///
/// Design Philosophy:
/// - Hanji elevated card style with seal stamp
/// - Calligraphy style title with Hanja
/// - Traditional fortune-telling language
class PersonalAnalysisCard extends StatelessWidget {
  final BiorhythmData biorhythmData;

  const PersonalAnalysisCard({
    super.key,
    required this.biorhythmData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = DSBiorhythmColors.getInkBleed(isDark);
    final age = DateTime.now().difference(biorhythmData.birthDate).inDays ~/ 365;

    return BiorhythmHanjiCard(
      style: HanjiCardStyle.elevated,
      showCornerDecorations: true,
      showSealStamp: true,
      sealText: '命',
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with calligraphy style
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      DSBiorhythmColors.getPhysical(isDark),
                      DSBiorhythmColors.getEmotional(isDark),
                      DSBiorhythmColors.getIntellectual(isDark),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '당신의 기운 분석 (氣運分析)',
                style: context.heading4.copyWith(
                  fontFamily: FontConfig.primary,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Personal journey text
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DSBiorhythmColors.getInkWashGuide(isDark).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: DSBiorhythmColors.getInkBleed(isDark).withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Text(
              '$age세의 당신은 지금까지 ${biorhythmData.totalDays}일의 세월을 살아오셨습니다.',
              style: context.bodyMedium.copyWith(
                fontFamily: FontConfig.primary,
                color: textColor,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Detailed analysis
          Text(
            _getPersonalAnalysis(),
            style: context.bodySmall.copyWith(
              color: textColor.withValues(alpha: 0.8),
              height: 1.7,
            ),
          ),

          const SizedBox(height: 20),

          // Cycle progress indicators
          _buildCycleIndicators(context, isDark, textColor),
        ],
      ),
    );
  }

  Widget _buildCycleIndicators(BuildContext context, bool isDark, Color textColor) {
    final physicalCycle = biorhythmData.totalDays % 23;
    final emotionalCycle = biorhythmData.totalDays % 28;
    final intellectualCycle = biorhythmData.totalDays % 33;

    return Row(
      children: [
        Expanded(
          child: _buildCycleProgress(
            context,
            '火',
            physicalCycle + 1,
            23,
            DSBiorhythmColors.getPhysical(isDark),
            textColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCycleProgress(
            context,
            '木',
            emotionalCycle + 1,
            28,
            DSBiorhythmColors.getEmotional(isDark),
            textColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCycleProgress(
            context,
            '水',
            intellectualCycle + 1,
            33,
            DSBiorhythmColors.getIntellectual(isDark),
            textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCycleProgress(
    BuildContext context,
    String hanja,
    int current,
    int total,
    Color color,
    Color textColor,
  ) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              hanja,
              style: context.bodySmall.copyWith(
                fontFamily: FontConfig.primary,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$current / $total일',
          style: context.labelTiny.copyWith(
            fontFamily: FontConfig.primary,
            color: textColor.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  String _getPersonalAnalysis() {
    String dominantRhythm;
    String dominantAdvice;

    if (biorhythmData.physicalScore > biorhythmData.emotionalScore &&
        biorhythmData.physicalScore > biorhythmData.intellectualScore) {
      dominantRhythm = '화기(火氣)가 왕성하여 신체적 활동력이 뛰어난 시기';
      dominantAdvice = '이 기운을 활용하여 운동이나 활동적인 일을 추진하시면 좋은 결과를 얻으실 것입니다.';
    } else if (biorhythmData.emotionalScore > biorhythmData.intellectualScore) {
      dominantRhythm = '목기(木氣)가 왕성하여 감정이 풍부하고 사교적인 시기';
      dominantAdvice = '이 기운을 활용하여 인간관계나 예술적 활동에 힘쓰시면 좋은 인연을 맺으실 것입니다.';
    } else {
      dominantRhythm = '수기(水氣)가 왕성하여 지적 능력이 활발한 창조적 시기';
      dominantAdvice = '이 기운을 활용하여 학습이나 중요한 결정에 집중하시면 현명한 판단을 내리실 것입니다.';
    }

    return '''현재 $dominantRhythm입니다.

$dominantAdvice

삼기(三氣)의 흐름을 살피며 자신만의 최적의 타이밍을 찾아보세요.''';
  }
}

/// Lifestyle advice card with traditional Korean style
///
/// Design Philosophy:
/// - Hanji card with brush stroke accents
/// - Five Elements based advice
/// - Traditional terminology
class LifestyleAdviceCard extends StatelessWidget {
  final BiorhythmData biorhythmData;

  const LifestyleAdviceCard({
    super.key,
    required this.biorhythmData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = DSBiorhythmColors.getInkBleed(isDark);
    final advices = _getLifestyleAdvices(isDark);

    return BiorhythmHanjiCard(
      style: HanjiCardStyle.standard,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                '생활 지침 (生活指針)',
                style: context.bodyLarge.copyWith(
                  fontFamily: FontConfig.primary,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Advices list
          ...advices.asMap().entries.map((entry) {
            final index = entry.key;
            final advice = entry.value;
            final color = advice['color'] as Color;

            return Padding(
              padding: EdgeInsets.only(
                  bottom: index < advices.length - 1 ? 16 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Traditional element badge
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: color.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        advice['hanja'] as String,
                        style: context.bodyLarge.copyWith(
                          fontFamily: FontConfig.primary,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          advice['title'] as String,
                          style: context.bodySmall.copyWith(
                            fontFamily: FontConfig.primary,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          advice['description'] as String,
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

  List<Map<String, dynamic>> _getLifestyleAdvices(bool isDark) {
    final advices = <Map<String, dynamic>>[];

    // 신체 리듬 기반 조언
    if (biorhythmData.physicalScore >= 70) {
      advices.add({
        'title': '활동 시간 활용',
        'description': '화기(火氣)가 왕성하니 새로운 운동이나 도전을 시작하기 좋은 때입니다',
        'hanja': '動',
        'color': DSBiorhythmColors.getPhysical(isDark),
      });
    } else if (biorhythmData.physicalScore <= 30) {
      advices.add({
        'title': '휴식 권장',
        'description': '화기(火氣)가 약하니 충분한 휴식으로 기력을 회복하세요',
        'hanja': '休',
        'color': DSBiorhythmColors.getPhysical(isDark),
      });
    }

    // 감정 리듬 기반 조언
    if (biorhythmData.emotionalScore >= 70) {
      advices.add({
        'title': '교류 강화',
        'description': '목기(木氣)가 왕성하니 귀한 인연과 시간을 보내기 좋은 때입니다',
        'hanja': '交',
        'color': DSBiorhythmColors.getEmotional(isDark),
      });
    } else if (biorhythmData.emotionalScore <= 30) {
      advices.add({
        'title': '심신 안정',
        'description': '목기(木氣)가 약하니 명상이나 산책으로 마음의 평화를 찾아보세요',
        'hanja': '靜',
        'color': DSBiorhythmColors.getEmotional(isDark),
      });
    }

    // 지적 리듬 기반 조언
    if (biorhythmData.intellectualScore >= 70) {
      advices.add({
        'title': '학습 시간 확보',
        'description': '수기(水氣)가 왕성하니 새로운 것을 배우거나 중요한 결정을 내리기 좋습니다',
        'hanja': '學',
        'color': DSBiorhythmColors.getIntellectual(isDark),
      });
    } else if (biorhythmData.intellectualScore <= 30) {
      advices.add({
        'title': '단순 업무 집중',
        'description': '수기(水氣)가 약하니 복잡한 일은 피하고 간단한 업무에 집중하세요',
        'hanja': '簡',
        'color': DSBiorhythmColors.getIntellectual(isDark),
      });
    }

    // 기본 조언들
    if (advices.isEmpty) {
      advices.addAll([
        {
          'title': '균형 잡힌 생활',
          'description': '삼기(三氣)가 조화롭게 흐르니 규칙적인 생활로 균형을 유지하세요',
          'hanja': '和',
          'color': DSBiorhythmColors.goldAccent,
        },
        {
          'title': '자기 관찰',
          'description': '자신의 컨디션 변화를 살펴보며 지혜롭게 행동하세요',
          'hanja': '觀',
          'color': DSBiorhythmColors.goldAccent,
        },
      ]);
    }

    return advices;
  }
}

/// Health tips card with traditional Korean medicine style
///
/// Design Philosophy:
/// - Hanji outlined card style
/// - Traditional medicine advice format
/// - Five Elements health guidance
class HealthTipsCard extends StatelessWidget {
  final BiorhythmData biorhythmData;

  const HealthTipsCard({
    super.key,
    required this.biorhythmData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = DSBiorhythmColors.getInkBleed(isDark);

    return BiorhythmHanjiCard(
      style: HanjiCardStyle.scroll,
      showSealStamp: true,
      sealText: '養',
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            '양생 지침 (養生指針)',
            style: context.bodyLarge.copyWith(
              fontFamily: FontConfig.primary,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '오행에 따른 건강 관리',
            style: context.labelMedium.copyWith(
              color: textColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),

          // Health tips
          _buildHealthTip(
            context,
            '수면 (睡眠)',
            _getSleepTip(),
            '眠',
            DSBiorhythmColors.getIntellectual(isDark),
          ),
          const SizedBox(height: 16),

          _buildHealthTip(
            context,
            '식이 (食餌)',
            _getNutritionTip(),
            '食',
            DSBiorhythmColors.getEmotional(isDark),
          ),
          const SizedBox(height: 16),

          _buildHealthTip(
            context,
            '운동 (運動)',
            _getExerciseTip(),
            '動',
            DSBiorhythmColors.getPhysical(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTip(
    BuildContext context,
    String title,
    String tip,
    String hanja,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = DSBiorhythmColors.getInkBleed(isDark);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Traditional hanja badge
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              hanja,
              style: context.heading4.copyWith(
                fontFamily: FontConfig.primary,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.bodySmall.copyWith(
                  fontFamily: FontConfig.primary,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tip,
                style: context.labelMedium.copyWith(
                  color: textColor.withValues(alpha: 0.7),
                  height: 1.5,
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
      return '화기(火氣)가 약하니 평소보다 일찍 취침하여 기력을 보충하세요';
    } else if (biorhythmData.physicalScore >= 70) {
      return '화기(火氣)가 왕성하니 취침 전 이완 운동으로 기운을 가라앉히세요';
    }
    return '자시(子時)에 취침하여 하루 7-8시간 숙면으로 기운을 길러보세요';
  }

  String _getNutritionTip() {
    if (biorhythmData.physicalScore <= 30) {
      return '인삼, 대추 등 보기(補氣) 음식으로 기력을 보충하세요';
    } else if (biorhythmData.emotionalScore <= 30) {
      return '견과류, 녹색 채소 등 안심(安心) 음식으로 심신을 달래보세요';
    }
    return '오곡(五穀)과 채소로 균형 잡힌 식단을 유지하세요';
  }

  String _getExerciseTip() {
    if (biorhythmData.physicalScore >= 70) {
      return '화기(火氣)가 왕성하니 등산이나 달리기 등 활동적인 운동을 권합니다';
    } else if (biorhythmData.physicalScore <= 30) {
      return '화기(火氣)가 약하니 산책이나 기체조 등 가벼운 운동을 권합니다';
    }
    return '태극권이나 요가 등 기를 순환시키는 운동으로 몸을 관리하세요';
  }
}

/// Next analysis card with traditional style
///
/// Design Philosophy:
/// - Hanji minimal card style
/// - Traditional encouragement message
class NextAnalysisCard extends StatelessWidget {
  const NextAnalysisCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = DSBiorhythmColors.getInkBleed(isDark);

    return BiorhythmHanjiCard(
      style: HanjiCardStyle.minimal,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Traditional badge
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  DSBiorhythmColors.getPhysical(isDark).withValues(alpha: 0.7),
                  DSBiorhythmColors.getEmotional(isDark).withValues(alpha: 0.7),
                  DSBiorhythmColors.getIntellectual(isDark).withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                '運',
                style: context.heading2.copyWith(
                  fontFamily: FontConfig.primary,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '일주일 후 다시 운세를 살펴보세요',
                  style: context.bodyMedium.copyWith(
                    fontFamily: FontConfig.primary,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '삼기(三氣)의 흐름은 날마다 변화합니다',
                  style: context.labelMedium.copyWith(
                    color: textColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.arrow_forward_ios_rounded,
            color: textColor.withValues(alpha: 0.3),
            size: 16,
          ),
        ],
      ),
    );
  }
}

/// Traditional wisdom card with fortune-telling advice
class TraditionalWisdomCard extends StatelessWidget {
  final BiorhythmData biorhythmData;

  const TraditionalWisdomCard({
    super.key,
    required this.biorhythmData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = DSBiorhythmColors.getInkBleed(isDark);
    final wisdom = _getWisdom();

    return BiorhythmHanjiCard(
      style: HanjiCardStyle.hanging,
      showSealStamp: true,
      sealText: '訓',
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Wisdom title
          Text(
            wisdom['title'] as String,
            style: context.heading4.copyWith(
              fontFamily: FontConfig.primary,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Hanja quote
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: DSBiorhythmColors.getInkWashGuide(isDark).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              wisdom['hanja'] as String,
              style: context.heading3.copyWith(
                fontFamily: FontConfig.primary,
                color: textColor.withValues(alpha: 0.8),
                letterSpacing: 4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),

          // Interpretation
          Text(
            wisdom['interpretation'] as String,
            style: context.bodySmall.copyWith(
              color: textColor.withValues(alpha: 0.7),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Map<String, String> _getWisdom() {
    final avgScore = (biorhythmData.physicalScore +
            biorhythmData.emotionalScore +
            biorhythmData.intellectualScore) /
        3;

    if (avgScore >= 70) {
      return {
        'title': '오늘의 가르침',
        'hanja': '天時不如地利 地利不如人和',
        'interpretation': '하늘의 때가 좋아도 사람의 화합만 못하니, 좋은 기운을 나누어 인연을 돈독히 하세요.',
      };
    } else if (avgScore >= 50) {
      return {
        'title': '오늘의 가르침',
        'hanja': '守靜能制動 心正則身正',
        'interpretation': '고요함을 지키면 움직임을 다스리고, 마음이 바르면 몸도 바르니 중심을 잡으세요.',
      };
    } else {
      return {
        'title': '오늘의 가르침',
        'hanja': '塞翁之馬 福禍無門',
        'interpretation': '새옹지마라 하였으니, 화와 복은 한 끗 차이입니다. 어려운 때일수록 긍정의 마음을 품으세요.',
      };
    }
  }
}
