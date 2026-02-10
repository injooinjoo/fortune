import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/character_chat_message.dart';
import 'character_chat_local_service.dart';
import '../../../../core/utils/logger.dart';

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

/// 캐릭터 채팅 API 서비스 (카카오톡 스타일: 로컬 우선 저장)
class CharacterChatService {
  final _supabase = Supabase.instance.client;
  final _localService = CharacterChatLocalService();

  /// 메시지 전송 및 AI 응답 받기 (감정 기반 딜레이 포함)
  Future<CharacterChatResponse> sendMessage({
    required String characterId,
    required String systemPrompt,
    required List<Map<String, dynamic>> messages,
    required String userMessage,
    String? userName,
    String? userDescription,
    String? oocInstructions,
    String? emojiFrequency,  // 캐릭터별 이모티콘 빈도
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
          if (emojiFrequency != null) 'emojiFrequency': emojiFrequency,
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

  /// 대화 스레드 불러오기 (로컬 우선, 서버 백업)
  Future<List<CharacterChatMessage>> loadConversation(String characterId) async {
    // 1. 먼저 로컬에서 불러오기 (카카오톡 스타일)
    final localMessages = await _localService.loadConversation(characterId);
    if (localMessages.isNotEmpty) {
      Logger.info('Loaded ${localMessages.length} messages from local storage');
      return localMessages;
    }

    // 2. 로컬에 없으면 서버에서 불러오기 시도
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
      final messages = messagesList
          .map((m) => CharacterChatMessage.fromJson(m as Map<String, dynamic>))
          .toList();

      // 서버에서 불러온 데이터를 로컬에 저장
      if (messages.isNotEmpty) {
        await _localService.saveConversation(characterId, messages);
        Logger.info('Synced ${messages.length} messages from server to local');
      }

      return messages;
    } catch (e) {
      // 네트워크 에러 등의 경우 빈 배열 반환
      Logger.warning('Failed to load from server: $e');
      return [];
    }
  }

  /// 대화 스레드 저장 (로컬 우선, 서버 백업)
  Future<bool> saveConversation(
    String characterId,
    List<CharacterChatMessage> messages,
  ) async {
    // 1. 로컬에 먼저 저장 (항상 - 카카오톡 스타일)
    final localSaved = await _localService.saveConversation(characterId, messages);
    if (!localSaved) {
      Logger.warning('Failed to save conversation locally');
    }

    // 2. 서버에 백업 시도 (인증된 경우만)
    try {
      if (_supabase.auth.currentSession == null) {
        // 인증 안 된 경우 로컬 저장 결과만 반환
        return localSaved;
      }

      final response = await _supabase.functions.invoke(
        'character-conversation-save',
        body: {
          'characterId': characterId,
          'messages': messages.map((m) => m.toJson()).toList(),
        },
      );

      if (response.status != 200) {
        Logger.warning('Failed to sync to server: ${response.status}');
        return localSaved; // 서버 실패해도 로컬 저장 성공이면 true
      }

      final data = response.data as Map<String, dynamic>;
      final serverSaved = data['success'] == true;
      if (serverSaved) {
        Logger.info('Synced conversation to server');
      }

      return localSaved || serverSaved;
    } catch (e) {
      Logger.warning('Server sync failed: $e');
      return localSaved; // 서버 실패해도 로컬 저장 성공이면 true
    }
  }

  /// 대화 삭제 (로컬 + 서버)
  Future<bool> deleteConversation(String characterId) async {
    final localDeleted = await _localService.deleteConversation(characterId);
    // 서버 삭제는 별도 API가 필요하면 추가
    return localDeleted;
  }
}
