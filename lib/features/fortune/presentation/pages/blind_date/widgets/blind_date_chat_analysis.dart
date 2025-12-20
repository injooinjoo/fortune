import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../shared/glassmorphism/glass_container.dart';
import '../constants/blind_date_options.dart';

/// 대화 분석 섹션 위젯
class BlindDateChatAnalysis extends StatelessWidget {
  final TextEditingController chatContentController;
  final String? chatPlatform;
  final ValueChanged<String?> onPlatformChanged;

  const BlindDateChatAnalysis({
    super.key,
    required this.chatContentController,
    required this.chatPlatform,
    required this.onPlatformChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.chat_bubble,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '대화 분석',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '상대방과 나눈 대화 내용을 붙여넣으면 신령이 호감도, 대화 스타일, 개선점을 읽어드립니다.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),

            // Chat Platform Selection
            Text(
              '대화 플랫폼',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chatPlatformOptions.entries.map((entry) {
                final isSelected = chatPlatform == entry.key;

                return InkWell(
                  onTap: () => onPlatformChanged(entry.key),
                  borderRadius: BorderRadius.circular(20),
                  child: Chip(
                    label: Text(entry.value),
                    backgroundColor: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.2)
                        : theme.colorScheme.surface.withValues(alpha: 0.5),
                    side: BorderSide(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Chat Content Input
            Text(
              '대화 내용',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: chatContentController,
              maxLines: 10,
              maxLength: 500,
              decoration: InputDecoration(
                hintText:
                    '상대방과의 대화 내용을 붙여넣으세요.\n예시:\n나: 안녕하세요! 만나서 반가워요\n상대: 네 저도 반가워요 ㅎㅎ\n나: 오늘 날씨 좋네요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface.withValues(alpha: 0.5),
                counterText: '${chatContentController.text.length}/500',
              ),
            ),
            const SizedBox(height: 16),

            // Info Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '대화 내용은 분석 후 안전하게 삭제되며, 저장되지 않습니다.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
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
