# Flutter 상수 표현식 에러 수정

## 🎯 수정 목표
const 위젯에서 non-const 값을 사용하는 에러를 수정합니다.

## 📁 수정 대상 파일 (4개)

### 1. `lib/features/fortune/presentation/pages/same_birthday_celebrity_fortune_page.dart`
```dart
// 에러 위치: 라인 475, 504
Error: Non-constant list literal is not a constant expression.
children: [
```

### 2. `lib/features/fortune/presentation/pages/tarot_enhanced_page.dart`
```dart
// 에러 위치: 라인 360, 367
Error: Non-constant list literal is not a constant expression.
colors: [
children: [
```

### 3. `lib/presentation/widgets/five_elements_widget.dart`
```dart
// 에러 위치: 라인 202, 431
Error: Non-constant list literal is not a constant expression.
children: [
```

### 4. `lib/screens/onboarding/steps/name_step.dart`
```dart
// 에러 위치: 라인 122
Error: Extension operations can't be used in constant expressions.
on: 600.ms).shimmer(,
```

### 5. `lib/presentation/widgets/fortune_explanation_bottom_sheet.dart`
```dart
// 에러 위치: 라인 1193-1194
Error: Extension operations can't be used in constant expressions.
.fadeIn(duration: 300.ms)
.slideY(begin: 0.2, end: 0, duration: 300.ms),
```

## 🔧 수정 방법

### 방법 1: const 제거
```dart
// Before
const MyWidget(
  children: [
    Widget1(),
    Widget2(),
  ],
)

// After
MyWidget(
  children: [
    Widget1(),
    Widget2(),
  ],
)
```

### 방법 2: Extension 메서드 수정
```dart
// Before
const MyWidget().animate(duration: 600.ms)

// After
MyWidget().animate(duration: const Duration(milliseconds: 600))
```

**주의**:
- `const` 키워드만 제거하고 로직은 변경하지 마세요
- `.ms` extension은 `const Duration(milliseconds: n)`으로 변경
- 가능한 최소한의 수정만 하세요