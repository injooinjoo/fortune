import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/services/fortune_batch_service.dart';
import '../../../../presentation/providers/providers.dart';

/// 배치 운세 상태
class BatchFortuneState {
  final bool isLoading;
  final List<BatchFortuneResult>? results;
  final String? error;
  final BatchPackageType? currentPackage;
  final double? tokenSavings;

  BatchFortuneState({
    this.isLoading = false,
    this.results,
    this.error,
    this.currentPackage,
    this.tokenSavings});

  BatchFortuneState copyWith({
    bool? isLoading,
    List<BatchFortuneResult>? results,
    String? error,
    BatchPackageType? currentPackage,
    double? tokenSavings}) {
    return BatchFortuneState(
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      error: error,
      currentPackage: currentPackage ?? this.currentPackage,
      tokenSavings: tokenSavings ?? this.tokenSavings);
}

  // 캐시된 운세 개수
  int get cachedCount {
    if (results == null) return 0;
    return results!.where((r) => r.fromCache).length;
}

  // 새로 생성된 운세 개수
  int get generatedCount {
    if (results == null) return 0;
    return results!.where((r) => !r.fromCache).length;
}
}

/// 배치 운세 Provider
final batchFortuneProvider = StateNotifierProvider<BatchFortuneNotifier, BatchFortuneState>((ref) {
  final service = ref.watch(fortuneBatchServiceProvider);
  final authService = ref.watch(authServiceProvider);
  return BatchFortuneNotifier(service, authService, ref);
});

class BatchFortuneNotifier extends StateNotifier<BatchFortuneState> {
  final FortuneBatchService _service;
  final dynamic _authService;
  final Ref _ref;

  BatchFortuneNotifier(this._service, this._authService, this._ref) : super(BatchFortuneState());

  /// 온보딩 완료 시 배치 운세 생성
  Future<void> generateOnboardingFortunes() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다');
}

      // 사용자 프로필 가져오기
      final profileAsync = await _ref.read(userProfileProvider.future);
      final userProfile = {
        'name': profileAsync?.name ?? '',
        'birth_date': profileAsync?.birthDate?.toIso8601String() ?? '',
        'gender': profileAsync?.gender ?? '',
        'mbti': profileAsync?.mbtiType ?? ''};

      final results = await _service.generateOnboardingFortunes(
        userId: user.id,
        userProfile: userProfile);

      final savings = _service.calculateTokenSavings(BatchPackageType.onboarding);

      state = state.copyWith(
        isLoading: false,
        results: results,
        currentPackage: BatchPackageType.onboarding,
        tokenSavings: savings);

      // 토큰 잔액 업데이트
      _ref.read(tokenProvider.notifier).refreshBalance();
} catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString());
    }
  }

  /// 일일 운세 갱신
  Future<void> refreshDailyFortunes() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다');
}

      final profileAsync = await _ref.read(userProfileProvider.future);
      final userProfile = profileAsync != null ? {
        'name': profileAsync.name ?? '',
        'birth_date': profileAsync.birthDate?.toIso8601String() ?? '',
        'gender': profileAsync.gender ?? '',
        'mbti': profileAsync.mbtiType ?? ''} : null;

      final results = await _service.refreshDailyFortunes(
        userId: user.id,
        userProfile: userProfile);

      final savings = _service.calculateTokenSavings(BatchPackageType.dailyRefresh);

      state = state.copyWith(
        isLoading: false,
        results: results,
        currentPackage: BatchPackageType.dailyRefresh,
        tokenSavings: savings);

      // 토큰 잔액 업데이트
      _ref.read(tokenProvider.notifier).refreshBalance();
} catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString());
    }
  }

  /// 패키지별 운세 생성
  Future<void> generatePackageFortunes(BatchPackageType packageType) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다');
}

      final profileAsync = await _ref.read(userProfileProvider.future);
      final userProfile = profileAsync != null ? {
        'name': profileAsync.name ?? '',
        'birth_date': profileAsync.birthDate?.toIso8601String() ?? '',
        'gender': profileAsync.gender ?? '',
        'mbti': profileAsync.mbtiType ?? ''} : null;

      final results = await _service.generateBatchFortunesByPackage(
        userId: user.id,
        packageType: packageType,
        userProfile: userProfile);

      final savings = _service.calculateTokenSavings(packageType);

      state = state.copyWith(
        isLoading: false,
        results: results,
        currentPackage: packageType,
        tokenSavings: savings);

      // 토큰 잔액 업데이트
      _ref.read(tokenProvider.notifier).refreshBalance();
} catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString());
    }
  }

  /// 커스텀 운세 타입으로 배치 생성
  Future<void> generateCustomBatchFortunes(List<String> fortuneTypes) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다');
}

      final profileAsync = await _ref.read(userProfileProvider.future);
      final userProfile = profileAsync != null ? {
        'name': profileAsync.name ?? '',
        'birth_date': profileAsync.birthDate?.toIso8601String() ?? '',
        'gender': profileAsync.gender ?? '',
        'mbti': profileAsync.mbtiType ?? ''} : null;

      final results = await _service.generateBatchFortunesByTypes(
        userId: user.id,
        fortuneTypes: fortuneTypes,
        userProfile: userProfile);

      state = state.copyWith(
        isLoading: false,
        results: results,
        currentPackage: null);

      // 토큰 잔액 업데이트
      _ref.read(tokenProvider.notifier).refreshBalance();
} catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString());
    }
  }

  /// 특정 운세 타입 결과 가져오기
  BatchFortuneResult? getFortuneByType(String fortuneType) {
    return state.results?.firstWhere(
      (result) => result.type == fortuneType,
      orElse: () => throw Exception('운세를 찾을 수 없습니다'));
  }

  /// 캐시된 운세 개수
  int get cachedCount {
    return state.results?.where((r) => r.fromCache).length ?? 0;
}

  /// 새로 생성된 운세 개수
  int get generatedCount {
    return state.results?.where((r) => !r.fromCache).length ?? 0;
}

  /// 전체 운세 개수
  int get totalCount {
    return state.results?.length ?? 0;
}

  void clearResults() {
    state = BatchFortuneState();
}
}

/// 시스템 운세 Provider (MBTI, 혈액형 등,
final systemFortuneProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, fortuneType) async {
  final service = ref.watch(fortuneBatchServiceProvider);
  
  return await service.generateSystemFortunes(
    fortuneType: fortuneType,
    period: 'monthly',
    forceRegenerate: false
  );
});

/// 특정 MBTI 타입의 운세 가져오기
final mbtiFortuneProvider = Provider.family<Map<String, dynamic>?, String>((ref, mbtiType) {
  final systemFortune = ref.watch(systemFortuneProvider('mbti'));
  
  return systemFortune.when(
    data: (data) => data['data'],
    loading: () => null,
    error: (_, __) => null
  );
});

/// 특정 혈액형의 운세 가져오기
final bloodTypeFortuneProvider = Provider.family<Map<String, dynamic>?, String>((ref, bloodType) {
  final systemFortune = ref.watch(systemFortuneProvider('blood_type'));
  
  return systemFortune.when(
    data: (data) => data['data'],
    loading: () => null,
    error: (_, __) => null
  );
});

/// 특정 별자리의 운세 가져오기
final zodiacFortuneProvider = Provider.family<Map<String, dynamic>?, String>((ref, zodiacSign) {
  final systemFortune = ref.watch(systemFortuneProvider('zodiac'));
  
  return systemFortune.when(
    data: (data) => data['data'],
    loading: () => null,
    error: (_, __) => null
  );
});

/// 특정 띠의 운세 가져오기
final zodiacAnimalFortuneProvider = Provider.family<Map<String, dynamic>?, String>((ref, zodiacAnimal) {
  final systemFortune = ref.watch(systemFortuneProvider('zodiac_animal'));
  
  return systemFortune.when(
    data: (data) => data['data'],
    loading: () => null,
    error: (_, __) => null
  );
});