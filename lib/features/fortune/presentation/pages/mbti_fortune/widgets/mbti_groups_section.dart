import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/typography_unified.dart';
import 'mbti_card.dart';

class MbtiGroupsSection extends StatelessWidget {
  final bool showAllGroups;
  final String? selectedMbti;
  final VoidCallback onToggle;
  final Function(String) onMbtiSelected;
  final ScrollController scrollController;

  static const Map<String, List<String>> mbtiGroups = {
    '분석가': ['INTJ', 'INTP', 'ENTJ', 'ENTP'],
    '외교관': ['INFJ', 'INFP', 'ENFJ', 'ENFP'],
    '관리자': ['ISTJ', 'ISFJ', 'ESTJ', 'ESFJ'],
    '탐험가': ['ISTP', 'ISFP', 'ESTP', 'ESFP'],
  };

  const MbtiGroupsSection({
    super.key,
    required this.showAllGroups,
    required this.selectedMbti,
    required this.onToggle,
    required this.onMbtiSelected,
    required this.scrollController,
  });

  Color _getGroupColor(String groupName) {
    switch (groupName) {
      case '분석가':
        return const Color(0xFF8B5CF6);
      case '외교관':
        return const Color(0xFF10B981);
      case '관리자':
        return const Color(0xFF3B82F6);
      case '탐험가':
        return const Color(0xFFF59E0B);
      default:
        return TossDesignSystem.tossBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Accordion 헤더
        GestureDetector(
          onTap: () {
            onToggle();
            HapticFeedback.lightImpact();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: showAllGroups
                  ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                  : (isDark
                      ? TossDesignSystem.grayDark700
                      : TossDesignSystem.gray50),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: showAllGroups
                    ? TossDesignSystem.tossBlue.withValues(alpha: 0.3)
                    : (isDark
                        ? TossDesignSystem.grayDark400
                        : TossDesignSystem.gray200),
                width: showAllGroups ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.psychology_rounded,
                  color: TossDesignSystem.tossBlue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedMbti ?? 'MBTI 성격 유형 선택',
                    style: TypographyUnified.buttonMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color:
                          isDark ? TossDesignSystem.white : TossDesignSystem.gray800,
                    ),
                  ),
                ),
                Icon(
                  showAllGroups
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: TossDesignSystem.tossBlue,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        // MBTI 그리드
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: showAllGroups
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              children: mbtiGroups.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 그룹 라벨
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12, left: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: _getGroupColor(entry.key),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Text(
                            entry.key,
                            style: TypographyUnified.buttonMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? TossDesignSystem.white
                                  : TossDesignSystem.gray800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // MBTI 카드
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      childAspectRatio: 0.85,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: entry.value
                          .map((mbti) => MbtiCard(
                                mbti: mbti,
                                isSelected: selectedMbti == mbti,
                                onTap: () {
                                  onMbtiSelected(mbti);
                                  // ✅ 부드러운 스크롤 애니메이션
                                  Future.delayed(const Duration(milliseconds: 350), () {
                                    if (scrollController.hasClients) {
                                      scrollController.animateTo(
                                        0,
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeOutCubic,
                                      );
                                    }
                                  });
                                },
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }).toList(),
            ),
          ),
          secondChild: const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
