/// Tarot Position Meanings - 메인 통합 클래스
/// 78장 타로 카드의 모든 스프레드 타입별 해석을 통합 관리합니다.
///
/// 스프레드 타입:
/// - Celtic Cross: 10개 위치 (78장 × 10위치 × 2방향 = 1,560개)
/// - Three Card: 3개 위치 (78장 × 3위치 × 2방향 = 468개)
/// - Relationship: 5개 위치 (78장 × 5위치 × 2방향 = 780개)
/// - Single: 1개 위치 (78장 × 1위치 × 2방향 = 156개)
///
/// 총 2,964개 해석 문구

// Celtic Cross 파일들
import 'positions/celtic_cross_major_arcana.dart';
import 'positions/celtic_cross_wands.dart';
import 'positions/celtic_cross_cups.dart';
import 'positions/celtic_cross_swords.dart';
import 'positions/celtic_cross_pentacles.dart';

// 기타 스프레드 파일들
import 'positions/three_card_meanings.dart';
import 'positions/relationship_meanings.dart';
import 'positions/single_card_meanings.dart';

/// 스프레드 타입 enum
enum TarotSpreadType {
  celticCross,
  threeCard,
  relationship,
  single,
}

/// 카드 방향 enum
enum CardOrientation {
  upright,
  reversed,
}

/// 타로 카드 위치별 해석을 통합 관리하는 클래스
class TarotPositionMeanings {
  /// Celtic Cross 스프레드의 위치 키 목록
  static const List<String> celticCrossPositions = [
    'presentSituation', // 0: 현재 상황
    'challenge', // 1: 도전/장애물
    'distantPast', // 2: 먼 과거
    'recentPast', // 3: 최근 과거
    'bestOutcome', // 4: 최선의 결과
    'nearFuture', // 5: 가까운 미래
    'selfView', // 6: 자기 인식
    'environment', // 7: 환경/주변
    'hopesAndFears', // 8: 희망과 두려움
    'finalOutcome', // 9: 최종 결과
  ];

  /// Three Card 스프레드의 위치 키 목록
  static const List<String> threeCardPositions = [
    'past', // 0: 과거
    'present', // 1: 현재
    'future', // 2: 미래
  ];

  /// Relationship 스프레드의 위치 키 목록
  static const List<String> relationshipPositions = [
    'you', // 0: 당신
    'partner', // 1: 상대방
    'relationship', // 2: 관계
    'challenges', // 3: 도전
    'advice', // 4: 조언
  ];

  /// Single Card 스프레드의 위치 키 목록
  static const List<String> singleCardPositions = [
    'general', // 0: 일반
  ];

  /// 스프레드 타입에 따른 위치 키 목록 반환
  static List<String> getPositionKeys(TarotSpreadType spreadType) {
    switch (spreadType) {
      case TarotSpreadType.celticCross:
        return celticCrossPositions;
      case TarotSpreadType.threeCard:
        return threeCardPositions;
      case TarotSpreadType.relationship:
        return relationshipPositions;
      case TarotSpreadType.single:
        return singleCardPositions;
    }
  }

  /// 메인 해석 가져오기 함수
  /// [cardIndex] 카드 인덱스 (0-77)
  /// [spreadType] 스프레드 타입
  /// [positionIndex] 위치 인덱스
  /// [isReversed] 역방향 여부 (기본값: false)
  static String? getInterpretation({
    required int cardIndex,
    required TarotSpreadType spreadType,
    required int positionIndex,
    bool isReversed = false,
  }) {
    // 위치 키 목록 가져오기
    final positionKeys = getPositionKeys(spreadType);

    // 위치 인덱스 범위 검증
    if (positionIndex < 0 || positionIndex >= positionKeys.length) {
      return null;
    }

    final position = positionKeys[positionIndex];
    final orientation = isReversed ? 'reversed' : 'upright';

    // 스프레드 타입에 따라 적절한 데이터 소스에서 해석 가져오기
    switch (spreadType) {
      case TarotSpreadType.celticCross:
        return _getCelticCrossInterpretation(cardIndex, orientation, position);
      case TarotSpreadType.threeCard:
        return ThreeCardMeanings.getInterpretation(
            cardIndex, orientation, position);
      case TarotSpreadType.relationship:
        return RelationshipMeanings.getInterpretation(
            cardIndex, orientation, position);
      case TarotSpreadType.single:
        return SingleCardMeanings.getInterpretation(
            cardIndex, orientation, position);
    }
  }

  /// 위치 이름으로 해석 가져오기 (문자열 기반)
  /// [cardIndex] 카드 인덱스 (0-77)
  /// [spreadType] 스프레드 타입
  /// [positionName] 위치 이름 (예: 'presentSituation', 'past', 'you', 'general')
  /// [isReversed] 역방향 여부
  static String? getInterpretationByName({
    required int cardIndex,
    required TarotSpreadType spreadType,
    required String positionName,
    bool isReversed = false,
  }) {
    final orientation = isReversed ? 'reversed' : 'upright';

    switch (spreadType) {
      case TarotSpreadType.celticCross:
        return _getCelticCrossInterpretation(
            cardIndex, orientation, positionName);
      case TarotSpreadType.threeCard:
        return ThreeCardMeanings.getInterpretation(
            cardIndex, orientation, positionName);
      case TarotSpreadType.relationship:
        return RelationshipMeanings.getInterpretation(
            cardIndex, orientation, positionName);
      case TarotSpreadType.single:
        return SingleCardMeanings.getInterpretation(
            cardIndex, orientation, positionName);
    }
  }

  /// Celtic Cross 해석 가져오기 (카드 범위에 따라 적절한 파일에서 가져옴)
  static String? _getCelticCrossInterpretation(
      int cardIndex, String orientation, String position) {
    final isReversed = orientation == 'reversed';

    if (cardIndex >= 0 && cardIndex <= 21) {
      // Major Arcana (0-21)
      return CelticCrossMajorArcana.getInterpretation(
        cardIndex: cardIndex,
        position: position,
        isReversed: isReversed,
      );
    } else if (cardIndex >= 22 && cardIndex <= 35) {
      // Wands (22-35)
      return CelticCrossWands.getInterpretation(
        cardIndex: cardIndex,
        position: position,
        isReversed: isReversed,
      );
    } else if (cardIndex >= 36 && cardIndex <= 49) {
      // Cups (36-49)
      return CelticCrossCups.getInterpretation(
        cardIndex: cardIndex,
        position: position,
        isReversed: isReversed,
      );
    } else if (cardIndex >= 50 && cardIndex <= 63) {
      // Swords (50-63)
      return CelticCrossSwords.getInterpretation(
        cardIndex: cardIndex,
        position: position,
        isReversed: isReversed,
      );
    } else if (cardIndex >= 64 && cardIndex <= 77) {
      // Pentacles (64-77)
      return CelticCrossPentacles.getInterpretation(
        cardIndex: cardIndex,
        position: position,
        isReversed: isReversed,
      );
    }
    return null;
  }

  /// 위치 인덱스를 한국어 이름으로 변환
  static String getPositionDisplayName(
      TarotSpreadType spreadType, int positionIndex) {
    switch (spreadType) {
      case TarotSpreadType.celticCross:
        const names = [
          '현재 상황',
          '도전/장애물',
          '먼 과거',
          '최근 과거',
          '최선의 결과',
          '가까운 미래',
          '자기 인식',
          '주변 환경',
          '희망과 두려움',
          '최종 결과',
        ];
        return positionIndex < names.length
            ? names[positionIndex]
            : '알 수 없음';

      case TarotSpreadType.threeCard:
        const names = ['과거', '현재', '미래'];
        return positionIndex < names.length
            ? names[positionIndex]
            : '알 수 없음';

      case TarotSpreadType.relationship:
        const names = ['당신', '상대방', '관계', '도전', '조언'];
        return positionIndex < names.length
            ? names[positionIndex]
            : '알 수 없음';

      case TarotSpreadType.single:
        return '일반 해석';
    }
  }

  /// 스프레드 타입을 한국어 이름으로 변환
  static String getSpreadDisplayName(TarotSpreadType spreadType) {
    switch (spreadType) {
      case TarotSpreadType.celticCross:
        return '켈틱 크로스';
      case TarotSpreadType.threeCard:
        return '쓰리 카드';
      case TarotSpreadType.relationship:
        return '연애 스프레드';
      case TarotSpreadType.single:
        return '싱글 카드';
    }
  }

  /// 스프레드 타입별 위치 개수 반환
  static int getPositionCount(TarotSpreadType spreadType) {
    return getPositionKeys(spreadType).length;
  }

  /// 카드 인덱스 유효성 검증
  static bool isValidCardIndex(int cardIndex) {
    return cardIndex >= 0 && cardIndex <= 77;
  }

  /// 문자열 스프레드 타입을 enum으로 변환
  static TarotSpreadType? parseSpreadType(String spreadTypeStr) {
    switch (spreadTypeStr.toLowerCase()) {
      case 'celtic':
      case 'celticcross':
      case 'celtic_cross':
      case 'celtic-cross':
        return TarotSpreadType.celticCross;
      case 'three':
      case 'threecard':
      case 'three_card':
      case 'three-card':
        return TarotSpreadType.threeCard;
      case 'relationship':
      case 'love':
        return TarotSpreadType.relationship;
      case 'single':
      case 'singlecard':
      case 'single_card':
      case 'one':
        return TarotSpreadType.single;
      default:
        return null;
    }
  }
}
