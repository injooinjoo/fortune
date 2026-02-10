import 'dart:async';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_sync_item.dart';
import '../utils/logger.dart';
import 'sync_queue_local_service.dart';

/// 통합 채팅 동기화 서비스
/// - Debounced 자동 저장 (3초)
/// - 오프라인 큐 관리
/// - 연결 복구 시 자동 동기화
/// - 게스트 사용자 마이그레이션 지원
class ChatSyncService {
  static final ChatSyncService _instance = ChatSyncService._internal();
  factory ChatSyncService() => _instance;
  ChatSyncService._internal();

  static ChatSyncService get instance => _instance;

  // Dependencies
  final SyncQueueLocalService _queueService = SyncQueueLocalService();
  final Connectivity _connectivity = Connectivity();
  final SupabaseClient _supabase = Supabase.instance.client;
  static const _uuid = Uuid();

  // State
  StreamSubscription? _connectivitySubscription;
  final Map<String, Timer> _debounceTimers = {};
  bool _isSyncing = false;
  bool _isInitialized = false;

  // Configuration
  static const Duration _debounceDelay = Duration(seconds: 3);
  static const Duration _minSyncInterval = Duration(seconds: 30);
  static const int _maxRetries = 3;
  DateTime? _lastSyncTime;

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await SyncQueueLocalService.initialize();
      _setupConnectivityMonitor();
      _isInitialized = true;
      Logger.info('[ChatSyncService] 초기화 완료');

      // 앱 시작 시 대기 중인 항목 처리
      await processQueue();
    } catch (e) {
      Logger.error('[ChatSyncService] 초기화 실패', e);
    }
  }

  /// 연결 상태 모니터링 설정
  void _setupConnectivityMonitor() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        if (!results.contains(ConnectivityResult.none)) {
          Logger.info('[ChatSyncService] 연결 복구됨 - 대기열 처리 시작');
          processQueue();
        }
      },
    );
  }

  /// 동기화 항목 큐에 추가 (Debounced)
  ///
  /// [chatId]: 캐릭터 ID 또는 'general'
  /// [chatType]: 'character' 또는 'general'
  /// [messages]: 메시지 목록 (JSON 형식)
  Future<void> queueForSync({
    required String chatId,
    required String chatType,
    required List<Map<String, dynamic>> messages,
  }) async {
    if (!_isInitialized) {
      Logger.warning('[ChatSyncService] 초기화되지 않음');
      return;
    }

    // 기존 타이머 취소
    final timerKey = '${chatType}_$chatId';
    _debounceTimers[timerKey]?.cancel();

    // 새 타이머 설정 (debounce)
    _debounceTimers[timerKey] = Timer(_debounceDelay, () async {
      await _performQueueAndSync(
        chatId: chatId,
        chatType: chatType,
        messages: messages,
      );
    });

    Logger.info('[ChatSyncService] 동기화 예약됨: $timerKey (${_debounceDelay.inSeconds}초 후)');
  }

  /// 즉시 동기화 (앱 백그라운드 진입 시)
  Future<void> syncImmediate({String? chatId, String? chatType}) async {
    // 모든 debounce 타이머 취소하고 즉시 실행
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();

    await processQueue();
  }

  /// 큐에 추가하고 동기화 시도
  Future<void> _performQueueAndSync({
    required String chatId,
    required String chatType,
    required List<Map<String, dynamic>> messages,
  }) async {
    // 현재 사용자 ID 가져오기
    final userId = _supabase.auth.currentUser?.id;

    // 동기화 항목 생성
    final item = ChatSyncItem(
      id: _uuid.v4(),
      chatId: chatId,
      chatType: chatType,
      messages: messages,
      createdAt: DateTime.now(),
      userId: userId,
      status: SyncStatus.pending,
    );

    // 로컬 큐에 저장
    await _queueService.enqueue(item);

    // 동기화 시도
    await _syncItem(item);
  }

  /// 대기열 전체 처리
  Future<void> processQueue() async {
    if (_isSyncing) {
      Logger.info('[ChatSyncService] 이미 동기화 중');
      return;
    }

    // 최소 동기화 간격 체크
    if (_lastSyncTime != null) {
      final elapsed = DateTime.now().difference(_lastSyncTime!);
      if (elapsed < _minSyncInterval) {
        Logger.info('[ChatSyncService] 최소 동기화 간격 미달');
        return;
      }
    }

    // 연결 상태 확인
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      Logger.info('[ChatSyncService] 오프라인 상태 - 나중에 동기화');
      return;
    }

    _isSyncing = true;
    _lastSyncTime = DateTime.now();

    try {
      final pendingItems = await _queueService.getPending();
      Logger.info('[ChatSyncService] 대기 항목 ${pendingItems.length}개 처리 시작');

      for (final item in pendingItems) {
        await _syncItem(item);
      }

      // 완료된 항목 정리
      await _queueService.clearCompleted();
    } finally {
      _isSyncing = false;
    }
  }

  /// 단일 항목 동기화
  Future<bool> _syncItem(ChatSyncItem item) async {
    // 인증 안 된 경우 로컬에만 저장 (나중에 마이그레이션)
    if (_supabase.auth.currentUser == null) {
      Logger.info('[ChatSyncService] 미인증 사용자 - 로컬에만 저장');
      return true;
    }

    // 재시도 가능 여부 확인
    if (!item.canRetry) {
      Logger.warning('[ChatSyncService] 최대 재시도 횟수 초과: ${item.chatId}');
      return false;
    }

    try {
      await _queueService.updateStatus(
        item.chatType,
        item.chatId,
        SyncStatus.syncing,
      );

      // Edge Function 호출
      final functionName = item.chatType == 'character'
          ? 'character-conversation-save'
          : 'chat-conversation-save';

      final response = await _supabase.functions.invoke(
        functionName,
        body: item.chatType == 'character'
            ? {
                'characterId': item.chatId,
                'messages': item.messages,
              }
            : {
                'messages': item.messages,
              },
      );

      if (response.status == 200) {
        await _queueService.remove(item.chatType, item.chatId);
        Logger.info('[ChatSyncService] 동기화 성공: ${item.chatId}');
        return true;
      } else {
        throw Exception('HTTP ${response.status}: ${response.data}');
      }
    } catch (e) {
      Logger.warning('[ChatSyncService] 동기화 실패: ${item.chatId} - $e');

      // 재시도 가능하면 실패 상태로 업데이트
      await _queueService.updateStatus(
        item.chatType,
        item.chatId,
        SyncStatus.failed,
        errorMessage: e.toString(),
      );

      return false;
    }
  }

  /// 게스트 데이터 마이그레이션 (로그인 후 호출)
  Future<bool> migrateGuestData(String userId) async {
    if (!_isInitialized) return false;

    try {
      // 게스트 항목에 userId 할당
      await _queueService.assignUserId(userId);

      // 동기화 시도
      await processQueue();

      Logger.info('[ChatSyncService] 게스트 데이터 마이그레이션 완료');
      return true;
    } catch (e) {
      Logger.error('[ChatSyncService] 게스트 마이그레이션 실패', e);
      return false;
    }
  }

  /// 대기 중인 항목 개수
  Future<int> getPendingCount() async {
    return await _queueService.getPendingCount();
  }

  /// 리소스 정리
  void dispose() {
    _connectivitySubscription?.cancel();
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
  }

  /// Exponential backoff 계산
  int _calculateBackoffMs(int attemptCount) {
    // 5초, 10초, 20초, 최대 60초
    return min(5000 * pow(2, attemptCount - 1).toInt(), 60000);
  }
}
