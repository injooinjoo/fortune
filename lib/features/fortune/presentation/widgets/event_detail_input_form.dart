import 'package:flutter/material.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/components/app_card.dart';
import 'event_category_selector.dart';
import '../../../../core/theme/typography_unified.dart';

/// 감정 상태 정의
enum EmotionState {
  anxious('불안함', Icons.sentiment_dissatisfied, TossDesignSystem.warningOrange),
  excited('기대됨', Icons.sentiment_very_satisfied, TossDesignSystem.successGreen),
  worried('걱정됨', Icons.sentiment_neutral, TossDesignSystem.gray600),
  nervous('떨림', Icons.favorite, TossDesignSystem.errorRed),
  fearful('두려움', Icons.sentiment_very_dissatisfied, TossDesignSystem.purple);

  final String label;
  final IconData icon;
  final Color color;

  const EmotionState(this.label, this.icon, this.color);
}

/// 이벤트 상세 입력 폼
class EventDetailInputForm extends StatelessWidget {
  final EventCategory category;
  final TextEditingController questionController;
  final EmotionState? selectedEmotion;
  final ValueChanged<EmotionState> onEmotionSelected;
  final bool showPartnerInfo;
  final VoidCallback onAddPartner;

  const EventDetailInputForm({
    super.key,
    required this.category,
    required this.questionController,
    required this.selectedEmotion,
    required this.onEmotionSelected,
    this.showPartnerInfo = false,
    required this.onAddPartner,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 질문/고민 입력
          Text(
            '질문이나 고민을 입력해주세요 (선택)',
            style: TossDesignSystem.heading4.copyWith(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: questionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: '예: 이번 면접에서 좋은 결과가 나올까요?',
              hintStyle: TextStyle(
                color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
              ),
              filled: true,
              fillColor: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: category.color,
                  width: 2,
                ),
              ),
            ),
          ),
          SizedBox(height: 24),

          // 감정 상태 선택
          Text(
            '현재 감정 상태',
            style: TossDesignSystem.heading4.copyWith(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: EmotionState.values.map((emotion) {
              final isSelected = selectedEmotion == emotion;
              return InkWell(
                onTap: () => onEmotionSelected(emotion),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? emotion.color.withValues(alpha: 0.15)
                        : (isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray100),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? emotion.color
                          : (isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        emotion.icon,
                        size: 18,
                        color: isSelected
                            ? emotion.color
                            : (isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600),
                      ),
                      SizedBox(width: 6),
                      Text(
                        emotion.label,
                        style: TypographyUnified.bodySmall.copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected
                              ? emotion.color
                              : (isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          // 연애/대인관계인 경우 상대방 정보 추가 옵션
          if (category == EventCategory.dating || category == EventCategory.relationship) ...[
            const SizedBox(height: 24),
            Divider(
              color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: onAddPartner,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_add,
                      color: category.color,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '상대방 정보 추가하기',
                            style: TossDesignSystem.heading4.copyWith(
                              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '궁합 분석을 받을 수 있어요',
                            style: TossDesignSystem.body3.copyWith(
                              color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
