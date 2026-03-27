import 'package:flutter/material.dart';

import '../../../../../core/design_system/design_system.dart';
import '_fortune_body_shared.dart';
import '_fortune_visual_components.dart';

/// Body widget for mystical/spiritual fortune types:
/// talisman, past-life, moving
class MysticalFortuneBody extends StatelessWidget {
  final String fortuneType;
  final Map<String, dynamic> componentData;

  const MysticalFortuneBody({
    super.key,
    required this.fortuneType,
    required this.componentData,
  });

  @override
  Widget build(BuildContext context) {
    switch (fortuneType) {
      case 'moving':
        return _buildMovingBody(context);
      case 'talisman':
        return _buildGenericBody(context, emoji: '🧧');
      case 'past-life':
        return _buildGenericBody(context, emoji: '🌀');
      default:
        return _buildGenericBody(context, emoji: '✨');
    }
  }

  // ═══ Moving / Fengshui (풍수/이사운) ═══

  Widget _buildMovingBody(BuildContext context) {
    final summary = fortuneStr(componentData['summary']) ??
        fortuneStr(componentData['content']) ??
        '이사운을 분석했어요.';
    final fengshuiAnalysis = fortuneAsMap(componentData['fengshuiAnalysis']) ??
        fortuneAsMap(componentData['fengshui_analysis']);
    final directionAnalysis =
        fortuneAsMap(componentData['directionAnalysis']) ??
            fortuneAsMap(componentData['direction_analysis']);
    final highlights = fortuneStrList(componentData['highlights']);
    final luckyItems = fortuneAsMap(componentData['luckyItems']);
    final recommendations = fortuneStrList(componentData['recommendations']);
    final warnings = fortuneStrList(componentData['warnings']);
    final specialTip = fortuneStr(componentData['specialTip']);
    final bestDirections = fortuneStrList(componentData['bestDirections']) +
        fortuneStrList(componentData['best_directions']);
    final avoidDirections = fortuneStrList(componentData['avoidDirections']) +
        fortuneStrList(componentData['avoid_directions']);

    // Fengshui sub-fields
    final overallEnergy = fortuneStr(fengshuiAnalysis?['overallEnergy']) ??
        fortuneStr(fengshuiAnalysis?['overall_energy']);
    final elementBalance = fortuneStr(fengshuiAnalysis?['elementBalance']) ??
        fortuneStr(fengshuiAnalysis?['element_balance']);

    // Direction sub-fields
    final bestDir = fortuneStr(directionAnalysis?['best']);
    final worstDir = fortuneStr(directionAnalysis?['worst']);
    final dirAdvice = fortuneStr(directionAnalysis?['advice']);

    var si = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FortuneEmojiHeader(emoji: '🏠', text: summary),

        if (highlights.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          Center(child: FortuneTagPillWrap(tags: highlights)),
        ],

        // Fengshui overview
        if (overallEnergy != null || elementBalance != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '🌊',
              title: '풍수 분석',
              child: Column(
                children: [
                  if (overallEnergy != null)
                    FortuneMetricRow(
                        emoji: '🔮', label: '전체 기운', value: overallEnergy),
                  if (elementBalance != null)
                    FortuneMetricRow(
                        emoji: '☯️', label: '오행 균형', value: elementBalance),
                ],
              ),
            ),
          ),
        ],

        // Direction analysis
        if (bestDir != null ||
            worstDir != null ||
            bestDirections.isNotEmpty ||
            avoidDirections.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '🧭',
              title: '방향 분석',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (bestDir != null)
                    FortuneMetricRow(emoji: '✅', label: '길방', value: bestDir),
                  if (worstDir != null)
                    FortuneMetricRow(emoji: '❌', label: '흉방', value: worstDir),
                  if (bestDirections.isNotEmpty) ...[
                    const SizedBox(height: DSSpacing.xs),
                    FortuneTagPillWrap(
                      tags: bestDirections.map((d) => '✅ $d').toList(),
                    ),
                  ],
                  if (avoidDirections.isNotEmpty) ...[
                    const SizedBox(height: DSSpacing.xs),
                    FortuneTagPillWrap(
                      tags: avoidDirections.map((d) => '❌ $d').toList(),
                    ),
                  ],
                  if (dirAdvice != null) ...[
                    const SizedBox(height: DSSpacing.sm),
                    FortuneTipCard(emoji: '💡', text: dirAdvice),
                  ],
                ],
              ),
            ),
          ),
        ],

        if (specialTip != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneTipCard(emoji: '💡', text: specialTip),
          ),
        ],

        if (luckyItems != null && luckyItems.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneLuckyItemGrid(items: luckyItems),
          ),
        ],

        if (recommendations.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '✅',
              title: '추천',
              child: FortuneBulletList(items: recommendations, bullet: '🏡'),
            ),
          ),
        ],

        if (warnings.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '⚠️',
              title: '주의',
              child: FortuneBulletList(
                  items: warnings, bullet: '⚠️', isWarning: true),
            ),
          ),
        ],
      ],
    );
  }

  // ═══ Generic fallback (talisman, past-life) ═══

  Widget _buildGenericBody(BuildContext context, {required String emoji}) {
    final summary = fortuneStr(componentData['summary']) ??
        fortuneStr(componentData['content']) ??
        '결과를 분석했어요.';
    final highlights = fortuneStrList(componentData['highlights']);
    final luckyItems = fortuneAsMap(componentData['luckyItems']);
    final recommendations = fortuneStrList(componentData['recommendations']);
    final warnings = fortuneStrList(componentData['warnings']);
    final specialTip = fortuneStr(componentData['specialTip']);

    var si = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FortuneEmojiHeader(emoji: emoji, text: summary),
        if (highlights.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          Center(child: FortuneTagPillWrap(tags: highlights)),
        ],
        if (specialTip != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneTipCard(emoji: '💡', text: specialTip),
          ),
        ],
        if (luckyItems != null && luckyItems.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneLuckyItemGrid(items: luckyItems),
          ),
        ],
        if (recommendations.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '💫',
              title: '추천',
              child: FortuneBulletList(items: recommendations, bullet: '✨'),
            ),
          ),
        ],
        if (warnings.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '⚠️',
              title: '주의',
              child: FortuneBulletList(
                  items: warnings, bullet: '⚠️', isWarning: true),
            ),
          ),
        ],
      ],
    );
  }
}
