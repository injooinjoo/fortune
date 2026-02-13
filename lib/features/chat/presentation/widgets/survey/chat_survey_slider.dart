import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';

/// 채팅 슬라이더 입력 위젯 (건강, 연애 자신감 등)
class ChatSurveySlider extends StatefulWidget {
  final void Function(double value) onValueChanged;
  final void Function(double value)? onSubmit;
  final String? hintText;
  final double minValue;
  final double maxValue;
  final double initialValue;
  final String? minLabel;
  final String? maxLabel;
  final String? unit;
  final int? divisions;
  final bool showSubmitButton;

  const ChatSurveySlider({
    super.key,
    required this.onValueChanged,
    this.onSubmit,
    this.hintText,
    this.minValue = 0,
    this.maxValue = 100,
    this.initialValue = 50,
    this.minLabel,
    this.maxLabel,
    this.unit,
    this.divisions,
    this.showSubmitButton = true,
  });

  @override
  State<ChatSurveySlider> createState() => _ChatSurveySliderState();
}

class _ChatSurveySliderState extends State<ChatSurveySlider> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  void _handleSubmit() {
    DSHaptics.light();
    widget.onSubmit?.call(_currentValue);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      // 투명 배경 - 하단 입력 영역과 일관성 유지
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.hintText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.xs),
              child: Text(
                widget.hintText!,
                style: typography.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          // 현재 값 표시
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.md,
                vertical: DSSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: colors.textPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.md),
              ),
              child: Text(
                widget.unit != null
                    ? '${_currentValue.round()}${widget.unit}'
                    : _currentValue.round().toString(),
                style: typography.headingSmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          // 슬라이더
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: colors.textPrimary,
              inactiveTrackColor: colors.textPrimary.withValues(alpha: 0.2),
              thumbColor: colors.textPrimary,
              overlayColor: colors.textPrimary.withValues(alpha: 0.1),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 10,
              ),
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: 20,
              ),
            ),
            child: Slider(
              value: _currentValue,
              min: widget.minValue,
              max: widget.maxValue,
              divisions: widget.divisions,
              onChanged: (value) {
                setState(() => _currentValue = value);
                widget.onValueChanged(value);
              },
              onChangeEnd: (value) {
                DSHaptics.light();
              },
            ),
          ),
          // 최소/최대 레이블
          if (widget.minLabel != null || widget.maxLabel != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.minLabel ?? widget.minValue.round().toString(),
                    style: typography.labelSmall.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                  Text(
                    widget.maxLabel ?? widget.maxValue.round().toString(),
                    style: typography.labelSmall.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          // 확인 버튼
          if (widget.showSubmitButton && widget.onSubmit != null) ...[
            const SizedBox(height: DSSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.ctaBackground,
                  foregroundColor: colors.ctaForeground,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DSRadius.md),
                  ),
                ),
                child: Text(
                  '확인',
                  style: typography.labelMedium.copyWith(
                    color: colors.ctaForeground,
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
