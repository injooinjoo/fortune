import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/widgets/fortune_action_buttons.dart';
import '../../../../core/design_system/tokens/ds_obangseok_colors.dart';

/// AI 코칭 결과 카드
///
/// 채팅 내에서 AI 코칭 결과를 따뜻하고 격려하는 톤으로 표시합니다.
/// - 사용자 상황 요약
/// - AI 코칭 어드바이스
/// - 실천 가능한 액션 아이템 3-5개
/// - 응원 메시지
class ChatCoachingResultCard extends ConsumerWidget {
  final String situation;
  final String coachingAdvice;
  final List<String> actionItems;
  final DateTime date;

  const ChatCoachingResultCard({
    super.key,
    required this.situation,
    required this.coachingAdvice,
    required this.actionItems,
    required this.date,
  });

  // 동양화 스타일 - 한지 느낌 배경 (ObangseokColors 사용)
  static const _creamLight = ObangseokColors.misaek;
  static const _creamDark = ObangseokColors.misaekWarm;
  // 다크모드 배경
  static const _darkBg1 = ObangseokColors.meokLight;
  static const _darkBg2 = ObangseokColors.meok;
  // 액센트 색상 - 코칭 핑크
  static const _pinkAccent = DSFortuneColors.categoryCoaching;
  static const _purpleAccent = DSFortuneColors.categoryDecision;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [_darkBg1, _darkBg2]
              : [_creamLight, _creamDark],
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
            color: _pinkAccent.withValues(alpha: 0.15),
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
            ..._buildBackgroundDecorations(isDark),

            // 메인 콘텐츠
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더
                  _buildHeader(context, isDark)
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: -0.1, end: 0),

                  const SizedBox(height: 16),

                  // 구분선
                  _buildDivider(context),

                  const SizedBox(height: 16),

                  // 상황 요약
                  if (situation.isNotEmpty) ...[
                    _buildSituationSection(context, isDark)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms),
                    const SizedBox(height: 16),
                  ],

                  // 코칭 어드바이스
                  _buildAdviceSection(context, isDark)
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 400.ms)
                    .slideX(begin: -0.05, end: 0),

                  const SizedBox(height: 20),

                  // 액션 아이템
                  _buildActionItems(context, isDark),

                  const SizedBox(height: 20),

                  // 마무리 응원 메시지
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

    // 우측 상단 별 장식
    decorations.add(
      Positioned(
        right: 15,
        top: 15,
        child: const Text(
          '💫',
          style: TextStyle(fontSize: 20),
        )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
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
          '🌱',
          style: TextStyle(
            fontSize: 16,
            color: Colors.green.withValues(alpha: 0.5),
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
    final formattedDate = DateFormat('M월 d일 HH:mm').format(date);
    final textColor = isDark ? Colors.white : ObangseokColors.hwangDark;

    return Row(
      children: [
        // 이모지
        const Text(
          '🧠',
          style: TextStyle(fontSize: 24),
        ),
        const SizedBox(width: 8),

        // 날짜 + 타이틀
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '코칭 세션',
                style: context.heading4.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 10,
                  color: textColor.withValues(alpha: 0.5),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),

        // 코칭 아이콘
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _pinkAccent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.psychology_outlined,
            size: 20,
            color: isDark ? _pinkAccent : _purpleAccent,
          ),
        ),
        const SizedBox(width: 8),
        // 좋아요 + 공유 버튼
        FortuneActionButtons(
          contentId: 'coaching_${date.millisecondsSinceEpoch}',
          contentType: 'coaching',
          fortuneType: 'coaching',
          shareTitle: '코칭 세션 - ${DateFormat('M월 d일').format(date)}',
          shareContent: coachingAdvice,
          iconSize: 18,
          iconColor: isDark ? _pinkAccent : _purpleAccent,
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
                  _pinkAccent.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '✨',
            style: TextStyle(
              fontSize: 12,
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
                  _pinkAccent.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSituationSection(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : ObangseokColors.hwangDark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: isDark ? 0.05 : 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _pinkAccent.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💭', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '나의 상황',
                  style: context.bodySmall.copyWith(
                    color: textColor.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  situation,
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

  Widget _buildAdviceSection(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : ObangseokColors.hwangDark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _pinkAccent.withValues(alpha: isDark ? 0.15 : 0.1),
            _purpleAccent.withValues(alpha: isDark ? 0.1 : 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _pinkAccent.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💝', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                '코칭 어드바이스',
                style: context.bodyMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            coachingAdvice,
            style: context.bodyMedium.copyWith(
              color: textColor.withValues(alpha: 0.9),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItems(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : ObangseokColors.hwangDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🎯', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              '실천 액션 아이템',
              style: context.bodyMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...actionItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _buildActionItem(context, index + 1, item, isDark)
            .animate()
            .fadeIn(duration: 300.ms, delay: Duration(milliseconds: 600 + (index * 150)))
            .slideX(begin: 0.1, end: 0);
        }),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, int index, String text, bool isDark) {
    final textColor = isDark ? Colors.white : ObangseokColors.hwangDark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _pinkAccent.withValues(alpha: isDark ? 0.3 : 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '$index',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? _pinkAccent : _purpleAccent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.colors.surface.withValues(alpha: isDark ? 0.05 : 0.6),
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

  Widget _buildClosingMessage(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : ObangseokColors.hwangDark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _purpleAccent.withValues(alpha: isDark ? 0.15 : 0.1),
            _pinkAccent.withValues(alpha: isDark ? 0.1 : 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _purpleAccent.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Text('🌟', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘도 한 걸음 더 성장해요',
                  style: context.bodyMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '작은 실천이 큰 변화를 만들어요. 당신은 할 수 있어요! 💪',
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
