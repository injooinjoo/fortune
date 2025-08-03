# Flutter Final 필드 초기화 에러 수정 - 배치 2 (프로바이더와 서비스)

## 🎯 수정 목표
프로바이더와 서비스 관련 Final 필드 초기화 에러를 수정합니다.

## 📁 수정 대상 파일 (6개 파일, 26개 에러)

### 1. `lib/presentation/widgets/social_accounts_section.dart` (8 에러)
```dart
라인 12: final List<String>? linkedProviders;
라인 13: final String? primaryProvider;
라인 14: final Function(List<String>) onProvidersChanged;
라인 15: final SocialAuthService socialAuthService;
라인 347: final String name;
라인 348: final IconType iconType;
라인 349: final IconData? iconData;
라인 350: final Color color;
```

### 2. `lib/presentation/providers/todo_provider.dart` (8 에러)
```dart
라인 48: final TodoStatus? status;
라인 49: final TodoPriority? priority;
라인 50: final String? searchQuery;
라인 51: final List<String>? tags;
라인 84: final bool isLoading;
라인 85: final Failure? failure;
라인 86: final bool hasMore;
라인 87: final int currentOffset;
```

### 3. `lib/services/notification/fcm_service.dart` (4 에러)
```dart
라인 31: final bool dailyFortune;
라인 32: final bool tokenAlert;
라인 33: final bool promotion;
라인 34: final String? dailyFortuneTime;
```

### 4. `lib/presentation/providers/token_provider.dart` (3 에러)
```dart
라인 22: final Map<String, int> consumptionRates;
라인 23: final bool isConsumingToken;
라인 24: final UserProfile? userProfile;
```

### 5. `lib/presentation/widgets/saju_chart_widget.dart` (1 에러)
```dart
라인 14: final Map<String, dynamic>? userProfile;
```

### 6. `lib/shared/components/token_insufficient_modal.dart` (2 에러)
```dart
라인 16: final int requiredTokens;
라인 17: final String fortuneType;
```

## 🔧 수정 방법

### Provider/State 클래스의 경우:
```dart
// Before
class TodoFilterState {
  final TodoStatus? status;
  final TodoPriority? priority;
  
  TodoFilterState();
}

// After
class TodoFilterState {
  final TodoStatus? status;
  final TodoPriority? priority;
  
  TodoFilterState({
    this.status,
    this.priority,
  });
}
```

### Service 클래스의 경우:
```dart
// Before
class NotificationSettings {
  final bool dailyFortune;
  
  NotificationSettings();
}

// After
class NotificationSettings {
  final bool dailyFortune;
  
  NotificationSettings({
    required this.dailyFortune,
  });
}
```

**주의사항**:
- Provider state는 보통 기본값이나 copyWith 메서드가 있을 수 있음
- Service 클래스는 초기화 시 설정값이 필요할 수 있음