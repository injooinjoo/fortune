import 'package:flutter/material.dart';

import '../../../../../core/design_system/design_system.dart';
import '_fortune_body_shared.dart';
import '_fortune_visual_components.dart';

/// Body widget for relationship fortune types:
/// love, compatibility, blind-date, ex-lover, avoid-people
///
/// Each type has a unique, visually rich layout matching its data structure.
/// Score is displayed only in the parent _buildCardShell header badge.
class RelationshipFortuneBody extends StatelessWidget {
  final String fortuneType;
  final Map<String, dynamic> componentData;

  const RelationshipFortuneBody({
    super.key,
    required this.fortuneType,
    required this.componentData,
  });

  @override
  Widget build(BuildContext context) {
    switch (fortuneType) {
      case 'compatibility':
        return _buildCompatibilityBody(context);
      case 'blind-date':
        return _buildBlindDateBody(context);
      case 'avoid-people':
        return _buildAvoidPeopleBody(context);
      case 'ex-lover':
        return _buildExLoverBody(context);
      case 'love':
      default:
        return _buildLoveBody(context);
    }
  }

  // ═══════════════════════════════════════════════
  // 💝 Love (연애운) — Rich profile + advice layout
  // ═══════════════════════════════════════════════

  Widget _buildLoveBody(BuildContext context) {
    final summary = fortuneStr(componentData['summary']) ??
        fortuneStr(componentData['content']) ??
        '연애운을 분석했어요.';
    final loveProfile = fortuneAsMap(componentData['loveProfile']);
    final detailedAnalysis = fortuneAsMap(componentData['detailedAnalysis']);
    final todaysAdvice = fortuneAsMap(componentData['todaysAdvice']);
    final predictions = fortuneAsMap(componentData['predictions']);
    final highlights = fortuneStrList(componentData['highlights']);
    final luckyItems = fortuneAsMap(componentData['luckyItems']);
    final recommendations = fortuneStrList(componentData['recommendations']);
    final warnings = fortuneStrList(componentData['warnings']);

    // Extract nested data
    final charmPoints = fortuneAsMap(detailedAnalysis?['charmPoints']);
    final improvementAreas =
        fortuneAsMap(detailedAnalysis?['improvementAreas']);
    final compatInsights =
        fortuneAsMap(detailedAnalysis?['compatibilityInsights']);

    var sectionIndex = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero emoji + summary
        FortuneEmojiHeader(
          emoji: '💝',
          text: summary,
        ),

        if (highlights.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          Center(child: FortuneTagPillWrap(tags: highlights)),
        ],

        // 🌸 Love Profile section
        if (loveProfile != null && loveProfile.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: sectionIndex++,
            child: _buildLoveProfileGrid(context, loveProfile),
          ),
        ],

        // ✨ Charm Points
        if (charmPoints != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: sectionIndex++,
            child: _buildCharmPointsCard(context, charmPoints),
          ),
        ],

        // 📈 Improvement Areas
        if (improvementAreas != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: sectionIndex++,
            child: _buildImprovementCard(context, improvementAreas),
          ),
        ],

        // 💕 Compatibility Insights
        if (compatInsights != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: sectionIndex++,
            child: _buildCompatInsightsCard(context, compatInsights),
          ),
        ],

        // 🎯 Today's Advice
        if (todaysAdvice != null && todaysAdvice.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: sectionIndex++,
            child: _buildTodaysAdviceCard(context, todaysAdvice),
          ),
        ],

        // Lucky items
        if (luckyItems != null && luckyItems.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: sectionIndex++,
            child: FortuneLuckyItemGrid(items: luckyItems),
          ),
        ],

        // 🔮 Predictions
        if (predictions != null) ...[
          if (fortuneStr(predictions['thisWeek']) != null) ...[
            const SizedBox(height: DSSpacing.md),
            FortuneStaggeredSection(
              index: sectionIndex++,
              child: FortuneQuoteBlock(
                emoji: '📅',
                title: '이번 주 예측',
                text: predictions['thisWeek'].toString(),
              ),
            ),
          ],
          if (fortuneStr(predictions['thisMonth']) != null) ...[
            const SizedBox(height: DSSpacing.md),
            FortuneStaggeredSection(
              index: sectionIndex++,
              child: FortuneQuoteBlock(
                emoji: '🗓️',
                title: '이번 달 예측',
                text: predictions['thisMonth'].toString(),
              ),
            ),
          ],
        ],

        // Recommendations
        if (recommendations.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: sectionIndex++,
            child: FortuneSectionCard(
              emoji: '💕',
              title: '추천',
              child: FortuneBulletList(items: recommendations, bullet: '💫'),
            ),
          ),
        ],

        // Warnings
        if (warnings.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: sectionIndex++,
            child: FortuneSectionCard(
              emoji: '⚠️',
              title: '주의',
              child: FortuneBulletList(
                items: warnings,
                bullet: '⚠️',
                isWarning: true,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoveProfileGrid(
    BuildContext context,
    Map<String, dynamic> profile,
  ) {
    final items = <_ProfileItem>[];
    if (fortuneStr(profile['dominantStyle']) != null) {
      items.add(_ProfileItem('💕', '연애 스타일', profile['dominantStyle']));
    }
    if (fortuneStr(profile['loveLanguage']) != null) {
      items.add(_ProfileItem('💌', '사랑의 언어', profile['loveLanguage']));
    }
    if (fortuneStr(profile['attachmentType']) != null) {
      items.add(_ProfileItem('🤗', '애착 유형', profile['attachmentType']));
    }
    if (fortuneStr(profile['communicationStyle']) != null) {
      items.add(_ProfileItem('🗣️', '소통 방식', profile['communicationStyle']));
    }
    if (fortuneStr(profile['conflictResolution']) != null) {
      items.add(_ProfileItem('⚡', '갈등 해결', profile['conflictResolution']));
    }
    if (items.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;
    return FortuneSectionCard(
      emoji: '🌸',
      title: '나의 연애 프로필',
      child: Wrap(
        spacing: DSSpacing.sm,
        runSpacing: DSSpacing.sm,
        children: items.map((item) {
          return Container(
            width: (MediaQuery.of(context).size.width - 120) / 2,
            padding: const EdgeInsets.all(DSSpacing.sm),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(DSRadius.md),
              border: Border.all(
                color: colors.border.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(item.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: DSSpacing.xxs),
                    Expanded(
                      child: Text(
                        item.label,
                        style: context.labelSmall.copyWith(
                          color: colors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DSSpacing.xxs),
                Text(
                  item.value,
                  style: context.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }).toList(growable: false),
      ),
    );
  }

  Widget _buildCharmPointsCard(
    BuildContext context,
    Map<String, dynamic> charm,
  ) {
    final primary = fortuneStr(charm['primary']);
    final secondary = fortuneStr(charm['secondary']);
    final hidden = fortuneStr(charm['hiddenCharm']);
    final details = fortuneStrList(charm['details']);

    return FortuneSectionCard(
      emoji: '✨',
      title: '매력 포인트',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (primary != null)
            FortuneMetricRow(emoji: '🌟', label: '주요 매력', value: primary),
          if (secondary != null)
            FortuneMetricRow(emoji: '💫', label: '보조 매력', value: secondary),
          if (hidden != null)
            FortuneMetricRow(emoji: '🔮', label: '숨겨진 매력', value: hidden),
          if (details.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.xs),
            FortuneTagPillWrap(tags: details.take(5).toList()),
          ],
        ],
      ),
    );
  }

  Widget _buildImprovementCard(
    BuildContext context,
    Map<String, dynamic> areas,
  ) {
    final main = fortuneStr(areas['main']);
    final specific = fortuneStrList(areas['specific']);
    final actionItems = fortuneStrList(areas['actionItems']);
    final tip = fortuneStr(areas['psychologyTip']);

    return FortuneSectionCard(
      emoji: '📈',
      title: '성장 포인트',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (main != null)
            Text(
              main,
              style: context.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.6,
              ),
            ),
          if (specific.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.xs),
            FortuneTagPillWrap(tags: specific.take(4).toList()),
          ],
          if (actionItems.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            FortuneBulletList(items: actionItems, bullet: '✏️'),
          ],
          if (tip != null) ...[
            const SizedBox(height: DSSpacing.sm),
            FortuneTipCard(emoji: '🧠', text: tip),
          ],
        ],
      ),
    );
  }

  Widget _buildCompatInsightsCard(
    BuildContext context,
    Map<String, dynamic> insights,
  ) {
    final bestMatch = fortuneStr(insights['bestMatch']);
    final goodMatch = fortuneStr(insights['goodMatch']);
    final challenging = fortuneStr(insights['challengingMatch']);
    final tips = fortuneStrList(insights['relationshipTips']);

    return FortuneSectionCard(
      emoji: '💕',
      title: '궁합 인사이트',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bestMatch != null)
            FortuneMetricRow(emoji: '💖', label: '최고 궁합', value: bestMatch),
          if (goodMatch != null)
            FortuneMetricRow(emoji: '💛', label: '좋은 궁합', value: goodMatch),
          if (challenging != null)
            FortuneMetricRow(emoji: '💔', label: '도전적', value: challenging),
          if (tips.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            FortuneBulletList(items: tips.take(3).toList(), bullet: '💡'),
          ],
        ],
      ),
    );
  }

  Widget _buildTodaysAdviceCard(
    BuildContext context,
    Map<String, dynamic> advice,
  ) {
    final general = fortuneStr(advice['general']);
    final specific = fortuneStrList(advice['specific']);
    final luckyAction = fortuneStr(advice['luckyAction']);
    final luckyItem = fortuneStr(advice['luckyItem']);
    final luckyTime = fortuneStr(advice['luckyTime']);
    final warningArea = fortuneStr(advice['warningArea']);

    return FortuneSectionCard(
      emoji: '🎯',
      title: '오늘의 연애 조언',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (general != null)
            Text(
              general,
              style: context.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.6,
              ),
            ),
          if (specific.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            FortuneBulletList(items: specific, bullet: '💫'),
          ],
          if (luckyAction != null ||
              luckyItem != null ||
              luckyTime != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(DSRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (luckyAction != null)
                    FortuneMetricRow(
                        emoji: '🎲', label: '행운 행동', value: luckyAction),
                  if (luckyItem != null)
                    FortuneMetricRow(
                        emoji: '🍀', label: '행운 아이템', value: luckyItem),
                  if (luckyTime != null)
                    FortuneMetricRow(
                        emoji: '⏰', label: '행운 시간', value: luckyTime),
                ],
              ),
            ),
          ],
          if (warningArea != null) ...[
            const SizedBox(height: DSSpacing.sm),
            FortuneTipCard(emoji: '⚠️', text: warningArea),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // 💑 Compatibility (궁합) — Comparison layout
  // ═══════════════════════════════════════════════

  Widget _buildCompatibilityBody(BuildContext context) {
    final summary = fortuneStr(componentData['summary']) ??
        fortuneStr(componentData['content']) ??
        '궁합을 분석했어요.';
    final keyword = fortuneStr(componentData['compatibilityKeyword']);
    final person1 = fortuneAsMap(componentData['person1']);
    final person2 = fortuneAsMap(componentData['person2']);
    final zodiacAnimal = fortuneAsMap(componentData['zodiacAnimal']);
    final starSign = fortuneAsMap(componentData['starSign']);
    final nameCompat = fortuneInt(componentData['nameCompatibility']);
    final destinyNumber = fortuneAsMap(componentData['destinyNumber']);
    final strengths = fortuneStrList(componentData['strengths']);
    final cautions = fortuneStrList(componentData['cautions']);
    final luckyItems = fortuneAsMap(componentData['luckyItems']);
    final recommendations = fortuneStrList(componentData['recommendations']);

    final matchScores = <String, int>{};
    _addScore(matchScores, '성격', componentData['personalityMatch']);
    _addScore(matchScores, '연애', componentData['loveMatch']);
    _addScore(matchScores, '결혼', componentData['marriageMatch']);
    _addScore(matchScores, '소통', componentData['communicationMatch']);

    var si = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero
        FortuneEmojiHeader(
          emoji: '💑',
          text: keyword != null ? '"$keyword"' : summary,
        ),
        if (keyword != null) ...[
          const SizedBox(height: DSSpacing.sm),
          Text(
            summary,
            textAlign: TextAlign.center,
            style: context.bodySmall.copyWith(
              color: context.colors.textSecondary,
              height: 1.55,
            ),
          ),
        ],

        // Person comparison
        if (zodiacAnimal != null || starSign != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: _buildPersonComparison(
                context, person1, person2, zodiacAnimal, starSign),
          ),
        ],

        // Match score bars
        if (matchScores.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '📊',
              title: '궁합 상세',
              child: Column(
                children: matchScores.entries.indexed
                    .map((indexed) => FortuneAnimatedProgressBar(
                          label: indexed.$2.key,
                          score: indexed.$2.value,
                          staggerIndex: indexed.$1,
                        ))
                    .toList(growable: false),
              ),
            ),
          ),
        ],

        // Strengths & Cautions
        if (strengths.isNotEmpty || cautions.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneDosDontsCard(dosList: strengths, dontsList: cautions),
          ),
        ],

        // Name compatibility & destiny number
        if (nameCompat != null || destinyNumber != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: _buildExtraMetrics(context, nameCompat, destinyNumber),
          ),
        ],

        // Lucky items
        if (luckyItems != null && luckyItems.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneLuckyItemGrid(items: luckyItems),
          ),
        ],

        // Recommendations
        if (recommendations.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '💕',
              title: '추천',
              child: FortuneBulletList(items: recommendations, bullet: '💫'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPersonComparison(
    BuildContext context,
    Map<String, dynamic>? person1,
    Map<String, dynamic>? person2,
    Map<String, dynamic>? zodiac,
    Map<String, dynamic>? star,
  ) {
    final colors = context.colors;
    final name1 = fortuneStr(person1?['name']) ?? '나';
    final name2 = fortuneStr(person2?['name']) ?? '상대';
    final zodiac1 = fortuneStr(zodiac?['person1']) ?? '';
    final zodiac2 = fortuneStr(zodiac?['person2']) ?? '';
    final star1 = fortuneStr(star?['person1']) ?? '';
    final star2 = fortuneStr(star?['person2']) ?? '';
    final zodiacMsg = fortuneStr(zodiac?['message']);
    final starMsg = fortuneStr(star?['message']);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          // Names row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _personBadge(context, '👤', name1),
              const Text('❤️', style: TextStyle(fontSize: 20)),
              _personBadge(context, '👤', name2),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          // Zodiac comparison
          if (zodiac1.isNotEmpty || zodiac2.isNotEmpty) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    '🐾 $zodiac1',
                    textAlign: TextAlign.center,
                    style:
                        context.bodySmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  'VS',
                  style: context.labelSmall.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Expanded(
                  child: Text(
                    '🐾 $zodiac2',
                    textAlign: TextAlign.center,
                    style:
                        context.bodySmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (zodiacMsg != null) ...[
              const SizedBox(height: DSSpacing.xxs),
              Text(
                zodiacMsg,
                textAlign: TextAlign.center,
                style: context.labelSmall.copyWith(
                  color: colors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ],
          // Star sign comparison
          if (star1.isNotEmpty || star2.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '⭐ $star1',
                    textAlign: TextAlign.center,
                    style:
                        context.bodySmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  'VS',
                  style: context.labelSmall.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Expanded(
                  child: Text(
                    '⭐ $star2',
                    textAlign: TextAlign.center,
                    style:
                        context.bodySmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (starMsg != null) ...[
              const SizedBox(height: DSSpacing.xxs),
              Text(
                starMsg,
                textAlign: TextAlign.center,
                style: context.labelSmall.copyWith(
                  color: colors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _personBadge(BuildContext context, String emoji, String name) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: DSSpacing.xxs),
        Text(
          name,
          style: context.labelMedium.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildExtraMetrics(
    BuildContext context,
    int? nameCompat,
    Map<String, dynamic>? destiny,
  ) {
    final destinyNum = fortuneStr(destiny?['number']);
    final destinyMeaning = fortuneStr(destiny?['meaning']);

    return FortuneSectionCard(
      emoji: '🔢',
      title: '추가 분석',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (nameCompat != null)
            FortuneProgressBar(
              label: '이름',
              score: nameCompat,
              emoji: '📝',
            ),
          if (destinyNum != null) ...[
            FortuneMetricRow(
              emoji: '🌟',
              label: '운명수',
              value: destinyNum,
            ),
            if (destinyMeaning != null)
              Text(
                destinyMeaning,
                style: context.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                  height: 1.55,
                ),
              ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // 🌹 Blind Date (소개팅) — Attractiveness + strategy
  // ═══════════════════════════════════════════════

  Widget _buildBlindDateBody(BuildContext context) {
    final summary = fortuneStr(componentData['summary']) ??
        fortuneStr(componentData['content']) ??
        '소개팅 운세를 분석했어요.';
    final myStyle = fortuneStr(componentData['myStyle']);
    final myAttractiveness = fortuneInt(componentData['myAttractiveness']);
    final theirAttractiveness =
        fortuneInt(componentData['theirAttractiveness']);
    final visualCompat = fortuneInt(componentData['visualCompatibility']);
    final firstImpression = fortuneStr(componentData['firstImpression']);
    final recommendedStyle = fortuneStr(componentData['recommendedDateStyle']);
    final interestLevel = fortuneInt(componentData['interestLevel']);
    final firstTips = fortuneStrList(componentData['firstImpressionTips']);
    final improvementTips = fortuneStrList(componentData['improvementTips']);
    final nextTopics = fortuneStrList(componentData['nextTopicSuggestions']);
    final redFlags = fortuneStrList(componentData['redFlags']);
    final conversationTopics =
        fortuneAsMap(componentData['conversationTopics']);
    final outfitAdvice = fortuneAsMap(componentData['outfitAdvice']);
    final dosList = fortuneStrList(componentData['dosList']);
    final dontsList = fortuneStrList(componentData['dontsList']);
    final luckyItems = fortuneAsMap(componentData['luckyItems']);
    final recommendations = fortuneStrList(componentData['recommendations']);
    final warnings = fortuneStrList(componentData['warnings']);

    var si = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero
        FortuneEmojiHeader(
          emoji: '🌹',
          text: myStyle != null ? '당신은 "$myStyle" 스타일!' : summary,
        ),
        if (myStyle != null) ...[
          const SizedBox(height: DSSpacing.xs),
          Text(
            summary,
            textAlign: TextAlign.center,
            style: context.bodySmall.copyWith(
              color: context.colors.textSecondary,
              height: 1.55,
            ),
          ),
        ],

        // Attractiveness bars
        if (myAttractiveness != null ||
            theirAttractiveness != null ||
            visualCompat != null ||
            interestLevel != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '💫',
              title: '매력도 분석',
              child: Column(
                children: [
                  if (myAttractiveness != null)
                    FortuneAnimatedProgressBar(
                      label: '나',
                      score: myAttractiveness,
                      emoji: '🙂',
                      staggerIndex: 0,
                    ),
                  if (theirAttractiveness != null)
                    FortuneAnimatedProgressBar(
                      label: '상대',
                      score: theirAttractiveness,
                      emoji: '😊',
                      staggerIndex: 1,
                    ),
                  if (visualCompat != null)
                    FortuneAnimatedProgressBar(
                      label: '비주얼',
                      score: visualCompat,
                      emoji: '✨',
                      staggerIndex: 2,
                    ),
                  if (interestLevel != null)
                    FortuneAnimatedProgressBar(
                      label: '관심도',
                      score: interestLevel,
                      emoji: '💘',
                      staggerIndex: 3,
                    ),
                ],
              ),
            ),
          ),
        ],

        // First impression
        if (firstImpression != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneTipCard(emoji: '👋', text: firstImpression),
          ),
        ],

        // First impression tips
        if (firstTips.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '💬',
              title: '첫인상 팁',
              child: FortuneBulletList(items: firstTips, bullet: '🎯'),
            ),
          ),
        ],

        // Conversation strategy
        if (conversationTopics != null || nextTopics.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: _buildConversationSection(
                context, conversationTopics, nextTopics),
          ),
        ],

        // Outfit advice
        if (outfitAdvice != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: _buildOutfitSection(context, outfitAdvice),
          ),
        ],

        // Recommended date style
        if (recommendedStyle != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child:
                FortuneTipCard(emoji: '🎬', text: '추천 데이트: $recommendedStyle'),
          ),
        ],

        // Do's and Don'ts
        if (dosList.isNotEmpty || dontsList.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneDosDontsCard(dosList: dosList, dontsList: dontsList),
          ),
        ],

        // Improvement tips
        if (improvementTips.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '📈',
              title: '개선 포인트',
              child: FortuneBulletList(items: improvementTips, bullet: '✏️'),
            ),
          ),
        ],

        // Red flags
        if (redFlags.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '🚩',
              title: '주의 신호',
              child: FortuneBulletList(
                items: redFlags,
                bullet: '🚩',
                isWarning: true,
              ),
            ),
          ),
        ],

        // Lucky items
        if (luckyItems != null && luckyItems.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneLuckyItemGrid(items: luckyItems),
          ),
        ],

        // Generic recommendations
        if (recommendations.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '💕',
              title: '추천',
              child: FortuneBulletList(items: recommendations, bullet: '💫'),
            ),
          ),
        ],

        // Warnings
        if (warnings.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '⚠️',
              title: '주의',
              child: FortuneBulletList(
                items: warnings,
                bullet: '⚠️',
                isWarning: true,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildConversationSection(
    BuildContext context,
    Map<String, dynamic>? topics,
    List<String> nextTopicSuggestions,
  ) {
    final recommended = fortuneStrList(topics?['recommended']);
    final avoid = fortuneStrList(topics?['avoid']);
    final allTopics = [...recommended, ...nextTopicSuggestions];

    return FortuneSectionCard(
      emoji: '💬',
      title: '대화 전략',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (allTopics.isNotEmpty) ...[
            Text(
              '추천 토픽',
              style: context.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: DSSpacing.xs),
            FortuneTagPillWrap(tags: allTopics.take(5).toList()),
          ],
          if (avoid.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            Text(
              '피할 토픽',
              style: context.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: DSSpacing.xs),
            FortuneTagPillWrap(tags: avoid.take(3).toList()),
          ],
        ],
      ),
    );
  }

  Widget _buildOutfitSection(
    BuildContext context,
    Map<String, dynamic> outfit,
  ) {
    final style = fortuneStr(outfit['style']);
    final outfitColors = fortuneStrList(outfit['colors']);
    final tips = fortuneStrList(outfit['tips']);

    return FortuneSectionCard(
      emoji: '👗',
      title: '코디 추천',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (style != null)
            Text(
              style,
              style: context.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.6,
              ),
            ),
          if (outfitColors.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.xs),
            FortuneTagPillWrap(tags: outfitColors),
          ],
          if (tips.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            FortuneBulletList(items: tips, bullet: '👔'),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // 🌙 Ex-Lover (재회 운세) — Possibility + timeline
  // ═══════════════════════════════════════════════

  Widget _buildExLoverBody(BuildContext context) {
    final summary = fortuneStr(componentData['summary']) ??
        fortuneStr(componentData['content']) ??
        '재회 운세를 분석했어요.';
    final reunionPossibility = fortuneInt(componentData['reunionPossibility']);
    final primaryGoal = fortuneStr(componentData['primaryGoal']);
    final timeline = fortuneStr(componentData['timeline']);
    final highlights = fortuneStrList(componentData['highlights']);
    final recommendations = fortuneStrList(componentData['recommendations']);
    final warnings = fortuneStrList(componentData['warnings']);
    final luckyItems = fortuneAsMap(componentData['luckyItems']);
    final advice = fortuneStr(componentData['advice']);

    var si = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero
        FortuneEmojiHeader(
          emoji: '🌙',
          text: summary,
        ),

        if (highlights.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          Center(child: FortuneTagPillWrap(tags: highlights)),
        ],

        // Reunion possibility
        if (reunionPossibility != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '🔮',
              title: '재회 가능성',
              child: FortuneAnimatedProgressBar(
                label: '가능성',
                score: reunionPossibility,
                emoji: '💫',
                staggerIndex: 0,
              ),
            ),
          ),
        ],

        // Primary goal
        if (primaryGoal != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '🎯',
              title: '주요 목표',
              child: Text(
                primaryGoal,
                style: context.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],

        // Timeline
        if (timeline != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '⏰',
              title: '타임라인',
              child: Text(
                timeline,
                style: context.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],

        // Advice
        if (advice != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneTipCard(emoji: '💡', text: advice),
          ),
        ],

        // Lucky items
        if (luckyItems != null && luckyItems.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneLuckyItemGrid(items: luckyItems),
          ),
        ],

        // Recommendations
        if (recommendations.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '💜',
              title: '추천 행동',
              child: FortuneBulletList(items: recommendations, bullet: '💫'),
            ),
          ),
        ],

        // Warnings
        if (warnings.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '⚠️',
              title: '주의사항',
              child: FortuneBulletList(
                items: warnings,
                bullet: '⚠️',
                isWarning: true,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════
  // 🛡️ Avoid People (피해야 할 사람) — Caution cards
  // ═══════════════════════════════════════════════

  Widget _buildAvoidPeopleBody(BuildContext context) {
    final summary = fortuneStr(componentData['summary']) ??
        fortuneStr(componentData['content']) ??
        '오늘 주의할 관계를 분석했어요.';
    final cautionPeople = fortuneMapList(componentData['cautionPeople']);
    final timeStrategy = fortuneAsMap(componentData['timeStrategy']);
    final cautionObjects = fortuneStrList(componentData['cautionObjects']);
    final cautionColors = fortuneStrList(componentData['cautionColors']);
    final cautionNumbers = fortuneStrList(componentData['cautionNumbers']);
    final highlights = fortuneStrList(componentData['highlights']);
    final recommendations = fortuneStrList(componentData['recommendations']);
    final warnings = fortuneStrList(componentData['warnings']);
    final luckyItems = fortuneAsMap(componentData['luckyItems']);

    var si = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero
        FortuneEmojiHeader(
          emoji: '🛡️',
          text: summary,
        ),

        if (highlights.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          Center(child: FortuneTagPillWrap(tags: highlights)),
        ],

        // Caution people cards
        if (cautionPeople.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          ...cautionPeople.take(3).indexed.map(
                (entry) => FortuneStaggeredSection(
                  index: si++,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: DSSpacing.sm),
                    child: _buildCautionPersonCard(context, entry.$2),
                  ),
                ),
              ),
        ],

        // Avoid items
        if (cautionObjects.isNotEmpty ||
            cautionColors.isNotEmpty ||
            cautionNumbers.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          FortuneStaggeredSection(
            index: si++,
            child: _buildAvoidItemsCard(
                context, cautionObjects, cautionColors, cautionNumbers),
          ),
        ],

        // Time strategy
        if (timeStrategy != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: _buildTimeStrategyCard(context, timeStrategy),
          ),
        ],

        // Lucky items
        if (luckyItems != null && luckyItems.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneLuckyItemGrid(items: luckyItems),
          ),
        ],

        // Recommendations
        if (recommendations.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '✅',
              title: '추천',
              child: FortuneBulletList(items: recommendations, bullet: '💫'),
            ),
          ),
        ],

        // Warnings
        if (warnings.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '⚠️',
              title: '주의',
              child: FortuneBulletList(
                items: warnings,
                bullet: '⚠️',
                isWarning: true,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCautionPersonCard(
    BuildContext context,
    Map<String, dynamic> person,
  ) {
    final colors = context.colors;
    final type = fortuneStr(person['type']) ?? '유형';
    final reason = fortuneStr(person['reason']);
    final sign = fortuneStr(person['sign']);
    final tip = fortuneStr(person['tip']);
    final severity = fortuneStr(person['severity']);

    final severityEmoji = severity == 'high'
        ? '🔴'
        : severity == 'medium'
            ? '🟡'
            : '🟢';
    final severityLabel = severity == 'high'
        ? '높음'
        : severity == 'medium'
            ? '보통'
            : '낮음';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: severity == 'high'
              ? colors.warning.withValues(alpha: 0.3)
              : colors.border.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: DSSpacing.xs),
              Expanded(
                child: Text(
                  type,
                  style: context.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (severity != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.sm,
                    vertical: DSSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(DSRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(severityEmoji, style: const TextStyle(fontSize: 10)),
                      const SizedBox(width: 2),
                      Text(
                        severityLabel,
                        style: context.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (reason != null) ...[
            const SizedBox(height: DSSpacing.xs),
            Text(
              reason,
              style: context.bodySmall.copyWith(
                color: colors.textSecondary,
                height: 1.55,
              ),
            ),
          ],
          if (sign != null) ...[
            const SizedBox(height: DSSpacing.xs),
            FortuneMetricRow(emoji: '🔍', label: '특징', value: sign),
          ],
          if (tip != null) ...[
            const SizedBox(height: DSSpacing.sm),
            FortuneTipCard(emoji: '💡', text: tip),
          ],
        ],
      ),
    );
  }

  Widget _buildAvoidItemsCard(
    BuildContext context,
    List<String> objects,
    List<String> avoidColors,
    List<String> numbers,
  ) {
    final allTags = <String>[
      ...objects.map((o) => '🚫 $o'),
      ...avoidColors.map((c) => '🎨 $c'),
      ...numbers.map((n) => '🔢 $n'),
    ];
    if (allTags.isEmpty) return const SizedBox.shrink();

    return FortuneSectionCard(
      emoji: '🚫',
      title: '피해야 할 것들',
      child: FortuneTagPillWrap(tags: allTags),
    );
  }

  Widget _buildTimeStrategyCard(
    BuildContext context,
    Map<String, dynamic> strategy,
  ) {
    final morning = fortuneStr(strategy['morning']);
    final afternoon = fortuneStr(strategy['afternoon']);
    final evening = fortuneStr(strategy['evening']);
    final period = fortuneStr(strategy['period']);
    final strategyText = fortuneStr(strategy['strategy']);

    if (morning == null &&
        afternoon == null &&
        evening == null &&
        strategyText == null) {
      return const SizedBox.shrink();
    }

    return FortuneSectionCard(
      emoji: '⏰',
      title: '시간 전략',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (period != null || strategyText != null) ...[
            Text(
              strategyText ?? period!,
              style: context.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.6,
              ),
            ),
            if (morning != null || afternoon != null || evening != null)
              const SizedBox(height: DSSpacing.sm),
          ],
          if (morning != null)
            FortuneMetricRow(emoji: '🌅', label: '오전', value: morning),
          if (afternoon != null)
            FortuneMetricRow(emoji: '☀️', label: '오후', value: afternoon),
          if (evening != null)
            FortuneMetricRow(emoji: '🌙', label: '저녁', value: evening),
        ],
      ),
    );
  }

  // ═══ Helpers ═══

  void _addScore(Map<String, int> map, String label, dynamic value) {
    final score = fortuneInt(value);
    if (score != null) map[label] = score;
  }
}

class _ProfileItem {
  final String emoji;
  final String label;
  final String value;
  _ProfileItem(this.emoji, this.label, this.value);
}
