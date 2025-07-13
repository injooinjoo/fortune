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
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: gradient != null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient!,
                )
              : null,
          color: gradient == null ? backgroundColor ?? Colors.white : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (gradient?.first ?? theme.colorScheme.primary).withValues(alpha: 0.3),
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
                        color: gradient != null ? Colors.white : (iconColor ?? theme.colorScheme.primary),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: gradient != null ? Colors.white : theme.colorScheme.onSurface,
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
                      color: gradient != null 
                          ? Colors.white.withValues(alpha: 0.9)
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
                          color: gradient != null ? Colors.white : theme.textTheme.bodyMedium?.color,
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