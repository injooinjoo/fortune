import 'package:flutter/material.dart';

import '../../../../../core/design_system/design_system.dart';
import '_fortune_body_shared.dart';
import '_fortune_visual_components.dart';

/// Body widget for profile-based fortune types:
/// blood-type, zodiac-animal, constellation
///
/// Paper artboards: F04 (45C-1/A9V-0), F05 (45D-1/AB8-0), F06 (45E-1/ACQ-0)
class ProfileFortuneBody extends StatelessWidget {
  final String fortuneType;
  final Map<String, dynamic> componentData;

  const ProfileFortuneBody({
    super.key,
    required this.fortuneType,
    required this.componentData,
  });

  @override
  Widget build(BuildContext context) {
    switch (fortuneType) {
      case 'blood-type':
        return _buildBloodTypeBody(context);
      case 'zodiac-animal':
        return _buildZodiacAnimalBody(context);
      case 'constellation':
        return _buildConstellationBody(context);
      default:
        return _buildGenericProfileBody(context);
    }
  }

  // ═══ Blood Type (혈액형 운세) — Paper F04 ═══

  Widget _buildBloodTypeBody(BuildContext context) {
    final summary = fortuneStr(componentData['summary']) ??
        fortuneStr(componentData['content']) ??
        '혈액형 운세를 분석했어요.';
    final bloodType = fortuneStr(componentData['bloodType']);
    final nickname = fortuneStr(componentData['nickname']);
    final keywords = fortuneStrList(componentData['keywords']);
    final personality = fortuneStrList(componentData['personality']);
    final compatibility = fortuneAsMap(componentData['compatibility']);
    final bestMatch = fortuneStr(compatibility?['best']) ??
        fortuneStr(compatibility?['bestMatch']);
    final cautionMatch = fortuneStr(compatibility?['caution']) ??
        fortuneStr(compatibility?['cautionMatch']);
    final recommendations = fortuneStrList(componentData['recommendations']);
    final luckyItems = fortuneAsMap(componentData['luckyItems']) ??
        fortuneAsMap(componentData['luckyElements']);
    final specialTip = fortuneStr(componentData['specialTip']) ??
        fortuneStr(componentData['tip']);

    var si = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Paper: centered emoji + static title "혈액형 운세"
        const FortuneEmojiHeader(emoji: '🩸', text: '혈액형 운세'),

        // Paper: summary section with colored title
        ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '🩸',
              title: bloodType != null ? '$bloodType형의 오늘 운세' : '오늘의 운세',
              titleColor: const Color(0xFFEF5350),
              child: Text(
                summary,
                style: _bodyTextStyle(context),
              ),
            ),
          ),
        ],

        // Paper: two side-by-side cards (blood type display + keywords)
        if (bloodType != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: _buildBloodTypeInfoCard(
              context,
              bloodType: bloodType,
              nickname: nickname,
              keywords: keywords,
            ),
          ),
        ],

        // Personality traits
        if (personality.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '🧬',
              title: '성격 특성',
              titleColor: const Color(0xFFFF9800),
              child: FortuneBulletList(items: personality, bullet: '✨'),
            ),
          ),
        ],

        // Paper: compatibility section with pink title
        if (bestMatch != null || cautionMatch != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '💕',
              title: '혈액형별 궁합',
              titleColor: const Color(0xFFFF6B8A),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (bestMatch != null)
                    _metricRow(context, label: '최고 궁합', value: '$bestMatch ❤️'),
                  if (cautionMatch != null)
                    _metricRow(context,
                        label: '주의 궁합', value: '$cautionMatch ⚡'),
                ],
              ),
            ),
          ),
        ],

        // Paper: recommendations with gold title
        if (recommendations.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '💡',
              title: '추천',
              titleColor: const Color(0xFFFFD54F),
              child: FortuneBulletList(items: recommendations, bullet: '✨'),
            ),
          ),
        ],

        // Special tip
        if (specialTip != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneTipCard(emoji: '💡', text: specialTip),
          ),
        ],

        // Paper: lucky items as metric rows with green title
        if (luckyItems != null && luckyItems.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: _buildLuckyItemsSection(context, luckyItems),
          ),
        ],
      ],
    );
  }

  /// Paper F04: Two side-by-side cards for blood type info
  /// Left: centered emoji + type name (24px w700 red) + nickname (9px)
  /// Right: "오늘의 키워드" label + tag pills
  /// Both: bg white@6%/#FFF5F5, radius 10, padding 14
  Widget _buildBloodTypeInfoCard(
    BuildContext context, {
    required String bloodType,
    String? nickname,
    List<String> keywords = const [],
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg =
        isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFFFF5F5);
    final subtitleColor =
        isDark ? const Color(0xFF888888) : context.colors.textTertiary;
    final labelColor =
        isDark ? const Color(0xFFAAAAAA) : context.colors.textTertiary;

    return Row(
      children: [
        // Paper: left card — blood type display
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                const Text('🩸',
                    style: TextStyle(fontSize: 28, height: 34 / 28)),
                const SizedBox(height: 6),
                // Paper: 24px w700 #EF5350
                Text(
                  '$bloodType형',
                  style: const TextStyle(
                    fontFamily: 'NotoSansKR',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 30 / 24,
                    color: Color(0xFFEF5350),
                  ),
                ),
                if (nickname != null) ...[
                  const SizedBox(height: 6),
                  // Paper: 9px w400 #888
                  Text(
                    nickname,
                    style: TextStyle(
                      fontFamily: 'NotoSansKR',
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      height: 12 / 9,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (keywords.isNotEmpty) ...[
          const SizedBox(width: 8), // Paper: gap 8
          // Paper: right card — keywords
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Paper: 11px w400 #AAA
                  Text(
                    '오늘의 키워드',
                    style: TextStyle(
                      fontFamily: 'NotoSansKR',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      height: 14 / 11,
                      color: labelColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FortuneTagPillWrap(tags: keywords),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ═══ Zodiac Animal (띠 운세) — Paper F05 ═══

  Widget _buildZodiacAnimalBody(BuildContext context) {
    final summary = fortuneStr(componentData['summary']) ??
        fortuneStr(componentData['content']) ??
        '띠 운세를 분석했어요.';
    final animalName = fortuneStr(componentData['animalName']) ??
        fortuneStr(componentData['animal']);
    final animalEmoji = fortuneStr(componentData['animalEmoji']);
    final earthlyBranch = fortuneStr(componentData['earthlyBranch']);
    final years = fortuneStrList(componentData['years']);
    final element = fortuneStr(componentData['element']);
    final elementEmoji = fortuneStr(componentData['elementEmoji']);
    final personality = fortuneStr(componentData['personality']) ??
        fortuneStr(componentData['characterDesc']);

    // Score bars
    final scores = fortuneAsMap(componentData['scores']) ??
        fortuneAsMap(componentData['todayScores']);
    final overallScore = fortuneInt(scores?['overall']) ??
        fortuneInt(scores?['총운']) ??
        fortuneInt(componentData['overallScore']);
    final wealthScore =
        fortuneInt(scores?['wealth']) ?? fortuneInt(scores?['재물운']);
    final loveScore = fortuneInt(scores?['love']) ?? fortuneInt(scores?['애정운']);
    final healthScore =
        fortuneInt(scores?['health']) ?? fortuneInt(scores?['건강운']);

    // Compatibility
    final compatibility = fortuneAsMap(componentData['compatibility']);
    final bestCompat =
        fortuneStr(compatibility?['best']) ?? fortuneStr(compatibility?['삼합']);
    final cautionCompat = fortuneStr(compatibility?['caution']) ??
        fortuneStr(compatibility?['상충']);

    final specialTip = fortuneStr(componentData['specialTip']) ??
        fortuneStr(componentData['tip']);
    final luckyItems = fortuneAsMap(componentData['luckyItems']) ??
        fortuneAsMap(componentData['luckyElements']);

    var si = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Paper: centered emoji + static title "띠 운세"
        FortuneEmojiHeader(
          emoji: animalEmoji ?? '🐾',
          text: '띠 운세',
        ),

        // Paper: summary section with orange title
        ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: animalEmoji ?? '🐾',
              title: animalName != null ? '$animalName의 오늘 운세' : '오늘의 운세',
              titleColor: const Color(0xFFFF9800),
              child: Text(
                summary,
                style: _bodyTextStyle(context),
              ),
            ),
          ),
        ],

        // Paper: two side-by-side info cards
        if (animalName != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: _buildAnimalInfoCard(
              context,
              animalName: animalName,
              earthlyBranch: earthlyBranch,
              years: years,
              element: element,
              elementEmoji: elementEmoji,
              personality: personality,
            ),
          ),
        ],

        // Paper: score bars with gold title
        if (overallScore != null ||
            wealthScore != null ||
            loveScore != null ||
            healthScore != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '🏆',
              title: '오늘의 운세 지수',
              titleColor: const Color(0xFFFFD54F),
              child: Column(
                children: [
                  if (overallScore != null)
                    FortuneAnimatedProgressBar(
                      label: '총운',
                      score: overallScore,
                      emoji: '🌟',
                      staggerIndex: 0,
                    ),
                  if (wealthScore != null)
                    FortuneAnimatedProgressBar(
                      label: '재물운',
                      score: wealthScore,
                      emoji: '💰',
                      staggerIndex: 1,
                    ),
                  if (loveScore != null)
                    FortuneAnimatedProgressBar(
                      label: '애정운',
                      score: loveScore,
                      emoji: '❤️',
                      staggerIndex: 2,
                    ),
                  if (healthScore != null)
                    FortuneAnimatedProgressBar(
                      label: '건강운',
                      score: healthScore,
                      emoji: '💪',
                      staggerIndex: 3,
                    ),
                ],
              ),
            ),
          ),
        ],

        // Paper: compatibility with pink title
        if (bestCompat != null || cautionCompat != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '🐾',
              title: '띠 궁합',
              titleColor: const Color(0xFFFF6B8A),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (bestCompat != null)
                    _metricRow(context, label: '삼합', value: bestCompat),
                  if (cautionCompat != null)
                    _metricRow(context, label: '상충', value: cautionCompat),
                ],
              ),
            ),
          ),
        ],

        // Special tip
        if (specialTip != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneTipCard(emoji: '💡', text: specialTip),
          ),
        ],

        // Lucky items
        if (luckyItems != null && luckyItems.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: _buildLuckyItemsSection(context, luckyItems),
          ),
        ],
      ],
    );
  }

  /// Paper F05: Two side-by-side cards for zodiac animal info
  /// Left: animal name (24px w700) + earthly branch + years
  /// Right: 오행 + 성격
  Widget _buildAnimalInfoCard(
    BuildContext context, {
    required String animalName,
    String? earthlyBranch,
    List<String> years = const [],
    String? element,
    String? elementEmoji,
    String? personality,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg =
        isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFFFF5F5);
    final subtitleColor =
        isDark ? const Color(0xFF888888) : context.colors.textTertiary;
    final labelColor =
        isDark ? const Color(0xFFAAAAAA) : context.colors.textTertiary;

    return Row(
      children: [
        // Left card — animal name
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  animalName,
                  style: TextStyle(
                    fontFamily: 'NotoSansKR',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 30 / 24,
                    color: isDark ? Colors.white : const Color(0xFF0B0B10),
                  ),
                ),
                if (earthlyBranch != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    earthlyBranch,
                    style: TextStyle(
                      fontFamily: 'NotoSansKR',
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      height: 12 / 9,
                      color: subtitleColor,
                    ),
                  ),
                ],
                if (years.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    years.join(', '),
                    style: TextStyle(
                      fontFamily: 'NotoSansKR',
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      height: 12 / 9,
                      color: subtitleColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (element != null || personality != null) ...[
          const SizedBox(width: 8),
          // Right card — element & personality
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (element != null) ...[
                    Text(
                      '오행',
                      style: TextStyle(
                        fontFamily: 'NotoSansKR',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        height: 14 / 11,
                        color: labelColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${elementEmoji ?? '🔥'} $element',
                      style: const TextStyle(
                        fontFamily: 'NotoSansKR',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 16 / 13,
                        color: Color(0xFFFF9800),
                      ),
                    ),
                  ],
                  if (personality != null) ...[
                    if (element != null) const SizedBox(height: 8),
                    Text(
                      '성격',
                      style: TextStyle(
                        fontFamily: 'NotoSansKR',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        height: 14 / 11,
                        color: labelColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      personality,
                      style: TextStyle(
                        fontFamily: 'NotoSansKR',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        height: 14 / 11,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.7)
                            : context.colors.textSecondary,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ═══ Constellation (별자리 운세) — Paper F06 ═══

  Widget _buildConstellationBody(BuildContext context) {
    final summary = fortuneStr(componentData['summary']) ??
        fortuneStr(componentData['content']) ??
        '별자리 운세를 분석했어요.';
    final constellationName = fortuneStr(componentData['constellationName']) ??
        fortuneStr(componentData['constellation']);
    final constellationEmoji =
        fortuneStr(componentData['constellationEmoji']) ??
            fortuneStr(componentData['emoji']);
    final englishName = fortuneStr(componentData['englishName']);
    final dateRange = fortuneStr(componentData['dateRange']);
    final element = fortuneStr(componentData['element']);
    final rulingPlanet = fortuneStr(componentData['rulingPlanet']);
    final rulingPlanetEmoji = fortuneStr(componentData['rulingPlanetEmoji']);
    final personality = fortuneStr(componentData['personality']) ??
        fortuneStr(componentData['characterDesc']);

    // Score bars
    final scores = fortuneAsMap(componentData['scores']) ??
        fortuneAsMap(componentData['todayScores']);
    final overallScore =
        fortuneInt(scores?['overall']) ?? fortuneInt(scores?['총운']);
    final romanceScore =
        fortuneInt(scores?['romance']) ?? fortuneInt(scores?['연애운']);
    final careerScore =
        fortuneInt(scores?['career']) ?? fortuneInt(scores?['직장운']);
    final financeScore =
        fortuneInt(scores?['finance']) ?? fortuneInt(scores?['금전운']);

    // Compatibility
    final compatibility = fortuneAsMap(componentData['compatibility']);
    final bestCompat = fortuneStr(compatibility?['best']) ??
        fortuneStr(compatibility?['bestMatch']);
    final cautionCompat = fortuneStr(compatibility?['caution']) ??
        fortuneStr(compatibility?['cautionMatch']);

    final luckyItems = fortuneAsMap(componentData['luckyItems']) ??
        fortuneAsMap(componentData['luckyElements']);

    var si = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Paper: centered emoji + static title "별자리 운세"
        FortuneEmojiHeader(
          emoji: constellationEmoji ?? '⭐',
          text: '별자리 운세',
        ),

        // Paper: summary section with orange title
        ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: constellationEmoji ?? '⭐',
              title: constellationName != null
                  ? '$constellationName의 오늘 운세'
                  : '오늘의 운세',
              titleColor: const Color(0xFFFF9800),
              child: Text(
                summary,
                style: _bodyTextStyle(context),
              ),
            ),
          ),
        ],

        // Paper: two side-by-side info cards
        if (constellationName != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: _buildConstellationInfoCard(
              context,
              name: constellationName,
              englishName: englishName,
              dateRange: dateRange,
              element: element,
              rulingPlanet: rulingPlanet,
              rulingPlanetEmoji: rulingPlanetEmoji,
              personality: personality,
            ),
          ),
        ],

        // Paper: score bars with gold title
        if (overallScore != null ||
            romanceScore != null ||
            careerScore != null ||
            financeScore != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '⭐',
              title: '오늘의 운세 지수',
              titleColor: const Color(0xFFFFD54F),
              child: Column(
                children: [
                  if (overallScore != null)
                    FortuneAnimatedProgressBar(
                      label: '총운',
                      score: overallScore,
                      emoji: '🌟',
                      staggerIndex: 0,
                    ),
                  if (romanceScore != null)
                    FortuneAnimatedProgressBar(
                      label: '연애운',
                      score: romanceScore,
                      emoji: '❤️',
                      staggerIndex: 1,
                    ),
                  if (careerScore != null)
                    FortuneAnimatedProgressBar(
                      label: '직장운',
                      score: careerScore,
                      emoji: '💼',
                      staggerIndex: 2,
                    ),
                  if (financeScore != null)
                    FortuneAnimatedProgressBar(
                      label: '금전운',
                      score: financeScore,
                      emoji: '💰',
                      staggerIndex: 3,
                    ),
                ],
              ),
            ),
          ),
        ],

        // Paper: compatibility with pink title
        if (bestCompat != null || cautionCompat != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '🌙',
              title: '별자리 궁합',
              titleColor: const Color(0xFFFF6B8A),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (bestCompat != null)
                    _metricRow(context, label: '최고 궁합', value: bestCompat),
                  if (cautionCompat != null)
                    _metricRow(context, label: '주의 궁합', value: cautionCompat),
                ],
              ),
            ),
          ),
        ],

        // Paper: lucky items with green title
        if (luckyItems != null && luckyItems.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: _buildLuckyItemsSection(context, luckyItems),
          ),
        ],
      ],
    );
  }

  /// Paper F06: Two side-by-side cards for constellation info
  /// Left: constellation name (24px w700) + english name + date range
  /// Right: 원소 + 수호성 + 성격
  Widget _buildConstellationInfoCard(
    BuildContext context, {
    required String name,
    String? englishName,
    String? dateRange,
    String? element,
    String? rulingPlanet,
    String? rulingPlanetEmoji,
    String? personality,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg =
        isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFFFF5F5);
    final subtitleColor =
        isDark ? const Color(0xFF888888) : context.colors.textTertiary;
    final labelColor =
        isDark ? const Color(0xFFAAAAAA) : context.colors.textTertiary;

    return Row(
      children: [
        // Left card — constellation name
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'NotoSansKR',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 30 / 24,
                    color: isDark ? Colors.white : const Color(0xFF0B0B10),
                  ),
                ),
                if (englishName != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    englishName,
                    style: TextStyle(
                      fontFamily: 'NotoSansKR',
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      height: 12 / 9,
                      color: subtitleColor,
                    ),
                  ),
                ],
                if (dateRange != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    dateRange,
                    style: TextStyle(
                      fontFamily: 'NotoSansKR',
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      height: 12 / 9,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (element != null || rulingPlanet != null || personality != null) ...[
          const SizedBox(width: 8),
          // Right card — element, ruling planet, personality
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (element != null) ...[
                    Text(
                      '원소',
                      style: TextStyle(
                        fontFamily: 'NotoSansKR',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        height: 14 / 11,
                        color: labelColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '🔥 $element',
                      style: const TextStyle(
                        fontFamily: 'NotoSansKR',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 16 / 13,
                        color: Color(0xFFFF9800),
                      ),
                    ),
                  ],
                  if (rulingPlanet != null) ...[
                    if (element != null) const SizedBox(height: 8),
                    Text(
                      '수호성',
                      style: TextStyle(
                        fontFamily: 'NotoSansKR',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        height: 14 / 11,
                        color: labelColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${rulingPlanetEmoji ?? '🌟'} $rulingPlanet',
                      style: const TextStyle(
                        fontFamily: 'NotoSansKR',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 16 / 13,
                        color: Color(0xFFFF9800),
                      ),
                    ),
                  ],
                  if (personality != null) ...[
                    if (element != null || rulingPlanet != null)
                      const SizedBox(height: 8),
                    Text(
                      '성격',
                      style: TextStyle(
                        fontFamily: 'NotoSansKR',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        height: 14 / 11,
                        color: labelColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      personality,
                      style: TextStyle(
                        fontFamily: 'NotoSansKR',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        height: 14 / 11,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.7)
                            : context.colors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ═══ Generic Profile Fallback ═══

  Widget _buildGenericProfileBody(BuildContext context) {
    final summary = fortuneStr(componentData['summary']) ??
        fortuneStr(componentData['content']) ??
        '결과를 분석했어요.';
    final highlights = fortuneStrList(componentData['highlights']);
    final luckyItems = fortuneAsMap(componentData['luckyItems']);
    final recommendations = fortuneStrList(componentData['recommendations']);

    var si = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FortuneEmojiHeader(emoji: '🔮', text: summary),
        if (highlights.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          Center(child: FortuneTagPillWrap(tags: highlights)),
        ],
        if (luckyItems != null && luckyItems.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: _buildLuckyItemsSection(context, luckyItems),
          ),
        ],
        if (recommendations.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '💫',
              title: '추천',
              child: FortuneBulletList(items: recommendations, bullet: '✨'),
            ),
          ),
        ],
      ],
    );
  }

  // ═══ Shared Helpers ═══

  /// Paper: metric row without emoji prefix — label left, value right
  /// Label: 11px w400 textTertiary, Value: 11px w400 textPrimary
  /// Row: space-between, padding 2px vertical
  Widget _metricRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'NotoSansKR',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              height: 14 / 11,
              color: colors.textTertiary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'NotoSansKR',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                height: 14 / 11,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// Paper: lucky items as metric rows with w600 values
  /// Section: "🍀 행운 포인트" title (green), metric rows inside
  Widget _buildLuckyItemsSection(
      BuildContext context, Map<String, dynamic> items) {
    final colors = context.colors;

    // Map known keys to emojis and labels
    final rows = <Widget>[];
    for (final entry in items.entries) {
      final val = fortuneStr(entry.value);
      if (val == null) continue;
      final mapped = _mapLuckyKey(entry.key);
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(mapped.emoji,
                      style: const TextStyle(fontSize: 11, height: 14 / 11)),
                  const SizedBox(width: 4),
                  Text(
                    mapped.label,
                    style: TextStyle(
                      fontFamily: 'NotoSansKR',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      height: 14 / 11,
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
              Flexible(
                child: Text(
                  val,
                  style: TextStyle(
                    fontFamily: 'NotoSansKR',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 14 / 11,
                    color: colors.textPrimary,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return FortuneSectionCard(
      emoji: '🍀',
      title: '행운 포인트',
      titleColor: const Color(0xFF4CAF50),
      child: Column(children: rows),
    );
  }

  /// Paper: body text style — 11px w400, #DDD dark / textSecondary light
  TextStyle _bodyTextStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontFamily: 'NotoSansKR',
      fontSize: 11,
      fontWeight: FontWeight.w400,
      height: 14 / 11,
      color: isDark ? const Color(0xFFDDDDDD) : context.colors.textSecondary,
    );
  }

  /// Map lucky item keys to emoji + display label
  static ({String emoji, String label}) _mapLuckyKey(String key) {
    final k = key.toLowerCase();
    if (k.contains('color') || k.contains('색상')) {
      return (emoji: '🎨', label: '행운 색상');
    }
    if (k.contains('number') || k.contains('숫자')) {
      return (emoji: '🔢', label: '행운 숫자');
    }
    if (k.contains('food') || k.contains('음식')) {
      return (emoji: '🍽️', label: '행운 음식');
    }
    if (k.contains('direction') || k.contains('방향')) {
      return (emoji: '🧭', label: '행운 방향');
    }
    if (k.contains('time') || k.contains('시간')) {
      return (emoji: '⏰', label: '행운 시간');
    }
    if (k.contains('stone') || k.contains('탄생석') || k.contains('보석')) {
      return (emoji: '💎', label: '탄생석');
    }
    if (k.contains('animal') || k.contains('동물')) {
      return (emoji: '🐾', label: '행운 동물');
    }
    if (k.contains('flower') || k.contains('꽃')) {
      return (emoji: '🌸', label: '행운 꽃');
    }
    // Fallback: use key as label
    return (emoji: '✨', label: key);
  }
}
