import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'tarot_metadata_data.dart';

// TarotHelper utility class
class TarotHelper {
  // 메이저 아르카나 파일 이름 매핑
  static const List<String> _majorArcanaFileNames = [
    '00_fool.jpg',
    '01_magician.jpg',
    '02_high_priestess.jpg',
    '03_empress.jpg',
    '04_emperor.jpg',
    '05_hierophant.jpg',
    '06_lovers.jpg',
    '07_chariot.jpg',
    '08_strength.jpg',
    '09_hermit.jpg',
    '10_wheel_of_fortune.jpg',
    '11_justice.jpg',
    '12_hanged_man.jpg',
    '13_death.jpg',
    '14_temperance.jpg',
    '15_devil.jpg',
    '16_tower.jpg',
    '17_star.jpg',
    '18_moon.jpg',
    '19_sun.jpg',
    '20_judgement.jpg',
    '21_world.jpg',
  ];

  /// 카드 인덱스에 해당하는 메이저 아르카나 파일 이름 반환
  static String getMajorArcanaFileName(int cardIndex) {
    if (cardIndex >= 0 && cardIndex < _majorArcanaFileNames.length) {
      return _majorArcanaFileNames[cardIndex];
    }
    // 범위 밖이면 모듈로 연산으로 순환
    return _majorArcanaFileNames[cardIndex % _majorArcanaFileNames.length];
  }

  /// 덱과 카드 인덱스로 전체 이미지 경로 반환
  static String getMajorArcanaImagePath(String deckId, int cardIndex) {
    final fileName = getMajorArcanaFileName(cardIndex);
    return 'assets/images/tarot/decks/$deckId/major/$fileName';
  }

  static String getCardImagePath(int cardId) {
    return 'assets/images/tarot/card_$cardId.png';
  }

  static Color getElementColor(String element) {
    switch (element.toLowerCase()) {
      case '불':
      case 'fire':
      case 'wands':
        return DSColors.error;
      case '물':
      case 'water':
      case 'cups':
        return DSColors.accentDark;
      case '공기':
      case 'air':
      case 'swords':
        return DSColors.warning;
      case '땅':
      case 'earth':
      case 'pentacles':
        return DSColors.success;
      default:
        return DSColors.accentTertiary;
    }
  }

  static IconData getElementIcon(String element) {
    switch (element.toLowerCase()) {
      case '불':
      case 'fire':
      case 'wands':
        return Icons.local_fire_department;
      case '물':
      case 'water':
      case 'cups':
        return Icons.water_drop;
      case '공기':
      case 'air':
      case 'swords':
        return Icons.air;
      case '땅':
      case 'earth':
      case 'pentacles':
        return Icons.terrain;
      default:
        return Icons.auto_awesome;
    }
  }

  static String getPositionDescription(String spreadType, int position) {
    final spread = TarotMetadata.spreads[spreadType];
    if (spread != null && position < spread.positions.length) {
      return spread.positions[position];
    }
    return '위치 ${position + 1}';
  }

  static List<String> getRelatedCards(int cardId) {
    // 수비학적 관련 카드 찾기
    final numerology = TarotMetadata.majorArcana[cardId]?.numerology ?? 0;
    final related = <String>[];
    
    // 같은 숫자의 마이너 아르카나 카드들
    if (numerology > 0 && numerology <= 10) {
      related.add('$numerology of Wands');
      related.add('$numerology of Cups');
      related.add('$numerology of Swords');
      related.add('$numerology of Pentacles');
    }
    
    // 수비학적 환원 (예: 13 Death -> 4 Emperor)
    if (numerology > 9) {
      final reduced = numerology.toString().split('').map(int.parse).reduce((a, b) => a + b);
      final reducedCard = TarotMetadata.majorArcana.values.firstWhere(
        (card) => card.numerology == reduced,
        orElse: () => TarotMetadata.majorArcana[0]!
      );
      related.add(reducedCard.name);
    }
    
    return related;
  }
}