import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ondo/core/design_system/design_system.dart';
import 'package:ondo/data/models/pet_profile.dart';
import 'package:ondo/data/models/secondary_profile.dart';
import 'package:ondo/features/character/presentation/widgets/pet_profile_create_sheet.dart';
import 'package:ondo/features/character/presentation/widgets/secondary_profile_create_sheet.dart';
import 'package:ondo/presentation/providers/pet_profiles_provider.dart';
import 'package:ondo/presentation/providers/secondary_profiles_provider.dart';

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

Finder _textFieldWithin(Key key) {
  return find.descendant(
    of: find.byKey(key),
    matching: find.byType(TextField),
  );
}

Future<void> _pressDsButton(WidgetTester tester, Key key) async {
  final button = tester.widget<DSButton>(find.byKey(key));
  button.onPressed?.call();
  await tester.pumpAndSettle();
}

Widget _buildHarness({
  required ProviderContainer container,
  required Future<void> Function(BuildContext context) onOpen,
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: DSTheme.light(),
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Center(
              child: TextButton(
                onPressed: () => onOpen(context),
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('pet profile create sheet validates and returns created profile',
      (tester) async {
    final notifier = _TestPetProfilesNotifier();
    final container = ProviderContainer(
      overrides: [
        petProfilesProvider.overrideWith((ref) => notifier),
      ],
    );
    addTearDown(container.dispose);

    PetProfile? createdProfile;

    await tester.pumpWidget(
      _buildHarness(
        container: container,
        onOpen: (context) async {
          createdProfile = await PetProfileCreateSheet.show(context);
        },
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await _pressDsButton(
      tester,
      const ValueKey('pet-create-submit-button'),
    );

    expect(find.text('이름을 입력해주세요.'), findsOneWidget);
    expect(find.text('종류를 입력해주세요.'), findsOneWidget);

    await tester.enterText(
      _textFieldWithin(const ValueKey('pet-create-name-field')),
      '루나',
    );
    await tester.enterText(
      _textFieldWithin(const ValueKey('pet-create-species-field')),
      '고양이',
    );
    await _pressDsButton(
      tester,
      const ValueKey('pet-create-submit-button'),
    );

    expect(createdProfile?.name, '루나');
    expect(createdProfile?.species, '고양이');
    expect(notifier.state.valueOrNull?.single.name, '루나');
  });

  testWidgets(
      'secondary profile create sheet saves fixed family relation after selecting birth date',
      (tester) async {
    final notifier = _TestSecondaryProfilesNotifier();
    final container = ProviderContainer(
      overrides: [
        secondaryProfilesProvider.overrideWith((ref) => notifier),
      ],
    );
    addTearDown(container.dispose);

    SecondaryProfile? createdProfile;

    await tester.pumpWidget(
      _buildHarness(
        container: container,
        onOpen: (context) async {
          createdProfile = await SecondaryProfileCreateSheet.show(
            context,
            selectedFamilyMember: 'parents',
          );
        },
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(
      _textFieldWithin(const ValueKey('secondary-create-name-field')),
      '엄마',
    );
    await _pressDsButton(
      tester,
      const ValueKey('secondary-create-birthdate-button'),
    );
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('여성'));
    await tester.pumpAndSettle();
    await _pressDsButton(
      tester,
      const ValueKey('secondary-create-submit-button'),
    );

    expect(createdProfile?.name, '엄마');
    expect(createdProfile?.relationship, 'family');
    expect(createdProfile?.familyRelation, 'parents');
    expect(notifier.state.valueOrNull?.single.familyRelation, 'parents');
  });
}
