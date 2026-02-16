import '../../../../services/remote_config_service.dart';

class CharacterToneRolloutConfig {
  final Set<String> enabledCharacterIds;
  final Set<String> idleIcebreakerCharacterIds;

  const CharacterToneRolloutConfig({
    required this.enabledCharacterIds,
    required this.idleIcebreakerCharacterIds,
  });
}

class CharacterToneRollout {
  static const Set<String> _defaultEnabledCharacterIds = {
    'luts',
    'jung_tae_yoon',
    'seo_yoonjae',
    'han_seojun',
  };

  static const Set<String> _defaultIdleIcebreakerCharacterIds = {
    'luts',
    'jung_tae_yoon',
    'seo_yoonjae',
    'han_seojun',
  };

  static CharacterToneRolloutConfig resolve({
    required RemoteConfigService remoteConfig,
  }) {
    final map = remoteConfig.getCharacterToneRolloutConfig();

    final enabled = _readStringSet(
      map: map,
      key: 'enabledCharacterIds',
      fallback: _defaultEnabledCharacterIds,
    );

    final idleEnabled = _readStringSet(
      map: map,
      key: 'idleIcebreakerCharacterIds',
      fallback: _defaultIdleIcebreakerCharacterIds,
    );

    return CharacterToneRolloutConfig(
      enabledCharacterIds: enabled,
      idleIcebreakerCharacterIds: idleEnabled,
    );
  }

  static bool isEnabledCharacter(
    String characterId, {
    required RemoteConfigService remoteConfig,
  }) {
    final config = resolve(remoteConfig: remoteConfig);
    return config.enabledCharacterIds.contains(characterId);
  }

  static bool isIdleIcebreakerEnabledCharacter(
    String characterId, {
    required RemoteConfigService remoteConfig,
  }) {
    final config = resolve(remoteConfig: remoteConfig);
    return config.idleIcebreakerCharacterIds.contains(characterId);
  }

  static Set<String> _readStringSet({
    required Map<String, dynamic> map,
    required String key,
    required Set<String> fallback,
  }) {
    final raw = map[key];
    if (raw is! List) return fallback;

    final values = raw.map((e) => e.toString()).where((e) => e.isNotEmpty);
    final set = values.toSet();
    if (set.isEmpty) return fallback;
    return set;
  }
}
