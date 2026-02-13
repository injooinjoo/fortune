// Extended TarotCardInfo class with rich content
class TarotCardInfo {
  final int id;
  final String name;
  final List<String> keywords;
  final String uprightMeaning;
  final String reversedMeaning;
  final String element;
  final String? astrology;
  final int? numerology;
  final String imagery;
  final String advice;
  final List<String> questions;

  // Extended fields for rich content
  final String? story;
  final String? mythology;
  final String? psychologicalMeaning;
  final String? spiritualMeaning;
  final List<String>? dailyApplications;
  final String? meditation;
  final List<String>? affirmations;
  final String? colorSymbolism;
  final List<String>? crystals;
  final String? timing;
  final String? healthMessage;
  final Map<String, String>? cardCombinations;
  final String? historicalContext;
  final String? artisticSymbolism;

  const TarotCardInfo(
      {required this.id,
      required this.name,
      required this.keywords,
      required this.uprightMeaning,
      required this.reversedMeaning,
      required this.element,
      this.astrology,
      this.numerology,
      required this.imagery,
      required this.advice,
      required this.questions,
      this.story,
      this.mythology,
      this.psychologicalMeaning,
      this.spiritualMeaning,
      this.dailyApplications,
      this.meditation,
      this.affirmations,
      this.colorSymbolism,
      this.crystals,
      this.timing,
      this.healthMessage,
      this.cardCombinations,
      this.historicalContext,
      this.artisticSymbolism});
}
