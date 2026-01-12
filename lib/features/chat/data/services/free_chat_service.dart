import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/edge_functions_endpoints.dart';

/// 자유 채팅 응답 모델
class FreeChatResponse {
  final bool success;
  final String response;
  final FreeChatMeta? meta;
  final String? error;

  const FreeChatResponse({
    required this.success,
    required this.response,
    this.meta,
    this.error,
  });

  factory FreeChatResponse.fromJson(Map<String, dynamic> json) {
    return FreeChatResponse(
      success: json['success'] as bool? ?? false,
      response: json['response'] as String? ?? '',
      meta: json['meta'] != null
          ? FreeChatMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
      error: json['error'] as String?,
    );
  }
}

/// 메타 정보
class FreeChatMeta {
  final String provider;
  final String model;
  final int latencyMs;

  const FreeChatMeta({
    required this.provider,
    required this.model,
    required this.latencyMs,
  });

  factory FreeChatMeta.fromJson(Map<String, dynamic> json) {
    return FreeChatMeta(
      provider: json['provider'] as String? ?? '',
      model: json['model'] as String? ?? '',
      latencyMs: json['latencyMs'] as int? ?? 0,
    );
  }
}

/// 자유 채팅 컨텍스트
class FreeChatContext {
  final String? userName;
  final String? birthDate;
  final String? birthTime;
  final String? gender;
  final String? mbti;
  final String? zodiacSign;
  final String? chineseZodiac;
  final String? bloodType;

  const FreeChatContext({
    this.userName,
    this.birthDate,
    this.birthTime,
    this.gender,
    this.mbti,
    this.zodiacSign,
    this.chineseZodiac,
    this.bloodType,
  });

  Map<String, dynamic> toJson() {
    return {
      if (userName != null) 'userName': userName,
      if (birthDate != null) 'birthDate': birthDate,
      if (birthTime != null) 'birthTime': birthTime,
      if (gender != null) 'gender': gender,
      if (mbti != null) 'mbti': mbti,
      if (zodiacSign != null) 'zodiacSign': zodiacSign,
      if (chineseZodiac != null) 'chineseZodiac': chineseZodiac,
      if (bloodType != null) 'bloodType': bloodType,
    };
  }
}

/// 자유 채팅 서비스
/// 사용자의 직접 질문에 AI가 답변합니다.
class FreeChatService {
  final Dio _dio;

  // 타임아웃
  static const Duration _timeout = Duration(seconds: 10);

  FreeChatService({Dio? dio}) : _dio = dio ?? _createDio();

  static Dio _createDio() {
    return Dio(BaseOptions(
      baseUrl: EdgeFunctionsEndpoints.currentBaseUrl,
      connectTimeout: _timeout,
      receiveTimeout: _timeout,
    ));
  }

  /// 메시지 전송
  Future<String> sendMessage(
    String message, {
    FreeChatContext? context,
  }) async {
    try {
      debugPrint('[FreeChatService] 요청: $message');

      // Supabase 인증 토큰 가져오기
      final session = Supabase.instance.client.auth.currentSession;
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
      };
      if (session?.accessToken != null) {
        headers['Authorization'] = 'Bearer ${session!.accessToken}';
      }

      final response = await _dio.post(
        '/free-chat',
        data: {
          'message': message,
          if (context != null) 'context': context.toJson(),
        },
        options: Options(headers: headers),
      );

      final result = FreeChatResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (result.success && result.response.isNotEmpty) {
        debugPrint(
          '[FreeChatService] 성공: ${result.meta?.latencyMs}ms',
        );
        return result.response;
      } else {
        debugPrint('[FreeChatService] 실패: ${result.error}');
        throw Exception(result.error ?? 'AI 응답을 받지 못했어요');
      }
    } on DioException catch (e) {
      debugPrint('[FreeChatService] Dio 에러: ${e.message}');

      // 타임아웃 처리
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('응답 시간이 초과되었어요. 다시 시도해주세요.');
      }

      throw Exception('네트워크 오류가 발생했어요. 다시 시도해주세요.');
    } catch (e) {
      debugPrint('[FreeChatService] 에러: $e');
      rethrow;
    }
  }
}
