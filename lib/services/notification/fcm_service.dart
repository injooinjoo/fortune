import 'dart:async';
import 'dart:convert';
import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/logger.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/theme_keys.dart';
import '../../features/character/data/services/active_character_chat_registry.dart';

// 백그라운드 메시지 핸들러 (반드시 톱레벨 함수여야 함)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  Logger.info('수신: ${message.messageId}');
}

// 알림 채널 정보
class NotificationChannels {
  static const String dailyFortune = 'daily_fortune';
  static const String tokenAlert = 'token_alert';
  static const String promotion = 'promotion';
  static const String system = 'system';
  static const String characterDm = 'character_dm';
}

// 알림 설정 모델
class NotificationSettings {
  final bool enabled;
  final bool dailyFortune;
  final bool tokenAlert;
  final bool promotion;
  final bool characterDm;
  final String? dailyFortuneTime; // HH:mm 형식

  const NotificationSettings(
      {this.enabled = true,
      this.dailyFortune = true,
      this.tokenAlert = true,
      this.promotion = true,
      this.characterDm = true,
      this.dailyFortuneTime = '07:00'});

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'dailyFortune': dailyFortune,
        'tokenAlert': tokenAlert,
        'promotion': promotion,
        'characterDm': characterDm,
        'dailyFortuneTime': dailyFortuneTime
      };

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
        enabled: json['enabled'] as bool? ?? true,
        dailyFortune: json['dailyFortune'] as bool? ?? true,
        tokenAlert: json['tokenAlert'] as bool? ?? true,
        promotion: json['promotion'] as bool? ?? true,
        characterDm: json['characterDm'] as bool? ?? true,
        dailyFortuneTime: json['dailyFortuneTime'] ?? '07:00');
  }

  NotificationSettings copyWith({
    bool? enabled,
    bool? dailyFortune,
    bool? tokenAlert,
    bool? promotion,
    bool? characterDm,
    String? dailyFortuneTime,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      dailyFortune: dailyFortune ?? this.dailyFortune,
      tokenAlert: tokenAlert ?? this.tokenAlert,
      promotion: promotion ?? this.promotion,
      characterDm: characterDm ?? this.characterDm,
      dailyFortuneTime: dailyFortuneTime ?? this.dailyFortuneTime,
    );
  }
}

class FCMService {
  static FCMService? _instance;
  factory FCMService() {
    _instance ??= FCMService._internal();
    return _instance!;
  }
  FCMService._internal();

  FirebaseMessaging? _fcm;
  FirebaseMessaging get fcm {
    _fcm ??= FirebaseMessaging.instance;
    return _fcm!;
  }

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final ApiClient _apiClient = ApiClient();

  String? _fcmToken;
  StreamController<RemoteMessage>? _messageStreamController;
  NotificationSettings _settings = const NotificationSettings();
  bool _isInitialized = false;

  // 알림 스트림
  Stream<RemoteMessage> get onMessage => _messageStreamController!.stream;

  // FCM 토큰 가져오기
  String? get fcmToken => _fcmToken;

  // 알림 설정 가져오기
  NotificationSettings get settings => _settings;

  // 초기화
  Future<void> initialize({bool requestPermissions = false}) async {
    if (_isInitialized) {
      if (requestPermissions) {
        await requestPermissionsIfNeeded();
      }
      await syncCurrentDevice();
      return;
    }

    try {
      // Firebase 초기화
      // TODO: Firebase options not available
      // await Firebase.initializeApp(
      //   options: DefaultFirebaseOptions.currentPlatform)
      // );

      // 백그라운드 메시지 핸들러 설정
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // 메시지 스트림 초기화
      _messageStreamController = StreamController<RemoteMessage>.broadcast();

      // 로컬 알림 초기화
      await _initializeLocalNotifications();

      if (requestPermissions) {
        await requestPermissionsIfNeeded();
      }

      // FCM 토큰 획득
      await _getToken();

      // 알림 설정 로드
      await _loadSettings();

      // 로그인된 세션이 있으면 현재 디바이스를 Supabase push 대상과 정렬
      await syncCurrentDevice();

      // 메시지 리스너 설정
      _setupMessageListeners();

      // 토픽 구독
      await _subscribeToTopics();

      _isInitialized = true;
      Logger.info('FCM 서비스 초기화 완료');
    } catch (e) {
      Logger.error('FCM 초기화 실패', e);
    }
  }

  // 로컬 알림 초기화
  Future<void> _initializeLocalNotifications() async {
    // Android 초기화 설정
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 초기화 설정
    final iosSettings = const DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      // onDidReceiveLocalNotification is deprecated
      // iOS 9 이하에서 포그라운드 알림 처리
    );

    // 초기화
    final initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped);

    // Android 알림 채널 생성
    await _createNotificationChannels();
  }

  // 알림 채널 생성 (Android)
  Future<void> _createNotificationChannels() async {
    if (!kIsWeb && Platform.isAndroid) {
      // 일일 운세 채널
      const dailyChannel = AndroidNotificationChannel(
          NotificationChannels.dailyFortune, '일일 운세',
          description: '매일 아침 오늘의 운세를 알려드립니다', importance: Importance.high);

      // 토큰 알림 채널
      const tokenChannel = AndroidNotificationChannel(
          NotificationChannels.tokenAlert, '토큰 알림',
          description: '토큰 부족 및 충전 관련 알림', importance: Importance.high);

      // 프로모션 채널
      const promotionChannel = AndroidNotificationChannel(
          NotificationChannels.promotion, '이벤트 및 프로모션',
          description: '특별 이벤트와 할인 정보',
          importance: Importance.defaultImportance);

      // 시스템 채널
      const systemChannel = AndroidNotificationChannel(
          NotificationChannels.system, '시스템 알림',
          description: '중요한 시스템 공지사항', importance: Importance.high);

      // 🆕 캐릭터 DM 채널 (카카오톡 스타일)
      const characterDmChannel = AndroidNotificationChannel(
          'character_dm', '캐릭터 메시지',
          description: '캐릭터로부터의 새 메시지 알림',
          importance: Importance.high,
          playSound: true,
          enableVibration: true);

      final plugin = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      await plugin?.createNotificationChannel(dailyChannel);
      await plugin?.createNotificationChannel(tokenChannel);
      await plugin?.createNotificationChannel(promotionChannel);
      await plugin?.createNotificationChannel(systemChannel);
      await plugin?.createNotificationChannel(characterDmChannel);
    }
  }

  // 권한 요청
  Future<bool> requestPermissionsIfNeeded() async {
    if (!kIsWeb && Platform.isIOS) {
      final iosPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    final settings = await fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);

    Logger.info('상태: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      Logger.info('사용자가 알림을 허용했습니다');
      return true;
    }

    if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      Logger.info('사용자가 임시 알림을 허용했습니다');
      return true;
    }

    Logger.info('사용자가 알림을 거부했습니다');
    return false;
  }

  // FCM 토큰 획득
  Future<void> _getToken() async {
    try {
      _fcmToken = await fcm.getToken();
      Logger.info('FCM 토큰 획득 완료');

      fcm.onTokenRefresh.listen((newToken) async {
        _fcmToken = newToken;
        Logger.info('FCM 토큰 갱신 완료');
        await syncCurrentDevice();
      });
    } catch (e) {
      Logger.error('FCM 토큰 획득 실패', e);
    }
  }

  String _currentPlatform() {
    if (kIsWeb) {
      return 'web';
    }
    if (!kIsWeb && Platform.isIOS) {
      return 'ios';
    }
    return 'android';
  }

  Map<String, dynamic> _buildDeviceInfo() {
    return {
      'os': kIsWeb ? 'web' : Platform.operatingSystem,
      'version': kIsWeb ? 'web' : Platform.operatingSystemVersion,
    };
  }

  Future<void> syncCurrentDevice() async {
    try {
      if (_fcmToken == null || _fcmToken!.isEmpty) {
        Logger.info('FCM 토큰이 없어 디바이스 동기화를 건너뜁니다');
        return;
      }

      final supabase = Supabase.instance.client;
      if (supabase.auth.currentSession == null) {
        Logger.info('로그인 세션이 없어 디바이스 동기화를 건너뜁니다');
        return;
      }

      await supabase.functions.invoke(
        'sync-notification-device',
        body: {
          'token': _fcmToken,
          'platform': _currentPlatform(),
          'deviceInfo': _buildDeviceInfo(),
          'preferences': _settings.toJson(),
        },
      );

      Logger.info('FCM 디바이스 동기화 완료');
    } catch (e) {
      Logger.error('FCM 디바이스 동기화 실패', e);
    }
  }

  Future<void> deactivateCurrentDevice() async {
    try {
      if (_fcmToken == null || _fcmToken!.isEmpty) {
        return;
      }

      final supabase = Supabase.instance.client;
      if (supabase.auth.currentSession == null) {
        return;
      }

      await supabase.functions.invoke(
        'sync-notification-device',
        body: {
          'token': _fcmToken,
          'platform': _currentPlatform(),
          'deviceInfo': _buildDeviceInfo(),
          'deactivateToken': true,
        },
      );

      Logger.info('FCM 디바이스 비활성화 완료');
    } catch (e) {
      Logger.warning('FCM 디바이스 비활성화 실패: $e');
    }
  }

  // 메시지 리스너 설정
  void _setupMessageListeners() {
    // 포그라운드 메시지
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Logger.info('수신: ${message.messageId}');
      _handleMessage(message);
      _messageStreamController?.add(message);
    });

    // 백그라운드에서 알림 탭
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Logger.info('열림: ${message.messageId}');
      _handleNotificationTap(message.data);
    });

    // 앱이 종료된 상태에서 알림으로 실행
    _checkInitialMessage();
  }

  // 초기 메시지 확인
  Future<void> _checkInitialMessage() async {
    final message = await fcm.getInitialMessage();
    if (message != null) {
      Logger.info('실행: ${message.messageId}');
      _handleNotificationTap(message.data);
    }
  }

  // 메시지 처리
  void _handleMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;
    final characterId =
        data['character_id']?.toString() ?? data['characterId']?.toString();
    final isActiveCharacterChat = data['type'] == 'character_dm' &&
        ActiveCharacterChatRegistry.isActive(characterId);

    if (isActiveCharacterChat) {
      Logger.info('활성 채팅방의 캐릭터 DM 알림은 포그라운드에서 억제합니다');
      return;
    }

    final title = notification?.title ?? data['title']?.toString() ?? '';
    final body = notification?.body ?? data['body']?.toString() ?? '';

    if (title.isNotEmpty || body.isNotEmpty) {
      _showLocalNotification(
        title: title,
        body: body,
        payload: jsonEncode(data),
        channelId: data['channel']?.toString() ?? NotificationChannels.system,
      );
    }
  }

  // 로컬 알림 표시
  Future<void> _showLocalNotification(
      {required String title,
      required String body,
      String? payload,
      String channelId = NotificationChannels.system}) async {
    final androidDetails = AndroidNotificationDetails(channelId, channelId,
        importance: Importance.high, priority: Priority.high, showWhen: true);

    const iosDetails = DarwinNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);

    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000, title, body, details,
        payload: payload);
  }

  // 알림 탭 처리
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload == null) {
      return;
    }

    final payload = response.payload!;

    // 기존 문자열 payload: character_chat:characterId
    if (payload.startsWith('character_chat:')) {
      final characterId = payload.split(':').last;
      _handleNotificationTap({
        'type': 'character_dm',
        'character_id': characterId,
      });
      Logger.info('캐릭터 채팅 알림 탭: $characterId');
      return;
    }

    // JSON payload 처리
    final data = _tryDecodePayload(payload);
    if (data != null) {
      _handleNotificationTap(data);
    } else {
      Logger.error('알림 페이로드 파싱 실패', Exception('invalid payload'));
    }
  }

  Map<String, dynamic>? _tryDecodePayload(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // 알림 탭 액션 처리
  void _handleNotificationTap(Map<String, dynamic> data) {
    final type = data['type'];
    final route = data['route'] as String?;
    final characterId =
        data['character_id']?.toString() ?? data['characterId']?.toString();

    // 알림 오픈 로깅
    _logNotificationOpen(data);

    // route가 명시되어 있으면 해당 경로로 이동
    if (route != null && route.isNotEmpty) {
      _navigateTo(route);
      return;
    }

    if (type == 'character_dm' || type == 'character_follow_up') {
      if (characterId != null && characterId.isNotEmpty) {
        _navigateTo(_buildCharacterRoute(characterId));
        return;
      }
    }

    // type 기반 네비게이션 (하위 호환성)
    switch (type) {
      case 'daily_fortune':
        _navigateTo('/chat');
        break;
      case 'score_alert':
        _navigateTo('/chat');
        break;
      case 'token_alert':
      case 'token_purchase':
        _navigateTo('/chat');
        break;
      case 'winback':
        _navigateTo('/chat');
        break;
      case 'promotion':
        final promoId = data['promo_id'] as String?;
        if (promoId != null) {
          _navigateTo('/promotion/$promoId');
        } else {
          _navigateTo('/chat');
        }
        break;
      case 'streak':
        _navigateTo('/chat');
        break;
      case 'event':
        final eventRoute = data['event_route'] as String?;
        _navigateTo(eventRoute ?? '/chat');
        break;
      default:
        Logger.info('알림 탭: 타입 $type, 홈으로 이동');
        _navigateTo('/chat');
    }
  }

  String _buildCharacterRoute(String characterId) {
    final encodedCharacterId = Uri.encodeComponent(characterId);
    return '/character/$encodedCharacterId?openCharacterChat=true';
  }

  // 네비게이션 실행
  void _navigateTo(String route) {
    try {
      final context = appNavigatorKey.currentContext;
      if (context != null) {
        GoRouter.of(context).go(route);
        Logger.info('알림 딥링크 이동: $route');
      } else {
        Logger.warning('네비게이션 컨텍스트 없음, 경로: $route');
      }
    } catch (e) {
      Logger.error('알림 딥링크 이동 실패', e);
    }
  }

  // 알림 오픈 로깅 (분석용)
  Future<void> _logNotificationOpen(Map<String, dynamic> data) async {
    try {
      final notificationId = data['notification_id'] as String?;
      final notificationType = data['type'] as String?;

      await _apiClient.post('/notification/opened', data: {
        'notification_id': notificationId,
        'notification_type': notificationType,
        'opened_at': DateTime.now().toIso8601String(),
      });

      Logger.info('알림 오픈 로깅 완료: $notificationType');
    } catch (e) {
      // 로깅 실패는 무시 (사용자 경험에 영향 없음)
      Logger.warning('알림 오픈 로깅 실패: $e');
    }
  }

  // 토픽 구독
  Future<void> _subscribeToTopics() async {
    try {
      // 전체 사용자 토픽
      await fcm.subscribeToTopic('all_users');

      // 플랫폼별 토픽
      if (kIsWeb) {
        await fcm.subscribeToTopic('web_users');
      } else if (!kIsWeb && Platform.isIOS) {
        await fcm.subscribeToTopic('ios_users');
      } else if (!kIsWeb && Platform.isAndroid) {
        await fcm.subscribeToTopic('android_users');
      }

      // 설정에 따른 토픽 구독
      if (_settings.dailyFortune) {
        await fcm.subscribeToTopic('daily_fortune');
      }
      if (_settings.promotion) {
        await fcm.subscribeToTopic('promotions');
      }

      Logger.info('FCM 토픽 구독 완료');
    } catch (e) {
      Logger.error('토픽 구독 실패', e);
    }
  }

  // 알림 설정 로드
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('notification_settings');

      if (settingsJson != null) {
        _settings = NotificationSettings.fromJson(
            jsonDecode(settingsJson) as Map<String, dynamic>);
      }
    } catch (e) {
      Logger.error('알림 설정 로드 실패', e);
    }
  }

  // 알림 설정 저장
  Future<void> updateSettings(NotificationSettings settings) async {
    try {
      _settings = settings;

      // 로컬 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'notification_settings', jsonEncode(settings.toJson()));

      // 로그인 세션이 있으면 Supabase source of truth에 즉시 반영
      await syncCurrentDevice();

      // 토픽 재구독
      await _updateTopicSubscriptions();

      Logger.info('알림 설정 업데이트 완료');
    } catch (e) {
      Logger.error('알림 설정 업데이트 실패', e);
    }
  }

  // 토픽 구독 업데이트
  Future<void> _updateTopicSubscriptions() async {
    if (_settings.dailyFortune) {
      await fcm.subscribeToTopic('daily_fortune');
    } else {
      await fcm.unsubscribeFromTopic('daily_fortune');
    }

    if (_settings.promotion) {
      await fcm.subscribeToTopic('promotions');
    } else {
      await fcm.unsubscribeFromTopic('promotions');
    }
  }

  // 테스트 알림 전송
  Future<void> sendTestNotification() async {
    await _showLocalNotification(
        title: '테스트 알림',
        body: 'Fortune 앱의 테스트 알림입니다.',
        channelId: NotificationChannels.system);
  }

  // 일일 운세 알림 예약
  Future<void> scheduleDailyFortuneNotification() async {
    if (!_settings.dailyFortune || _settings.dailyFortuneTime == null) {
      return;
    }
    // 매일 반복 알림 설정
    await _localNotifications.periodicallyShow(
        0, // 알림 ID
        '오늘의 운세가 도착했습니다 🔮',
        '오늘은 어떤 일이 일어날까요? 지금 확인해보세요!',
        RepeatInterval.daily,
        const NotificationDetails(
            android: AndroidNotificationDetails(
                NotificationChannels.dailyFortune,
                NotificationChannels.dailyFortune,
                importance: Importance.high,
                priority: Priority.high),
            iOS: DarwinNotificationDetails()),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: jsonEncode({'type': 'daily_fortune'}));
  }

  // 리소스 정리
  void dispose() {
    _messageStreamController?.close();
  }
}
