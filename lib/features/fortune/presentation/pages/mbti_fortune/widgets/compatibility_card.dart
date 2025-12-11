import 'package:flutter/material.dart';
import 'package:fortune/core/components/app_card.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/typography_unified.dart';

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
    const labels = ['Best Match', 'Good Match', 'Compatible'];
    return index < labels.length ? labels[index] : 'Compatible';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final compatibleTypes = _getCompatibleTypes(selectedMbti);

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people,
                size: 20,
                color: TossDesignSystem.purple),
              const SizedBox(width: 8),
              Text(
                '오늘의 궁합',
                style: TypographyUnified.buttonMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: compatibleTypes.map((type) {
              final colors = mbtiColors[type]!;
              return Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        type,
                        style: const TextStyle(
                          color: TossDesignSystem.white,
                          fontFamily: 'ZenSerif',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getCompatibilityLabel(compatibleTypes.indexOf(type)),
                    style: TypographyUnified.labelMedium.copyWith(
                      color: TossDesignSystem.gray600,
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
