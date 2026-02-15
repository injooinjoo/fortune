import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_sync_item.dart';
import '../utils/logger.dart';

/// 채팅 동기화 큐 로컬 저장소 서비스
/// Hive를 사용하여 동기화 대기 항목을 로컬에 저장
class SyncQueueLocalService {
  static const String _boxName = 'chat_sync_queue';
  static const String _migrationDoneKey = 'chat_sync_queue_owner_migrated_v1';
  static Box<String>? _box;

  /// Hive 박스 초기화 (main.dart에서 호출)
  static Future<void> initialize() async {
    try {
      _box = await Hive.openBox<String>(_boxName);
      await _migrateLegacyKeysIfNeeded();
      Logger.info('[SyncQueueLocalService] 초기화 완료');
    } catch (e) {
      Logger.error('[SyncQueueLocalService] 초기화 실패', e);
    }
  }

  /// 박스가 초기화되었는지 확인
  static bool get isInitialized => _box != null;

  /// 동기화 항목 추가/업데이트 (upsert)
  Future<bool> enqueue(ChatSyncItem item) async {
    if (!isInitialized) {
      Logger.warning('[SyncQueueLocalService] 초기화되지 않음');
      return false;
    }

    try {
      // ownerId + chatType + chatId를 키로 사용하여 동일 스코프 채팅은 덮어쓰기
      final key = _key(item.ownerId, item.chatType, item.chatId);
      await _box!.put(key, item.toJsonString());
      Logger.info('[SyncQueueLocalService] 큐에 추가: $key');
      return true;
    } catch (e) {
      Logger.error('[SyncQueueLocalService] 큐 추가 실패', e);
      return false;
    }
  }

  /// 대기 중인 모든 항목 조회
  Future<List<ChatSyncItem>> getPending({String? ownerId}) async {
    if (!isInitialized) {
      Logger.warning('[SyncQueueLocalService] 초기화되지 않음');
      return [];
    }

    try {
      final items = <ChatSyncItem>[];
      for (final key in _box!.keys) {
        final jsonString = _box!.get(key);
        if (jsonString != null) {
          try {
            final item = ChatSyncItem.fromJsonString(jsonString);
            final statusMatched = item.status == SyncStatus.pending ||
                item.status == SyncStatus.failed;
            final ownerMatched = ownerId == null || item.ownerId == ownerId;
            if (statusMatched && ownerMatched) {
              items.add(item);
            }
          } catch (e) {
            Logger.warning('[SyncQueueLocalService] 항목 파싱 실패: $key');
          }
        }
      }

      // 생성 시간순 정렬
      items.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      Logger.info('[SyncQueueLocalService] 대기 항목 ${items.length}개 조회');
      return items;
    } catch (e) {
      Logger.error('[SyncQueueLocalService] 대기 항목 조회 실패', e);
      return [];
    }
  }

  /// 항목 상태 업데이트
  Future<bool> updateStatus(
    String ownerId,
    String chatType,
    String chatId,
    SyncStatus status, {
    String? errorMessage,
  }) async {
    if (!isInitialized) return false;

    try {
      final key = _key(ownerId, chatType, chatId);
      final jsonString = _box!.get(key);

      if (jsonString == null) return false;

      final item = ChatSyncItem.fromJsonString(jsonString);
      final updatedItem = item.copyWith(
        status: status,
        lastAttemptAt: DateTime.now(),
        attemptCount: item.attemptCount + 1,
        errorMessage: errorMessage,
      );

      await _box!.put(key, updatedItem.toJsonString());
      Logger.info('[SyncQueueLocalService] 상태 업데이트: $key → ${status.name}');
      return true;
    } catch (e) {
      Logger.error('[SyncQueueLocalService] 상태 업데이트 실패', e);
      return false;
    }
  }

  /// owner 기반 동기화 완료된 항목 제거
  Future<bool> remove(String ownerId, String chatType, String chatId) async {
    if (!isInitialized) return false;

    try {
      final key = _key(ownerId, chatType, chatId);
      await _box!.delete(key);
      Logger.info('[SyncQueueLocalService] 항목 제거: $key');
      return true;
    } catch (e) {
      Logger.error('[SyncQueueLocalService] 항목 제거 실패', e);
      return false;
    }
  }

  /// 완료된 항목 모두 삭제
  Future<int> clearCompleted({String? ownerId}) async {
    if (!isInitialized) return 0;

    try {
      int count = 0;
      final keysToDelete = <String>[];

      for (final key in _box!.keys) {
        final jsonString = _box!.get(key);
        if (jsonString != null) {
          try {
            final item = ChatSyncItem.fromJsonString(jsonString);
            if (item.status == SyncStatus.completed &&
                (ownerId == null || item.ownerId == ownerId)) {
              keysToDelete.add(key as String);
            }
          } catch (_) {}
        }
      }

      for (final key in keysToDelete) {
        await _box!.delete(key);
        count++;
      }

      Logger.info('[SyncQueueLocalService] 완료 항목 $count개 삭제');
      return count;
    } catch (e) {
      Logger.error('[SyncQueueLocalService] 완료 항목 삭제 실패', e);
      return 0;
    }
  }

  /// 대기 중인 항목 개수
  Future<int> getPendingCount() async {
    final pending = await getPending();
    return pending.length;
  }

  /// 특정 채팅의 동기화 항목 조회
  Future<ChatSyncItem?> getItem(
      String ownerId, String chatType, String chatId) async {
    if (!isInitialized) return null;

    try {
      final key = _key(ownerId, chatType, chatId);
      final jsonString = _box!.get(key);
      if (jsonString == null) return null;
      return ChatSyncItem.fromJsonString(jsonString);
    } catch (e) {
      Logger.error('[SyncQueueLocalService] 항목 조회 실패', e);
      return null;
    }
  }

  /// 게스트 사용자 항목 조회 (userId가 null인 것들)
  Future<List<ChatSyncItem>> getGuestItems({String? guestOwnerId}) async {
    if (!isInitialized) return [];

    try {
      final items = <ChatSyncItem>[];
      for (final key in _box!.keys) {
        final jsonString = _box!.get(key);
        if (jsonString != null) {
          try {
            final item = ChatSyncItem.fromJsonString(jsonString);
            if (item.isGuest &&
                (guestOwnerId == null || item.ownerId == guestOwnerId)) {
              items.add(item);
            }
          } catch (_) {}
        }
      }
      return items;
    } catch (e) {
      Logger.error('[SyncQueueLocalService] 게스트 항목 조회 실패', e);
      return [];
    }
  }

  /// 게스트 항목에 userId 할당 (로그인 후 마이그레이션용)
  Future<bool> assignOwner({
    required String fromOwnerId,
    required String toOwnerId,
  }) async {
    if (!isInitialized) return false;

    try {
      final guestItems = await getGuestItems(guestOwnerId: fromOwnerId);
      for (final item in guestItems) {
        final updatedItem = item.copyWith(
          ownerId: toOwnerId,
          status: SyncStatus.pending, // 다시 동기화 대기
        );
        final oldKey = _key(item.ownerId, item.chatType, item.chatId);
        final newKey = _key(toOwnerId, item.chatType, item.chatId);
        await _box!.put(newKey, updatedItem.toJsonString());
        await _box!.delete(oldKey);
      }
      Logger.info(
          '[SyncQueueLocalService] ${guestItems.length}개 항목 owner 변경: $fromOwnerId → $toOwnerId');
      return true;
    } catch (e) {
      Logger.error('[SyncQueueLocalService] owner 변경 실패', e);
      return false;
    }
  }

  /// 모든 항목 삭제
  Future<bool> clearAll() async {
    if (!isInitialized) return false;

    try {
      await _box!.clear();
      Logger.info('[SyncQueueLocalService] 모든 항목 삭제');
      return true;
    } catch (e) {
      Logger.error('[SyncQueueLocalService] 전체 삭제 실패', e);
      return false;
    }
  }

  static String _key(String ownerId, String chatType, String chatId) {
    return '$ownerId|$chatType|$chatId';
  }

  static Future<void> _migrateLegacyKeysIfNeeded() async {
    if (!isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final alreadyMigrated = prefs.getBool(_migrationDoneKey) ?? false;
    if (alreadyMigrated) return;

    final keys = _box!.keys.cast<String>().toList();
    for (final key in keys) {
      if (key.contains('|')) continue;

      final jsonString = _box!.get(key);
      if (jsonString == null) continue;

      try {
        final item = ChatSyncItem.fromJsonString(jsonString);
        final newKey = _key(item.ownerId, item.chatType, item.chatId);
        if (!_box!.containsKey(newKey)) {
          await _box!.put(newKey, item.toJsonString());
        }
        await _box!.delete(key);
      } catch (_) {
        // malformed legacy row는 삭제
        await _box!.delete(key);
      }
    }

    await prefs.setBool(_migrationDoneKey, true);
    Logger.info('[SyncQueueLocalService] 레거시 키 마이그레이션 완료');
  }
}
