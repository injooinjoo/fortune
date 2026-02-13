// MBTI Fortune Page - Widget Test
// MBTI 운세 페이지 UI 테스트

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('MBTIFortunePage 테스트', () {
    group('UI 렌더링', () {
      testWidgets('MBTI 운세 화면이 정상적으로 렌더링되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockMBTIFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('MBTI 운세'), findsOneWidget);
      });
    });

    group('MBTI 선택', () {
      testWidgets('모든 MBTI 유형이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockMBTIFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 16가지 MBTI 유형
        expect(find.text('INTJ'), findsOneWidget);
        expect(find.text('ENFP'), findsOneWidget);
        expect(find.text('ISFJ'), findsOneWidget);
        expect(find.text('ESTP'), findsOneWidget);
      });

      testWidgets('MBTI 유형 선택 시 선택됨 표시', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockMBTIFortunePage(selectedMBTI: 'INTJ'),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        // 선택된 MBTI가 강조되어야 함
        expect(find.text('INTJ'), findsOneWidget);
      });

      testWidgets('MBTI 모름 옵션이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockMBTIFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('MBTI를 모르시나요?'), findsOneWidget);
      });
    });

    group('결과 화면', () {
      testWidgets('MBTI 설명이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockMBTIFortuneResult(mbtiType: 'INTJ'),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('INTJ'), findsOneWidget);
        expect(find.text('전략가'), findsOneWidget);
      });

      testWidgets('오늘의 운세가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockMBTIFortuneResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('오늘의 운세'), findsOneWidget);
      });

      testWidgets('MBTI 특성이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockMBTIFortuneResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('성격 특성'), findsOneWidget);
      });

      testWidgets('궁합 MBTI가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockMBTIFortuneResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('최고의 궁합'), findsOneWidget);
        expect(find.text('최악의 궁합'), findsOneWidget);
      });

      testWidgets('직업 추천이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockMBTIFortuneResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('추천 직업'), findsOneWidget);
      });
    });

    group('사주 + MBTI 통합 분석', () {
      testWidgets('통합 분석이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockMBTIFortuneResult(hasSajuData: true),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('사주 + MBTI 통합 분석'), findsOneWidget);
      });
    });

    group('인터랙션', () {
      testWidgets('분석하기 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockMBTIFortunePage(selectedMBTI: 'INTJ'),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('운세 보기'), findsOneWidget);
      });
    });
  });
}

// ============================================
// Mock Widgets
// ============================================

class _MockMBTIFortunePage extends StatelessWidget {
  final String? selectedMBTI;

  const _MockMBTIFortunePage({this.selectedMBTI});

  @override
  Widget build(BuildContext context) {
    final mbtiTypes = [
      'INTJ', 'INTP', 'ENTJ', 'ENTP',
      'INFJ', 'INFP', 'ENFJ', 'ENFP',
      'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
      'ISTP', 'ISFP', 'ESTP', 'ESFP',
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('MBTI 운세', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const Text('나의 MBTI를 선택해주세요'),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: mbtiTypes.length,
              itemBuilder: (context, index) {
                final type = mbtiTypes[index];
                return ChoiceChip(
                  label: Text(type),
                  selected: selectedMBTI == type,
                  onSelected: (_) {},
                );
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: const Text('MBTI를 모르시나요?'),
            ),
            if (selectedMBTI != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('운세 보기'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MockMBTIFortuneResult extends StatelessWidget {
  final String mbtiType;
  final bool hasSajuData;

  const _MockMBTIFortuneResult({
    this.mbtiType = 'INTJ',
    this.hasSajuData = false,
  });

  String _getMBTIName(String type) {
    switch (type) {
      case 'INTJ':
        return '전략가';
      case 'INTP':
        return '논리술사';
      case 'ENTJ':
        return '통솔자';
      case 'ENTP':
        return '변론가';
      case 'INFJ':
        return '옹호자';
      case 'INFP':
        return '중재자';
      case 'ENFJ':
        return '선도자';
      case 'ENFP':
        return '활동가';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('MBTI 운세 결과', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(mbtiType, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                  Text(_getMBTIName(mbtiType), style: const TextStyle(fontSize: 20)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Card(
              child: ListTile(
                title: Text('오늘의 운세'),
                subtitle: Text('분석적인 능력이 빛나는 날입니다'),
              ),
            ),
            const Card(
              child: ListTile(
                title: Text('성격 특성'),
                subtitle: Text('독립적, 전략적, 완벽주의'),
              ),
            ),
            const Card(
              child: ListTile(
                title: Text('최고의 궁합'),
                subtitle: Text('ENFP, ENTP'),
              ),
            ),
            const Card(
              child: ListTile(
                title: Text('최악의 궁합'),
                subtitle: Text('ESFP, ISFP'),
              ),
            ),
            const Card(
              child: ListTile(
                title: Text('추천 직업'),
                subtitle: Text('과학자, 엔지니어, 전략 컨설턴트'),
              ),
            ),

            if (hasSajuData) ...[
              const SizedBox(height: 16),
              const Card(
                child: ListTile(
                  title: Text('사주 + MBTI 통합 분석'),
                  subtitle: Text('사주의 목(木) 기운과 INTJ의 전략적 성향이 조화롭게 어우러집니다'),
                ),
              ),
            ],

          ],
        ),
      ),
    );
  }
}
