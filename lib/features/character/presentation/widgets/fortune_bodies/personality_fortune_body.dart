import 'package:flutter/material.dart';

import '../../../../../core/design_system/design_system.dart';
import '_fortune_body_shared.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FortuneEmojiHeader(emoji: '🧠', text: summary),

        // Dimension pairs
        if (dimensions.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          ...dimensions.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: DSSpacing.sm),
                child: _buildDimensionCard(context, d),
              )),
        ],

        // Today's trap
        if (todayTrap != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneTipCard(emoji: '🚨', text: '오늘의 함정: $todayTrap'),
        ],

        // Lucky info
        if (luckyColor != null || luckyNumber != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneSectionCard(
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
        ],

        if (luckyItems != null && luckyItems.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneLuckyItemGrid(items: luckyItems),
        ],

        if (recommendations.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneSectionCard(
            emoji: '💡',
            title: '추천',
            child: FortuneBulletList(items: recommendations, bullet: '🧠'),
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
              FortuneProgressBar(label: dim.keyA, score: scoreA, emoji: '🔵'),
            if (scoreB != null)
              FortuneProgressBar(label: dim.keyB, score: scoreB, emoji: '🟣'),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FortuneEmojiHeader(emoji: '📊', text: assessment ?? summary),

        // Three rate bars
        if (physical != null || emotional != null || intellectual != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneSectionCard(
            emoji: '📈',
            title: '바이오리듬 지표',
            child: Column(
              children: [
                if (physical != null)
                  FortuneProgressBar(label: '신체', score: physical, emoji: '💪'),
                if (emotional != null)
                  FortuneProgressBar(
                      label: '감정', score: emotional, emoji: '💜'),
                if (intellectual != null)
                  FortuneProgressBar(
                      label: '지성', score: intellectual, emoji: '🧠'),
              ],
            ),
          ),
        ],

        if (bestTime != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneTipCard(emoji: '⏰', text: '최적의 시간: $bestTime'),
        ],

        // Weekly forecast
        if (weeklyForecast != null) ...[
          const SizedBox(height: DSSpacing.md),
          _buildWeeklyForecast(context, weeklyForecast),
        ],

        // Important dates
        if (importantDates.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneSectionCard(
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
        ],

        // Lifestyle advice
        if (lifestyleAdvice != null) ...[
          const SizedBox(height: DSSpacing.md),
          _buildLifestyleAdvice(context, lifestyleAdvice),
        ],

        // Health tips
        if (healthTips != null) ...[
          const SizedBox(height: DSSpacing.md),
          _buildHealthTips(context, healthTips),
        ],

        if (luckyItems != null && luckyItems.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneLuckyItemGrid(items: luckyItems),
        ],

        if (recommendations.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneSectionCard(
            emoji: '💡',
            title: '추천',
            child: FortuneBulletList(items: recommendations, bullet: '📊'),
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
      emoji: '🏥',
      title: '건강 팁',
      child: FortuneBulletList(items: items, bullet: ''),
    );
  }

  // ═══ Generic (personality-dna etc.) ═══

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
