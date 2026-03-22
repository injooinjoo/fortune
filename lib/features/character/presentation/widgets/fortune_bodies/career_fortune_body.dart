import 'package:flutter/material.dart';

import '../../../../../core/design_system/design_system.dart';
import '_fortune_body_shared.dart';
import '_fortune_visual_components.dart';

/// Body widget for career/achievement fortune types:
/// career, talent, exam
class CareerFortuneBody extends StatelessWidget {
  final String fortuneType;
  final Map<String, dynamic> componentData;

  const CareerFortuneBody({
    super.key,
    required this.fortuneType,
    required this.componentData,
  });

  @override
  Widget build(BuildContext context) {
    switch (fortuneType) {
      case 'exam':
        return _buildExamBody(context);
      case 'talent':
        return _buildGenericBody(context, emoji: '🌟');
      case 'career':
      default:
        return _buildCareerBody(context);
    }
  }

  // ═══ Career (직업운) ═══

  Widget _buildCareerBody(BuildContext context) {
    final summary = fortuneStr(componentData['summary']) ??
        fortuneStr(componentData['content']) ??
        '직업운을 분석했어요.';
    final careerAnalysis = fortuneAsMap(componentData['careerAnalysis']);
    final careerTips = fortuneStrList(componentData['careertips']) +
        fortuneStrList(componentData['careerTips']);
    final weeklyOutlook = fortuneAsMap(componentData['weeklyOutlook']);
    final luckyItems = fortuneAsMap(componentData['luckyItems']) ??
        fortuneAsMap(componentData['luckyElements']);
    final recommendations = fortuneStrList(componentData['recommendations']);
    final warnings = fortuneStrList(componentData['warnings']);
    final highlights = fortuneStrList(componentData['highlights']);

    final strengths = fortuneStrList(careerAnalysis?['strengths']);
    final challenges = fortuneStrList(careerAnalysis?['challenges']);
    final roles = fortuneStrList(careerAnalysis?['potentialRoles']);
    final phase = fortuneStr(careerAnalysis?['currentPhase']);

    var si = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FortuneEmojiHeader(emoji: '💼', text: summary),
        if (phase != null) ...[
          const SizedBox(height: DSSpacing.sm),
          Center(child: FortuneTagPillWrap(tags: ['📍 $phase'])),
        ],
        if (highlights.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          Center(child: FortuneTagPillWrap(tags: highlights)),
        ],
        if (roles.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '🎯',
              title: '잠재 역할',
              child: FortuneTagPillWrap(tags: roles),
            ),
          ),
        ],
        if (strengths.isNotEmpty || challenges.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneDosDontsCard(dosList: strengths, dontsList: challenges),
          ),
        ],
        if (weeklyOutlook != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: _buildWeeklyOutlook(context, weeklyOutlook),
          ),
        ],
        if (careerTips.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '💡',
              title: '커리어 팁',
              child: FortuneBulletList(items: careerTips, bullet: '💼'),
            ),
          ),
        ],
        if (luckyItems != null && luckyItems.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneLuckyItemGrid(items: luckyItems),
          ),
        ],
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
        if (warnings.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
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

  Widget _buildWeeklyOutlook(
      BuildContext context, Map<String, dynamic> outlook) {
    final bestDays = fortuneStrList(outlook['bestDays']);
    final cautionDays = fortuneStrList(outlook['cautionDays']);
    final rec = fortuneStr(outlook['recommendation']);

    return FortuneSectionCard(
      emoji: '📅',
      title: '주간 전망',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bestDays.isNotEmpty)
            FortuneMetricRow(
                emoji: '🟢', label: '좋은 날', value: bestDays.join(', ')),
          if (cautionDays.isNotEmpty)
            FortuneMetricRow(
                emoji: '🟡', label: '주의 날', value: cautionDays.join(', ')),
          if (rec != null) ...[
            const SizedBox(height: DSSpacing.sm),
            FortuneTipCard(emoji: '💡', text: rec),
          ],
        ],
      ),
    );
  }

  // ═══ Exam (시험운) ═══

  Widget _buildExamBody(BuildContext context) {
    final summary = fortuneStr(componentData['summary']) ??
        fortuneStr(componentData['content']) ??
        '시험운을 분석했어요.';
    final passGrade = fortuneStr(componentData['passGrade']);
    final statusMessage = fortuneStr(componentData['statusMessage']);
    final examStats = fortuneAsMap(componentData['examStats']);
    final csatFocus = fortuneMapList(componentData['csatFocus']);
    final csatRoadmap = fortuneMapList(componentData['csatRoadmap']);
    final csatRoutine = fortuneStrList(componentData['csatRoutine']);
    final todayStrategy = fortuneAsMap(componentData['todayStrategy']);
    final spiritAnimal = fortuneAsMap(componentData['spiritAnimal']);
    final hashtags = fortuneStrList(componentData['hashtags']);
    final luckyItems = fortuneAsMap(componentData['luckyItems']);
    final recommendations = fortuneStrList(componentData['recommendations']);
    final warnings = fortuneStrList(componentData['warnings']);

    var si = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FortuneEmojiHeader(emoji: '📝', text: statusMessage ?? summary),

        if (passGrade != null) ...[
          const SizedBox(height: DSSpacing.sm),
          Center(child: FortuneTagPillWrap(tags: ['🏆 $passGrade'])),
        ],

        // Exam stats
        if (examStats != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: _buildExamStats(context, examStats),
          ),
        ],

        // CSAT focus subjects
        if (csatFocus.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: _buildCsatFocus(context, csatFocus),
          ),
        ],

        // Roadmap
        if (csatRoadmap.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: _buildCsatRoadmap(context, csatRoadmap),
          ),
        ],

        // Today strategy
        if (todayStrategy != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: _buildTodayStrategy(context, todayStrategy),
          ),
        ],

        // Routine
        if (csatRoutine.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '📋',
              title: '추천 루틴',
              child: FortuneBulletList(items: csatRoutine, bullet: '✏️'),
            ),
          ),
        ],

        // Spirit animal
        if (spiritAnimal != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: _buildSpiritAnimal(context, spiritAnimal),
          ),
        ],

        // Hashtags
        if (hashtags.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          Center(
              child: FortuneTagPillWrap(
                  tags: hashtags.map((h) => '#$h').toList())),
        ],

        if (luckyItems != null && luckyItems.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneLuckyItemGrid(items: luckyItems),
          ),
        ],

        if (recommendations.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '💡',
              title: '추천',
              child: FortuneBulletList(items: recommendations, bullet: '📝'),
            ),
          ),
        ],

        if (warnings.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
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

  Widget _buildExamStats(BuildContext context, Map<String, dynamic> stats) {
    final intuition = fortuneInt(stats['answerIntuition']);
    final intuitionDesc = fortuneStr(stats['answerIntuitionDesc']);
    final defense = fortuneInt(stats['mentalDefense']);
    final defenseDesc = fortuneStr(stats['mentalDefenseDesc']);
    final memAccel = fortuneStr(stats['memoryAcceleration']);
    final memDesc = fortuneStr(stats['memoryAccelerationDesc']);

    return FortuneSectionCard(
      emoji: '📊',
      title: '시험 능력치',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (intuition != null) ...[
            FortuneAnimatedProgressBar(label: '직감력', score: intuition, emoji: '🎯', staggerIndex: 0),
            if (intuitionDesc != null)
              Text(intuitionDesc,
                  style: context.labelSmall.copyWith(
                      color: context.colors.textSecondary, height: 1.4)),
          ],
          if (defense != null) ...[
            const SizedBox(height: DSSpacing.xs),
            FortuneAnimatedProgressBar(label: '멘탈', score: defense, emoji: '🛡️', staggerIndex: 1),
            if (defenseDesc != null)
              Text(defenseDesc,
                  style: context.labelSmall.copyWith(
                      color: context.colors.textSecondary, height: 1.4)),
          ],
          if (memAccel != null) ...[
            const SizedBox(height: DSSpacing.xs),
            FortuneMetricRow(
              emoji: memAccel == 'UP'
                  ? '📈'
                  : memAccel == 'DOWN'
                      ? '📉'
                      : '➡️',
              label: '기억력',
              value: memAccel == 'UP'
                  ? '상승'
                  : memAccel == 'DOWN'
                      ? '하락'
                      : '안정',
            ),
            if (memDesc != null)
              Text(memDesc,
                  style: context.labelSmall.copyWith(
                      color: context.colors.textSecondary, height: 1.4)),
          ],
        ],
      ),
    );
  }

  Widget _buildCsatFocus(
      BuildContext context, List<Map<String, dynamic>> focus) {
    return FortuneSectionCard(
      emoji: '📚',
      title: '과목별 포커스',
      child: Column(
        children: focus.take(4).map((item) {
          final subject = fortuneStr(item['subject']) ?? '';
          final focusText = fortuneStr(item['focus']) ?? '';
          final tip = fortuneStr(item['tip']);
          return Padding(
            padding: const EdgeInsets.only(bottom: DSSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FortuneMetricRow(emoji: '📖', label: subject, value: focusText),
                if (tip != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Text('💡 $tip',
                        style: context.labelSmall.copyWith(
                            color: context.colors.textSecondary, height: 1.4)),
                  ),
              ],
            ),
          );
        }).toList(growable: false),
      ),
    );
  }

  Widget _buildCsatRoadmap(
      BuildContext context, List<Map<String, dynamic>> roadmap) {
    return FortuneSectionCard(
      emoji: '🗺️',
      title: '학습 로드맵',
      child: Column(
        children: roadmap.take(4).map((item) {
          final phase = fortuneStr(item['phase']) ?? '';
          final action = fortuneStr(item['action']) ?? '';
          final caution = fortuneStr(item['caution']);
          return Padding(
            padding: const EdgeInsets.only(bottom: DSSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FortuneMetricRow(emoji: '📍', label: phase, value: action),
                if (caution != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Text('⚠️ $caution',
                        style: context.labelSmall.copyWith(
                            color: context.colors.textSecondary, height: 1.4)),
                  ),
              ],
            ),
          );
        }).toList(growable: false),
      ),
    );
  }

  Widget _buildTodayStrategy(
      BuildContext context, Map<String, dynamic> strategy) {
    final action = fortuneStr(strategy['mainAction']);
    final reason = fortuneStr(strategy['actionReason']);
    final food = fortuneStr(strategy['luckyFood']);
    final foodReason = fortuneStr(strategy['luckyFoodReason']);

    return FortuneSectionCard(
      emoji: '🎯',
      title: '오늘의 전략',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (action != null) FortuneTipCard(emoji: '⚡', text: action),
          if (reason != null)
            Text(reason,
                style: context.labelSmall.copyWith(
                    color: context.colors.textSecondary, height: 1.4)),
          if (food != null) ...[
            const SizedBox(height: DSSpacing.sm),
            FortuneMetricRow(emoji: '🍀', label: '행운 음식', value: food),
            if (foodReason != null)
              Text(foodReason,
                  style: context.labelSmall.copyWith(
                      color: context.colors.textSecondary, height: 1.4)),
          ],
        ],
      ),
    );
  }

  Widget _buildSpiritAnimal(BuildContext context, Map<String, dynamic> animal) {
    final name = fortuneStr(animal['animal']) ?? '수호 동물';
    final message = fortuneStr(animal['message']) ?? '';
    final direction = fortuneStr(animal['direction']);
    final dirTip = fortuneStr(animal['directionTip']);

    return FortuneQuoteBlock(
      emoji: '🐾',
      title: '수호 동물: $name',
      text:
          '$message${direction != null ? "\n🧭 $direction" : ""}${dirTip != null ? " · $dirTip" : ""}',
    );
  }

  // ═══ Generic fallback (talent etc.) ═══

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
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneTipCard(emoji: '💡', text: specialTip),
          ),
        ],
        if (luckyItems != null && luckyItems.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneLuckyItemGrid(items: luckyItems),
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
        if (warnings.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
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
