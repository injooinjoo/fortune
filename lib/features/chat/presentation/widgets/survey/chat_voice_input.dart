import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/widgets/unified_voice_bubble_input.dart';

/// 채팅 음성/텍스트 입력 위젯 (꿈해몽, 소원용)
///
/// UnifiedVoiceBubbleInput을 채팅 설문 흐름에 맞게 래핑
class ChatVoiceInput extends StatefulWidget {
  final void Function(String text) onSubmit;
  final String hintText;
  final String? submitLabel;

  const ChatVoiceInput({
    super.key,
    required this.onSubmit,
    this.hintText = '말하거나 적어주세요',
    this.submitLabel,
  });

  @override
  State<ChatVoiceInput> createState() => _ChatVoiceInputState();
}

class _ChatVoiceInputState extends State<ChatVoiceInput> {
  final TextEditingController _controller = TextEditingController();
  bool _isRecording = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      DSHaptics.light();
      widget.onSubmit(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasText = _controller.text.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark ? colors.backgroundSecondary : colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.textPrimary.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 음성/텍스트 입력
          UnifiedVoiceBubbleInput(
            controller: _controller,
            hintText: widget.hintText,
            transcribingText: '듣고 있어요...',
            showCharacterCount: true,
            showEditDeleteButtons: true,
            onTextChanged: () => setState(() {}),
            onRecordingChanged: (isRecording) {
              setState(() => _isRecording = isRecording);
            },
          ),
          // 전송 버튼 (텍스트가 있을 때만)
          if (hasText && !_isRecording) ...[
            const SizedBox(height: DSSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accentSecondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DSRadius.md),
                  ),
                ),
                child: Text(
                  widget.submitLabel ?? '확인',
                  style: typography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
