import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/toss_design_system.dart';

/// 운세 카드 컴포넌트 - 토스 디자인 시스템 적용
class FortuneCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final bool showBorder;
  final bool animate;
  final Duration? animationDelay;
  final Widget? leading;
  final Widget? trailing;
  final double? elevation;

  const FortuneCard({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.showBorder = false,
    this.animate = true,
    this.animationDelay,
    this.leading,
    this.trailing,
    this.elevation,
  });

  /// 운세 결과 카드 팩토리
  factory FortuneCard.result({
    required String title,
    required String content,
    int? score,
    VoidCallback? onTap,
    Widget? icon,
    Color? scoreColor,
  }) {
    return FortuneCard(
      title: title,
      onTap: onTap,
      leading: icon,
      trailing: score != null ? _ScoreBadge(score: score, color: scoreColor) : null,
      child: Text(
        content,
        style: TossDesignSystem.body2.copyWith(
          color: TossDesignSystem.gray700,
          height: 1.6,
        ),
      ),
    );
  }

  /// 운세 선택 카드 팩토리
  factory FortuneCard.selection({
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
    Widget? icon,
    String? badge,
  }) {
    return FortuneCard(
      title: title,
      subtitle: description,
      onTap: onTap,
      showBorder: true,
      backgroundColor: isSelected 
          ? TossDesignSystem.tossBlue.withValues(alpha: 0.05)
          : null,
      leading: icon != null 
          ? Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected 
                    ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                    : TossDesignSystem.gray100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: icon),
            )
          : null,
      trailing: isSelected 
          ? Icon(
              Icons.check_circle,
              color: TossDesignSystem.tossBlue,
              size: 24,
            )
          : badge != null 
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: TossDesignSystem.caption.copyWith(
                      color: TossDesignSystem.tossBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : null,
      child: const SizedBox.shrink(),
    );
  }

  /// 운세 정보 카드 팩토리
  factory FortuneCard.info({
    required String title,
    required String content,
    Widget? icon,
    Color? iconColor,
    bool showArrow = false,
    VoidCallback? onTap,
  }) {
    return FortuneCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (iconColor ?? TossDesignSystem.tossBlue).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: IconTheme(
                  data: IconThemeData(
                    color: iconColor ?? TossDesignSystem.tossBlue,
                    size: 20,
                  ),
                  child: icon,
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TossDesignSystem.heading4.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TossDesignSystem.body3.copyWith(
                    color: TossDesignSystem.gray600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (showArrow)
            Icon(
              Icons.arrow_forward_ios,
              color: TossDesignSystem.gray400,
              size: 16,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Widget cardContent = Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white),
        borderRadius: BorderRadius.circular(16),
        border: showBorder 
            ? Border.all(
                color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
                width: 1,
              )
            : null,
        boxShadow: elevation != null && elevation! > 0
            ? [
                BoxShadow(
                  color: TossDesignSystem.black.withValues(alpha: 0.04),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Material(
        color: TossDesignSystem.white.withValues(alpha: 0.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null || leading != null || trailing != null)
                  Row(
                    children: [
                      if (leading != null) ...[
                        leading!,
                        const SizedBox(width: 12),
                      ],
                      if (title != null)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title!,
                                style: TossDesignSystem.heading4.copyWith(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                                ),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  subtitle!,
                                  style: TossDesignSystem.body3.copyWith(
                                    color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      if (trailing != null) ...[
                        const SizedBox(width: 12),
                        trailing!,
                      ],
                    ],
                  ),
                if ((title != null || leading != null || trailing != null) && child is! SizedBox)
                  const SizedBox(height: 16),
                child,
              ],
            ),
          ),
        ),
      ),
    );

    if (animate) {
      return animationDelay != null
          ? cardContent
              .animate(delay: animationDelay!)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0)
          : cardContent
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0);
    }

    return cardContent;
  }
}

/// 점수 배지 위젯
class _ScoreBadge extends StatelessWidget {
  final int score;
  final Color? color;

  const _ScoreBadge({
    required this.score,
    this.color,
  });

  Color _getScoreColor(int score) {
    if (score >= 80) return TossDesignSystem.successGreen;
    if (score >= 60) return TossDesignSystem.tossBlue;
    if (score >= 40) return TossDesignSystem.warningOrange;
    return TossDesignSystem.errorRed;
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = color ?? _getScoreColor(score);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: scoreColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.stars_rounded,
            color: scoreColor,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '$score점',
            style: TossDesignSystem.caption.copyWith(
              color: scoreColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// 운세 카드 그룹
class FortuneCardGroup extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final double spacing;

  const FortuneCardGroup({
    super.key,
    required this.children,
    this.padding,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) SizedBox(height: spacing),
          ],
        ],
      ),
    );
  }
}