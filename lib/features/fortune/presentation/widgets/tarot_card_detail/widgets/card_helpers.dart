import 'package:fortune/core/constants/tarot_metadata.dart';
import 'package:fortune/core/constants/tarot_minor_arcana.dart';

class TarotCardHelpers {
  static Map<String, dynamic> getCardInfo(int cardIndex) {
    // Major Arcana (0-21)
    if (cardIndex < 22) {
      final majorCard = TarotMetadata.majorArcana[cardIndex];
      if (majorCard != null) {
        return {
          'name': majorCard.name,
          'keywords': majorCard.keywords,
          'element': majorCard.element,
          'astrology': majorCard.astrology,
          'numerology': majorCard.numerology,
          'imagery': majorCard.imagery,
          'uprightMeaning': majorCard.uprightMeaning,
          'reversedMeaning': majorCard.reversedMeaning,
          'advice': majorCard.advice,
          'questions': majorCard.questions,
          'relatedCards': null,
        };
      }
    }

    // Minor Arcana (22-77)
    TarotCardInfo? minorCard;

    // Wands (22-35)
    if (cardIndex >= 22 && cardIndex < 36) {
      final wandsCards = TarotMinorArcana.wands.values.toList();
      final index = cardIndex - 22;
      if (index < wandsCards.length) {
        minorCard = wandsCards[index];
      }
    }
    // Cups (36-49)
    else if (cardIndex >= 36 && cardIndex < 50) {
      final cupsCards = TarotMinorArcana.cups.values.toList();
      final index = cardIndex - 36;
      if (index < cupsCards.length) {
        minorCard = cupsCards[index];
      }
    }
    // Swords (50-63)
    else if (cardIndex >= 50 && cardIndex < 64) {
      final swordsCards = TarotMinorArcana.swords.values.toList();
      final index = cardIndex - 50;
      if (index < swordsCards.length) {
        minorCard = swordsCards[index];
      }
    }
    // Pentacles (64-77)
    else if (cardIndex >= 64 && cardIndex < 78) {
      final pentaclesCards = TarotMinorArcana.pentacles.values.toList();
      final index = cardIndex - 64;
      if (index < pentaclesCards.length) {
        minorCard = pentaclesCards[index];
      }
    }

    if (minorCard != null) {
      return {
        'name': minorCard.name,
        'keywords': minorCard.keywords,
        'element': minorCard.element,
        'astrology': minorCard.astrology,
        'numerology': minorCard.numerology,
        'imagery': minorCard.imagery,
        'uprightMeaning': minorCard.uprightMeaning,
        'reversedMeaning': minorCard.reversedMeaning,
        'advice': minorCard.advice,
        'questions': minorCard.questions,
        'relatedCards': null,
      };
    }

    // Fallback
    return {
      'name': 'Unknown Card',
      'element': 'Mystery',
    };
  }

  static String getCardImagePath(int cardIndex) {
    // Default to before_tarot deck
    const deckPath = 'decks/before_tarot';

    if (cardIndex < 22) {
      // Major Arcana
      final cardNames = [
        'fool',
        'magician',
        'high_priestess',
        'empress',
        'emperor',
        'hierophant',
        'lovers',
        'chariot',
        'strength',
        'hermit',
        'wheel_of_fortune',
        'justice',
        'hanged_man',
        'death',
        'temperance',
        'devil',
        'tower',
        'star',
        'moon',
        'sun',
        'judgement',
        'world'
      ];
      return '$deckPath/major/${cardIndex.toString().padLeft(2, '0')}_${cardNames[cardIndex]}.jpg';
    } else if (cardIndex < 36) {
      // Wands
      final wandsIndex = cardIndex - 21;
      final cardName = wandsIndex <= 10
          ? 'of_wands'
          : _getCourtCardName(wandsIndex, 'wands');
      return '$deckPath/wands/${wandsIndex.toString().padLeft(2, '0')}_$cardName.jpg';
    } else if (cardIndex < 50) {
      // Cups
      final cupsIndex = cardIndex - 35;
      final cardName =
          cupsIndex <= 10 ? 'of_cups' : _getCourtCardName(cupsIndex, 'cups');
      return '$deckPath/cups/${cupsIndex.toString().padLeft(2, '0')}_$cardName.jpg';
    } else if (cardIndex < 64) {
      // Swords
      final swordsIndex = cardIndex - 49;
      final cardName = swordsIndex <= 10
          ? 'of_swords'
          : _getCourtCardName(swordsIndex, 'swords');
      return '$deckPath/swords/${swordsIndex.toString().padLeft(2, '0')}_$cardName.jpg';
    } else {
      // Pentacles
      final pentaclesIndex = cardIndex - 63;
      final cardName = pentaclesIndex <= 10
          ? 'of_pentacles'
          : _getCourtCardName(pentaclesIndex, 'pentacles');
      return '$deckPath/pentacles/${pentaclesIndex.toString().padLeft(2, '0')}_$cardName.jpg';
    }
  }

  static String _getCourtCardName(int index, String suit) {
    switch (index) {
      case 11:
        return 'page_of_$suit';
      case 12:
        return 'knight_of_$suit';
      case 13:
        return 'queen_of_$suit';
      case 14:
        return 'king_of_$suit';
      default:
        return 'of_$suit';
    }
  }
}
