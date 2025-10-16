/// Flutter Screen Usage Analyzer
///
/// 정적 분석 도구: lib/screens/ 폴더의 모든 화면 클래스를 분석하고
/// GoRouter, MaterialPageRoute, showDialog 등의 패턴에서 실제 사용 여부를 확인합니다.
///
/// 사용법:
///   dart run tools/screen_analyzer.dart
///   dart run tools/screen_analyzer.dart --output analysis_result.json
library;

import 'dart:io';
import 'dart:convert';

void main(List<String> arguments) async {
  print('🔍 Flutter Screen Usage Analyzer');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  final analyzer = ScreenAnalyzer();
  final result = await analyzer.analyze();

  // 분석 결과 출력
  print('\n📊 분석 결과:');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('총 스크린 클래스: ${result.totalScreens}개');
  print('사용 중인 스크린: ${result.usedScreens}개');
  print('미사용 스크린: ${result.unusedScreens}개');
  print('위젯 컴포넌트: ${result.widgetComponents}개');

  if (result.unusedScreensList.isNotEmpty) {
    print('\n❌ 미사용 스크린 목록:');
    for (var screen in result.unusedScreensList) {
      print('  - ${screen.className} (${screen.relativePath})');
    }
  }

  if (result.widgetComponentsList.isNotEmpty) {
    print('\n🧩 위젯 컴포넌트 (screens/ → widgets/ 이동 고려):');
    for (var widget in result.widgetComponentsList) {
      print('  - ${widget.className} (${widget.relativePath})');
      if (widget.usageType == 'dialog') {
        print('    → showDialog/showBottomSheet로 사용됨');
      } else if (widget.usageType == 'widget') {
        print('    → 다른 화면의 위젯으로 사용됨');
      }
    }
  }

  // JSON 파일로 저장
  final outputPath = arguments.contains('--output')
      ? arguments[arguments.indexOf('--output') + 1]
      : 'screen_analysis_result.json';

  final file = File(outputPath);
  await file.writeAsString(jsonEncode(result.toJson()));
  print('\n💾 상세 결과가 $outputPath 에 저장되었습니다.');

  print('\n💡 다음 단계:');
  if (result.unusedScreens > 0) {
    print('  1. 미사용 스크린 확인 후 ./scripts/cleanup_unused_screens.sh 실행');
    print('  2. 또는 수동으로 lib/screens_unused/로 이동');
  }
  if (result.widgetComponents > 0) {
    print('  3. 위젯 컴포넌트는 lib/core/widgets/로 이동 고려');
  }

  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}

class ScreenAnalyzer {
  final String projectRoot = Directory.current.path;
  final String screensDir = 'lib/screens';
  final List<String> routeFiles = [
    'lib/routes/route_config.dart',
    'lib/routes/routes/auth_routes.dart',
    'lib/routes/routes/fortune_routes.dart',
    'lib/routes/routes/interactive_routes.dart',
  ];

  Future<AnalysisResult> analyze() async {
    print('\n📁 스크린 파일 탐색 중...');
    final screenClasses = await _findScreenClasses();
    print('  → ${screenClasses.length}개 클래스 발견');

    print('\n📝 라우트 설정 분석 중...');
    final routeReferences = await _findRouteReferences();
    print('  → ${routeReferences.length}개 라우트 참조 발견');

    print('\n🔎 MaterialPageRoute 패턴 탐색 중...');
    final materialRouteRefs = await _findMaterialPageRouteReferences();
    print('  → ${materialRouteRefs.length}개 동적 라우트 발견');

    print('\n🎨 Dialog/BottomSheet 패턴 탐색 중...');
    final dialogRefs = await _findDialogReferences();
    print('  → ${dialogRefs.length}개 다이얼로그/시트 발견');

    print('\n🧩 위젯 사용 패턴 탐색 중...');
    final widgetRefs = await _findWidgetReferences();
    print('  → ${widgetRefs.length}개 위젯 참조 발견');

    // 사용 여부 판정
    final results = <ScreenInfo>[];
    for (var screen in screenClasses) {
      final isInRoute = routeReferences.contains(screen.className);
      final isInMaterialRoute = materialRouteRefs.contains(screen.className);
      final isDialog = dialogRefs.contains(screen.className);
      final isWidget = widgetRefs.contains(screen.className);

      String usageType = 'unused';
      if (isInRoute) {
        usageType = 'route';
      } else if (isInMaterialRoute) usageType = 'material_route';
      else if (isDialog) usageType = 'dialog';
      else if (isWidget) usageType = 'widget';

      final isUsed = usageType != 'unused';
      final isWidgetComponent = usageType == 'dialog' || usageType == 'widget';

      results.add(screen.copyWith(
        isUsed: isUsed,
        isWidgetComponent: isWidgetComponent,
        usageType: usageType,
      ));
    }

    return AnalysisResult(
      totalScreens: results.length,
      usedScreens: results.where((s) => s.isUsed).length,
      unusedScreens: results.where((s) => !s.isUsed).length,
      widgetComponents: results.where((s) => s.isWidgetComponent).length,
      screens: results,
    );
  }

  Future<List<ScreenInfo>> _findScreenClasses() async {
    final screenClasses = <ScreenInfo>[];
    final screensDirectory = Directory('$projectRoot/$screensDir');

    if (!await screensDirectory.exists()) {
      print('❌ lib/screens/ 폴더를 찾을 수 없습니다.');
      return screenClasses;
    }

    await for (var entity in screensDirectory.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = await entity.readAsString();
        final relativePath = entity.path.replaceFirst('$projectRoot/', '');

        // class XYZ extends StatelessWidget|StatefulWidget|ConsumerWidget 패턴
        final classPattern = RegExp(
          r'class\s+(\w+)\s+extends\s+(StatelessWidget|StatefulWidget|ConsumerWidget|ConsumerStatefulWidget)',
          multiLine: true,
        );

        for (var match in classPattern.allMatches(content)) {
          final className = match.group(1)!;
          final widgetType = match.group(2)!;

          screenClasses.add(ScreenInfo(
            className: className,
            relativePath: relativePath,
            widgetType: widgetType,
          ));
        }
      }
    }

    return screenClasses;
  }

  Future<Set<String>> _findRouteReferences() async {
    final references = <String>{};

    for (var routeFile in routeFiles) {
      final file = File('$projectRoot/$routeFile');
      if (!await file.exists()) continue;

      final content = await file.readAsString();

      // GoRoute builder/pageBuilder 패턴
      final builderPattern = RegExp(
        r'(?:builder|pageBuilder):\s*\([^)]*\)\s*=>\s*(?:const\s+)?(\w+)',
        multiLine: true,
      );

      for (var match in builderPattern.allMatches(content)) {
        references.add(match.group(1)!);
      }
    }

    return references;
  }

  Future<Set<String>> _findMaterialPageRouteReferences() async {
    final references = <String>{};
    final libDirectory = Directory('$projectRoot/lib');

    await for (var entity in libDirectory.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = await entity.readAsString();

        // MaterialPageRoute(builder: => SomeScreen()
        final pattern = RegExp(
          r'MaterialPageRoute\s*\([^)]*builder:\s*\([^)]*\)\s*=>\s*(?:const\s+)?(\w+)',
          multiLine: true,
        );

        for (var match in pattern.allMatches(content)) {
          references.add(match.group(1)!);
        }
      }
    }

    return references;
  }

  Future<Set<String>> _findDialogReferences() async {
    final references = <String>{};
    final libDirectory = Directory('$projectRoot/lib');

    await for (var entity in libDirectory.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = await entity.readAsString();

        // showDialog, showBottomSheet, showModalBottomSheet 패턴
        final patterns = [
          RegExp(r'showDialog\s*\([^)]*builder:\s*\([^)]*\)\s*=>\s*(?:const\s+)?(\w+)', multiLine: true),
          RegExp(r'showModalBottomSheet\s*\([^)]*builder:\s*\([^)]*\)\s*=>\s*(?:const\s+)?(\w+)', multiLine: true),
          RegExp(r'showBottomSheet\s*\([^)]*builder:\s*\([^)]*\)\s*=>\s*(?:const\s+)?(\w+)', multiLine: true),
        ];

        for (var pattern in patterns) {
          for (var match in pattern.allMatches(content)) {
            references.add(match.group(1)!);
          }
        }
      }
    }

    return references;
  }

  Future<Set<String>> _findWidgetReferences() async {
    final references = <String>{};
    final libDirectory = Directory('$projectRoot/lib');

    await for (var entity in libDirectory.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = await entity.readAsString();

        // 위젯으로 사용되는 패턴: SomeWidget(...)
        // 단, import 문이나 class 정의는 제외
        final lines = content.split('\n');
        for (var line in lines) {
          if (line.trim().startsWith('import ')) continue;
          if (line.trim().startsWith('class ')) continue;
          if (line.trim().startsWith('//')) continue;

          final widgetPattern = RegExp(r'\b(\w+)\s*\(');
          for (var match in widgetPattern.allMatches(line)) {
            final className = match.group(1)!;
            // 대문자로 시작하는 클래스명만 (위젯 네이밍 컨벤션)
            if (className[0] == className[0].toUpperCase()) {
              references.add(className);
            }
          }
        }
      }
    }

    return references;
  }
}

class ScreenInfo {
  final String className;
  final String relativePath;
  final String widgetType;
  final bool isUsed;
  final bool isWidgetComponent;
  final String usageType; // 'route', 'material_route', 'dialog', 'widget', 'unused'

  ScreenInfo({
    required this.className,
    required this.relativePath,
    required this.widgetType,
    this.isUsed = false,
    this.isWidgetComponent = false,
    this.usageType = 'unused',
  });

  ScreenInfo copyWith({
    String? className,
    String? relativePath,
    String? widgetType,
    bool? isUsed,
    bool? isWidgetComponent,
    String? usageType,
  }) {
    return ScreenInfo(
      className: className ?? this.className,
      relativePath: relativePath ?? this.relativePath,
      widgetType: widgetType ?? this.widgetType,
      isUsed: isUsed ?? this.isUsed,
      isWidgetComponent: isWidgetComponent ?? this.isWidgetComponent,
      usageType: usageType ?? this.usageType,
    );
  }

  Map<String, dynamic> toJson() => {
    'className': className,
    'relativePath': relativePath,
    'widgetType': widgetType,
    'isUsed': isUsed,
    'isWidgetComponent': isWidgetComponent,
    'usageType': usageType,
  };
}

class AnalysisResult {
  final int totalScreens;
  final int usedScreens;
  final int unusedScreens;
  final int widgetComponents;
  final List<ScreenInfo> screens;

  AnalysisResult({
    required this.totalScreens,
    required this.usedScreens,
    required this.unusedScreens,
    required this.widgetComponents,
    required this.screens,
  });

  List<ScreenInfo> get unusedScreensList =>
      screens.where((s) => !s.isUsed).toList();

  List<ScreenInfo> get widgetComponentsList =>
      screens.where((s) => s.isWidgetComponent).toList();

  Map<String, dynamic> toJson() => {
    'summary': {
      'total_screens': totalScreens,
      'used_screens': usedScreens,
      'unused_screens': unusedScreens,
      'widget_components': widgetComponents,
    },
    'screens': screens.map((s) => s.toJson()).toList(),
    'unused_list': unusedScreensList.map((s) => {
      'class': s.className,
      'file': s.relativePath,
    }).toList(),
    'widget_components_list': widgetComponentsList.map((s) => {
      'class': s.className,
      'file': s.relativePath,
      'usage_type': s.usageType,
    }).toList(),
  };
}
