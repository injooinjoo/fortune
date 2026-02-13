import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/character_chat_message.dart';
import '../../../../core/utils/logger.dart';

/// 캐릭터 채팅 로컬 저장소 서비스 (카카오톡 스타일)
/// - Hive를 사용하여 대화 내용을 기기에 저장
/// - 서버 동기화와 독립적으로 로컬에 저장
class CharacterChatLocalService {
  static const String _boxName = 'character_chats';
  static const String _metadataBoxName = 'character_chat_metadata';
  static Box<String>? _box;
  static Box<String>? _metadataBox;

  /// Hive 박스 초기화 (main.dart에서 호출)
  static Future<void> initialize() async {
    try {
      _box = await Hive.openBox<String>(_boxName);
      _metadataBox = await Hive.openBox<String>(_metadataBoxName);
      Logger.info('CharacterChatLocalService initialized');
    } catch (e) {
      Logger.error('CharacterChatLocalService initialization failed', e);
    }
  }

  /// 박스가 초기화되었는지 확인
  static bool get isInitialized => _box != null && _metadataBox != null;

  /// 대화 저장 (로컬)
  Future<bool> saveConversation(
    String characterId,
    List<CharacterChatMessage> messages,
  ) async {
    if (!isInitialized) {
      Logger.warning('CharacterChatLocalService not initialized');
      return false;
    }

    try {
      // 메시지 목록을 JSON으로 변환
      final messagesJson = messages.map((m) => m.toJson()).toList();
      final jsonString = jsonEncode(messagesJson);

      // characterId를 키로 저장
      await _box!.put(characterId, jsonString);

      // 마지막 업데이트 시간 저장
      await _metadataBox!.put(
        '${characterId}_lastUpdate',
        DateTime.now().toIso8601String(),
      );

      Logger.info(
          'Saved ${messages.length} messages for character: $characterId');
      return true;
    } catch (e) {
      Logger.error('Failed to save conversation locally', e);
      return false;
    }
  }

  /// 대화 불러오기 (로컬)
  Future<List<CharacterChatMessage>> loadConversation(
      String characterId) async {
    if (!isInitialized) {
      Logger.warning('CharacterChatLocalService not initialized');
      return [];
    }

    try {
      final jsonString = _box!.get(characterId);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> messagesJson = jsonDecode(jsonString);
      final messages = messagesJson
          .map((m) => CharacterChatMessage.fromJson(m as Map<String, dynamic>))
          .toList();

      Logger.info(
          'Loaded ${messages.length} messages for character: $characterId');
      return messages;
    } catch (e) {
      Logger.error('Failed to load conversation locally', e);
      return [];
    }
  }

  /// 대화 삭제 (로컬)
  Future<bool> deleteConversation(String characterId) async {
    if (!isInitialized) {
      return false;
    }

    try {
      await _box!.delete(characterId);
      await _metadataBox!.delete('${characterId}_lastUpdate');
      Logger.info('Deleted conversation for character: $characterId');
      return true;
    } catch (e) {
      Logger.error('Failed to delete conversation locally', e);
      return false;
    }
  }

  /// 대화 존재 여부 확인
  Future<bool> hasConversation(String characterId) async {
    if (!isInitialized) {
      return false;
    }

    return _box!.containsKey(characterId);
  }

  /// 마지막 업데이트 시간 조회
  Future<DateTime?> getLastUpdateTime(String characterId) async {
    if (!isInitialized) {
      return null;
    }

    final timeString = _metadataBox!.get('${characterId}_lastUpdate');
    if (timeString == null) {
      return null;
    }

    return DateTime.tryParse(timeString);
  }

  /// 마지막으로 읽은 시간 저장 (읽지 않음 표시용)
  Future<void> saveLastReadTimestamp(String characterId) async {
    if (!isInitialized) return;

    await _metadataBox!.put(
      '${characterId}_lastRead',
      DateTime.now().toIso8601String(),
    );
  }

  /// 마지막으로 읽은 시간 조회
  Future<DateTime?> getLastReadTimestamp(String characterId) async {
    if (!isInitialized) return null;

    final timeString = _metadataBox!.get('${characterId}_lastRead');
    if (timeString == null) return null;

    return DateTime.tryParse(timeString);
  }

  /// 모든 캐릭터 ID 목록 조회
  Future<List<String>> getAllCharacterIds() async {
    if (!isInitialized) {
      return [];
    }

    return _box!.keys.cast<String>().toList();
  }

  /// 모든 대화 삭제
  Future<bool> clearAllConversations() async {
    if (!isInitialized) {
      return false;
    }

    try {
      await _box!.clear();
      await _metadataBox!.clear();
      Logger.info('Cleared all local conversations');
      return true;
    } catch (e) {
      Logger.error('Failed to clear all conversations', e);
      return false;
    }
  }
}
