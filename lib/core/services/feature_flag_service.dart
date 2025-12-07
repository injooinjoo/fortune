import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

/// Feature Flag 모델
class FeatureFlag {
  final String key;
  final bool enabled;
  final String variant;
  final int rolloutPercentage;
  final List<String> targetUserIds;
  final Map<String, dynamic> metadata;

  FeatureFlag({
    required this.key,
    required this.enabled,
    this.variant = 'control',
    this.rolloutPercentage = 0,
    this.targetUserIds = const [],
    this.metadata = const {},
  });

  factory FeatureFlag.fromJson(Map<String, dynamic> json) {
    return FeatureFlag(
      key: json['key'] as String,
      enabled: json['enabled'] as bool? ?? false,
      variant: json['variant'] as String? ?? 'control',
      rolloutPercentage: json['rollout_percentage'] as int? ?? 0,
      targetUserIds: (json['target_user_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}

/// Feature Flag 서비스
class FeatureFlagService {
  final SupabaseClient _supabase;
  Map<String, FeatureFlag> _flags = {};
  bool _initialized = false;

  FeatureFlagService(this._supabase);

  /// 초기화 - 모든 플래그 로드
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final response = await _supabase
          .from('feature_flags')
          .select()
          .order('key');

      _flags = {
        for (final row in response)
          row['key'] as String: FeatureFlag.fromJson(row),
      };
      _initialized = true;
      AppLogger.debug('FeatureFlagService initialized with ${_flags.length} flags');
    } catch (e) {
      AppLogger.error('Failed to load feature flags', error: e);
      _flags = {};
    }
  }

  /// 플래그 활성화 여부 확인
  bool isEnabled(String key, {String? userId}) {
    final flag = _flags[key];
    if (flag == null) return false;
    if (!flag.enabled) return false;

    // 특정 사용자 대상인 경우
    if (flag.targetUserIds.isNotEmpty && userId != null) {
      return flag.targetUserIds.contains(userId);
    }

    // 롤아웃 퍼센트 기반
    if (flag.rolloutPercentage < 100 && userId != null) {
      final hash = userId.hashCode.abs() % 100;
      return hash < flag.rolloutPercentage;
    }

    return flag.enabled;
  }

  /// A/B 테스트 variant 가져오기
  String getVariant(String key, {String? userId}) {
    final flag = _flags[key];
    if (flag == null) return 'control';

    // 사용자 ID 기반으로 일관된 variant 할당
    if (userId != null && flag.variant != 'control') {
      final hash = userId.hashCode.abs() % 2;
      return hash == 0 ? 'control' : flag.variant;
    }

    return flag.variant;
  }

  /// 메타데이터 가져오기
  Map<String, dynamic> getMetadata(String key) {
    return _flags[key]?.metadata ?? {};
  }

  /// 플래그 새로고침
  Future<void> refresh() async {
    _initialized = false;
    await initialize();
  }
}

/// Feature Flag 서비스 Provider
final featureFlagServiceProvider = Provider<FeatureFlagService>((ref) {
  return FeatureFlagService(Supabase.instance.client);
});

/// 특정 플래그 활성화 여부 Provider
final isFeatureEnabledProvider = Provider.family<bool, String>((ref, key) {
  final service = ref.watch(featureFlagServiceProvider);
  // TODO: 현재 사용자 ID 가져오기
  return service.isEnabled(key);
});

/// A/B 테스트 variant Provider
final featureVariantProvider = Provider.family<String, String>((ref, key) {
  final service = ref.watch(featureFlagServiceProvider);
  return service.getVariant(key);
});
