import 'package:flutter/material.dart';
import '../../theme/toss_design_system.dart';
import 'tarot_metadata_data.dart';

// TarotHelper utility class
class TarotHelper {
  static String getCardImagePath(int cardId) {
    return 'assets/images/tarot/card_$cardId.png';
  }

  static Color getElementColor(String element) {
    switch (element.toLowerCase()) {
      case '불':
      case 'fire':
      case 'wands':
        return TossDesignSystem.error;
      case '물':
      case 'water':
      case 'cups':
        return TossDesignSystem.tossBlue;
      case '공기':
      case 'air':
      case 'swords':
        return TossDesignSystem.warningYellow;
      case '땅':
      case 'earth':
      case 'pentacles':
        return TossDesignSystem.success;
      default:
        return TossDesignSystem.purple;
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