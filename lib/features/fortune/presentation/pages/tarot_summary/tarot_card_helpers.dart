class TarotCardHelpers {
  static String getCardImagePath(int cardIndex) {
    // Use before_tarot deck (actual images available)
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
        'world',
      ];
      return '$deckPath/major/${cardIndex.toString().padLeft(2, '0')}_${cardNames[cardIndex]}.jpg';
    } else if (cardIndex < 36) {
      // Wands
      final wandsIndex = cardIndex - 21;
      if (wandsIndex <= 10) {
        return '$deckPath/wands/${wandsIndex.toString().padLeft(2, '0')}_of_wands.jpg';
      } else {
        // Court cards: 숫자 프리픽스 없이 파일명만 사용
        return '$deckPath/wands/${_getCourtCardName(wandsIndex, 'wands')}.jpg';
      }
    } else if (cardIndex < 50) {
      // Cups
      final cupsIndex = cardIndex - 35;
      if (cupsIndex <= 10) {
        return '$deckPath/cups/${cupsIndex.toString().padLeft(2, '0')}_of_cups.jpg';
      } else {
        // Court cards: 숫자 프리픽스 없이 파일명만 사용
        return '$deckPath/cups/${_getCourtCardName(cupsIndex, 'cups')}.jpg';
      }
    } else if (cardIndex < 64) {
      // Swords
      final swordsIndex = cardIndex - 49;
      if (swordsIndex <= 10) {
        return '$deckPath/swords/${swordsIndex.toString().padLeft(2, '0')}_of_swords.jpg';
      } else {
        // Court cards: 숫자 프리픽스 없이 파일명만 사용
        return '$deckPath/swords/${_getCourtCardName(swordsIndex, 'swords')}.jpg';
      }
    } else {
      // Pentacles
      final pentaclesIndex = cardIndex - 63;
      if (pentaclesIndex <= 10) {
        return '$deckPath/pentacles/${pentaclesIndex.toString().padLeft(2, '0')}_of_pentacles.jpg';
      } else {
        // Court cards: 숫자 프리픽스 없이 파일명만 사용
        return '$deckPath/pentacles/${_getCourtCardName(pentaclesIndex, 'pentacles')}.jpg';
      }
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
