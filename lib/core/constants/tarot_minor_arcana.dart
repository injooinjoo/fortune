// Tarot Minor Arcana - Barrel File
// 소아르카나 모든 컴포넌트 export

import 'tarot_metadata.dart';
import 'tarot_minor_arcana/wands.dart';
import 'tarot_minor_arcana/cups.dart';
import 'tarot_minor_arcana/swords.dart';
import 'tarot_minor_arcana/pentacles.dart';
import 'tarot_minor_arcana/minor_arcana_helper.dart';

export 'tarot_minor_arcana/wands.dart';
export 'tarot_minor_arcana/cups.dart';
export 'tarot_minor_arcana/swords.dart';
export 'tarot_minor_arcana/pentacles.dart';
export 'tarot_minor_arcana/minor_arcana_helper.dart';

// Backward compatibility wrapper
class TarotMinorArcana {
  static final wands = TarotWands.cards;
  static final cups = TarotCups.cards;
  static final swords = TarotSwords.cards;
  static final pentacles = TarotPentacles.cards;

  static Map<String, TarotCardInfo> getAllMinorArcana() =>
      MinorArcanaHelper.getAllMinorArcana();

  static TarotCardInfo? getCardById(int id) =>
      MinorArcanaHelper.getCardById(id);

  static List<TarotCardInfo> getCardsBySuit(String suit) =>
      MinorArcanaHelper.getCardsBySuit(suit);
}
