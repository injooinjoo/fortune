import 'package:flutter/material.dart';

// Export utilities FIRST (before any other code)
export 'date_picker/date_picker_utils.dart';

import 'date_picker/dropdown_date_picker.dart';
import 'date_picker/calendar_date_picker.dart';
import 'date_picker/wheel_date_picker.dart';
import 'date_picker/numeric_date_input.dart';

/// 📅 통합 날짜 선택기
///
/// **Silicon Valley Best Practices**:
/// - ✅ Single Responsibility (단일 책임 원칙)
/// - ✅ Strategy Pattern (전략 패턴 - 4가지 모드)
/// - ✅ Composition over Inheritance (조합 우선)
/// - ✅ Toss Design System 완전 통합
///
/// **4가지 모드**:
/// 1. **Dropdown** - 한국식 년/월/일 드롭다운 (기본값)
/// 2. **Calendar** - 시각적 월간 캘린더 (운세 정보 표시 가능)
/// 3. **Wheel** - 한국식 휠 피커 (년→월→일, Bottom sheet)
/// 4. **Numeric** - 숫자 키패드 직접 입력 (YYYYMMDD)
///
/// **기본 사용 예시**:
/// ```dart
/// UnifiedDatePicker(
///   selectedDate: _birthDate,
///   onDateChanged: (date) => setState(() => _birthDate = date),
///   label: '생년월일',
/// )
/// ```
///
/// **숫자 입력 방식 (연애운 상대방 생년월일)**:
/// ```dart
/// UnifiedDatePicker(
///   mode: UnifiedDatePickerMode.numeric,
///   selectedDate: _partnerBirthDate,
///   onDateChanged: (date) => setState(() => _partnerBirthDate = date),
///   label: '상대방 생년월일',
/// )
/// ```
///
/// **운세 정보와 함께 사용**:
/// ```dart
/// UnifiedDatePicker(
///   mode: UnifiedDatePickerMode.calendar,
///   selectedDate: _moveDate,
///   onDateChanged: (date) => setState(() => _moveDate = date),
///   luckyScores: {DateTime(2025, 1, 15): 0.9},
///   auspiciousDays: [DateTime(2025, 1, 20)],
/// )
/// ```
enum UnifiedDatePickerMode {
  /// 드롭다운 방식 (한국식 년/월/일 선택)
  dropdown,

  /// 캘린더 방식 (TableCalendar 기반 월간 뷰)
  calendar,

  /// 휠 방식 (한국식 년→월→일, Bottom sheet)
  wheel,

  /// 숫자 입력 방식 (키패드 YYYYMMDD)
  numeric,
}

class UnifiedDatePicker extends StatelessWidget {
  // ==================== 기본 파라미터 ====================

  /// 현재 선택된 날짜 (nullable)
  final DateTime? selectedDate;

  /// 날짜 변경 콜백
  final ValueChanged<DateTime> onDateChanged;

  /// 입력 필드 라벨 (선택)
  final String? label;

  /// 선택 가능한 최소 날짜 (기본값: 1900-01-01)
  final DateTime? minDate;

  /// 선택 가능한 최대 날짜 (기본값: 오늘)
  final DateTime? maxDate;

  // ==================== UI 모드 ====================

  /// 날짜 선택기 모드 (기본값: dropdown)
  final UnifiedDatePickerMode mode;

  // ==================== 옵션 ====================

  /// 나이 표시 여부 (기본값: true)
  final bool showAge;

  /// 음력 날짜 표시 여부 (기본값: false, 향후 구현)
  final bool showLunarDate;

  /// 드롭다운 모드에서 초기 확장 상태 (기본값: false)
  final bool initiallyExpanded;

  // ==================== 운세 정보 (Calendar 모드 전용) ====================

  /// 길흉 점수 맵 (0.0 ~ 1.0)
  ///
  /// **예시**:
  /// ```dart
  /// {
  ///   DateTime(2025, 1, 15): 0.9,  // 매우 길한 날
  ///   DateTime(2025, 1, 20): 0.3,  // 피해야 할 날
  /// }
  /// ```
  final Map<DateTime, double>? luckyScores;

  /// 손없는날 리스트
  ///
  /// **예시**:
  /// ```dart
  /// [
  ///   DateTime(2025, 1, 5),
  ///   DateTime(2025, 1, 20),
  /// ]
  /// ```
  final List<DateTime>? auspiciousDays;

  /// 휴일 맵
  ///
  /// **예시**:
  /// ```dart
  /// {
  ///   DateTime(2025, 1, 1): '신정',
  ///   DateTime(2025, 2, 10): '설날',
  /// }
  /// ```
  final Map<DateTime, String>? holidayMap;

  const UnifiedDatePicker({
    super.key,
    this.selectedDate,
    required this.onDateChanged,
    this.label,
    this.minDate,
    this.maxDate,
    this.mode = UnifiedDatePickerMode.dropdown,
    this.showAge = true,
    this.showLunarDate = false,
    this.initiallyExpanded = false,
    this.luckyScores,
    this.auspiciousDays,
    this.holidayMap,
  });

  @override
  Widget build(BuildContext context) {
    // 모드에 따라 적절한 위젯 반환
    switch (mode) {
      case UnifiedDatePickerMode.dropdown:
        return DropdownDatePicker(
          selectedDate: selectedDate,
          onDateChanged: onDateChanged,
          label: label,
          showAge: showAge,
          minDate: minDate,
          maxDate: maxDate,
          initiallyExpanded: initiallyExpanded,
        );

      case UnifiedDatePickerMode.calendar:
        return CalendarDatePickerWidget(
          selectedDate: selectedDate,
          onDateChanged: onDateChanged,
          minDate: minDate,
          maxDate: maxDate,
          luckyScores: luckyScores,
          auspiciousDays: auspiciousDays,
          holidayMap: holidayMap,
        );

      case UnifiedDatePickerMode.wheel:
        return WheelDatePicker(
          selectedDate: selectedDate,
          onDateChanged: onDateChanged,
          label: label,
          minDate: minDate,
          maxDate: maxDate,
          showAge: showAge,
        );

      case UnifiedDatePickerMode.numeric:
        return NumericDateInput(
          selectedDate: selectedDate,
          onDateChanged: onDateChanged,
          label: label,
          minDate: minDate,
          maxDate: maxDate,
          showAge: showAge,
        );
    }
  }
}
