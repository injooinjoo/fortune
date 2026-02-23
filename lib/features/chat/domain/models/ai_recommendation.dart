import '../models/fortune_survey_config.dart';
import '../services/intent_detector.dart';

/// AI 운세 추천 결과
class AIRecommendation {
  final String fortuneType;
  final double confidence;
  final String? reason;

  const AIRecommendation({
    required this.fortuneType,
    required this.confidence,
    this.reason,
  });

  factory AIRecommendation.fromJson(Map<String, dynamic> json) {
    final rawType = (json['fortuneType'] as String?) ?? 'daily';
    final canonicalType =
        FortuneSurveyTypeCanonicalX.fromCanonicalId(rawType) != null
            ? rawType
            : FortuneSurveyType.daily.canonicalId;
    return AIRecommendation(
      fortuneType: canonicalType,
      confidence: (json['confidence'] as num).toDouble(),
      reason: json['reason'] as String?,
    );
  }

  /// DetectedIntent로 변환 (기존 FortuneTypeChips 호환)
  DetectedIntent toDetectedIntent() {
    final surveyType = _mapToSurveyType(fortuneType);
    return DetectedIntent(
      type: surveyType,
      confidence: confidence,
      matchedKeywords: reason != null ? [reason!] : [],
      isAiGenerated: true,
    );
  }

  /// fortuneType 문자열 → FortuneSurveyType 매핑
  FortuneSurveyType _mapToSurveyType(String type) {
    return FortuneSurveyTypeCanonicalX.fromCanonicalId(type) ??
        FortuneSurveyType.daily;
  }

  @override
  String toString() {
    return 'AIRecommendation(fortuneType: $fortuneType, confidence: ${(confidence * 100).toStringAsFixed(1)}%, reason: $reason)';
  }
}

/// AI 추천 응답
class AIRecommendResponse {
  final bool success;
  final List<AIRecommendation> recommendations;
  final String? error;
  final AIRecommendMeta? meta;

  const AIRecommendResponse({
    required this.success,
    required this.recommendations,
    this.error,
    this.meta,
  });

  factory AIRecommendResponse.fromJson(Map<String, dynamic> json) {
    return AIRecommendResponse(
      success: json['success'] as bool? ?? false,
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((r) => AIRecommendation.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      error: json['error'] as String?,
      meta: json['meta'] != null
          ? AIRecommendMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
    );
  }

  /// DetectedIntent 리스트로 변환
  List<DetectedIntent> toDetectedIntents() {
    return recommendations.map((r) => r.toDetectedIntent()).toList();
  }
}

/// 메타 정보
class AIRecommendMeta {
  final String provider;
  final String model;
  final int latencyMs;

  const AIRecommendMeta({
    required this.provider,
    required this.model,
    required this.latencyMs,
  });

  factory AIRecommendMeta.fromJson(Map<String, dynamic> json) {
    return AIRecommendMeta(
      provider: json['provider'] as String? ?? '',
      model: json['model'] as String? ?? '',
      latencyMs: json['latencyMs'] as int? ?? 0,
    );
  }
}
