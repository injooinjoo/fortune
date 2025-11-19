import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/toss_design_system.dart';
import '../theme/typography_unified.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.labelMedium.copyWith(
            color: isDark
                ? TossDesignSystem.textSecondaryDark
                : TossDesignSystem.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            await showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) => Container(
                height: 300,
                decoration: BoxDecoration(
                  color: isDark
                      ? TossDesignSystem.grayDark800
                      : TossDesignSystem.gray50,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              '취소',
                              style: context.bodyMedium.copyWith(
                                color: TossDesignSystem.textSecondaryDark,
                              ),
                            ),
                          ),
                          Text(
                            '시간 선택',
                            style: context.heading4,
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              '완료',
                              style: context.bodyMedium.copyWith(
                                color: TossDesignSystem.tossBlue,
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
                              style: context.bodyLarge,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? TossDesignSystem.grayDark800
                  : TossDesignSystem.gray50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? TossDesignSystem.borderDark
                    : TossDesignSystem.borderLight,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: isDark
                      ? TossDesignSystem.textSecondaryDark
                      : TossDesignSystem.textSecondaryLight,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  selectedHour != null
                      ? '$selectedHour시'
                      : '시간을 선택해주세요',
                  style: context.bodyMedium.copyWith(
                    color: selectedHour != null
                        ? (isDark
                            ? TossDesignSystem.textPrimaryDark
                            : TossDesignSystem.textPrimaryLight)
                        : (isDark
                            ? TossDesignSystem.textSecondaryDark
                            : TossDesignSystem.textSecondaryLight),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.labelMedium.copyWith(
            color: isDark
                ? TossDesignSystem.textSecondaryDark
                : TossDesignSystem.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.entries.map((entry) {
            final isSelected = selectedValue == entry.key;

            return InkWell(
              onTap: () => onSelected(entry.key),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? TossDesignSystem.tossBlue
                      : (isDark
                          ? TossDesignSystem.grayDark800
                          : TossDesignSystem.gray50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? TossDesignSystem.tossBlue
                        : (isDark
                            ? TossDesignSystem.borderDark
                            : TossDesignSystem.borderLight),
                  ),
                ),
                child: Text(
                  entry.value,
                  style: context.bodyMedium.copyWith(
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? TossDesignSystem.textPrimaryDark
                            : TossDesignSystem.textPrimaryLight),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.labelMedium.copyWith(
            color: isDark
                ? TossDesignSystem.textSecondaryDark
                : TossDesignSystem.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: context.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: context.bodyMedium.copyWith(
              color: isDark
                  ? TossDesignSystem.textSecondaryDark
                  : TossDesignSystem.textSecondaryLight,
            ),
            filled: true,
            fillColor: isDark
                ? TossDesignSystem.grayDark800
                : TossDesignSystem.gray50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? TossDesignSystem.borderDark
                    : TossDesignSystem.borderLight,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? TossDesignSystem.borderDark
                    : TossDesignSystem.borderLight,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: TossDesignSystem.tossBlue,
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
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: TossDesignSystem.tossBlue,
          disabledBackgroundColor: TossDesignSystem.textSecondaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
                style: context.buttonMedium.copyWith(
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
