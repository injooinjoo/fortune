import 'character_voice_profile_registry.dart';

/// 캐릭터 톤 롤아웃 설정 (앱 기본값 사용, Firebase Remote Config 미사용)
class CharacterToneRolloutConfig {
  final Set<String> enabledCharacterIds;
  final Set<String> idleIcebreakerCharacterIds;

  const CharacterToneRolloutConfig({
    required this.enabledCharacterIds,
    required this.idleIcebreakerCharacterIds,
  });
}

/// 캐릭터 톤/스타일 가드·아이스브레이커 적용 대상.
///
/// Firebase Remote Config 대신 앱 기본값(스토리 캐릭터 전원)만 사용합니다.
/// 추후 Supabase feature_flags 등으로 오버라이드할 수 있도록 resolve()를 확장할 수 있습니다.
class CharacterToneRollout {
  /// 스토리 캐릭터 전원에 톤/스타일 가드 적용 (CharacterVoiceProfileRegistry.storyCharacterIds와 동기화)
  static Set<String> get _defaultEnabledCharacterIds =>
      CharacterVoiceProfileRegistry.storyCharacterIds;

  static Set<String> get _defaultIdleIcebreakerCharacterIds =>
      CharacterVoiceProfileRegistry.storyCharacterIds;

  /// 현재 적용 중인 롤아웃 설정 (앱 기본값).
  static CharacterToneRolloutConfig resolve() {
    return CharacterToneRolloutConfig(
      enabledCharacterIds: _defaultEnabledCharacterIds,
      idleIcebreakerCharacterIds: _defaultIdleIcebreakerCharacterIds,
    );
  }

  static bool isEnabledCharacter(String characterId) {
    return _defaultEnabledCharacterIds.contains(characterId);
  }

  static bool isIdleIcebreakerEnabledCharacter(String characterId) {
    return _defaultIdleIcebreakerCharacterIds.contains(characterId);
  }
}
