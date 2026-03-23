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
  testWidgets('daily card renders rich mystical sections from existing payload',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        const EmbeddedFortuneComponent(
          embeddedWidgetType: 'fortune_result_card',
          componentData: {
            'fortuneType': 'daily',
            'title': '오늘의 흐름',
            'summary': '우선순위를 분명히 할수록 흐름이 더 또렷해져요.',
            'description': '작은 정리 하나가 큰 차이를 만드는 날',
            'score': 86,
            'highlights': ['집중', '대화운', '정리'],
            'specialMessage': '과하게 넓히기보다 중요한 두세 가지에 빛을 모으면 운이 더 빨리 붙어요.',
            'recommendations': [
              '가장 중요한 일부터 시작하세요.',
              '대화는 오전에 정리하세요.',
            ],
            'warnings': [
              '즉흥적인 소비는 점검하세요.',
            ],
            'luckyItems': {
              'color': '문라이트 블루',
              'number': '7',
              'time': '오전 9:30',
            },
            'categories': {
              'work': {
                'score': 88,
                'message': '우선순위를 정리하면 성과가 커져요.',
              },
              'love': {
                'score': 82,
                'message': '부드러운 대화가 분위기를 살려줘요.',
              },
            },
            'timeSpecificFortunes': [
              {
                'time': '오전',
                'title': '집중 시동',
                'score': 87,
                'description': '가장 중요한 일을 한 번에 밀어붙이기 좋은 시간이에요.',
                'recommendation': '핵심 메모를 먼저 정리하세요.',
              },
            ],
            'personalActions': [
              {
                'title': '우선순위 3개만 남기기',
                'description': '집중운이 살아나요.',
                'timing': '오전 초반',
              },
            ],
            'godlife': {
              'summary': '오늘은 조용한 정리가 결국 이기는 날이에요.',
              'cheatkeys': [
                {'icon': '⚡', 'key': '한 번에 하나만'},
              ],
            },
            'fortuneSummary': {
              'byMBTI': {
                'title': '성향 흐름',
                'content': '오늘은 즉흥성보다 구조화가 더 유리해요.',
              },
            },
            'storySegments': [
              {
                'text': '작은 메모 하나가 전체 흐름을 바꿔줄 수 있어요.',
              },
            ],
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('오늘의 흐름'), findsOneWidget);
    expect(find.text('86점'), findsOneWidget);
    expect(find.text('우선순위를 분명히 할수록 흐름이 더 또렷해져요.'), findsOneWidget);
    expect(find.text('오늘의 리듬'), findsOneWidget);
    expect(find.text('분야별 운세'), findsOneWidget);
    expect(find.text('행운 포인트'), findsOneWidget);
    expect(find.text('오늘의 액션'), findsOneWidget);
    expect(find.text('갓생 부스트'), findsOneWidget);
    expect(find.text('집중 시동'), findsOneWidget);
    expect(find.textContaining('일과운'), findsOneWidget);
    expect(find.text('우선순위 3개만 남기기 · 집중운이 살아나요. · 오전 초반'), findsOneWidget);
    expect(find.text('오늘은 조용한 정리가 결국 이기는 날이에요.'), findsOneWidget);
    expect(find.text('즉흥적인 소비는 점검하세요.'), findsOneWidget);

    final storyText = find.text('작은 메모 하나가 전체 흐름을 바꿔줄 수 있어요.');
    expect(storyText.hitTestable(), findsNothing);

    await tester.ensureVisible(find.text('더 읽기'));
    await tester.tap(find.text('더 읽기'));
    await tester.pumpAndSettle();

    expect(storyText, findsOneWidget);
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

    expect(goalPrediction.hitTestable(), findsOneWidget);
    expect(
      find.text('욕심을 줄이고 반복 가능한 루틴을 만드는 편이 유리해요.').hitTestable(),
      findsOneWidget,
    );
    expect(monthlyTheme.hitTestable(), findsNothing);

    await tester.tap(find.text('월별 하이라이트'));
    await tester.pumpAndSettle();

    expect(monthlyTheme.hitTestable(), findsOneWidget);
    await tester.ensureVisible(find.text('가벼운 제안도 바로 메모해두세요.'));
    await tester.pumpAndSettle();
    expect(
      find.text('가벼운 제안도 바로 메모해두세요.'),
      findsOneWidget,
    );
  });

  testWidgets('daily-calendar card renders time sections and calendar advice',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        const EmbeddedFortuneComponent(
          embeddedWidgetType: 'fortune_result_card',
          componentData: {
            'fortuneType': 'daily-calendar',
            'title': '오늘 일정 흐름',
            'summary': '오전과 오후의 밀도가 달라서, 중요한 일정은 좋은 시간대에 몰아두는 편이 좋아요.',
            'score': 84,
            'dayTheme': '리듬 조율의 날',
            'bestTime': {
              'period': '오전 9:00-11:00',
              'reason': '집중력과 전달력이 함께 올라와요.',
            },
            'worstTime': {
              'period': '오후 4:00 이후',
              'reason': '피로감 때문에 판단이 느려질 수 있어요.',
            },
            'timeSlots': [
              {
                'period': '오전',
                'traditionalName': '집중 시동',
                'score': 87,
                'description': '중요한 일정을 가장 선명하게 처리하기 좋아요.',
                'caution': '메신저 멀티태스킹은 줄이세요.',
              },
            ],
            'calendarAdvice': [
              {
                'eventTitle': '팀 미팅',
                'advice': '핵심 안건을 먼저 꺼내면 훨씬 짧고 선명하게 끝낼 수 있어요.',
                'luckyTip': '회의 전 3줄 메모',
              },
            ],
            'luckyItems': {
              'color': '소프트 아이보리',
              'time': '오전 9:30',
            },
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('좋은 시간 / 조심할 시간'), findsOneWidget);
    expect(find.text('시간대별 흐름'), findsOneWidget);
    expect(find.text('일정 인사이트'), findsOneWidget);
    expect(find.text('오전 9:00-11:00'), findsOneWidget);
    expect(find.text('팀 미팅'), findsOneWidget);
  });

  testWidgets('fortune-cookie card renders lucky set and mission',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        const EmbeddedFortuneComponent(
          embeddedWidgetType: 'fortune_cookie',
          componentData: {
            'title': '오늘의 포춘 메시지',
            'score': 79,
            'emoji': '🥠',
            'message': '작은 용기가 오늘의 흐름을 바꿔줄 거예요.',
            'cookieType': 'luck',
            'actionMission': '오전에 미뤄둔 연락 하나만 먼저 보내보세요.',
            'luckyItems': {
              'number': '3',
              'color': '문라이트 블루',
              'time': '오전 10시',
              'direction': '동남',
              'item': '작은 노트',
              'place': '창가 자리',
            },
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('오늘의 럭키 세트'), findsOneWidget);
    expect(find.text('오늘의 미션'), findsOneWidget);
    expect(find.text('행운 숫자 3'), findsOneWidget);
    expect(find.text('오전에 미뤄둔 연락 하나만 먼저 보내보세요.'), findsOneWidget);
  });

  testWidgets('fortune-cookie card localizes english fallback labels',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        const EmbeddedFortuneComponent(
          embeddedWidgetType: 'fortune_cookie',
          componentData: {
            'title': '오늘의 메시지',
            'score': 89,
            'message': '보물은 생각보다 가까운 곳에 있어요.',
            'cookieType': 'Fortune Cookie',
            'luckyItems': {
              'lucky number': '49',
              'lucky color': '터콰이즈',
              'lucky time': '오전 11시',
            },
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('포춘쿠키'), findsOneWidget);
    expect(find.text('행운 숫자 49'), findsOneWidget);
    expect(find.text('행운 컬러 터콰이즈'), findsOneWidget);
    expect(find.text('행운 시간 오전 11시'), findsOneWidget);
    expect(find.text('Fortune Cookie'), findsNothing);
    expect(find.text('lucky number 49'), findsNothing);
  });
}
