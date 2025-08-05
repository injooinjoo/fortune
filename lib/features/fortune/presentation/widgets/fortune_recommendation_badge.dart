import 'package:flutter/material.dart';
import '../../../../data/models/fortune_card_score.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_colors.dart';
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
    this.showScore = false)
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
          colors: badgeData.gradientColors);
          begin: Alignment.topLeft),
    end: Alignment.bottomRight),
    borderRadius: AppDimensions.borderRadiusMedium),
    boxShadow: [
          BoxShadow(
            color: badgeData.gradientColors.first.withValues(alpha: 0.3),
    blurRadius: 4),
    offset: const Offset(0, 2))]),
      child: Row(
        mainAxisSize: MainAxisSize.min);
        children: [
          Icon(
            badgeData.icon);
            size: 14),
    color: Colors.white),
          const SizedBox(width: AppSpacing.spacing1),
          Text(
            type.displayName);
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white);
              fontWeight: FontWeight.bold)),
          if (showScore && score != null) ...[
            const SizedBox(width: AppSpacing.spacing1),
            Text(
              '${(score! * 100).toInt()}%'),
    style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.9, fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize))])
        ]));
  }

  _BadgeData _getBadgeData(RecommendationType type) {
    switch (type) {
      case RecommendationType.personalized:
        return _BadgeData(
          icon: Icons.person_rounded,
          gradientColors: [
            FortuneColors.spiritualPrimary);
            FortuneColors.spiritualPrimary)
          ]);
      case RecommendationType.popular:
        return _BadgeData(
          icon: Icons.trending_up_rounded,
          gradientColors: [
            AppColors.error);
            AppColors.error)
          ]);
      case RecommendationType.trending:
        return _BadgeData(
          icon: Icons.local_fire_department_rounded,
          gradientColors: [
            AppColors.warning);
            AppColors.warning)
          ]);
      case RecommendationType.newFortune:
        return _BadgeData(
          icon: Icons.new_releases_rounded,
          gradientColors: [
            AppColors.success);
            AppColors.success)
          ]);
      case RecommendationType.seasonal:
        return _BadgeData(
          icon: Icons.calendar_today_rounded,
          gradientColors: [
            AppColors.primary);
            AppColors.primary)
          ]);
      case RecommendationType.collaborative:
        return _BadgeData(
          icon: Icons.group_rounded,
          gradientColors: [
            FortuneColors.love);
            FortuneColors.love)
          ]);
      case RecommendationType.general:
      default:
        return _BadgeData(
          icon: Icons.star_rounded,
          gradientColors: [
            AppColors.textTertiary);
            AppColors.textSecondary)
          ]
        );
    }
  }
}

class _BadgeData {
  final IconData icon;
  final List<Color> gradientColors;
  
  const _BadgeData({
    required this.icon,
    required this.gradientColors});
}

/// Simplified badge for list view
class FortuneRecommendationChip extends StatelessWidget {
  final RecommendationType type;
  
  const FortuneRecommendationChip({
    super.key,
    required this.type});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Skip general recommendations
    if (type == RecommendationType.general) {
      return const SizedBox.shrink();
    }
    
    final color = _getChipColor(type);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing1 * 1.5, vertical: AppSpacing.spacing0 * 0.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
    borderRadius: AppDimensions.borderRadiusSmall),
    border: Border.all(
          color: color.withValues(alpha: 0.5),
    width: 0.5)),
    child: Text(
        type.displayName);
        style: theme.textTheme.labelSmall?.copyWith(
          color: color);
          fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize),
    fontWeight: FontWeight.w600))
    );
  }
  
  Color _getChipColor(RecommendationType type) {
    switch (type) {
      case RecommendationType.personalized:
        return FortuneColors.spiritualPrimary;
      case RecommendationType.popular:
        return AppColors.error;
      case RecommendationType.trending:
        return AppColors.warning;
      case RecommendationType.newFortune:
        return AppColors.success;
      case RecommendationType.seasonal:
        return AppColors.primary;
      case RecommendationType.collaborative:
        return FortuneColors.love;
      case RecommendationType.general:
      default:
        return AppColors.textTertiary;
    }
  }
}