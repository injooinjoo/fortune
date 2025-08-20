import 'package:equatable/equatable.dart';
import 'ab_test_variant.dart';

/// A/B 테스트 실험 모델
class ABTestExperiment extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<ABTestVariant> variants;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final double trafficAllocation; // 전체 트래픽 중 실험에 참여할 비율 (0.0 ~ 1.0)
  final List<String> targetAudience; // 타겟 오디언스 조건들
  final Map<String, dynamic> metadata;

  const ABTestExperiment({
    required this.id,
    required this.name,
    required this.description,
    required this.variants,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.trafficAllocation = 1.0,
    this.targetAudience = const [],
    this.metadata = const {},
  });

  /// 실험이 현재 진행 중인지 확인
  bool get isRunning {
    if (!isActive) return false;
    
    final now = DateTime.now();
    if (now.isBefore(startDate)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    
    return true;
  }

  /// Control 변형 가져오기
  ABTestVariant? get controlVariant {
    try {
      return variants.firstWhere((v) => v.id == 'control');
    } catch (_) {
      return null;
    }
  }

  /// 특정 ID의 변형 가져오기
  ABTestVariant? getVariant(String variantId) {
    try {
      return variants.firstWhere((v) => v.id == variantId);
    } catch (_) {
      return null;
    }
  }

  /// JSON으로부터 생성
  factory ABTestExperiment.fromJson(Map<String, dynamic> json) {
    return ABTestExperiment(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      variants: (json['variants'] as List<dynamic>)
          .map((v) => ABTestVariant.fromJson(v as Map<String, dynamic>))
          .toList(),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      trafficAllocation: (json['traffic_allocation'] as num?)?.toDouble() ?? 1.0,
      targetAudience: (json['target_audience'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'variants': variants.map((v) => v.toJson()).toList(),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive,
      'traffic_allocation': trafficAllocation,
      'target_audience': targetAudience,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        variants,
        startDate,
        endDate,
        isActive,
        trafficAllocation,
        targetAudience,
        metadata,
      ];
}

/// 실험 타입 열거형
enum ExperimentType {
  payment('payment', '결제'),
  onboarding('onboarding', '온보딩'),
  ui('ui', 'UI/UX'),
  feature('feature', '기능'),
  pricing('pricing', '가격'),
  content('content', '콘텐츠');

  final String key;
  final String displayName;
  
  const ExperimentType(this.key, this.displayName);
}

/// 실험 목표 메트릭
class ExperimentMetric extends Equatable {
  final String id;
  final String name;
  final String type; // 'conversion', 'revenue', 'engagement', 'retention'
  final String eventName; // Firebase Analytics 이벤트 이름
  final Map<String, dynamic>? eventParameters;
  final double? targetValue;
  final String? unit;

  const ExperimentMetric({
    required this.id,
    required this.name,
    required this.type,
    required this.eventName,
    this.eventParameters,
    this.targetValue,
    this.unit,
  });

  /// JSON으로부터 생성
  factory ExperimentMetric.fromJson(Map<String, dynamic> json) {
    return ExperimentMetric(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      eventName: json['event_name'] as String,
      eventParameters: json['event_parameters'] as Map<String, dynamic>?,
      targetValue: (json['target_value'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'event_name': eventName,
      if (eventParameters != null) 'event_parameters': eventParameters,
      if (targetValue != null) 'target_value': targetValue,
      if (unit != null) 'unit': unit,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        eventName,
        eventParameters,
        targetValue,
        unit,
      ];
}