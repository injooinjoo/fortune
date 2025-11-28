import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';

class BirthTimeInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(TimeOfDay) onTimeSelected;

  const BirthTimeInput({
    super.key,
    required this.controller,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HH:MM 형식으로 입력해주세요 (예: 14:30)',
          style: TypographyUnified.labelSmall.copyWith(
            color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'HH:MM',
            prefixIcon: Icon(Icons.access_time),
            filled: true,
            fillColor: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            // HH:MM 형식 파싱
            if (value.length == 5 && value.contains(':')) {
              try {
                final parts = value.split(':');
                if (parts.length == 2) {
                  final hour = int.parse(parts[0]);
                  final minute = int.parse(parts[1]);

                  if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
                    final time = TimeOfDay(hour: hour, minute: minute);
                    onTimeSelected(time);
                  }
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
