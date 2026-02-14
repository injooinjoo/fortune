// Screenshot Test for Figma Design Sync
// Flutter 앱의 모든 주요 페이지를 스크린샷으로 캡처
//
// 실행 방법:
// flutter test integration_test/screenshot_test.dart --dart-define=SCREENSHOT_MODE=true
//
// 또는 특정 디바이스로:
// flutter test integration_test/screenshot_test.dart -d "iPhone 15 Pro"

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:fortune/presentation/providers/theme_provider.dart';

import 'test_app.dart';
import 'helpers/navigation_helpers.dart';

/// 테스트용 테마 모드 Notifier (초기값 고정)
class FixedThemeModeNotifier extends ThemeModeNotifier {
  final ThemeMode _fixedMode;

  FixedThemeModeNotifier(this._fixedMode) : super() {
    state = _fixedMode;
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    // 테스트에서는 고정 모드 유지
    state = _fixedMode;
  }
}

/// 스크린샷 저장 디렉토리
const String screenshotDir = 'integration_test/screenshots';

/// 스크린샷 모드별 디렉토리
const String lightModeDir = '$screenshotDir/light';
const String darkModeDir = '$screenshotDir/dark';

/// 캡처할 페이지 정의
class ScreenshotPage {
  final String name;
  final String route;
  final Future<void> Function(WidgetTester tester)? setup;
  final Duration waitDuration;

  const ScreenshotPage({
    required this.name,
    required this.route,
    this.setup,
    this.waitDuration = const Duration(seconds: 2),
  });
}

/// 캡처할 페이지 목록
final List<ScreenshotPage> pagesToCapture = [
  // 메인 탭 페이지
  const ScreenshotPage(
    name: '01_chat_home',
    route: '/chat',
  ),
  const ScreenshotPage(
    name: '02_insight_home',
    route: '/home',
  ),
  const ScreenshotPage(
    name: '03_fortune_list',
    route: '/fortune',
  ),
  const ScreenshotPage(
    name: '04_trend',
    route: '/trend',
  ),
  const ScreenshotPage(
    name: '05_profile',
    route: '/profile',
  ),

  // 운세 상세 페이지
  const ScreenshotPage(
    name: '10_tarot',
    route: '/fortune/tarot',
    waitDuration: Duration(seconds: 3),
  ),
  const ScreenshotPage(
    name: '11_dream',
    route: '/fortune/dream',
  ),
  const ScreenshotPage(
    name: '12_saju',
    route: '/fortune/saju',
  ),
  const ScreenshotPage(
    name: '13_compatibility',
    route: '/fortune/compatibility',
  ),
  const ScreenshotPage(
    name: '14_face_reading',
    route: '/fortune/face-reading',
  ),
  const ScreenshotPage(
    name: '15_daily',
    route: '/fortune/daily',
  ),

  // 기타 페이지
  const ScreenshotPage(
    name: '20_token_purchase',
    route: '/premium/tokens',
  ),
  const ScreenshotPage(
    name: '21_settings',
    route: '/settings',
  ),
  const ScreenshotPage(
    name: '22_fortune_history',
    route: '/history',
  ),
];

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // 테스트 앱 초기화
    await initializeTestApp(
      skipSupabase: true,
      skipHive: false,
    );

    debugPrint('📸 Screenshot test initialized');
    debugPrint('📁 Screenshots will be saved via binding.takeScreenshot()');
    debugPrint('📁 Check: build/integration_test_screenshots/');
  });

  group('📸 Screenshot Capture - Light Mode', () {
    for (final page in pagesToCapture) {
      testWidgets('Capture ${page.name}', (tester) async {
        await _captureScreenshot(
          tester: tester,
          binding: binding,
          page: page,
          isDarkMode: false,
        );
      });
    }
  });

  group('🌙 Screenshot Capture - Dark Mode', () {
    for (final page in pagesToCapture) {
      testWidgets('Capture ${page.name}', (tester) async {
        await _captureScreenshot(
          tester: tester,
          binding: binding,
          page: page,
          isDarkMode: true,
        );
      });
    }
  });

  group('📱 All Pages Overview', () {
    testWidgets('Generate page index', (tester) async {
      await _generatePageIndex();
    });
  });
}

/// 스크린샷 캡처 함수
Future<void> _captureScreenshot({
  required WidgetTester tester,
  required IntegrationTestWidgetsFlutterBinding binding,
  required ScreenshotPage page,
  required bool isDarkMode,
}) async {
  debugPrint('📸 Capturing: ${page.name} (${isDarkMode ? "dark" : "light"})');

  // 테마 오버라이드와 함께 앱 생성
  final app = ProviderScope(
    overrides: [
      themeModeProvider.overrideWith(
        (ref) => FixedThemeModeNotifier(
            isDarkMode ? ThemeMode.dark : ThemeMode.light),
      ),
    ],
    child: const TestApp(),
  );

  await tester.pumpWidget(app);
  await tester.pumpAndSettle(const Duration(seconds: 1));

  // 페이지로 네비게이션
  await _navigateToRoute(tester, page.route);

  // 추가 설정이 있으면 실행
  if (page.setup != null) {
    await page.setup!(tester);
  }

  // 페이지 로딩 대기
  await tester.pump(page.waitDuration);

  // 무한 애니메이션 처리를 위해 pump 사용
  for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }

  // 스크린샷 캡처 (binding이 자동으로 저장)
  final screenshotName = '${isDarkMode ? "dark" : "light"}_${page.name}';

  try {
    // IntegrationTestWidgetsFlutterBinding의 takeScreenshot 사용
    // 스크린샷은 테스트 완료 후 결과 디렉토리에서 확인
    await binding.takeScreenshot(screenshotName);
    debugPrint('✅ Captured: $screenshotName');
  } catch (e) {
    debugPrint('⚠️ Screenshot failed for $screenshotName: $e');
  }
}

/// 라우트로 네비게이션
Future<void> _navigateToRoute(WidgetTester tester, String route) async {
  // 바텀 네비게이션 탭 확인
  if (route == '/chat' || route == '/home') {
    await NavigationHelpers.tapBottomNavTab(tester, NavTab.home);
  } else if (route == '/fortune' || route.startsWith('/fortune/')) {
    await NavigationHelpers.tapBottomNavTab(tester, NavTab.fortune);

    // 하위 라우트면 추가 네비게이션
    if (route != '/fortune') {
      await tester.pump(const Duration(seconds: 1));
      await _tapRouteItem(tester, route);
    }
  } else if (route == '/trend') {
    await NavigationHelpers.tapBottomNavTab(tester, NavTab.trend);
  } else if (route == '/profile' || route == '/settings') {
    await NavigationHelpers.tapBottomNavTab(tester, NavTab.profile);

    if (route == '/settings') {
      await tester.pump(const Duration(milliseconds: 500));
      final settingsButton = find.byIcon(Icons.settings);
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton.first);
      }
    }
  } else if (route.startsWith('/premium')) {
    await NavigationHelpers.tapBottomNavTab(tester, NavTab.premium);
  }

  await tester.pump(const Duration(seconds: 1));
}

/// 특정 라우트 아이템 탭
Future<void> _tapRouteItem(WidgetTester tester, String route) async {
  // 라우트에 해당하는 텍스트 매핑
  final routeTextMap = {
    '/fortune/tarot': '타로',
    '/fortune/dream': '꿈해몽',
    '/fortune/saju': '사주',
    '/fortune/compatibility': '궁합',
    '/fortune/face-reading': '관상',
    '/fortune/daily': '오늘의 운세',
    '/fortune/love': '연애운',
    '/fortune/health': '건강운',
  };

  final text = routeTextMap[route];
  if (text != null) {
    final finder = find.text(text);
    if (finder.evaluate().isNotEmpty) {
      await tester.tap(finder.first);
      await tester.pump(const Duration(seconds: 1));
    }
  }
}

/// RenderObject를 사용한 대체 캡처 방법
Future<void> _captureWithRenderObject(WidgetTester tester, String path) async {
  final element = tester.element(find.byType(MaterialApp));
  final renderObject = element.renderObject;

  if (renderObject is RenderRepaintBoundary) {
    final image = await renderObject.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      final file = File(path);
      await file.writeAsBytes(byteData.buffer.asUint8List());
    }
  }
}

/// 페이지 인덱스 HTML 생성
Future<void> _generatePageIndex() async {
  final buffer = StringBuffer();
  buffer.writeln('<!DOCTYPE html>');
  buffer.writeln('<html><head>');
  buffer.writeln('<title>ZPZG Screenshots</title>');
  buffer.writeln('<style>');
  buffer.writeln(
      'body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 40px; background: #f5f5f5; }');
  buffer.writeln('h1 { color: #333; }');
  buffer.writeln(
      '.grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 20px; }');
  buffer.writeln(
      '.card { background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }');
  buffer.writeln('.card img { width: 100%; height: auto; }');
  buffer.writeln('.card .label { padding: 12px; font-weight: 500; }');
  buffer.writeln('.mode-section { margin-bottom: 40px; }');
  buffer.writeln('.mode-title { font-size: 24px; margin-bottom: 20px; }');
  buffer.writeln('</style>');
  buffer.writeln('</head><body>');
  buffer.writeln('<h1>📸 ZPZG Screenshots</h1>');
  buffer.writeln('<p>Generated: ${DateTime.now()}</p>');

  // Light Mode
  buffer.writeln('<div class="mode-section">');
  buffer.writeln('<h2 class="mode-title">☀️ Light Mode</h2>');
  buffer.writeln('<div class="grid">');
  for (final page in pagesToCapture) {
    buffer.writeln('<div class="card">');
    buffer.writeln('<img src="light/${page.name}.png" alt="${page.name}">');
    buffer.writeln('<div class="label">${page.name}</div>');
    buffer.writeln('</div>');
  }
  buffer.writeln('</div></div>');

  // Dark Mode
  buffer.writeln('<div class="mode-section">');
  buffer.writeln('<h2 class="mode-title">🌙 Dark Mode</h2>');
  buffer.writeln('<div class="grid">');
  for (final page in pagesToCapture) {
    buffer.writeln(
        '<div class="card" style="background: #1a1a1a; color: white;">');
    buffer.writeln('<img src="dark/${page.name}.png" alt="${page.name}">');
    buffer.writeln('<div class="label">${page.name}</div>');
    buffer.writeln('</div>');
  }
  buffer.writeln('</div></div>');

  buffer.writeln('</body></html>');

  final indexFile = File('$screenshotDir/index.html');
  await indexFile.writeAsString(buffer.toString());
  debugPrint('📄 Generated: $screenshotDir/index.html');
}
