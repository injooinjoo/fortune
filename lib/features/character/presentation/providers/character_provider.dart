import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/default_characters.dart';
import '../../domain/models/ai_character.dart';
import '../../../../features/chat/domain/models/recommendation_chip.dart';

/// 전체 캐릭터 목록 Provider
final charactersProvider = Provider<List<AiCharacter>>((ref) {
  return defaultCharacters;
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
