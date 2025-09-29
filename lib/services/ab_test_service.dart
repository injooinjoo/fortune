import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/utils/logger.dart';
import '../core/services/resilient_service.dart';
import '../models/ab_test_experiment.dart';
import '../models/ab_test_variant.dart' show ABTestVariant, ControlVariant;
import '../models/ab_test_result.dart' show ABTestResult, ConversionEvent, VariantResult;
import 'analytics_service.dart';
import 'remote_config_service.dart';

/// 강화된 A/B 테스트 관리 서비스
///
/// KAN-75: A/B 테스트 연결 안정성 문제 해결
/// - ResilientService 패턴 적용
/// - Remote Config 연결 실패 대응
/// - 실험 데이터 로딩 오류 처리
/// - 오프라인 모드 지원 (캐시된 변형 사용)
class ABTestService extends ResilientService {
  static final ABTestService _instance = ABTestService._internal();
  factory ABTestService() => _instance;
  ABTestService._internal();

  static ABTestService get instance => _instance;

  @override
  String get serviceName => 'ABTestService';

  final RemoteConfigService _remoteConfig = RemoteConfigService();
  final AnalyticsService _analytics = AnalyticsService.instance;
  final Map<String, ABTestVariant> _activeVariants = {};
  final Map<String, ABTestExperiment> _experiments = {};
  final Map<String, ABTestResult> _experimentResults = {};
  final Map<String, List<ConversionEvent>> _conversionEvents = {};
  
  late SharedPreferences _prefs;
  bool _isInitialized = false;
  String? _userId;
  
  // 실험 결과 추적을 위한 변수들
  final Map<String, int> _impressions = {};
  final Map<String, int> _conversions = {};

  /// 강화된 서비스 초기화 (ResilientService 패턴)
  Future<void> initialize({
    required SharedPreferences prefs,
    String? userId,
  }) async {
    if (_isInitialized) return;

    await safeExecute(
      () async {
        _prefs = prefs;
        _userId = userId;

        // 저장된 변형 정보 로드
        await _loadSavedVariants();

        // 실험 설정 로드
        await _loadExperiments();

        _isInitialized = true;
        Logger.info('ABTestService initialized with userId: $_userId');
      },
      'A/B 테스트 서비스 초기화',
      'A/B 테스트 초기화 실패, 기본 설정 사용'
    );
  }

  /// 사용자 ID 설정
  void setUserId(String userId) {
    _userId = userId;
    Logger.info('ABTestService userId updated: $userId');
  }

  /// 강화된 저장된 변형 정보 로드 (ResilientService 패턴)
  Future<void> _loadSavedVariants() async {
    await safeExecute(
      () async {
        final keys = _prefs.getKeys().where((key) => key.startsWith('ab_variant_'));

        for (final key in keys) {
          final variantData = _prefs.getString(key);
          if (variantData != null) {
            final experimentId = key.replaceFirst('ab_variant_', '');
            // Remote Config에서 최신 변형 정보 가져오기
            final variant = await _getVariantFromRemoteConfig(experimentId);
            if (variant != null) {
              _activeVariants[experimentId] = variant;
            }
          }
        }

        Logger.info('A/B 테스트 저장된 변형 ${_activeVariants.length}개 로드 완료');
      },
      '저장된 A/B 테스트 변형 로드',
      '변형 로드 실패, 빈 상태로 시작'
    );
  }

  /// 강화된 Remote Config에서 변형 정보 가져오기 (ResilientService 패턴)
  Future<ABTestVariant?> _getVariantFromRemoteConfig(String experimentId) async {
    return await safeExecuteWithNull(
      () async {
        final variantId = _remoteConfig.getValue('ab_${experimentId}_variant')?.asString();
        if (variantId == null || variantId.isEmpty) {
          throw Exception('Variant ID not found for experiment: $experimentId');
        }

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
      },
      'Remote Config 변형 데이터 로드: $experimentId',
      'Remote Config 연결 실패, 기본 변형 사용'
    );
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
    variant ??= _assignRandomVariant(experiment);

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
    // 노출 카운트 증가
    final key = '${experimentId}_${variant.id}';
    _impressions[key] = (_impressions[key] ?? 0) + 1;
    
    // 실험 결과 업데이트
    _updateExperimentResult(experimentId);
    
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

  /// 강화된 전환 이벤트 추적 (ResilientService 패턴)
  Future<void> trackConversion({
    required String experimentId,
    String? conversionType,
    Map<String, dynamic>? additionalData,
  }) async {
    await safeExecute(
      () async {
        final variant = _activeVariants[experimentId];
        if (variant == null) {
          throw Exception('활성 변형이 없는 실험: $experimentId');
        }

        // 전환 카운트 증가
        final key = '${experimentId}_${variant.id}';
        _conversions[key] = (_conversions[key] ?? 0) + 1;

        // 전환 이벤트 저장
        _conversionEvents[experimentId] ??= [];
        _conversionEvents[experimentId]!.add(
          ConversionEvent(
            variantId: variant.id,
            conversionType: conversionType ?? 'default',
            timestamp: DateTime.now(),
            value: additionalData?['value'],
            metadata: additionalData,
          ),
        );

        // 실험 결과 업데이트
        _updateExperimentResult(experimentId);

        // Analytics 이벤트 전송
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

        Logger.info('A/B 테스트 전환 추적 완료: $experimentId, 변형: ${variant.id}');
      },
      'A/B 테스트 전환 이벤트 추적: $experimentId',
      '전환 추적 실패, 로컬 데이터만 저장'
    );
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

  /// 강화된 디버그 모드에서 특정 변형 강제 설정 (ResilientService 패턴)
  Future<void> forceVariant(String experimentId, String variantId) async {
    if (!kDebugMode) {
      Logger.warning('변형 강제 설정은 디버그 모드에서만 사용 가능');
      return;
    }

    await safeExecute(
      () async {
        final experiment = _experiments[experimentId];
        if (experiment == null) {
          throw Exception('실험을 찾을 수 없음: $experimentId');
        }

        final variant = experiment.getVariant(variantId);
        if (variant == null) {
          throw Exception('변형을 찾을 수 없음: $variantId in $experimentId');
        }

        _activeVariants[experimentId] = variant;
        await _prefs.setString('ab_variant_$experimentId', variant.id);

        Logger.info('디버그 모드: 변형 강제 설정 완료 - $variantId for $experimentId');
      },
      '디버그 변형 강제 설정: $experimentId -> $variantId',
      '변형 강제 설정 실패, 기존 변형 유지'
    );
  }

  /// 강화된 모든 실험 데이터 초기화 (ResilientService 패턴)
  Future<void> reset() async {
    await safeExecute(
      () async {
        _activeVariants.clear();
        _experimentResults.clear();
        _conversionEvents.clear();
        _impressions.clear();
        _conversions.clear();

        // SharedPreferences에서 모든 A/B 테스트 데이터 삭제
        final keys = _prefs.getKeys().where((key) => key.startsWith('ab_'));
        for (final key in keys) {
          await _prefs.remove(key);
        }

        Logger.info('A/B 테스트 서비스 초기화 완료');
      },
      'A/B 테스트 데이터 초기화',
      '일부 데이터 초기화 실패, 메모리 데이터는 정리됨'
    );
  }
  
  // ============ 실험 결과 분석 기능 ============
  
  /// 실험 결과 업데이트
  void _updateExperimentResult(String experimentId) {
    final experiment = _experiments[experimentId];
    if (experiment == null) return;
    
    final variantResults = <String, VariantResult>{};
    
    for (final variant in experiment.variants) {
      final key = '${experimentId}_${variant.id}';
      final impressions = _impressions[key] ?? 0;
      final conversions = _conversions[key] ?? 0;
      final conversionRate = impressions > 0 ? conversions / impressions : 0.0;
      
      variantResults[variant.id] = VariantResult(
        variantId: variant.id,
        variantName: variant.name,
        impressions: impressions,
        conversions: conversions,
        conversionRate: conversionRate,
      );
    }
    
    // 통계적 유의성 계산
    final controlResult = variantResults['control'];
    double? pValue;
    double? confidenceLevel;
    
    if (controlResult != null && variantResults.length > 1) {
      // 간단한 Z-test 구현 (실제로는 더 정교한 통계 계산 필요)
      VariantResult? testVariant;
      try {
        testVariant = variantResults.values.firstWhere(
          (v) => v.variantId != 'control',
        );
      } catch (e) {
        testVariant = controlResult;
      }
      
      if (controlResult.impressions >= 30 && testVariant.impressions >= 30) {
        final z = _calculateZScore(
          controlResult.conversionRate,
          testVariant.conversionRate,
          controlResult.impressions,
          testVariant.impressions,
        );
        pValue = _calculatePValue(z);
        confidenceLevel = 1 - pValue;
      }
    }
    
    _experimentResults[experimentId] = ABTestResult(
      experimentId: experimentId,
      experimentName: experiment.name,
      startDate: experiment.startDate,
      variantResults: variantResults,
      winningVariantId: _determineWinner(variantResults),
      statisticalSignificance: pValue,
      confidenceLevel: confidenceLevel,
      lastUpdated: DateTime.now(),
    );
  }
  
  /// Z-score 계산
  double _calculateZScore(
    double p1, double p2, int n1, int n2,
  ) {
    final pooledP = ((p1 * n1) + (p2 * n2)) / (n1 + n2);
    final se = sqrt(pooledP * (1 - pooledP) * ((1 / n1) + (1 / n2)));
    return se > 0 ? (p2 - p1) / se : 0;
  }
  
  /// P-value 계산 (간단한 근사치)
  double _calculatePValue(double z) {
    // 표준정규분포의 CDF를 사용한 간단한 근사
    final absZ = z.abs();
    if (absZ > 3.5) return 0.0005;
    if (absZ > 3.0) return 0.003;
    if (absZ > 2.5) return 0.012;
    if (absZ > 2.0) return 0.046;
    if (absZ > 1.96) return 0.05;
    if (absZ > 1.5) return 0.134;
    return 0.5;
  }
  
  /// 승자 변형 결정
  String? _determineWinner(Map<String, VariantResult> results) {
    if (results.isEmpty) return null;
    
    String? winner;
    double maxRate = -1;
    
    for (final result in results.values) {
      // 최소 30개 이상의 노출이 있어야 유효
      if (result.impressions >= 30 && result.conversionRate > maxRate) {
        maxRate = result.conversionRate;
        winner = result.variantId;
      }
    }
    
    return winner;
  }
  
  /// 실험 결과 가져오기
  ABTestResult? getExperimentResult(String experimentId) {
    return _experimentResults[experimentId];
  }

  /// 모든 실험 결과 가져오기
  Map<String, ABTestResult> getAllResults() {
    return Map.from(_experimentResults);
  }
  
  /// 실험 자동 종료 (승자가 명확한 경우)
  Future<void> concludeExperiment(String experimentId) async {
    final result = _experimentResults[experimentId];
    if (result == null) return;
    
    // 통계적 유의성이 95% 이상이고 충분한 샘플이 있는 경우
    if ((result.confidenceLevel ?? 0) >= 0.95) {
      final experiment = _experiments[experimentId];
      if (experiment != null && result.winningVariantId != null) {
        // 승자 변형을 100% 트래픽으로 설정
        await forceVariant(experimentId, result.winningVariantId!);
        
        // Analytics에 실험 종료 이벤트 로그
        await _analytics.logEvent(
          'ab_test_concluded',
          parameters: {
            'experiment_id': experimentId,
            'winning_variant': result.winningVariantId!,
            'confidence_level': result.confidenceLevel!,
            'total_impressions': result.totalImpressions,
            'total_conversions': result.totalConversions,
          },
        );
        
        Logger.info('Experiment $experimentId concluded. Winner: ${result.winningVariantId}');
      }
    }
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