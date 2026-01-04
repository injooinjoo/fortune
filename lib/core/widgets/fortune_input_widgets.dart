import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../design_system/design_system.dart';
import 'unified_date_picker.dart';

/// 🎨 공통 운세 입력 위젯 라이브러리
///
/// Silicon Valley Best Practices:
/// - ✅ Reusable Components (재사용 가능한 컴포넌트)
/// - ✅ Composition over Inheritance (상속보다 조합)
/// - ✅ Consistent Design System (일관된 디자인 시스템)
/// - ✅ Type-Safe Callbacks (타입 안전 콜백)
///
/// **사용 예시**:
/// ```dart
/// FortuneInputWidgets.buildDatePicker(
///   context: context,
///   label: '생년월일',
///   selectedDate: _birthDate,
///   onDateSelected: (date) => setState(() => _birthDate = date),
/// )
/// ```
class FortuneInputWidgets {
  // Private constructor to prevent instantiation
  FortuneInputWidgets._();

  // ==================== 📅 날짜/시간 입력 ====================

  /// 날짜 선택기 (DatePicker) - UnifiedDatePicker 사용
  ///
  /// **파라미터**:
  /// - `label`: 입력 필드 라벨
  /// - `selectedDate`: 현재 선택된 날짜 (nullable)
  /// - `onDateSelected`: 날짜 선택 콜백
  /// - `firstDate`: 선택 가능한 최소 날짜 (기본값: 1900-01-01)
  /// - `lastDate`: 선택 가능한 최대 날짜 (기본값: 오늘)
  /// - `mode`: 날짜 선택기 모드 (기본값: wheel - 기존 showDatePicker 대체)
  /// - `showAge`: 나이 표시 여부 (기본값: false)
  static Widget buildDatePicker({
    required BuildContext context,
    required String label,
    required DateTime? selectedDate,
    required ValueChanged<DateTime> onDateSelected,
    DateTime? firstDate,
    DateTime? lastDate,
    UnifiedDatePickerMode mode = UnifiedDatePickerMode.wheel, // wheel 모드가 기존 동작과 가장 유사
    bool showAge = false,
  }) {
    return UnifiedDatePicker(
      selectedDate: selectedDate,
      onDateChanged: onDateSelected,
      label: label,
      minDate: firstDate ?? DateTime(1900),
      maxDate: lastDate ?? DateTime.now(),
      mode: mode,
      showAge: showAge,
    );
  }

  /// 시간 선택기 (TimePicker - iOS Style Wheel)
  ///
  /// **파라미터**:
  /// - `label`: 입력 필드 라벨
  /// - `selectedHour`: 현재 선택된 시간 (nullable, 0-23)
  /// - `onHourSelected`: 시간 선택 콜백
  static Widget buildTimePicker({
    required BuildContext context,
    required String label,
    required int? selectedHour,
    required ValueChanged<int> onHourSelected,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: typography.labelMedium.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: DSSpacing.sm),
        InkWell(
          onTap: () async {
            await showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              barrierColor: DSColors.overlay,
              builder: (ctx) {
                final sheetColors = ctx.colors;
                final sheetTypography = ctx.typography;
                return Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: sheetColors.surfaceSecondary,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(DSRadius.xl),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(DSSpacing.md),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(
                                '취소',
                                style: sheetTypography.bodyMedium.copyWith(
                                  color: sheetColors.textSecondary,
                                ),
                              ),
                            ),
                            Text(
                              '시간 선택',
                              style: sheetTypography.headingSmall,
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(
                                '완료',
                                style: sheetTypography.bodyMedium.copyWith(
                                  color: sheetColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: selectedHour ?? 0,
                          ),
                          itemExtent: 40,
                          onSelectedItemChanged: onHourSelected,
                          children: List.generate(
                            24,
                            (index) => Center(
                              child: Text(
                                '$index시',
                                style: sheetTypography.bodyLarge,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.all(DSSpacing.md),
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(DSRadius.md),
              border: Border.all(
                color: colors.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: colors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: DSSpacing.sm + 4),
                Text(
                  selectedHour != null
                      ? '$selectedHour시'
                      : '시간을 선택해주세요',
                  style: typography.bodyMedium.copyWith(
                    color: selectedHour != null
                        ? colors.textPrimary
                        : colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== 🎯 선택 입력 ====================

  /// 단일 선택 (Single Select)
  ///
  /// **파라미터**:
  /// - `label`: 입력 필드 라벨
  /// - `options`: 선택 가능한 옵션 리스트 (value → label)
  /// - `selectedValue`: 현재 선택된 값 (nullable)
  /// - `onSelected`: 선택 콜백
  static Widget buildSingleSelect<T>({
    required BuildContext context,
    required String label,
    required Map<T, String> options,
    required T? selectedValue,
    required ValueChanged<T> onSelected,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: typography.labelMedium.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: DSSpacing.sm),
        Wrap(
          spacing: DSSpacing.sm,
          runSpacing: DSSpacing.sm,
          children: options.entries.map((entry) {
            final isSelected = selectedValue == entry.key;

            return InkWell(
              onTap: () => onSelected(entry.key),
              borderRadius: BorderRadius.circular(DSRadius.md),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.md,
                  vertical: DSSpacing.sm + 4,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.accent
                      : colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(DSRadius.md),
                  border: Border.all(
                    color: isSelected
                        ? colors.accent
                        : colors.border,
                  ),
                ),
                child: Text(
                  entry.value,
                  style: typography.bodyMedium.copyWith(
                    color: isSelected
                        ? Colors.white
                        : colors.textPrimary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 텍스트 입력 (TextField)
  ///
  /// **파라미터**:
  /// - `label`: 입력 필드 라벨
  /// - `hint`: 플레이스홀더 텍스트
  /// - `controller`: TextEditingController
  /// - `maxLines`: 최대 줄 수 (기본값: 1)
  /// - `keyboardType`: 키보드 타입 (기본값: text)
  static Widget buildTextField({
    required BuildContext context,
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: typography.labelMedium.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: DSSpacing.sm),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: typography.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: typography.bodyMedium.copyWith(
              color: colors.textTertiary,
            ),
            filled: true,
            fillColor: colors.surfaceSecondary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DSRadius.md),
              borderSide: BorderSide(
                color: colors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DSRadius.md),
              borderSide: BorderSide(
                color: colors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DSRadius.md),
              borderSide: BorderSide(
                color: colors.accent,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== 🎬 액션 버튼 ====================

  /// 제출 버튼 (Primary Action Button)
  ///
  /// **파라미터**:
  /// - `label`: 버튼 텍스트
  /// - `onPressed`: 버튼 클릭 콜백 (nullable = disabled)
  /// - `isLoading`: 로딩 중 상태 (기본값: false)
  static Widget buildSubmitButton({
    required BuildContext context,
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.accent,
          disabledBackgroundColor: colors.textTertiary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DSRadius.md),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: typography.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
