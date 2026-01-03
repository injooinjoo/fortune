import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/typography_unified.dart';

/// 감사일기 결과 카드 (일기장 스타일)
///
/// 채팅 내에서 감사일기 결과를 따뜻하고 감성적으로 표시합니다.
/// - 종이 느낌의 크림색 배경
/// - 손글씨 느낌의 폰트 스타일
/// - 하트 아이콘과 부드러운 장식
/// - 공유 기능
class ChatGratitudeResultCard extends StatelessWidget {
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

  // 크림색 배경
  static const _creamLight = Color(0xFFFFF8E7);
  static const _creamDark = Color(0xFFFFFAF0);
  // 다크모드 배경
  static const _darkBg1 = Color(0xFF2A2520);
  static const _darkBg2 = Color(0xFF1E1E1E);
  // 액센트 색상
  static const _pinkAccent = Color(0xFFE8B4B8);
  static const _goldAccent = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // 종이 느낌 배경 그라데이션
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
                  _buildDivider(isDark),

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

                  // 공유 버튼
                  _buildShareButton(context, isDark)
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 1000.ms),
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
    final formattedDate = DateFormat('M월 d일').format(date);
    final textColor = isDark ? Colors.white : const Color(0xFF4A3728);

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
              const SizedBox(height: 2),
              Text(
                'Gratitude Journal',
                style: TextStyle(
                  fontSize: 10,
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
            color: isDark ? _pinkAccent : const Color(0xFF8B6914),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
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
            style: TextStyle(
              fontSize: 12,
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3),
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
    final textColor = isDark ? Colors.white : const Color(0xFF4A3728);

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
          child: Center(
            child: Text(
              '💛',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 감사 내용
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (isDark ? _pinkAccent : _goldAccent).withValues(alpha: 0.2),
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
    final textColor = isDark ? Colors.white : const Color(0xFF4A3728);

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
                const SizedBox(height: 4),
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

  Widget _buildShareButton(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () => _shareGratitude(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _pinkAccent.withValues(alpha: 0.3),
                  _pinkAccent.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.share_rounded,
                  size: 14,
                  color: isDark ? _pinkAccent : const Color(0xFF8B6914),
                ),
                const SizedBox(width: 6),
                Text(
                  '공유',
                  style: context.labelSmall.copyWith(
                    color: isDark ? _pinkAccent : const Color(0xFF8B6914),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _shareGratitude(BuildContext context) {
    HapticFeedback.mediumImpact();

    final formattedDate = DateFormat('M월 d일').format(date);
    final shareText = '''
✨ $formattedDate의 감사일기

💛 $gratitude1
💛 $gratitude2
💛 $gratitude3

오늘도 감사한 하루였네요 🌸
작은 것에 감사하는 습관이 행복을 키워줘요.

#감사일기 #오늘의감사
''';

    Share.share(shareText);
  }
}
