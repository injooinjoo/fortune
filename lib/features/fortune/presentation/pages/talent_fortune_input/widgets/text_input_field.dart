import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';

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
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (helperText != null) ...[
          Text(
            helperText!,
            style: DSTypography.labelMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: colors.backgroundSecondary,
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
