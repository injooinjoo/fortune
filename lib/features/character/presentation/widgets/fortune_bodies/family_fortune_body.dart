import 'package:flutter/material.dart';

import '../../../../../core/design_system/design_system.dart';
import '_fortune_body_shared.dart';
import '_fortune_visual_components.dart';

/// Body widget for family/pet fortune types:
/// family, pet-compatibility, naming
class FamilyFortuneBody extends StatelessWidget {
  final String fortuneType;
  final Map<String, dynamic> componentData;

  const FamilyFortuneBody({
    super.key,
    required this.fortuneType,
    required this.componentData,
  });

  @override
  Widget build(BuildContext context) {
    switch (fortuneType) {
      case 'pet-compatibility':
        return _buildPetCompatibilityBody(context);
      case 'naming':
        return _buildGenericBody(context, emoji: '✍️');
      case 'family':
      default:
        return _buildGenericBody(context, emoji: '👨‍👩‍👧‍👦');
    }
  }

  // ═══ Pet Compatibility (반려동물 궁합) ═══

  Widget _buildPetCompatibilityBody(BuildContext context) {
    final summary = fortuneStr(componentData['summary']) ??
        fortuneStr(componentData['content']) ??
        '반려동물 궁합을 분석했어요.';
    final overallCompat = fortuneStr(componentData['overallCompatibility']) ??
        fortuneStr(componentData['overall_compatibility']);
    final dailyFortune = fortuneStr(componentData['dailyFortune']) ??
        fortuneStr(componentData['daily_fortune']);
    final petsVoice = fortuneAsMap(componentData['petsVoice']) ??
        fortuneAsMap(componentData['pets_voice']);
    final bondingMission = fortuneAsMap(componentData['bondingMission']) ??
        fortuneAsMap(componentData['bonding_mission']);
    final activities = fortuneStrList(componentData['activities']);
    final healthInsight = fortuneStr(componentData['healthInsight']) ??
        fortuneStr(componentData['health_insight']);
    final emotionalCare = fortuneStr(componentData['emotionalCare']) ??
        fortuneStr(componentData['emotional_care']);
    final activityRecommendation =
        fortuneAsMap(componentData['activityRecommendation']) ??
            fortuneAsMap(componentData['activity_recommendation']);
    final luckyItemsForPet = fortuneAsMap(componentData['luckyItemsForPet']) ??
        fortuneAsMap(componentData['lucky_items_for_pet']);
    final luckyItems = fortuneAsMap(componentData['luckyItems']);
    final highlights = fortuneStrList(componentData['highlights']);
    final recommendations = fortuneStrList(componentData['recommendations']);
    final warnings = fortuneStrList(componentData['warnings']);

    // Pet's voice sub-fields
    final letter = fortuneStr(petsVoice?['heartfeltLetter']) ??
        fortuneStr(petsVoice?['heartfelt_letter']) ??
        fortuneStr(petsVoice?['letter']);

    // Bonding mission sub-fields
    final missionTitle = fortuneStr(bondingMission?['title']) ??
        fortuneStr(bondingMission?['mission']);
    final missionDifficulty = fortuneStr(bondingMission?['difficulty']);
    final missionDesc = fortuneStr(bondingMission?['description']);

    // Activity recommendation sub-fields
    final morning = fortuneStr(activityRecommendation?['morning']);
    final afternoon = fortuneStr(activityRecommendation?['afternoon']);
    final evening = fortuneStr(activityRecommendation?['evening']);

    var si = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FortuneEmojiHeader(emoji: '🐾', text: summary),

        if (overallCompat != null) ...[
          const SizedBox(height: DSSpacing.sm),
          Center(child: FortuneTagPillWrap(tags: ['💕 $overallCompat'])),
        ],

        if (highlights.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          Center(child: FortuneTagPillWrap(tags: highlights)),
        ],

        if (dailyFortune != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneTipCard(emoji: '🌟', text: dailyFortune),
          ),
        ],

        // Pet's heartfelt letter — special QuoteBlock
        if (letter != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneQuoteBlock(
              emoji: '💌',
              title: '반려동물의 편지',
              text: letter,
            ),
          ),
        ],

        // Bonding mission
        if (missionTitle != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '🎯',
              title: '오늘의 미션',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          missionTitle,
                          style: context.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (missionDifficulty != null)
                        FortuneTagPillWrap(tags: ['⭐ $missionDifficulty']),
                    ],
                  ),
                  if (missionDesc != null) ...[
                    const SizedBox(height: DSSpacing.xs),
                    Text(
                      missionDesc,
                      style: context.bodySmall.copyWith(
                        color: context.colors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],

        // Activity recommendations by time
        if (morning != null || afternoon != null || evening != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '🕐',
              title: '시간대별 활동',
              child: Column(
                children: [
                  if (morning != null)
                    FortuneMetricRow(emoji: '🌅', label: '아침', value: morning),
                  if (afternoon != null)
                    FortuneMetricRow(
                        emoji: '☀️', label: '오후', value: afternoon),
                  if (evening != null)
                    FortuneMetricRow(emoji: '🌙', label: '저녁', value: evening),
                ],
              ),
            ),
          ),
        ],

        if (activities.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '🎾',
              title: '추천 활동',
              child: FortuneBulletList(items: activities, bullet: '🐕'),
            ),
          ),
        ],

        if (healthInsight != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneTipCard(emoji: '🏥', text: healthInsight),
          ),
        ],

        if (emotionalCare != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneTipCard(emoji: '💝', text: emotionalCare),
          ),
        ],

        if ((luckyItemsForPet ?? luckyItems) != null &&
            (luckyItemsForPet ?? luckyItems)!.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneLuckyItemGrid(items: luckyItemsForPet ?? luckyItems!),
          ),
        ],

        if (recommendations.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '💫',
              title: '추천',
              child: FortuneBulletList(items: recommendations, bullet: '🐾'),
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

  // ═══ Generic fallback (family, naming) ═══

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
