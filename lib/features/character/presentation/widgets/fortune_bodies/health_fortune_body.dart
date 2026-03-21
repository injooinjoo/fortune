import 'package:flutter/material.dart';

import '../../../../../core/design_system/design_system.dart';
import '_fortune_body_shared.dart';

/// Body widget for health/wellness fortune types:
/// health, exercise, match-insight, breathing
class HealthFortuneBody extends StatelessWidget {
  final String fortuneType;
  final Map<String, dynamic> componentData;

  const HealthFortuneBody({
    super.key,
    required this.fortuneType,
    required this.componentData,
  });

  @override
  Widget build(BuildContext context) {
    switch (fortuneType) {
      case 'health':
        return _buildHealthBody(context);
      case 'exercise':
        return _buildGenericBody(context, emoji: '💪');
      case 'match-insight':
        return _buildGenericBody(context, emoji: '⚽');
      case 'game-enhance':
        return _buildGenericBody(context, emoji: '🎮');
      default:
        return _buildGenericBody(context, emoji: '🌬️');
    }
  }

  // ═══ Health (건강운) ═══

  Widget _buildHealthBody(BuildContext context) {
    final summary = fortuneStr(componentData['summary']) ??
        fortuneStr(componentData['content']) ??
        '건강운을 분석했어요.';
    final healthAnalysis = fortuneAsMap(componentData['healthAnalysis']) ??
        fortuneAsMap(componentData['health_analysis']);
    final recommendations =
        fortuneAsMap(componentData['healthRecommendations']) ??
            fortuneAsMap(componentData['recommendations']);
    final warningsList = fortuneStrList(componentData['warnings']) +
        fortuneStrList(componentData['warningSigns']) +
        fortuneStrList(componentData['warning_signs']);
    final luckyItems = fortuneAsMap(componentData['luckyItems']);
    final highlights = fortuneStrList(componentData['highlights']);
    final specialTip = fortuneStr(componentData['specialTip']);

    // Health analysis sub-fields
    final overallStatus = fortuneStr(healthAnalysis?['overallStatus']) ??
        fortuneStr(healthAnalysis?['overall_status']);
    final physical = fortuneInt(healthAnalysis?['physicalCondition']) ??
        fortuneInt(healthAnalysis?['physical_condition']) ??
        fortuneInt(healthAnalysis?['physical']);
    final mental = fortuneInt(healthAnalysis?['mentalCondition']) ??
        fortuneInt(healthAnalysis?['mental_condition']) ??
        fortuneInt(healthAnalysis?['mental']);
    final energy = fortuneInt(healthAnalysis?['energyLevel']) ??
        fortuneInt(healthAnalysis?['energy_level']) ??
        fortuneInt(healthAnalysis?['energy']);
    final sleep = fortuneInt(healthAnalysis?['sleepQuality']) ??
        fortuneInt(healthAnalysis?['sleep_quality']) ??
        fortuneInt(healthAnalysis?['sleep']);

    // Recommendation sub-fields
    final exerciseRec = fortuneStrList(recommendations?['exercise']);
    final dietRec = fortuneStrList(recommendations?['diet']);
    final restRec = fortuneStrList(recommendations?['rest']);
    final stressRec = fortuneStrList(recommendations?['stressManagement']) +
        fortuneStrList(recommendations?['stress_management']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FortuneEmojiHeader(emoji: '🏥', text: summary),

        if (overallStatus != null) ...[
          const SizedBox(height: DSSpacing.sm),
          Center(child: FortuneTagPillWrap(tags: ['🩺 $overallStatus'])),
        ],

        if (highlights.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          Center(child: FortuneTagPillWrap(tags: highlights)),
        ],

        // Health indicators
        if (physical != null ||
            mental != null ||
            energy != null ||
            sleep != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneSectionCard(
            emoji: '📊',
            title: '건강 지표',
            child: Column(
              children: [
                if (physical != null)
                  FortuneProgressBar(
                      label: '체력', score: physical, emoji: '💪'),
                if (mental != null) ...[
                  const SizedBox(height: DSSpacing.xs),
                  FortuneProgressBar(
                      label: '정신력', score: mental, emoji: '🧠'),
                ],
                if (energy != null) ...[
                  const SizedBox(height: DSSpacing.xs),
                  FortuneProgressBar(
                      label: '에너지', score: energy, emoji: '⚡'),
                ],
                if (sleep != null) ...[
                  const SizedBox(height: DSSpacing.xs),
                  FortuneProgressBar(
                      label: '수면', score: sleep, emoji: '😴'),
                ],
              ],
            ),
          ),
        ],

        // Exercise recommendations
        if (exerciseRec.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneSectionCard(
            emoji: '🏃',
            title: '운동 추천',
            child: FortuneBulletList(items: exerciseRec, bullet: '💪'),
          ),
        ],

        // Diet recommendations
        if (dietRec.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneSectionCard(
            emoji: '🥗',
            title: '식단 추천',
            child: FortuneBulletList(items: dietRec, bullet: '🍎'),
          ),
        ],

        // Rest recommendations
        if (restRec.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneSectionCard(
            emoji: '😴',
            title: '휴식 팁',
            child: FortuneBulletList(items: restRec, bullet: '🌙'),
          ),
        ],

        // Stress management
        if (stressRec.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneSectionCard(
            emoji: '🧘',
            title: '스트레스 관리',
            child: FortuneBulletList(items: stressRec, bullet: '🌿'),
          ),
        ],

        if (specialTip != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneTipCard(emoji: '💡', text: specialTip),
        ],

        if (luckyItems != null && luckyItems.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneLuckyItemGrid(items: luckyItems),
        ],

        if (warningsList.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneSectionCard(
            emoji: '⚠️',
            title: '주의 신호',
            child: FortuneBulletList(
                items: warningsList, bullet: '⚠️', isWarning: true),
          ),
        ],
      ],
    );
  }

  // ═══ Generic fallback (exercise, match-insight, breathing) ═══

  Widget _buildGenericBody(BuildContext context, {required String emoji}) {
    final summary = fortuneStr(componentData['summary']) ??
        fortuneStr(componentData['content']) ??
        '결과를 분석했어요.';
    final highlights = fortuneStrList(componentData['highlights']);
    final luckyItems = fortuneAsMap(componentData['luckyItems']);
    final recommendations = fortuneStrList(componentData['recommendations']);
    final warnings = fortuneStrList(componentData['warnings']);
    final specialTip = fortuneStr(componentData['specialTip']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FortuneEmojiHeader(emoji: emoji, text: summary),
        if (highlights.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          Center(child: FortuneTagPillWrap(tags: highlights)),
        ],
        if (specialTip != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneTipCard(emoji: '💡', text: specialTip),
        ],
        if (luckyItems != null && luckyItems.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneLuckyItemGrid(items: luckyItems),
        ],
        if (recommendations.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneSectionCard(
            emoji: '✅',
            title: '추천',
            child: FortuneBulletList(items: recommendations, bullet: '💫'),
          ),
        ],
        if (warnings.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneSectionCard(
            emoji: '⚠️',
            title: '주의',
            child: FortuneBulletList(
                items: warnings, bullet: '⚠️', isWarning: true),
          ),
        ],
      ],
    );
  }
}
