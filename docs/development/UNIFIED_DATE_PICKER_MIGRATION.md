# 📅 UnifiedDatePicker 마이그레이션 가이드

## 🎯 개요

모든 날짜 선택기를 `UnifiedDatePicker`로 통합하여 일관성 있는 UI/UX를 제공합니다.

---

## 📦 새로운 모듈 구조

```
lib/core/widgets/
├── unified_date_picker.dart          # 메인 모듈 (이것만 import!)
└── date_picker/
    ├── dropdown_date_picker.dart     # 드롭다운 구현
    ├── calendar_date_picker.dart     # 캘린더 구현
    ├── wheel_date_picker.dart        # 휠 구현
    └── date_picker_utils.dart        # 공통 유틸
```

---

## 🔄 마이그레이션 방법

### 1️⃣ **기본 showDatePicker → UnifiedDatePicker (Wheel 모드)**

#### ❌ 기존 코드
```dart
final picked = await showDatePicker(
  context: context,
  initialDate: _birthDate ?? DateTime.now(),
  firstDate: DateTime(1900),
  lastDate: DateTime.now(),
);

if (picked != null) {
  setState(() {
    _birthDate = picked;
  });
}
```

#### ✅ 새로운 코드
```dart
import 'package:fortune/core/widgets/unified_date_picker.dart';

UnifiedDatePicker(
  mode: DatePickerMode.wheel,  // iOS 스타일 휠
  selectedDate: _birthDate,
  onDateChanged: (date) {
    setState(() {
      _birthDate = date;
    });
  },
  label: '생년월일',
  minDate: DateTime(1900),
  maxDate: DateTime.now(),
  showAge: true,  // 나이 표시
)
```

---

### 2️⃣ **KoreanDatePicker → UnifiedDatePicker (Dropdown 모드)**

#### ❌ 기존 코드
```dart
import 'package:fortune/shared/components/korean_date_picker.dart';

KoreanDatePicker(
  selectedDate: _birthDate,
  onDateChanged: (date) {
    setState(() {
      _birthDate = date;
    });
  },
  label: '생년월일',
  showAge: true,
)
```

#### ✅ 새로운 코드
```dart
import 'package:fortune/core/widgets/unified_date_picker.dart';

UnifiedDatePicker(
  mode: DatePickerMode.dropdown,  // 한국식 드롭다운
  selectedDate: _birthDate,
  onDateChanged: (date) {
    setState(() {
      _birthDate = date;
    });
  },
  label: '생년월일',
  showAge: true,
)
```

---

### 3️⃣ **EnhancedDatePicker → UnifiedDatePicker (Calendar 모드)**

#### ❌ 기존 코드
```dart
import 'package:fortune/features/fortune/presentation/widgets/enhanced_date_picker.dart';

EnhancedDatePicker(
  initialDate: _moveDate,
  onDateSelected: (date) {
    setState(() {
      _moveDate = date;
    });
  },
  luckyScores: _luckyScores,
  auspiciousDays: _auspiciousDays,
  holidayMap: _holidays,
)
```

#### ✅ 새로운 코드
```dart
import 'package:fortune/core/widgets/unified_date_picker.dart';

UnifiedDatePicker(
  mode: UnifiedDatePickerMode.calendar,  // 캘린더 뷰
  selectedDate: _moveDate,
  onDateChanged: (date) {
    setState(() {
      _moveDate = date;
    });
  },
  luckyScores: _luckyScores,
  auspiciousDays: _auspiciousDays,
  holidayMap: _holidays,
)
```

---

### 4️⃣ **CupertinoDatePicker → UnifiedDatePicker (Wheel 모드)**

#### ❌ 기존 코드
```dart
showModalBottomSheet(
  context: context,
  builder: (context) => Container(
    height: 300,
    child: CupertinoDatePicker(
      mode: CupertinoDatePickerMode.date,
      initialDateTime: _selectedDate ?? DateTime.now(),
      onDateTimeChanged: (date) {
        setState(() {
          _selectedDate = date;
        });
      },
    ),
  ),
)
```

#### ✅ 새로운 코드
```dart
import 'package:fortune/core/widgets/unified_date_picker.dart';

UnifiedDatePicker(
  mode: DatePickerMode.wheel,  // iOS 휠 (모달 자동 처리)
  selectedDate: _selectedDate,
  onDateChanged: (date) {
    setState(() {
      _selectedDate = date;
    });
  },
  label: '날짜 선택',
  showAge: false,
)
```

---

### 5️⃣ **FortuneInputWidgets.buildDatePicker (이미 통합됨)**

#### ✅ 그대로 사용 가능!
```dart
import 'package:fortune/core/widgets/fortune_input_widgets.dart';

FortuneInputWidgets.buildDatePicker(
  context: context,
  label: '생년월일',
  selectedDate: _birthDate,
  onDateSelected: (date) => setState(() => _birthDate = date),
  mode: UnifiedDatePickerMode.dropdown,  // 선택 가능
  showAge: true,
)
```

---

## 🎨 3가지 모드 비교

| 모드 | 특징 | 적합한 경우 | UI 스타일 |
|------|------|------------|-----------|
| **Dropdown** | 한국식 년/월/일 드롭다운 | 정확한 날짜 입력, 생년월일 | 확장/축소 애니메이션 |
| **Calendar** | TableCalendar 월간 뷰 | 시각적 선택, 운세 정보 표시 | 월간 캘린더 |
| **Wheel** | **한국식 휠 피커 (년→월→일)** | **모바일 친화적, 빠른 선택** | **Bottom sheet + 3개 휠** |

### ✨ **Wheel 모드 개선사항 (한국식 UI)**
- ✅ **년 → 월 → 일** 순서로 3개 휠 표시
- ✅ Bottom sheet 모달
- ✅ 취소/완료 버튼
- ✅ 선택된 날짜 실시간 미리보기
- ✅ 나이 자동 계산 표시
- ✅ Toss 디자인 시스템 색상

---

## 📋 마이그레이션 체크리스트

각 파일 마이그레이션 시 확인:

- [ ] `import 'package:fortune/core/widgets/unified_date_picker.dart';` 추가
- [ ] 기존 날짜 선택기 코드를 `UnifiedDatePicker`로 교체
- [ ] 적절한 `mode` 선택 (dropdown / calendar / wheel)
- [ ] `selectedDate`와 `onDateChanged` 파라미터 연결
- [ ] `minDate`, `maxDate` 범위 설정 (필요시)
- [ ] `showAge` 옵션 설정 (필요시)
- [ ] `label` 텍스트 설정 (필요시)
- [ ] 기존 import 제거 (KoreanDatePicker, EnhancedDatePicker 등)
- [ ] `flutter analyze` 실행하여 에러 확인
- [ ] 실제 디바이스에서 동작 테스트

---

## 🗂️ 마이그레이션 대상 파일 목록 (24개)

### ✅ 완료 (1개)
- `lib/core/widgets/fortune_input_widgets.dart`

### ⏳ 작업 필요 (23개)

#### 운세 페이지 (15개)
1. `lib/features/fortune/presentation/pages/biorhythm_input_page.dart`
2. `lib/features/fortune/presentation/pages/blind_date_fortune_page.dart`
3. `lib/features/fortune/presentation/pages/compatibility_page.dart`
4. `lib/features/fortune/presentation/pages/ex_lover_fortune_simple_page.dart`
5. `lib/features/fortune/presentation/pages/lucky_items_page_unified.dart`
6. `lib/features/fortune/presentation/pages/saju_psychology_fortune_page.dart`
7. `lib/features/fortune/presentation/pages/daily_calendar_fortune_page.dart`

#### 인터랙티브 페이지 (4개)
8. `lib/features/interactive/presentation/pages/dream_page.dart`
9. `lib/features/interactive/presentation/pages/dream_interpretation_page.dart`
10. `lib/features/interactive/presentation/pages/psychology_test_page.dart`

#### 위젯 (4개)
11. `lib/features/fortune/presentation/widgets/saju_input_form.dart`
12. `lib/features/fortune/presentation/widgets/moving_input_step1.dart`
13. `lib/features/fortune/presentation/widgets/blood_type_personality_chart.dart`
14. `lib/presentation/widgets/fortune_explanation_bottom_sheet.dart`
15. `lib/presentation/widgets/profile_edit_dialogs/birth_date_edit_dialog.dart`

#### 레거시 제거 대상 (3개)
- `lib/shared/components/korean_date_picker.dart` ❌ 삭제 예정
- `lib/shared/components/custom_calendar_date_picker.dart` ❌ 삭제 예정
- `lib/features/fortune/presentation/widgets/enhanced_date_picker.dart` ❌ 삭제 예정

---

## 💡 유틸리티 함수 사용

`DatePickerUtils`를 통해 공통 기능 사용 가능:

```dart
import 'package:fortune/core/widgets/unified_date_picker.dart';

// 나이 계산
final age = DatePickerUtils.calculateAge(birthDate);

// 한국어 포맷팅
final formatted = DatePickerUtils.formatKorean(date, showWeekday: true);
// 결과: "2025년 1월 15일 (수)"

// 숫자 포맷팅
final numeric = DatePickerUtils.formatNumeric(date);
// 결과: "2025.01.15"

// ISO 8601 포맷팅
final iso = DatePickerUtils.formatISO(date);
// 결과: "2025-01-15"

// 요일 확인
final weekday = DatePickerUtils.getKoreanWeekday(date);
// 결과: "수"

// 주말 여부
final isWeekend = DatePickerUtils.isWeekend(date);

// 범위 체크
final isInRange = DatePickerUtils.isInRange(
  date,
  minDate: DateTime(2025, 1, 1),
  maxDate: DateTime(2025, 12, 31),
);
```

---

## 🚨 주의사항

1. **한 번에 하나씩 마이그레이션**
   - 파일 하나 수정 → 테스트 → 다음 파일
   - 일괄 변경 금지 (CLAUDE.md 규칙)

2. **기존 기능 유지**
   - 사용자가 느끼는 변화 최소화
   - 동일한 UX 제공

3. **모드 선택 가이드**
   - 생년월일, 프로필 입력 → `dropdown` (한국식)
   - 이사 날짜, 운세 날짜 → `calendar` (시각적)
   - 일반 날짜 입력 → `wheel` (빠른 선택)

4. **테스트 필수**
   - `flutter analyze` 실행
   - 실제 디바이스에서 동작 확인
   - 나이 계산 정확성 확인

---

## 📚 참고 파일

- **메인 모듈**: `lib/core/widgets/unified_date_picker.dart`
- **유틸리티**: `lib/core/widgets/date_picker/date_picker_utils.dart`
- **예시**: `lib/core/widgets/fortune_input_widgets.dart:40-59`

---

## ✅ 마이그레이션 완료 후

1. 레거시 파일 3개 삭제
2. CLAUDE.md에 UnifiedDatePicker 사용 규칙 추가
3. 전체 통합 테스트 실행
4. JIRA 완료 처리

---

**작성일**: 2025-01-15
**작성자**: Claude Code
**버전**: 1.0
