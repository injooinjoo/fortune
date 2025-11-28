import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';

class TextInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? helperText;
  final int maxLines;
  final Function(String)? onChanged;

  const TextInputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.helperText,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (helperText != null) ...[
          Text(
            helperText!,
            style: TypographyUnified.labelMedium.copyWith(
              color: TossDesignSystem.gray600,
            ),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: TossDesignSystem.gray100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          maxLines: maxLines,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
