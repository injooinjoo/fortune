// TarotSpread, InterpretationDepth, CardCombination classes
class TarotSpread {
  final String name;
  final String description;
  final int cardCount;
  final List<String> positions;
  final SpreadLayout layout;
  final int soulCost;

  const TarotSpread(
      {required this.name,
      required this.description,
      required this.cardCount,
      required this.positions,
      required this.layout,
      required this.soulCost});
}

enum SpreadLayout {
  single,
  horizontal,
  vertical,
  celticCross,
  pyramid,
  circle,
  relationship,
  decision
}

class InterpretationDepth {
  final String name;
  final bool includeReversed;
  final bool includeElemental;
  final bool includeNumerology;
  final bool includeAstrology;
  final int detailLevel;

  const InterpretationDepth(
      {required this.name,
      required this.includeReversed,
      required this.includeElemental,
      required this.includeNumerology,
      required this.includeAstrology,
      required this.detailLevel});
}

class CardCombination {
  final List<String> cards;
  final String meaning;
  final String advice;

  const CardCombination(
      {required this.cards, required this.meaning, required this.advice});
}

// 카드별 상세 정보 제공 메서드
