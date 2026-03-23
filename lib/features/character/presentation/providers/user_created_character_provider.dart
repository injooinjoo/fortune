import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/services/user_created_character_repository.dart';
import '../../domain/models/ai_character.dart';
import '../../domain/models/user_created_character.dart';

final userCreatedCharacterRepositoryProvider =
    Provider<UserCreatedCharacterRepository>((ref) {
  return UserCreatedCharacterRepository();
});

final userCreatedCharactersProvider = StateNotifierProvider<
    UserCreatedCharactersNotifier, List<UserCreatedCharacter>>(
  (ref) => UserCreatedCharactersNotifier(
    ref.read(userCreatedCharacterRepositoryProvider),
  ),
);

final userCreatedAiCharactersProvider = Provider<List<AiCharacter>>((ref) {
  final characters = ref.watch(userCreatedCharactersProvider);
  return characters.map((character) => character.toAiCharacter()).toList();
});

class UserCreatedCharactersNotifier
    extends StateNotifier<List<UserCreatedCharacter>> {
  UserCreatedCharactersNotifier(this._repository) : super(const []) {
    _loadFuture = _load();
  }

  final UserCreatedCharacterRepository _repository;
  final Uuid _uuid = const Uuid();
  late final Future<void> _loadFuture;

  Future<void> _load() async {
    state = await _repository.loadCharacters();
  }

  Future<void> ensureLoaded() => _loadFuture;

  Future<UserCreatedCharacter> createCharacter(
    FriendCreationDraft draft,
  ) async {
    await ensureLoaded();

    final created = draft.toCharacter(
      id: 'user_friend_${_uuid.v4()}',
      createdAt: DateTime.now(),
    );

    state = [
      created,
      ...state.where((character) => character.id != created.id),
    ];
    await _repository.saveCharacters(state);
    return created;
  }
}

final friendCreationDraftProvider =
    StateNotifierProvider<FriendCreationDraftNotifier, FriendCreationDraft>(
  (ref) => FriendCreationDraftNotifier(),
);

class FriendCreationDraft {
  const FriendCreationDraft({
    this.name = '',
    this.gender = UserCreatedCharacterGender.female,
    this.relationship = UserCreatedCharacterRelationship.friend,
    this.stylePreset = UserCreatedCharacterStylePreset.warm,
    this.personalityTags = const [],
    this.interestTags = const [],
    this.scenario = '',
    this.memoryNote = '',
    this.timeMode = UserCreatedCharacterTimeMode.realTime,
  });

  final String name;
  final UserCreatedCharacterGender gender;
  final UserCreatedCharacterRelationship relationship;
  final UserCreatedCharacterStylePreset stylePreset;
  final List<String> personalityTags;
  final List<String> interestTags;
  final String scenario;
  final String memoryNote;
  final UserCreatedCharacterTimeMode timeMode;

  bool get isBasicComplete => name.trim().isNotEmpty;
  bool get isPersonaComplete =>
      personalityTags.length >= 2 && interestTags.length >= 2;
  bool get isStoryComplete => scenario.trim().isNotEmpty;

  FriendCreationDraft copyWith({
    String? name,
    UserCreatedCharacterGender? gender,
    UserCreatedCharacterRelationship? relationship,
    UserCreatedCharacterStylePreset? stylePreset,
    List<String>? personalityTags,
    List<String>? interestTags,
    String? scenario,
    String? memoryNote,
    UserCreatedCharacterTimeMode? timeMode,
  }) {
    return FriendCreationDraft(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      relationship: relationship ?? this.relationship,
      stylePreset: stylePreset ?? this.stylePreset,
      personalityTags: personalityTags ?? this.personalityTags,
      interestTags: interestTags ?? this.interestTags,
      scenario: scenario ?? this.scenario,
      memoryNote: memoryNote ?? this.memoryNote,
      timeMode: timeMode ?? this.timeMode,
    );
  }

  UserCreatedCharacter toCharacter({
    required String id,
    required DateTime createdAt,
  }) {
    return UserCreatedCharacter(
      id: id,
      name: name.trim(),
      gender: gender,
      relationship: relationship,
      stylePreset: stylePreset,
      personalityTags: personalityTags,
      interestTags: interestTags,
      scenario: scenario.trim(),
      memoryNote: memoryNote.trim(),
      timeMode: timeMode,
      createdAt: createdAt,
    );
  }
}

class FriendCreationDraftNotifier extends StateNotifier<FriendCreationDraft> {
  FriendCreationDraftNotifier() : super(const FriendCreationDraft());

  void reset() {
    state = const FriendCreationDraft();
  }

  void updateBasic({
    String? name,
    UserCreatedCharacterGender? gender,
    UserCreatedCharacterRelationship? relationship,
  }) {
    state = state.copyWith(
      name: name,
      gender: gender,
      relationship: relationship,
    );
  }

  void updatePersona({
    UserCreatedCharacterStylePreset? stylePreset,
    List<String>? personalityTags,
    List<String>? interestTags,
  }) {
    state = state.copyWith(
      stylePreset: stylePreset,
      personalityTags: personalityTags,
      interestTags: interestTags,
    );
  }

  void updateStory({
    String? scenario,
    String? memoryNote,
    UserCreatedCharacterTimeMode? timeMode,
  }) {
    state = state.copyWith(
      scenario: scenario,
      memoryNote: memoryNote,
      timeMode: timeMode,
    );
  }
}
