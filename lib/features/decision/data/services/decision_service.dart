import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/decision_receipt.dart';
import '../../domain/models/user_coach_preferences.dart';

/// Decision Service Provider
final decisionServiceProvider = Provider<DecisionService>((ref) {
  return DecisionService();
});

/// Decision 관련 Edge Function 호출 서비스
///
/// ZPZG Decision Coach Pivot - Phase 1.3
class DecisionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Edge Function 타임아웃 (결정 분석은 복잡함)
  static const _defaultTimeout = Duration(seconds: 30);
  static const _analysisTimeout = Duration(seconds: 60);

  // ========================================
  // Decision Receipt API
  // ========================================

  /// 새 결정 기록 생성
  Future<DecisionReceipt> createReceipt({
    required String userId,
    required DecisionType decisionType,
    required String question,
    String? chosenOption,
    String? reasoning,
    List<OptionAnalysis>? optionsAnalyzed,
    String? aiRecommendation,
    int? confidenceLevel,
    String? emotionalState,
    int? followUpDays,
    List<String>? tags,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'decision-receipt',
        body: {
          'action': 'create',
          'userId': userId,
          'data': {
            'decisionType': decisionType.value,
            'question': question,
            if (chosenOption != null) 'chosenOption': chosenOption,
            if (reasoning != null) 'reasoning': reasoning,
            if (optionsAnalyzed != null)
              'optionsAnalyzed':
                  optionsAnalyzed.map((e) => e.toJson()).toList(),
            if (aiRecommendation != null) 'aiRecommendation': aiRecommendation,
            if (confidenceLevel != null) 'confidenceLevel': confidenceLevel,
            if (emotionalState != null) 'emotionalState': emotionalState,
            if (followUpDays != null) 'followUpDays': followUpDays,
            if (tags != null) 'tags': tags,
          },
        },
      ).timeout(_defaultTimeout);

      if (response.status != 200) {
        throw Exception('Failed to create receipt: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Unknown error');
      }

      return DecisionReceipt.fromJson(data['data'] as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ Error creating decision receipt: $e');
      rethrow;
    }
  }

  /// 결정 기록 업데이트
  Future<DecisionReceipt> updateReceipt({
    required String userId,
    required String receiptId,
    String? chosenOption,
    String? reasoning,
    int? confidenceLevel,
    String? emotionalState,
    List<String>? tags,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'decision-receipt',
        body: {
          'action': 'update',
          'userId': userId,
          'receiptId': receiptId,
          'data': {
            if (chosenOption != null) 'chosenOption': chosenOption,
            if (reasoning != null) 'reasoning': reasoning,
            if (confidenceLevel != null) 'confidenceLevel': confidenceLevel,
            if (emotionalState != null) 'emotionalState': emotionalState,
            if (tags != null) 'tags': tags,
          },
        },
      ).timeout(_defaultTimeout);

      if (response.status != 200) {
        throw Exception('Failed to update receipt: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Unknown error');
      }

      return DecisionReceipt.fromJson(data['data'] as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ Error updating decision receipt: $e');
      rethrow;
    }
  }

  /// 단일 결정 기록 조회
  Future<DecisionReceipt> getReceipt({
    required String userId,
    required String receiptId,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'decision-receipt',
        body: {
          'action': 'get',
          'userId': userId,
          'receiptId': receiptId,
        },
      ).timeout(_defaultTimeout);

      if (response.status != 200) {
        throw Exception('Failed to get receipt: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Unknown error');
      }

      return DecisionReceipt.fromJson(data['data'] as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ Error getting decision receipt: $e');
      rethrow;
    }
  }

  /// 결정 기록 목록 조회
  Future<List<DecisionReceipt>> listReceipts({
    required String userId,
    DecisionType? decisionType,
    OutcomeStatus? outcomeStatus,
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'decision-receipt',
        body: {
          'action': 'list',
          'userId': userId,
          'filters': {
            if (decisionType != null) 'decisionType': decisionType.value,
            if (outcomeStatus != null) 'outcomeStatus': outcomeStatus.value,
            if (limit != null) 'limit': limit,
            if (offset != null) 'offset': offset,
          },
        },
      ).timeout(_defaultTimeout);

      if (response.status != 200) {
        throw Exception('Failed to list receipts: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Unknown error');
      }

      final receipts = (data['data'] as List<dynamic>)
          .map((e) => DecisionReceipt.fromJson(e as Map<String, dynamic>))
          .toList();

      return receipts;
    } catch (e) {
      debugPrint('❌ Error listing decision receipts: $e');
      rethrow;
    }
  }

  /// 결정 기록 삭제
  Future<void> deleteReceipt({
    required String userId,
    required String receiptId,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'decision-receipt',
        body: {
          'action': 'delete',
          'userId': userId,
          'receiptId': receiptId,
        },
      ).timeout(_defaultTimeout);

      if (response.status != 200) {
        throw Exception('Failed to delete receipt: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      debugPrint('❌ Error deleting decision receipt: $e');
      rethrow;
    }
  }

  /// 결정 통계 조회
  Future<DecisionStats> getStats({required String userId}) async {
    try {
      final response = await _supabase.functions.invoke(
        'decision-receipt',
        body: {
          'action': 'stats',
          'userId': userId,
        },
      ).timeout(_defaultTimeout);

      if (response.status != 200) {
        throw Exception('Failed to get stats: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Unknown error');
      }

      return DecisionStats.fromJson(data['data'] as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ Error getting decision stats: $e');
      rethrow;
    }
  }

  // ========================================
  // Decision Follow-up API
  // ========================================

  /// 결과 기록
  Future<DecisionReceipt> recordOutcome({
    required String userId,
    required String receiptId,
    required OutcomeStatus outcomeStatus,
    String? outcomeNotes,
    int? outcomeRating,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'decision-followup',
        body: {
          'action': 'recordOutcome',
          'userId': userId,
          'receiptId': receiptId,
          'data': {
            'outcomeStatus': outcomeStatus.value,
            if (outcomeNotes != null) 'outcomeNotes': outcomeNotes,
            if (outcomeRating != null) 'outcomeRating': outcomeRating,
          },
        },
      ).timeout(_defaultTimeout);

      if (response.status != 200) {
        throw Exception('Failed to record outcome: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Unknown error');
      }

      return DecisionReceipt.fromJson(data['data'] as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ Error recording outcome: $e');
      rethrow;
    }
  }

  /// 팔로업 대기 목록 조회
  Future<List<DecisionReceipt>> getPendingFollowUps({
    required String userId,
    int? limit,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'decision-followup',
        body: {
          'action': 'getPending',
          'userId': userId,
          if (limit != null) 'limit': limit,
        },
      ).timeout(_defaultTimeout);

      if (response.status != 200) {
        throw Exception('Failed to get pending follow-ups: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Unknown error');
      }

      final receipts = (data['data'] as List<dynamic>)
          .map((e) => DecisionReceipt.fromJson(e as Map<String, dynamic>))
          .toList();

      return receipts;
    } catch (e) {
      debugPrint('❌ Error getting pending follow-ups: $e');
      rethrow;
    }
  }

  /// 팔로업 발송 표시
  Future<void> markFollowUpSent({
    required String userId,
    required String receiptId,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'decision-followup',
        body: {
          'action': 'markFollowUpSent',
          'userId': userId,
          'receiptId': receiptId,
        },
      ).timeout(_defaultTimeout);

      if (response.status != 200) {
        throw Exception('Failed to mark follow-up sent: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      debugPrint('❌ Error marking follow-up sent: $e');
      rethrow;
    }
  }

  /// 결정 패턴 분석
  Future<DecisionPatternAnalysis> getPatterns({
    required String userId,
    int? limit,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'decision-followup',
        body: {
          'action': 'getPatterns',
          'userId': userId,
          if (limit != null) 'limit': limit,
        },
      ).timeout(_analysisTimeout);

      if (response.status != 200) {
        throw Exception('Failed to get patterns: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Unknown error');
      }

      final analysisData = data['data'] as Map<String, dynamic>;
      return DecisionPatternAnalysis.fromJson(
        analysisData['analysis'] as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('❌ Error getting patterns: $e');
      rethrow;
    }
  }

  /// 팔로업 날짜 재설정
  Future<DecisionReceipt> rescheduleFollowUp({
    required String userId,
    required String receiptId,
    DateTime? newFollowUpDate,
    int? newFollowUpDays,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'decision-followup',
        body: {
          'action': 'reschedule',
          'userId': userId,
          'receiptId': receiptId,
          'data': {
            if (newFollowUpDate != null)
              'newFollowUpDate': newFollowUpDate.toIso8601String(),
            if (newFollowUpDays != null) 'newFollowUpDays': newFollowUpDays,
          },
        },
      ).timeout(_defaultTimeout);

      if (response.status != 200) {
        throw Exception('Failed to reschedule follow-up: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Unknown error');
      }

      return DecisionReceipt.fromJson(data['data'] as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ Error rescheduling follow-up: $e');
      rethrow;
    }
  }

  // ========================================
  // Coach Personalize API
  // ========================================

  /// 코치 설정 조회 (없으면 생성)
  Future<UserCoachPreferences> getPreferences({required String userId}) async {
    try {
      final response = await _supabase.functions.invoke(
        'coach-personalize',
        body: {
          'action': 'get',
          'userId': userId,
        },
      ).timeout(_defaultTimeout);

      if (response.status != 200) {
        throw Exception('Failed to get preferences: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Unknown error');
      }

      return UserCoachPreferences.fromJson(
          data['data'] as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ Error getting preferences: $e');
      rethrow;
    }
  }

  /// 코치 설정 업데이트
  Future<UserCoachPreferences> updatePreferences({
    required String userId,
    TonePreference? tonePreference,
    ResponseLength? responseLength,
    DecisionStyle? decisionStyle,
    RelationshipStatus? relationshipStatus,
    AgeGroup? ageGroup,
    String? occupationType,
    List<String>? preferredCategories,
    bool? followUpReminderEnabled,
    int? followUpDays,
    bool? pushNotificationEnabled,
    AnonymousPrefixType? communityAnonymousPrefix,
    bool? communityParticipationEnabled,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'coach-personalize',
        body: {
          'action': 'update',
          'userId': userId,
          'data': {
            if (tonePreference != null) 'tone_preference': tonePreference.value,
            if (responseLength != null) 'response_length': responseLength.value,
            if (decisionStyle != null) 'decision_style': decisionStyle.value,
            if (relationshipStatus != null)
              'relationship_status': relationshipStatus.value,
            if (ageGroup != null) 'age_group': ageGroup.value,
            if (occupationType != null) 'occupation_type': occupationType,
            if (preferredCategories != null)
              'preferred_categories': preferredCategories,
            if (followUpReminderEnabled != null)
              'follow_up_reminder_enabled': followUpReminderEnabled,
            if (followUpDays != null) 'follow_up_days': followUpDays,
            if (pushNotificationEnabled != null)
              'push_notification_enabled': pushNotificationEnabled,
            if (communityAnonymousPrefix != null)
              'community_anonymous_prefix': communityAnonymousPrefix.value,
            if (communityParticipationEnabled != null)
              'community_participation_enabled': communityParticipationEnabled,
          },
        },
      ).timeout(_defaultTimeout);

      if (response.status != 200) {
        throw Exception('Failed to update preferences: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Unknown error');
      }

      return UserCoachPreferences.fromJson(
          data['data'] as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ Error updating preferences: $e');
      rethrow;
    }
  }

  /// 코치 설정 초기화
  Future<UserCoachPreferences> resetPreferences(
      {required String userId}) async {
    try {
      final response = await _supabase.functions.invoke(
        'coach-personalize',
        body: {
          'action': 'reset',
          'userId': userId,
        },
      ).timeout(_defaultTimeout);

      if (response.status != 200) {
        throw Exception('Failed to reset preferences: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Unknown error');
      }

      return UserCoachPreferences.fromJson(
          data['data'] as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ Error resetting preferences: $e');
      rethrow;
    }
  }

  /// 커뮤니티 익명 ID 생성
  Future<String> generateAnonymousId({required String userId}) async {
    try {
      final response = await _supabase.functions.invoke(
        'coach-personalize',
        body: {
          'action': 'generateAnonymousId',
          'userId': userId,
        },
      ).timeout(_defaultTimeout);

      if (response.status != 200) {
        throw Exception('Failed to generate anonymous ID: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Unknown error');
      }

      return data['data']['anonymousId'] as String;
    } catch (e) {
      debugPrint('❌ Error generating anonymous ID: $e');
      rethrow;
    }
  }

  // ========================================
  // Decision Analysis (fortune-decision)
  // ========================================

  /// 결정 분석 요청
  Future<DecisionAnalysisResult> analyzeDecision({
    required String userId,
    required String question,
    DecisionType decisionType = DecisionType.lifestyle,
    List<String>? options,
    bool isPremium = false,
    bool saveReceipt = false,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'fortune-decision',
        body: {
          'userId': userId,
          'question': question,
          'decisionType': decisionType.value,
          if (options != null && options.isNotEmpty) 'options': options,
          'isPremium': isPremium,
          'saveReceipt': saveReceipt,
        },
      ).timeout(_analysisTimeout);

      if (response.status != 200) {
        throw Exception('Failed to analyze decision: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Unknown error');
      }

      return DecisionAnalysisResult.fromJson(
          data['data'] as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ Error analyzing decision: $e');
      rethrow;
    }
  }
}

/// 결정 분석 결과 (fortune-decision 응답)
class DecisionAnalysisResult {
  final String fortuneType;
  final String decisionType;
  final String question;
  final List<OptionAnalysis> options;
  final String recommendation;
  final List<String> confidenceFactors;
  final List<String> nextSteps;
  final DateTime timestamp;
  final String? decisionReceiptId;

  DecisionAnalysisResult({
    required this.fortuneType,
    required this.decisionType,
    required this.question,
    required this.options,
    required this.recommendation,
    required this.confidenceFactors,
    required this.nextSteps,
    required this.timestamp,
    this.decisionReceiptId,
  });

  factory DecisionAnalysisResult.fromJson(Map<String, dynamic> json) {
    return DecisionAnalysisResult(
      fortuneType: json['fortuneType'] as String? ?? 'decision',
      decisionType: json['decisionType'] as String? ?? 'lifestyle',
      question: json['question'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => OptionAnalysis.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recommendation: json['recommendation'] as String? ?? '',
      confidenceFactors:
          (json['confidenceFactors'] as List<dynamic>?)?.cast<String>() ?? [],
      nextSteps: (json['nextSteps'] as List<dynamic>?)?.cast<String>() ?? [],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      decisionReceiptId: json['decisionReceiptId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'fortuneType': fortuneType,
        'decisionType': decisionType,
        'question': question,
        'options': options.map((e) => e.toJson()).toList(),
        'recommendation': recommendation,
        'confidenceFactors': confidenceFactors,
        'nextSteps': nextSteps,
        'timestamp': timestamp.toIso8601String(),
        if (decisionReceiptId != null) 'decisionReceiptId': decisionReceiptId,
      };
}
