import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/data/models/secondary_profile.dart';

void main() {
  group('SecondaryProfile family survey matching', () {
    final createdAt = DateTime(2026, 3, 17);

    final spouseProfile = SecondaryProfile(
      id: 'spouse-1',
      ownerId: 'owner-1',
      name: '신영은',
      birthDate: '1993-01-12',
      gender: 'female',
      relationship: 'lover',
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    final childProfile = SecondaryProfile(
      id: 'child-1',
      ownerId: 'owner-1',
      name: '아가',
      birthDate: '2023-03-03',
      gender: 'male',
      relationship: 'family',
      familyRelation: 'children',
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    test('treats lover profiles as spouse candidates in family survey', () {
      expect(spouseProfile.matchesFamilyMember('spouse'), isTrue);
      expect(
        spouseProfile.familySurveyRelationText(selectedMember: 'spouse'),
        '배우자',
      );
    });

    test('does not match lover profiles for non-spouse family members', () {
      expect(spouseProfile.matchesFamilyMember('parents'), isFalse);
      expect(spouseProfile.matchesFamilyMember('children'), isFalse);
    });

    test('keeps standard family relation matching for family profiles', () {
      expect(childProfile.matchesFamilyMember('children'), isTrue);
      expect(childProfile.matchesFamilyMember('siblings'), isFalse);
      expect(
        childProfile.familySurveyRelationText(selectedMember: 'children'),
        '자녀',
      );
    });
  });
}
