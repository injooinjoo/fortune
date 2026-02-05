import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import '../../shared/glassmorphism/glass_container.dart';

/// 화살표(tail) 위치
enum ChatBubbleTailPosition {
  /// 왼쪽 화살표 (상대방 메시지)
  left,

  /// 오른쪽 화살표 (내 메시지)
  right,
}

/// 채팅 버블 공통 컴포넌트
///
/// 화살표(tail) 유무를 선택할 수 있는 범용 채팅 버블 위젯입니다.
///
/// ## 사용 예시
///
/// ```dart
/// // 화살표 없는 버블 (기본)
/// ChatBubble(
///   child: Text('메시지 내용'),
/// )
///
/// // 왼쪽 화살표 버블 (상대방)
/// ChatBubble(
///   showTail: true,
///   tailPosition: ChatBubbleTailPosition.left,
///   child: Text('상대방 메시지'),
/// )
///
/// // 글래스모피즘 스타일
/// ChatBubble(
///   useGlass: true,
///   gradient: LinearGradient(colors: [...]),
///   child: Text('글래스 버블'),
/// )
/// ```
class ChatBubble extends StatelessWidget {
  /// 버블 내부 컨텐츠
  final Widget child;

  /// 화살표 표시 여부 (기본값: false)
  final bool showTail;

  /// 화살표 위치 (기본값: left)
  final ChatBubbleTailPosition tailPosition;

  /// 배경색 (useGlass가 false일 때 사용)
  final Color? backgroundColor;

  /// 테두리 색상
  final Color? borderColor;

  /// 테두리 두께
  final double borderWidth;

  /// 모서리 둥글기
  final BorderRadius? borderRadius;

  /// 내부 패딩
  final EdgeInsets? padding;

  /// 글래스모피즘 효과 사용 여부
  final bool useGlass;

  /// 글래스모피즘 그라데이션 (useGlass가 true일 때 사용)
  final Gradient? gradient;

  /// 글래스모피즘 블러 강도
  final double blurStrength;

  /// 화살표 색상 (showTail이 true일 때 사용)
  final Color? tailColor;

  /// 화살표 세로 위치 오프셋
  final double tailVerticalOffset;

  const ChatBubble({
    super.key,
    required this.child,
    this.showTail = false,
    this.tailPosition = ChatBubbleTailPosition.left,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius,
    this.padding,
    this.useGlass = false,
    this.gradient,
    this.blurStrength = 10,
    this.tailColor,
    this.tailVerticalOffset = 40,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final colors = context.colors;

    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(DSRadius.lg);
    final effectivePadding = padding ?? const EdgeInsets.all(16);
    final effectiveBackgroundColor =
        backgroundColor ?? colors.backgroundSecondary;
    final effectiveBorderColor = borderColor ?? colors.surface.withValues(alpha: 0.1);
    final effectiveTailColor =
        tailColor ?? (useGlass ? DSColors.accentSecondary.withValues(alpha: 0.2) : effectiveBackgroundColor);

    // 화살표 위치에 따른 마진 계산
    final tailMargin = showTail
        ? (tailPosition == ChatBubbleTailPosition.left
            ? const EdgeInsets.only(left: 10)
            : const EdgeInsets.only(right: 10))
        : EdgeInsets.zero;

    return Container(
      margin: tailMargin,
      child: Stack(
        children: [
          // 메인 버블
          if (useGlass)
            GlassContainer(
              padding: effectivePadding,
              gradient: gradient ??
                  LinearGradient(
                    colors: isDark
                        ? [
                            DSColors.textTertiary.withValues(alpha: 0.1),
                            DSColors.textTertiary.withValues(alpha: 0.05),
                          ]
                        : [
                            colors.surface.withValues(alpha: 0.9),
                            colors.surface.withValues(alpha: 0.7),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
              borderRadius: effectiveBorderRadius,
              border: Border.all(
                color: effectiveBorderColor,
                width: borderWidth,
              ),
              blur: blurStrength,
              child: child,
            )
          else
            Container(
              padding: effectivePadding,
              decoration: BoxDecoration(
                color: effectiveBackgroundColor,
                borderRadius: effectiveBorderRadius,
                border: borderColor != null
                    ? Border.all(
                        color: effectiveBorderColor,
                        width: borderWidth,
                      )
                    : null,
              ),
              child: child,
            ),

          // 화살표 (tail)
          if (showTail)
            Positioned(
              top: tailVerticalOffset,
              left: tailPosition == ChatBubbleTailPosition.left ? -10 : null,
              right: tailPosition == ChatBubbleTailPosition.right ? -10 : null,
              child: CustomPaint(
                painter: _ChatBubbleTailPainter(
                  color: effectiveTailColor,
                  isLeft: tailPosition == ChatBubbleTailPosition.left,
                ),
                size: const Size(20, 20),
              ),
            ),
        ],
      ),
    );
  }
}

/// 채팅 버블 화살표 페인터
class _ChatBubbleTailPainter extends CustomPainter {
  final Color color;
  final bool isLeft;

  _ChatBubbleTailPainter({
    required this.color,
    this.isLeft = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    if (isLeft) {
      // 왼쪽 화살표 (오른쪽에서 왼쪽으로 뾰족함)
      path
        ..moveTo(size.width, 0)
        ..lineTo(size.width, size.height * 0.8)
        ..quadraticBezierTo(
          size.width * 0.5,
          size.height * 0.9,
          0,
          size.height * 0.5,
        )
        ..quadraticBezierTo(
          size.width * 0.5,
          size.height * 0.3,
          size.width,
          0,
        )
        ..close();
    } else {
      // 오른쪽 화살표 (왼쪽에서 오른쪽으로 뾰족함)
      path
        ..moveTo(0, 0)
        ..lineTo(0, size.height * 0.8)
        ..quadraticBezierTo(
          size.width * 0.5,
          size.height * 0.9,
          size.width,
          size.height * 0.5,
        )
        ..quadraticBezierTo(
          size.width * 0.5,
          size.height * 0.3,
          0,
          0,
        )
        ..close();
    }

    canvas.drawPath(path, paint);

    // 테두리
    final borderPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _ChatBubbleTailPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isLeft != isLeft;
  }
}
