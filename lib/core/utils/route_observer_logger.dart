// Route Observer Logger
//
// 런타임에 실제로 방문된 화면을 추적하고 visited_screens.json에 기록합니다.
// 개발 모드(kDebugMode)에서만 동작하며, 실제 사용 패턴 분석에 활용됩니다.
library;

import 'package:universal_io/io.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class RouteObserverLogger extends RouteObserver<PageRoute<dynamic>> {
  static final RouteObserverLogger _instance = RouteObserverLogger._internal();
  factory RouteObserverLogger() => _instance;
  RouteObserverLogger._internal();

  final Map<String, VisitInfo> _visits = {};
  String? _logFilePath;  // Will be initialized with app directory

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logRouteChange('PUSH', route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logRouteChange('POP', route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _logRouteChange('REPLACE', newRoute);
    }
  }

  void _logRouteChange(String action, Route<dynamic> route) {
    if (!kDebugMode) return; // 디버그 모드에서만 동작

    final routeName = _getRouteName(route);
    final screenName = _extractScreenName(route);

    if (screenName != null) {
      // 방문 정보 업데이트
      if (_visits.containsKey(screenName)) {
        _visits[screenName] = _visits[screenName]!.incrementVisit();
      } else {
        _visits[screenName] = VisitInfo(
          screenName: screenName,
          routeName: routeName ?? 'unknown',
          firstVisit: DateTime.now(),
          lastVisit: DateTime.now(),
          visitCount: 1,
        );
      }

      // 파일에 즉시 저장
      _saveToFile();

      debugPrint('🔍 [$action] Screen: $screenName, Route: $routeName');
    }
  }

  String? _getRouteName(Route<dynamic> route) {
    if (route.settings.name != null) {
      return route.settings.name;
    }

    // GoRouter의 경우 settings.arguments에서 추출 시도
    if (route.settings.arguments is Map) {
      final args = route.settings.arguments as Map;
      if (args.containsKey('name')) {
        return args['name'] as String?;
      }
    }

    return null;
  }

  String? _extractScreenName(Route<dynamic> route) {
    // Route의 타입 정보에서 화면 이름 추출
    final routeType = route.runtimeType.toString();

    // MaterialPageRoute<T> 패턴에서 추출
    if (routeType.contains('MaterialPageRoute')) {
      // route.settings.name이 있으면 우선 사용
      if (route.settings.name != null && route.settings.name!.isNotEmpty) {
        return route.settings.name!.replaceAll('/', '');
      }
    }

    // Widget 이름 직접 추출 시도 (PageRoute의 builder 결과)
    if (route is PageRoute) {
      try {
        // Route의 문자열 표현에서 위젯 이름 추출 시도
        final str = route.toString();
        final match = RegExp(r'PageRoute<[^>]*>\(([^)]+)\)').firstMatch(str);
        if (match != null) {
          return match.group(1);
        }
      } catch (e) {
        // 추출 실패 시 무시
      }
    }

    return route.settings.name;
  }

  Future<void> _ensureLogFilePath() async {
    if (kIsWeb) return; // Web does not support getApplicationDocumentsDirectory

    if (_logFilePath != null) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      _logFilePath = '${directory.path}/visited_screens.json';
    } catch (e) {
      debugPrint('⚠️ RouteObserver: 경로 초기화 실패 - $e');
    }
  }

  void _saveToFile() async {
    try {
      await _ensureLogFilePath();
      if (_logFilePath == null) return;

      final file = File(_logFilePath!);
      final data = {
        'last_updated': DateTime.now().toIso8601String(),
        'total_screens': _visits.length,
        'total_visits': _visits.values.fold(0, (sum, v) => sum + v.visitCount),
        'visits': _visits.values.map((v) => v.toJson()).toList(),
      };

      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('⚠️ RouteObserver: 파일 저장 실패 - $e');
    }
  }

  /// 현재까지 기록된 방문 정보 반환
  Map<String, VisitInfo> getVisits() => Map.unmodifiable(_visits);

  /// 방문 기록 초기화
  void clearVisits() {
    _visits.clear();
    _saveToFile();
  }

  /// 특정 화면의 방문 정보 조회
  VisitInfo? getVisitInfo(String screenName) => _visits[screenName];

  /// 방문 횟수로 정렬된 화면 목록
  List<VisitInfo> getMostVisitedScreens({int limit = 10}) {
    final sorted = _visits.values.toList()
      ..sort((a, b) => b.visitCount.compareTo(a.visitCount));
    return sorted.take(limit).toList();
  }

  /// 기존 로그 파일에서 데이터 로드
  Future<void> loadFromFile() async {
    try {
      await _ensureLogFilePath();
      if (_logFilePath == null) return;

      final file = File(_logFilePath!);
      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content) as Map<String, dynamic>;

        if (data.containsKey('visits')) {
          _visits.clear();
          for (var visitJson in data['visits'] as List) {
            final visit = VisitInfo.fromJson(visitJson as Map<String, dynamic>);
            _visits[visit.screenName] = visit;
          }
        }

        debugPrint('✅ RouteObserver: 기존 로그 로드 완료 (${_visits.length}개 화면)');
      }
    } catch (e) {
      debugPrint('⚠️ RouteObserver: 로그 로드 실패 - $e');
    }
  }
}

class VisitInfo {
  final String screenName;
  final String routeName;
  final DateTime firstVisit;
  final DateTime lastVisit;
  final int visitCount;

  VisitInfo({
    required this.screenName,
    required this.routeName,
    required this.firstVisit,
    required this.lastVisit,
    required this.visitCount,
  });

  VisitInfo incrementVisit() {
    return VisitInfo(
      screenName: screenName,
      routeName: routeName,
      firstVisit: firstVisit,
      lastVisit: DateTime.now(),
      visitCount: visitCount + 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'screen_name': screenName,
    'route_name': routeName,
    'first_visit': firstVisit.toIso8601String(),
    'last_visit': lastVisit.toIso8601String(),
    'visit_count': visitCount,
  };

  factory VisitInfo.fromJson(Map<String, dynamic> json) => VisitInfo(
    screenName: json['screen_name'] as String,
    routeName: json['route_name'] as String,
    firstVisit: DateTime.parse(json['first_visit'] as String),
    lastVisit: DateTime.parse(json['last_visit'] as String),
    visitCount: json['visit_count'] as int,
  );
}

/// RouteObserver 사용 예시:
///
/// 1. main.dart에서 MaterialApp에 추가:
/// ```dart
/// MaterialApp.router(
///   routerConfig: router,
///   navigatorObservers: kDebugMode ? [RouteObserverLogger()] : [],
/// )
/// ```
///
/// 2. 앱 시작 시 기존 로그 로드 (선택사항):
/// ```dart
/// if (kDebugMode) {
///   await RouteObserverLogger().loadFromFile();
/// }
/// ```
///
/// 3. 방문 통계 조회:
/// ```dart
/// final mostVisited = RouteObserverLogger().getMostVisitedScreens();
/// debugPrint('Most visited: ${mostVisited.first.screenName}');
/// ```
