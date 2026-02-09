import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../data/models/chat_insight_result.dart';

/// 대화 패턴 카드 (태그 + 근거 수 + 설명 펼침)
class PatternCardWidget extends StatefulWidget {
  final InsightPatterns patterns;

  const PatternCardWidget({super.key, required this.patterns});

  @override
  State<PatternCardWidget> createState() => _PatternCardWidgetState();
}

class _PatternCardWidgetState extends State<PatternCardWidget> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final items = widget.patterns.items;

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
              Icon(Icons.pattern, color: colors.textSecondary, size: 20),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '대화 패턴',
                style: typography.headingSmall.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // 패턴 리스트
          ...List.generate(items.length, (index) {
            final item = items[index];
            final isExpanded = _expandedIndex == index;

            return Semantics(
              label: '패턴: ${item.tag}, 근거 ${item.evidenceCount}건',
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _expandedIndex = isExpanded ? null : index;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: DSSpacing.sm),
                  padding: const EdgeInsets.all(DSSpacing.sm),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(DSRadius.sm),
                    border: isExpanded
                        ? Border.all(
                            color: colors.border)
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // 태그 칩
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DSSpacing.sm,
                              vertical: DSSpacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: colors.backgroundTertiary,
                              borderRadius:
                                  BorderRadius.circular(DSRadius.full),
                            ),
                            child: Text(
                              item.tag,
                              style: typography.labelSmall.copyWith(
                                color: colors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: DSSpacing.xs),
                          // 근거 수 배지
                          Text(
                            '근거 ${item.evidenceCount}건',
                            style: typography.labelSmall.copyWith(
                              color: colors.textTertiary,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            isExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            size: 18,
                            color: colors.textTertiary,
                          ),
                        ],
                      ),
                      // 설명 (펼침)
                      if (isExpanded) ...[
                        const SizedBox(height: DSSpacing.sm),
                        Text(
                          item.description,
                          style: typography.bodySmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
