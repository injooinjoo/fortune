import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/logger.dart';
import '../core/theme/theme_keys.dart';

/// 딥링크 처리 서비스
/// 카카오톡 공유 링크, 외부 링크 등을 처리
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  /// 대기 중인 딥링크 fortuneType (앱 시작 시 처리용)
  static const String _pendingFortuneTypeKey = 'pending_deep_link_fortune_type';

  /// 초기화
  Future<void> initialize() async {
    if (kIsWeb) return;

    try {
      _appLinks = AppLinks();

      // 앱이 이미 실행 중일 때 딥링크 수신
      _linkSubscription = _appLinks.uriLinkStream.listen(
        _handleDeepLink,
        onError: (error) {
          Logger.error('딥링크 스트림 에러', error);
        },
      );

      // 앱이 종료된 상태에서 딥링크로 실행된 경우
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        Logger.info('초기 딥링크: $initialLink');
        await _handleDeepLink(initialLink);
      }

      Logger.info('DeepLinkService 초기화 완료');
    } catch (e) {
      Logger.error('DeepLinkService 초기화 실패', e);
    }
  }

  /// 딥링크 처리
  Future<void> _handleDeepLink(Uri uri) async {
    Logger.info('딥링크 수신: $uri');

    // 쿼리 파라미터 추출
    final screen = uri.queryParameters['screen'];
    final fortuneType = uri.queryParameters['fortuneType'];

    Logger.info('딥링크 파라미터 - screen: $screen, fortuneType: $fortuneType');

    // 카카오톡 공유 딥링크 처리
    if (screen == 'chat' && fortuneType != null) {
      await _navigateToChatWithFortuneType(fortuneType);
      return;
    }

    // 기타 screen 파라미터 처리
    if (screen != null) {
      _navigateTo('/$screen');
      return;
    }

    // 기본: 홈으로 이동
    _navigateTo('/chat');
  }

  /// 채팅 화면으로 이동하며 fortuneType 저장
  Future<void> _navigateToChatWithFortuneType(String fortuneType) async {
    try {
      // SharedPreferences에 fortuneType 저장 (ChatHomePage에서 읽어서 처리)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pendingFortuneTypeKey, fortuneType);
      Logger.info('대기 중인 fortuneType 저장: $fortuneType');

      // 채팅 화면으로 이동
      _navigateTo('/chat');
    } catch (e) {
      Logger.error('fortuneType 저장 실패', e);
      _navigateTo('/chat');
    }
  }

  /// 네비게이션 실행
  void _navigateTo(String route) {
    try {
      final context = appNavigatorKey.currentContext;
      if (context != null) {
        GoRouter.of(context).go(route);
        Logger.info('딥링크 네비게이션: $route');
      } else {
        Logger.warning('딥링크 네비게이션 실패: context가 null');
      }
    } catch (e) {
      Logger.error('딥링크 네비게이션 에러', e);
    }
  }

  /// 대기 중인 fortuneType 가져오기 및 삭제
  static Future<String?> consumePendingFortuneType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fortuneType = prefs.getString(_pendingFortuneTypeKey);
      if (fortuneType != null) {
        await prefs.remove(_pendingFortuneTypeKey);
        Logger.info('대기 중인 fortuneType 소비: $fortuneType');
      }
      return fortuneType;
    } catch (e) {
      Logger.error('대기 중인 fortuneType 읽기 실패', e);
      return null;
    }
  }

  /// 리소스 해제
  void dispose() {
    _linkSubscription?.cancel();
  }
}
