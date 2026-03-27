import 'package:flutter/material.dart';

import '../../../../../core/design_system/design_system.dart';
import '../../utils/fortune_key_localizer.dart';
import '_fortune_body_shared.dart';
import '_fortune_visual_components.dart';

/// Body widget for wealth/lucky fortune types:
/// wealth, lucky-items, lotto
class WealthFortuneBody extends StatelessWidget {
  final String fortuneType;
  final Map<String, dynamic> componentData;

  const WealthFortuneBody({
    super.key,
    required this.fortuneType,
    required this.componentData,
  });

  @override
  Widget build(BuildContext context) {
    switch (fortuneType) {
      case 'lucky-items':
        return _buildLuckyItemsBody(context);
      case 'lotto':
        return _buildLottoBody(context);
      case 'wealth':
      default:
        return _buildWealthBody(context);
    }
  }

  // ═══ Wealth (재물운) ═══

  Widget _buildWealthBody(BuildContext context) {
    final summary = fortuneStr(componentData['summary']) ??
        fortuneStr(componentData['content']) ??
        '재물운을 분석했어요.';
    final wealthPotential = fortuneStr(componentData['wealthPotential']);
    final elementAnalysis = fortuneAsMap(componentData['elementAnalysis']);
    final goalAdvice = fortuneAsMap(componentData['goalAdvice']);
    final cashflowInsight = fortuneAsMap(componentData['cashflowInsight']);
    final investmentInsights =
        fortuneAsMap(componentData['investmentInsights']);
    final monthlyFlow = fortuneMapList(componentData['monthlyFlow']);
    final actionItems = fortuneStrList(componentData['actionItems']);
    final luckyItems = fortuneAsMap(componentData['luckyItems']) ??
        fortuneAsMap(componentData['luckyElements']);
    final recommendations = fortuneStrList(componentData['recommendations']);
    final warnings = fortuneStrList(componentData['warnings']);

    var si = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FortuneEmojiHeader(emoji: '💰', text: summary),

        if (wealthPotential != null) ...[
          const SizedBox(height: DSSpacing.sm),
          Center(child: FortuneTagPillWrap(tags: [wealthPotential])),
        ],

        // Element analysis
        if (elementAnalysis != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: _buildElementCard(context, elementAnalysis),
          ),
        ],

        // Goal advice
        if (goalAdvice != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: _buildGoalCard(context, goalAdvice),
          ),
        ],

        // Cashflow insight
        if (cashflowInsight != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: _buildCashflowCard(context, cashflowInsight),
          ),
        ],

        // Investment insights
        if (investmentInsights != null && investmentInsights.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: _buildInvestmentGrid(context, investmentInsights),
          ),
        ],

        // Monthly flow
        if (monthlyFlow.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: _buildMonthlyFlow(context, monthlyFlow),
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

        // Action items
        if (actionItems.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '✅',
              title: '액션 아이템',
              child: FortuneBulletList(items: actionItems, bullet: '💫'),
            ),
          ),
        ],

        if (recommendations.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '💡',
              title: '추천',
              child: FortuneBulletList(items: recommendations, bullet: '💰'),
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

  Widget _buildElementCard(
      BuildContext context, Map<String, dynamic> analysis) {
    final dominant = fortuneStr(analysis['dominantElement']);
    final wealth = fortuneStr(analysis['wealthElement']);
    final compat = fortuneInt(analysis['compatibility']);
    final insight = fortuneStr(analysis['insight']);

    return FortuneSectionCard(
      emoji: '📊',
      title: '오행 분석',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (dominant != null)
            FortuneMetricRow(emoji: '🔥', label: '주요 기운', value: dominant),
          if (wealth != null)
            FortuneMetricRow(emoji: '💎', label: '재물 기운', value: wealth),
          if (compat != null)
            FortuneAnimatedProgressBar(
                label: '조화도', score: compat, emoji: '☯️'),
          if (insight != null) ...[
            const SizedBox(height: DSSpacing.xs),
            Text(
              insight,
              style: context.bodySmall
                  .copyWith(color: context.colors.textSecondary, height: 1.6),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, Map<String, dynamic> goal) {
    final primary = fortuneStr(goal['primaryGoal']);
    final timeline = fortuneStr(goal['timeline']);
    final strategy = fortuneStr(goal['strategy']);
    final monthly = fortuneStr(goal['monthlyTarget']);
    final luckyTiming = fortuneStr(goal['luckyTiming']);

    return FortuneSectionCard(
      emoji: '🎯',
      title: '목표 전략',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (primary != null)
            FortuneMetricRow(emoji: '🎯', label: '목표', value: primary),
          if (timeline != null)
            FortuneMetricRow(emoji: '⏰', label: '기간', value: timeline),
          if (strategy != null) ...[
            const SizedBox(height: DSSpacing.xs),
            FortuneTipCard(emoji: '📝', text: strategy),
          ],
          if (monthly != null)
            FortuneMetricRow(emoji: '📅', label: '월 목표', value: monthly),
          if (luckyTiming != null)
            FortuneMetricRow(emoji: '🍀', label: '행운 타이밍', value: luckyTiming),
        ],
      ),
    );
  }

  Widget _buildCashflowCard(
      BuildContext context, Map<String, dynamic> cashflow) {
    final incomeEnergy = fortuneStr(cashflow['incomeEnergy']);
    final incomeDetail = fortuneStr(cashflow['incomeDetail']);
    final expenseWarning = fortuneStr(cashflow['expenseWarning']);
    final savingTip = fortuneStr(cashflow['savingTip']);

    return FortuneSectionCard(
      emoji: '💸',
      title: '자금 흐름',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (incomeEnergy != null)
            FortuneMetricRow(emoji: '📈', label: '수입 에너지', value: incomeEnergy),
          if (incomeDetail != null)
            Text(incomeDetail, style: context.bodySmall.copyWith(height: 1.6)),
          if (expenseWarning != null) ...[
            const SizedBox(height: DSSpacing.xs),
            FortuneTipCard(emoji: '💳', text: expenseWarning),
          ],
          if (savingTip != null) ...[
            const SizedBox(height: DSSpacing.xs),
            FortuneTipCard(emoji: '🏦', text: savingTip),
          ],
        ],
      ),
    );
  }

  Widget _buildInvestmentGrid(
      BuildContext context, Map<String, dynamic> investments) {
    final colors = context.colors;
    final entries = investments.entries
        .where((e) => e.value is Map)
        .toList(growable: false);
    if (entries.isEmpty) return const SizedBox.shrink();

    const emojiMap = {
      'realestate': '🏠',
      'stock': '📈',
      'crypto': '₿',
      'side': '💼',
      'saving': '🏦',
      'business': '🏢',
    };
    const labelMap = {
      'realestate': '부동산',
      'stock': '주식',
      'crypto': '암호화폐',
      'side': '부업',
      'saving': '저축',
      'business': '사업',
    };

    return FortuneSectionCard(
      emoji: '📈',
      title: '투자 인사이트',
      child: Wrap(
        spacing: DSSpacing.sm,
        runSpacing: DSSpacing.sm,
        children: entries.map((e) {
          final data = fortuneAsMap(e.value) ?? {};
          final score = fortuneInt(data['score']);
          final analysis = fortuneStr(data['analysis']);
          final emoji = emojiMap[e.key] ?? '💰';
          final label = labelMap[e.key] ?? FortuneKeyLocalizer.labelFor(e.key);

          return Container(
            width: (MediaQuery.of(context).size.width - 120) / 2,
            padding: const EdgeInsets.all(DSSpacing.sm),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(DSRadius.md),
              border: Border.all(color: colors.border.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: DSSpacing.xxs),
                    Text(label,
                        style: context.labelMedium
                            .copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                if (score != null) ...[
                  const SizedBox(height: DSSpacing.xs),
                  FortuneAnimatedProgressBar(label: '점수', score: score),
                ],
                if (analysis != null)
                  Text(analysis,
                      style: context.labelSmall
                          .copyWith(color: colors.textSecondary, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          );
        }).toList(growable: false),
      ),
    );
  }

  Widget _buildMonthlyFlow(
      BuildContext context, List<Map<String, dynamic>> flow) {
    return FortuneSectionCard(
      emoji: '📅',
      title: '월간 흐름',
      child: Column(
        children: flow.take(4).map((item) {
          final week = fortuneStr(item['week']) ?? '';
          final energy = fortuneStr(item['energy']) ?? '';
          final advice = fortuneStr(item['advice']) ?? '';
          return Padding(
            padding: const EdgeInsets.only(bottom: DSSpacing.sm),
            child: FortuneMetricRow(
              emoji: energy == '상승'
                  ? '📈'
                  : energy == '하락'
                      ? '📉'
                      : '➡️',
              label: week,
              value: '$energy${advice.isNotEmpty ? " · $advice" : ""}',
            ),
          );
        }).toList(growable: false),
      ),
    );
  }

  // ═══ Lucky Items (행운 아이템) ═══

  Widget _buildLuckyItemsBody(BuildContext context) {
    final summary = fortuneStr(componentData['summary']) ??
        fortuneStr(componentData['content']) ??
        '행운 아이템을 분석했어요.';
    final category = fortuneStr(componentData['selectedCategoryLabel']) ??
        fortuneStr(componentData['selectedCategory']);
    final itemsByCategory = fortuneAsMap(componentData['itemsByCategory']) ??
        fortuneAsMap(componentData['items_by_category']);
    final elementsAnalysis = fortuneAsMap(componentData['elementsAnalysis']) ??
        fortuneAsMap(componentData['elements_analysis']);
    final todayPrediction = fortuneStr(componentData['todayPrediction']) ??
        fortuneStr(componentData['today_prediction']);
    final actions = fortuneStrList(componentData['actions']);
    final luckyItems = fortuneAsMap(componentData['luckyItems']);
    final recommendations = fortuneStrList(componentData['recommendations']);
    final warnings = fortuneStrList(componentData['warnings']);

    var si = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FortuneEmojiHeader(emoji: '🍀', text: summary),
        if (category != null) ...[
          const SizedBox(height: DSSpacing.sm),
          Center(child: FortuneTagPillWrap(tags: ['📂 $category'])),
        ],
        if (itemsByCategory != null && itemsByCategory.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: _buildCategoryItems(context, itemsByCategory),
          ),
        ],
        if (elementsAnalysis != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: _buildElementsAnalysis(context, elementsAnalysis),
          ),
        ],
        if (todayPrediction != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneQuoteBlock(
                emoji: '🔮', title: '오늘의 예측', text: todayPrediction),
          ),
        ],
        if (luckyItems != null && luckyItems.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneLuckyItemGrid(items: luckyItems),
          ),
        ],
        if (actions.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '✅',
              title: '행동 추천',
              child: FortuneBulletList(items: actions, bullet: '🍀'),
            ),
          ),
        ],
        if (recommendations.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '💡',
              title: '추천',
              child: FortuneBulletList(items: recommendations, bullet: '💫'),
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

  Widget _buildCategoryItems(BuildContext context, Map<String, dynamic> items) {
    final colors = context.colors;
    // Flatten all category items into a display list
    final allItems = <Widget>[];
    for (final entry in items.entries) {
      if (entry.value is List) {
        for (final item in entry.value as List) {
          final map = fortuneAsMap(item);
          if (map == null) continue;
          final name = fortuneStr(map['name']) ?? '';
          final benefit = fortuneStr(map['benefit']) ??
              fortuneStr(map['reason']) ??
              fortuneStr(map['meaning']) ??
              fortuneStr(map['usage']) ??
              '';
          allItems.add(
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: DSSpacing.xs),
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(DSRadius.md),
                border:
                    Border.all(color: colors.border.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: context.bodySmall
                          .copyWith(fontWeight: FontWeight.w700)),
                  if (benefit.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(benefit,
                        style: context.labelSmall.copyWith(
                            color: colors.textSecondary, height: 1.4)),
                  ],
                ],
              ),
            ),
          );
        }
      }
    }
    if (allItems.isEmpty) return const SizedBox.shrink();

    return FortuneSectionCard(
      emoji: '✨',
      title: '행운 아이템 목록',
      child: Column(children: allItems.take(6).toList()),
    );
  }

  Widget _buildElementsAnalysis(
      BuildContext context, Map<String, dynamic> analysis) {
    final dominant = fortuneStr(analysis['dominant_element']) ??
        fortuneStr(analysis['dominantElement']);
    final energy = fortuneStr(analysis['current_energy']) ??
        fortuneStr(analysis['currentEnergy']);
    final tip = fortuneStr(analysis['element_tip']) ??
        fortuneStr(analysis['elementTip']);
    final compatColors = fortuneStrList(analysis['compatible_colors']) +
        fortuneStrList(analysis['compatibleColors']);

    return FortuneSectionCard(
      emoji: '☯️',
      title: '오행 분석',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (dominant != null)
            FortuneMetricRow(emoji: '🔥', label: '주요 원소', value: dominant),
          if (energy != null)
            FortuneMetricRow(emoji: '⚡', label: '현재 에너지', value: energy),
          if (compatColors.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.xs),
            FortuneTagPillWrap(tags: compatColors.map((c) => '🎨 $c').toList()),
          ],
          if (tip != null) ...[
            const SizedBox(height: DSSpacing.sm),
            FortuneTipCard(emoji: '💡', text: tip),
          ],
        ],
      ),
    );
  }

  // ═══ Lotto (로또운) ═══

  Widget _buildLottoBody(BuildContext context) {
    final summary = fortuneStr(componentData['summary']) ??
        fortuneStr(componentData['content']) ??
        '로또운을 분석했어요.';
    final luckyItems = fortuneAsMap(componentData['luckyItems']);
    final recommendations = fortuneStrList(componentData['recommendations']);
    final warnings = fortuneStrList(componentData['warnings']);
    final highlights = fortuneStrList(componentData['highlights']);

    var si = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FortuneEmojiHeader(emoji: '🎰', text: summary),
        if (highlights.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          Center(child: FortuneTagPillWrap(tags: highlights)),
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
              emoji: '🎯',
              title: '추천',
              child: FortuneBulletList(items: recommendations, bullet: '🎰'),
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
