import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/design_system.dart';

class MbtiSynergyCard extends StatelessWidget {
  final Map<String, dynamic> synergyMap;
  final bool isDark;

  const MbtiSynergyCard({
    super.key,
    required this.synergyMap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bestMatch = synergyMap['bestMatch'] as Map<String, dynamic>? ?? {};
    final worstMatch = synergyMap['worstMatch'] as Map<String, dynamic>? ?? {};
    final todaySpecial = synergyMap['todaySpecial'] as Map<String, dynamic>? ?? {};
    final communicationTip = synergyMap['communicationTip'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? DSColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
              ? Colors.black.withValues(alpha: 0.2)
              : DSColors.textTertiary.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      DSColors.accentSecondary,
                      DSColors.accent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.people,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'MBTI 시너지',
                style: DSTypography.headingSmall.copyWith(
                  color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Today's Special
          if (todaySpecial.isNotEmpty) ...[
            _buildSpecialCard(todaySpecial),
            const SizedBox(height: 20),
          ],
          
          // Best Match
          _buildMatchCard(
            title: '최고의 궁합',
            mbti: bestMatch['type'] as String? ?? '',
            score: bestMatch['score'] as int? ?? 0,
            reason: bestMatch['reason'] as String? ?? '',
            color: DSColors.success,
            icon: Icons.favorite,
          ),
          
          const SizedBox(height: 16),
          
          // Worst Match
          _buildMatchCard(
            title: '주의가 필요한 궁합',
            mbti: worstMatch['type'] as String? ?? '',
            score: worstMatch['score'] as int? ?? 0,
            reason: worstMatch['reason'] as String? ?? '',
            color: DSColors.warning,
            icon: Icons.warning_amber_outlined,
          ),
          
          const SizedBox(height: 20),
          
          // Communication Tip
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DSColors.accent.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: DSColors.accent.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.tips_and_updates,
                  color: DSColors.accent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '오늘의 소통 팁',
                        style: DSTypography.bodySmall.copyWith(
                          color: DSColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        communicationTip,
                        style: DSTypography.labelSmall.copyWith(
                          color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms, curve: Curves.easeOutQuart)
      .slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutQuart);
  }

  Widget _buildSpecialCard(Map<String, dynamic> special) {
    final type = special['type'] as String? ?? '';
    final score = special['score'] as int? ?? 0;
    final message = special['message'] as String? ?? '';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DSColors.accentSecondary.withValues(alpha: 0.8),
            DSColors.accent.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '오늘의 특별 시너지',
                style: DSTypography.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  type,
                  style: DSTypography.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$score%',
                  style: DSTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: DSTypography.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate()
      .scale(delay: 300.ms, duration: 500.ms)
      .shimmer(delay: 800.ms, duration: 1500.ms);
  }

  Widget _buildMatchCard({
    required String title,
    required String mbti,
    required int score,
    required String reason,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
          ? DSColors.surface
          : DSColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: DSTypography.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    mbti,
                    style: DSTypography.bodyMedium.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getMbtiTitle(mbti),
                      style: DSTypography.bodyMedium.copyWith(
                        color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reason,
                      style: DSTypography.labelSmall.copyWith(
                        color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$score%',
                  style: DSTypography.bodySmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMbtiTitle(String type) {
    final titles = {
      'INTJ': '전략가',
      'INTP': '논리술사',
      'ENTJ': '통솔자',
      'ENTP': '변론가',
      'INFJ': '옹호자',
      'INFP': '중재자',
      'ENFJ': '선도자',
      'ENFP': '활동가',
      'ISTJ': '현실주의자',
      'ISFJ': '수호자',
      'ESTJ': '경영자',
      'ESFJ': '집정관',
      'ISTP': '장인',
      'ISFP': '모험가',
      'ESTP': '사업가',
      'ESFP': '연예인',
    };
    return titles[type] ?? type;
  }
}