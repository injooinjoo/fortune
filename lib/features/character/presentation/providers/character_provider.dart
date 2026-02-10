import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/default_characters.dart';
import '../../data/fortune_characters.dart';
import '../../domain/models/ai_character.dart';
import '../../../../features/chat/domain/models/recommendation_chip.dart';

/// 전체 캐릭터 목록 Provider (스토리 + 운세)
final charactersProvider = Provider<List<AiCharacter>>((ref) {
  return [...defaultCharacters, ...fortuneCharacters];
});

/// 스토리 캐릭터만 (로맨스/스토리)
final storyCharactersProvider = Provider<List<AiCharacter>>((ref) {
  return defaultCharacters.where((c) => c.characterType == CharacterType.story).toList();
});

/// 운세 전문가 캐릭터만
final fortuneCharactersProvider = Provider<List<AiCharacter>>((ref) {
  return fortuneCharacters.where((c) => c.characterType == CharacterType.fortune).toList();
});

/// 캐릭터 목록 탭
enum CharacterListTab { story, fortune }

/// 현재 선택된 캐릭터 목록 탭 (스토리가 기본값)
final characterListTabProvider = StateProvider<CharacterListTab>((ref) => CharacterListTab.story);

/// 현재 탭에 맞는 캐릭터 목록
final currentTabCharactersProvider = Provider<List<AiCharacter>>((ref) {
  final tab = ref.watch(characterListTabProvider);
  switch (tab) {
    case CharacterListTab.story:
      return ref.watch(storyCharactersProvider);
    case CharacterListTab.fortune:
      return ref.watch(fortuneCharactersProvider);
  }
});

/// 선택된 운세 칩 Provider (FortuneListPanel에서 선택 시 설정)
/// ChatHomePage에서 감시하고 설문 시작 후 null로 리셋
final pendingFortuneChipProvider = StateProvider<RecommendationChip?>((ref) => null);

/// 현재 선택된 캐릭터 Provider
final selectedCharacterProvider = StateProvider<AiCharacter?>((ref) => null);

/// 채팅 모드 (운세 vs 캐릭터)
enum ChatMode { fortune, character }

/// 현재 채팅 모드 Provider
final chatModeProvider = StateProvider<ChatMode>((ref) => ChatMode.fortune);

/// 캐릭터 ID로 캐릭터 찾기
final characterByIdProvider = Provider.family<AiCharacter?, String>((ref, id) {
  final characters = ref.watch(charactersProvider);
  try {
    return characters.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
});

/// 운세 타입으로 전문 캐릭터 찾기
final fortuneExpertByTypeProvider = Provider.family<AiCharacter?, String>((ref, fortuneType) {
  return findFortuneExpert(fortuneType);
});

/// 카테고리로 전문 캐릭터 찾기
final categoryExpertProvider = Provider.family<AiCharacter?, String>((ref, category) {
  return findCategoryExpert(category);
});
