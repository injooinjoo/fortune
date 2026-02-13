import 'package:hive_flutter/hive_flutter.dart';
import '../models/chat_sync_item.dart';
import '../utils/logger.dart';

/// 채팅 동기화 큐 로컬 저장소 서비스
/// Hive를 사용하여 동기화 대기 항목을 로컬에 저장
class SyncQueueLocalService {
  static const String _boxName = 'chat_sync_queue';
  static Box<String>? _box;

  /// Hive 박스 초기화 (main.dart에서 호출)
  static Future<void> initialize() async {
    try {
      _box = await Hive.openBox<String>(_boxName);
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
      // chatId + chatType을 키로 사용하여 동일 채팅은 덮어쓰기
      final key = '${item.chatType}_${item.chatId}';
      await _box!.put(key, item.toJsonString());
      Logger.info('[SyncQueueLocalService] 큐에 추가: $key');
      return true;
    } catch (e) {
      Logger.error('[SyncQueueLocalService] 큐 추가 실패', e);
      return false;
    }
  }

  /// 대기 중인 모든 항목 조회
  Future<List<ChatSyncItem>> getPending() async {
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
            if (item.status == SyncStatus.pending ||
                item.status == SyncStatus.failed) {
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
    String chatType,
    String chatId,
    SyncStatus status, {
    String? errorMessage,
  }) async {
    if (!isInitialized) return false;

    try {
      final key = '${chatType}_$chatId';
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

  /// 동기화 완료된 항목 제거
  Future<bool> remove(String chatType, String chatId) async {
    if (!isInitialized) return false;

    try {
      final key = '${chatType}_$chatId';
      await _box!.delete(key);
      Logger.info('[SyncQueueLocalService] 항목 제거: $key');
      return true;
    } catch (e) {
      Logger.error('[SyncQueueLocalService] 항목 제거 실패', e);
      return false;
    }
  }

  /// 완료된 항목 모두 삭제
  Future<int> clearCompleted() async {
    if (!isInitialized) return 0;

    try {
      int count = 0;
      final keysToDelete = <String>[];

      for (final key in _box!.keys) {
        final jsonString = _box!.get(key);
        if (jsonString != null) {
          try {
            final item = ChatSyncItem.fromJsonString(jsonString);
            if (item.status == SyncStatus.completed) {
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
  Future<ChatSyncItem?> getItem(String chatType, String chatId) async {
    if (!isInitialized) return null;

    try {
      final key = '${chatType}_$chatId';
      final jsonString = _box!.get(key);
      if (jsonString == null) return null;
      return ChatSyncItem.fromJsonString(jsonString);
    } catch (e) {
      Logger.error('[SyncQueueLocalService] 항목 조회 실패', e);
      return null;
    }
  }

  /// 게스트 사용자 항목 조회 (userId가 null인 것들)
  Future<List<ChatSyncItem>> getGuestItems() async {
    if (!isInitialized) return [];

    try {
      final items = <ChatSyncItem>[];
      for (final key in _box!.keys) {
        final jsonString = _box!.get(key);
        if (jsonString != null) {
          try {
            final item = ChatSyncItem.fromJsonString(jsonString);
            if (item.isGuest) {
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
  Future<bool> assignUserId(String userId) async {
    if (!isInitialized) return false;

    try {
      final guestItems = await getGuestItems();
      for (final item in guestItems) {
        final updatedItem = item.copyWith(
          userId: userId,
          status: SyncStatus.pending, // 다시 동기화 대기
        );
        final key = '${item.chatType}_${item.chatId}';
        await _box!.put(key, updatedItem.toJsonString());
      }
      Logger.info(
          '[SyncQueueLocalService] ${guestItems.length}개 게스트 항목에 userId 할당');
      return true;
    } catch (e) {
      Logger.error('[SyncQueueLocalService] userId 할당 실패', e);
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
}
