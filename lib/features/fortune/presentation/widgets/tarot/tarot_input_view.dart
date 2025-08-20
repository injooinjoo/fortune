import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/glassmorphism/glass_container.dart';
import '../../../../../shared/components/app_header.dart' show FontSize;
import '../../../../../presentation/providers/font_size_provider.dart';

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
            fontSize: 24 * fontScale,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '마음을 가라앉히고 질문에 집중해주세요',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontSize: 16 * fontScale,
          ),
        ),
        const SizedBox(height: 32),
        
        // Question input
        GlassContainer(
          padding: const EdgeInsets.all(20),
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
                  const SizedBox(width: 8),
                  Text(
                    '당신의 질문',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16 * fontScale,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _questionController,
                style: TextStyle(fontSize: 16 * fontScale),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '예: 나의 연애운은 어떨까요?\n예: 이직을 해야 할까요?\n예: 오늘 하루는 어떨까요?',
                  filled: true,
                  fillColor: theme.colorScheme.surface.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(16),
                ),
                onChanged: widget.onQuestionChanged,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Tip
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.purple.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.purple,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '질문이 없으시다면 오늘의 전반적인 운세를 봐드립니다',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 14 * fontScale,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        
        // Proceed button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleProceed,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, size: 20 * fontScale),
                const SizedBox(width: 8),
                Text(
                  '계속하기',
                  style: TextStyle(
                    fontSize: 18 * fontScale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}