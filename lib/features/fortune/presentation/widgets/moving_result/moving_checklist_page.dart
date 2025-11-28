import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/components/app_card.dart';
import '../../../../../core/theme/toss_theme.dart';
import '../../../../../core/theme/toss_design_system.dart';
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
            style: TossTheme.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            '시기별로 준비해야 할 사항들입니다',
            style: TossTheme.body2.copyWith(color: TossTheme.textGray600),
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
                            ? TossDesignSystem.success
                            : TossTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: item.isCompleted
                            ? Icon(Icons.check, color: TossDesignSystem.white, size: 20)
                            : Text(
                                '${index + 1}',
                                style: TossTheme.body2.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: TossTheme.primaryBlue,
                                ),
                              ),
                      ),
                    ),
                    if (!isLastItem)
                      Container(
                        width: 2,
                        height: 60,
                        color: TossTheme.borderGray200,
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
                                  style: TossTheme.caption.copyWith(
                                    color: MovingResultUtils.getTimeColor(item.timing),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (item.isCompleted)
                                Text(
                                  '완료',
                                  style: TossTheme.caption.copyWith(
                                    color: TossDesignSystem.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.task,
                            style: TossTheme.body2.copyWith(
                              decoration: item.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: item.isCompleted
                                  ? TossTheme.textGray400
                                  : TossTheme.textBlack,
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
