import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_insight_result.dart';
import '../../domain/services/anonymizer.dart';
import '../storage/insight_storage.dart';

/// Chat Insight API Service Provider
final chatInsightApiServiceProvider = Provider<ChatInsightApiService>((ref) {
  return ChatInsightApiService();
});

/// Chat Insight Edge Function 호출 서비스
/// 프라이버시 설정에 따라 서버 전송 여부 결정
class ChatInsightApiService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const _analysisTimeout = Duration(seconds: 60);
  static const _followupTimeout = Duration(seconds: 30);
  static const _suggestTimeout = Duration(seconds: 30);

  /// 서버 분석 가능 여부 확인
  Future<bool> isServerAnalysisEnabled() async {
    final config = await InsightStorage.loadPrivacyConfig();
    return config.serverSent;
  }

  /// 딥 분석 (서버 전송 ON 시만 사용)
  /// anonymized 메시지를 서버로 전송하여 LLM 분석
  Future<ChatInsightResult?> analyzeDeep({
    required AnonymizedResult anonymized,
    required AnalysisConfig config,
    required String userSender,
  }) async {
    final privacyConfig = await InsightStorage.loadPrivacyConfig();
    if (!privacyConfig.serverSent) {
      debugPrint('⚠️ 서버 분석 비활성화: 로컬 분석만 사용');
      return null;
    }

    try {
      final messages = anonymized.messages.map((m) {
        return {
          'sender': m.sender,
          'text': m.text,
          'timestamp': m.timestamp.toIso8601String(),
        };
      }).toList();

      final response = await _supabase.functions
          .invoke(
            'chat-insight-analyze',
            body: {
              'anonymized_messages': messages,
              'relation_type': config.relationType.name,
              'date_range': _dateRangeToString(config.dateRange),
              'intensity': config.intensity.name,
              'user_is': 'A',
            },
          )
          .timeout(_analysisTimeout);

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw Exception(data['error'] ?? '서버 분석 실패');
      }

      final resultData = data['data'] as Map<String, dynamic>;

      // analysis_meta는 로컬에서 생성
      final meta = AnalysisMeta(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        relationType: config.relationType,
        range: config.dateRange,
        intensity: config.intensity,
        privacy: privacyConfig,
        messageCount: anonymized.messages.length,
        dateFrom: anonymized.messages.isNotEmpty
            ? anonymized.messages.first.timestamp
            : DateTime.now(),
        dateTo: anonymized.messages.isNotEmpty
            ? anonymized.messages.last.timestamp
            : DateTime.now(),
      );

      return ChatInsightResult(
        analysisMeta: meta,
        scores: InsightScores.fromJson(resultData['scores'] as Map<String, dynamic>),
        highlights: InsightHighlights.fromJson(resultData['highlights'] as Map<String, dynamic>),
        timeline: InsightTimeline.fromJson(resultData['timeline'] as Map<String, dynamic>),
        patterns: InsightPatterns.fromJson(resultData['patterns'] as Map<String, dynamic>),
        triggers: InsightTriggers.fromJson(resultData['triggers'] as Map<String, dynamic>),
        guidance: InsightGuidance.fromJson(resultData['guidance'] as Map<String, dynamic>),
        followupMemory: FollowupMemory.fromJson(resultData['followup_memory'] as Map<String, dynamic>),
      );
    } catch (e) {
      debugPrint('❌ chat-insight-analyze 에러: $e');
      return null;
    }
  }

  /// 후속 상담 질문
  Future<String?> askFollowup({
    required ChatInsightResult analysisResult,
    required String question,
    List<Map<String, String>> conversationHistory = const [],
  }) async {
    final privacyConfig = await InsightStorage.loadPrivacyConfig();
    if (!privacyConfig.serverSent) {
      return null;
    }

    try {
      final response = await _supabase.functions
          .invoke(
            'chat-insight-followup',
            body: {
              'analysis_result': {
                'followup_memory': analysisResult.followupMemory.toJson(),
                'scores': analysisResult.scores.toJson(),
                'guidance': analysisResult.guidance.toJson(),
              },
              'user_question': question,
              'conversation_history': conversationHistory,
            },
          )
          .timeout(_followupTimeout);

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw Exception(data['error'] ?? '상담 실패');
      }

      return (data['data'] as Map<String, dynamic>)['answer'] as String?;
    } catch (e) {
      debugPrint('❌ chat-insight-followup 에러: $e');
      return null;
    }
  }

  /// 추천 문장 생성
  Future<List<Map<String, String>>?> suggestMessages({
    required String situation,
    required String tone,
    required RelationType relationType,
    required InsightGuidance guidance,
  }) async {
    final privacyConfig = await InsightStorage.loadPrivacyConfig();
    if (!privacyConfig.serverSent) {
      return null;
    }

    try {
      final response = await _supabase.functions
          .invoke(
            'chat-insight-suggest',
            body: {
              'situation': situation,
              'tone': tone,
              'relation_type': relationType.name,
              'analysis_context': {
                'do_items': guidance.doList.map((g) => g.toJson()).toList(),
                'dont_items': guidance.dontList.map((g) => g.toJson()).toList(),
              },
            },
          )
          .timeout(_suggestTimeout);

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw Exception(data['error'] ?? '추천 문장 생성 실패');
      }

      final suggestions = (data['data'] as Map<String, dynamic>)['suggestions'] as List<dynamic>?;
      if (suggestions == null) return null;

      return suggestions.map((s) {
        final item = s as Map<String, dynamic>;
        return {
          'text': item['text'] as String? ?? '',
          'tone_note': item['tone_note'] as String? ?? '',
        };
      }).toList();
    } catch (e) {
      debugPrint('❌ chat-insight-suggest 에러: $e');
      return null;
    }
  }

  String _dateRangeToString(DateRange range) {
    switch (range) {
      case DateRange.days7:
        return '7d';
      case DateRange.days30:
        return '30d';
      case DateRange.all:
        return 'all';
    }
  }
}
