import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/glassmorphism/glass_container.dart';
import '../../../../../shared/components/app_header.dart' show FontSize;
import '../../../../../presentation/providers/font_size_provider.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

/// Simplified input view for tarot questions
class TarotInputView extends ConsumerStatefulWidget {
  final VoidCallback onProceed;
  final Function(String) onQuestionChanged;
  final String? initialQuestion;

  const TarotInputView({
    Key? key,
    required this.onProceed,
    required this.onQuestionChanged,
    this.initialQuestion,
  }) : super(key: key);

  @override
  ConsumerState<TarotInputView> createState() => _TarotInputViewState();
}

class _TarotInputViewState extends ConsumerState<TarotInputView> {
  late TextEditingController _questionController;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.initialQuestion);
}

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
}

  void _handleProceed() {
    widget.onQuestionChanged(_questionController.text);
    widget.onProceed();
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    final fontScale = fontSize == FontSize.small ? 0.85 : fontSize == FontSize.large ? 1.15 : 1.0;

    return Column(
      children: [
        // Title
        Text(
          '무엇이 궁금하신가요?',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize * fontScale,
            letterSpacing: -0.5,
          ),
        const SizedBox(height: AppSpacing.spacing2),
        Text(
          '마음을 가라앉히고 질문에 집중해주세요',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize! * fontScale,
          ),
        const SizedBox(height: AppSpacing.spacing8),
        
        // Question input
        GlassContainer(
          padding: AppSpacing.paddingAll20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.spacing2),
                  Text(
                    '당신의 질문',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize * fontScale,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.spacing3),
              TextField(
                controller: _questionController,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '예: 나의 연애운은 어떨까요?\n예: 이직을 해야 할까요?\n예: 오늘 하루는 어떨까요?',
                  filled: true,
                  fillColor: theme.colorScheme.surface.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: AppDimensions.borderRadiusMedium,
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: AppSpacing.paddingAll16,
                ),
                onChanged: widget.onQuestionChanged,
              ),
            ],
          ),
        const SizedBox(height: AppSpacing.spacing6),
        
        // Tip
        Container(
          padding: AppSpacing.paddingAll16,
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.1),
            borderRadius: AppDimensions.borderRadiusMedium,
            border: Border.all(
              color: Colors.purple.withValues(alpha: 0.3),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.purple,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.spacing3),
              Expanded(
                child: Text(
                  '질문이 없으시다면 오늘의 전반적인 운세를 봐드립니다',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize! * fontScale,
                  ),
              ),
            ],
          ),
        const SizedBox(height: AppSpacing.spacing8),
        
        // Proceed button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleProceed,
            style: ElevatedButton.styleFrom(
              padding: AppSpacing.paddingVertical16,
              shape: RoundedRectangleBorder(
                borderRadius: AppDimensions.borderRadiusMedium,
              ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, size: 20 * fontScale),
                const SizedBox(width: AppSpacing.spacing2),
                Text(
                  '계속하기',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
        ),
      ],
    );
}
}