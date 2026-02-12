import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/utils/logger.dart';
import '../../../../services/notification_service.dart';
import '../../domain/models/ai_character.dart';
import '../../domain/models/character_chat_message.dart';
import '../default_characters.dart';

/// 점심시간 Proactive 메시지 스케줄러
///
/// 점심시간(11:30-14:00)에 캐릭터가 자발적으로 음식 사진과 함께
/// 메시지를 보내는 기능을 스케줄링합니다.
class ProactiveMessageScheduler {
  // 싱글톤 패턴
  static final ProactiveMessageScheduler _instance =
      ProactiveMessageScheduler._internal();
  factory ProactiveMessageScheduler() => _instance;
  ProactiveMessageScheduler._internal();

  // Hive box 이름 (오늘 보낸 메시지 추적)
  static const String _boxName = 'proactive_messages';
  static const String _lastScheduleDateKey = 'last_schedule_date';
  static const String _sentTodayKey = 'sent_today';

  Box<dynamic>? _box;

  /// 초기화
  Future<void> initialize() async {
    try {
      _box = await Hive.openBox(_boxName);
      Logger.info('[ProactiveMessageScheduler] 초기화 완료');
    } catch (e) {
      Logger.warning('[ProactiveMessageScheduler] 초기화 실패: $e');
    }
  }

  /// 매일 점심 메시지 스케줄 (앱 시작 시 호출)
  Future<void> scheduleDailyLunchMessages() async {
    if (_box == null) await initialize();

    final today = _getDateString(DateTime.now());
    final lastScheduleDate = _box?.get(_lastScheduleDateKey) as String?;

    // 오늘 이미 스케줄했으면 스킵
    if (lastScheduleDate == today) {
      Logger.info('[ProactiveMessageScheduler] 오늘 이미 스케줄됨');
      return;
    }

    // 오늘 보낸 메시지 초기화
    await _box?.put(_sentTodayKey, <String>[]);
    await _box?.put(_lastScheduleDateKey, today);

    // 각 캐릭터별로 스케줄
    for (final character in defaultCharacters) {
      await _scheduleForCharacter(character);
    }

    Logger.info('[ProactiveMessageScheduler] 오늘 점심 메시지 스케줄 완료');
  }

  /// 특정 캐릭터의 점심 메시지 스케줄
  Future<void> _scheduleForCharacter(AiCharacter character) async {
    final config = character.behaviorPattern.lunchProactiveConfig;
    if (config == null || !config.enabled || config.messages.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final randomMinutes = config.getRandomMinutesInWindow();
    final scheduledHour = randomMinutes ~/ 60;
    final scheduledMinute = randomMinutes % 60;

    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      scheduledHour,
      scheduledMinute,
    );

    // 이미 시간이 지났으면 스킵
    if (scheduledTime.isBefore(now)) {
      Logger.info(
          '[ProactiveMessageScheduler] ${character.name}: 오늘 시간 지남, 스킵');
      return;
    }

    // 랜덤 메시지 선택
    final message = config.getRandomMessage();
    if (message == null) return;

    // 알림 ID 생성
    final notificationId = 'lunch_${character.id}_${_getDateString(now)}';

    // 알림 스케줄
    await NotificationService.scheduleNotification(
      id: notificationId,
      title: character.name,
      body: '새 메시지가 도착했어요 💬',
      scheduledTime: scheduledTime,
      payload: 'proactive_lunch:${character.id}',
    );

    Logger.info(
        '[ProactiveMessageScheduler] ${character.name}: $scheduledHour:$scheduledMinute 스케줄됨');
  }

  /// 점심 메시지를 즉시 처리 (알림 탭 시 또는 앱 내에서 직접 호출)
  ///
  /// 반환: 생성된 메시지 (null이면 이미 보냈거나 설정 비활성화)
  CharacterChatMessage? handleLunchMessage(String characterId) {
    final character = defaultCharacters.firstWhere(
      (c) => c.id == characterId,
      orElse: () => defaultCharacters.first,
    );

    final config = character.behaviorPattern.lunchProactiveConfig;
    if (config == null || !config.enabled) return null;

    // 오늘 이미 보낸 캐릭터인지 확인
    final sentToday = _getSentTodayList();
    if (sentToday.contains(characterId)) {
      Logger.info('[ProactiveMessageScheduler] ${character.name}: 오늘 이미 전송됨');
      return null;
    }

    // 랜덤 메시지 선택
    final proactiveMessage = config.getRandomMessage();
    if (proactiveMessage == null) return null;

    // 보낸 캐릭터 기록
    _markAsSentToday(characterId);

    // 채팅 메시지 생성
    return CharacterChatMessage.characterWithImage(
      proactiveMessage.text,
      characterId,
      imageAsset: proactiveMessage.imageAsset ?? '',
    );
  }

  /// 현재 시간이 점심시간인지 확인
  bool isLunchTime() {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    // 11:30 ~ 14:00
    return currentMinutes >= (11 * 60 + 30) && currentMinutes <= (14 * 60);
  }

  /// 특정 캐릭터가 오늘 점심 메시지를 보낼 수 있는지 확인
  bool canSendLunchMessage(String characterId) {
    final character = defaultCharacters.firstWhere(
      (c) => c.id == characterId,
      orElse: () => defaultCharacters.first,
    );

    final config = character.behaviorPattern.lunchProactiveConfig;
    if (config == null || !config.enabled) return false;

    // 오늘 이미 보냈는지 확인
    final sentToday = _getSentTodayList();
    if (sentToday.contains(characterId)) return false;

    // 시간대 확인
    return isLunchTime();
  }

  /// 모든 스케줄 취소
  Future<void> cancelAllSchedules() async {
    for (final character in defaultCharacters) {
      final notificationId =
          'lunch_${character.id}_${_getDateString(DateTime.now())}';
      await NotificationService.cancelNotification(notificationId);
    }
    Logger.info('[ProactiveMessageScheduler] 모든 스케줄 취소됨');
  }

  /// 오늘 보낸 캐릭터 목록
  List<String> _getSentTodayList() {
    final list = _box?.get(_sentTodayKey);
    if (list == null) return [];
    return List<String>.from(list as List);
  }

  /// 오늘 보낸 것으로 기록
  void _markAsSentToday(String characterId) {
    final list = _getSentTodayList();
    if (!list.contains(characterId)) {
      list.add(characterId);
      _box?.put(_sentTodayKey, list);
    }
  }

  /// 날짜를 문자열로 변환 (YYYY-MM-DD)
  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 리소스 정리
  Future<void> dispose() async {
    await _box?.close();
  }
}
