import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';

/// 텍스트 입력 + "없음" 스킵 칩 위젯
class TextWithSkipInput extends StatefulWidget {
  final VoidCallback onSkip;
  final TextEditingController textController;

  const TextWithSkipInput({
    super.key,
    required this.onSkip,
    required this.textController,
  });

  @override
  State<TextWithSkipInput> createState() => _TextWithSkipInputState();
}

class _TextWithSkipInputState extends State<TextWithSkipInput> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.textController.text.isNotEmpty;
    widget.textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.textController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.textController.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 텍스트가 있으면 칩 숨김
    if (_hasText) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8,
        children: [
          GestureDetector(
            onTap: () {
              DSHaptics.light();
              widget.onSkip();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: context.colors.textSecondary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '🎲 없음',
                style: context.typography.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
