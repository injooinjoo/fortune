import '../tarot_metadata.dart';
import 'wands.dart';
import 'cups.dart';
import 'swords.dart';
import 'pentacles.dart';

// Helper methods for Minor Arcana
class MinorArcanaHelper {
  static Map<String, TarotCardInfo> getAllMinorArcana() {
    return {
      ...TarotWands.cards,
      ...TarotCups.cards,
      ...TarotSwords.cards,
      ...TarotPentacles.cards,
    };
  }

  static TarotCardInfo? getCardById(int id) {
    final allCards = getAllMinorArcana();
    return allCards.values.firstWhere(
      (card) => card.id == id,
      orElse: () => throw Exception('Card not found'),
    );
  }

  static List<TarotCardInfo> getCardsBySuit(String suit) {
    switch (suit.toLowerCase()) {
      case 'wands':
        return TarotWands.cards.values.toList();
      case 'cups':
        return TarotCups.cards.values.toList();
      case 'swords':
        return TarotSwords.cards.values.toList();
      case 'pentacles':
        return TarotPentacles.cards.values.toList();
      default:
        return [];
    }
  }
}
