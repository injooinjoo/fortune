# 상태관리 가이드 (Riverpod StateNotifier)

> 최종 업데이트: 2025.01.03

## 개요

Fortune App은 **Riverpod StateNotifier 패턴**을 사용합니다.

**중요**: `riverpod_generator` (@riverpod 어노테이션) 사용 금지!

---

## 표준 StateNotifier 패턴

### 1. State 클래스 정의

```dart
// lib/features/{feature}/presentation/providers/{feature}_provider.dart

class FortuneState {
  final bool isLoading;
  final String? error;
  final FortuneResult? result;
  final List<FortuneHistory> history;

  const FortuneState({
    this.isLoading = false,
    this.error,
    this.result,
    this.history = const [],
  });

  FortuneState copyWith({
    bool? isLoading,
    String? error,
    FortuneResult? result,
    List<FortuneHistory>? history,
  }) {
    return FortuneState(
      isLoading: isLoading ?? this.isLoading,
      error: error,  // null 허용 (에러 클리어용)
      result: result ?? this.result,
      history: history ?? this.history,
    );
  }
}
```

### 2. StateNotifier 클래스 정의

```dart
class FortuneNotifier extends StateNotifier<FortuneState> {
  final Ref _ref;
  final FortuneService _fortuneService;

  FortuneNotifier(this._ref, this._fortuneService)
      : super(const FortuneState());

  // 로드 메서드
  Future<void> loadFortune(FortuneConditions conditions) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _fortuneService.getFortune(conditions);
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 업데이트 메서드
  void updateResult(FortuneResult result) {
    state = state.copyWith(result: result);
  }

  // 리셋 메서드
  void reset() {
    state = const FortuneState();
  }

  // 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }
}
```

### 3. Provider 정의

```dart
final fortuneServiceProvider = Provider<FortuneService>((ref) {
  return FortuneService();
});

final fortuneNotifierProvider =
    StateNotifierProvider<FortuneNotifier, FortuneState>((ref) {
  final fortuneService = ref.watch(fortuneServiceProvider);
  return FortuneNotifier(ref, fortuneService);
});

// 파생 Provider (선택적)
final fortuneResultProvider = Provider<FortuneResult?>((ref) {
  return ref.watch(fortuneNotifierProvider).result;
});

final isFortuneLoadingProvider = Provider<bool>((ref) {
  return ref.watch(fortuneNotifierProvider).isLoading;
});
```

---

## 위젯에서 사용법

### ConsumerWidget 사용

```dart
class FortunePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fortuneNotifierProvider);

    if (state.isLoading) {
      return TossFortuneLoadingScreen();
    }

    if (state.error != null) {
      return ErrorWidget(state.error!);
    }

    if (state.result != null) {
      return FortuneResultWidget(result: state.result!);
    }

    return FortuneInputForm(
      onSubmit: (conditions) {
        ref.read(fortuneNotifierProvider.notifier).loadFortune(conditions);
      },
    );
  }
}
```

### ConsumerStatefulWidget 사용

```dart
class FortunePage extends ConsumerStatefulWidget {
  @override
  ConsumerState<FortunePage> createState() => _FortunePageState();
}

class _FortunePageState extends ConsumerState<FortunePage> {
  @override
  void initState() {
    super.initState();
    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fortuneNotifierProvider.notifier).loadFortune(conditions);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fortuneNotifierProvider);
    // ... UI 구현
  }
}
```

---

## 참조 구현 예시

### 표준 패턴: TokenProvider

**파일**: `lib/presentation/providers/token_provider.dart` (561줄)

```dart
// State 클래스
class TokenState {
  final TokenBalance? balance;
  final bool isLoading;
  final String? error;
  final TokenUsageHistory? usageHistory;

  const TokenState({
    this.balance,
    this.isLoading = false,
    this.error,
    this.usageHistory,
  });

  TokenState copyWith({...});

  // 편의 getter
  bool get hasUnlimitedAccess => balance?.hasUnlimitedAccess ?? false;
  int get remainingTokens => balance?.remainingTokens ?? 0;
}

// StateNotifier 클래스
class TokenNotifier extends StateNotifier<TokenState> {
  final TokenApiService _apiService;
  final Ref ref;

  TokenNotifier(this._apiService, this.ref) : super(const TokenState());

  Future<void> loadBalance() async {...}
  Future<void> consumeTokens(int amount, String fortuneType) async {...}
  Future<void> addTokens(int amount, String source) async {...}
  void reset() {...}
  void clearError() {...}
}

// Provider 선언
final tokenProvider = StateNotifierProvider<TokenNotifier, TokenState>((ref) {
  final apiService = ref.watch(tokenApiServiceProvider);
  return TokenNotifier(apiService, ref);
});
```

---

## 금지 패턴

### @riverpod 어노테이션 사용 금지

```dart
// WRONG - riverpod_generator 사용 금지
@riverpod
class FortuneNotifier extends _$FortuneNotifier {
  @override
  FortuneState build() => const FortuneState();

  Future<void> loadFortune() async {...}
}

// CORRECT - 수동 StateNotifier 패턴 사용
class FortuneNotifier extends StateNotifier<FortuneState> {
  FortuneNotifier() : super(const FortuneState());

  Future<void> loadFortune() async {...}
}
```

### Provider 외부에서 State 직접 수정 금지

```dart
// WRONG
ref.read(fortuneNotifierProvider).result = newResult;

// CORRECT
ref.read(fortuneNotifierProvider.notifier).updateResult(newResult);
```

---

## 비동기 처리 패턴

### AsyncValue 대신 State 플래그 사용

```dart
// 권장 패턴
class FortuneState {
  final bool isLoading;
  final String? error;
  final FortuneResult? data;

  bool get hasData => data != null;
  bool get hasError => error != null;
}

// 위젯에서 사용
if (state.isLoading) return LoadingWidget();
if (state.hasError) return ErrorWidget(state.error!);
if (state.hasData) return DataWidget(state.data!);
return EmptyWidget();
```

### 에러 처리 패턴

```dart
Future<void> loadData() async {
  state = state.copyWith(isLoading: true, error: null);

  try {
    final result = await _service.fetchData();
    state = state.copyWith(isLoading: false, data: result);
  } on NetworkException catch (e) {
    state = state.copyWith(isLoading: false, error: '네트워크 오류: ${e.message}');
  } on ApiException catch (e) {
    state = state.copyWith(isLoading: false, error: 'API 오류: ${e.message}');
  } catch (e) {
    state = state.copyWith(isLoading: false, error: '알 수 없는 오류: $e');
  }
}
```

---

## Provider 구성 패턴

### 서비스 의존성 주입

```dart
// 1. 서비스 Provider
final fortuneServiceProvider = Provider<FortuneService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return FortuneService(supabase);
});

// 2. Notifier Provider (서비스 주입)
final fortuneNotifierProvider =
    StateNotifierProvider<FortuneNotifier, FortuneState>((ref) {
  final service = ref.watch(fortuneServiceProvider);
  return FortuneNotifier(ref, service);
});

// 3. 파생 Provider
final fortuneResultProvider = Provider<FortuneResult?>((ref) {
  return ref.watch(fortuneNotifierProvider).result;
});
```

### Family Provider (파라미터화)

```dart
final fortuneByTypeProvider =
    StateNotifierProvider.family<FortuneNotifier, FortuneState, String>(
  (ref, fortuneType) {
    final service = ref.watch(fortuneServiceProvider);
    return FortuneNotifier(ref, service, fortuneType);
  },
);

// 사용
ref.watch(fortuneByTypeProvider('daily'));
ref.watch(fortuneByTypeProvider('tarot'));
```

---

## 검증 체크리스트

### 새 Provider 작성 시
- [ ] State 클래스에 copyWith 메서드 구현
- [ ] StateNotifier에 load, update, reset, clearError 메서드
- [ ] @riverpod 어노테이션 미사용
- [ ] 서비스는 Provider로 주입
- [ ] 에러 상태 처리 구현

---

## 관련 문서

- [02-architecture.md](02-architecture.md) - 전체 아키텍처
- [08-agents-skills.md](08-agents-skills.md) - `/sc:state-notifier` 커맨드
