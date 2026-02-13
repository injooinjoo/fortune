import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/fortune_action_buttons.dart';

/// 하루 회고 결과 카드
///
/// 채팅 내에서 일일 회고 결과를 따뜻하고 성찰적인 톤으로 표시합니다.
/// - 오늘의 하이라이트
/// - 오늘 배운 점
/// - 내일을 위한 한 마디
class ChatDailyReviewCard extends ConsumerWidget {
  final String highlight;
  final String learning;
  final String tomorrow;
  final DateTime date;

  const ChatDailyReviewCard({
    super.key,
    required this.highlight,
    required this.learning,
    required this.tomorrow,
    required this.date,
  });

  // 디자인 색상 → DSColors 기반 (ChatGPT monochrome style)
  static const _creamLight = DSColors.backgroundSecondary;
  static const _creamDark = DSColors.background;
  // 다크모드 배경
  static const _darkBg1 = DSColors.background;
  static const _darkBg2 = DSColors.backgroundSecondary;
  // 액센트 색상 - semantic colors
  static const _mintAccent = DSColors.success;
  static const _tealAccent = Color(0xFF20C997);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark ? [_darkBg1, _darkBg2] : [_creamLight, _creamDark],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? _mintAccent.withValues(alpha: 0.3)
              : _mintAccent.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _mintAccent.withValues(alpha: 0.15),
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

                  // 오늘의 하이라이트
                  _buildHighlightSection(context)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms)
                      .slideX(begin: -0.05, end: 0),

                  const SizedBox(height: 16),

                  // 오늘 배운 점
                  _buildLearningSection(context)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 400.ms)
                      .slideX(begin: -0.05, end: 0),

                  const SizedBox(height: 16),

                  // 내일을 위한 한 마디
                  _buildTomorrowSection(context)
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 600.ms),

                  const SizedBox(height: 16),
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

    // 우측 상단 달 장식
    decorations.add(
      Positioned(
        right: 15,
        top: 15,
        child: const Text(
          '🌙',
          style: TextStyle(fontSize: 20),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(duration: 2000.ms)
            .fade(duration: 2000.ms, begin: 1.0, end: 0.6),
      ),
    );

    // 좌측 하단 별 장식
    decorations.add(
      Positioned(
        left: 20,
        bottom: 60,
        child: Text(
          '⭐',
          style: context.typography.bodyMedium.copyWith(
            color: Colors.amber.withValues(alpha: 0.5),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.2, 1.2),
              duration: 1500.ms,
            ),
      ),
    );

    return decorations;
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = context.isDark;
    final formattedDate = DateFormat('M월 d일 (E)', 'ko').format(date);
    final textColor =
        isDark ? context.colors.textPrimary : DSColors.textPrimary;

    return Row(
      children: [
        // 이모지
        const Text(
          '📝',
          style: TextStyle(fontSize: 24),
        ),
        const SizedBox(width: DSSpacing.sm),

        // 날짜 + 타이틀
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '하루 회고',
                style: context.heading4.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: DSSpacing.xxs),
              Text(
                formattedDate,
                style: context.typography.labelTiny.copyWith(
                  color: textColor.withValues(alpha: 0.5),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),

        // 회고 아이콘
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _mintAccent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.edit_note_outlined,
            size: 20,
            color: isDark ? _mintAccent : _tealAccent,
          ),
        ),
        const SizedBox(width: DSSpacing.sm),
        // 좋아요 + 공유 버튼
        FortuneActionButtons(
          contentId: 'daily_review_${date.millisecondsSinceEpoch}',
          contentType: 'daily_review',
          fortuneType: 'daily_review',
          shareTitle: '하루 회고 - ${DateFormat('M월 d일').format(date)}',
          shareContent: '오늘의 하이라이트: $highlight\n배운 점: $learning',
          iconSize: 18,
          iconColor: isDark ? _mintAccent : _tealAccent,
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
                  _mintAccent.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '🌿',
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
                  _mintAccent.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightSection(BuildContext context) {
    final isDark = context.isDark;
    final textColor =
        isDark ? context.colors.textPrimary : DSColors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _mintAccent.withValues(alpha: isDark ? 0.15 : 0.1),
            _tealAccent.withValues(alpha: isDark ? 0.1 : 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _mintAccent.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 18)),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '오늘의 하이라이트',
                style: context.bodyMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            highlight,
            style: context.bodyMedium.copyWith(
              color: textColor.withValues(alpha: 0.9),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningSection(BuildContext context) {
    final isDark = context.isDark;
    final textColor =
        isDark ? context.colors.textPrimary : DSColors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: isDark ? 0.05 : 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _mintAccent.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 18)),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '오늘 배운 점',
                style: context.bodyMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            learning,
            style: context.bodyMedium.copyWith(
              color: textColor.withValues(alpha: 0.9),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTomorrowSection(BuildContext context) {
    final isDark = context.isDark;
    final textColor =
        isDark ? context.colors.textPrimary : DSColors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _tealAccent.withValues(alpha: isDark ? 0.2 : 0.15),
            _mintAccent.withValues(alpha: isDark ? 0.15 : 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _tealAccent.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const Text('🌅', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '내일을 위한 한 마디',
                  style: context.bodyMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: DSSpacing.sm),
                Text(
                  tomorrow,
                  style: context.bodyMedium.copyWith(
                    color: textColor.withValues(alpha: 0.9),
                    height: 1.5,
                    fontStyle: FontStyle.italic,
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
