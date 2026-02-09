import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../data/models/chat_insight_result.dart';

/// 주요 대화 트리거 카드 (마스킹된 인용문 + 설명)
class TriggerCardWidget extends StatelessWidget {
  final InsightTriggers triggers;

  const TriggerCardWidget({super.key, required this.triggers});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final items = triggers.items;

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return DSCard.elevated(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Icon(Icons.format_quote, color: colors.textSecondary, size: 20),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '주요 대화',
                style: typography.headingSmall.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // 트리거 리스트
          ...items.map((item) => Semantics(
                label: '주요 대화: ${item.maskedQuote}. '
                    '중요한 이유: ${item.whyItMatters}',
                child: Container(
                  margin: const EdgeInsets.only(bottom: DSSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 인용문 블록
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(DSSpacing.sm),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(DSRadius.sm),
                          border: Border(
                            left: BorderSide(
                              color: colors.textTertiary,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.time != null)
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: DSSpacing.xxs),
                                child: Text(
                                  '${item.time!.month}/${item.time!.day} '
                                  '${item.time!.hour.toString().padLeft(2, '0')}:'
                                  '${item.time!.minute.toString().padLeft(2, '0')}',
                                  style: typography.labelSmall.copyWith(
                                    color: colors.textTertiary,
                                  ),
                                ),
                              ),
                            Text(
                              item.maskedQuote,
                              style: typography.bodySmall.copyWith(
                                color: colors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: DSSpacing.xs),
                      // 설명
                      Text(
                        item.whyItMatters,
                        style: typography.bodySmall.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
