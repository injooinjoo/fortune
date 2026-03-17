class ActiveCharacterChatRegistry {
  ActiveCharacterChatRegistry._();

  static String? _activeCharacterId;

  static String? get activeCharacterId => _activeCharacterId;

  static void setActiveCharacterId(String? characterId) {
    _activeCharacterId = characterId;
  }

  static bool isActive(String? characterId) {
    return characterId != null && _activeCharacterId == characterId;
  }
}
