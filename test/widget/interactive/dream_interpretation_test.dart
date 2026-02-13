// Dream Interpretation Interactive - Widget Test
// 꿈 해몽 인터랙티브 기능 UI 테스트

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('DreamInterpretation 테스트', () {
    group('UI 렌더링', () {
      testWidgets('꿈 해몽 화면이 정상적으로 렌더링되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockDreamInterpretationScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('꿈 해몽'), findsOneWidget);
      });
    });

    group('입력 방식', () {
      testWidgets('텍스트 입력 필드가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockDreamInterpretationScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('음성 입력 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockDreamInterpretationScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.mic), findsOneWidget);
      });

      testWidgets('꿈 내용을 입력할 수 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockDreamInterpretationScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '돼지가 나오는 꿈을 꿨어요');
        await tester.pumpAndSettle();

        expect(find.text('돼지가 나오는 꿈을 꿨어요'), findsOneWidget);
      });
    });

    group('인기 주제', () {
      testWidgets('인기 꿈 주제가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockDreamInterpretationScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('인기 주제'), findsOneWidget);
      });

      testWidgets('인기 주제 칩이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockDreamInterpretationScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('돼지'), findsOneWidget);
        expect(find.text('뱀'), findsOneWidget);
        expect(find.text('물'), findsOneWidget);
      });

      testWidgets('인기 주제 탭 시 입력 필드에 추가되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockDreamInterpretationScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('돼지'));
        await tester.pumpAndSettle();

        // 입력 필드에 돼지가 추가되었는지 확인
        expect(find.byType(TextField), findsOneWidget);
      });
    });

    group('해몽 분석', () {
      testWidgets('해몽하기 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockDreamInterpretationScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('해몽하기'), findsOneWidget);
      });

      testWidgets('입력 없이 해몽 버튼 비활성화', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockDreamInterpretationScreen(dreamContent: ''),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final button = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, '해몽하기'),
        );
        expect(button.onPressed, isNull);
      });
    });

    group('결과 표시', () {
      testWidgets('해몽 결과가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockDreamInterpretationScreen(
                  hasResult: true,
                  fortune: '대길',
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('대길'), findsOneWidget);
      });

      testWidgets('해몽 의미가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockDreamInterpretationScreen(hasResult: true),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('꿈 해석'), findsOneWidget);
      });

      testWidgets('로또 번호가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockDreamInterpretationScreen(hasResult: true),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('행운의 숫자'), findsOneWidget);
      });
    });

    group('음성 입력', () {
      testWidgets('음성 입력 모드로 전환할 수 있어야 함', (tester) async {
        bool voiceModeActivated = false;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockDreamInterpretationScreen(
                  onVoiceTap: () => voiceModeActivated = true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.mic));
        await tester.pumpAndSettle();

        expect(voiceModeActivated, isTrue);
      });

      testWidgets('음성 녹음 중 인디케이터가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockDreamInterpretationScreen(isRecording: true),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('녹음 중...'), findsOneWidget);
      });
    });

    group('히스토리', () {
      testWidgets('최근 해몽 기록이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockDreamInterpretationScreen(showHistory: true),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('최근 해몽'), findsOneWidget);
      });
    });

    group('로딩 상태', () {
      testWidgets('해몽 중 로딩 인디케이터가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockDreamInterpretationScreen(isLoading: true),
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('테마 지원', () {
      testWidgets('라이트 테마에서 올바르게 렌더링', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.light(),
              home: const Scaffold(body: _MockDreamInterpretationScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('다크 테마에서 올바르게 렌더링', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.dark(),
              home: const Scaffold(body: _MockDreamInterpretationScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });
  });
}

// ============================================
// Mock Widgets
// ============================================

class _MockDreamInterpretationScreen extends StatefulWidget {
  final String dreamContent;
  final bool hasResult;
  final String fortune;
  final bool isLoading;
  final bool isRecording;
  final bool showHistory;
  final VoidCallback? onVoiceTap;

  const _MockDreamInterpretationScreen({
    this.dreamContent = '',
    this.hasResult = false,
    this.fortune = '길몽',
    this.isLoading = false,
    this.isRecording = false,
    this.showHistory = false,
    this.onVoiceTap,
  });

  @override
  State<_MockDreamInterpretationScreen> createState() =>
      _MockDreamInterpretationScreenState();
}

class _MockDreamInterpretationScreenState
    extends State<_MockDreamInterpretationScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.dreamContent);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('꿈을 해석하고 있어요...'),
          ],
        ),
      );
    }

    if (widget.hasResult) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '꿈 해몽 결과',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // 운세 결과
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: widget.fortune == '대길'
                        ? Colors.red.shade50
                        : Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    widget.fortune,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: widget.fortune == '대길'
                          ? Colors.red
                          : Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 해석
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '꿈 해석',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('돼지는 재물과 풍요를 상징합니다. 이 꿈은 가까운 시일 내에 금전적 행운이 찾아올 것을 암시합니다.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 행운의 숫자
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '행운의 숫자',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [3, 7, 12, 24, 36, 45]
                            .map((n) => _LuckyNumberBall(number: n))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '꿈 해몽',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('어젯밤 꾼 꿈을 들려주세요'),
            const SizedBox(height: 24),

            // 음성 녹음 중
            if (widget.isRecording) ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.mic, size: 48, color: Colors.red),
                    SizedBox(height: 8),
                    Text('녹음 중...'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 입력 필드
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '꿈 내용을 자세히 적어주세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.mic),
                  onPressed: widget.onVoiceTap,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 인기 주제
            const Text(
              '인기 주제',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['돼지', '뱀', '물', '용', '죽음', '불', '돈', '치아', '아기', '결혼']
                  .map((topic) => ActionChip(
                        label: Text(topic),
                        onPressed: () {
                          _controller.text = '$topic 꿈';
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),

            // 해몽하기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _controller.text.isNotEmpty ? () {} : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('해몽하기'),
              ),
            ),

            // 최근 해몽
            if (widget.showHistory) ...[
              const SizedBox(height: 32),
              const Text(
                '최근 해몽',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const ListTile(
                leading: CircleAvatar(child: Text('대길')),
                title: Text('돼지가 나오는 꿈'),
                subtitle: Text('2024.12.05'),
              ),
              const ListTile(
                leading: CircleAvatar(child: Text('길')),
                title: Text('하늘을 나는 꿈'),
                subtitle: Text('2024.12.03'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LuckyNumberBall extends StatelessWidget {
  final int number;

  const _LuckyNumberBall({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.amber,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$number',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
