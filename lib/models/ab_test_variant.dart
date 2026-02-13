import 'package:equatable/equatable.dart';

/// A/B 테스트 변형 (Variant) 모델
class ABTestVariant extends Equatable {
  final String id;
  final String name;
  final Map<String, dynamic> parameters;
  final double weight; // 변형이 선택될 가중치 (0.0 ~ 1.0)

  const ABTestVariant({
    required this.id,
    required this.name,
    required this.parameters,
    this.weight = 1.0,
  });

  /// 특정 파라미터 값 가져오기
  T? getParameter<T>(String key) {
    return parameters[key] as T?;
  }

  /// 파라미터가 존재하는지 확인
  bool hasParameter(String key) {
    return parameters.containsKey(key);
  }

  /// JSON으로부터 생성
  factory ABTestVariant.fromJson(Map<String, dynamic> json) {
    return ABTestVariant(
      id: json['id'] as String,
      name: json['name'] as String,
      parameters: json['parameters'] as Map<String, dynamic>? ?? {},
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parameters': parameters,
      'weight': weight,
    };
  }

  @override
  List<Object?> get props => [id, name, parameters, weight];
}

/// Control Group (대조군) 변형
class ControlVariant extends ABTestVariant {
  const ControlVariant({
    required super.parameters,
  }) : super(
          id: 'control',
          name: 'Control Group',
          weight: 1.0,
        );
}

/// A/B 테스트 결과 추적 모델
class ABTestResult extends Equatable {
  final String experimentId;
  final String variantId;
  final String userId;
  final DateTime timestamp;
  final Map<String, dynamic> metrics;
  final bool converted;

  const ABTestResult({
    required this.experimentId,
    required this.variantId,
    required this.userId,
    required this.timestamp,
    required this.metrics,
    this.converted = false,
  });

  /// 전환 이벤트 발생 시 업데이트
  ABTestResult markAsConverted({
    Map<String, dynamic>? additionalMetrics,
  }) {
    final updatedMetrics = {...metrics};
    if (additionalMetrics != null) {
      updatedMetrics.addAll(additionalMetrics);
    }

    return ABTestResult(
      experimentId: experimentId,
      variantId: variantId,
      userId: userId,
      timestamp: timestamp,
      metrics: updatedMetrics,
      converted: true,
    );
  }

  /// JSON으로부터 생성
  factory ABTestResult.fromJson(Map<String, dynamic> json) {
    return ABTestResult(
      experimentId: json['experiment_id'] as String,
      variantId: json['variant_id'] as String,
      userId: json['user_id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metrics: json['metrics'] as Map<String, dynamic>? ?? {},
      converted: json['converted'] as bool? ?? false,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'experiment_id': experimentId,
      'variant_id': variantId,
      'user_id': userId,
      'timestamp': timestamp.toIso8601String(),
      'metrics': metrics,
      'converted': converted,
    };
  }

  @override
  List<Object?> get props => [
        experimentId,
        variantId,
        userId,
        timestamp,
        metrics,
        converted,
      ];
}
