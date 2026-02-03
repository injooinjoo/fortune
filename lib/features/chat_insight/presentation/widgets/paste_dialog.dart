import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';

/// 카카오톡 대화 붙여넣기 바텀시트
class PasteDialog extends StatefulWidget {
  final void Function(String text) onSubmit;

  const PasteDialog({super.key, required this.onSubmit});

  @override
  State<PasteDialog> createState() => _PasteDialogState();
}

class _PasteDialogState extends State<PasteDialog> {
  final _controller = TextEditingController();
  int _lineCount = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateLineCount);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateLineCount() {
    final lines = _controller.text.split('\n').length;
    if (lines != _lineCount) {
      setState(() => _lineCount = lines);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(DSRadius.lg),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(DSSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 드래그 핸들
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.textTertiary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: DSSpacing.md),

                // 헤더
                Text(
                  '카카오톡 대화 붙여넣기',
                  style: typography.headingSmall
                      .copyWith(color: colors.textPrimary),
                ),
                const SizedBox(height: DSSpacing.xs),
                Text(
                  '카카오톡 > 채팅방 > ⋯ > 대화 내보내기 > 텍스트만',
                  style: typography.bodySmall
                      .copyWith(color: colors.textTertiary),
                ),
                const SizedBox(height: DSSpacing.md),

                // 텍스트 입력 영역
                Expanded(
                  child: Semantics(
                    label: '카카오톡 대화 붙여넣기. 현재 $_lineCount줄',
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: typography.bodySmall
                          .copyWith(color: colors.textPrimary),
                      decoration: InputDecoration(
                        hintText:
                            '여기에 카카오톡 대화를 붙여넣어 주세요...\n\n'
                            '예시:\n'
                            '2026년 1월 4일 오후 2:30, 이름 : 메시지',
                        hintStyle: typography.bodySmall
                            .copyWith(color: colors.textTertiary),
                        filled: true,
                        fillColor: colors.surface,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(DSRadius.md),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.all(DSSpacing.md),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: DSSpacing.sm),

                // 하단: 줄 수 + 분석 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_lineCount줄',
                      style: typography.labelSmall
                          .copyWith(color: colors.textTertiary),
                    ),
                    DSButton.primary(
                      text: '분석하기',
                      fullWidth: false,
                      onPressed: _controller.text.trim().isEmpty
                          ? null
                          : () => widget.onSubmit(_controller.text),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
