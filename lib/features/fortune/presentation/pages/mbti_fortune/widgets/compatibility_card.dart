import 'package:flutter/material.dart';
import 'package:fortune/core/components/app_card.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:fortune/core/theme/font_config.dart';

class CompatibilityCard extends StatelessWidget {
  final String selectedMbti;
  final Map<String, List<Color>> mbtiColors;

  static const Map<String, List<String>> compatibility = {
    'INTJ': ['ENTP', 'ENFP'],
    'INTP': ['ENTJ', 'ESTJ'],
    'ENTJ': ['INTP', 'ISTP'],
    'ENTP': ['INTJ', 'INFJ'],
    'INFJ': ['ENTP', 'ENFP'],
    'INFP': ['ENFJ', 'ENTJ'],
    'ENFJ': ['INFP', 'ISFP'],
    'ENFP': ['INTJ', 'INFJ'],
    'ISTJ': ['ESFP', 'ESTP'],
    'ISFJ': ['ESFP', 'ESTP'],
    'ESTJ': ['INTP', 'ISTP'],
    'ESFJ': ['ISFP', 'ISTP'],
    'ISTP': ['ESTJ', 'ENTJ'],
    'ISFP': ['ENFJ', 'ESFJ'],
    'ESTP': ['ISTJ', 'ISFJ'],
    'ESFP': ['ISTJ', 'ISFJ'],
  };

  const CompatibilityCard({
    super.key,
    required this.selectedMbti,
    required this.mbtiColors,
  });

  List<String> _getCompatibleTypes(String mbti) {
    return compatibility[mbti] ?? ['INFJ', 'ENFP'];
  }

  String _getCompatibilityLabel(int index) {
    const labels = ['찰떡궁합 💕', '좋은 궁합 ✨'];
    return index < labels.length ? labels[index] : '좋은 궁합';
  }

  // 안맞는 유형 데이터
  static const Map<String, List<String>> incompatibility = {
    'INTJ': ['ESFP', 'ISFP'],
    'INTP': ['ESFJ', 'ISFJ'],
    'ENTJ': ['ISFP', 'INFP'],
    'ENTP': ['ISFJ', 'ISTJ'],
    'INFJ': ['ESTP', 'ISTP'],
    'INFP': ['ESTJ', 'ISTJ'],
    'ENFJ': ['ISTP', 'ESTP'],
    'ENFP': ['ISTJ', 'ESTJ'],
    'ISTJ': ['ENFP', 'INFP'],
    'ISFJ': ['ENTP', 'INTP'],
    'ESTJ': ['INFP', 'ENFP'],
    'ESFJ': ['INTP', 'ISTP'],
    'ISTP': ['ENFJ', 'INFJ'],
    'ISFP': ['ENTJ', 'INTJ'],
    'ESTP': ['INFJ', 'ENFJ'],
    'ESFP': ['INTJ', 'INTP'],
  };

  List<String> _getIncompatibleTypes(String mbti) {
    return incompatibility[mbti] ?? ['ESTJ', 'ISTJ'];
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = context.colors;
    final compatibleTypes = _getCompatibleTypes(selectedMbti);
    final incompatibleTypes = _getIncompatibleTypes(selectedMbti);

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 잘 맞는 유형 섹션
          Row(
            children: [
              const Icon(Icons.favorite,
                size: 20,
                color: Color(0xFFEC4899)),
              const SizedBox(width: 8),
              Text(
                '잘 맞는 유형',
                style: DSTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: themeColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: compatibleTypes.map((type) {
              final colors = mbtiColors[type]!;
              return Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: colors[0].withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        type,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: FontConfig.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getCompatibilityLabel(compatibleTypes.indexOf(type)),
                    style: DSTypography.labelSmall.copyWith(
                      color: const Color(0xFFEC4899),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // 주의할 유형 섹션
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                size: 20,
                color: themeColors.textTertiary),
              const SizedBox(width: 8),
              Text(
                '주의할 유형',
                style: DSTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: themeColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: incompatibleTypes.map((type) {
              final colors = mbtiColors[type]!;
              return Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: themeColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: colors[0].withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        type,
                        style: TextStyle(
                          color: themeColors.textSecondary,
                          fontFamily: FontConfig.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '조심 ⚡',
                    style: DSTypography.labelSmall.copyWith(
                      color: themeColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
