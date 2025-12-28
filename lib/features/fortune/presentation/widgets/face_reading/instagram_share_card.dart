import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/theme/typography_unified.dart';

/// 인스타그램 공유 카드
/// 1:1 비율, 감성 디자인으로 SNS 공유에 최적화
///
/// 핵심 가치: 위로·공감·공유 (자기계발 ❌)
/// 타겟: 2-30대 여성
///
/// **공유 제목**: "오늘의 얼굴 운세" ❌ → "오늘의 나" ✅
class InstagramShareCard extends StatelessWidget {
  /// 카드 크기 (정사각형)
  final double size;

  /// 핵심 인사이트 메시지
  final String insightMessage;

  /// 매력 포인트
  final String charmPoint;

  /// 오늘의 한줄 (감성 문구)
  final String todayQuote;

  /// 사용자 이름 (선택)
  final String? userName;

  /// 그라데이션 색상
  final List<Color>? gradientColors;

  /// 다크 모드 여부
  final bool isDark;

  const InstagramShareCard({
    super.key,
    this.size = 375,
    required this.insightMessage,
    required this.charmPoint,
    required this.todayQuote,
    this.userName,
    this.gradientColors,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ??
        [
          DSColors.accent,
          DSColors.accentSecondary,
        ];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors[0].withValues(alpha: 0.15),
            colors[1].withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.95),
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
        borderRadius: BorderRadius.circular(0), // 인스타용 정사각형
      ),
      child: Stack(
        children: [
          // 배경 패턴
          _buildBackgroundPattern(),

          // 콘텐츠
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 타이틀
                _buildTitle(context),
                const Spacer(),

                // 중앙 인사이트
                _buildMainInsight(context),
                const SizedBox(height: 24),

                // 매력 포인트
                _buildCharmPoint(context),
                const Spacer(),

                // 하단 문구
                _buildFooter(context),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  /// 배경 패턴
  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _ShareCardPatternPainter(
          color: DSColors.accent.withValues(alpha: 0.03),
        ),
      ),
    );
  }

  /// 타이틀
  Widget _buildTitle(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: DSColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✨', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                '오늘의 나',
                style: context.labelMedium.copyWith(
                  color: DSColors.accent,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (userName != null)
          Text(
            '@$userName',
            style: context.labelSmall.copyWith(
              color: DSColors.textSecondary.withValues(alpha: 0.6),
            ),
          ),
      ],
    );
  }

  /// 메인 인사이트
  Widget _buildMainInsight(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '"',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w300,
            color: DSColors.accent.withValues(alpha: 0.3),
            height: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          insightMessage,
          style: context.heading3.copyWith(
            color: DSColors.textPrimary,
            fontWeight: FontWeight.w600,
            height: 1.4,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  /// 매력 포인트
  Widget _buildCharmPoint(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DSColors.accent.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: DSColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('💫', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '나의 매력 포인트',
                  style: context.labelSmall.copyWith(
                    color: DSColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  charmPoint,
                  style: context.bodyMedium.copyWith(
                    color: DSColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 하단 푸터
  Widget _buildFooter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          todayQuote,
          style: context.labelMedium.copyWith(
            color: DSColors.textSecondary,
            fontStyle: FontStyle.italic,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // 앱 로고 (간단하게)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: DSColors.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'my morrow',
                style: context.labelSmall.copyWith(
                  color: DSColors.accent,
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
              ),
            ),
            const Spacer(),
            Text(
              '#오늘의나 #AI분석',
              style: context.labelSmall.copyWith(
                color: DSColors.textSecondary.withValues(alpha: 0.5),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 공유 카드 배경 패턴 페인터
class _ShareCardPatternPainter extends CustomPainter {
  final Color color;

  _ShareCardPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 원형 패턴
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        final x = (size.width / 7) * i;
        final y = (size.height / 7) * j;
        canvas.drawCircle(Offset(x, y), 3, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 공유 카드 변형 - 감정 중심
class EmotionShareCard extends StatelessWidget {
  final double size;
  final String emotion;
  final String emotionEmoji;
  final String message;
  final int emotionPercentage;
  final bool isDark;

  const EmotionShareCard({
    super.key,
    this.size = 375,
    required this.emotion,
    required this.emotionEmoji,
    required this.message,
    required this.emotionPercentage,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            DSColors.accentSecondary.withValues(alpha: 0.12),
            Colors.white,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이모지
            Text(
              emotionEmoji,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 24),

            // 감정 라벨
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: DSColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '오늘의 나는 $emotion',
                style: context.labelMedium.copyWith(
                  color: DSColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 퍼센티지
            Text(
              '$emotionPercentage%',
              style: context.displayMedium.copyWith(
                color: DSColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            // 메시지
            Text(
              message,
              style: context.bodyMedium.copyWith(
                color: DSColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),

            // 앱 로고
            Text(
              'my morrow',
              style: context.labelSmall.copyWith(
                color: DSColors.textSecondary.withValues(alpha: 0.5),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
