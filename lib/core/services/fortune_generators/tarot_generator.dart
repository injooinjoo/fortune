import '../../models/fortune_result.dart';
import '../../../features/fortune/domain/models/tarot_card_model.dart';
import '../../../features/fortune/services/tarot_service.dart';

/// 타로 카드 운세 생성기
///
/// UnifiedFortuneService와 통합되어 표준화된 타로 운세를 생성합니다.
/// - 기존 TarotService의 로직을 재사용
/// - input_conditions를 FortuneResult로 변환
/// - 중복 방지를 위한 조건 정규화
class TarotGenerator {
  /// 타로 운세 생성
  ///
  /// **input_conditions 형식**:
  /// ```json
  /// {
  ///   "spread_type": "threeCard",  // single, threeCard, relationship, celticCross
  ///   "deck_type": "riderWaite",   // riderWaite, marseille, thoth 등
  ///   "question": "오늘의 연애운은?"
  /// }
  /// ```
  static Future<FortuneResult> generate(
    Map<String, dynamic> inputConditions,
  ) async {
    // 1. 조건 추출
    final spreadTypeStr =
        inputConditions['spread_type'] as String? ?? 'threeCard';
    final deckTypeStr = inputConditions['deck_type'] as String? ?? 'riderWaite';
    final question = inputConditions['question'] as String? ?? '오늘의 운세는 어떤가요?';

    // 2. Enum 변환
    final spreadType = _parseSpreadType(spreadTypeStr);
    final deckType = _parseDeckType(deckTypeStr);

    // 3. 기존 TarotService를 사용해서 카드 뽑기
    final tarotResult = TarotService.drawCards(
      spreadType: spreadType,
      question: question,
      deck: deckType,
    );

    // 4. FortuneResult로 변환
    return _convertToFortuneResult(tarotResult, spreadType, question);
  }

  /// 타로 스프레드 타입 파싱
  static TarotSpreadType _parseSpreadType(String spreadTypeStr) {
    switch (spreadTypeStr.toLowerCase()) {
      case 'single':
        return TarotSpreadType.single;
      case 'threecard':
      case 'three_card':
        return TarotSpreadType.threeCard;
      case 'relationship':
        return TarotSpreadType.relationship;
      case 'celticcross':
      case 'celtic_cross':
        return TarotSpreadType.celticCross;
      default:
        return TarotSpreadType.threeCard; // 기본값
    }
  }

  /// 타로 덱 타입 파싱
  static TarotDeckType _parseDeckType(String deckTypeStr) {
    switch (deckTypeStr.toLowerCase()) {
      case 'riderwaite':
      case 'rider_waite':
        return TarotDeckType.riderWaite;
      case 'thoth':
        return TarotDeckType.thoth;
      case 'ancient_italian':
      case 'ancientitalian':
        return TarotDeckType.ancientItalian;
      case 'after_tarot':
      case 'aftertarot':
        return TarotDeckType.afterTarot;
      case 'before_tarot':
      case 'beforetarot':
        return TarotDeckType.beforeTarot;
      case 'golden_dawn_cicero':
      case 'goldendawncicero':
        return TarotDeckType.goldenDawnCicero;
      case 'golden_dawn_wang':
      case 'goldendawnwang':
        return TarotDeckType.goldenDawnWang;
      case 'grand_etteilla':
      case 'grandetteilla':
        return TarotDeckType.grandEtteilla;
      default:
        return TarotDeckType.riderWaite; // 기본값
    }
  }

  /// TarotSpreadResult를 FortuneResult로 변환
  static FortuneResult _convertToFortuneResult(
    TarotSpreadResult tarotResult,
    TarotSpreadType spreadType,
    String question,
  ) {
    // 카드 정보를 JSON 형식으로 변환
    final cardsData = tarotResult.cards.map((card) {
      return {
        'deck_type': card.deckType.name,
        'category': card.category.name,
        'number': card.number,
        'card_name': card.cardName,
        'card_name_kr': card.cardNameKr,
        'full_name': card.fullName,
        'is_reversed': card.isReversed,
        'position_key': card.positionKey,
        'image_path': card.imagePath,
      };
    }).toList();

    // 전체 데이터
    final data = {
      'spread_type': spreadType.name,
      'question': question,
      'cards': cardsData,
      'position_interpretations': tarotResult.positionInterpretations,
      'overall_interpretation': tarotResult.overallInterpretation,
      'timestamp': tarotResult.timestamp.toIso8601String(),
    };

    // 요약 정보
    final summary = {
      'card_count': tarotResult.cards.length,
      'reversed_count': tarotResult.cards.where((c) => c.isReversed).length,
      'spread_name': _getSpreadKoreanName(spreadType),
      'main_message': _extractMainMessage(tarotResult),
    };

    // 점수 계산 (정방향 카드 비율 기반)
    final score = _calculateScore(tarotResult);

    return FortuneResult(
      type: 'tarot',
      title: '타로 카드 운세',
      summary: summary,
      data: data,
      score: score,
      createdAt: tarotResult.timestamp,
    );
  }

  /// 스프레드 타입 한글명
  static String _getSpreadKoreanName(TarotSpreadType type) {
    switch (type) {
      case TarotSpreadType.single:
        return '원 카드 스프레드';
      case TarotSpreadType.threeCard:
        return '과거-현재-미래 스프레드';
      case TarotSpreadType.relationship:
        return '관계 스프레드';
      case TarotSpreadType.celticCross:
        return '켈틱 크로스 스프레드';
    }
  }

  /// 메인 메시지 추출
  static String _extractMainMessage(TarotSpreadResult result) {
    final lines = result.overallInterpretation.split('\n');
    // "🔮" 이후 첫 번째 실질적인 문장 추출
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty &&
          !trimmed.startsWith('🔮') &&
          !trimmed.startsWith('•') &&
          !trimmed.startsWith('💡')) {
        return trimmed;
      }
    }
    return '타로 카드가 당신에게 메시지를 전합니다.';
  }

  /// 점수 계산 (정방향 카드 비율 기반)
  static int _calculateScore(TarotSpreadResult result) {
    if (result.cards.isEmpty) return 50;

    final totalCards = result.cards.length;
    final reversedCount = result.cards.where((c) => c.isReversed).length;
    final uprightCount = totalCards - reversedCount;

    // 정방향 비율로 점수 계산 (40 ~ 95점)
    // 100% 정방향 = 95점
    // 50% 정방향 = 67점
    // 0% 정방향 = 40점
    final uprightRatio = uprightCount / totalCards;
    final score = (40 + (uprightRatio * 55)).round();

    return score.clamp(0, 100);
  }
}
