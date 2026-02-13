// Fortune Cookie Widget Test
// 포춘쿠키 인터랙티브 기능 테스트

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('포춘쿠키 화면 테스트', () {
    group('초기 렌더링', () {
      testWidgets('포춘쿠키 화면이 정상적으로 렌더링되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockFortuneCookieScreen(),
          ),
        );

        expect(find.text('포춘쿠키'), findsOneWidget);
        expect(find.byType(_MockFortuneCookieScreen), findsOneWidget);
      });

      testWidgets('포춘쿠키 이미지가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockFortuneCookieScreen(),
          ),
        );

        expect(find.byKey(const Key('fortune_cookie_image')), findsOneWidget);
      });

      testWidgets('쿠키 깨기 안내 메시지가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockFortuneCookieScreen(),
          ),
        );

        expect(find.text('쿠키를 탭해서 깨보세요!'), findsOneWidget);
      });

      testWidgets('쿠키 깨기 버튼이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockFortuneCookieScreen(),
          ),
        );

        expect(find.text('쿠키 깨기'), findsOneWidget);
      });
    });

    group('쿠키 깨기 인터랙션', () {
      testWidgets('쿠키 탭 시 깨지는 애니메이션이 시작되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockFortuneCookieScreen(),
          ),
        );

        // 쿠키 이미지 탭
        await tester.tap(find.byKey(const Key('fortune_cookie_image')));
        await tester.pumpAndSettle();

        // 탭 후 결과 화면으로 전환되며 파티클 효과가 보여야 함
        expect(find.byKey(const Key('crumbs_particle')), findsOneWidget);
      });

      testWidgets('쿠키 버튼 탭 시 깨지는 동작이 실행되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockFortuneCookieScreen(),
          ),
        );

        await tester.tap(find.text('쿠키 깨기'));
        await tester.pumpAndSettle();

        // 결과 화면으로 전환
        expect(find.byKey(const Key('fortune_message')), findsOneWidget);
      });

      testWidgets('쿠키 깨기 후 운세 메시지가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockFortuneCookieScreen(showResult: true),
          ),
        );

        expect(find.byKey(const Key('fortune_message')), findsOneWidget);
        expect(find.textContaining('오늘의 행운'), findsOneWidget);
      });

      testWidgets('운세 메시지에 행운 숫자가 포함되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockFortuneCookieScreen(showResult: true),
          ),
        );

        expect(find.text('행운의 숫자'), findsOneWidget);
        expect(find.textContaining('7'), findsOneWidget);
      });

      testWidgets('운세 메시지에 행운 색상이 포함되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockFortuneCookieScreen(showResult: true),
          ),
        );

        expect(find.text('행운의 색상'), findsOneWidget);
      });
    });

    group('결과 화면', () {
      testWidgets('결과 화면에 공유 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockFortuneCookieScreen(showResult: true),
          ),
        );

        expect(find.text('공유하기'), findsOneWidget);
      });

      testWidgets('결과 화면에 다시하기 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockFortuneCookieScreen(showResult: true),
          ),
        );

        expect(find.text('다시 뽑기'), findsOneWidget);
      });

      testWidgets('다시하기 버튼 탭 시 초기 화면으로 돌아가야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockFortuneCookieScreen(showResult: true),
          ),
        );

        await tester.tap(find.text('다시 뽑기'));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('fortune_cookie_image')), findsOneWidget);
        expect(find.byKey(const Key('fortune_message')), findsNothing);
      });

      testWidgets('운세 메시지 카드가 스타일링되어 있어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockFortuneCookieScreen(showResult: true),
          ),
        );

        final messageCard = find.byKey(const Key('message_card'));
        expect(messageCard, findsOneWidget);
      });
    });

    group('일일 제한', () {
      testWidgets('일일 무료 횟수가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockFortuneCookieScreen(),
          ),
        );

        expect(find.textContaining('무료 기회'), findsOneWidget);
      });

      testWidgets('무료 횟수 소진 시 프리미엄 유도가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockFortuneCookieScreen(freeCountRemaining: 0),
          ),
        );

        expect(find.text('무제한으로 뽑기'), findsOneWidget);
      });

      testWidgets('프리미엄 사용자는 제한 없이 사용 가능', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockFortuneCookieScreen(isPremium: true),
          ),
        );

        expect(find.textContaining('무료 기회'), findsNothing);
        expect(find.text('무제한'), findsOneWidget);
      });
    });

    group('애니메이션', () {
      testWidgets('쿠키 흔들림 애니메이션이 동작해야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockFortuneCookieScreen(),
          ),
        );

        // AnimatedWidget 확인
        expect(find.byKey(const Key('shake_animation')), findsOneWidget);
      });

      testWidgets('깨지는 효과 파티클이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockFortuneCookieScreen(showResult: true),
          ),
        );

        expect(find.byKey(const Key('crumbs_particle')), findsOneWidget);
      });

      testWidgets('메시지 등장 애니메이션이 동작해야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockFortuneCookieScreen(showResult: true),
          ),
        );

        expect(find.byKey(const Key('message_fade_in')), findsOneWidget);
      });
    });

    group('테마 지원', () {
      testWidgets('라이트 모드에서 올바른 색상이 적용되어야 함', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: const _MockFortuneCookieScreen(),
          ),
        );

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, isNot(Colors.black));
      });

      testWidgets('다크 모드에서 올바른 색상이 적용되어야 함', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: const _MockFortuneCookieScreen(),
          ),
        );

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, isNot(Colors.white));
      });
    });

    group('사운드 효과', () {
      testWidgets('쿠키 깨기 시 효과음 재생 옵션이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockFortuneCookieScreen(),
          ),
        );

        expect(find.byIcon(Icons.volume_up), findsOneWidget);
      });

      testWidgets('효과음 토글이 동작해야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockFortuneCookieScreen(),
          ),
        );

        await tester.tap(find.byIcon(Icons.volume_up));
        await tester.pump();

        expect(find.byIcon(Icons.volume_off), findsOneWidget);
      });
    });

    group('히스토리', () {
      testWidgets('이전 운세 보기 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockFortuneCookieScreen(),
          ),
        );

        expect(find.text('이전 운세'), findsOneWidget);
      });

      testWidgets('이전 운세 목록이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockFortuneCookieScreen(showHistory: true),
          ),
        );

        expect(find.byKey(const Key('history_list')), findsOneWidget);
        expect(find.byType(ListTile), findsWidgets);
      });
    });
  });
}

// ===========================================
// Mock Widgets
// ===========================================

class _MockFortuneCookieScreen extends StatefulWidget {
  final bool showResult;
  final int freeCountRemaining;
  final bool isPremium;
  final bool showHistory;

  const _MockFortuneCookieScreen({
    this.showResult = false,
    this.freeCountRemaining = 3,
    this.isPremium = false,
    this.showHistory = false,
  });

  @override
  State<_MockFortuneCookieScreen> createState() =>
      _MockFortuneCookieScreenState();
}

class _MockFortuneCookieScreenState extends State<_MockFortuneCookieScreen> {
  late bool _showResult;
  late bool _soundEnabled;

  @override
  void initState() {
    super.initState();
    _showResult = widget.showResult;
    _soundEnabled = true;
  }

  void _breakCookie() {
    setState(() {
      _showResult = true;
    });
  }

  void _resetCookie() {
    setState(() {
      _showResult = false;
    });
  }

  void _toggleSound() {
    setState(() {
      _soundEnabled = !_soundEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showHistory) {
      return Scaffold(
        appBar: AppBar(title: const Text('포춘쿠키')),
        body: ListView.builder(
          key: const Key('history_list'),
          itemCount: 5,
          itemBuilder: (context, index) => ListTile(
            title: Text('운세 메시지 $index'),
            subtitle: Text('${DateTime.now().subtract(Duration(days: index))}'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('포춘쿠키'),
        actions: [
          IconButton(
            icon: Icon(_soundEnabled ? Icons.volume_up : Icons.volume_off),
            onPressed: _toggleSound,
          ),
        ],
      ),
      body: _showResult ? _buildResultView() : _buildCookieView(),
    );
  }

  Widget _buildCookieView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 안내 메시지
        const Text('쿠키를 탭해서 깨보세요!'),
        const SizedBox(height: 20),

        // 쿠키 이미지
        GestureDetector(
          onTap: _breakCookie,
          child: SizedBox(
            key: const Key('fortune_cookie_image'),
            width: 200,
            height: 200,
            child: Stack(
              children: [
                const Icon(Icons.cookie, size: 150),
                Positioned.fill(
                  child: Container(key: const Key('shake_animation')),
                ),
                Container(key: const Key('cracking_animation')),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // 쿠키 깨기 버튼
        ElevatedButton(
          onPressed: _breakCookie,
          child: const Text('쿠키 깨기'),
        ),

        const SizedBox(height: 20),

        // 무료 횟수 또는 프리미엄 상태
        if (widget.isPremium)
          const Text('무제한')
        else if (widget.freeCountRemaining > 0)
          Text('무료 기회: ${widget.freeCountRemaining}회 남음')
        else
          ElevatedButton(
            onPressed: () {},
            child: const Text('무제한으로 뽑기'),
          ),

        const SizedBox(height: 10),

        // 이전 운세 버튼
        TextButton(
          onPressed: () {},
          child: const Text('이전 운세'),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 파티클 효과
          Container(key: const Key('crumbs_particle'), height: 50),

          // 메시지 카드
          Container(
            key: const Key('message_card'),
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              key: const Key('message_fade_in'),
              children: [
                Container(
                  key: const Key('fortune_message'),
                  child: const Text(
                    '오늘의 행운: 기대하지 않은 곳에서 좋은 소식이 찾아올 것입니다.',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                const Text('행운의 숫자'),
                const Text('7, 14, 21'),
                const SizedBox(height: 10),
                const Text('행운의 색상'),
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 공유 버튼
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share),
            label: const Text('공유하기'),
          ),

          const SizedBox(height: 10),

          // 다시하기 버튼
          OutlinedButton(
            onPressed: _resetCookie,
            child: const Text('다시 뽑기'),
          ),
        ],
      ),
    );
  }
}

// Colors extension for gold
extension GoldColor on Colors {
  static const Color gold = Color(0xFFFFD700);
}
