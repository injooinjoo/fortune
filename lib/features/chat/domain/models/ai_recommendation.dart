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
    return AIRecommendation(
      fortuneType: json['fortuneType'] as String,
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
    switch (type) {
      // 시간 기반
      case 'daily':
        return FortuneSurveyType.daily;
      case 'yearly':
        return FortuneSurveyType.yearly;
      case 'newYear':
        return FortuneSurveyType.newYear;

      // 연애/관계
      case 'love':
        return FortuneSurveyType.love;
      case 'compatibility':
        return FortuneSurveyType.compatibility;
      case 'blindDate':
        return FortuneSurveyType.blindDate;
      case 'exLover':
        return FortuneSurveyType.exLover;
      case 'avoidPeople':
        return FortuneSurveyType.avoidPeople;

      // 직업/재능
      case 'career':
        return FortuneSurveyType.career;
      case 'talent':
        return FortuneSurveyType.talent;

      // 재물
      case 'money':
        return FortuneSurveyType.money;
      case 'luckyItems':
        return FortuneSurveyType.luckyItems;
      case 'lotto':
        return FortuneSurveyType.lotto;

      // 전통/신비
      case 'tarot':
        return FortuneSurveyType.tarot;
      case 'traditional':
        return FortuneSurveyType.traditional;
      case 'faceReading':
        return FortuneSurveyType.faceReading;

      // 성격/개성
      case 'mbti':
        return FortuneSurveyType.mbti;
      case 'personalityDna':
        return FortuneSurveyType.personalityDna;
      case 'biorhythm':
        return FortuneSurveyType.biorhythm;

      // 건강/스포츠
      case 'health':
        return FortuneSurveyType.health;
      case 'exercise':
        return FortuneSurveyType.exercise;
      case 'sportsGame':
        return FortuneSurveyType.sportsGame;

      // 인터랙티브
      case 'dream':
        return FortuneSurveyType.dream;
      case 'wish':
        return FortuneSurveyType.wish;
      case 'fortuneCookie':
        return FortuneSurveyType.fortuneCookie;
      case 'celebrity':
        return FortuneSurveyType.celebrity;

      // 가족/반려동물
      case 'family':
        return FortuneSurveyType.family;
      case 'pet':
        return FortuneSurveyType.pet;
      case 'naming':
        return FortuneSurveyType.naming;

      // 스타일/패션
      case 'ootdEvaluation':
        return FortuneSurveyType.ootdEvaluation;

      // 기타
      case 'talisman':
        return FortuneSurveyType.talisman;
      case 'exam':
        return FortuneSurveyType.exam;
      case 'moving':
        return FortuneSurveyType.moving;

      default:
        return FortuneSurveyType.daily;
    }
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
