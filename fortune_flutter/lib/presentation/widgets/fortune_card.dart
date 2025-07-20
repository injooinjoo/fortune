import 'package:flutter/material.dart';
import '../../shared/glassmorphism/glass_container.dart';

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
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Light mode용 밝은 그라데이션 색상
    final lightModeGradients = {
      // 사주팔자 - 밝은 노란색
      0xFF000000: [Color(0xFFFFF8E1), Color(0xFFFFF3CD)],
      // AI 관상 - 밝은 회색
      0xFF1A1A1A: [Color(0xFFF5F5F5), Color(0xFFEEEEEE)],
      // 프리미엄 - 밝은 보라색
      0xFF2C2C2C: [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
      // 전체 운세 - 밝은 파란색
      0xFF4A4A4A: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
    };
    
    List<Color>? adjustedGradient;
    if (gradient != null && !isDarkMode) {
      // Light mode에서는 밝은 색상으로 변경
      adjustedGradient = lightModeGradients[gradient!.first.value] ?? 
          gradient!.map((color) => Color.lerp(color, Colors.white, 0.85)!).toList();
    } else {
      adjustedGradient = gradient;
    }
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: adjustedGradient != null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: adjustedGradient,
                )
              : null,
          color: adjustedGradient == null ? (backgroundColor ?? (isDarkMode ? Color(0xFF1F2937) : Colors.white)) : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (adjustedGradient?.first ?? theme.colorScheme.primary).withValues(alpha: isDarkMode ? 0.3 : 0.15),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Emoji or Icon
                  if (emoji != null)
                    Text(
                      emoji!,
                      style: TextStyle(fontSize: 40),
                    )
                  else
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        icon,
                        size: 28,
                        color: adjustedGradient != null 
                            ? (isDarkMode ? Colors.white : (iconColor ?? theme.colorScheme.primary))
                            : (iconColor ?? theme.colorScheme.primary),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: adjustedGradient != null 
                          ? (isDarkMode ? Colors.white : theme.colorScheme.onSurface)
                          : theme.colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: adjustedGradient != null 
                          ? (isDarkMode ? Colors.white.withValues(alpha: 0.9) : theme.colorScheme.onSurface.withValues(alpha: 0.6))
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (badge != null) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badge!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: adjustedGradient != null 
                              ? (isDarkMode ? Colors.white : theme.textTheme.bodyMedium?.color)
                              : theme.textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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