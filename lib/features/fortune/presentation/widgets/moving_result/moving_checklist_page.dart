import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/components/app_card.dart';
import '../../../../../core/design_system/design_system.dart';
import 'moving_fortune_data.dart';
import 'moving_result_utils.dart';

/// 페이지 4: 체크리스트
class MovingChecklistPage extends StatelessWidget {
  final MovingFortuneData fortuneData;

  const MovingChecklistPage({
    super.key,
    required this.fortuneData,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이사 준비 체크리스트',
            style: DSTypography.headingLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '시기별로 준비해야 할 사항들입니다',
            style: DSTypography.bodyMedium.copyWith(color: DSColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // 타임라인 형태의 체크리스트
          ...fortuneData.checklistItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLastItem = index == fortuneData.checklistItems.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 타임라인 라인
                Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.isCompleted
                            ? DSColors.success
                            : DSColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: item.isCompleted
                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                            : Text(
                                '${index + 1}',
                                style: DSTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: DSColors.accent,
                                ),
                              ),
                      ),
                    ),
                    if (!isLastItem)
                      Container(
                        width: 2,
                        height: 60,
                        color: DSColors.border,
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                // 체크리스트 아이템
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: MovingResultUtils.getTimeColor(item.timing).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.timing,
                                  style: DSTypography.labelSmall.copyWith(
                                    color: MovingResultUtils.getTimeColor(item.timing),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (item.isCompleted)
                                Text(
                                  '완료',
                                  style: DSTypography.labelSmall.copyWith(
                                    color: DSColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.task,
                            style: DSTypography.bodyMedium.copyWith(
                              decoration: item.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: item.isCompleted
                                  ? DSColors.textTertiary
                                  : DSColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ).animate()
              .fadeIn(delay: Duration(milliseconds: 100 + index * 50))
              .slideX(begin: 0.05, end: 0);
          }),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
