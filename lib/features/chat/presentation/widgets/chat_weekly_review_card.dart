import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/fortune_action_buttons.dart';

/// 주간 리포트 결과 카드
///
/// 채팅 내에서 주간 리포트 결과를 분석적이고 격려하는 톤으로 표시합니다.
/// - 이번 주 요약
/// - 성장 트렌드
/// - 다음 주 액션 제안
class ChatWeeklyReviewCard extends ConsumerWidget {
  final String summary;
  final List<String> trends;
  final List<String> actions;
  final DateTime date;

  const ChatWeeklyReviewCard({
    super.key,
    required this.summary,
    required this.trends,
    required this.actions,
    required this.date,
  });

  // 디자인 색상 → DSColors 기반 (ChatGPT monochrome style)
  static const _creamLight = DSColors.backgroundSecondary;
  static const _creamDark = DSColors.background;
  // 다크모드 배경
  static const _darkBg1 = DSColors.background;
  static const _darkBg2 = DSColors.backgroundSecondary;
  // 액센트 색상 - semantic colors
  static const _orangeAccent = DSColors.warning;
  static const _amberAccent = DSColors.warning;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              context.isDark ? [_darkBg1, _darkBg2] : [_creamLight, _creamDark],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.isDark
              ? _orangeAccent.withValues(alpha: 0.3)
              : _orangeAccent.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _orangeAccent.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // 배경 장식
            ..._buildBackgroundDecorations(context),

            // 메인 콘텐츠
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더
                  _buildHeader(context)
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: -0.1, end: 0),

                  const SizedBox(height: 16),

                  // 구분선
                  _buildDivider(context),

                  const SizedBox(height: 16),

                  // 이번 주 요약
                  _buildSummarySection(context)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms)
                      .slideX(begin: -0.05, end: 0),

                  const SizedBox(height: 16),

                  // 성장 트렌드
                  if (trends.isNotEmpty) ...[
                    _buildTrendsSection(context),
                    const SizedBox(height: 16),
                  ],

                  // 다음 주 액션 제안
                  if (actions.isNotEmpty) ...[
                    _buildActionsSection(context),
                    const SizedBox(height: 16),
                  ],

                  // 마무리 메시지
                  _buildClosingMessage(context)
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 800.ms),

                  const SizedBox(height: DSSpacing.sm),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundDecorations(BuildContext context) {
    final decorations = <Widget>[];

    // 우측 상단 캘린더 장식
    decorations.add(
      Positioned(
        right: 15,
        top: 15,
        child: const Text(
          '📅',
          style: TextStyle(fontSize: 20),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .rotate(begin: -0.03, end: 0.03, duration: 2500.ms),
      ),
    );

    // 좌측 하단 차트 장식
    decorations.add(
      Positioned(
        left: 20,
        bottom: 60,
        child: Text(
          '📊',
          style: context.typography.bodyMedium.copyWith(
            color: Colors.orange.withValues(alpha: 0.4),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(duration: 1800.ms)
            .fadeOut(duration: 1800.ms),
      ),
    );

    return decorations;
  }

  Widget _buildHeader(BuildContext context) {
    // 주간 범위 계산 (월~일)
    final weekStart = date.subtract(Duration(days: date.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final formattedRange =
        '${DateFormat('M/d').format(weekStart)} - ${DateFormat('M/d').format(weekEnd)}';
    final textColor =
        context.isDark ? context.colors.textPrimary : DSColors.textPrimary;

    return Row(
      children: [
        // 이모지
        const Text(
          '📈',
          style: TextStyle(fontSize: 24),
        ),
        const SizedBox(width: DSSpacing.sm),

        // 날짜 + 타이틀
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '주간 리포트',
                style: context.heading4.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: DSSpacing.xxs),
              Text(
                formattedRange,
                style: context.typography.labelTiny.copyWith(
                  color: textColor.withValues(alpha: 0.5),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),

        // 주간 아이콘
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _orangeAccent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.calendar_view_week_outlined,
            size: 20,
            color: context.isDark ? _orangeAccent : _amberAccent,
          ),
        ),
        const SizedBox(width: DSSpacing.sm),
        // 좋아요 + 공유 버튼
        FortuneActionButtons(
          contentId: 'weekly_review_${date.millisecondsSinceEpoch}',
          contentType: 'weekly-review',
          fortuneType: 'weekly-review',
          shareTitle: '주간 리포트',
          shareContent: summary,
          iconSize: 18,
          iconColor: context.isDark ? _orangeAccent : _amberAccent,
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _orangeAccent.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '🔥',
            style: context.typography.labelSmall.copyWith(
              color: context.colors.textPrimary.withValues(alpha: 0.3),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _orangeAccent.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    final textColor =
        context.isDark ? context.colors.textPrimary : DSColors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _orangeAccent.withValues(alpha: context.isDark ? 0.15 : 0.1),
            _amberAccent.withValues(alpha: context.isDark ? 0.1 : 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _orangeAccent.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📋', style: TextStyle(fontSize: 18)),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '이번 주 요약',
                style: context.bodyMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            summary,
            style: context.bodyMedium.copyWith(
              color: textColor.withValues(alpha: 0.9),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsSection(BuildContext context) {
    final textColor =
        context.isDark ? context.colors.textPrimary : DSColors.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('📈', style: TextStyle(fontSize: 16)),
            const SizedBox(width: DSSpacing.sm),
            Text(
              '성장 트렌드',
              style: context.bodyMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...trends.asMap().entries.map((entry) {
          final index = entry.key;
          final trend = entry.value;
          return _buildTrendItem(context, index + 1, trend)
              .animate()
              .fadeIn(
                  duration: 300.ms,
                  delay: Duration(milliseconds: 400 + (index * 150)))
              .slideX(begin: 0.1, end: 0);
        }),
      ],
    );
  }

  Widget _buildTrendItem(BuildContext context, int index, String text) {
    final textColor =
        context.isDark ? context.colors.textPrimary : DSColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _orangeAccent.withValues(alpha: context.isDark ? 0.4 : 0.3),
                  _amberAccent.withValues(alpha: context.isDark ? 0.3 : 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '↗',
                style: context.typography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                      context.isDark ? _orangeAccent : Colors.orange.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.colors.surface
                    .withValues(alpha: context.isDark ? 0.05 : 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                text,
                style: context.bodySmall.copyWith(
                  color: textColor.withValues(alpha: 0.9),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    final textColor =
        context.isDark ? context.colors.textPrimary : DSColors.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🎯', style: TextStyle(fontSize: 16)),
            const SizedBox(width: DSSpacing.sm),
            Text(
              '다음 주 액션 제안',
              style: context.bodyMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...actions.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;
          return _buildActionItem(context, index + 1, action)
              .animate()
              .fadeIn(
                  duration: 300.ms,
                  delay: Duration(milliseconds: 600 + (index * 150)))
              .slideX(begin: 0.1, end: 0);
        }),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, int index, String text) {
    final textColor =
        context.isDark ? context.colors.textPrimary : DSColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _amberAccent.withValues(alpha: context.isDark ? 0.3 : 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '$index',
                style: context.typography.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                      context.isDark ? _orangeAccent : Colors.orange.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.colors.surface
                    .withValues(alpha: context.isDark ? 0.05 : 0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _orangeAccent.withValues(alpha: 0.15),
                ),
              ),
              child: Text(
                text,
                style: context.bodySmall.copyWith(
                  color: textColor.withValues(alpha: 0.9),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClosingMessage(BuildContext context) {
    final textColor =
        context.isDark ? context.colors.textPrimary : DSColors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _amberAccent.withValues(alpha: context.isDark ? 0.15 : 0.1),
            _orangeAccent.withValues(alpha: context.isDark ? 0.1 : 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _amberAccent.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Text('💪', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '한 주도 수고하셨어요!',
                  style: context.bodyMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: DSSpacing.xs),
                Text(
                  '다음 주도 함께 성장해요. 당신의 노력이 빛날 거예요! ✨',
                  style: context.bodySmall.copyWith(
                    color: textColor.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
