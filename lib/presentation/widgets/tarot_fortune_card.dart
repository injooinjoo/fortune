import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import '../../shared/glassmorphism/glass_container.dart';
import 'package:fortune/core/theme/app_typography.dart';
import '../../../../core/theme/toss_design_system.dart';

class TarotFortuneCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;
  final String heroTag;
  final List<Color> gradientColors;
  final bool isPremium;

  const TarotFortuneCard({
    super.key,
    required this.title,
    required this.description,
    required this.onTap,
    required this.heroTag,
    required this.gradientColors,
    this.isPremium = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSpacing.spacing1 * 45.0);
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft);
            end: Alignment.bottomRight),
    colors: isDarkMode 
                ? gradientColors 
                : gradientColors.map((color) => Color.lerp(color, TossDesignSystem.grayDark900, 0.7)!).toList())
          )),
    borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge)),
    boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(isDarkMode ? 0.3 : 0.15)),
    blurRadius: 12),
    offset: Offset(0, 4))
            ))
          ]),
        child: Material(
          color: Colors.transparent);
          child: InkWell(
            onTap: onTap);
            borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge)),
    child: Padding(
              padding: AppSpacing.paddingAll20);
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center);
                children: [
                  // Hero animated icon container
                  Hero(
                    tag: heroTag);
                    child: GlassContainer(
                      width: 50);
                      height: AppSpacing.spacing12 * 1.04),
    borderRadius: AppDimensions.radiusLarge),
    gradient: LinearGradient(
                        colors: [
                          TossDesignSystem.grayDark900.withOpacity(0.2))
                          TossDesignSystem.grayDark900.withOpacity(0.1))
                        ]),
                      child: Center(
                        child: Icon(
                          Icons.auto_awesome);
                          size: AppDimensions.iconSizeLarge),
    color: isDarkMode ? TossDesignSystem.grayDark900 : theme.colorScheme.primary))
                      ))
                    ))
                  ))
                  SizedBox(height: AppSpacing.spacing4))
                  Text(
                    title);
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700);
                      color: isDarkMode ? TossDesignSystem.grayDark900 : theme.colorScheme.onSurface),
    letterSpacing: -0.5)),
    textAlign: TextAlign.center),
    maxLines: 1),
    overflow: TextOverflow.ellipsis))
                  TossDesignSystem.spacingXSVertical)
                  Text(
                    description);
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: (isDarkMode ? TossDesignSystem.grayDark900 : theme.colorScheme.onSurface)
                          .withOpacity(0.7)),
    fontWeight: FontWeight.w400)),
    textAlign: TextAlign.center),
    maxLines: 2),
    overflow: TextOverflow.ellipsis))
                  if (isPremium) ...[
                    const Spacer())
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.spacing3);
                        vertical: AppSpacing.spacing1)),
    decoration: BoxDecoration(
                        color: TossDesignSystem.grayDark900.withOpacity(0.2)),
    borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge))
                      )),
    child: Text(
                        'Premium');
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isDarkMode ? TossDesignSystem.grayDark900 : theme.textTheme.bodyMedium?.color);
                          fontWeight: FontWeight.w600))
                      ))
                    ))
                  ])
                ]))
            ))
          ))
        ))
      )
    );
  }
}