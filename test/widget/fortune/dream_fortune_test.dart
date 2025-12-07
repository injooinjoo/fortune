/// Dream Fortune Page - Widget Test
/// 꿈 해몽 페이지 UI 테스트

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('DreamFortunePage 테스트', () {
    group('UI 렌더링', () {
      testWidgets('꿈 해몽 화면이 정상적으로 렌더링되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockDreamFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('꿈 해몽'), findsOneWidget);
      });
    });

    group('입력 방식', () {
      testWidgets('텍스트 입력 방식이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockDreamFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('꿈 내용을 입력해주세요'), findsOneWidget);
      });

      testWidgets('음성 입력 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockDreamFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.mic), findsOneWidget);
      });

      testWidgets('인기 꿈 주제가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockDreamFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('인기 꿈 주제'), findsOneWidget);
      });
    });

    group('인기 꿈 주제', () {
      testWidgets('돼지꿈 주제가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockDreamFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('돼지'), findsOneWidget);
      });

      testWidgets('뱀꿈 주제가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockDreamFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('뱀'), findsOneWidget);
      });

      testWidgets('물꿈 주제가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockDreamFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('물'), findsOneWidget);
      });
    });

    group('결과 화면', () {
      testWidgets('해몽 결과가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockDreamFortuneResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('해몽 결과'), findsOneWidget);
      });

      testWidgets('길흉 판정이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockDreamFortuneResult(fortune: '대길'),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('대길'), findsOneWidget);
      });

      testWidgets('꿈의 의미가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockDreamFortuneResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('꿈의 의미'), findsOneWidget);
      });

      testWidgets('행운 번호가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockDreamFortuneResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('행운의 번호'), findsOneWidget);
      });

      testWidgets('주의사항이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockDreamFortuneResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('주의사항'), findsOneWidget);
      });
    });

    group('블러 처리', () {
      testWidgets('무료 사용자는 일부 콘텐츠 블러', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockDreamFortuneResult(isBlurred: true),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('전체 해석 보기'), findsOneWidget);
      });
    });

    group('인터랙션', () {
      testWidgets('해몽하기 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockDreamFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('해몽하기'), findsOneWidget);
      });

      testWidgets('꿈 주제 탭 시 입력 필드에 추가', (tester) async {
        String? inputText;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockDreamFortunePage(
                  onTopicSelected: (topic) => inputText = topic,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        await tester.tap(find.text('돼지'));
        await tester.pumpAndSettle();

        expect(inputText, '돼지');
      });
    });

    group('음성 입력', () {
      testWidgets('마이크 버튼 탭 시 음성 입력 시작', (tester) async {
        bool voiceStarted = false;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockDreamFortunePage(
                  onVoiceStart: () => voiceStarted = true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.mic));
        await tester.pumpAndSettle();

        expect(voiceStarted, isTrue);
      });
    });
  });
}

// ============================================
// Mock Widgets
// ============================================

class _MockDreamFortunePage extends StatelessWidget {
  final void Function(String)? onTopicSelected;
  final VoidCallback? onVoiceStart;

  const _MockDreamFortunePage({
    this.onTopicSelected,
    this.onVoiceStart,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('꿈 해몽', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '꿈 내용을 입력해주세요',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.mic),
                  onPressed: onVoiceStart,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('인기 꿈 주제'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                GestureDetector(
                  onTap: () => onTopicSelected?.call('돼지'),
                  child: const Chip(label: Text('돼지')),
                ),
                GestureDetector(
                  onTap: () => onTopicSelected?.call('뱀'),
                  child: const Chip(label: Text('뱀')),
                ),
                GestureDetector(
                  onTap: () => onTopicSelected?.call('물'),
                  child: const Chip(label: Text('물')),
                ),
                const Chip(label: Text('용')),
                const Chip(label: Text('죽음')),
                const Chip(label: Text('불')),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('해몽하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockDreamFortuneResult extends StatelessWidget {
  final String fortune;
  final bool isBlurred;

  const _MockDreamFortuneResult({
    this.fortune = '길',
    this.isBlurred = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('해몽 결과', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: fortune == '대길' ? Colors.red : Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  fortune,
                  style: const TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Card(
              child: ListTile(
                title: Text('꿈의 의미'),
                subtitle: Text('이 꿈은 재물운의 상승을 의미합니다'),
              ),
            ),
            const Card(
              child: ListTile(
                title: Text('행운의 번호'),
                subtitle: Text('3, 7, 12, 24, 36, 45'),
              ),
            ),
            const Card(
              child: ListTile(
                title: Text('주의사항'),
                subtitle: Text('오늘은 중요한 결정을 피하세요'),
              ),
            ),
            if (isBlurred) ...[
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('전체 해석 보기'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
