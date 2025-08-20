import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/utils/logger.dart';
import '../models/ab_test_experiment.dart';
import '../models/ab_test_variant.dart';
import 'analytics_service.dart';
import 'remote_config_service.dart';

/// A/B 테스트 관리 서비스
class ABTestService {
  static final ABTestService _instance = ABTestService._internal();
  factory ABTestService() => _instance;
  ABTestService._internal();

  static ABTestService get instance => _instance;

  final RemoteConfigService _remoteConfig = RemoteConfigService();
  final AnalyticsService _analytics = AnalyticsService.instance;
  final Map<String, ABTestVariant> _activeVariants = {};
  final Map<String, ABTestExperiment> _experiments = {};
  
  late SharedPreferences _prefs;
  bool _isInitialized = false;
  String? _userId;

  /// 서비스 초기화
  Future<void> initialize({
    required SharedPreferences prefs,
    String? userId,
  }) async {
    if (_isInitialized) return;

    _prefs = prefs;
    _userId = userId;
    
    // 저장된 변형 정보 로드
    await _loadSavedVariants();
    
    // 실험 설정 로드
    await _loadExperiments();
    
    _isInitialized = true;
    Logger.info('ABTestService initialized with userId: $_userId');
  }

  /// 사용자 ID 설정
  void setUserId(String userId) {
    _userId = userId;
    Logger.info('ABTestService userId updated: $userId');
  }

  /// 저장된 변형 정보 로드
  Future<void> _loadSavedVariants() async {
    final keys = _prefs.getKeys().where((key) => key.startsWith('ab_variant_'));
    
    for (final key in keys) {
      final variantData = _prefs.getString(key);
      if (variantData != null) {
        try {
          final experimentId = key.replaceFirst('ab_variant_', '');
          // Remote Config에서 최신 변형 정보 가져오기
          final variant = await _getVariantFromRemoteConfig(experimentId);
          if (variant != null) {
            _activeVariants[experimentId] = variant;
          }
        } catch (e) {
          Logger.error('Failed to load saved variant for $key', e);
        }
      }
    }
  }

  /// Remote Config에서 변형 정보 가져오기
  Future<ABTestVariant?> _getVariantFromRemoteConfig(String experimentId) async {
    try {
      final variantId = _remoteConfig.getValue('ab_${experimentId}_variant')?.asString();
      if (variantId == null || variantId.isEmpty) return null;

      // 변형 파라미터 가져오기
      final parameters = <String, dynamic>{};
      final configKeys = [
        'ab_${experimentId}_${variantId}_params',
        'ab_${experimentId}_params',
      ];

      for (final key in configKeys) {
        final value = _remoteConfig.getValue(key);
        if (value != null) {
          try {
            final params = value.asString();
            if (params.isNotEmpty) {
              // JSON 파싱 시도
              // 실제로는 json.decode를 사용해야 하지만 여기서는 간단히 처리
              parameters[key] = params;
            }
          } catch (_) {
            // 파싱 실패 시 무시
          }
        }
      }

      return ABTestVariant(
        id: variantId,
        name: variantId,
        parameters: parameters,
      );
    } catch (e) {
      Logger.error('Failed to get variant from RemoteConfig for $experimentId', e);
      return null;
    }
  }

  /// 실험 설정 로드
  Future<void> _loadExperiments() async {
    // 여기에 미리 정의된 실험들을 로드
    // 실제로는 서버나 Remote Config에서 가져올 수 있음
    _registerPredefinedExperiments();
  }

  /// 미리 정의된 실험들 등록
  void _registerPredefinedExperiments() {
    // 결제 화면 A/B 테스트
    registerExperiment(
      ABTestExperiment(
        id: 'payment_ui_test',
        name: '결제 화면 UI 테스트',
        description: '결제 화면 레이아웃과 버튼 스타일 테스트',
        variants: [
          const ControlVariant(parameters: {
            'layout': 'split',
            'button_style': 'rounded',
            'show_discount_badge': true,
          }),
          const ABTestVariant(
            id: 'variant_a',
            name: 'Compact Layout',
            parameters: {
              'layout': 'compact',
              'button_style': 'rounded',
              'show_discount_badge': true,
            },
            weight: 0.5,
          ),
          const ABTestVariant(
            id: 'variant_b',
            name: 'Full Width Buttons',
            parameters: {
              'layout': 'split',
              'button_style': 'full_width',
              'show_discount_badge': false,
            },
            weight: 0.5,
          ),
        ],
        startDate: DateTime.now().subtract(const Duration(days: 7)),
        trafficAllocation: 1.0,
      ),
    );

    // 온보딩 플로우 A/B 테스트
    registerExperiment(
      ABTestExperiment(
        id: 'onboarding_flow_test',
        name: '온보딩 플로우 테스트',
        description: '온보딩 단계와 스킵 가능 여부 테스트',
        variants: [
          const ControlVariant(parameters: {
            'flow_type': 'standard',
            'skippable': false,
            'steps': 5,
          }),
          const ABTestVariant(
            id: 'variant_a',
            name: 'Simplified Flow',
            parameters: {
              'flow_type': 'simplified',
              'skippable': true,
              'steps': 3,
            },
            weight: 0.3,
          ),
          const ABTestVariant(
            id: 'variant_b',
            name: 'Progressive Disclosure',
            parameters: {
              'flow_type': 'progressive',
              'skippable': false,
              'steps': 4,
            },
            weight: 0.3,
          ),
        ],
        startDate: DateTime.now().subtract(const Duration(days: 3)),
        trafficAllocation: 0.8,
      ),
    );

    // 운세 카드 UI A/B 테스트
    registerExperiment(
      ABTestExperiment(
        id: 'fortune_card_ui_test',
        name: '운세 카드 UI 테스트',
        description: '운세 카드 스타일과 애니메이션 테스트',
        variants: [
          const ControlVariant(parameters: {
            'card_style': 'modern',
            'animation_enabled': true,
            'card_layout': 'card',
          }),
          const ABTestVariant(
            id: 'variant_a',
            name: 'Classic Style',
            parameters: {
              'card_style': 'classic',
              'animation_enabled': false,
              'card_layout': 'list',
            },
            weight: 0.33,
          ),
          const ABTestVariant(
            id: 'variant_b',
            name: 'Premium Style',
            parameters: {
              'card_style': 'premium',
              'animation_enabled': true,
              'card_layout': 'carousel',
            },
            weight: 0.33,
          ),
        ],
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        trafficAllocation: 1.0,
      ),
    );

    // 토큰 가격 A/B 테스트
    registerExperiment(
      ABTestExperiment(
        id: 'token_pricing_test',
        name: '토큰 가격 테스트',
        description: '토큰 패키지 가격과 보너스 비율 테스트',
        variants: [
          const ControlVariant(parameters: {
            'base_price': 1000,
            'bonus_rate': 1.0,
            'popular_package': 'tokens100',
          }),
          const ABTestVariant(
            id: 'variant_a',
            name: 'Lower Price',
            parameters: {
              'base_price': 900,
              'bonus_rate': 1.1,
              'popular_package': 'tokens50',
            },
            weight: 0.25,
          ),
          const ABTestVariant(
            id: 'variant_b',
            name: 'Higher Bonus',
            parameters: {
              'base_price': 1000,
              'bonus_rate': 1.3,
              'popular_package': 'tokens200',
            },
            weight: 0.25,
          ),
        ],
        startDate: DateTime.now(),
        trafficAllocation: 0.5,
      ),
    );
  }

  /// 실험 등록
  void registerExperiment(ABTestExperiment experiment) {
    _experiments[experiment.id] = experiment;
    Logger.info('Registered experiment: ${experiment.id}');
  }

  /// 사용자를 실험에 할당하고 변형 가져오기
  Future<ABTestVariant> getVariant(String experimentId) async {
    // 이미 할당된 변형이 있으면 반환
    if (_activeVariants.containsKey(experimentId)) {
      final variant = _activeVariants[experimentId]!;
      await _trackVariantExposure(experimentId, variant);
      return variant;
    }

    // 실험 가져오기
    final experiment = _experiments[experimentId];
    if (experiment == null || !experiment.isRunning) {
      Logger.warning('Experiment not found or not running: $experimentId');
      return const ControlVariant(parameters: {});
    }

    // 트래픽 할당 확인
    final random = Random(_userId?.hashCode ?? 0);
    if (random.nextDouble() > experiment.trafficAllocation) {
      Logger.info('User not in traffic allocation for experiment: $experimentId');
      return experiment.controlVariant ?? const ControlVariant(parameters: {});
    }

    // Remote Config에서 변형 확인
    var variant = await _getVariantFromRemoteConfig(experimentId);
    
    // Remote Config에 없으면 랜덤 할당
    if (variant == null) {
      variant = _assignRandomVariant(experiment);
    }

    // 변형 저장
    _activeVariants[experimentId] = variant;
    await _prefs.setString('ab_variant_$experimentId', variant.id);

    // Analytics 이벤트 전송
    await _trackVariantExposure(experimentId, variant);

    return variant;
  }

  /// 랜덤으로 변형 할당
  ABTestVariant _assignRandomVariant(ABTestExperiment experiment) {
    final random = Random(_userId?.hashCode ?? 0);
    final randomValue = random.nextDouble();
    
    double cumulativeWeight = 0;
    for (final variant in experiment.variants) {
      cumulativeWeight += variant.weight / experiment.variants.length;
      if (randomValue <= cumulativeWeight) {
        return variant;
      }
    }
    
    return experiment.variants.last;
  }

  /// 변형 노출 추적
  Future<void> _trackVariantExposure(String experimentId, ABTestVariant variant) async {
    await _analytics.logEvent(
      'ab_test_exposure',
      parameters: {
        'experiment_id': experimentId,
        'variant_id': variant.id,
        'variant_name': variant.name,
        if (_userId != null) 'user_id': _userId!,
      },
    );
  }

  /// 전환 이벤트 추적
  Future<void> trackConversion({
    required String experimentId,
    String? conversionType,
    Map<String, dynamic>? additionalData,
  }) async {
    final variant = _activeVariants[experimentId];
    if (variant == null) {
      Logger.warning('No active variant for experiment: $experimentId');
      return;
    }

    await _analytics.logEvent(
      'ab_test_conversion',
      parameters: {
        'experiment_id': experimentId,
        'variant_id': variant.id,
        'variant_name': variant.name,
        if (conversionType != null) 'conversion_type': conversionType,
        if (_userId != null) 'user_id': _userId!,
        ...?additionalData,
      },
    );

    Logger.info('Tracked conversion for experiment: $experimentId, variant: ${variant.id}');
  }

  /// 특정 실험의 변형 파라미터 가져오기
  T? getParameter<T>(String experimentId, String parameterKey) {
    final variant = _activeVariants[experimentId];
    return variant?.getParameter<T>(parameterKey);
  }

  /// 모든 활성 실험 가져오기
  Map<String, ABTestExperiment> getActiveExperiments() {
    return Map.fromEntries(
      _experiments.entries.where((entry) => entry.value.isRunning),
    );
  }

  /// 특정 실험 가져오기
  ABTestExperiment? getExperiment(String experimentId) {
    return _experiments[experimentId];
  }

  /// 사용자의 모든 활성 변형 가져오기
  Map<String, ABTestVariant> getActiveVariants() {
    return Map.from(_activeVariants);
  }

  /// 디버그 모드에서 특정 변형 강제 설정
  Future<void> forceVariant(String experimentId, String variantId) async {
    if (!kDebugMode) {
      Logger.warning('Force variant is only available in debug mode');
      return;
    }

    final experiment = _experiments[experimentId];
    if (experiment == null) {
      Logger.error('Experiment not found: $experimentId');
      return;
    }

    final variant = experiment.getVariant(variantId);
    if (variant == null) {
      Logger.error('Variant not found: $variantId in experiment: $experimentId');
      return;
    }

    _activeVariants[experimentId] = variant;
    await _prefs.setString('ab_variant_$experimentId', variant.id);
    
    Logger.info('Forced variant: $variantId for experiment: $experimentId');
  }

  /// 모든 실험 데이터 초기화
  Future<void> reset() async {
    _activeVariants.clear();
    
    // SharedPreferences에서 모든 A/B 테스트 데이터 삭제
    final keys = _prefs.getKeys().where((key) => key.startsWith('ab_'));
    for (final key in keys) {
      await _prefs.remove(key);
    }
    
    Logger.info('ABTestService reset completed');
  }
}

/// A/B 테스트 서비스 Provider
final abTestServiceProvider = Provider<ABTestService>((ref) {
  return ABTestService.instance;
});

/// A/B 테스트 초기화 Provider
final abTestInitializerProvider = FutureProvider<void>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final abTestService = ref.watch(abTestServiceProvider);
  
  // TODO: 실제 사용자 ID로 교체
  await abTestService.initialize(
    prefs: prefs,
    userId: 'user_id_placeholder',
  );
});

/// 특정 실험의 변형 Provider
final experimentVariantProvider = FutureProvider.family<ABTestVariant, String>(
  (ref, experimentId) async {
    final abTestService = ref.watch(abTestServiceProvider);
    await ref.watch(abTestInitializerProvider.future);
    return abTestService.getVariant(experimentId);
  },
);