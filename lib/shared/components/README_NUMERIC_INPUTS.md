# 숫자패드 날짜/시간 입력 위젯 사용 가이드

## 개요

기존의 드롭다운 선택 방식 대신, 숫자패드로 직접 입력하는 날짜/시간 선택 위젯입니다.

- **NumericDateInput**: YYYY-MM-DD 형식으로 날짜 입력
- **NumericTimeInput**: HH:MM 형식으로 시간 입력

## 특징

✅ **사용자 친화적**: 숫자 8자리만 입력하면 자동으로 하이픈 추가 (19900101 → 1990-01-01)
✅ **실시간 검증**: 올바른 날짜/시간인지 입력하면서 즉시 검증
✅ **에러 표시**: 잘못된 입력 시 명확한 에러 메시지 표시
✅ **자동 포매팅**: 입력하면서 자동으로 구분자(-,:) 추가
✅ **날짜 범위 제한**: firstDate, lastDate로 유효한 날짜 범위 설정 가능

---

## NumericDateInput 사용법

### 기본 사용

```dart
import 'package:fortune/shared/components/numeric_date_input.dart';

NumericDateInput(
  label: '생년월일',
  hint: 'YYYY-MM-DD',
  onDateChanged: (DateTime? date) {
    setState(() {
      _birthDate = date;
    });
  },
)
```

### 옵션 설정

```dart
NumericDateInput(
  initialDate: DateTime(1990, 1, 1),        // 초기값 설정
  label: '생년월일',
  hint: 'YYYY-MM-DD',
  firstDate: DateTime(1900, 1, 1),          // 최소 날짜
  lastDate: DateTime.now(),                  // 최대 날짜
  onDateChanged: (DateTime? date) {
    if (date != null) {
      print('선택된 날짜: ${date.toString()}');
    }
  },
)
```

### 입력 예시

사용자가 `19900101`을 입력하면:
1. 자동으로 `1990-01-01` 형식으로 변환
2. 유효한 날짜인지 검증
3. firstDate/lastDate 범위 내인지 확인
4. 모두 통과하면 `onDateChanged` 콜백 호출

---

## NumericTimeInput 사용법

### 기본 사용

```dart
import 'package:fortune/shared/components/numeric_time_input.dart';

NumericTimeInput(
  label: '태어난 시간',
  hint: 'HH:MM',
  required: false,                           // 선택사항
  onTimeChanged: (String? time) {
    setState(() {
      _birthTime = time;  // "14:30" 형식
    });
  },
)
```

### 옵션 설정

```dart
NumericTimeInput(
  initialTime: TimeOfDay(hour: 14, minute: 30),  // 초기값 설정
  label: '약속 시간',
  hint: 'HH:MM',
  required: true,                                  // 필수 입력
  onTimeChanged: (String? time) {
    if (time != null) {
      print('선택된 시간: $time');  // "14:30"
    }
  },
)
```

### 입력 예시

사용자가 `1430`을 입력하면:
1. 자동으로 `14:30` 형식으로 변환
2. 시간(0-23), 분(0-59) 유효성 검증
3. 통과하면 `onTimeChanged` 콜백 호출

---

## 실제 적용 예시

### 프로필 편집 페이지 (profile_edit_page.dart)

```dart
class _ProfileEditPageState extends State<ProfileEditPage> {
  DateTime? _birthDate;
  String? _birthTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 생년월일 입력
        NumericDateInput(
          initialDate: _birthDate,
          label: '생년월일',
          hint: 'YYYY-MM-DD',
          onDateChanged: (date) {
            setState(() {
              _birthDate = date;
            });
          },
          firstDate: DateTime(1900, 1, 1),
          lastDate: DateTime.now(),
        ),
        SizedBox(height: 20),

        // 태어난 시간 입력 (선택)
        NumericTimeInput(
          initialTime: _birthTime != null
              ? TimeOfDay(
                  hour: int.parse(_birthTime!.split(':')[0]),
                  minute: int.parse(_birthTime!.split(':')[1]),
                )
              : null,
          label: '태어난 시간',
          hint: 'HH:MM',
          required: false,
          onTimeChanged: (time) {
            setState(() {
              _birthTime = time;
            });
          },
        ),
      ],
    );
  }
}
```

---

## 에러 처리

### NumericDateInput 에러

| 에러 메시지 | 원인 |
|------------|------|
| "올바른 날짜 형식이 아닙니다 (YYYY-MM-DD)" | 유효하지 않은 날짜 (예: 2월 30일) |
| firstDate 미만 | 설정된 최소 날짜보다 이전 |
| lastDate 초과 | 설정된 최대 날짜보다 이후 |

### NumericTimeInput 에러

| 에러 메시지 | 원인 |
|------------|------|
| "올바른 시간 형식이 아닙니다 (HH:MM)" | 유효하지 않은 시간 (예: 25:00, 14:99) |
| "시간을 입력해주세요" | required=true인데 비어있음 |

---

## 스타일 커스터마이징

두 위젯 모두 TOSS Design System을 사용하여 일관된 UI를 제공합니다:

- **포커스 시**: 파란색 테두리 (TossDesignSystem.primaryBlue)
- **에러 시**: 빨간색 테두리 (TossDesignSystem.error)
- **기본**: 회색 테두리 (#E5E5E5)

---

## 기존 드롭다운과 비교

### Before (드롭다운)

```dart
// 년도 선택
DropdownButtonFormField<String>(
  items: yearOptions.map((year) => DropdownMenuItem(...)).toList(),
  onChanged: (value) => setState(() => _birthYear = value),
)

// 월 선택
DropdownButtonFormField<String>(
  items: monthOptions.map((month) => DropdownMenuItem(...)).toList(),
  onChanged: (value) => setState(() => _birthMonth = value),
)

// 일 선택
DropdownButtonFormField<String>(
  items: dayOptions.map((day) => DropdownMenuItem(...)).toList(),
  onChanged: (value) => setState(() => _birthDay = value),
)
```

❌ **문제점**:
- 3개 드롭다운 필요
- 스크롤해서 선택해야 함
- 모바일에서 불편함

### After (숫자패드)

```dart
NumericDateInput(
  label: '생년월일',
  onDateChanged: (date) => setState(() => _birthDate = date),
)
```

✅ **장점**:
- 하나의 위젯으로 완결
- 숫자패드로 빠른 입력
- 자동 포매팅 및 검증

---

## 주의사항

1. **initialDate 설정 시**: TimeOfDay 변환 시 `split(':')` 에러 방지를 위해 null 체크 필수
2. **onDateChanged/onTimeChanged**: null이 올 수 있으므로 null 처리 필요
3. **날짜 형식**: 반환되는 DateTime은 UTC가 아닌 로컬 시간
4. **시간 형식**: 반환되는 시간은 "HH:MM" String 형식 (24시간제)

---

## 마이그레이션 가이드

### 1. import 추가

```dart
import 'package:fortune/shared/components/numeric_date_input.dart';
import 'package:fortune/shared/components/numeric_time_input.dart';
```

### 2. 상태 변수 변경

```dart
// Before
String _birthYear = '';
String _birthMonth = '';
String _birthDay = '';
String? _birthTimePeriod;

// After
DateTime? _birthDate;
String? _birthTime;
```

### 3. UI 위젯 교체

드롭다운 3개 → `NumericDateInput` 1개
시간 드롭다운 → `NumericTimeInput` 1개

### 4. 저장 로직 수정

```dart
// Before
final isoDate = FortuneDateUtils.koreanToIsoDate(
  _birthYear,
  _birthMonth,
  _birthDay,
);

// After
final isoDate = _birthDate!.toIso8601String().split('T')[0];
```

---

## 참고

- 프로필 편집: `lib/screens/profile/profile_edit_page.dart`
- 행운아이템: `lib/features/fortune/presentation/pages/lucky_items_unified_page.dart`
