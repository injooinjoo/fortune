StateNotifier + State 클래스를 생성합니다.

## 입력 정보

- **Provider 이름**: $ARGUMENTS 또는 사용자에게 질문
- **Feature 이름**: Provider가 속한 Feature
- **State 필드**: 상태로 관리할 필드들

## 생성 위치

```
lib/features/{feature}/presentation/providers/{name}_provider.dart
```

## 생성 템플릿

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================
// State 클래스
// ============================================
class {Name}State {
  final bool isLoading;
  final String? error;
  final {ResultType}? result;

  const {Name}State({
    this.isLoading = false,
    this.error,
    this.result,
  });

  {Name}State copyWith({
    bool? isLoading,
    String? error,
    {ResultType}? result,
  }) {
    return {Name}State(
      isLoading: isLoading ?? this.isLoading,
      error: error,  // null 허용 (에러 클리어)
      result: result ?? this.result,
    );
  }

  // 편의 getter
  bool get hasData => result != null;
  bool get hasError => error != null;
}

// ============================================
// StateNotifier 클래스
// ============================================
class {Name}Notifier extends StateNotifier<{Name}State> {
  final {Service} _service;
  final Ref _ref;

  {Name}Notifier(this._ref, this._service) : super(const {Name}State());

  Future<void> load{Name}() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _service.fetch{Name}();
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void update({ResultType} result) {
    state = state.copyWith(result: result);
  }

  void reset() {
    state = const {Name}State();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ============================================
// Provider 정의
// ============================================
final {name}ServiceProvider = Provider<{Service}>((ref) {
  return {Service}();
});

final {name}NotifierProvider =
    StateNotifierProvider<{Name}Notifier, {Name}State>((ref) {
  final service = ref.watch({name}ServiceProvider);
  return {Name}Notifier(ref, service);
});

// 파생 Provider (선택적)
final {name}ResultProvider = Provider<{ResultType}?>((ref) {
  return ref.watch({name}NotifierProvider).result;
});

final is{Name}LoadingProvider = Provider<bool>((ref) {
  return ref.watch({name}NotifierProvider).isLoading;
});
```

## 금지 패턴

```dart
// ❌ @riverpod 어노테이션 사용 금지
@riverpod
class {Name}Notifier extends _${Name}Notifier { }
```

## 관련 Agent

- riverpod-specialist

