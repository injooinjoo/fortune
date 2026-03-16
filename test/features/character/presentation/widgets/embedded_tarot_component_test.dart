import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/core/constants/tarot/tarot_card_catalog.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:fortune/features/character/presentation/widgets/embedded_fortune_component.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: DSTheme.light(),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('tarot result card opens detail bottom sheet on tap',
      (tester) async {
    final card = TarotCardCatalog.fromIndex(0);

    await tester.pumpWidget(
      _wrap(
        EmbeddedFortuneComponent(
          embeddedWidgetType: 'tarot_spread',
          componentData: {
            'title': '타로 리딩',
            'deckId': 'rider_waite',
            'deckName': '라이더-웨이트-스미스',
            'spreadType': 'threeCard',
            'spreadDisplayName': '3카드 스프레드',
            'question': '지금 제게 필요한 조언이 궁금해요.',
            'overallInterpretation': '카드가 전하는 흐름을 읽어보세요.',
            'guidance': '핵심 메시지를 먼저 붙잡아 보세요.',
            'adviceText': '오늘은 작은 행동부터 시작해 보세요.',
            'cards': [
              {
                'index': card.index,
                'cardId': card.cardId,
                'cardName': card.cardName,
                'cardNameKr': card.cardNameKr,
                'imagePath': card.imagePath,
                'positionKey': 'past',
                'positionName': '과거',
                'positionDesc': '지나간 영향과 원인',
                'interpretation': '과거의 흐름을 정리해야 해요.',
                'keywords': card.keywords,
                'isReversed': false,
              },
            ],
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('tarot-result-card-0')));
    await tester.pumpAndSettle();

    expect(find.text('이 카드의 조언'), findsOneWidget);
    expect(find.text(card.cardNameKr), findsWidgets);
    expect(find.text('과거'), findsWidgets);
  });
}
