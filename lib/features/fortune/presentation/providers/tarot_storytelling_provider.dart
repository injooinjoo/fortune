import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/tarot_metadata.dart';
import '../../../../core/constants/tarot_minor_arcana.dart';
import '../../../../presentation/providers/providers.dart';

class TarotInterpretationRequest {
  final int cardIndex;
  final int position;
  final String spreadType;
  final String? question;

  TarotInterpretationRequest({
    required this.cardIndex,
    required this.position,
    required this.spreadType,
    this.question});
}

final tarotInterpretationProvider = FutureProvider.family<String, TarotInterpretationRequest>(
  (ref, request) async {
    final supabase = ref.read(supabaseProvider);
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('사용자 인증이 필요합니다');
}

    // Get card information
    final cardInfo = _getCardInfo(request.cardIndex);
    final positionMeaning = TarotHelper.getPositionDescription(
      request.spreadType,
      request.position);

    try {
      // TODO: Implement tarot interpretation via Edge Functions
      // For now, use local interpretation
      throw Exception('Edge function not implemented');
} catch (e) {
      // Fallback to local interpretation
      return _generateLocalInterpretation(
        cardInfo: cardInfo,
        position: positionMeaning,
        question: request.question);
}
  }
);

// 타로 전체 해석 프로바이더
final tarotFullInterpretationProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>(
  (ref, params) async {
    final supabase = ref.read(supabaseProvider);
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('사용자 인증이 필요합니다');
}

    final cards = params['cards'] as List<int>;
    final spreadType = params['spreadType'] as String;
    final question = params['question'] as String?;

    // Prepare card information
    final cardInfoList = cards.map((cardIndex) => _getCardInfo(cardIndex)).toList();

    try {
      // TODO: Implement full tarot reading via Edge Functions
      // For now, use local summary
      throw Exception('Edge function not implemented');
} catch (e) {
      // Fallback to local summary
      return _generateLocalSummary(
        cards: cardInfoList,
        spreadType: spreadType,
        question: question);
}
  }
);

// Helper functions
Map<String, dynamic> _getCardInfo(int cardIndex) {
  // Major Arcana (0-21,
  if (cardIndex < 22) {
    final majorCard = TarotMetadata.majorArcana[cardIndex];
    if (majorCard != null) {
      return {
        'index': cardIndex,
        'type': 'major',
        'name': majorCard.name,
        'keywords': majorCard.keywords,
        'element': majorCard.element,
        'meaning': majorCard.uprightMeaning,
        'advice': null};
}
  }

  // Minor Arcana (22-77,
  TarotCardInfo? minorCard;

  // Wands (22-35,
  if (cardIndex >= 22 && cardIndex < 36) {
    final wandsCards = TarotMinorArcana.wands.values.toList();
    final index = cardIndex - 22;
    if (index < wandsCards.length) {
      minorCard = wandsCards[index];
}
  }
  // Cups (36-49,
  else if (cardIndex >= 36 && cardIndex < 50) {
    final cupsCards = TarotMinorArcana.cups.values.toList();
    final index = cardIndex - 36;
    if (index < cupsCards.length) {
      minorCard = cupsCards[index];
}
  }
  // Swords (50-63,
  else if (cardIndex >= 50 && cardIndex < 64) {
    final swordsCards = TarotMinorArcana.swords.values.toList();
    final index = cardIndex - 50;
    if (index < swordsCards.length) {
      minorCard = swordsCards[index];
}
  }
  // Pentacles (64-77,
  else if (cardIndex >= 64 && cardIndex < 78) {
    final pentaclesCards = TarotMinorArcana.pentacles.values.toList();
    final index = cardIndex - 64;
    if (index < pentaclesCards.length) {
      minorCard = pentaclesCards[index];
}
  }
  
  if (minorCard != null) {
    return {
      'index': cardIndex,
      'type': 'minor',
      'name': minorCard.name,
      'keywords': minorCard.keywords,
      'element': minorCard.element,
      'meaning': minorCard.uprightMeaning,
      'advice': minorCard.advice,
      'suit': null};
}
  
  // Fallback
  return {
    'index': cardIndex,
    'type': 'unknown',
    'name': 'Unknown Card',
    'keywords': [],
    'element': 'Unknown',
    'meaning': 'Card information not available'};
}

String _generateLocalInterpretation({
  required Map<String, dynamic> cardInfo,
  required String position,
  required String? question}) {
  final buffer = StringBuffer();
  
  // Opening
  buffer.writeln('${cardInfo['name']} 카드가 $position 자리에 나타났습니다.');
  buffer.writeln();
  
  // Main interpretation
  if (cardInfo['type'] == 'major') {
    buffer.writeln('이 카드는 **${(cardInfo['keywords'] as List).first}**을 상징하는 중요한 메이저 아르카나입니다.');
    buffer.writeln(cardInfo['meaning'] ?? '');
} else {
    final suit = cardInfo['suit'];
    final element = cardInfo['element'];
    buffer.writeln('$suit의 카드는 $element 원소를 나타내며, ${_getSuitMeaning(suit)}와 관련이 있습니다.');
    buffer.writeln(cardInfo['meaning'] ?? '');
}
  
  buffer.writeln();
  
  // Advice
  if (cardInfo['advice'] != null) {
    buffer.writeln('💡 ${cardInfo['advice']}');
} else {
    buffer.writeln('💡 이 카드가 전하는 메시지에 귀 기울이고, 내면의 직관을 믿으세요.');
}
  
  return buffer.toString();
}

Map<String, dynamic> _generateLocalSummary({
  required List<Map<String, dynamic>> cards,
  required String spreadType,
  required String? question}) {
  // Count elements
  final elementCounts = <String, int>{};
  final majorCount = cards.where((card) => card['type'] == 'major').length;
  
  for (final card in cards) {
    final element = card['element'] as String;
    elementCounts[element] = (elementCounts[element] ?? 0) + 1;
}
  
  // Find dominant element
  String dominantElement = '';
  int maxCount = 0;
  elementCounts.forEach((element, count) {
    if (count > maxCount) {
      maxCount = count;
      dominantElement = element;
}
  });
  
  return {
    'summary': '이번 리딩에서는 ${cards.length}장의 카드가 당신의 상황을 보여주고 있습니다.',
    'elementBalance': elementCounts,
    'dominantElement': dominantElement,
    'majorArcanaCount': majorCount,
    'advice': [
      '카드들이 보여준 메시지를 종합해보면, 지금은 신중하면서도 적극적인 행동이 필요한 시기입니다.',
      '내면의 목소리에 귀 기울이되, 현실적인 계획도 함께 세워보세요.',
      '변화를 두려워하지 말고, 새로운 기회를 받아들일 준비를 하세요.'],
    'timeline': '앞으로 3-6개월 동안 중요한 변화가 예상됩니다.'};
}

String _getSuitMeaning(String suit) {
  switch (suit) {
    case 'Wands': return '열정과 창의적 에너지';
    case 'Cups':
      return '감정과 인간관계';
    case 'Swords':
      return '지성과 의사소통';
    case 'Pentacles':
      return '물질적 안정과 성취';
    default:
      return '삶의 변화';
  }
}