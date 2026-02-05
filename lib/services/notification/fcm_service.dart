import 'dart:async';
import 'dart:convert';
import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/logger.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/theme_keys.dart';

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
}

// 알림 설정 모델
class NotificationSettings {
  final bool enabled;
  final bool dailyFortune;
  final bool tokenAlert;
  final bool promotion;
  final String? dailyFortuneTime; // HH:mm 형식

  NotificationSettings({
    this.enabled = true,
    this.dailyFortune = true,
    this.tokenAlert = true,
    this.promotion = true,
    this.dailyFortuneTime = '07:00'});

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'dailyFortune': dailyFortune,
    'tokenAlert': tokenAlert,
    'promotion': promotion,
    'dailyFortuneTime': null};

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: json['enabled'],
      dailyFortune: json['dailyFortune'],
      tokenAlert: json['tokenAlert'],
      promotion: json['promotion'],
        dailyFortuneTime: json['dailyFortuneTime'] ?? '07:00');
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

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final ApiClient _apiClient = ApiClient();

  String? _fcmToken;
  StreamController<RemoteMessage>? _messageStreamController;
  NotificationSettings _settings = NotificationSettings();

  // 알림 스트림
  Stream<RemoteMessage> get onMessage => _messageStreamController!.stream;

  // FCM 토큰 가져오기
  String? get fcmToken => _fcmToken;

  // 알림 설정 가져오기
  NotificationSettings get settings => _settings;

  // 초기화
  Future<void> initialize() async {
    try {
      // Firebase 초기화
      // TODO: Firebase options not available
      // await Firebase.initializeApp(
      //   options: DefaultFirebaseOptions.currentPlatform)
      // );
      
      // 백그라운드 메시지 핸들러 설정
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // 메시지 스트림 초기화
      _messageStreamController = StreamController<RemoteMessage>.broadcast();
      
      // 로컬 알림 초기화
      await _initializeLocalNotifications();
      
      // 알림 권한 요청
      await _requestPermission();
      
      // FCM 토큰 획득
      await _getToken();
      
      // 알림 설정 로드
      await _loadSettings();
      
      // 메시지 리스너 설정
      _setupMessageListeners();
      
      // 토픽 구독
      await _subscribeToTopics();
      
      Logger.info('FCM 서비스 초기화 완료');
    } catch (e) {
      Logger.error('FCM 초기화 실패', e);
    }
  }
  
  // 로컬 알림 초기화
  Future<void> _initializeLocalNotifications() async {
    // Android 초기화 설정
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS 초기화 설정
    final iosSettings = const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // onDidReceiveLocalNotification is deprecated
      // iOS 9 이하에서 포그라운드 알림 처리
    );
    
    // 초기화
    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings);
    
    await _localNotifications.initialize(
      initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped);
    
    // Android 알림 채널 생성
    await _createNotificationChannels();
  }
  
  // 알림 채널 생성 (Android)
  Future<void> _createNotificationChannels() async {
    if (!kIsWeb && Platform.isAndroid) {
      // 일일 운세 채널
      const dailyChannel = AndroidNotificationChannel(
        NotificationChannels.dailyFortune,
        '일일 운세',
        description: '매일 아침 오늘의 운세를 알려드립니다',
        importance: Importance.high);
      
      // 복주머니 알림 채널
      const tokenChannel = AndroidNotificationChannel(
        NotificationChannels.tokenAlert,
        '복주머니 알림',
        description: '복주머니 부족 및 충전 관련 알림',
        importance: Importance.high);
      
      // 프로모션 채널
      const promotionChannel = AndroidNotificationChannel(
        NotificationChannels.promotion,
        '이벤트 및 프로모션',
        description: '특별 이벤트와 할인 정보',
        importance: Importance.defaultImportance);
      
      // 시스템 채널
      const systemChannel = AndroidNotificationChannel(
        NotificationChannels.system,
        '시스템 알림',
        description: '중요한 시스템 공지사항',
        importance: Importance.high);
      
      final plugin = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      await plugin?.createNotificationChannel(dailyChannel);
      await plugin?.createNotificationChannel(tokenChannel);
      await plugin?.createNotificationChannel(promotionChannel);
      await plugin?.createNotificationChannel(systemChannel);
    }
  }
  
  // 권한 요청
  Future<void> _requestPermission() async {
    final settings = await fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true
    );

    Logger.info('상태: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      Logger.info('사용자가 알림을 허용했습니다');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      Logger.info('사용자가 임시 알림을 허용했습니다');
    } else {
      Logger.info('사용자가 알림을 거부했습니다');
    }
  }

  // FCM 토큰 획득
  Future<void> _getToken() async {
    try {
      _fcmToken = await fcm.getToken();
      Logger.info('Supabase initialized successfully');

      if (_fcmToken != null) {
        // 서버에 토큰 전송
        await _sendTokenToServer(_fcmToken!);
      }

      // 토큰 갱신 리스너
      fcm.onTokenRefresh.listen((newToken) async {
        Logger.info('Supabase initialized successfully');
        _fcmToken = newToken;
        await _sendTokenToServer(newToken);
      });
    } catch (e) {
      Logger.error('FCM 토큰 획득 실패', e);
    }
  }
  
  // 서버에 FCM 토큰 전송
  Future<void> _sendTokenToServer(String token) async {
    try {
      await _apiClient.post('/user/fcm-token', data: {
        'token': token,
        'platform': kIsWeb ? 'web' : (!kIsWeb && Platform.isIOS ? 'ios' : 'android'),
        'deviceInfo': {
          'os': kIsWeb ? 'web' : (!kIsWeb ? Platform.operatingSystem : 'unknown'),
          'version': kIsWeb ? 'web' : (!kIsWeb ? Platform.operatingSystemVersion : 'unknown')}
      });
      
      Logger.info('FCM 토큰 서버 전송 완료');
    } catch (e) {
      Logger.error('FCM 토큰 서버 전송 실패', e);
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
    
    if (notification != null) {
      // 포그라운드에서 로컬 알림 표시
      _showLocalNotification(
        title: notification.title ?? '',
        body: notification.body ?? '',
        payload: jsonEncode(data),
        channelId: data['channel'] ?? NotificationChannels.system
      );
    }
  }
  
  // 로컬 알림 표시
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
    String channelId = NotificationChannels.system}) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true);
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true);
    
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails);
    
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload
    );
  }
  
  // 알림 탭 처리
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _handleNotificationTap(data);
      } catch (e) {
        Logger.error('알림 페이로드 파싱 실패', e);
      }
    }
  }
  
  // 알림 탭 액션 처리
  void _handleNotificationTap(Map<String, dynamic> data) {
    final type = data['type'];
    final route = data['route'] as String?;

    // 알림 오픈 로깅
    _logNotificationOpen(data);

    // route가 명시되어 있으면 해당 경로로 이동
    if (route != null && route.isNotEmpty) {
      _navigateTo(route);
      return;
    }

    // type 기반 네비게이션 (하위 호환성)
    switch (type) {
      case 'daily_fortune':
        _navigateTo('/home');
        break;
      case 'score_alert':
        _navigateTo('/home');
        break;
      case 'token_alert':
      case 'token_purchase':
        _navigateTo('/token-purchase');
        break;
      case 'winback':
        _navigateTo('/home');
        break;
      case 'promotion':
        final promoId = data['promo_id'] as String?;
        if (promoId != null) {
          _navigateTo('/promotion/$promoId');
        } else {
          _navigateTo('/home');
        }
        break;
      case 'streak':
        _navigateTo('/home');
        break;
      case 'event':
        final eventRoute = data['event_route'] as String?;
        _navigateTo(eventRoute ?? '/home');
        break;
      default:
        Logger.info('알림 탭: 타입 $type, 홈으로 이동');
        _navigateTo('/home');
    }
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
          jsonDecode(settingsJson) as Map<String, dynamic>
        );
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
      await prefs.setString('notification_settings', jsonEncode(settings.toJson()));
      
      // 서버에 전송
      await _apiClient.put('/user/notification-settings', data: settings.toJson());
      
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
      channelId: NotificationChannels.system
    );
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
      payload: jsonEncode({
        'type': 'daily_fortune'})
    );
  }
  
  // 리소스 정리
  void dispose() {
    _messageStreamController?.close();
  }
}
