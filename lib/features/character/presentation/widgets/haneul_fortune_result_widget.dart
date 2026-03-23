import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/design_system/design_system.dart';
import '../utils/fortune_key_localizer.dart';
import 'fortune_bodies/_fortune_visual_components.dart';

class HaneulFortuneResultWidget extends StatelessWidget {
  final String fortuneType;
  final Map<String, dynamic> componentData;

  const HaneulFortuneResultWidget({
    super.key,
    required this.fortuneType,
    required this.componentData,
  });

  @override
  Widget build(BuildContext context) {
    switch (fortuneType) {
      case 'daily':
        return _buildDailyCard(context);
      case 'daily-calendar':
        return _buildDailyCalendarCard(context);
      case 'new-year':
        return _buildNewYearCard(context);
      case 'fortune-cookie':
        return _buildFortuneCookieCard(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDailyCard(BuildContext context) {
    final summary = _stringValue(componentData['summary']) ??
        _stringValue(componentData['content']) ??
        '오늘의 흐름을 정리했어요.';
    final omen = _stringValue(componentData['specialMessage']) ??
        _stringValue(componentData['description']) ??
        _stringValue(componentData['greeting']);
    final score = _intValue(componentData['score']);
    final categories = _asMap(componentData['categories']) ?? const {};
    final rhythm = _normalizeTimeEntries(
      componentData['timeSpecificFortunes'] ?? componentData['timeSlots'],
    );
    final highlightChips = _stringList(componentData['highlights']);
    final personalActions = _buildActionLines(
      componentData['personalActions'],
      fallback: _stringList(componentData['recommendations']),
    );
    final luckyItems = _asMap(componentData['luckyItems']) ?? const {};
    final warnings = _stringList(componentData['warnings']);
    final godlife = _asMap(componentData['godlife']);
    final storySegments = _buildStoryParagraphs();
    final fortuneSummary = _asMap(componentData['fortuneSummary']);
    final sajuInsight = _asMap(componentData['sajuInsight']);

    var sectionIndex = 0;

    return _buildMysticalShell(
      context,
      title: _stringValue(componentData['title']) ?? '오늘의 흐름',
      score: score,
      icon: Icons.auto_awesome_rounded,
      eyebrow: _buildHeroEyebrow(
        title: '오늘 브리프',
        value: highlightChips.isNotEmpty ? highlightChips.first : null,
      ),
      heroBody: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // — Animated score ring (hero visual) —
          if (score != null) ...[
            Center(
              child: FortuneAnimatedScoreRing(
                score: score,
                size: 108,
                strokeWidth: 10,
                label: '오늘 운세',
              ),
            ),
            const SizedBox(height: DSSpacing.md),
          ],
          if (omen != null) ...[
            _buildOmenPill(context, omen),
            const SizedBox(height: DSSpacing.sm),
          ],
          Text(
            summary,
            style: context.bodyLarge.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w600,
              height: 1.62,
            ),
          ),
          // — Highlight chips —
          if (highlightChips.length > 1) ...[
            const SizedBox(height: DSSpacing.sm),
            Wrap(
              spacing: DSSpacing.xs,
              runSpacing: DSSpacing.xs,
              children: highlightChips.map((chip) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.sm,
                    vertical: DSSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(DSRadius.full),
                  ),
                  child: Text(
                    chip,
                    style: context.labelSmall.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }).toList(growable: false),
            ),
          ],
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (rhythm.isNotEmpty) ...[
            FortuneStaggeredSection(
              index: sectionIndex++,
              child: _buildSectionFrame(
                context,
                title: '오늘의 리듬',
                icon: Icons.schedule_rounded,
                child: _buildAnimatedRhythmTimeline(
                    context, rhythm.take(3).toList()),
              ),
            ),
            const SizedBox(height: DSSpacing.md),
          ],
          if (categories.isNotEmpty) ...[
            FortuneStaggeredSection(
              index: sectionIndex++,
              child: _buildSectionFrame(
                context,
                title: '분야별 운세',
                icon: Icons.grid_view_rounded,
                child: _buildAnimatedCategoryGrid(context, categories),
              ),
            ),
            const SizedBox(height: DSSpacing.md),
          ],
          if (luckyItems.isNotEmpty) ...[
            FortuneStaggeredSection(
              index: sectionIndex++,
              child: _buildSectionFrame(
                context,
                title: '행운 포인트',
                icon: Icons.stars_rounded,
                child: _buildLuckyInfoGrid(context, luckyItems),
              ),
            ),
            const SizedBox(height: DSSpacing.md),
          ],
          if (personalActions.isNotEmpty) ...[
            FortuneStaggeredSection(
              index: sectionIndex++,
              child: _buildSectionFrame(
                context,
                title: '오늘의 액션',
                icon: Icons.bolt_rounded,
                child: _buildAnimatedActionList(
                    context, personalActions.take(4).toList()),
              ),
            ),
            const SizedBox(height: DSSpacing.md),
          ],
          if (godlife != null && godlife.isNotEmpty) ...[
            FortuneStaggeredSection(
              index: sectionIndex++,
              child: _buildSectionFrame(
                context,
                title: '갓생 부스트',
                icon: Icons.wb_twilight_rounded,
                child: _buildGodlifeSection(context, godlife),
              ),
            ),
            const SizedBox(height: DSSpacing.md),
          ],
          if (warnings.isNotEmpty) ...[
            FortuneStaggeredSection(
              index: sectionIndex++,
              child: _buildSectionFrame(
                context,
                title: '조심할 포인트',
                icon: Icons.shield_moon_rounded,
                child: _buildWarningCards(context, warnings.take(2).toList()),
              ),
            ),
            const SizedBox(height: DSSpacing.md),
          ],
          if (storySegments.isNotEmpty ||
              (fortuneSummary != null && fortuneSummary.isNotEmpty) ||
              (sajuInsight != null && sajuInsight.isNotEmpty)) ...[
            FortuneStaggeredSection(
              index: sectionIndex++,
              child: _HaneulExpandableSection(
                title: '더 읽기',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (fortuneSummary != null && fortuneSummary.isNotEmpty)
                      _buildSummaryStories(context, fortuneSummary),
                    if (sajuInsight != null && sajuInsight.isNotEmpty) ...[
                      if (fortuneSummary != null && fortuneSummary.isNotEmpty)
                        const SizedBox(height: DSSpacing.sm),
                      _buildSectionCaption(context, '사주 인사이트'),
                      const SizedBox(height: DSSpacing.xs),
                      _buildBulletList(
                        context,
                        _formattedMapLines(sajuInsight),
                      ),
                    ],
                    if (storySegments.isNotEmpty) ...[
                      if (fortuneSummary != null && fortuneSummary.isNotEmpty ||
                          sajuInsight != null && sajuInsight.isNotEmpty)
                        const SizedBox(height: DSSpacing.sm),
                      _buildSectionCaption(context, '스토리'),
                      const SizedBox(height: DSSpacing.xs),
                      ...storySegments.map(
                        (paragraph) => Padding(
                          padding: const EdgeInsets.only(bottom: DSSpacing.sm),
                          child: Text(
                            paragraph,
                            style: context.bodySmall.copyWith(
                              color: context.colors.textPrimary,
                              height: 1.65,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDailyCalendarCard(BuildContext context) {
    final summary = _stringValue(componentData['summary']) ??
        _stringValue(componentData['content']) ??
        '오늘 일정 흐름을 정리했어요.';
    final rhythm = _normalizeTimeEntries(
      componentData['timeSlots'] ?? componentData['timeSpecificFortunes'],
    );
    final bestTime = _asMap(componentData['bestTime']);
    final worstTime = _asMap(componentData['worstTime']);
    final luckyItems = _asMap(componentData['luckyItems']) ?? const {};
    final calendarAdvice = _mapList(componentData['calendarAdvice']);
    final warnings = _stringList(componentData['warnings']);
    final specialMessage = _stringValue(componentData['specialMessage']) ??
        _stringValue(componentData['description']);
    final dayTheme = _stringValue(componentData['dayTheme']);
    final eventCount = _mapList(componentData['calendarEvents']).length;

    return _buildMysticalShell(
      context,
      title: _stringValue(componentData['title']) ?? '오늘 일정 흐름',
      score: _intValue(componentData['score']),
      icon: Icons.calendar_today_rounded,
      eyebrow: _buildHeroEyebrow(
        title: dayTheme ?? '시간 흐름',
        value: eventCount > 0 ? '$eventCount개 일정 반영' : null,
      ),
      heroBody: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (specialMessage != null) ...[
            _buildOmenPill(context, specialMessage),
            const SizedBox(height: DSSpacing.sm),
          ],
          Text(
            summary,
            style: context.bodyLarge.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w600,
              height: 1.62,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bestTime != null || worstTime != null) ...[
            FortuneStaggeredSection(
              index: 0,
              child: _buildSectionFrame(
                context,
                title: '좋은 시간 / 조심할 시간',
                icon: Icons.timelapse_rounded,
                child: Row(
                  children: [
                    if (bestTime != null)
                      Expanded(
                        child: _buildDualTimeTile(
                          context,
                          title: '좋은 시간',
                          tone: context.colors.accent,
                          label: _stringValue(bestTime['period']) ??
                              _stringValue(bestTime['name']) ??
                              '시간대 확인',
                          description: _stringValue(bestTime['reason']) ?? '',
                        ),
                      ),
                    if (bestTime != null && worstTime != null)
                      const SizedBox(width: DSSpacing.sm),
                    if (worstTime != null)
                      Expanded(
                        child: _buildDualTimeTile(
                          context,
                          title: '조심할 시간',
                          tone: context.colors.warning,
                          label: _stringValue(worstTime['period']) ??
                              _stringValue(worstTime['name']) ??
                              '시간대 확인',
                          description: _stringValue(worstTime['reason']) ?? '',
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: DSSpacing.md),
          ],
          if (rhythm.isNotEmpty) ...[
            FortuneStaggeredSection(
              index: 1,
              child: _buildSectionFrame(
                context,
                title: '시간대별 흐름',
                icon: Icons.view_timeline_rounded,
                child: _buildAnimatedRhythmTimeline(
                    context, rhythm.take(4).toList()),
              ),
            ),
            const SizedBox(height: DSSpacing.md),
          ],
          if (calendarAdvice.isNotEmpty) ...[
            FortuneStaggeredSection(
              index: 2,
              child: _buildSectionFrame(
                context,
                title: '일정 인사이트',
                icon: Icons.event_note_rounded,
                child: Column(
                  children: calendarAdvice
                      .take(3)
                      .map((entry) => _buildAdviceTile(context, entry))
                      .toList(growable: false),
                ),
              ),
            ),
            const SizedBox(height: DSSpacing.md),
          ],
          if (luckyItems.isNotEmpty) ...[
            FortuneStaggeredSection(
              index: 3,
              child: _buildSectionFrame(
                context,
                title: '행운 포인트',
                icon: Icons.auto_awesome_rounded,
                child: _buildLuckyInfoGrid(context, luckyItems),
              ),
            ),
            const SizedBox(height: DSSpacing.md),
          ],
          if (warnings.isNotEmpty) ...[
            FortuneStaggeredSection(
              index: 4,
              child: _buildSectionFrame(
                context,
                title: '체크 포인트',
                icon: Icons.shield_moon_rounded,
                child: _buildWarningCards(context, warnings.take(2).toList()),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNewYearCard(BuildContext context) {
    final summary = _stringValue(componentData['summary']) ??
        _stringValue(componentData['content']) ??
        '올해의 흐름을 정리했어요.';
    final greeting = _stringValue(componentData['greeting']);
    final goalFortune = _asMap(componentData['goalFortune']);
    final sajuAnalysis = _asMap(componentData['sajuAnalysis']);
    final monthlyHighlights = _mapList(componentData['monthlyHighlights']);
    final actionPlan = _asMap(componentData['actionPlan']);
    final luckyItems = _asMap(componentData['luckyItems']) ?? const {};
    final specialMessage = _stringValue(componentData['specialMessage']);
    final storySegments = _buildStoryParagraphs();

    return _buildMysticalShell(
      context,
      title: _stringValue(componentData['title']) ?? '올해의 흐름',
      score: _intValue(componentData['score']),
      icon: Icons.celebration_rounded,
      eyebrow: _buildHeroEyebrow(
        title: '연간 포인트',
        value: _stringValue(goalFortune?['goalLabel']) ??
            _stringValue(goalFortune?['title']),
      ),
      heroBody: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (greeting != null) ...[
            _buildOmenPill(context, greeting),
            const SizedBox(height: DSSpacing.sm),
          ],
          Text(
            summary,
            style: context.bodyLarge.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w600,
              height: 1.62,
            ),
          ),
          if (specialMessage != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Text(
              specialMessage,
              style: context.bodySmall.copyWith(
                color: context.colors.textSecondary,
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (goalFortune != null && goalFortune.isNotEmpty) ...[
            FortuneStaggeredSection(
              index: 0,
              child: _HaneulExpandableSection(
                title: '올해 핵심 목표',
                initiallyExpanded: true,
                child: _buildGoalFortune(context, goalFortune),
              ),
            ),
            const SizedBox(height: DSSpacing.md),
          ],
          if (sajuAnalysis != null && sajuAnalysis.isNotEmpty) ...[
            FortuneStaggeredSection(
              index: 1,
              child: _HaneulExpandableSection(
                title: '사주 흐름',
                child: _buildMapSection(context, sajuAnalysis),
              ),
            ),
            const SizedBox(height: DSSpacing.md),
          ],
          if (monthlyHighlights.isNotEmpty) ...[
            FortuneStaggeredSection(
              index: 2,
              child: _HaneulExpandableSection(
                title: '월별 하이라이트',
                child: Column(
                  children: monthlyHighlights
                      .map(
                          (entry) => _buildMonthlyHighlightTile(context, entry))
                      .toList(growable: false),
                ),
              ),
            ),
            const SizedBox(height: DSSpacing.md),
          ],
          if (luckyItems.isNotEmpty) ...[
            FortuneStaggeredSection(
              index: 3,
              child: _HaneulExpandableSection(
                title: '행운 요소',
                child: _buildLuckyInfoGrid(context, luckyItems),
              ),
            ),
            const SizedBox(height: DSSpacing.md),
          ],
          if (actionPlan != null && actionPlan.isNotEmpty) ...[
            FortuneStaggeredSection(
              index: 4,
              child: _HaneulExpandableSection(
                title: '실천 계획',
                child: _buildActionPlan(context, actionPlan),
              ),
            ),
            const SizedBox(height: DSSpacing.md),
          ],
          if (storySegments.isNotEmpty) ...[
            _HaneulExpandableSection(
              title: '더 읽기',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: storySegments
                    .map(
                      (paragraph) => Padding(
                        padding: const EdgeInsets.only(bottom: DSSpacing.sm),
                        child: Text(
                          paragraph,
                          style: context.bodySmall.copyWith(
                            color: context.colors.textPrimary,
                            height: 1.65,
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFortuneCookieCard(BuildContext context) {
    final emoji = _stringValue(componentData['emoji']) ?? '🥠';
    final message = _stringValue(componentData['message']) ??
        _stringValue(componentData['summary']) ??
        '오늘의 포춘 메시지를 준비했어요.';
    final luckyItems = _asMap(componentData['luckyItems']) ?? const {};
    final actionMission = _stringValue(componentData['actionMission']);
    final cookieType = _stringValue(componentData['cookieType']);

    return _buildMysticalShell(
      context,
      title: _stringValue(componentData['title']) ?? '오늘의 포춘 메시지',
      score: _intValue(componentData['score']),
      icon: Icons.cookie_rounded,
      eyebrow: _buildHeroEyebrow(
        title: _resolveFortuneCookieLabel(cookieType),
        value: _stringValue(componentData['luckyColor']),
      ),
      heroBody: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 360),
        tween: Tween(begin: 0.94, end: 1),
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmojiHero(context, emoji),
            const SizedBox(height: DSSpacing.sm),
            Text(
              message,
              style: context.bodyLarge.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w700,
                height: 1.58,
              ),
            ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (luckyItems.isNotEmpty) ...[
            _buildSectionFrame(
              context,
              title: '오늘의 럭키 세트',
              icon: Icons.auto_awesome_rounded,
              child: _buildLuckySetGrid(context, luckyItems),
            ),
            const SizedBox(height: DSSpacing.md),
          ],
          if (actionMission != null) ...[
            _buildSectionFrame(
              context,
              title: '오늘의 미션',
              icon: Icons.flag_rounded,
              child: Text(
                actionMission,
                style: context.bodyMedium.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  height: 1.62,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMysticalShell(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
    required Widget heroBody,
    int? score,
    String? eyebrow,
  }) {
    final colors = context.colors;
    final accentWash = Color.alphaBlend(
      colors.accent.withValues(alpha: context.isDark ? 0.18 : 0.08),
      colors.surface,
    );
    final pearlWash = Color.alphaBlend(
      colors.backgroundSecondary
          .withValues(alpha: context.isDark ? 0.32 : 0.88),
      colors.surface,
    );

    return Container(
      margin: const EdgeInsets.only(top: DSSpacing.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DSRadius.xl),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.55),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentWash,
            colors.surface,
            pearlWash,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: colors.accent.withValues(alpha: 0.06),
            blurRadius: 48,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -16,
            child: IgnorePointer(
              child: Container(
                width: 124,
                height: 124,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colors.accent.withValues(alpha: 0.18),
                      colors.accent.withValues(alpha: 0.05),
                      colors.accent.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(DSSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroIcon(context, icon),
                    const SizedBox(width: DSSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (eyebrow != null) ...[
                            Text(
                              eyebrow,
                              style: context.labelSmall.copyWith(
                                color: colors.textSecondary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: DSSpacing.xxs),
                          ],
                          Text(
                            title,
                            style: context.headingLarge.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (score != null) _buildScorePill(context, score),
                  ],
                ),
                const SizedBox(height: DSSpacing.md),
                heroBody,
                const SizedBox(height: DSSpacing.lg),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroIcon(BuildContext context, IconData icon) {
    final colors = context.colors;

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DSRadius.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.surface,
            Color.alphaBlend(
              colors.accent.withValues(alpha: 0.18),
              colors.backgroundSecondary,
            ),
          ],
        ),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.48),
        ),
      ),
      child: Icon(
        icon,
        color: colors.textPrimary,
        size: 22,
      ),
    );
  }

  Widget _buildScorePill(BuildContext context, int score) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          colors.surface.withValues(alpha: 0.7),
          colors.backgroundSecondary,
        ),
        borderRadius: BorderRadius.circular(DSRadius.full),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.42),
        ),
      ),
      child: Text(
        '$score점',
        style: context.labelLarge.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildOmenPill(BuildContext context, String text) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          colors.accent.withValues(alpha: 0.08),
          colors.backgroundSecondary,
        ),
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        text,
        style: context.bodySmall.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
          height: 1.58,
        ),
      ),
    );
  }

  Widget _buildSectionFrame(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          colors.surface.withValues(alpha: 0.72),
          colors.backgroundSecondary,
        ),
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: colors.textSecondary,
              ),
              const SizedBox(width: DSSpacing.xs),
              Text(
                title,
                style: context.labelLarge.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          child,
        ],
      ),
    );
  }

  Widget _buildRhythmTimeline(
    BuildContext context,
    List<Map<String, dynamic>> entries,
  ) {
    final colors = context.colors;
    return Column(
      children: entries
          .map(
            (entry) => Container(
              margin: const EdgeInsets.only(bottom: DSSpacing.sm),
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(DSRadius.lg),
                border: Border.all(
                  color: colors.border.withValues(alpha: 0.36),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Color.alphaBlend(
                        colors.accent.withValues(alpha: 0.08),
                        colors.backgroundSecondary,
                      ),
                      borderRadius: BorderRadius.circular(DSRadius.lg),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${_intValue(entry['score']) ?? 0}',
                      style: context.labelMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _stringValue(entry['label']) ??
                              _stringValue(entry['time']) ??
                              '시간대',
                          style: context.labelLarge.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (_stringValue(entry['subtitle']) != null) ...[
                          const SizedBox(height: DSSpacing.xxs),
                          Text(
                            _stringValue(entry['subtitle'])!,
                            style: context.labelSmall.copyWith(
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (_stringValue(entry['body']) != null) ...[
                          const SizedBox(height: DSSpacing.xs),
                          Text(
                            _stringValue(entry['body'])!,
                            style: context.bodySmall.copyWith(
                              color: colors.textPrimary,
                              height: 1.58,
                            ),
                          ),
                        ],
                        if (_stringValue(entry['tail']) != null) ...[
                          const SizedBox(height: DSSpacing.xs),
                          Text(
                            '포인트: ${_stringValue(entry['tail'])!}',
                            style: context.labelSmall.copyWith(
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _buildCategoryGrid(
    BuildContext context,
    Map<String, dynamic> categories,
  ) {
    final entries = categories.entries
        .where((entry) => entry.key != 'total')
        .map(
          (entry) => {
            'title': _categoryLabel(entry.key),
            'score': _intValue(_asMap(entry.value)?['score']) ?? 0,
            'body': _stringValue(_asMap(entry.value)?['message']) ??
                _stringValue(_asMap(entry.value)?['description']) ??
                _stringValue(_asMap(entry.value)?['summary']) ??
                _stringValue(_asMap(entry.value)?['advice']),
          },
        )
        .take(5)
        .toList(growable: false);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: DSSpacing.sm,
        crossAxisSpacing: DSSpacing.sm,
        childAspectRatio: 1.32,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final colors = context.colors;

        return Container(
          padding: const EdgeInsets.all(DSSpacing.sm),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(DSRadius.lg),
            border: Border.all(
              color: colors.border.withValues(alpha: 0.36),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry['title']! as String,
                style: context.labelLarge.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: DSSpacing.xxs),
              Text(
                '${entry['score']}점',
                style: context.headingSmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (entry['body'] is String &&
                  (entry['body'] as String).trim().isNotEmpty) ...[
                const SizedBox(height: DSSpacing.xxs),
                Expanded(
                  child: Text(
                    entry['body']! as String,
                    style: context.labelSmall.copyWith(
                      color: colors.textSecondary,
                      height: 1.45,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildLuckyStrip(
      BuildContext context, Map<String, dynamic> luckyItems) {
    final entries = _luckyDisplayEntries(luckyItems);
    return Wrap(
      spacing: DSSpacing.xs,
      runSpacing: DSSpacing.xs,
      children: entries
          .map(
            (entry) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.sm,
                vertical: DSSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(DSRadius.full),
                border: Border.all(
                  color: context.colors.border.withValues(alpha: 0.34),
                ),
              ),
              child: Text(
                entry,
                style: context.labelMedium.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _buildLuckySetGrid(
      BuildContext context, Map<String, dynamic> luckyItems) {
    final entries = _luckyDisplayEntries(luckyItems);
    return Wrap(
      spacing: DSSpacing.sm,
      runSpacing: DSSpacing.sm,
      children: entries
          .map(
            (entry) => SizedBox(
              width: 148,
              child: Container(
                padding: const EdgeInsets.all(DSSpacing.sm),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(DSRadius.lg),
                  border: Border.all(
                    color: context.colors.border.withValues(alpha: 0.36),
                  ),
                ),
                child: Text(
                  entry,
                  style: context.labelMedium.copyWith(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _buildActionList(BuildContext context, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: context.colors.accent,
                    ),
                  ),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      item,
                      style: context.bodySmall.copyWith(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        height: 1.58,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _buildBulletList(BuildContext context, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.xs),
              child: Text(
                '• $item',
                style: context.bodySmall.copyWith(
                  color: context.colors.textPrimary,
                  height: 1.58,
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _buildGodlifeSection(
      BuildContext context, Map<String, dynamic> godlife) {
    final summary = _stringValue(godlife['summary']);
    final cheatkeys = _mapList(godlife['cheatkeys']);
    final talisman = _stringValue(godlife['talisman']);
    final luckyMusic = _stringValue(godlife['lucky_music']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (summary != null)
          Text(
            summary,
            style: context.bodyMedium.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w700,
              height: 1.58,
            ),
          ),
        if (cheatkeys.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.xs,
            runSpacing: DSSpacing.xs,
            children: cheatkeys
                .map(
                  (entry) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DSSpacing.sm,
                      vertical: DSSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(DSRadius.full),
                      border: Border.all(
                        color: context.colors.border.withValues(alpha: 0.34),
                      ),
                    ),
                    child: Text(
                      [
                        _stringValue(entry['icon']),
                        _stringValue(entry['key']) ??
                            _stringValue(entry['title']),
                      ].whereType<String>().join(' '),
                      style: context.labelMedium.copyWith(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
        if (talisman != null || luckyMusic != null) ...[
          const SizedBox(height: DSSpacing.sm),
          if (talisman != null)
            Text(
              '부적 키워드: $talisman',
              style: context.labelMedium.copyWith(
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (luckyMusic != null) ...[
            const SizedBox(height: DSSpacing.xxs),
            Text(
              '오늘의 음악: $luckyMusic',
              style: context.labelMedium.copyWith(
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ],
    );
  }

  // ─── Enhanced animated helpers for Phase 1 (daily) ───

  Widget _buildAnimatedRhythmTimeline(
    BuildContext context,
    List<Map<String, dynamic>> entries,
  ) {
    final colors = context.colors;
    return Column(
      children: entries.asMap().entries.map((indexed) {
        final i = indexed.key;
        final entry = indexed.value;
        final score = _intValue(entry['score']) ?? 50;
        final statusColor = score >= 70
            ? colors.success
            : score >= 40
                ? colors.warning
                : colors.error;
        final isLast = i == entries.length - 1;

        return Animate(
          effects: [
            FadeEffect(
              duration: DSAnimation.normal,
              delay: DSAnimation.contentStagger * (i + 1),
              curve: DSAnimation.claude,
            ),
            SlideEffect(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
              duration: DSAnimation.normal,
              delay: DSAnimation.contentStagger * (i + 1),
              curve: DSAnimation.claude,
            ),
          ],
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline rail: dot + vertical line
                SizedBox(
                  width: 24,
                  child: Column(
                    children: [
                      const SizedBox(height: 14),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withValues(alpha: 0.3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(
                                vertical: DSSpacing.xxs),
                            color: colors.border.withValues(alpha: 0.3),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: DSSpacing.xs),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: DSSpacing.sm),
                    padding: const EdgeInsets.all(DSSpacing.sm),
                    decoration: BoxDecoration(
                      color: Color.alphaBlend(
                        statusColor.withValues(alpha: 0.05),
                        colors.surface,
                      ),
                      borderRadius: BorderRadius.circular(DSRadius.lg),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _stringValue(entry['label']) ??
                                  _stringValue(entry['time']) ??
                                  '시간대',
                              style: context.labelLarge.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: DSSpacing.xs,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius:
                                    BorderRadius.circular(DSRadius.full),
                              ),
                              child: Text(
                                '$score점',
                                style: context.labelSmall.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_stringValue(entry['subtitle']) != null) ...[
                          const SizedBox(height: DSSpacing.xxs),
                          Text(
                            _stringValue(entry['subtitle'])!,
                            style: context.labelSmall.copyWith(
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (_stringValue(entry['body']) != null) ...[
                          const SizedBox(height: DSSpacing.xs),
                          Text(
                            _stringValue(entry['body'])!,
                            style: context.bodySmall.copyWith(
                              color: colors.textPrimary,
                              height: 1.58,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(growable: false),
    );
  }

  Widget _buildAnimatedCategoryGrid(
    BuildContext context,
    Map<String, dynamic> categories,
  ) {
    final entries = categories.entries
        .where((entry) => entry.key != 'total')
        .map(
          (entry) => {
            'title': _categoryLabel(entry.key),
            'emoji': _categoryEmoji(entry.key),
            'score': _intValue(_asMap(entry.value)?['score']) ?? 0,
            'body': _stringValue(_asMap(entry.value)?['message']) ??
                _stringValue(_asMap(entry.value)?['description']) ??
                _stringValue(_asMap(entry.value)?['summary']) ??
                _stringValue(_asMap(entry.value)?['advice']),
          },
        )
        .take(5)
        .toList(growable: false);

    return Column(
      children: entries.asMap().entries.map((indexed) {
        final i = indexed.key;
        final entry = indexed.value;
        final score = entry['score'] as int;

        return FortuneAnimatedProgressBar(
          label: '${entry['emoji']}  ${entry['title']}',
          score: score,
          staggerIndex: i,
        );
      }).toList(growable: false),
    );
  }

  Widget _buildLuckyInfoGrid(
    BuildContext context,
    Map<String, dynamic> luckyItems,
  ) {
    final items = <FortuneInfoGraphItem>[];
    final iconMap = {
      'color': Icons.palette_rounded,
      'number': Icons.tag_rounded,
      'direction': Icons.explore_rounded,
      'item': Icons.diamond_rounded,
      'time': Icons.schedule_rounded,
      'food': Icons.restaurant_rounded,
      'drink': Icons.local_cafe_rounded,
      'place': Icons.place_rounded,
      'music': Icons.music_note_rounded,
      'animal': Icons.pets_rounded,
      'flower': Icons.local_florist_rounded,
    };
    final labelMap = {
      'color': '행운 색상',
      'number': '행운 번호',
      'direction': '행운 방향',
      'item': '행운 아이템',
      'time': '행운 시간',
      'food': '행운 음식',
      'drink': '행운 음료',
      'place': '행운 장소',
      'music': '행운 음악',
      'animal': '행운 동물',
      'flower': '행운 꽃',
    };

    for (final entry in luckyItems.entries) {
      final value = _stringValue(entry.value);
      if (value == null || value.isEmpty) continue;
      final key = entry.key.toLowerCase();
      items.add(FortuneInfoGraphItem(
        iconData: iconMap[key] ?? Icons.auto_awesome_rounded,
        label: labelMap[key] ?? entry.key,
        value: value,
      ));
    }

    if (items.isEmpty) return const SizedBox.shrink();
    return FortuneInfoGraphGrid(items: items);
  }

  Widget _buildAnimatedActionList(BuildContext context, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.asMap().entries.map((indexed) {
        final i = indexed.key;
        final item = indexed.value;
        return Animate(
          effects: [
            FadeEffect(
              duration: DSAnimation.normal,
              delay: DSAnimation.stagger * (i + 1),
              curve: DSAnimation.claude,
            ),
            SlideEffect(
              begin: const Offset(0.03, 0),
              end: Offset.zero,
              duration: DSAnimation.normal,
              delay: DSAnimation.stagger * (i + 1),
              curve: DSAnimation.claude,
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.only(bottom: DSSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: context.colors.accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${i + 1}',
                    style: context.labelSmall.copyWith(
                      color: context.colors.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: DSSpacing.xs),
                Expanded(
                  child: Text(
                    item,
                    style: context.bodySmall.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w600,
                      height: 1.58,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(growable: false),
    );
  }

  Widget _buildWarningCards(BuildContext context, List<String> items) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: DSSpacing.xs),
          padding: const EdgeInsets.all(DSSpacing.sm),
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              colors.warning.withValues(alpha: 0.06),
              colors.surface,
            ),
            borderRadius: BorderRadius.circular(DSRadius.lg),
            border: Border.all(
              color: colors.warning.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: colors.warning,
              ),
              const SizedBox(width: DSSpacing.xs),
              Expanded(
                child: Text(
                  item,
                  style: context.bodySmall.copyWith(
                    color: colors.textPrimary,
                    height: 1.58,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(growable: false),
    );
  }

  String _categoryEmoji(String key) {
    const map = {
      'love': '💝',
      'money': '💰',
      'wealth': '💰',
      'finance': '💰',
      'health': '🌿',
      'work': '💼',
      'career': '💼',
      'study': '📚',
      'relationship': '🤝',
      'social': '👥',
      'family': '👨‍👩‍👧‍👦',
      'luck': '🍀',
      'overall': '✨',
      'total': '✨',
    };
    return map[key.toLowerCase()] ?? '✨';
  }

  Widget _buildSummaryStories(
      BuildContext context, Map<String, dynamic> summary) {
    final blocks = summary.entries
        .map(
          (entry) => {
            'title': _summaryTitle(entry.key),
            'text': _stringValue(_asMap(entry.value)?['content']) ??
                _stringValue(_asMap(entry.value)?['summary']) ??
                _stringValue(_asMap(entry.value)?['title']),
          },
        )
        .where((entry) => entry['text'] != null)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionCaption(context, entry['title']!),
                  const SizedBox(height: DSSpacing.xxs),
                  Text(
                    entry['text']!,
                    style: context.bodySmall.copyWith(
                      color: context.colors.textPrimary,
                      height: 1.62,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _buildDualTimeTile(
    BuildContext context, {
    required String title,
    required Color tone,
    required String label,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          tone.withValues(alpha: 0.08),
          context.colors.surface,
        ),
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: tone.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.labelMedium.copyWith(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DSSpacing.xxs),
          Text(
            label,
            style: context.headingSmall.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (description.trim().isNotEmpty) ...[
            const SizedBox(height: DSSpacing.xs),
            Text(
              description,
              style: context.labelSmall.copyWith(
                color: context.colors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdviceTile(BuildContext context, Map<String, dynamic> entry) {
    final colors = context.colors;
    final title = _stringValue(entry['eventTitle']) ??
        _stringValue(entry['title']) ??
        '일정 인사이트';
    final advice = _stringValue(entry['advice']) ??
        _stringValue(entry['description']) ??
        '';
    final luckyTip =
        _stringValue(entry['luckyTip']) ?? _stringValue(entry['lucky_tip']);
    final cautionTip =
        _stringValue(entry['cautionTip']) ?? _stringValue(entry['caution_tip']);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: DSSpacing.sm),
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.34),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.labelLarge.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            advice,
            style: context.bodySmall.copyWith(
              color: colors.textPrimary,
              height: 1.58,
            ),
          ),
          if (luckyTip != null) ...[
            const SizedBox(height: DSSpacing.xs),
            Text(
              '럭키 팁: $luckyTip',
              style: context.labelSmall.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (cautionTip != null) ...[
            const SizedBox(height: DSSpacing.xxs),
            Text(
              '주의: $cautionTip',
              style: context.labelSmall.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalFortune(
      BuildContext context, Map<String, dynamic> goalFortune) {
    final prediction = _stringValue(goalFortune['prediction']);
    final analysis = _stringValue(goalFortune['deepAnalysis']) ??
        _stringValue(goalFortune['deep_analysis']);
    final bestMonths = _stringList(goalFortune['bestMonths']);
    final cautionMonths = _stringList(goalFortune['cautionMonths']);
    final actionItems = _stringList(goalFortune['actionItems']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (prediction != null)
          Text(
            prediction,
            style: context.bodyMedium.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w700,
              height: 1.62,
            ),
          ),
        if (analysis != null) ...[
          const SizedBox(height: DSSpacing.sm),
          Text(
            analysis,
            style: context.bodySmall.copyWith(
              color: context.colors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
        if (bestMonths.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          _buildSectionCaption(context, '좋은 시기'),
          const SizedBox(height: DSSpacing.xs),
          _buildTagWrap(context, bestMonths),
        ],
        if (cautionMonths.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          _buildSectionCaption(context, '조심할 시기'),
          const SizedBox(height: DSSpacing.xs),
          _buildTagWrap(context, cautionMonths),
        ],
        if (actionItems.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          _buildSectionCaption(context, '실행 포인트'),
          const SizedBox(height: DSSpacing.xs),
          _buildBulletList(context, actionItems.take(4).toList()),
        ],
      ],
    );
  }

  Widget _buildMapSection(BuildContext context, Map<String, dynamic> map) {
    return _buildBulletList(
      context,
      _formattedMapLines(map),
    );
  }

  Widget _buildActionPlan(
      BuildContext context, Map<String, dynamic> actionPlan) {
    final immediate = _stringList(actionPlan['immediate']);
    final shortTerm = <String>[
      ..._stringList(actionPlan['shortTerm']),
      ..._stringList(actionPlan['short_term']),
    ];
    final longTerm = <String>[
      ..._stringList(actionPlan['longTerm']),
      ..._stringList(actionPlan['long_term']),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (immediate.isNotEmpty) ...[
          _buildSectionCaption(context, '바로 시작'),
          const SizedBox(height: DSSpacing.xs),
          _buildBulletList(context, immediate.take(3).toList()),
        ],
        if (shortTerm.isNotEmpty) ...[
          if (immediate.isNotEmpty) const SizedBox(height: DSSpacing.sm),
          _buildSectionCaption(context, '1~3개월'),
          const SizedBox(height: DSSpacing.xs),
          _buildBulletList(context, shortTerm.take(3).toList()),
        ],
        if (longTerm.isNotEmpty) ...[
          if (immediate.isNotEmpty || shortTerm.isNotEmpty)
            const SizedBox(height: DSSpacing.sm),
          _buildSectionCaption(context, '하반기'),
          const SizedBox(height: DSSpacing.xs),
          _buildBulletList(context, longTerm.take(3).toList()),
        ],
      ],
    );
  }

  Widget _buildMonthlyHighlightTile(
    BuildContext context,
    Map<String, dynamic> entry,
  ) {
    final colors = context.colors;
    final month = _stringValue(entry['month']) ?? '월';
    final theme = _stringValue(entry['theme']);
    final advice = _stringValue(entry['advice']);
    final recommendedAction = _stringValue(entry['recommendedAction']) ??
        _stringValue(entry['recommended_action']);
    final score = _intValue(entry['score']);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: DSSpacing.xs),
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.34),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  theme != null ? '$month · $theme' : month,
                  style: context.labelLarge.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (score != null)
                Text(
                  '$score점',
                  style: context.labelSmall.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          if (advice != null) ...[
            const SizedBox(height: DSSpacing.xxs),
            Text(
              advice,
              style: context.bodySmall.copyWith(
                color: colors.textPrimary,
                height: 1.56,
              ),
            ),
          ],
          if (recommendedAction != null) ...[
            const SizedBox(height: DSSpacing.xxs),
            Text(
              '추천 행동: $recommendedAction',
              style: context.labelSmall.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTagWrap(BuildContext context, List<String> items) {
    return Wrap(
      spacing: DSSpacing.xs,
      runSpacing: DSSpacing.xs,
      children: items
          .map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.sm,
                vertical: DSSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(DSRadius.full),
                border: Border.all(
                  color: context.colors.border.withValues(alpha: 0.34),
                ),
              ),
              child: Text(
                item,
                style: context.labelSmall.copyWith(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _buildSectionCaption(BuildContext context, String title) {
    return Text(
      title,
      style: context.labelMedium.copyWith(
        color: context.colors.textSecondary,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildEmojiHero(BuildContext context, String emoji) {
    final colors = context.colors;
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          colors.accent.withValues(alpha: 0.1),
          colors.backgroundSecondary,
        ),
        borderRadius: BorderRadius.circular(DSRadius.xl),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.38),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        emoji,
        style: context.headingLarge,
      ),
    );
  }

  String? _buildHeroEyebrow({
    required String title,
    String? value,
  }) {
    if (value == null) {
      return title;
    }
    return '$title · $value';
  }

  List<Map<String, dynamic>> _normalizeTimeEntries(dynamic value) {
    final items = _mapList(value);
    return items
        .map(
          (entry) => {
            'label': _stringValue(entry['period']) ??
                _stringValue(entry['time']) ??
                '시간대',
            'subtitle': _stringValue(entry['traditionalName']) ??
                _stringValue(entry['traditional_name']) ??
                _stringValue(entry['title']),
            'score': _intValue(entry['score']),
            'body': _stringValue(entry['description']) ??
                _joinReadable(entry['activities']) ??
                _stringValue(entry['reason']),
            'tail': _stringValue(entry['recommendation']) ??
                _stringValue(entry['caution']) ??
                _stringValue(entry['advice']) ??
                _stringValue(entry['luckyAction']) ??
                _stringValue(entry['lucky_action']),
          },
        )
        .toList(growable: false);
  }

  List<String> _buildActionLines(
    dynamic value, {
    List<String> fallback = const [],
  }) {
    final actions = _mapList(value)
        .map(
          (entry) => [
            _stringValue(entry['title']) ??
                _stringValue(entry['action']) ??
                _stringValue(entry['task']),
            _stringValue(entry['why']) ??
                _stringValue(entry['description']) ??
                _stringValue(entry['reason']),
            _stringValue(entry['timing']) ?? _stringValue(entry['priority']),
          ].whereType<String>().join(' · '),
        )
        .where((item) => item.trim().isNotEmpty)
        .toList(growable: false);

    if (actions.isNotEmpty) {
      return actions;
    }
    return fallback;
  }

  List<String> _buildStoryParagraphs() {
    return _mapList(componentData['storySegments'])
        .map(
          (entry) =>
              _stringValue(entry['text']) ??
              _stringValue(entry['content']) ??
              _stringValue(entry['message']) ??
              _stringValue(entry['body']),
        )
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  List<String> _formattedMapLines(Map<String, dynamic> map) {
    return map.entries
        .map((entry) {
          final mapValue = entry.value;
          if (mapValue is Map<String, dynamic>) {
            final inner = mapValue.entries
                .map((innerEntry) => _stringValue(innerEntry.value))
                .whereType<String>()
                .where((item) => item.isNotEmpty)
                .join(' · ');
            if (inner.isEmpty) {
              return null;
            }
            return '${_displayKey(entry.key)}: $inner';
          }
          if (mapValue is List) {
            final joined = _joinReadable(mapValue);
            if (joined == null) {
              return null;
            }
            return '${_displayKey(entry.key)}: $joined';
          }
          final resolved = _stringValue(mapValue);
          if (resolved == null) {
            return null;
          }
          return '${_displayKey(entry.key)}: $resolved';
        })
        .whereType<String>()
        .toList(growable: false);
  }

  List<String> _luckyDisplayEntries(Map<String, dynamic> luckyItems) {
    return luckyItems.entries
        .map(
          (entry) => _formatLuckyEntry(entry.key, entry.value),
        )
        .whereType<String>()
        .toList(growable: false);
  }

  String? _formatLuckyEntry(String key, dynamic value) {
    final readable = value is List ? _joinReadable(value) : _stringValue(value);
    if (readable == null) {
      return null;
    }
    return '${_displayKey(key)} $readable';
  }

  String _categoryLabel(String key) {
    const labels = {
      'love': '연애운',
      'money': '재물운',
      'work': '일과운',
      'study': '학업운',
      'health': '웰니스',
      'social': '대화운',
      'relationship': '관계운',
    };
    return labels[key] ?? _displayKey(key);
  }

  String _summaryTitle(String key) {
    const labels = {
      'byZodiacAnimal': '띠별 흐름',
      'byZodiacSign': '별자리 흐름',
      'byMBTI': 'MBTI 흐름',
    };
    return labels[key] ?? _displayKey(key);
  }

  String _displayKey(String key) {
    return FortuneKeyLocalizer.labelFor(key);
  }

  String _resolveFortuneCookieLabel(String? cookieType) {
    if (cookieType == null || cookieType.trim().isEmpty) {
      return '포춘쿠키';
    }

    const genericEnglishLabels = {
      'fortune cookie',
      'fortune-cookie',
      'cookie',
      'luck',
    };
    final normalizedType = FortuneKeyLocalizer.normalize(cookieType);
    if (genericEnglishLabels.contains(normalizedType)) {
      return '포춘쿠키';
    }

    return cookieType;
  }

  String? _joinReadable(dynamic value) {
    if (value is! List) {
      return null;
    }
    final items = value
        .map(_stringValue)
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    if (items.isEmpty) {
      return null;
    }
    return items.join(' · ');
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (key, entryValue) => MapEntry(key.toString(), entryValue),
      );
    }
    return null;
  }

  List<Map<String, dynamic>> _mapList(dynamic value) {
    if (value is! List) {
      return const [];
    }
    return value
        .map(_asMap)
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }

  List<String> _stringList(dynamic value) {
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? const [] : [trimmed];
    }
    if (value is! List) {
      return const [];
    }
    return value
        .map(_stringValue)
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  String? _stringValue(dynamic value) {
    if (value == null) {
      return null;
    }
    final stringValue = value.toString().trim();
    return stringValue.isEmpty ? null : stringValue;
  }

  int? _intValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }
}

class _HaneulExpandableSection extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;

  const _HaneulExpandableSection({
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  State<_HaneulExpandableSection> createState() =>
      _HaneulExpandableSectionState();
}

class _HaneulExpandableSectionState extends State<_HaneulExpandableSection> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          colors.surface.withValues(alpha: 0.72),
          colors.backgroundSecondary,
        ),
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(DSRadius.lg),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.sm + DSSpacing.xxs,
                vertical: DSSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: context.labelLarge.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(
                DSSpacing.sm,
                0,
                DSSpacing.sm,
                DSSpacing.sm,
              ),
              child: widget.child,
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
        ],
      ),
    );
  }
}
