import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/toss_design_system.dart';

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
        color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withOpacity(0.2)
              : Colors.grey.withOpacity(0.08),
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
                      TossDesignSystem.purple,
                      TossDesignSystem.tossBlue,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.people,
                  color: TossDesignSystem.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'MBTI 시너지',
                style: TossDesignSystem.heading3.copyWith(
                  color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
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
            color: TossDesignSystem.green,
            icon: Icons.favorite,
          ),
          
          const SizedBox(height: 16),
          
          // Worst Match
          _buildMatchCard(
            title: '주의가 필요한 궁합',
            mbti: worstMatch['type'] as String? ?? '',
            score: worstMatch['score'] as int? ?? 0,
            reason: worstMatch['reason'] as String? ?? '',
            color: TossDesignSystem.orange,
            icon: Icons.warning_amber_outlined,
          ),
          
          const SizedBox(height: 20),
          
          // Communication Tip
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TossDesignSystem.tossBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: TossDesignSystem.tossBlue.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.tips_and_updates,
                  color: TossDesignSystem.tossBlue,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '오늘의 소통 팁',
                        style: TossDesignSystem.body3.copyWith(
                          color: TossDesignSystem.tossBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        communicationTip,
                        style: TossDesignSystem.caption.copyWith(
                          color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
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
            TossDesignSystem.purple.withOpacity(0.8),
            TossDesignSystem.tossBlue.withOpacity(0.8),
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
                color: TossDesignSystem.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '오늘의 특별 시너지',
                style: TossDesignSystem.body2.copyWith(
                  color: TossDesignSystem.white,
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
                  color: TossDesignSystem.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  type,
                  style: TossDesignSystem.body1.copyWith(
                    color: TossDesignSystem.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: TossDesignSystem.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$score%',
                  style: TossDesignSystem.body2.copyWith(
                    color: TossDesignSystem.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TossDesignSystem.body3.copyWith(
              color: TossDesignSystem.white.withOpacity(0.95),
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
          ? TossDesignSystem.grayDark50
          : TossDesignSystem.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
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
                style: TossDesignSystem.body3.copyWith(
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    mbti,
                    style: TossDesignSystem.body2.copyWith(
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
                      style: TossDesignSystem.body2.copyWith(
                        color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reason,
                      style: TossDesignSystem.caption.copyWith(
                        color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$score%',
                  style: TossDesignSystem.body3.copyWith(
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