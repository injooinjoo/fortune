import 'package:flutter/material.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'dart:math' as math;

/// 토스 스타일 점수/수치 표시 카드
/// Toss 신용점수 화면처럼 큰 숫자와 원형 프로그레스를 표시
class TossScoreCard extends StatelessWidget {
  final String title;
  final String score;
  final String? subtitle;
  final String? description;
  final double? progress; // 0.0 ~ 1.0
  final Color? progressColor;
  final Widget? icon;
  final VoidCallback? onTap;
  final List<Widget>? additionalInfo;

  const TossScoreCard({
    super.key,
    required this.title,
    required this.score,
    this.subtitle,
    this.description,
    this.progress,
    this.progressColor,
    this.icon,
    this.onTap,
    this.additionalInfo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    Widget content = Container(
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(TossDesignSystem.radiusXL),
        boxShadow: isDark ? null : TossDesignSystem.shadowS,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상단 타이틀 영역
          Padding(
            padding: const EdgeInsets.fromLTRB(
              TossDesignSystem.spacingL,
              TossDesignSystem.spacingL,
              TossDesignSystem.spacingL,
              TossDesignSystem.spacingM,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TossDesignSystem.body1.copyWith(
                    color: isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray600,
                  ),
                ),
                if (icon != null) icon!,
              ],
            ),
          ),
          
          // 중앙 점수 표시 영역
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: TossDesignSystem.spacingL,
            ),
            child: progress != null
                ? _buildProgressScore(context)
                : _buildSimpleScore(context),
          ),
          
          // 하단 설명 영역
          if (description != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                TossDesignSystem.spacingL,
                TossDesignSystem.spacingM,
                TossDesignSystem.spacingL,
                TossDesignSystem.spacingL,
              ),
              child: Text(
                description!,
                style: TossDesignSystem.body2.copyWith(
                  color: isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          
          // 추가 정보 영역
          if (additionalInfo != null && additionalInfo!.isNotEmpty) ...[
            Divider(
              height: 1,
              color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
            ),
            Padding(
              padding: const EdgeInsets.all(TossDesignSystem.spacingL),
              child: Column(
                children: additionalInfo!,
              ),
            ),
          ],
        ],
      ),
    );
    
    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(TossDesignSystem.radiusXL),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TossDesignSystem.radiusXL),
          child: content,
        ),
      );
    }
    
    return content;
  }
  
  Widget _buildSimpleScore(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      children: [
        Text(
          score,
          style: TossDesignSystem.display1.copyWith(
            color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
            fontFamily: TossDesignSystem.fontFamilyNumber,
          ),
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: TossDesignSystem.spacingXS),
            child: Text(
              subtitle!,
              style: TossDesignSystem.body2.copyWith(
                color: progressColor ?? TossDesignSystem.tossBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildProgressScore(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = progressColor ?? TossDesignSystem.tossBlue;
    
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 배경 원
          CustomPaint(
            size: const Size(200, 200),
            painter: _CircleProgressPainter(
              progress: 1.0,
              color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
              strokeWidth: 12,
            ),
          ),
          // 진행률 원
          CustomPaint(
            size: const Size(200, 200),
            painter: _CircleProgressPainter(
              progress: progress!,
              color: color,
              strokeWidth: 12,
            ),
          ),
          // 중앙 텍스트
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                score,
                style: TossDesignSystem.display2.copyWith(
                  color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  fontFamily: TossDesignSystem.fontFamilyNumber,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TossDesignSystem.body2.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CircleProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 작은 점수 카드 (리스트용)
class TossScoreCardMini extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final Widget? icon;

  const TossScoreCardMini({
    super.key,
    required this.label,
    required this.value,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(TossDesignSystem.spacingM),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray50,
        borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: TossDesignSystem.spacingXS),
              ],
              Text(
                label,
                style: TossDesignSystem.caption.copyWith(
                  color: isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray600,
                ),
              ),
            ],
          ),
          const SizedBox(height: TossDesignSystem.spacingXS),
          Text(
            value,
            style: TossDesignSystem.heading3.copyWith(
              color: color ?? (isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900),
              fontFamily: TossDesignSystem.fontFamilyNumber,
            ),
          ),
        ],
      ),
    );
  }
}