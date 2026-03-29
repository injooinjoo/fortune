import 'package:flutter_test/flutter_test.dart';
import 'package:ondo/core/constants/tarot/tarot_card_catalog.dart';

void main() {
  test('major arcana index mapping is stable', () {
    final card = TarotCardCatalog.fromIndex(0, deckId: 'rider_waite');

    expect(card.cardId, 'major_00_fool');
    expect(card.cardName, 'The Fool');
    expect(card.imagePath, contains('rider_waite/major/00_fool.webp'));
  });

  test('minor arcana ordering matches deterministic 78-card layout', () {
    final cupsAce = TarotCardCatalog.fromIndex(22, deckId: 'rider_waite');
    final pentaclesKing = TarotCardCatalog.fromIndex(77, deckId: 'rider_waite');

    expect(cupsAce.cardId, 'cups_01');
    expect(cupsAce.cardName, 'Ace of Cups');
    expect(cupsAce.imagePath, contains('rider_waite/cups/01_of_cups.webp'));

    expect(pentaclesKing.cardId, 'pentacles_14');
    expect(pentaclesKing.cardNameKr, '펜타클 왕');
    expect(
      pentaclesKing.imagePath,
      contains('rider_waite/pentacles/king_of_pentacles.webp'),
    );
  });
}
