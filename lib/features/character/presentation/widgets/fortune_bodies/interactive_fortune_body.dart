import 'package:flutter/material.dart';

import '../../../../../core/design_system/design_system.dart';
import '_fortune_body_shared.dart';

/// Body widget for interactive fortune types:
/// game-enhance, wish, celebrity, ootd-evaluation
class InteractiveFortuneBody extends StatelessWidget {
  final String fortuneType;
  final Map<String, dynamic> componentData;

  const InteractiveFortuneBody({
    super.key,
    required this.fortuneType,
    required this.componentData,
  });

  @override
  Widget build(BuildContext context) {
    switch (fortuneType) {
      case 'game-enhance':
        return _buildGenericBody(context, emoji: '🎮');
      case 'wish':
        return _buildGenericBody(context, emoji: '⭐');
      case 'celebrity':
        return _buildGenericBody(context, emoji: '🌟');
      case 'ootd-evaluation':
        return _buildOotdBody(context);
      default:
        return _buildGenericBody(context, emoji: '✨');
    }
  }

  // ═══ OOTD Evaluation (패션 평가) ═══

  Widget _buildOotdBody(BuildContext context) {
    final summary = fortuneStr(componentData['summary']) ??
        fortuneStr(componentData['content']) ??
        '오늘의 패션을 분석했어요.';
    final highlights = fortuneStrList(componentData['highlights']);
    final luckyItems = fortuneAsMap(componentData['luckyItems']);
    final recommendations = fortuneStrList(componentData['recommendations']);
    final warnings = fortuneStrList(componentData['warnings']);
    final specialTip = fortuneStr(componentData['specialTip']);
    final styleAnalysis = fortuneAsMap(componentData['styleAnalysis']);
    final colorAdvice = fortuneStr(componentData['colorAdvice']);

    final styleType = fortuneStr(styleAnalysis?['type']);
    final styleTips = fortuneStrList(styleAnalysis?['tips']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FortuneEmojiHeader(emoji: '👗', text: summary),

        if (styleType != null) ...[
          const SizedBox(height: DSSpacing.sm),
          Center(child: FortuneTagPillWrap(tags: ['👔 $styleType'])),
        ],

        if (highlights.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          Center(child: FortuneTagPillWrap(tags: highlights)),
        ],

        if (colorAdvice != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneTipCard(emoji: '🎨', text: colorAdvice),
        ],

        if (styleTips.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneSectionCard(
            emoji: '💅',
            title: '스타일 팁',
            child: FortuneBulletList(items: styleTips, bullet: '👗'),
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

  // ═══ Generic fallback ═══

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
