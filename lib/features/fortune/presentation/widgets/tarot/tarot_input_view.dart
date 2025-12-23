import 'package:flutter/material.dart';
import '../../../../../core/widgets/unified_button.dart';
import '../../../../../core/widgets/unified_button_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/widgets/unified_voice_text_field.dart';

/// Simplified input view for tarot questions
class TarotInputView extends ConsumerStatefulWidget {
  final VoidCallback onProceed;
  final Function(String) onQuestionChanged;
  final String? initialQuestion;

  const TarotInputView({
    super.key,
    required this.onProceed,
    required this.onQuestionChanged,
    this.initialQuestion,
  });

  @override
  ConsumerState<TarotInputView> createState() => _TarotInputViewState();
}

class _TarotInputViewState extends ConsumerState<TarotInputView> {
  @override
  void initState() {
    super.initState();
  }

  void _handleQuestionSubmit(String text) {
    widget.onQuestionChanged(text);
    widget.onProceed();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Title
        Text(
          '무엇이 궁금하신가요?',
          style: context.typography.headingLarge.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '마음을 가라앉히고 질문에 집중해주세요',
          style: context.typography.labelLarge.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 32),

        // Voice input
        UnifiedVoiceTextField(
          onSubmit: _handleQuestionSubmit,
          hintText: '질문을 말하거나 적어주세요',
          transcribingText: '듣고 있어요...',
        ),

        const SizedBox(height: 24),

        // Tip
        Container(
          padding: const EdgeInsets.all(DSSpacing.md),
          decoration: BoxDecoration(
            color: DSColors.accentSecondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DSRadius.md),
            border: Border.all(
              color: DSColors.accentSecondary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: DSColors.accentSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '질문이 없으시다면 오늘의 전반적인 운세를 봐드립니다',
                  style: context.typography.bodySmall.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Proceed button (for skipping question)
        SizedBox(
          width: double.infinity,
          child: UnifiedButton(
            text: '질문 없이 진행하기',
            onPressed: () {
              widget.onQuestionChanged('');
              widget.onProceed();
            },
            style: UnifiedButtonStyle.secondary,
            size: UnifiedButtonSize.large,
            icon: const Icon(Icons.arrow_forward),
          ),
        ),
      ],
    );
  }
}
