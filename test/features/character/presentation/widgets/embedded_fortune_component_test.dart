import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:fortune/features/character/presentation/widgets/embedded_fortune_component.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: DSTheme.light(),
    home: Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: 420,
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('daily card keeps compact summary and limited sections',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        const EmbeddedFortuneComponent(
          embeddedWidgetType: 'fortune_result_card',
          componentData: {
            'fortuneType': 'daily',
            'title': '오늘의 메시지',
            'summary': '우선순위를 분명히 할수록 흐름이 더 또렷해져요.',
            'score': 86,
            'highlights': ['집중', '대화운', '정리', '과몰입 주의'],
            'recommendations': [
              '가장 중요한 일부터 시작하세요.',
              '대화는 오전에 정리하세요.',
              '세 번째 추천은 숨겨져야 해요.',
            ],
            'warnings': [
              '즉흥적인 소비는 점검하세요.',
              '두 번째 경고는 보이면 안 돼요.',
            ],
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('오늘의 메시지'), findsOneWidget);
    expect(find.text('86점'), findsOneWidget);
    expect(find.text('우선순위를 분명히 할수록 흐름이 더 또렷해져요.'), findsOneWidget);
    expect(find.text('집중'), findsOneWidget);
    expect(find.text('대화운'), findsOneWidget);
    expect(find.text('정리'), findsNothing);
    expect(find.text('과몰입 주의'), findsNothing);
    expect(find.text('가장 중요한 일부터 시작하세요.'), findsOneWidget);
    expect(find.text('대화는 오전에 정리하세요.'), findsOneWidget);
    expect(find.text('세 번째 추천은 숨겨져야 해요.'), findsNothing);
    expect(find.text('즉흥적인 소비는 점검하세요.'), findsOneWidget);
    expect(find.text('두 번째 경고는 보이면 안 돼요.'), findsNothing);
  });

  testWidgets('new-year card reveals details inside expandable sections',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        const EmbeddedFortuneComponent(
          embeddedWidgetType: 'fortune_result_card',
          componentData: {
            'fortuneType': 'new-year',
            'title': '2026년 새해 인사이트',
            'summary': '크게 욕심내기보다 리듬을 일정하게 유지하는 해예요.',
            'score': 91,
            'highlights': ['리듬 회복', '관계 정비', '꾸준한 실행'],
            'specialMessage': '한 번에 바꾸기보다 작은 습관을 오래 유지해보세요.',
            'goalFortune': {
              'title': '새해 목표 운세',
              'prediction': '상반기에 방향을 정하면 하반기에 속도가 붙어요.',
              'deepAnalysis': '욕심을 줄이고 반복 가능한 루틴을 만드는 편이 유리해요.',
              'bestMonths': ['3월', '8월'],
              'actionItems': ['한 가지 목표에만 집중하세요.'],
            },
            'luckyItems': {
              'color': '아이보리',
              'number': '3',
            },
            'actionPlan': {
              'immediate': ['이번 주 안에 우선순위를 다시 적어보세요.'],
            },
            'monthlyHighlights': [
              {
                'month': '3월',
                'theme': '기회 포착',
                'advice': '가벼운 제안도 바로 메모해두세요.',
              },
            ],
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    final goalPrediction = find.text(
      '상반기에 방향을 정하면 하반기에 속도가 붙어요.',
    );
    final monthlyTheme = find.text('3월 · 기회 포착');

    expect(goalPrediction.hitTestable(), findsNothing);

    await tester.tap(find.text('새해 목표 운세'));
    await tester.pumpAndSettle();

    expect(goalPrediction.hitTestable(), findsOneWidget);
    expect(
      find.text('욕심을 줄이고 반복 가능한 루틴을 만드는 편이 유리해요.').hitTestable(),
      findsOneWidget,
    );
    expect(monthlyTheme.hitTestable(), findsNothing);

    await tester.tap(find.text('월별 하이라이트'));
    await tester.pumpAndSettle();

    expect(monthlyTheme.hitTestable(), findsOneWidget);
    expect(
      find.text('가벼운 제안도 바로 메모해두세요.').hitTestable(),
      findsOneWidget,
    );
  });
}
