import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/tarot_metadata.dart';
import '../../../../core/constants/tarot_minor_arcana.dart';
import '../../../../core/constants/tarot/tarot_position_meanings.dart';
import '../../../../presentation/providers/providers.dart';

class TarotInterpretationRequest {
  final int cardIndex;
  final int position;
  final String spreadType;
  final String? question;
  final bool isReversed;

  TarotInterpretationRequest({
    required this.cardIndex,
    required this.position,
    required this.spreadType,
    this.question,
    this.isReversed = false,
  });
}

final tarotInterpretationProvider =
    FutureProvider.family<String, TarotInterpretationRequest>(
  (ref, request) async {
    final supabase = ref.read(supabaseProvider);
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('사용자 인증이 필요합니다');
    }

    // Get card information
    final cardInfo = _getCardInfo(request.cardIndex);
    final positionMeaning = TarotHelper.getPositionDescription(
        request.spreadType, request.position);

    // 스프레드 타입 파싱
    final spreadType =
        TarotPositionMeanings.parseSpreadType(request.spreadType);
    if (spreadType == null) {
      // 알 수 없는 스프레드 타입이면 기본 해석 사용
      return _generateLocalInterpretation(
        cardInfo: cardInfo,
        position: positionMeaning,
        question: request.question,
      );
    }

    // 하드코딩된 위치별 해석 가져오기
    final interpretation = TarotPositionMeanings.getInterpretation(
      cardIndex: request.cardIndex,
      spreadType: spreadType,
      positionIndex: request.position,
      isReversed: request.isReversed,
    );

    if (interpretation != null) {
      // 위치별 맞춤 해석이 있으면 사용
      return _formatInterpretation(
        cardInfo: cardInfo,
        positionName: TarotPositionMeanings.getPositionDisplayName(
            spreadType, request.position),
        interpretation: interpretation,
        isReversed: request.isReversed,
      );
    }

    // Fallback to local interpretation
    return _generateLocalInterpretation(
      cardInfo: cardInfo,
      position: positionMeaning,
      question: request.question,
    );
  },
);

// 타로 전체 해석 프로바이더
final tarotFullInterpretationProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>(
  (ref, params) async {
    final supabase = ref.read(supabaseProvider);
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('사용자 인증이 필요합니다');
    }

    final cards = params['cards'] as List<int>;
    final spreadType = params['spreadType'] as String;
    final question = params['question'] as String?;
    final reversedCards = params['reversedCards'] as List<bool>? ??
        List.filled(cards.length, false);

    // 스프레드 타입 파싱
    final parsedSpreadType = TarotPositionMeanings.parseSpreadType(spreadType);

    // Prepare card information with interpretations
    final cardInterpretations = <Map<String, dynamic>>[];

    for (int i = 0; i < cards.length; i++) {
      final cardIndex = cards[i];
      final isReversed = i < reversedCards.length ? reversedCards[i] : false;
      final cardInfo = _getCardInfo(cardIndex);

      String? interpretation;
      String positionName = '위치 ${i + 1}';

      if (parsedSpreadType != null) {
        interpretation = TarotPositionMeanings.getInterpretation(
          cardIndex: cardIndex,
          spreadType: parsedSpreadType,
          positionIndex: i,
          isReversed: isReversed,
        );
        positionName =
            TarotPositionMeanings.getPositionDisplayName(parsedSpreadType, i);
      }

      cardInterpretations.add({
        'index': cardIndex,
        'name': cardInfo['name'],
        'position': positionName,
        'isReversed': isReversed,
        'interpretation': interpretation ?? cardInfo['meaning'],
        'keywords': cardInfo['keywords'],
        'element': cardInfo['element'],
      });
    }

    // Count elements
    final elementCounts = <String, int>{};
    final majorCount =
        cardInterpretations.where((card) => card['index'] < 22).length;

    for (final card in cardInterpretations) {
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
      'spreadType': parsedSpreadType != null
          ? TarotPositionMeanings.getSpreadDisplayName(parsedSpreadType)
          : spreadType,
      'question': question,
      'cards': cardInterpretations,
      'summary': _generateSummary(cardInterpretations, parsedSpreadType),
      'elementBalance': elementCounts,
      'dominantElement': dominantElement,
      'majorArcanaCount': majorCount,
      'advice': _generateAdvice(cardInterpretations),
      'timeline': '앞으로 3-6개월 동안 중요한 변화가 예상됩니다.',
    };
  },
);

/// 하드코딩된 해석을 포맷팅하여 반환
String _formatInterpretation({
  required Map<String, dynamic> cardInfo,
  required String positionName,
  required String interpretation,
  required bool isReversed,
}) {
  final buffer = StringBuffer();
  final directionText = isReversed ? '(역방향)' : '(정방향)';

  // Opening
  buffer.writeln(
      '**${cardInfo['name']}** $directionText 카드가 **$positionName** 자리에 나타났습니다.');
  buffer.writeln();

  // 위치별 맞춤 해석
  buffer.writeln(interpretation);
  buffer.writeln();

  // 키워드
  final keywords = cardInfo['keywords'] as List?;
  if (keywords != null && keywords.isNotEmpty) {
    buffer.writeln('🔮 키워드: ${keywords.take(3).join(', ')}');
  }

  return buffer.toString();
}

/// 카드 해석들을 기반으로 종합 요약 생성
String _generateSummary(
    List<Map<String, dynamic>> cards, TarotSpreadType? spreadType) {
  final buffer = StringBuffer();

  final reversedCount = cards.where((c) => c['isReversed'] == true).length;
  final majorCount = cards.where((c) => (c['index'] as int) < 22).length;

  buffer.write('이번 리딩에서는 ${cards.length}장의 카드가 당신의 상황을 보여주고 있습니다. ');

  if (majorCount > 0) {
    buffer.write('$majorCount장의 메이저 아르카나가 등장하여 중요한 인생의 전환점을 암시합니다. ');
  }

  if (reversedCount > 0) {
    buffer.write('$reversedCount장의 역방향 카드는 내면의 성찰이나 도전을 나타냅니다. ');
  }

  return buffer.toString();
}

/// 카드 해석들을 기반으로 조언 생성
List<String> _generateAdvice(List<Map<String, dynamic>> cards) {
  final advice = <String>[];

  // 메이저 아르카나가 많으면
  final majorCount = cards.where((c) => (c['index'] as int) < 22).length;
  if (majorCount >= 2) {
    advice.add('메이저 아르카나가 여러 장 등장했습니다. 지금은 중요한 결정을 앞두고 있으니 신중하게 행동하세요.');
  }

  // 역방향이 많으면
  final reversedCount = cards.where((c) => c['isReversed'] == true).length;
  if (reversedCount >= cards.length ~/ 2) {
    advice.add('역방향 카드가 많이 나왔습니다. 내면을 돌아보고 막혀있는 에너지를 풀어줄 시간이 필요합니다.');
  }

  // 기본 조언
  advice.add('카드가 전하는 메시지에 귀 기울이되, 최종 결정은 당신의 직관을 믿으세요.');
  advice.add('변화를 두려워하지 말고, 새로운 기회를 받아들일 준비를 하세요.');

  return advice;
}

// Helper functions
Map<String, dynamic> _getCardInfo(int cardIndex) {
  // Major Arcana (0-21)
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
        'advice': null,
      };
    }
  }

  // Minor Arcana (22-77)
  TarotCardInfo? minorCard;
  String? suit;

  // Wands (22-35)
  if (cardIndex >= 22 && cardIndex < 36) {
    final wandsCards = TarotMinorArcana.wands.values.toList();
    final index = cardIndex - 22;
    if (index < wandsCards.length) {
      minorCard = wandsCards[index];
      suit = 'Wands';
    }
  }
  // Cups (36-49)
  else if (cardIndex >= 36 && cardIndex < 50) {
    final cupsCards = TarotMinorArcana.cups.values.toList();
    final index = cardIndex - 36;
    if (index < cupsCards.length) {
      minorCard = cupsCards[index];
      suit = 'Cups';
    }
  }
  // Swords (50-63)
  else if (cardIndex >= 50 && cardIndex < 64) {
    final swordsCards = TarotMinorArcana.swords.values.toList();
    final index = cardIndex - 50;
    if (index < swordsCards.length) {
      minorCard = swordsCards[index];
      suit = 'Swords';
    }
  }
  // Pentacles (64-77)
  else if (cardIndex >= 64 && cardIndex < 78) {
    final pentaclesCards = TarotMinorArcana.pentacles.values.toList();
    final index = cardIndex - 64;
    if (index < pentaclesCards.length) {
      minorCard = pentaclesCards[index];
      suit = 'Pentacles';
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
      'suit': suit,
    };
  }

  // Fallback
  return {
    'index': cardIndex,
    'type': 'unknown',
    'name': 'Unknown Card',
    'keywords': [],
    'element': 'Unknown',
    'meaning': 'Card information not available',
  };
}

String _generateLocalInterpretation({
  required Map<String, dynamic> cardInfo,
  required String position,
  required String? question,
}) {
  final buffer = StringBuffer();

  // Opening
  buffer.writeln('${cardInfo['name']} 카드가 $position 자리에 나타났습니다.');
  buffer.writeln();

  // Main interpretation
  if (cardInfo['type'] == 'major') {
    buffer.writeln(
        '이 카드는 **${(cardInfo['keywords'] as List).first}**을 상징하는 중요한 메이저 아르카나입니다.');
    buffer.writeln(cardInfo['meaning'] ?? '');
  } else {
    final suit = cardInfo['suit'];
    final element = cardInfo['element'];
    buffer.writeln(
        '$suit의 카드는 $element 원소를 나타내며, ${_getSuitMeaning(suit)}와 관련이 있습니다.');
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

String _getSuitMeaning(String? suit) {
  switch (suit) {
    case 'Wands':
      return '열정과 창의적 에너지';
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
