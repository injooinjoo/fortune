# Flutter Final 필드 초기화 에러 수정 - 배치 3 (온보딩과 위젯)

## 🎯 수정 목표
온보딩 스텝과 기타 위젯의 Final 필드 초기화 에러를 수정합니다.

## 📁 수정 대상 파일 (11개 파일, 26개 에러)

### 1. `lib/screens/onboarding/steps/phone_step.dart` (5 에러)
```dart
라인 10: final String? initialPhone;
라인 11: final String initialCountryCode;
라인 12: final Function(String?, String) onPhoneChanged;
라인 13: final VoidCallback onNext;
라인 14: final VoidCallback? onBack;
```

### 2. `lib/screens/onboarding/steps/name_step.dart` (4 에러)
```dart
라인 10: final String? initialName;
라인 11: final Function(String) onNameChanged;
라인 12: final VoidCallback onNext;
라인 13: final VoidCallback? onShowSocialLogin;
```

### 3. `lib/screens/onboarding/steps/birth_info_step.dart` (3 에러)
```dart
라인 14: final Function(BirthInfo) onBirthInfoChanged;
라인 15: final VoidCallback onNext;
라인 16: final VoidCallback onBack;
```

### 4. `lib/screens/onboarding/steps/gender_step.dart` (3 에러)
```dart
라인 12: final Function(String) onGenderChanged;
라인 13: final VoidCallback onNext;
라인 14: final VoidCallback onBack;
```

### 5. `lib/screens/onboarding/steps/location_step.dart` (3 에러)
```dart
라인 10: final Function(LatLng?) onLocationChanged;
라인 11: final VoidCallback onComplete;
라인 12: final VoidCallback onBack;
```

### 6. `lib/presentation/widgets/five_elements_explanation_bottom_sheet.dart` (3 에러)
```dart
라인 12: final String element;
라인 13: final int elementCount;
라인 14: final int totalCount;
```

### 7. `lib/presentation/widgets/saju_element_explanation_bottom_sheet.dart` (4 에러)
```dart
라인 13: final String element;
라인 14: final String elementHanja;
라인 15: final bool isCheongan;
라인 16: final String elementType;
```

### 8. `lib/presentation/widgets/time_based_fortune_bottom_sheet.dart` (1 에러)
```dart
라인 30: final VoidCallback? onDismiss;
```

### 9. `lib/presentation/widgets/time_specific_fortune_card.dart` (2 에러)
```dart
라인 143: final List<FortuneModel> fortunes;
라인 144: final String? title;
```

### 10. `lib/presentation/widgets/ad_widgets.dart` (1 에러)
```dart
라인 80: final double? width;
```

## 🔧 수정 방법

### 온보딩 스텝의 경우:
```dart
// Before
class NameStep extends StatefulWidget {
  final String? initialName;
  final Function(String) onNameChanged;
  
  const NameStep({Key? key}) : super(key: key);
}

// After
class NameStep extends StatefulWidget {
  final String? initialName;
  final Function(String) onNameChanged;
  
  const NameStep({
    Key? key,
    this.initialName,
    required this.onNameChanged,
  }) : super(key: key);
}
```

**주의사항**:
- 온보딩 스텝은 콜백 함수가 많으므로 required로 처리
- BottomSheet 위젯들은 데이터 전달이 필수인 경우가 많음