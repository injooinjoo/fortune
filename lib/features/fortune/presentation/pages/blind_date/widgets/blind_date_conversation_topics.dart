import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../shared/glassmorphism/glass_container.dart';

/// 대화 주제 추천 위젯
class BlindDateConversationTopics extends StatelessWidget {
  const BlindDateConversationTopics({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '대화 주제 추천',
                  style: theme.textTheme.headlineSmall,
                )
              ],
            ),
            const SizedBox(height: 16),
            ...topics.map((topic) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          topic['category'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (topic['items'] as List)
                            .map((item) => Chip(
                                  label: Text(
                                    item as String,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  backgroundColor: theme.colorScheme.surface
                                      .withValues(alpha: 0.8),
                                  side: BorderSide(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.2),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DSColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: DSColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: DSColors.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '피해야 할 주제',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: DSColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: avoidTopics
                        .map((topic) => Text(
                              '• $topic',
                              style: theme.textTheme.bodySmall,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
