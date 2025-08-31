import 'package:flutter/material.dart';
import '../../../../data/models/fortune_card_score.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import '../../../../core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/fortune_colors.dart';

/// Badge widget to display recommendation type on fortune cards
class FortuneRecommendationBadge extends StatelessWidget {
  final RecommendationType type;
  final double? score;
  final bool showScore;
  
  const FortuneRecommendationBadge({
    super.key,
    required this.type,
    this.score,
    this.showScore = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Get badge color and icon based on recommendation type
    final badgeData = _getBadgeData(type);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing2, vertical: AppSpacing.spacing1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: badgeData.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppDimensions.borderRadiusMedium,
        boxShadow: [
          BoxShadow(
            color: badgeData.gradientColors.first.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeData.icon,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: AppSpacing.spacing1),
          Text(
            type.displayName,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showScore && score != null) ...[
            const SizedBox(width: AppSpacing.spacing1),
            Text(
              '${(score! * 100).toInt()}%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
        ],
      ),;
  }

  _BadgeData _getBadgeData(RecommendationType type) {
    switch (type) {
      case RecommendationType.personalized:
        return _BadgeData(
          icon: Icons.person_rounded,
          gradientColors: [
            FortuneColors.spiritualPrimary,
            FortuneColors.spiritualPrimary,
          ],
        );
      case RecommendationType.popular:
        return _BadgeData(
          icon: Icons.trending_up_rounded,
          gradientColors: [
            TossDesignSystem.errorRed,
            TossDesignSystem.errorRed,
          ],
        );
      case RecommendationType.trending:
        return _BadgeData(
          icon: Icons.local_fire_department_rounded,
          gradientColors: [
            TossDesignSystem.warningOrange,
            TossDesignSystem.warningOrange,
          ],
        );
      case RecommendationType.newFortune:
        return _BadgeData(
          icon: Icons.new_releases_rounded,
          gradientColors: [
            TossDesignSystem.successGreen,
            TossDesignSystem.successGreen,
          ],
        );
      case RecommendationType.seasonal:
        return _BadgeData(
          icon: Icons.calendar_today_rounded,
          gradientColors: [
            TossDesignSystem.tossBlue,
            TossDesignSystem.tossBlue,
          ],
        );
      case RecommendationType.collaborative:
        return _BadgeData(
          icon: Icons.group_rounded,
          gradientColors: [
            FortuneColors.love,
            FortuneColors.love,
          ],
        );
      case RecommendationType.general:
      default:
        return _BadgeData(
          icon: Icons.star_rounded,
          gradientColors: [
            TossDesignSystem.gray900Tertiary,
            TossDesignSystem.gray600,
          ],
        );
    }
  }
}

class _BadgeData {
  final IconData icon;
  final List<Color> gradientColors;
  
  const _BadgeData({
    required this.icon,
    required this.gradientColors,
  });
}

/// Simplified badge for list view
class FortuneRecommendationChip extends StatelessWidget {
  final RecommendationType type;
  
  const FortuneRecommendationChip({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Skip general recommendations
    if (type == RecommendationType.general) {
      return const SizedBox.shrink();
    }
    
    final color = _getChipColor(type);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing1 * 1.5, vertical: 4 * 0.5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: AppDimensions.borderRadiusSmall,
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: Text(
        type.displayName,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Color _getChipColor(RecommendationType type) {
    switch (type) {
      case RecommendationType.personalized:
        return FortuneColors.spiritualPrimary;
      case RecommendationType.popular:
        return TossDesignSystem.errorRed;
      case RecommendationType.trending:
        return TossDesignSystem.warningOrange;
      case RecommendationType.newFortune:
        return TossDesignSystem.successGreen;
      case RecommendationType.seasonal:
        return TossDesignSystem.tossBlue;
      case RecommendationType.collaborative:
        return FortuneColors.love;
      case RecommendationType.general:
      default:
        return TossDesignSystem.gray900Tertiary;
    }
  }
}