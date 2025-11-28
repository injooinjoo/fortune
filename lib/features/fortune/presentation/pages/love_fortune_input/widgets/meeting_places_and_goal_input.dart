import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_theme.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';

/// Section 6: 만남 장소 & 연애 목표
class MeetingPlacesAndGoalInput extends StatelessWidget {
  final Set<String> selectedMeetingPlaces;
  final String? relationshipGoal;
  final ValueChanged<String> onMeetingPlaceToggled;
  final ValueChanged<String> onRelationshipGoalChanged;

  const MeetingPlacesAndGoalInput({
    super.key,
    required this.selectedMeetingPlaces,
    required this.relationshipGoal,
    required this.onMeetingPlaceToggled,
    required this.onRelationshipGoalChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final places = [
      {'id': 'cafe', 'text': '카페·맛집', 'emoji': '☕'},
      {'id': 'gym', 'text': '헬스장·운동시설', 'emoji': '🏋️'},
      {'id': 'library', 'text': '도서관·문화공간', 'emoji': '📚'},
      {'id': 'meeting', 'text': '소개팅·미팅', 'emoji': '👥'},
      {'id': 'app', 'text': '앱·온라인', 'emoji': '📱'},
      {'id': 'hobby', 'text': '취미모임·동호회', 'emoji': '🎭'},
    ];

    final goals = [
      {'id': 'casual', 'text': '가벼운 만남', 'emoji': '😊'},
      {'id': 'serious', 'text': '진지한 연애', 'emoji': '💕'},
      {'id': 'marriage', 'text': '결혼 전제', 'emoji': '💍'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 만남 장소
        Text(
          '선호하는 만남 장소',
          style: TypographyUnified.labelLarge.copyWith(
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '여러 개 선택 가능',
          style: TypographyUnified.labelMedium.copyWith(
            color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: places.map((place) {
            final placeId = place['id'] as String;
            final isSelected = selectedMeetingPlaces.contains(placeId);
            return InkWell(
              onTap: () {
                onMeetingPlaceToggled(placeId);
                TossDesignSystem.hapticLight();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                      : (isDark ? TossDesignSystem.cardBackgroundDark : TossTheme.backgroundSecondary),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? TossDesignSystem.tossBlue
                        : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      place['emoji'] as String,
                      style: TypographyUnified.bodyMedium,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      place['text'] as String,
                      style: TypographyUnified.bodySmall.copyWith(
                        color: isSelected
                            ? TossDesignSystem.tossBlue
                            : (isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // 연애 목표
        Text(
          '연애 목표',
          style: TypographyUnified.labelLarge.copyWith(
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...goals.map((goal) {
          final goalId = goal['id'] as String;
          final isSelected = relationshipGoal == goalId;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                onRelationshipGoalChanged(goalId);
                TossDesignSystem.hapticLight();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                      : (isDark ? TossDesignSystem.cardBackgroundDark : TossTheme.backgroundSecondary),
                  border: Border.all(
                    color: isSelected
                        ? TossDesignSystem.tossBlue
                        : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      goal['emoji'] as String,
                      style: TypographyUnified.displaySmall,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        goal['text'] as String,
                        style: TypographyUnified.bodyMedium.copyWith(
                          color: isSelected
                              ? TossDesignSystem.tossBlue
                              : (isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: TossDesignSystem.tossBlue,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
