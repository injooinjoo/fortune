import 'package:flutter/material.dart';
import 'package:fortune/core/theme/toss_design_system.dart';

/// 토스 스타일 리스트 타일
/// 아이콘, 타이틀, 서브타이틀, 트레일링 위젯을 지원
class TossListTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final bool showDivider;
  final bool isEnabled;
  final Color? backgroundColor;

  const TossListTile({
    super.key,
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding,
    this.showDivider = false,
    this.isEnabled = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final Widget content = Container(
      color: backgroundColor ?? (isDark ? TossDesignSystem.grayDark50 : TossDesignSystem.white),
      child: Column(
        children: [
          Material(
            color: TossDesignSystem.transparent,
            child: InkWell(
              onTap: isEnabled ? () {
                if (onTap != null) {
                  TossDesignSystem.hapticLight();
                  onTap!();
                }
              } : null,
              child: Padding(
                padding: padding ?? const EdgeInsets.symmetric(
                  horizontal: TossDesignSystem.spacingL,
                  vertical: TossDesignSystem.spacingM,
                ),
                child: Row(
                  children: [
                    if (leading != null) ...[
                      _buildLeading(context),
                      const SizedBox(width: TossDesignSystem.spacingM),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TossDesignSystem.body1.copyWith(
                              color: isEnabled 
                                ? (isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900)
                                : (isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: TossDesignSystem.spacingXXS),
                            Text(
                              subtitle!,
                              style: TossDesignSystem.body3.copyWith(
                                color: isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: TossDesignSystem.spacingM),
                      trailing!,
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              thickness: 1,
              color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
              indent: leading != null ? TossDesignSystem.spacingL + 40 + TossDesignSystem.spacingM : TossDesignSystem.spacingL,
              endIndent: TossDesignSystem.spacingL,
            ),
        ],
      ),
    );
    
    return content;
  }
  
  Widget _buildLeading(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (leading is Icon) {
      final icon = leading as Icon;
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray100,
          borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
        ),
        child: Icon(
          icon.icon,
          color: icon.color ?? (isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700),
          size: 20,
        ),
      );
    }
    
    return SizedBox(
      width: 40,
      height: 40,
      child: leading,
    );
  }
}

/// 토스 스타일 섹션 헤더
class TossListSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  const TossListSection({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      color: isDark ? TossDesignSystem.grayDark50 : TossDesignSystem.gray50,
      padding: padding ?? const EdgeInsets.fromLTRB(
        TossDesignSystem.spacingL,
        TossDesignSystem.spacingM,
        TossDesignSystem.spacingL,
        TossDesignSystem.spacingS,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TossDesignSystem.caption.copyWith(
                    color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: TossDesignSystem.spacingXXS),
                  Text(
                    subtitle!,
                    style: TossDesignSystem.small.copyWith(
                      color: isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// 토스 스타일 리스트 아이템 (더 복잡한 레이아웃)
class TossComplexListTile extends StatelessWidget {
  final Widget? icon;
  final String title;
  final String? subtitle;
  final String? value;
  final String? valueLabel;
  final Color? valueColor;
  final Widget? badge;
  final VoidCallback? onTap;
  final bool showArrow;

  const TossComplexListTile({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.value,
    this.valueLabel,
    this.valueColor,
    this.badge,
    this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Material(
      color: isDark ? TossDesignSystem.grayDark50 : TossDesignSystem.white,
      child: InkWell(
        onTap: onTap != null ? () {
          TossDesignSystem.hapticLight();
          onTap!();
        } : null,
        child: Container(
          padding: const EdgeInsets.all(TossDesignSystem.spacingL),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: TossDesignSystem.spacingM),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TossDesignSystem.body1.copyWith(
                            color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: TossDesignSystem.spacingXS),
                          badge!,
                        ],
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: TossDesignSystem.spacingXXS),
                      Text(
                        subtitle!,
                        style: TossDesignSystem.body3.copyWith(
                          color: isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (value != null || valueLabel != null) ...[
                const SizedBox(width: TossDesignSystem.spacingM),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (value != null)
                      Text(
                        value!,
                        style: TossDesignSystem.body1.copyWith(
                          color: valueColor ?? (isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900),
                          fontWeight: FontWeight.w600,
                          fontFamily: value!.contains(RegExp(r'\d')) ? TossDesignSystem.fontFamilyNumber : null,
                        ),
                      ),
                    if (valueLabel != null) ...[
                      const SizedBox(height: TossDesignSystem.spacingXXS),
                      Text(
                        valueLabel!,
                        style: TossDesignSystem.caption.copyWith(
                          color: isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              if (showArrow && onTap != null) ...[
                const SizedBox(width: TossDesignSystem.spacingS),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 토스 스타일 배지
class TossBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;

  const TossBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TossDesignSystem.spacingXS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? TossDesignSystem.tossBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(TossDesignSystem.radiusXS),
      ),
      child: Text(
        text,
        style: TossDesignSystem.small.copyWith(
          color: textColor ?? TossDesignSystem.tossBlue,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}