import 'package:flutter/material.dart';

import '../../../../../core/design_system/design_system.dart';
import '_fortune_body_shared.dart';
import '_fortune_visual_components.dart';

/// Body widget for personality/self fortune types:
/// mbti, biorhythm, personality-dna
class PersonalityFortuneBody extends StatelessWidget {
  final String fortuneType;
  final Map<String, dynamic> componentData;

  const PersonalityFortuneBody({
    super.key,
    required this.fortuneType,
    required this.componentData,
  });

  @override
  Widget build(BuildContext context) {
    switch (fortuneType) {
      case 'mbti':
        return _buildMbtiBody(context);
      case 'biorhythm':
        return _buildBiorhythmBody(context);
      case 'personality-dna':
        return _buildPersonalityDnaBody(context);
      default:
        return _buildGenericBody(context, emoji: '🧬');
    }
  }

  // ═══ MBTI ═══

  Widget _buildMbtiBody(BuildContext context) {
    final summary = fortuneStr(componentData['summary']) ??
        fortuneStr(componentData['content']) ??
        'MBTI 운세를 분석했어요.';
    final todayTrap = fortuneStr(componentData['todayTrap']);
    final meta = fortuneAsMap(componentData['_meta']);
    final luckyColor = fortuneStr(componentData['luckyColor']) ??
        fortuneStr(meta?['luckyColor']);
    final luckyNumber = fortuneStr(componentData['luckyNumber']?.toString()) ??
        fortuneStr(meta?['luckyNumber']?.toString());
    final luckyItems = fortuneAsMap(componentData['luckyItems']);
    final recommendations = fortuneStrList(componentData['recommendations']);
    final warnings = fortuneStrList(componentData['warnings']);

    // MBTI dimension pairs
    final dimensions = <_MbtiDimension>[];
    _addDimension(dimensions, 'E', 'I', '외향', '내향');
    _addDimension(dimensions, 'N', 'S', '직관', '감각');
    _addDimension(dimensions, 'T', 'F', '사고', '감정');
    _addDimension(dimensions, 'J', 'P', '판단', '인식');

    var si = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FortuneEmojiHeader(emoji: '🧠', text: summary),

        // Dimension pairs
        if (dimensions.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          ...dimensions.map((d) => FortuneStaggeredSection(
                index: si++,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: DSSpacing.sm),
                  child: _buildDimensionCard(context, d),
                ),
              )),
        ],

        // Today's trap
        if (todayTrap != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneTipCard(emoji: '🚨', text: '오늘의 함정: $todayTrap'),
          ),
        ],

        // Lucky info
        if (luckyColor != null || luckyNumber != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '🍀',
              title: '행운 포인트',
              child: Column(
                children: [
                  if (luckyColor != null)
                    FortuneMetricRow(
                        emoji: '🎨', label: '행운 색상', value: luckyColor),
                  if (luckyNumber != null)
                    FortuneMetricRow(
                        emoji: '🔢', label: '행운 숫자', value: luckyNumber),
                ],
              ),
            ),
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
              emoji: '💡',
              title: '추천',
              child: FortuneBulletList(items: recommendations, bullet: '🧠'),
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

  void _addDimension(List<_MbtiDimension> list, String a, String b,
      String aLabel, String bLabel) {
    final dataA = fortuneAsMap(componentData[a]);
    final dataB = fortuneAsMap(componentData[b]);
    if (dataA != null || dataB != null) {
      list.add(_MbtiDimension(
        keyA: a,
        keyB: b,
        labelA: aLabel,
        labelB: bLabel,
        dataA: dataA ?? {},
        dataB: dataB ?? {},
      ));
    }
  }

  Widget _buildDimensionCard(BuildContext context, _MbtiDimension dim) {
    final colors = context.colors;
    final scoreA = fortuneInt(dim.dataA['score']);
    final scoreB = fortuneInt(dim.dataB['score']);
    final fortuneA = fortuneStr(dim.dataA['fortune']);
    final fortuneB = fortuneStr(dim.dataB['fortune']);
    final tipA = fortuneStr(dim.dataA['tip']);
    final tipB = fortuneStr(dim.dataB['tip']);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(color: colors.border.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: A vs B
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _mbtiLabel(context, dim.keyA, dim.labelA, true),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm),
                child: Text('vs',
                    style: context.labelSmall.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w800)),
              ),
              _mbtiLabel(context, dim.keyB, dim.labelB, false),
            ],
          ),
          // Score bars
          if (scoreA != null || scoreB != null) ...[
            const SizedBox(height: DSSpacing.sm),
            if (scoreA != null)
              FortuneAnimatedProgressBar(
                  label: dim.keyA, score: scoreA, emoji: '🔵', staggerIndex: 0),
            if (scoreB != null)
              FortuneAnimatedProgressBar(
                  label: dim.keyB, score: scoreB, emoji: '🟣', staggerIndex: 1),
          ],
          // Fortune text
          if (fortuneA != null || fortuneB != null) ...[
            const SizedBox(height: DSSpacing.xs),
            if (fortuneA != null)
              Text('${dim.keyA}: $fortuneA',
                  style: context.bodySmall.copyWith(height: 1.55)),
            if (fortuneB != null)
              Text('${dim.keyB}: $fortuneB',
                  style: context.bodySmall.copyWith(height: 1.55)),
          ],
          // Tips
          if (tipA != null || tipB != null) ...[
            const SizedBox(height: DSSpacing.xs),
            if (tipA != null)
              Text('💡 ${dim.keyA}: $tipA',
                  style: context.labelSmall
                      .copyWith(color: colors.textSecondary, height: 1.4)),
            if (tipB != null)
              Text('💡 ${dim.keyB}: $tipB',
                  style: context.labelSmall
                      .copyWith(color: colors.textSecondary, height: 1.4)),
          ],
        ],
      ),
    );
  }

  Widget _mbtiLabel(
      BuildContext context, String key, String label, bool isLeft) {
    return Column(
      children: [
        Text(key,
            style: context.headingSmall.copyWith(fontWeight: FontWeight.w800)),
        Text(label,
            style: context.labelSmall
                .copyWith(color: context.colors.textSecondary)),
      ],
    );
  }

  // ═══ Biorhythm (바이오리듬) ═══

  Widget _buildBiorhythmBody(BuildContext context) {
    final summary = fortuneStr(componentData['summary']) ??
        fortuneStr(componentData['content']) ??
        '바이오리듬을 분석했어요.';
    final status = fortuneAsMap(componentData['currentStatus']) ??
        fortuneAsMap(componentData['current_status']);
    final weeklyForecast = fortuneAsMap(componentData['weeklyForecast']) ??
        fortuneAsMap(componentData['weekly_forecast']);
    final importantDates = fortuneMapList(componentData['importantDates']) +
        fortuneMapList(componentData['important_dates']);
    final lifestyleAdvice = fortuneAsMap(componentData['lifestyleAdvice']) ??
        fortuneAsMap(componentData['lifestyle_advice']);
    final healthTips = fortuneAsMap(componentData['healthTips']) ??
        fortuneAsMap(componentData['health_tips']);
    final luckyItems = fortuneAsMap(componentData['luckyItems']);
    final recommendations = fortuneStrList(componentData['recommendations']);
    final warnings = fortuneStrList(componentData['warnings']);

    final physical =
        fortuneInt(status?['physical_rate'] ?? status?['physicalRate']);
    final emotional =
        fortuneInt(status?['emotional_rate'] ?? status?['emotionalRate']);
    final intellectual =
        fortuneInt(status?['intellectual_rate'] ?? status?['intellectualRate']);
    final assessment = fortuneStr(
        status?['overall_assessment'] ?? status?['overallAssessment']);
    final bestTime = fortuneStr(status?['best_time'] ?? status?['bestTime']);

    var si = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FortuneEmojiHeader(emoji: '📊', text: assessment ?? summary),

        // Three rate bars
        if (physical != null || emotional != null || intellectual != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '📈',
              title: '바이오리듬 지표',
              child: Column(
                children: [
                  if (physical != null)
                    FortuneAnimatedProgressBar(
                        label: '신체',
                        score: physical,
                        emoji: '💪',
                        staggerIndex: 0),
                  if (emotional != null)
                    FortuneAnimatedProgressBar(
                        label: '감정',
                        score: emotional,
                        emoji: '💜',
                        staggerIndex: 1),
                  if (intellectual != null)
                    FortuneAnimatedProgressBar(
                        label: '지성',
                        score: intellectual,
                        emoji: '🧠',
                        staggerIndex: 2),
                ],
              ),
            ),
          ),
        ],

        if (bestTime != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneTipCard(emoji: '⏰', text: '최적의 시간: $bestTime'),
          ),
        ],

        // Weekly forecast
        if (weeklyForecast != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: _buildWeeklyForecast(context, weeklyForecast),
          ),
        ],

        // Important dates
        if (importantDates.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '📅',
              title: '중요 날짜',
              child: Column(
                children: importantDates.take(3).map((d) {
                  final date = fortuneStr(d['date']) ?? '';
                  final type = fortuneStr(d['type']) ?? '';
                  final desc = fortuneStr(d['description']) ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                    child: FortuneMetricRow(
                      emoji: type == 'positive' ? '🟢' : '🟡',
                      label: date,
                      value: desc,
                    ),
                  );
                }).toList(growable: false),
              ),
            ),
          ),
        ],

        // Lifestyle advice
        if (lifestyleAdvice != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: _buildLifestyleAdvice(context, lifestyleAdvice),
          ),
        ],

        // Health tips
        if (healthTips != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: _buildHealthTips(context, healthTips),
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
              emoji: '💡',
              title: '추천',
              child: FortuneBulletList(items: recommendations, bullet: '📊'),
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

  Widget _buildWeeklyForecast(
      BuildContext context, Map<String, dynamic> forecast) {
    final bestDay = fortuneStr(forecast['best_day'] ?? forecast['bestDay']);
    final worstDay = fortuneStr(forecast['worst_day'] ?? forecast['worstDay']);
    final overview = fortuneStr(forecast['overview']);
    final advice =
        fortuneStr(forecast['weekly_advice'] ?? forecast['weeklyAdvice']);

    return FortuneSectionCard(
      emoji: '📅',
      title: '주간 전망',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bestDay != null)
            FortuneMetricRow(emoji: '🟢', label: '최고의 날', value: bestDay),
          if (worstDay != null)
            FortuneMetricRow(emoji: '🔴', label: '주의할 날', value: worstDay),
          if (overview != null) ...[
            const SizedBox(height: DSSpacing.xs),
            Text(overview, style: context.bodySmall.copyWith(height: 1.6)),
          ],
          if (advice != null) ...[
            const SizedBox(height: DSSpacing.sm),
            FortuneTipCard(emoji: '💡', text: advice),
          ],
        ],
      ),
    );
  }

  Widget _buildLifestyleAdvice(
      BuildContext context, Map<String, dynamic> advice) {
    final items = <String>[];
    final sleep = fortuneStr(advice['sleep_pattern'] ?? advice['sleepPattern']);
    final exercise =
        fortuneStr(advice['exercise_timing'] ?? advice['exerciseTiming']);
    final nutrition =
        fortuneStr(advice['nutrition_tip'] ?? advice['nutritionTip']);
    final stress =
        fortuneStr(advice['stress_management'] ?? advice['stressManagement']);
    if (sleep != null) items.add('😴 수면: $sleep');
    if (exercise != null) items.add('🏃 운동: $exercise');
    if (nutrition != null) items.add('🥗 영양: $nutrition');
    if (stress != null) items.add('🧘 스트레스: $stress');
    if (items.isEmpty) return const SizedBox.shrink();

    return FortuneSectionCard(
      emoji: '🌿',
      title: '라이프스타일 조언',
      child: FortuneBulletList(items: items, bullet: ''),
    );
  }

  Widget _buildHealthTips(BuildContext context, Map<String, dynamic> tips) {
    final items = <String>[];
    final physical =
        fortuneStr(tips['physical_health'] ?? tips['physicalHealth']);
    final mental = fortuneStr(tips['mental_health'] ?? tips['mentalHealth']);
    final boost = fortuneStr(tips['energy_boost'] ?? tips['energyBoost']);
    final warning = fortuneStr(tips['warning_signs'] ?? tips['warningSign']);
    if (physical != null) items.add('💪 신체: $physical');
    if (mental != null) items.add('🧠 정신: $mental');
    if (boost != null) items.add('⚡ 에너지: $boost');
    if (warning != null) items.add('⚠️ 주의: $warning');
    if (items.isEmpty) return const SizedBox.shrink();

    return FortuneSectionCard(
      emoji: '🌿',
      title: '생활 습관 팁',
      child: FortuneBulletList(items: items, bullet: ''),
    );
  }

  // ═══ Personality DNA (성격운) ═══

  Widget _buildPersonalityDnaBody(BuildContext context) {
    final colors = context.colors;

    // Extract data
    final summary = fortuneStr(componentData['summary']) ??
        fortuneStr(componentData['content']) ??
        '오늘의 성격운을 분석했어요.';
    final personalityType = fortuneStr(componentData['personalityType']) ??
        fortuneStr(componentData['personality_type']) ??
        fortuneStr(componentData['mbtiType']) ??
        fortuneStr(componentData['type']);
    final personalityTitle = fortuneStr(componentData['personalityTitle']) ??
        fortuneStr(componentData['personality_title']) ??
        fortuneStr(componentData['typeTitle']);
    final todayInsight = fortuneStr(componentData['todayInsight']) ??
        fortuneStr(componentData['today_insight']) ??
        fortuneStr(componentData['insight']);
    final growthTip = fortuneStr(componentData['growthTip']) ??
        fortuneStr(componentData['growth_tip']);

    // Dimension spectrum (E/I, N/S, T/F, J/P)
    final dimensionSpectrum =
        fortuneAsMap(componentData['dimensionSpectrum']) ??
            fortuneAsMap(componentData['dimension_spectrum']);

    // Traits (4 trait cards)
    final traits = fortuneMapList(componentData['traits']);

    // Compatibility
    final compatibility = fortuneAsMap(componentData['compatibility']) ??
        fortuneAsMap(componentData['chemistryMatch']);
    final bestMatch = fortuneAsMap(compatibility?['best']) ??
        fortuneAsMap(compatibility?['bestMatch']);
    final goodMatch = fortuneAsMap(compatibility?['good']) ??
        fortuneAsMap(compatibility?['goodMatch']);

    // Lucky items
    final luckyItems = fortuneAsMap(componentData['luckyItems']);
    final recommendations = fortuneStrList(componentData['recommendations']);
    final warnings = fortuneStrList(componentData['warnings']);

    // Spectrum dimension pairs
    final spectrumPairs = <_SpectrumDimension>[];
    _addSpectrumDimension(
        spectrumPairs, dimensionSpectrum, 'E', 'I', '외향', '내향');
    _addSpectrumDimension(
        spectrumPairs, dimensionSpectrum, 'N', 'S', '직관', '감각');
    _addSpectrumDimension(
        spectrumPairs, dimensionSpectrum, 'T', 'F', '사고', '감정');
    _addSpectrumDimension(
        spectrumPairs, dimensionSpectrum, 'J', 'P', '판단', '인식');

    final spectrumColors = [
      colors.chipPeach,
      colors.success,
      colors.accentSecondary,
      colors.info,
    ];

    var si = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        FortuneEmojiHeader(emoji: '✨', text: summary),

        // Hero card: personality type + title
        if (personalityType != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: _buildPersonalityHeroCard(
              context,
              personalityType,
              personalityTitle,
            ),
          ),
        ],

        // Dimension spectrum bars
        if (spectrumPairs.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '📊',
              title: '차원 스펙트럼',
              child: Column(
                children: spectrumPairs.asMap().entries.map((entry) {
                  final i = entry.key;
                  final dim = entry.value;
                  final barColor = i < spectrumColors.length
                      ? spectrumColors[i]
                      : colors.accent;
                  return _buildSpectrumBar(context, dim, barColor, i);
                }).toList(growable: false),
              ),
            ),
          ),
        ],

        // Trait cards in 2x2 grid
        if (traits.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneInfoGraphGrid(
              items: traits.take(4).map((t) {
                final emoji = fortuneStr(t['emoji']) ?? '🧩';
                final label =
                    fortuneStr(t['name']) ?? fortuneStr(t['label']) ?? '';
                final desc = fortuneStr(t['description']) ??
                    fortuneStr(t['value']) ??
                    '';
                return FortuneInfoGraphItem(
                  icon: emoji,
                  label: label,
                  value: desc,
                );
              }).toList(growable: false),
            ),
          ),
        ],

        // Today's insight
        if (todayInsight != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '💡',
              title: '오늘의 인사이트',
              child: Text(
                todayInsight,
                style: context.bodySmall.copyWith(height: 1.6),
              ),
            ),
          ),
        ],

        // Compatibility cards
        if (bestMatch != null || goodMatch != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneComparisonCard(
              leftTitle: fortuneStr(bestMatch?['type']) ?? '최고 궁합',
              rightTitle: fortuneStr(goodMatch?['type']) ?? '좋은 궁합',
              leftEmoji: '💕',
              rightEmoji: '🤝',
              leftItems: [
                if (fortuneStr(bestMatch?['name']) != null)
                  fortuneStr(bestMatch!['name'])!,
                if (fortuneStr(bestMatch?['description']) != null)
                  fortuneStr(bestMatch!['description'])!,
                if (fortuneStr(bestMatch?['reason']) != null)
                  fortuneStr(bestMatch!['reason'])!,
              ],
              rightItems: [
                if (fortuneStr(goodMatch?['name']) != null)
                  fortuneStr(goodMatch!['name'])!,
                if (fortuneStr(goodMatch?['description']) != null)
                  fortuneStr(goodMatch!['description'])!,
                if (fortuneStr(goodMatch?['reason']) != null)
                  fortuneStr(goodMatch!['reason'])!,
              ],
              leftColor: colors.success,
              rightColor: colors.info,
            ),
          ),
        ],

        // Growth tip
        if (growthTip != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneTipCard(emoji: '🌱', text: growthTip),
          ),
        ],

        // Lucky items
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

  /// Hero card showing personality type (e.g. "ENFP") and title
  Widget _buildPersonalityHeroCard(
    BuildContext context,
    String type,
    String? title,
  ) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DSRadius.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.success.withValues(alpha: context.isDark ? 0.18 : 0.10),
            colors.surface,
          ],
        ),
        border: Border.all(color: colors.success.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text(
            type,
            style: context.typography.displayLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.success,
              height: 1.1,
              letterSpacing: 2,
            ),
          ),
          if (title != null) ...[
            const SizedBox(height: DSSpacing.xs),
            Text(
              title,
              style: context.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  void _addSpectrumDimension(
    List<_SpectrumDimension> list,
    Map<String, dynamic>? spectrum,
    String keyA,
    String keyB,
    String labelA,
    String labelB,
  ) {
    if (spectrum == null) return;
    final scoreA =
        fortuneInt(spectrum[keyA]) ?? fortuneInt(spectrum[keyA.toLowerCase()]);
    final scoreB =
        fortuneInt(spectrum[keyB]) ?? fortuneInt(spectrum[keyB.toLowerCase()]);
    if (scoreA != null || scoreB != null) {
      list.add(_SpectrumDimension(
        keyA: keyA,
        keyB: keyB,
        labelA: labelA,
        labelB: labelB,
        scoreA: scoreA ?? (scoreB != null ? 100 - scoreB : 50),
        scoreB: scoreB ?? (scoreA != null ? 100 - scoreA : 50),
      ));
    }
  }

  Widget _buildSpectrumBar(
    BuildContext context,
    _SpectrumDimension dim,
    Color barColor,
    int staggerIndex,
  ) {
    final colors = context.colors;
    final fractionA = (dim.scoreA / 100).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.md),
      child: Column(
        children: [
          // Labels row: A label (left) ... B label (right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${dim.keyA} ${dim.labelA} ${dim.scoreA}%',
                style: context.labelSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: barColor,
                ),
              ),
              Text(
                '${dim.scoreB}% ${dim.labelB} ${dim.keyB}',
                style: context.labelSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.xxs),
          // Dual bar
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: colors.border.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(5),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: constraints.maxWidth * fractionA,
                        height: 10,
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: barColor.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ═══ Generic ═══

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

class _MbtiDimension {
  final String keyA, keyB, labelA, labelB;
  final Map<String, dynamic> dataA, dataB;
  _MbtiDimension({
    required this.keyA,
    required this.keyB,
    required this.labelA,
    required this.labelB,
    required this.dataA,
    required this.dataB,
  });
}

class _SpectrumDimension {
  final String keyA, keyB, labelA, labelB;
  final int scoreA, scoreB;
  _SpectrumDimension({
    required this.keyA,
    required this.keyB,
    required this.labelA,
    required this.labelB,
    required this.scoreA,
    required this.scoreB,
  });
}
