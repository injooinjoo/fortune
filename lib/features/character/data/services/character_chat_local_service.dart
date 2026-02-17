import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/character_chat_message.dart';
import '../../../../core/services/user_scope_service.dart';
import '../../../../core/utils/logger.dart';

/// 캐릭터 채팅 로컬 저장소 서비스 (카카오톡 스타일)
/// - Hive를 사용하여 대화 내용을 기기에 저장
/// - 서버 동기화와 독립적으로 로컬에 저장
class CharacterChatLocalService {
  static const String _boxName = 'character_chats';
  static const String _metadataBoxName = 'character_chat_metadata';
  static const String _migrationDoneKey = 'character_chat_scope_migrated_v1';
  static Box<String>? _box;
  static Box<String>? _metadataBox;

  /// Hive 박스 초기화 (main.dart에서 호출)
  static Future<void> initialize() async {
    try {
      _box = await Hive.openBox<String>(_boxName);
      _metadataBox = await Hive.openBox<String>(_metadataBoxName);
      await _migrateLegacyKeysIfNeeded();
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
      final ownerScope = await UserScopeService.instance.getCurrentOwnerId();
      final conversationKey = _conversationKey(ownerScope, characterId);

      // 메시지 목록을 JSON으로 변환
      final messagesJson = messages.map((m) => m.toJson()).toList();
      final jsonString = jsonEncode(messagesJson);

      // ownerScope|characterId를 키로 저장
      await _box!.put(conversationKey, jsonString);

      // 마지막 업데이트 시간 저장
      await _metadataBox!.put(
        _metadataKey(ownerScope, characterId, _MetadataType.lastUpdate),
        DateTime.now().toIso8601String(),
      );

      Logger.info(
          'Saved ${messages.length} messages for character: $characterId (owner: $ownerScope)');
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
      final ownerScope = await UserScopeService.instance.getCurrentOwnerId();
      final jsonString = _box!.get(_conversationKey(ownerScope, characterId));
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> messagesJson = jsonDecode(jsonString);
      final messages = messagesJson
          .map((m) => CharacterChatMessage.fromJson(m as Map<String, dynamic>))
          .toList();

      Logger.info(
          'Loaded ${messages.length} messages for character: $characterId (owner: $ownerScope)');
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
      final ownerScope = await UserScopeService.instance.getCurrentOwnerId();
      await _box!.delete(_conversationKey(ownerScope, characterId));
      await _metadataBox!.delete(
          _metadataKey(ownerScope, characterId, _MetadataType.lastUpdate));
      await _metadataBox!.delete(
          _metadataKey(ownerScope, characterId, _MetadataType.lastRead));
      await _metadataBox!.delete(_metadataKey(
          ownerScope, characterId, _MetadataType.lastProactiveImageAt));
      await _metadataBox!.delete(_metadataKey(
          ownerScope, characterId, _MetadataType.proactiveImageDailyCount));
      Logger.info(
          'Deleted conversation for character: $characterId (owner: $ownerScope)');
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

    final ownerScope = await UserScopeService.instance.getCurrentOwnerId();
    return _box!.containsKey(_conversationKey(ownerScope, characterId));
  }

  /// 마지막 업데이트 시간 조회
  Future<DateTime?> getLastUpdateTime(String characterId) async {
    if (!isInitialized) {
      return null;
    }

    final ownerScope = await UserScopeService.instance.getCurrentOwnerId();
    final timeString = _metadataBox!
        .get(_metadataKey(ownerScope, characterId, _MetadataType.lastUpdate));
    if (timeString == null) {
      return null;
    }

    return DateTime.tryParse(timeString);
  }

  /// 마지막으로 읽은 시간 저장 (읽지 않음 표시용)
  Future<void> saveLastReadTimestamp(String characterId) async {
    if (!isInitialized) return;

    final ownerScope = await UserScopeService.instance.getCurrentOwnerId();
    await _metadataBox!.put(
      _metadataKey(ownerScope, characterId, _MetadataType.lastRead),
      DateTime.now().toIso8601String(),
    );
  }

  /// 마지막으로 읽은 시간 조회
  Future<DateTime?> getLastReadTimestamp(String characterId) async {
    if (!isInitialized) return null;

    final ownerScope = await UserScopeService.instance.getCurrentOwnerId();
    final timeString = _metadataBox!
        .get(_metadataKey(ownerScope, characterId, _MetadataType.lastRead));
    if (timeString == null) return null;

    return DateTime.tryParse(timeString);
  }

  /// 마지막 proactive 이미지 발화 시간 저장
  Future<void> saveLastProactiveImageTimestamp(
    String characterId, {
    DateTime? timestamp,
  }) async {
    if (!isInitialized) return;

    final ownerScope = await UserScopeService.instance.getCurrentOwnerId();
    final now = timestamp ?? DateTime.now();
    await _metadataBox!.put(
      _metadataKey(ownerScope, characterId, _MetadataType.lastProactiveImageAt),
      now.toIso8601String(),
    );
  }

  /// 마지막 proactive 이미지 발화 시간 조회
  Future<DateTime?> getLastProactiveImageTimestamp(String characterId) async {
    if (!isInitialized) return null;

    final ownerScope = await UserScopeService.instance.getCurrentOwnerId();
    final timeString = _metadataBox!.get(_metadataKey(
        ownerScope, characterId, _MetadataType.lastProactiveImageAt));
    if (timeString == null) return null;

    return DateTime.tryParse(timeString);
  }

  /// 오늘 발화한 proactive 이미지 수 조회
  Future<int> getTodayProactiveImageCount(String characterId) async {
    if (!isInitialized) return 0;

    final ownerScope = await UserScopeService.instance.getCurrentOwnerId();
    final countKey = _metadataKey(
        ownerScope, characterId, _MetadataType.proactiveImageDailyCount);
    final dateKey = _metadataKey(
        ownerScope, characterId, _MetadataType.lastProactiveImageAt);
    final dateValue = _metadataBox!.get(dateKey);
    if (dateValue == null) return 0;

    final lastSentDate = DateTime.tryParse(dateValue);
    if (lastSentDate == null) return 0;

    final now = DateTime.now();
    final isSameDay = lastSentDate.year == now.year &&
        lastSentDate.month == now.month &&
        lastSentDate.day == now.day;

    if (!isSameDay) return 0;

    final countRaw = _metadataBox!.get(countKey);
    if (countRaw == null) return 1;
    final parsed = int.tryParse(countRaw);
    return parsed ?? 1;
  }

  /// proactive 이미지 발화 가능 여부
  Future<bool> canSendProactiveImage(
    String characterId, {
    int maxPerDay = 1,
  }) async {
    if (maxPerDay <= 0) return false;
    final count = await getTodayProactiveImageCount(characterId);
    return count < maxPerDay;
  }

  /// proactive 이미지 발화 기록 (일자별 카운트)
  Future<void> markProactiveImageSent(
    String characterId, {
    DateTime? timestamp,
  }) async {
    if (!isInitialized) return;

    final ownerScope = await UserScopeService.instance.getCurrentOwnerId();
    final now = timestamp ?? DateTime.now();
    final dateKey = _metadataKey(
        ownerScope, characterId, _MetadataType.lastProactiveImageAt);
    final countKey = _metadataKey(
        ownerScope, characterId, _MetadataType.proactiveImageDailyCount);

    final previousDateRaw = _metadataBox!.get(dateKey);
    final previousDate =
        previousDateRaw != null ? DateTime.tryParse(previousDateRaw) : null;
    final isSameDay = previousDate != null &&
        previousDate.year == now.year &&
        previousDate.month == now.month &&
        previousDate.day == now.day;

    final currentCountRaw = _metadataBox!.get(countKey);
    final currentCount = int.tryParse(currentCountRaw ?? '') ?? 0;
    final nextCount = isSameDay ? currentCount + 1 : 1;

    await _metadataBox!.put(dateKey, now.toIso8601String());
    await _metadataBox!.put(countKey, nextCount.toString());
  }

  /// 모든 캐릭터 ID 목록 조회
  Future<List<String>> getAllCharacterIds() async {
    if (!isInitialized) {
      return [];
    }

    final ownerScope = await UserScopeService.instance.getCurrentOwnerId();
    final prefix = '$ownerScope|';
    return _box!.keys
        .cast<String>()
        .where((key) => key.startsWith(prefix))
        .map((key) => key.substring(prefix.length))
        .toList();
  }

  /// 모든 대화 삭제
  Future<bool> clearAllConversations() async {
    if (!isInitialized) {
      return false;
    }

    try {
      final ownerScope = await UserScopeService.instance.getCurrentOwnerId();
      await clearConversationsByOwner(ownerScope);
      Logger.info('Cleared all local conversations for owner: $ownerScope');
      return true;
    } catch (e) {
      Logger.error('Failed to clear all conversations', e);
      return false;
    }
  }

  /// 특정 ownerScope의 모든 대화 삭제
  Future<void> clearConversationsByOwner(String ownerScope) async {
    if (!isInitialized) return;

    final conversationPrefix = '$ownerScope|';
    final metadataPrefix = '$ownerScope|';

    final conversationKeys = _box!.keys
        .cast<String>()
        .where((key) => key.startsWith(conversationPrefix))
        .toList();
    for (final key in conversationKeys) {
      await _box!.delete(key);
    }

    final metadataKeys = _metadataBox!.keys
        .cast<String>()
        .where((key) => key.startsWith(metadataPrefix))
        .toList();
    for (final key in metadataKeys) {
      await _metadataBox!.delete(key);
    }
  }

  static Future<void> _migrateLegacyKeysIfNeeded() async {
    if (!isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final alreadyMigrated = prefs.getBool(_migrationDoneKey) ?? false;
    if (alreadyMigrated) return;

    String? currentUserId;
    try {
      currentUserId = Supabase.instance.client.auth.currentUser?.id;
    } catch (_) {
      currentUserId = null;
    }
    final lastKnownUserId =
        await UserScopeService.instance.getLastKnownUserId();
    final guestOwnerScope = await UserScopeService.instance.getGuestOwnerId();

    final targetOwnerScope =
        currentUserId != null && currentUserId == lastKnownUserId
            ? UserScopeService.ownerIdForUser(currentUserId)
            : guestOwnerScope;

    final legacyConversationKeys =
        _box!.keys.cast<String>().where((key) => !_isScopedKey(key)).toList();

    for (final legacyCharacterId in legacyConversationKeys) {
      final value = _box!.get(legacyCharacterId);
      if (value == null) continue;

      final newKey = _conversationKey(targetOwnerScope, legacyCharacterId);
      if (!_box!.containsKey(newKey)) {
        await _box!.put(newKey, value);
      }
      await _box!.delete(legacyCharacterId);
    }

    final legacyMetadataKeys = _metadataBox!.keys
        .cast<String>()
        .where((key) => !_isScopedKey(key))
        .toList();

    for (final legacyKey in legacyMetadataKeys) {
      final parsed = _parseLegacyMetadataKey(legacyKey);
      if (parsed == null) continue;

      final value = _metadataBox!.get(legacyKey);
      if (value == null) continue;

      final newKey =
          _metadataKey(targetOwnerScope, parsed.characterId, parsed.type);
      if (!_metadataBox!.containsKey(newKey)) {
        await _metadataBox!.put(newKey, value);
      }
      await _metadataBox!.delete(legacyKey);
    }

    await prefs.setBool(_migrationDoneKey, true);
    Logger.info(
        'CharacterChatLocalService legacy migration completed (owner: $targetOwnerScope)');
  }

  static bool _isScopedKey(String key) => key.contains('|');

  static String _conversationKey(String ownerScope, String characterId) {
    return '$ownerScope|$characterId';
  }

  static String _metadataKey(
      String ownerScope, String characterId, _MetadataType type) {
    return '$ownerScope|$characterId|${type.name}';
  }

  static _LegacyMetadataParsed? _parseLegacyMetadataKey(String key) {
    if (key.endsWith('_lastUpdate')) {
      return _LegacyMetadataParsed(
        characterId: key.replaceFirst('_lastUpdate', ''),
        type: _MetadataType.lastUpdate,
      );
    }

    if (key.endsWith('_lastRead')) {
      return _LegacyMetadataParsed(
        characterId: key.replaceFirst('_lastRead', ''),
        type: _MetadataType.lastRead,
      );
    }

    return null;
  }
}

enum _MetadataType {
  lastUpdate,
  lastRead,
  lastProactiveImageAt,
  proactiveImageDailyCount,
}

class _LegacyMetadataParsed {
  final String characterId;
  final _MetadataType type;

  const _LegacyMetadataParsed({
    required this.characterId,
    required this.type,
  });
}
