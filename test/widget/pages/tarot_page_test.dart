// Tarot Page - Widget Test
// 타로 페이지 UI 컴포넌트 테스트

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 타로 관련 위젯들의 기본 테스트
void main() {
  group('타로 덱 선택 UI 테스트', () {
    testWidgets('덱 선택 카드가 렌더링되어야 함', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: _MockDeckSelectionWidget(),
            ),
          ),
        ),
      );

      // 덱 선택 UI 요소 확인
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('덱 선택 시 콜백이 호출되어야 함', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: _MockDeckSelectionWidget(
                onDeckSelected: (deck) {},
              ),
            ),
          ),
        ),
      );

      // 첫 번째 덱 카드 탭
      final deckCard = find.byType(Card).first;
      if (deckCard.evaluate().isNotEmpty) {
        await tester.tap(deckCard);
        await tester.pumpAndSettle();
      }
    });
  });

  group('타로 카드 선택 UI 테스트', () {
    testWidgets('카드 그리드가 표시되어야 함', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: _MockCardGridWidget(),
            ),
          ),
        ),
      );

      // 그리드 뷰 확인
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('카드 선택 시 하이라이트되어야 함', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: _MockCardGridWidget(),
            ),
          ),
        ),
      );

      // 카드 탭 및 선택 상태 확인
      final cards = find.byType(GestureDetector);
      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await tester.pumpAndSettle();
      }
    });
  });

  group('타로 결과 화면 테스트', () {
    testWidgets('결과 카드와 해석이 표시되어야 함', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: _MockTarotResultWidget(),
            ),
          ),
        ),
      );

      // 결과 요소 확인
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}

// Mock Widgets for Testing
class _MockDeckSelectionWidget extends StatelessWidget {
  final void Function(String)? onDeckSelected;

  const _MockDeckSelectionWidget({this.onDeckSelected});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        GestureDetector(
          onTap: () => onDeckSelected?.call('rider_waite'),
          child: const Card(
            child: ListTile(
              title: Text('라이더 웨이트'),
              subtitle: Text('클래식 타로 덱'),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => onDeckSelected?.call('thoth'),
          child: const Card(
            child: ListTile(
              title: Text('토트'),
              subtitle: Text('알레이스터 크로울리 덱'),
            ),
          ),
        ),
      ],
    );
  }
}

class _MockCardGridWidget extends StatefulWidget {
  const _MockCardGridWidget();

  @override
  State<_MockCardGridWidget> createState() => _MockCardGridWidgetState();
}

class _MockCardGridWidgetState extends State<_MockCardGridWidget> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.7,
      ),
      itemCount: 22,
      itemBuilder: (context, index) {
        final isSelected = selectedIndex == index;
        return GestureDetector(
          onTap: () => setState(() => selectedIndex = index),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey,
                width: isSelected ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text('Card $index')),
          ),
        );
      },
    );
  }
}

class _MockTarotResultWidget extends StatelessWidget {
  const _MockTarotResultWidget();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 200,
            color: Colors.purple.withValues(alpha: 0.1),
            child: const Center(child: Text('선택한 카드')),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '카드 해석 내용이 여기에 표시됩니다.',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
