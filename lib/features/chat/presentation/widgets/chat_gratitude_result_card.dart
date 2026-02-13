import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/fortune_action_buttons.dart';

/// 감사일기 결과 카드 (일기장 스타일)
///
/// 채팅 내에서 감사일기 결과를 따뜻하고 감성적으로 표시합니다.
/// - 종이 느낌의 크림색 배경
/// - 손글씨 느낌의 폰트 스타일
/// - 하트 아이콘과 부드러운 장식
/// - 공유 기능
class ChatGratitudeResultCard extends ConsumerWidget {
  final String gratitude1;
  final String gratitude2;
  final String gratitude3;
  final DateTime date;

  const ChatGratitudeResultCard({
    super.key,
    required this.gratitude1,
    required this.gratitude2,
    required this.gratitude3,
    required this.date,
  });

  // 디자인 색상 → DSColors 기반 (ChatGPT monochrome style)
  static const _creamLight = DSColors.backgroundSecondary;
  static const _creamDark = DSColors.background;
  // 다크모드 배경
  static const _darkBg1 = DSColors.background;
  static const _darkBg2 = DSColors.backgroundSecondary;
  // 액센트 색상 - semantic colors
  static const _pinkAccent = DSColors.error;
  static const _goldAccent = DSColors.warning;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // 종이 느낌 배경 그라데이션
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark ? [_darkBg1, _darkBg2] : [_creamLight, _creamDark],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? _pinkAccent.withValues(alpha: 0.3)
              : _pinkAccent.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? _pinkAccent : _goldAccent).withValues(alpha: 0.15),
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
            // 배경 장식 (꽃잎 패턴)
            ..._buildBackgroundDecorations(isDark),

            // 메인 콘텐츠
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더 (날짜 + 이모지)
                  _buildHeader(context, isDark)
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: -0.1, end: 0),

                  const SizedBox(height: 16),

                  // 구분선
                  _buildDivider(context),

                  const SizedBox(height: 16),

                  // 감사 항목들
                  _buildGratitudeItem(context, 1, gratitude1, isDark)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms)
                      .slideX(begin: -0.05, end: 0),

                  const SizedBox(height: 12),

                  _buildGratitudeItem(context, 2, gratitude2, isDark)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 400.ms)
                      .slideX(begin: -0.05, end: 0),

                  const SizedBox(height: 12),

                  _buildGratitudeItem(context, 3, gratitude3, isDark)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 600.ms)
                      .slideX(begin: -0.05, end: 0),

                  const SizedBox(height: 20),

                  // 마무리 메시지
                  _buildClosingMessage(context, isDark)
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 800.ms),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundDecorations(bool isDark) {
    final decorations = <Widget>[];
    final baseColor = isDark ? _pinkAccent : _goldAccent;

    // 우측 상단 꽃잎 장식
    decorations.add(
      Positioned(
        right: 15,
        top: 15,
        child: Text(
          '🌸',
          style: TextStyle(
            fontSize: 20,
            color: baseColor.withValues(alpha: 0.3),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.1, 1.1),
              duration: 2000.ms,
            ),
      ),
    );

    // 좌측 하단 하트 장식
    decorations.add(
      Positioned(
        left: 20,
        bottom: 60,
        child: Text(
          '💛',
          style: TextStyle(
            fontSize: 16,
            color: baseColor.withValues(alpha: 0.25),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(duration: 1500.ms)
            .fadeOut(duration: 1500.ms),
      ),
    );

    return decorations;
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final typography = context.typography;
    final formattedDate = DateFormat('M월 d일').format(date);
    final textColor = isDark ? Colors.white : DSColors.textPrimary;

    return Row(
      children: [
        // 이모지
        const Text(
          '✨',
          style: TextStyle(fontSize: 24),
        ),
        const SizedBox(width: 8),

        // 날짜 + 타이틀
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$formattedDate의 감사일기',
                style: context.heading4.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: DSSpacing.xxs),
              Text(
                'Gratitude Journal',
                style: typography.labelTiny.copyWith(
                  color: textColor.withValues(alpha: 0.5),
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),

        // 노트 아이콘
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _pinkAccent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.auto_stories_rounded,
            size: 20,
            color: isDark ? _pinkAccent : DSColors.warning,
          ),
        ),
        const SizedBox(width: 8),
        // 좋아요 + 공유 버튼
        FortuneActionButtons(
          contentId: 'gratitude_${date.millisecondsSinceEpoch}',
          contentType: 'gratitude',
          fortuneType: 'gratitude',
          shareTitle: '${DateFormat('M월 d일').format(date)}의 감사일기',
          shareContent: '$gratitude1, $gratitude2, $gratitude3',
          iconSize: 18,
          iconColor: isDark ? _pinkAccent : DSColors.warning,
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    final typography = context.typography;
    final isDark = context.isDark;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  (isDark ? _pinkAccent : _goldAccent).withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '🍃',
            style: typography.bodySmall.copyWith(
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
                  (isDark ? _pinkAccent : _goldAccent).withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGratitudeItem(
    BuildContext context,
    int index,
    String text,
    bool isDark,
  ) {
    final textColor = isDark ? Colors.white : DSColors.textPrimary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 하트 아이콘 (번호 대신)
        Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: _pinkAccent.withValues(alpha: isDark ? 0.2 : 0.15),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              '💛',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 감사 내용
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color:
                  context.colors.surface.withValues(alpha: isDark ? 0.05 : 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    (isDark ? _pinkAccent : _goldAccent).withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              text,
              style: context.bodyMedium.copyWith(
                color: textColor.withValues(alpha: 0.9),
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClosingMessage(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : DSColors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _pinkAccent.withValues(alpha: isDark ? 0.15 : 0.1),
            _goldAccent.withValues(alpha: isDark ? 0.1 : 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _pinkAccent.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Text('🌸', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘도 감사한 하루였네요',
                  style: context.bodyMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: DSSpacing.xs),
                Text(
                  '작은 것에 감사하는 습관이 행복을 키워줘요 💛',
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
