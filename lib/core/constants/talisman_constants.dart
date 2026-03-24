class TalismanGenerationMode {
  static const String prebuilt = 'prebuilt';
  static const String premiumAi = 'premium_ai';

  static const Set<String> values = {
    prebuilt,
    premiumAi,
  };

  static bool isValid(String? value) => values.contains(value);
}

class TalismanTierCosts {
  static const int prebuilt = 2;
  static const int premiumAi = 10;

  static int forGenerationMode(String? generationMode) {
    switch (generationMode) {
      case TalismanGenerationMode.prebuilt:
        return prebuilt;
      case TalismanGenerationMode.premiumAi:
      default:
        return premiumAi;
    }
  }
}
