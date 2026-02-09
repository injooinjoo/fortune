import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/design_system/design_system.dart';

class FortuneCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final String? badge;
  final Color? iconColor;
  final Color? backgroundColor;
  final String? emoji;
  final List<Color>? gradient;

  const FortuneCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.badge,
    this.iconColor,
    this.backgroundColor,
    this.emoji,
    this.gradient});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Light mode용 밝은 그라데이션 색상 (ChatGPT monochrome style)
    final lightModeGradients = {
      // 사주팔자 - 한지 크림 그라데이션
      0xFF000000: [DSColors.backgroundSecondary, DSColors.backgroundSecondary],
      // AI 관상 - 밝은 회색
      0xFF1A1A1A: [const Color(0xFFF5F5F5), const Color(0xFFEEEEEE)], // 고유 색상 - 라이트모드 그라데이션
      // 프리미엄 - 밝은 보라색
      0xFF2C2C2C: [DSColors.accentSecondary, const Color(0xFFE1BEE7)], // 고유 색상 - 보라 그라데이션 끝
      // 전체 운세 - 밝은 파란색
      0xFF4A4A4A: [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)], // 고유 색상 - 라이트모드 그라데이션
    };
    
    List<Color>? adjustedGradient;
    if (gradient != null && !isDarkMode) {
      // Light mode에서는 밝은 색상으로 변경
      adjustedGradient = lightModeGradients[gradient!.first.toARGB32()] ??
          gradient!.map((color) => Color.lerp(color, DSColors.textPrimary, 0.85)!).toList();
    } else {
      adjustedGradient = gradient;
    }
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSpacing.spacing1 * 45.0,
        decoration: BoxDecoration(
          gradient: adjustedGradient != null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: adjustedGradient)
              : null,
          color: adjustedGradient == null
              ? (backgroundColor ?? (isDarkMode ? DSColors.surface : DSColors.surfaceDark))
              : null,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
          boxShadow: [
            BoxShadow(
              color: (adjustedGradient?.first ?? theme.colorScheme.primary)
                  .withValues(alpha: isDarkMode ? 0.3 : 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4))]),
        child: Material(
          color: Colors.white.withValues(alpha: 0.0),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
            child: Padding(
              padding: AppSpacing.paddingAll20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Emoji or Icon
                  if (emoji != null)
                    Text(
                      emoji!,
                      style: Theme.of(context).textTheme.displaySmall,
                    )
                  else
                    Container(
                      width: 50,
                      height: AppSpacing.spacing12 * 1.04,
                      decoration: BoxDecoration(
                        color: DSColors.textPrimary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge)),
                      child: Icon(
                        icon,
                        size: AppDimensions.iconSizeLarge,
                        color: adjustedGradient != null
                            ? (isDarkMode ? DSColors.textPrimary : (iconColor ?? theme.colorScheme.primary))
                            : (iconColor ?? theme.colorScheme.primary),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.spacing4),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: adjustedGradient != null
                          ? (isDarkMode ? DSColors.textPrimary : theme.colorScheme.onSurface)
                          : theme.colorScheme.onSurface,
                      letterSpacing: -0.5),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                  const SizedBox(height: AppSpacing.spacing1),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: adjustedGradient != null
                          ? (isDarkMode
                              ? DSColors.textPrimary.withValues(alpha: 0.9)
                              : theme.colorScheme.onSurface.withValues(alpha: 0.6))
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                  if (badge != null) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spacing3,
                        vertical: AppSpacing.spacing1),
                      decoration: BoxDecoration(
                        color: DSColors.textPrimary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge)),
                      child: Text(
                        badge!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: adjustedGradient != null
                              ? (isDarkMode ? DSColors.textPrimary : theme.textTheme.bodyMedium?.color)
                              : theme.textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.w600)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}