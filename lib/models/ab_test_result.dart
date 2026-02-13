import 'package:equatable/equatable.dart';

/// AB 테스트 실험 결과 모델
class ABTestResult extends Equatable {
  final String experimentId;
  final String experimentName;
  final DateTime startDate;
  final Map<String, VariantResult> variantResults;
  final String? winningVariantId;
  final double? statisticalSignificance; // p-value
  final double? confidenceLevel; // 1 - p-value
  final DateTime lastUpdated;

  const ABTestResult({
    required this.experimentId,
    required this.experimentName,
    required this.startDate,
    required this.variantResults,
    this.winningVariantId,
    this.statisticalSignificance,
    this.confidenceLevel,
    required this.lastUpdated,
  });

  /// 전체 노출 수
  int get totalImpressions {
    return variantResults.values
        .fold(0, (sum, result) => sum + result.impressions);
  }

  /// 전체 전환 수
  int get totalConversions {
    return variantResults.values
        .fold(0, (sum, result) => sum + result.conversions);
  }

  /// 전체 전환율
  double get overallConversionRate {
    final impressions = totalImpressions;
    return impressions > 0 ? totalConversions / impressions : 0.0;
  }

  /// 실험이 통계적으로 유의미한지 여부
  bool get isStatisticallySignificant {
    return (confidenceLevel ?? 0) >= 0.95; // 95% 신뢰수준
  }

  /// Control 대비 최고 성과 변형의 개선율
  double? get uplift {
    final controlResult = variantResults['control'];
    if (controlResult == null ||
        winningVariantId == null ||
        winningVariantId == 'control') {
      return null;
    }

    final winnerResult = variantResults[winningVariantId];
    if (winnerResult == null || controlResult.conversionRate == 0) {
      return null;
    }

    return ((winnerResult.conversionRate - controlResult.conversionRate) /
            controlResult.conversionRate) *
        100;
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'experiment_id': experimentId,
      'experiment_name': experimentName,
      'start_date': startDate.toIso8601String(),
      'variant_results': variantResults.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'winning_variant_id': winningVariantId,
      'statistical_significance': statisticalSignificance,
      'confidence_level': confidenceLevel,
      'last_updated': lastUpdated.toIso8601String(),
      'total_impressions': totalImpressions,
      'total_conversions': totalConversions,
      'overall_conversion_rate': overallConversionRate,
      'is_statistically_significant': isStatisticallySignificant,
      'uplift': uplift,
    };
  }

  @override
  List<Object?> get props => [
        experimentId,
        experimentName,
        startDate,
        variantResults,
        winningVariantId,
        statisticalSignificance,
        confidenceLevel,
        lastUpdated,
      ];
}

/// 변형별 결과
class VariantResult extends Equatable {
  final String variantId;
  final String variantName;
  final int impressions;
  final int conversions;
  final double conversionRate;

  const VariantResult({
    required this.variantId,
    required this.variantName,
    required this.impressions,
    required this.conversions,
    required this.conversionRate,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'variant_id': variantId,
      'variant_name': variantName,
      'impressions': impressions,
      'conversions': conversions,
      'conversion_rate': conversionRate,
    };
  }

  @override
  List<Object> get props => [
        variantId,
        variantName,
        impressions,
        conversions,
        conversionRate,
      ];
}

/// 전환 이벤트
class ConversionEvent extends Equatable {
  final String variantId;
  final String conversionType;
  final DateTime timestamp;
  final dynamic value;
  final Map<String, dynamic>? metadata;

  const ConversionEvent({
    required this.variantId,
    required this.conversionType,
    required this.timestamp,
    this.value,
    this.metadata,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'variant_id': variantId,
      'conversion_type': conversionType,
      'timestamp': timestamp.toIso8601String(),
      'value': value,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
        variantId,
        conversionType,
        timestamp,
        value,
        metadata,
      ];
}
