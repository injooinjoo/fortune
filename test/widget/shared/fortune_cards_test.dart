import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ondo/core/design_system/design_system.dart';
import 'package:ondo/shared/components/cards/fortune_cards.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: DSTheme.light(),
      darkTheme: DSTheme.dark(),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('Fortune card family', () {
    testWidgets('FortuneFeatureCard renders headline and highlights',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const FortuneFeatureCard(
            eyebrow: '호기심',
            title: '질문 하나로 시작하는 인사이트',
            description: '짧은 설문 뒤에 결과를 바로 보여줍니다.',
            highlights: ['전문가 선택', '결과 카드'],
          ),
        ),
      );

      expect(find.text('호기심'), findsOneWidget);
      expect(find.text('질문 하나로 시작하는 인사이트'), findsOneWidget);
      expect(find.text('전문가 선택'), findsOneWidget);
      expect(find.text('결과 카드'), findsOneWidget);
    });

    testWidgets('FortuneRecordCard renders summary and footer metrics',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const FortuneRecordCard(
            badgeLabel: '연인',
            badgeIcon: Icons.favorite,
            metaText: '2026.03.14',
            trailingText: '12개 메시지',
            summary: '감정선이 안정적으로 이어지는 대화였어요.',
            footer: [
              FortuneMetricPill(
                label: '온도',
                value: '82',
                tone: FortuneCardTone.success,
              ),
            ],
          ),
        ),
      );

      expect(find.text('연인'), findsOneWidget);
      expect(find.text('2026.03.14'), findsOneWidget);
      expect(find.text('감정선이 안정적으로 이어지는 대화였어요.'), findsOneWidget);
      expect(find.text('온도 82'), findsOneWidget);
    });

    testWidgets('FortuneResultFrame renders header and body', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const FortuneResultFrame(
            header: Padding(
              padding: EdgeInsets.all(12),
              child: Text('결과 헤더'),
            ),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text('결과 본문'),
            ),
          ),
        ),
      );

      expect(find.text('결과 헤더'), findsOneWidget);
      expect(find.text('결과 본문'), findsOneWidget);
    });
  });
}
