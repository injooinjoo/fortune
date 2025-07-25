import 'package:flutter/material.dart';
import '../../../../data/models/fortune_card_score.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: badgeData.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: badgeData.gradientColors.first.withValues(alpha: 0.3),
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
          const SizedBox(width: 4),
          Text(
            type.displayName,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showScore && score != null) ...[
            const SizedBox(width: 4),
            Text(
              '${(score! * 100).toInt()}%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  _BadgeData _getBadgeData(RecommendationType type) {
    switch (type) {
      case RecommendationType.personalized:
        return _BadgeData(
          icon: Icons.person_rounded,
          gradientColors: [
            const Color(0xFF9333EA),
            const Color(0xFF7C3AED),
          ],
        );
      case RecommendationType.popular:
        return _BadgeData(
          icon: Icons.trending_up_rounded,
          gradientColors: [
            const Color(0xFFEF4444),
            const Color(0xFFDC2626),
          ],
        );
      case RecommendationType.trending:
        return _BadgeData(
          icon: Icons.local_fire_department_rounded,
          gradientColors: [
            const Color(0xFFF59E0B),
            const Color(0xFFD97706),
          ],
        );
      case RecommendationType.newFortune:
        return _BadgeData(
          icon: Icons.new_releases_rounded,
          gradientColors: [
            const Color(0xFF10B981),
            const Color(0xFF059669),
          ],
        );
      case RecommendationType.seasonal:
        return _BadgeData(
          icon: Icons.calendar_today_rounded,
          gradientColors: [
            const Color(0xFF3B82F6),
            const Color(0xFF2563EB),
          ],
        );
      case RecommendationType.collaborative:
        return _BadgeData(
          icon: Icons.group_rounded,
          gradientColors: [
            const Color(0xFFEC4899),
            const Color(0xFFDB2777),
          ],
        );
      case RecommendationType.general:
      default:
        return _BadgeData(
          icon: Icons.star_rounded,
          gradientColors: [
            const Color(0xFF6B7280),
            const Color(0xFF4B5563),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Text(
        type.displayName,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Color _getChipColor(RecommendationType type) {
    switch (type) {
      case RecommendationType.personalized:
        return const Color(0xFF9333EA);
      case RecommendationType.popular:
        return const Color(0xFFEF4444);
      case RecommendationType.trending:
        return const Color(0xFFF59E0B);
      case RecommendationType.newFortune:
        return const Color(0xFF10B981);
      case RecommendationType.seasonal:
        return const Color(0xFF3B82F6);
      case RecommendationType.collaborative:
        return const Color(0xFFEC4899);
      case RecommendationType.general:
      default:
        return const Color(0xFF6B7280);
    }
  }
}