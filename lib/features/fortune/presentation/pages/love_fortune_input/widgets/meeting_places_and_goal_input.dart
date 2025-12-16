import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/design_system/design_system.dart';

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
    final colors = context.colors;

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
          style: DSTypography.labelLarge.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '여러 개 선택 가능',
          style: DSTypography.labelMedium.copyWith(
            color: colors.textSecondary,
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
                HapticFeedback.lightImpact();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.accent.withValues(alpha: 0.1)
                      : colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? colors.accent
                        : colors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      place['emoji'] as String,
                      style: DSTypography.bodyMedium,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      place['text'] as String,
                      style: DSTypography.bodySmall.copyWith(
                        color: isSelected
                            ? colors.accent
                            : colors.textPrimary,
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
          style: DSTypography.labelLarge.copyWith(
            color: colors.textPrimary,
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
                HapticFeedback.lightImpact();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.accent.withValues(alpha: 0.1)
                      : colors.surface,
                  border: Border.all(
                    color: isSelected
                        ? colors.accent
                        : colors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      goal['emoji'] as String,
                      style: DSTypography.displaySmall,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        goal['text'] as String,
                        style: DSTypography.bodyMedium.copyWith(
                          color: isSelected
                              ? colors.accent
                              : colors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: colors.accent,
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
