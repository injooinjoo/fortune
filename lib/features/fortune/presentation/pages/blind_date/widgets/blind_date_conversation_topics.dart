import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../shared/glassmorphism/glass_container.dart';

/// 대화 주제 추천 위젯
class BlindDateConversationTopics extends StatelessWidget {
  const BlindDateConversationTopics({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final topics = [
      {
        'category': '가벼운 주제',
        'items': ['취미', '여행', '음식', '영화/드라마']
      },
      {
        'category': '일상 이야기',
        'items': ['주말 보내는 법', '좋아하는 활동', '버킷리스트']
      },
      {
        'category': '진지한 대화',
        'items': ['일과 삶의 균형', '미래 계획', '관계에서 중요한 것']
      }
    ];

    final avoidTopics = ['전 애인', '정치/종교', '연봉', '결혼 압박', '부정적인 이야기'];

    return GlassCard(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                color: colors.accent,
                size: 24,
              ),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '대화 주제 추천',
                style: DSTypography.headingSmall.copyWith(
                  color: colors.textPrimary,
                ),
              )
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          // 주제 카테고리들
          ...topics.map((topic) => Padding(
                padding: const EdgeInsets.only(bottom: DSSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(DSRadius.full),
                      ),
                      child: Text(
                        topic['category'] as String,
                        style: DSTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: DSSpacing.sm),
                    Wrap(
                      spacing: DSSpacing.sm,
                      runSpacing: DSSpacing.sm,
                      children: (topic['items'] as List)
                          .map((item) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(DSRadius.full),
                                  border: Border.all(
                                    color: colors.border,
                                  ),
                                ),
                                child: Text(
                                  item as String,
                                  style: DSTypography.bodySmall.copyWith(
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: DSSpacing.sm),
          // 피해야 할 주제
          Container(
            padding: const EdgeInsets.all(DSSpacing.md),
            decoration: BoxDecoration(
              color: DSColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DSRadius.sm),
              border: Border.all(
                color: DSColors.error.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: DSColors.error,
                    ),
                    const SizedBox(width: DSSpacing.sm),
                    Text(
                      '피해야 할 주제',
                      style: DSTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: DSColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DSSpacing.sm),
                Wrap(
                  spacing: DSSpacing.sm,
                  runSpacing: DSSpacing.sm,
                  children: avoidTopics
                      .map((topic) => Text(
                            '• $topic',
                            style: DSTypography.bodySmall.copyWith(
                              color: colors.textPrimary,
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
