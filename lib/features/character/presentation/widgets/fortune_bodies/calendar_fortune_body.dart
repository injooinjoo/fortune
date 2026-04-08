import 'package:flutter/material.dart';

import '../../../../../core/design_system/design_system.dart';
import '_fortune_body_shared.dart';
import '_fortune_visual_components.dart';

/// Body widget for 만세력 (manseryeok/calendar fortune) types.
///
/// Paper artboard: F02 (Dark: 45A-1, Light: A6W-0)
class CalendarFortuneBody extends StatelessWidget {
  final String fortuneType;
  final Map<String, dynamic> componentData;

  const CalendarFortuneBody({
    super.key,
    required this.fortuneType,
    required this.componentData,
  });

  @override
  Widget build(BuildContext context) {
    final summary = fortuneStr(componentData['summary']) ??
        fortuneStr(componentData['content']) ??
        '만세력을 분석했어요.';
    final solarDate = fortuneStr(componentData['solarDate']);
    final lunarDate = fortuneStr(componentData['lunarDate']);
    final time = fortuneStr(componentData['time']);
    final seasonalTerm = fortuneAsMap(componentData['seasonalTerm']);
    final zodiacAnimal = fortuneStr(componentData['zodiacAnimal']);
    final age = fortuneStr(componentData['age']);
    final daewoon = fortuneStr(componentData['daewoon']);
    final tips = fortuneStrList(componentData['tips']);
    final highlights = fortuneStrList(componentData['highlights']);
    final recommendations = fortuneStrList(componentData['recommendations']);
    final warnings = fortuneStrList(componentData['warnings']);

    // Paper: 절기 section uses metric rows without emoji prefix
    final jeolgiName = fortuneStr(seasonalTerm?['name']);
    final wolgeon = fortuneStr(seasonalTerm?['wolgeon'] ?? seasonalTerm?['월건']);
    final iljin = fortuneStr(seasonalTerm?['iljin'] ?? seasonalTerm?['일진']);
    final napeum = fortuneStr(seasonalTerm?['napeum'] ?? seasonalTerm?['납음']);
    final period = fortuneStr(seasonalTerm?['period']);
    final meaning = fortuneStr(seasonalTerm?['meaning']);
    final advice = fortuneStr(seasonalTerm?['advice']);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Paper: light mode sections use salmon pink #FFF5F5
    final sectionBg =
        isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFFFF5F5);

    var si = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Paper: centered 📅 emoji (28px) + "만세력 (萬歲曆)" title (13px w600)
        FortuneEmojiHeader(emoji: '📅', text: summary),

        if (highlights.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          Center(child: FortuneTagPillWrap(tags: highlights)),
        ],

        // Paper: 3-column date section (양력 | 음력 | 시간)
        // bg: white@6% dark / #FFF5F5 light, radius: 10, padding: 14
        if (solarDate != null || lunarDate != null || time != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: _buildDateColumnsSection(context,
                solarDate: solarDate, lunarDate: lunarDate, time: time),
          ),
        ],

        // Paper: 절기 정보 section — title #B388FF purple
        if (seasonalTerm != null && seasonalTerm.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: _buildJeolgiSection(
              context,
              jeolgiName: jeolgiName,
              wolgeon: wolgeon,
              iljin: iljin,
              napeum: napeum,
              period: period,
              meaning: meaning,
              advice: advice,
              sectionBg: sectionBg,
            ),
          ),
        ],

        // Paper: 띠 · 나이 section — title #FF9800 orange
        if (zodiacAnimal != null || age != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: _buildZodiacAgeSection(
              context,
              zodiacAnimal: zodiacAnimal,
              age: age,
              daewoon: daewoon,
              sectionBg: sectionBg,
            ),
          ),
        ],

        // Paper: tip box — bg #FFD7401A, radius 8, padding 10, text 10px
        if (tips.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: _buildTipBox(context, tips.join('\n')),
          ),
        ],

        // Recommendations (only if present in data)
        if (recommendations.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '✅',
              title: '추천',
              backgroundColor: sectionBg,
              child: FortuneBulletList(items: recommendations, bullet: '📅'),
            ),
          ),
        ],

        // Warnings (only if present in data)
        if (warnings.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '⚠️',
              title: '주의',
              backgroundColor: sectionBg,
              child: FortuneBulletList(
                  items: warnings, bullet: '⚠️', isWarning: true),
            ),
          ),
        ],
      ],
    );
  }

  /// Paper: 3-column date display (양력 | 음력 | 시간)
  /// Each column: label 9px #888/#98A0B1 on top, value 14px w700 below
  /// Container: bg white@6%/#FFF5F5, radius 10, padding 14
  Widget _buildDateColumnsSection(
    BuildContext context, {
    String? solarDate,
    String? lunarDate,
    String? time,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFFFF5F5);
    final labelColor =
        isDark ? const Color(0xFF888888) : const Color(0xFF98A0B1);
    final valueColor = isDark ? Colors.white : const Color(0xFF0B0B10);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (solarDate != null)
            Expanded(
              child: _dateColumn(
                context,
                label: '양력',
                value: solarDate,
                labelColor: labelColor,
                valueColor: valueColor,
              ),
            ),
          if (lunarDate != null)
            Expanded(
              child: _dateColumn(
                context,
                label: '음력',
                value: lunarDate,
                labelColor: labelColor,
                valueColor: valueColor,
              ),
            ),
          if (time != null)
            Expanded(
              child: _dateColumn(
                context,
                label: '시간',
                value: time,
                labelColor: labelColor,
                valueColor: valueColor,
              ),
            ),
        ],
      ),
    );
  }

  /// Single date column: small label on top, bold value below
  Widget _dateColumn(
    BuildContext context, {
    required String label,
    required String value,
    required Color labelColor,
    required Color valueColor,
  }) {
    return Column(
      children: [
        // Paper: 9px label
        Text(
          label,
          style: TextStyle(
            fontFamily: 'NotoSansKR',
            fontSize: 9,
            fontWeight: FontWeight.w400,
            height: 12 / 9,
            color: labelColor,
          ),
        ),
        const SizedBox(height: DSSpacing.xs), // 4px gap
        // Paper: 14px w700 value
        Text(
          value,
          style: TextStyle(
            fontFamily: 'NotoSansKR',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 18 / 14,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  /// Paper: 절기 정보 section
  /// Title: "🏛 절기 정보" in #B388FF, 12px
  /// Rows: label 11px #AAA/#666, value 11px white/#0B0B10, padding 2px
  Widget _buildJeolgiSection(
    BuildContext context, {
    String? jeolgiName,
    String? wolgeon,
    String? iljin,
    String? napeum,
    String? period,
    String? meaning,
    String? advice,
    required Color sectionBg,
  }) {
    return FortuneSectionCard(
      emoji: '🏛',
      title: '절기 정보',
      titleColor: const Color(0xFFB388FF),
      backgroundColor: sectionBg,
      child: Column(
        children: [
          if (jeolgiName != null)
            _metricRow(context, label: '절기', value: jeolgiName),
          if (wolgeon != null) _metricRow(context, label: '월건', value: wolgeon),
          if (iljin != null) _metricRow(context, label: '일진', value: iljin),
          if (napeum != null) _metricRow(context, label: '납음', value: napeum),
          if (period != null) _metricRow(context, label: '기간', value: period),
          if (meaning != null) ...[
            const SizedBox(height: DSSpacing.xs),
            Text(
              meaning,
              style: context.bodySmall.copyWith(
                color: context.colors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
          if (advice != null) ...[
            const SizedBox(height: DSSpacing.sm),
            _buildTipBox(context, advice),
          ],
        ],
      ),
    );
  }

  /// Paper: 띠 · 나이 section
  /// Title: "🐴 띠 · 나이" in #FF9800, 12px
  Widget _buildZodiacAgeSection(
    BuildContext context, {
    String? zodiacAnimal,
    String? age,
    String? daewoon,
    required Color sectionBg,
  }) {
    return FortuneSectionCard(
      emoji: '🐴',
      title: '띠 · 나이',
      titleColor: const Color(0xFFFF9800),
      backgroundColor: sectionBg,
      child: Column(
        children: [
          if (zodiacAnimal != null)
            _metricRow(context, label: '띠', value: zodiacAnimal),
          if (age != null) _metricRow(context, label: '만 나이', value: age),
          if (daewoon != null) _metricRow(context, label: '대운', value: daewoon),
        ],
      ),
    );
  }

  /// Paper-matched metric row without emoji.
  /// Label: 11px w400, #AAA dark / #666 light (textTertiary)
  /// Value: 11px w400, white dark / #0B0B10 light (textPrimary)
  /// Row padding: 2px vertical
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

  /// Paper: tip box — bg #FFD7401A (gold 10% alpha), radius 8, padding 10
  /// Emoji: 💡 10px, Text: 10px #FFFFFFB3 dark / #444 light
  Widget _buildTipBox(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? Colors.white.withValues(alpha: 0.7) // #FFFFFFB3
        : const Color(0xFF444444);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD740).withValues(alpha: 0.1), // #FFD7401A
        borderRadius: BorderRadius.circular(DSRadius.smd), // 8px
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 10, height: 14 / 10)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'NotoSansKR',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                height: 14 / 10,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
