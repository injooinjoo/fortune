import 'package:ondo/data/models/pet_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ondo/data/models/secondary_profile.dart';
import 'package:ondo/features/character/presentation/utils/chat_survey_profile_utils.dart';

void main() {
  final sampleProfile = SecondaryProfile(
    id: 'profile-1',
    ownerId: 'user-1',
    name: '로제',
    birthDate: '1998-02-11',
    birthTime: '13:30',
    gender: 'female',
    relationship: 'friend',
    familyRelation: null,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 2),
  );

  final samplePet = PetProfile(
    id: 'pet-1',
    userId: 'user-1',
    name: '보리',
    species: '강아지',
    age: 4,
    gender: '수컷',
    breed: '말티즈',
    personality: '활발함',
    healthNotes: '슬개골 주의',
    isNeutered: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 2),
  );

  group('chat_survey_profile_utils', () {
    test('buildStoredProfileSurveyAnswer stores profile metadata for survey',
        () {
      final answer = buildStoredProfileSurveyAnswer(
        profile: sampleProfile,
        displayText: '📋 로제 · 친구',
      );

      expect(answer['profileId'], 'profile-1');
      expect(answer['name'], '로제');
      expect(answer['birthDate'], '1998-02-11');
      expect(answer['birthTime'], '13:30');
      expect(answer['gender'], 'female');
      expect(answer['relationship'], 'friend');
      expect(answer['displayText'], '📋 로제 · 친구');
    });

    test('normalizeCompatibilitySurveyAnswers expands nested partner profile',
        () {
      final normalized = normalizeCompatibilitySurveyAnswers({
        'inputMethod': 'profile',
        'partner': buildStoredProfileSurveyAnswer(
          profile: sampleProfile,
          displayText: '📋 로제 · 친구',
        ),
      });

      expect(normalized['partnerName'], '로제');
      expect(normalized['partnerBirth'], '1998-02-11');
      expect(normalized['partnerGender'], 'female');
      expect(normalized['relationship'], 'friend');
    });

    test(
        'normalizeCompatibilitySurveyAnswers keeps explicit relationship answer',
        () {
      final normalized = normalizeCompatibilitySurveyAnswers({
        'relationship': 'lover',
        'partner': buildStoredProfileSurveyAnswer(
          profile: sampleProfile,
          displayText: '📋 로제 · 친구',
        ),
      });

      expect(normalized['relationship'], 'lover');
    });

    test('compatibilityPartnerNameFromAnswers reads nested partner selection',
        () {
      final name = compatibilityPartnerNameFromAnswers({
        'partner': buildStoredProfileSurveyAnswer(
          profile: sampleProfile,
          displayText: '📋 로제 · 친구',
        ),
      });

      expect(name, '로제');
    });

    test('buildPetProfileSurveyAnswer stores pet metadata for survey', () {
      final answer = buildPetProfileSurveyAnswer(
        profile: samplePet,
        displayText: '🐾 보리 · 강아지 · 말티즈',
      );

      expect(answer['profileId'], 'pet-1');
      expect(answer['name'], '보리');
      expect(answer['species'], '강아지');
      expect(answer['type'], '강아지');
      expect(answer['age'], 4);
      expect(answer['gender'], '수컷');
      expect(answer['breed'], '말티즈');
      expect(answer['personality'], '활발함');
      expect(answer['healthNotes'], '슬개골 주의');
      expect(answer['isNeutered'], isTrue);
      expect(answer['displayText'], '🐾 보리 · 강아지 · 말티즈');
    });
  });
}
