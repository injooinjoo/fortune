import 'package:flutter/material.dart';

import '../../../../../core/design_system/design_system.dart';
import '_fortune_body_shared.dart';
import '_fortune_visual_components.dart';

/// Body widget for tarot fortune type.
///
/// Paper artboard: F18 (Dark: 53E-1, Light: B04-0)
/// Sections: header → 3-card spread → per-card readings (left-bordered)
///           → overall reading → practice guide → core themes
class TarotFortuneBody extends StatelessWidget {
  final String fortuneType;
  final Map<String, dynamic> componentData;

  const TarotFortuneBody({
    super.key,
    required this.fortuneType,
    required this.componentData,
  });

  // Per-card accent colors (past/present/future)
  static const _pastColor = Color(0xFF4FC3F7);
  static const _presentColor = Color(0xFFFFD54F);
  static const _futureColor = Color(0xFFB388FF);

  @override
  Widget build(BuildContext context) {
    final summary = fortuneStr(componentData['summary']) ??
        fortuneStr(componentData['content']) ??
        '타로 리딩';

    // Card data
    final cards = fortuneMapList(componentData['cards']).isNotEmpty
        ? fortuneMapList(componentData['cards'])
        : fortuneMapList(componentData['tarotCards']).isNotEmpty
            ? fortuneMapList(componentData['tarotCards'])
            : fortuneMapList(componentData['spread']);

    final overallReading = fortuneStr(componentData['overallReading']) ??
        fortuneStr(componentData['readings']);
    final practiceGuide = fortuneStr(componentData['practiceGuide']) ??
        fortuneStr(componentData['guide']);
    final coreThemes = fortuneStrList(componentData['coreThemes']).isNotEmpty
        ? fortuneStrList(componentData['coreThemes'])
        : fortuneStrList(componentData['themes']);
    final focusAreas = fortuneStr(componentData['focusAreas']) ??
        fortuneStr(componentData['focusArea']);
    final validityPeriod = fortuneStr(componentData['validityPeriod']) ??
        fortuneStr(componentData['validity']);
    final luckyItems = fortuneAsMap(componentData['luckyItems']) ??
        fortuneAsMap(componentData['luckyElements']);
    final warnings = fortuneStrList(componentData['warnings']);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    var si = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Paper: centered 🃏 (28px) + "타로 리딩" (13px w600)
        FortuneEmojiHeader(emoji: '🃏', text: summary),

        // Paper: three-card spread in purple-tinted container
        if (cards.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: _buildCardSpread(context, cards, isDark),
          ),
        ],

        // Paper: per-card reading sections with left border
        if (cards.isNotEmpty) ...[
          ...cards.take(3).toList().asMap().entries.map((entry) {
            final i = entry.key;
            final card = entry.value;
            final name = fortuneStr(card['name']) ?? '';
            final emoji = fortuneStr(card['emoji']) ?? '🃏';
            final position = _localizePosition(fortuneStr(card['position']));
            final reading = fortuneStr(card['reading']);
            final keywords = fortuneStrList(card['keywords']);

            if (reading == null && keywords.isEmpty) {
              return const SizedBox.shrink();
            }

            final accentColor = _cardColor(i);

            return Padding(
              padding: const EdgeInsets.only(top: DSSpacing.md),
              child: FortuneStaggeredSection(
                index: si++,
                child: _buildCardReading(
                  context,
                  emoji: emoji,
                  position: position,
                  name: name,
                  reading: reading,
                  keywords: keywords,
                  accentColor: accentColor,
                  isDark: isDark,
                ),
              ),
            );
          }),
        ],

        // Paper: 총합 리딩 — title #FF6B8A pink
        if (overallReading != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '🔮',
              title: '총합 리딩',
              titleColor: const Color(0xFFFF6B8A),
              child: Text(
                overallReading,
                style: TextStyle(
                  fontFamily: 'NotoSansKR',
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  height: 12 / 10,
                  color: isDark
                      ? const Color(0xFFDDDDDD)
                      : context.colors.textSecondary,
                ),
              ),
            ),
          ),
        ],

        // Paper: 실천 가이드 — title #66BB6A green
        if (practiceGuide != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '🌿',
              title: '실천 가이드',
              titleColor: const Color(0xFF66BB6A),
              child: Text(
                practiceGuide,
                style: TextStyle(
                  fontFamily: 'NotoSansKR',
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  height: 12 / 10,
                  color: isDark
                      ? const Color(0xFFDDDDDD)
                      : context.colors.textSecondary,
                ),
              ),
            ),
          ),
        ],

        // Paper: 핵심 테마 — title #B388FF purple, colored pill tags
        if (coreThemes.isNotEmpty ||
            focusAreas != null ||
            validityPeriod != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: _buildCoreThemesSection(
              context,
              themes: coreThemes,
              focusAreas: focusAreas,
              validityPeriod: validityPeriod,
              isDark: isDark,
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

  // ═══ Card Spread Section ═══

  /// Paper: purple-tinted container with 3 card tiles + position labels
  Widget _buildCardSpread(
    BuildContext context,
    List<Map<String, dynamic>> cards,
    bool isDark,
  ) {
    final displayCards = cards.take(3).toList(growable: false);
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _futureColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // Paper: title "🃏 쓰리 카드 스프레드" (11px, #B388FF)
          const Text(
            '🃏 쓰리 카드 스프레드',
            style: TextStyle(
              fontFamily: 'NotoSansKR',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              height: 14 / 11,
              color: _futureColor,
            ),
          ),
          const SizedBox(height: 10),
          // Paper: 3 card tiles in a row, gap 12
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: displayCards.asMap().entries.map((entry) {
              final i = entry.key;
              final card = entry.value;
              final emoji = fortuneStr(card['emoji']) ?? '🃏';
              final name = fortuneStr(card['name']) ?? '';
              final numeral = fortuneStr(card['numeral']) ?? '';
              final accentColor = _cardColor(i);

              return Padding(
                padding: EdgeInsets.only(
                  left: i > 0 ? 12 : 0,
                ),
                child: FortuneCardReveal(
                  index: i,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(emoji,
                            style:
                                const TextStyle(fontSize: 28, height: 34 / 28)),
                        const SizedBox(height: 6),
                        Text(
                          name,
                          style: TextStyle(
                            fontFamily: 'NotoSansKR',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            height: 14 / 11,
                            color: colors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (numeral.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            numeral,
                            style: TextStyle(
                              fontFamily: 'NotoSansKR',
                              fontSize: 8,
                              fontWeight: FontWeight.w400,
                              height: 10 / 8,
                              color: isDark
                                  ? const Color(0xFF888888)
                                  : colors.textTertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(growable: false),
          ),
          const SizedBox(height: 10),
          // Paper: position labels (과거/현재/미래) with gap 24
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: displayCards.asMap().entries.map((entry) {
              final i = entry.key;
              final card = entry.value;
              final position = _localizePosition(fortuneStr(card['position']));
              final isCurrent = i == 1;
              final accentColor = _cardColor(i);

              return Padding(
                padding: EdgeInsets.only(left: i > 0 ? 24 : 0),
                child: Text(
                  position,
                  style: TextStyle(
                    fontFamily: 'NotoSansKR',
                    fontSize: 9,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                    height: 12 / 9,
                    color: isCurrent
                        ? accentColor
                        : (isDark
                            ? const Color(0xFF888888)
                            : context.colors.textTertiary),
                  ),
                ),
              );
            }).toList(growable: false),
          ),
        ],
      ),
    );
  }

  // ═══ Per-Card Reading (Left-bordered) ═══

  /// Paper: left-bordered card reading section
  /// Left border 3px colored, right corners rounded 10px
  /// Title: 12px w600 colored, Body: 10px #DDD, Keywords as colored tags
  Widget _buildCardReading(
    BuildContext context, {
    required String emoji,
    required String position,
    required String name,
    String? reading,
    required List<String> keywords,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        border: Border(
          left: BorderSide(color: accentColor, width: 3),
          top: BorderSide.none,
          right: BorderSide.none,
          bottom: BorderSide.none,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Paper: title "🌙 과거 — The Moon (달)" (12px w600, card color)
          Text(
            '$emoji $position — $name',
            style: TextStyle(
              fontFamily: 'NotoSansKR',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 16 / 12,
              color: accentColor,
            ),
          ),
          if (reading != null) ...[
            const SizedBox(height: 6),
            // Paper: 10px body text
            Text(
              reading,
              style: TextStyle(
                fontFamily: 'NotoSansKR',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                height: 12 / 10,
                color: isDark
                    ? const Color(0xFFDDDDDD)
                    : context.colors.textSecondary,
              ),
            ),
          ],
          if (keywords.isNotEmpty) ...[
            const SizedBox(height: 6),
            // Paper: small colored keyword tags
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: keywords.map((kw) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    kw,
                    style: TextStyle(
                      fontFamily: 'NotoSansKR',
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      height: 12 / 9,
                      color: accentColor,
                    ),
                  ),
                );
              }).toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }

  // ═══ Core Themes Section ═══

  /// Paper: 핵심 테마 with colored pill tags + focus/validity as small text
  Widget _buildCoreThemesSection(
    BuildContext context, {
    required List<String> themes,
    String? focusAreas,
    String? validityPeriod,
    required bool isDark,
  }) {
    // Paper: colored pill tag backgrounds
    const tagColors = [
      Color(0xFFEF5350), // red
      Color(0xFFFFA726), // orange
      Color(0xFF66BB6A), // green
      Color(0xFF42A5F5), // blue
      Color(0xFFB388FF), // purple
    ];

    return FortuneSectionCard(
      emoji: '🎯',
      title: '핵심 테마',
      titleColor: _futureColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (themes.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: themes.asMap().entries.map((entry) {
                final color = tagColors[entry.key % tagColors.length];
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    entry.value,
                    style: const TextStyle(
                      fontFamily: 'NotoSansKR',
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      height: 12 / 10,
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(growable: false),
            ),
          if (focusAreas != null) ...[
            const SizedBox(height: 8),
            Text(
              '집중 영역: $focusAreas',
              style: TextStyle(
                fontFamily: 'NotoSansKR',
                fontSize: 9,
                fontWeight: FontWeight.w400,
                height: 12 / 9,
                color: isDark
                    ? const Color(0xFF888888)
                    : context.colors.textTertiary,
              ),
            ),
          ],
          if (validityPeriod != null) ...[
            const SizedBox(height: 4),
            Text(
              '유효 기간: $validityPeriod',
              style: TextStyle(
                fontFamily: 'NotoSansKR',
                fontSize: 9,
                fontWeight: FontWeight.w400,
                height: 12 / 9,
                color: isDark
                    ? const Color(0xFF888888)
                    : context.colors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══ Helpers ═══

  /// Get accent color for card position index
  static Color _cardColor(int index) {
    switch (index) {
      case 0:
        return _pastColor;
      case 1:
        return _presentColor;
      case 2:
        return _futureColor;
      default:
        return _futureColor;
    }
  }

  /// Translate position keys to Korean labels
  static String _localizePosition(String? position) {
    switch (position?.toLowerCase()) {
      case 'past':
        return '과거';
      case 'present':
        return '현재';
      case 'future':
        return '미래';
      default:
        return position ?? '';
    }
  }
}
