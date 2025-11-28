import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';

class BirthDateInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(DateTime) onDateSelected;

  const BirthDateInput({
    super.key,
    required this.controller,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YYYY-MM-DD 형식으로 입력해주세요 (예: 1990-05-15)',
          style: TypographyUnified.labelSmall.copyWith(
            color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'YYYY-MM-DD',
            prefixIcon: Icon(Icons.calendar_today),
            filled: true,
            fillColor: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            // YYYY-MM-DD 형식 파싱
            if (value.length == 10) {
              try {
                final parts = value.split('-');
                if (parts.length == 3) {
                  final year = int.parse(parts[0]);
                  final month = int.parse(parts[1]);
                  final day = int.parse(parts[2]);
                  final date = DateTime(year, month, day);
                  onDateSelected(date);
                }
              } catch (e) {
                // 파싱 실패 - 아무것도 안함
              }
            }
          },
        ),
      ],
    );
  }
}
