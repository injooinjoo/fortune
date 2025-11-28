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
      final cardName = wandsIndex <= 10 ? 'of_wands' : _getCourtCardName(wandsIndex, 'wands');
      return '$deckPath/wands/${wandsIndex.toString().padLeft(2, '0')}_$cardName.jpg';
    } else if (cardIndex < 50) {
      // Cups
      final cupsIndex = cardIndex - 35;
      final cardName = cupsIndex <= 10 ? 'of_cups' : _getCourtCardName(cupsIndex, 'cups');
      return '$deckPath/cups/${cupsIndex.toString().padLeft(2, '0')}_$cardName.jpg';
    } else if (cardIndex < 64) {
      // Swords
      final swordsIndex = cardIndex - 49;
      final cardName = swordsIndex <= 10 ? 'of_swords' : _getCourtCardName(swordsIndex, 'swords');
      return '$deckPath/swords/${swordsIndex.toString().padLeft(2, '0')}_$cardName.jpg';
    } else {
      // Pentacles
      final pentaclesIndex = cardIndex - 63;
      final cardName = pentaclesIndex <= 10 ? 'of_pentacles' : _getCourtCardName(pentaclesIndex, 'pentacles');
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
