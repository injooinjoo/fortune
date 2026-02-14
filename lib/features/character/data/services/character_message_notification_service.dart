import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../../core/design_system/utils/ds_haptics.dart';
import '../../../../core/utils/logger.dart';

/// 캐릭터 메시지 알림 서비스 (카카오톡 스타일)
///
/// 캐릭터로부터 메시지가 도착했을 때:
/// - 로컬 푸시 알림 표시
/// - 진동 피드백 (DSHaptics.medium)
class CharacterMessageNotificationService {
  static final CharacterMessageNotificationService _instance =
      CharacterMessageNotificationService._internal();
  factory CharacterMessageNotificationService() => _instance;
  CharacterMessageNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// 캐릭터 메시지 로컬 푸시 알림 표시
  ///
  /// [characterId] 캐릭터 고유 ID (notification ID로 사용)
  /// [characterName] 캐릭터 이름 (알림 제목)
  /// [messagePreview] 메시지 미리보기 (알림 내용)
  Future<void> showNotification({
    required String characterId,
    required String characterName,
    required String messagePreview,
    String? messageId,
    String? conversationId,
    String? roomState,
  }) async {
    try {
      // 카카오톡 DM 스타일 - 높은 중요도 + 소리 + 진동
      const androidDetails = AndroidNotificationDetails(
        'character_dm',
        '캐릭터 메시지',
        channelDescription: '캐릭터로부터의 새 메시지 알림',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        category: AndroidNotificationCategory.message,
        styleInformation: BigTextStyleInformation(''),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // 메시지 미리보기 (50자 제한)
      final preview = messagePreview.length > 50
          ? '${messagePreview.substring(0, 50)}...'
          : messagePreview;
      final encodedCharacterId = Uri.encodeComponent(characterId);
      final payload = jsonEncode({
        'type': 'character_dm',
        'character_id': characterId,
        'characterId': characterId,
        'title': characterName,
        'body': preview,
        'route': '/character/$encodedCharacterId?openCharacterChat=true',
        if (messageId != null) 'message_id': messageId,
        if (conversationId != null) 'conversation_id': conversationId,
        if (roomState != null) 'room_state': roomState,
      });

      await _notifications.show(
        characterId.hashCode,
        characterName,
        preview,
        details,
        payload: payload,
      );

      Logger.info('캐릭터 메시지 알림 표시: $characterName');
    } catch (e) {
      Logger.warning('캐릭터 메시지 알림 표시 실패 (선택적 기능): $e');
    }
  }

  /// 메시지 도착 진동 피드백 (카카오톡 느낌)
  void triggerHaptic() {
    try {
      DSHaptics.medium();
    } catch (e) {
      // 진동 실패해도 무시
    }
  }

  /// 알림 + 진동 한번에 처리
  Future<void> notifyNewMessage({
    required String characterId,
    required String characterName,
    required String messagePreview,
    String? messageId,
    String? conversationId,
    String? roomState,
  }) async {
    // 진동 먼저 (즉각적 피드백)
    triggerHaptic();

    // 푸시 알림
    await showNotification(
      characterId: characterId,
      characterName: characterName,
      messagePreview: messagePreview,
      messageId: messageId,
      conversationId: conversationId,
      roomState: roomState,
    );
  }
}
