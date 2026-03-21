import 'package:flutter/material.dart';

import '../../../../../core/design_system/design_system.dart';
import '_fortune_body_shared.dart';

/// Body widget for coaching/review fortune types:
/// coaching, decision, daily-review, weekly-review
class CoachingFortuneBody extends StatelessWidget {
  final String fortuneType;
  final Map<String, dynamic> componentData;

  const CoachingFortuneBody({
    super.key,
    required this.fortuneType,
    required this.componentData,
  });

  @override
  Widget build(BuildContext context) {
    switch (fortuneType) {
      case 'coaching':
        return _buildGenericBody(context, emoji: '🎯');
      case 'decision':
        return _buildGenericBody(context, emoji: '🤔');
      case 'daily-review':
        return _buildGenericBody(context, emoji: '📋');
      case 'weekly-review':
        return _buildGenericBody(context, emoji: '📊');
      default:
        return _buildGenericBody(context, emoji: '✨');
    }
  }

  // ═══ Generic body with coaching-flavored design ═══

  Widget _buildGenericBody(BuildContext context, {required String emoji}) {
    final summary = fortuneStr(componentData['summary']) ??
        fortuneStr(componentData['content']) ??
        '결과를 분석했어요.';
    final highlights = fortuneStrList(componentData['highlights']);
    final luckyItems = fortuneAsMap(componentData['luckyItems']);
    final recommendations = fortuneStrList(componentData['recommendations']);
    final warnings = fortuneStrList(componentData['warnings']);
    final specialTip = fortuneStr(componentData['specialTip']);
    final actionItems = fortuneStrList(componentData['actionItems']);
    final insights = fortuneStrList(componentData['insights']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FortuneEmojiHeader(emoji: emoji, text: summary),
        if (highlights.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          Center(child: FortuneTagPillWrap(tags: highlights)),
        ],

        if (insights.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneSectionCard(
            emoji: '💡',
            title: '인사이트',
            child: FortuneBulletList(items: insights, bullet: '🔍'),
          ),
        ],

        if (actionItems.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneSectionCard(
            emoji: '📝',
            title: '실천 항목',
            child: FortuneBulletList(items: actionItems, bullet: '✅'),
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

        if (recommendations.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneSectionCard(
            emoji: '💫',
            title: '추천',
            child: FortuneBulletList(items: recommendations, bullet: '✨'),
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
