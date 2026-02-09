import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/character_chat_message.dart';

/// 캐릭터 채팅 응답 모델 (감정 기반 딜레이 포함)
class CharacterChatResponse {
  final String response;
  final String emotionTag;
  final int delaySec;

  const CharacterChatResponse({
    required this.response,
    required this.emotionTag,
    required this.delaySec,
  });

  factory CharacterChatResponse.fromJson(Map<String, dynamic> json) {
    return CharacterChatResponse(
      response: json['response'] as String? ?? '응답을 받지 못했습니다.',
      emotionTag: json['emotionTag'] as String? ?? '일상',
      delaySec: json['delaySec'] as int? ?? 10,
    );
  }
}

/// 캐릭터 채팅 API 서비스
class CharacterChatService {
  final _supabase = Supabase.instance.client;

  /// 메시지 전송 및 AI 응답 받기 (감정 기반 딜레이 포함)
  Future<CharacterChatResponse> sendMessage({
    required String characterId,
    required String systemPrompt,
    required List<Map<String, dynamic>> messages,
    required String userMessage,
    String? userName,
    String? userDescription,
    String? oocInstructions,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'character-chat',
        body: {
          'characterId': characterId,
          'systemPrompt': systemPrompt,
          'messages': messages,
          'userMessage': userMessage,
          if (userName != null) 'userName': userName,
          if (userDescription != null) 'userDescription': userDescription,
          if (oocInstructions != null) 'oocInstructions': oocInstructions,
        },
      );

      if (response.status != 200) {
        throw Exception('API 호출 실패: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;
      return CharacterChatResponse.fromJson(data);
    } catch (e) {
      throw Exception('메시지 전송 실패: $e');
    }
  }

  /// 대화 스레드 불러오기
  Future<List<CharacterChatMessage>> loadConversation(String characterId) async {
    try {
      final response = await _supabase.functions.invoke(
        'character-conversation-load',
        body: {'characterId': characterId},
      );

      if (response.status != 200) {
        // 인증 안 된 경우 빈 배열 반환 (게스트 모드)
        if (response.status == 401) {
          return [];
        }
        throw Exception('대화 불러오기 실패: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        return [];
      }

      final messagesList = data['messages'] as List<dynamic>? ?? [];
      return messagesList
          .map((m) => CharacterChatMessage.fromJson(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // 네트워크 에러 등의 경우 빈 배열 반환
      return [];
    }
  }

  /// 대화 스레드 저장
  Future<bool> saveConversation(
    String characterId,
    List<CharacterChatMessage> messages,
  ) async {
    try {
      // 인증 안 된 경우 저장 안 함
      if (_supabase.auth.currentSession == null) {
        return false;
      }

      final response = await _supabase.functions.invoke(
        'character-conversation-save',
        body: {
          'characterId': characterId,
          'messages': messages.map((m) => m.toJson()).toList(),
        },
      );

      if (response.status != 200) {
        return false;
      }

      final data = response.data as Map<String, dynamic>;
      return data['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
