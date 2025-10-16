import 'dart:math';
import '../domain/models/tarot_card_model.dart';

class TarotService {
  static final Random _random = Random();

  // 메이저 아르카나 한국어 이름
  static final Map<int, String> majorArcanaKoreanNames = {
    0: '바보',
    1: '마법사',
    2: '여사제',
    3: '여황제',
    4: '황제',
    5: '교황',
    6: '연인',
    7: '전차',
    8: '힘',
    9: '은둔자',
    10: '운명의 수레바퀴',
    11: '정의',
    12: '매달린 사람',
    13: '죽음',
    14: '절제',
    15: '악마',
    16: '탑',
    17: '별',
    18: '달',
    19: '태양',
    20: '심판',
    21: '세계',
  };

  // 마이너 아르카나 한국어 이름
  static final Map<int, String> minorArcanaKoreanNames = {
    1: '에이스',
    2: '2',
    3: '3',
    4: '4',
    5: '5',
    6: '6',
    7: '7',
    8: '8',
    9: '9',
    10: '10',
    11: '시종',
    12: '기사',
    13: '여왕',
    14: '왕',
  };

  // 카드 카테고리 한국어 이름
  static final Map<CardCategory, String> categoryKoreanNames = {
    CardCategory.cups: '컵',
    CardCategory.wands: '완드',
    CardCategory.swords: '소드',
    CardCategory.pentacles: '펜타클',
  };

  /// 스프레드에 따른 카드 뽑기
  static TarotSpreadResult drawCards({
    required TarotSpreadType spreadType,
    required String question,
    TarotDeckType deck = TarotDeckType.riderWaite,
  }) {
    final cards = <TarotCard>[];
    final usedCards = <String>{};

    // 스프레드에 필요한 카드 수만큼 뽑기
    for (int i = 0; i < spreadType.cardCount; i++) {
      TarotCard card;
      String cardKey;

      do {
        card = _drawSingleCard(deck, i, spreadType);
        cardKey = '${card.category.path}_${card.number}';
      } while (usedCards.contains(cardKey));

      usedCards.add(cardKey);
      cards.add(card);
    }

    // 포지션별 해석 생성
    final positionInterpretations = _generatePositionInterpretations(
      spreadType,
      cards,
      question,
    );

    // 전체 해석 생성
    final overallInterpretation = _generateOverallInterpretation(
      spreadType,
      cards,
      question,
      positionInterpretations,
    );

    return TarotSpreadResult(
      spreadType: spreadType,
      cards: cards,
      question: question,
      timestamp: DateTime.now(),
      overallInterpretation: overallInterpretation,
      positionInterpretations: positionInterpretations,
    );
  }

  /// 단일 카드 뽑기
  static TarotCard _drawSingleCard(
    TarotDeckType deck,
    int position,
    TarotSpreadType spreadType,
  ) {
    // 메이저/마이너 선택 (메이저 30% 확률)
    final isMajor = _random.nextInt(100) < 30;

    CardCategory category;
    int number;
    String cardName;
    String cardNameKr;

    if (isMajor) {
      category = CardCategory.major;
      number = _random.nextInt(22); // 0-21
      cardName = majorArcanaKoreanNames[number]!;
      cardNameKr = majorArcanaKoreanNames[number]!;
    } else {
      // 마이너 카테고리 선택
      final minorCategories = [
        CardCategory.cups,
        CardCategory.wands,
        CardCategory.swords,
        CardCategory.pentacles,
      ];
      category = minorCategories[_random.nextInt(4)];
      number = _random.nextInt(14) + 1; // 1-14

      final categoryName = categoryKoreanNames[category]!;
      final numberName = minorArcanaKoreanNames[number]!;
      cardName = '$categoryName의 $numberName';
      cardNameKr = '$categoryName의 $numberName';
    }

    // 역방향 확률 (30%)
    final isReversed = _random.nextInt(100) < 30;

    // 포지션 키 설정
    final positionKey = _getPositionKey(spreadType, position);

    return TarotCard(
      deckType: deck,
      category: category,
      number: number,
      cardName: cardName,
      cardNameKr: cardNameKr,
      isReversed: isReversed,
      positionKey: positionKey,
    );
  }

  /// 스프레드와 위치에 따른 포지션 키 반환
  static String? _getPositionKey(TarotSpreadType spreadType, int position) {
    switch (spreadType) {
      case TarotSpreadType.single:
        return null;

      case TarotSpreadType.threeCard:
        final positions = ['past', 'present', 'future'];
        return positions[position];

      case TarotSpreadType.relationship:
        final positions = [
          'myFeelings',
          'theirFeelings',
          'pastConnection',
          'currentDynamic',
          'futureOutlook'
        ];
        return positions[position];

      case TarotSpreadType.celticCross:
        final positions = [
          'presentSituation',
          'challenge',
          'distantPast',
          'recentPast',
          'possibleOutcome',
          'immediateFuture',
          'yourApproach',
          'externalInfluences',
          'hopesAndFears',
          'finalOutcome'
        ];
        return positions[position];
    }
  }

  /// 포지션별 해석 생성
  static Map<String, String> _generatePositionInterpretations(
    TarotSpreadType spreadType,
    List<TarotCard> cards,
    String question,
  ) {
    final interpretations = <String, String>{};

    for (int i = 0; i < cards.length; i++) {
      final card = cards[i];
      final positionKey = card.positionKey ?? 'card_$i';

      // 카드와 포지션에 따른 해석 생성
      String interpretation = _generateCardInterpretation(
        card,
        spreadType,
        i,
        question,
      );

      interpretations[positionKey] = interpretation;
    }

    return interpretations;
  }

  /// 개별 카드 해석 생성
  static String _generateCardInterpretation(
    TarotCard card,
    TarotSpreadType spreadType,
    int position,
    String question,
  ) {
    // 메이저 아르카나 기본 의미 (간단한 예시)
    final majorMeanings = {
      0: '새로운 시작, 순수함, 모험',
      1: '의지력, 창조성, 능력',
      2: '직관, 내면의 지혜, 신비',
      3: '풍요, 창조, 모성',
      4: '권위, 안정, 리더십',
      5: '전통, 가르침, 영적 지도',
      6: '사랑, 선택, 조화',
      7: '결단력, 승리, 전진',
      8: '용기, 인내, 내면의 힘',
      9: '성찰, 지혜, 고독',
      10: '변화, 운명, 기회',
      11: '균형, 공정, 진실',
      12: '희생, 새로운 관점, 인내',
      13: '변화, 종료, 새로운 시작',
      14: '균형, 조화, 절제',
      15: '유혹, 집착, 물질주의',
      16: '급격한 변화, 깨달음, 충격',
      17: '희망, 영감, 평화',
      18: '환상, 두려움, 직관',
      19: '성공, 활력, 긍정',
      20: '부활, 평가, 새로운 단계',
      21: '완성, 성취, 통합',
    };

    String baseMeaning = '';

    if (card.category == CardCategory.major) {
      baseMeaning = majorMeanings[card.number] ?? '심오한 메시지';
    } else {
      // 마이너 아르카나 해석
      baseMeaning = _getMinorArcanaInterpretation(card);
    }

    // 역방향인 경우 의미 조정
    if (card.isReversed) {
      baseMeaning = '[역방향] 주의가 필요합니다. $baseMeaning의 반대되는 에너지가 작용하고 있습니다.';
    }

    // 포지션에 따른 해석 추가
    String positionContext = _getPositionContext(spreadType, position);

    return '$positionContext: ${card.fullName}\n$baseMeaning';
  }

  /// 마이너 아르카나 해석
  static String _getMinorArcanaInterpretation(TarotCard card) {
    final suitMeanings = {
      CardCategory.cups: '감정, 관계, 창의성',
      CardCategory.wands: '열정, 행동, 영감',
      CardCategory.swords: '사고, 소통, 갈등',
      CardCategory.pentacles: '물질, 실용, 안정',
    };

    final numberMeanings = {
      1: '새로운 시작',
      2: '균형과 선택',
      3: '성장과 협력',
      4: '안정과 기초',
      5: '도전과 갈등',
      6: '조화와 성공',
      7: '인내와 평가',
      8: '움직임과 변화',
      9: '거의 완성',
      10: '완성과 새로운 순환',
      11: '배움과 시작',
      12: '행동과 모험',
      13: '지혜와 양육',
      14: '통치와 완성',
    };

    final suit = suitMeanings[card.category] ?? '에너지';
    final number = numberMeanings[card.number] ?? '과정';

    return '$suit 영역에서 $number을 나타냅니다.';
  }

  /// 포지션 컨텍스트 반환
  static String _getPositionContext(TarotSpreadType spreadType, int position) {
    switch (spreadType) {
      case TarotSpreadType.single:
        return '핵심 메시지';

      case TarotSpreadType.threeCard:
        final contexts = ['과거의 영향', '현재 상황', '미래의 가능성'];
        return contexts[position];

      case TarotSpreadType.relationship:
        final contexts = [
          '당신의 마음',
          '상대방의 마음',
          '과거의 연결',
          '현재 관계',
          '미래 전망'
        ];
        return contexts[position];

      case TarotSpreadType.celticCross:
        final contexts = [
          '현재 상황',
          '도전 과제',
          '깊은 과거',
          '최근 과거',
          '가능한 미래',
          '가까운 미래',
          '당신의 접근',
          '외부 영향',
          '희망과 두려움',
          '최종 결과'
        ];
        return contexts[position];
    }
  }

  /// 전체 해석 생성 (스토리텔링)
  static String _generateOverallInterpretation(
    TarotSpreadType spreadType,
    List<TarotCard> cards,
    String question,
    Map<String, String> positionInterpretations,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('🔮 "$question"에 대한 타로 리딩 결과입니다.\n');

    switch (spreadType) {
      case TarotSpreadType.single:
        buffer.writeln('한 장의 카드가 전하는 메시지입니다.');
        break;

      case TarotSpreadType.threeCard:
        buffer.writeln('과거, 현재, 미래의 흐름을 통해 답을 찾아보세요.');
        buffer.writeln('\n시간의 흐름 속에서 보면:');
        buffer.writeln('• 과거의 ${cards[0].fullName}이(가) 현재의 기초를 만들었고,');
        buffer.writeln('• 현재의 ${cards[1].fullName}을(를) 통해 변화가 일어나고 있으며,');
        buffer.writeln('• 미래의 ${cards[2].fullName}이(가) 결과를 암시합니다.');
        break;

      case TarotSpreadType.relationship:
        buffer.writeln('관계의 다양한 측면을 살펴봅니다.');
        buffer.writeln('\n💕 관계 분석:');
        buffer.writeln('두 사람의 마음이 ${cards[0].fullName}과(와) ${cards[1].fullName}로 나타나며,');
        buffer.writeln('과거의 ${cards[2].fullName}이(가) 현재의 ${cards[3].fullName}을(를) 만들었습니다.');
        buffer.writeln('미래는 ${cards[4].fullName}의 에너지로 흘러갈 것입니다.');
        break;

      case TarotSpreadType.celticCross:
        buffer.writeln('켈틱 크로스 스프레드로 심층 분석합니다.');
        buffer.writeln('\n📊 종합 분석:');
        buffer.writeln('현재 ${cards[0].fullName}의 상황에서 ${cards[1].fullName}의 도전을 마주하고 있습니다.');
        buffer.writeln('${cards[9].fullName}이(가) 최종적인 결과를 암시합니다.');
        break;
    }

    // 조언 추가
    buffer.writeln('\n💡 조언:');
    if (cards.any((c) => c.isReversed)) {
      buffer.writeln('역방향 카드가 나타났습니다. 내면을 돌아보고 신중하게 접근하세요.');
    } else {
      buffer.writeln('정방향 카드들이 긍정적인 에너지를 보여줍니다. 자신감을 가지세요.');
    }

    return buffer.toString();
  }
}