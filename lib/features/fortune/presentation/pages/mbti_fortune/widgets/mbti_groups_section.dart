import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'mbti_card.dart';

// MBTI 별칭을 MbtiCard에서 가져옴
const _mbtiNicknames = MbtiCard.mbtiNicknames;

class MbtiGroupsSection extends StatelessWidget {
  final bool showAllGroups;
  final String? selectedMbti;
  final VoidCallback onToggle;
  final Function(String) onMbtiSelected;
  final ScrollController scrollController;

  // ✅ 카테고리 제거: 단순 리스트로 변경
  static const List<String> allMbtiTypes = [
    'INTJ', 'INTP', 'ENTJ', 'ENTP',
    'INFJ', 'INFP', 'ENFJ', 'ENFP',
    'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
    'ISTP', 'ISFP', 'ESTP', 'ESFP',
  ];

  const MbtiGroupsSection({
    super.key,
    required this.showAllGroups,
    required this.selectedMbti,
    required this.onToggle,
    required this.onMbtiSelected,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
                  ? colors.accent.withValues(alpha: 0.1)
                  : colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: showAllGroups
                    ? colors.accent.withValues(alpha: 0.3)
                    : colors.border,
                width: showAllGroups ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.psychology_rounded,
                  color: colors.accent,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedMbti != null
                        ? '$selectedMbti (${_mbtiNicknames[selectedMbti] ?? ''})'
                        : 'MBTI 성격 유형 선택',
                    style: DSTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  showAllGroups
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: colors.accent,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        // ✅ MBTI 그리드 (카테고리 없이 4x4)
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: showAllGroups
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              childAspectRatio: 0.85,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: allMbtiTypes
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
          ),
          secondChild: const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
