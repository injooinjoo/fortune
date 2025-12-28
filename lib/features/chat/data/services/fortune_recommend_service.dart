import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/edge_functions_endpoints.dart';
import '../../domain/models/ai_recommendation.dart';

/// AI 기반 운세 추천 서비스
class FortuneRecommendService {
  final Dio _dio;
  final Map<String, AIRecommendResponse> _cache = {};

  // 디바운싱
  Timer? _debounceTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 300);

  // 타임아웃
  static const Duration _timeout = Duration(milliseconds: 3000);

  FortuneRecommendService({Dio? dio}) : _dio = dio ?? _createDio();

  static Dio _createDio() {
    return Dio(BaseOptions(
      baseUrl: EdgeFunctionsEndpoints.currentBaseUrl,
      connectTimeout: _timeout,
      receiveTimeout: _timeout,
    ));
  }

  /// AI 추천 호출 (디바운싱 없이 직접 호출)
  Future<AIRecommendResponse> getRecommendations(String query) async {
    // 캐시 확인
    if (_cache.containsKey(query)) {
      debugPrint('🎯 [FortuneRecommendService] 캐시 히트: $query');
      return _cache[query]!;
    }

    try {
      debugPrint('🤖 [FortuneRecommendService] AI 추천 요청: $query');

      // Supabase 인증 토큰 가져오기
      final session = Supabase.instance.client.auth.currentSession;
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
      };
      if (session?.accessToken != null) {
        headers['Authorization'] = 'Bearer ${session!.accessToken}';
      }

      final response = await _dio.post(
        EdgeFunctionsEndpoints.fortuneRecommend,
        data: {'query': query, 'limit': 3},
        options: Options(headers: headers),
      );

      final result = AIRecommendResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      // 캐시 저장 (성공 시에만)
      if (result.success && result.recommendations.isNotEmpty) {
        _cache[query] = result;
        debugPrint(
          '✅ [FortuneRecommendService] 추천 성공: ${result.recommendations.length}개, '
          '지연: ${result.meta?.latencyMs}ms',
        );
      }

      return result;
    } on DioException catch (e) {
      debugPrint('❌ [FortuneRecommendService] Dio 에러: ${e.message}');
      return AIRecommendResponse(
        success: false,
        recommendations: [],
        error: e.message,
      );
    } catch (e) {
      debugPrint('❌ [FortuneRecommendService] 에러: $e');
      return AIRecommendResponse(
        success: false,
        recommendations: [],
        error: e.toString(),
      );
    }
  }

  /// 디바운싱 래퍼 (타이핑 중 실시간 추천용)
  void getRecommendationsDebounced(
    String query, {
    required void Function(AIRecommendResponse) onSuccess,
    void Function()? onError,
    void Function()? onStart,
  }) {
    _debounceTimer?.cancel();

    if (query.length < 2) {
      return;
    }

    _debounceTimer = Timer(_debounceDelay, () async {
      onStart?.call();

      try {
        final response = await getRecommendations(query);
        if (response.success && response.recommendations.isNotEmpty) {
          onSuccess(response);
        } else {
          onError?.call();
        }
      } catch (e) {
        debugPrint('❌ [FortuneRecommendService] 디바운스 에러: $e');
        onError?.call();
      }
    });
  }

  /// 캐시 초기화
  void clearCache() {
    _cache.clear();
    debugPrint('🗑️ [FortuneRecommendService] 캐시 초기화');
  }

  /// 디바운스 타이머 취소
  void cancelDebounce() {
    _debounceTimer?.cancel();
  }

  /// 리소스 정리
  void dispose() {
    cancelDebounce();
    clearCache();
  }
}
