import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:fortune/data/models/pet_profile.dart';
import 'package:fortune/data/models/secondary_profile.dart';
import 'package:fortune/features/character/data/fortune_characters.dart';
import 'package:fortune/features/character/presentation/pages/character_chat_panel.dart';
import 'package:fortune/features/character/presentation/providers/character_chat_provider.dart';
import 'package:fortune/features/character/presentation/providers/character_chat_survey_provider.dart';
import 'package:fortune/features/chat/domain/models/fortune_survey_config.dart';
import 'package:fortune/presentation/providers/pet_profiles_provider.dart';
import 'package:fortune/presentation/providers/secondary_profiles_provider.dart';

class _TestPetProfilesNotifier extends PetProfilesNotifier {
  _TestPetProfilesNotifier({
    List<PetProfile> initialProfiles = const [],
  }) : super(
          loadOnInit: false,
          initialState: AsyncValue.data(initialProfiles),
        );

  int _sequence = 0;

  @override
  Future<PetProfile> addProfile({
    required String name,
    required String species,
  }) async {
    _sequence += 1;
    final profile = PetProfile(
      id: 'pet-$_sequence',
      userId: 'test-user',
      name: name,
      species: species,
      createdAt: DateTime(2026, 3, 24),
      updatedAt: DateTime(2026, 3, 24),
    );
    state = AsyncValue.data([...(state.valueOrNull ?? const []), profile]);
    return profile;
  }
}

class _TestSecondaryProfilesNotifier extends SecondaryProfilesNotifier {
  _TestSecondaryProfilesNotifier({
    List<SecondaryProfile> initialProfiles = const [],
  }) : super(
          loadOnInit: false,
          initialState: AsyncValue.data(initialProfiles),
        );

  int _sequence = 0;

  @override
  Future<SecondaryProfile?> addProfile({
    required String name,
    required String birthDate,
    String? birthTime,
    required String gender,
    bool isLunar = false,
    String? relationship,
    String? familyRelation,
    String? mbti,
    String? bloodType,
  }) async {
    _sequence += 1;
    final profile = SecondaryProfile(
      id: 'profile-$_sequence',
      ownerId: 'test-user',
      name: name,
      birthDate: birthDate,
      birthTime: birthTime,
      gender: gender,
      isLunar: isLunar,
      relationship: relationship,
      familyRelation: familyRelation,
      mbti: mbti,
      bloodType: bloodType,
      createdAt: DateTime(2026, 3, 24),
      updatedAt: DateTime(2026, 3, 24),
    );
    state = AsyncValue.data([...(state.valueOrNull ?? const []), profile]);
    return profile;
  }
}

Widget _buildSubject(
  CharacterChatPanel panel, {
  required ProviderContainer container,
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: DSTheme.light(),
      darkTheme: DSTheme.dark(),
      home: Scaffold(body: panel),
    ),
  );
}

ProviderContainer _createContainer({
  PetProfilesNotifier? petNotifier,
  SecondaryProfilesNotifier? secondaryNotifier,
}) {
  final overrides = <Override>[
    if (petNotifier != null)
      petProfilesProvider.overrideWith((ref) => petNotifier),
    if (secondaryNotifier != null)
      secondaryProfilesProvider.overrideWith((ref) => secondaryNotifier),
  ];

  final container = ProviderContainer(overrides: overrides);
  final notifier =
      container.read(characterChatProvider(haneulCharacter.id).notifier);
  addTearDown(notifier.cancelFollowUp);
  addTearDown(container.dispose);
  return container;
}

void main() {
  testWidgets('empty pet survey state opens registration sheet',
      (tester) async {
    final petNotifier = _TestPetProfilesNotifier(initialProfiles: const []);
    final container = _createContainer(petNotifier: petNotifier);

    container
        .read(characterChatSurveyProvider(haneulCharacter.id).notifier)
        .startSurvey(
          FortuneSurveyType.pet,
          fortuneTypeStr: 'pet-compatibility',
        );

    await tester.pumpWidget(
      _buildSubject(
        const CharacterChatPanel(
          character: haneulCharacter,
          debugSkipRegistrationAuthGate: true,
        ),
        container: container,
      ),
    );
    await tester.pump();

    expect(find.text('선택할 수 있는 반려동물이 없어요.'), findsOneWidget);
    expect(find.text('등록하기'), findsOneWidget);

    await tester.ensureVisible(find.text('등록하기'));
    await tester.tap(find.text('등록하기'));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey('pet-profile-create-sheet')), findsOneWidget);
  });

  testWidgets(
      'empty family survey state opens registration sheet with selected relation',
      (tester) async {
    final secondaryNotifier =
        _TestSecondaryProfilesNotifier(initialProfiles: const []);
    final container = _createContainer(secondaryNotifier: secondaryNotifier);
    final surveyNotifier = container
        .read(characterChatSurveyProvider(haneulCharacter.id).notifier);

    surveyNotifier.startSurvey(
      FortuneSurveyType.family,
      fortuneTypeStr: 'family',
    );
    surveyNotifier.answerCurrentStep('relationship');
    surveyNotifier.answerCurrentStep('parents');

    await tester.pumpWidget(
      _buildSubject(
        const CharacterChatPanel(
          character: haneulCharacter,
          debugSkipRegistrationAuthGate: true,
        ),
        container: container,
      ),
    );
    await tester.pump();

    expect(find.text('선택한 가족 관계에 맞는 저장 프로필이 없어요.'), findsOneWidget);

    await tester.ensureVisible(find.text('등록하기'));
    await tester.tap(find.text('등록하기'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('secondary-profile-create-sheet')),
      findsOneWidget,
    );
    expect(find.text('저장 관계: 부모님'), findsOneWidget);
  });
}
