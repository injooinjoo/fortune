import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/design_system.dart';
import 'fortune_card.dart';

/// 가족 운세 카드 컴포넌트 - 토스 디자인 시스템
class FamilyFortuneCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final bool isSelected;
  final VoidCallback? onTap;
  final Widget? badge;
  final bool showArrow;
  
  const FamilyFortuneCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.gradientColors,
    this.isSelected = false,
    this.onTap,
    this.badge,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? DSColors.accent.withValues(alpha:0.05)
              : isDark ? DSColors.surface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? DSColors.accent 
                : isDark ? DSColors.border : DSColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: DSColors.accent.withValues(alpha:0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ] : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon with gradient
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSelected 
                        ? [DSColors.accent, DSColors.accentSecondary]
                        : gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: DSTypography.headingSmall.copyWith(
                            
                            fontWeight: FontWeight.w700,
                            color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          badge!,
                        ],
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: DSTypography.bodySmall.copyWith(
                          color: isDark ? DSColors.textTertiary : DSColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Selection indicator or arrow
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: DSColors.accent,
                  size: 24,
                )
              else if (showArrow)
                Icon(
                  Icons.arrow_forward_ios,
                  color: isDark ? DSColors.textTertiary : DSColors.textTertiary,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 가족 구성원 선택 칩
class FamilyMemberChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? color;
  
  const FamilyMemberChip({
    super.key,
    required this.label,
    required this.icon,
    this.isSelected = false,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipColor = color ?? DSColors.accent;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? chipColor.withValues(alpha:0.1)
              : isDark ? DSColors.surface : DSColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected 
                ? chipColor
                : isDark ? DSColors.border : DSColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected 
                  ? chipColor
                  : isDark ? DSColors.textTertiary : DSColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: DSTypography.bodySmall.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected 
                    ? chipColor
                    : isDark ? DSColors.textSecondary : DSColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(
      begin: const Offset(0.95, 0.95),
      end: const Offset(1, 1),
      duration: 200.ms,
    );
  }
}

/// 가족 활동 추천 카드
class FamilyActivityCard extends StatelessWidget {
  final String activity;
  final String description;
  final String difficulty;
  final String duration;
  final String benefit;
  final IconData icon;
  final List<Color> gradientColors;
  
  const FamilyActivityCard({
    super.key,
    required this.activity,
    required this.description,
    required this.difficulty,
    required this.duration,
    required this.benefit,
    this.icon = Icons.stars,
    this.gradientColors = const [DSColors.accent, DSColors.accentSecondary],
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors.map((c) => c.withValues(alpha:0.05)).toList(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gradientColors[0].withValues(alpha:0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity,
                        style: DSTypography.headingSmall.copyWith(
                          
                          fontWeight: FontWeight.w700,
                          color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          _buildTag(difficulty, _getDifficultyColor(difficulty)),
                          const SizedBox(width: 8),
                          _buildTag(duration, DSColors.textSecondary),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              description,
              style: DSTypography.bodySmall.copyWith(
                color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Benefit
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DSColors.success.withValues(alpha:0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: DSColors.success,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      benefit,
                      style: DSTypography.labelSmall.copyWith(
                        color: DSColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
  
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: DSTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case '쉬움':
        return DSColors.success;
      case '보통':
        return DSColors.warning;
      case '어려움':
        return DSColors.error;
      default:
        return DSColors.textSecondary;
    }
  }
}

/// 가족 구성원 운세 카드
class FamilyMemberFortuneCard extends StatelessWidget {
  final String name;
  final String mood;
  final int energy;
  final String advice;
  final String luckyTime;
  final IconData icon;
  
  const FamilyMemberFortuneCard({
    super.key,
    required this.name,
    required this.mood,
    required this.energy,
    required this.advice,
    required this.luckyTime,
    this.icon = Icons.person,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final moodColor = _getMoodColor(mood);
    
    return FortuneCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: moodColor.withValues(alpha:0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: moodColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: DSTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: moodColor.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        mood,
                        style: DSTypography.labelSmall.copyWith(
                          color: moodColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  advice,
                  style: DSTypography.labelSmall.copyWith(
                    color: isDark ? DSColors.textTertiary : DSColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.bolt,
                      size: 14,
                      color: DSColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '에너지 $energy%',
                      style: DSTypography.labelSmall.copyWith(
                        color: DSColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: DSColors.accentSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      luckyTime,
                      style: DSTypography.labelSmall.copyWith(
                        color: DSColors.accentSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getMoodColor(String mood) {
    final moodColors = {
      '활기찬': DSColors.warning,
      '평온한': DSColors.accent,
      '도전적인': DSColors.error,
      '성장하는': DSColors.success,
      '행복한': DSColors.accentSecondary,
    };
    
    return moodColors[mood] ?? DSColors.textSecondary;
  }
}