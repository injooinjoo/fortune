import '../../../../data/models/pet_profile.dart';
import '../../../../data/models/secondary_profile.dart';

Map<String, dynamic> buildStoredProfileSurveyAnswer({
  required SecondaryProfile profile,
  required String displayText,
  String? selectedFamilyMember,
}) {
  final familyRelation =
      selectedFamilyMember == 'spouse' && profile.matchesFamilyMember('spouse')
          ? 'spouse'
          : profile.familyRelation;

  return {
    'profileId': profile.id,
    'name': profile.name,
    'birthDate': profile.birthDate,
    'birthTime': profile.birthTime,
    'gender': profile.gender,
    'relationship': profile.relationship,
    'familyRelation': familyRelation,
    'displayText': displayText,
  };
}

Map<String, dynamic> buildPetProfileSurveyAnswer({
  required PetProfile profile,
  required String displayText,
}) {
  return {
    'profileId': profile.id,
    'name': profile.name,
    'species': profile.species,
    'type': profile.species,
    'age': profile.age,
    'gender': profile.gender,
    'breed': profile.breed,
    'personality': profile.personality,
    'healthNotes': profile.healthNotes,
    'isNeutered': profile.isNeutered,
    'displayText': displayText,
  };
}

Map<String, dynamic> normalizeCompatibilitySurveyAnswers(
  Map<String, dynamic> answers,
) {
  final normalized = Map<String, dynamic>.from(answers);
  final partner = _asStringKeyedMap(normalized['partner']);

  if (partner == null) {
    return normalized;
  }

  final partnerName = partner['name']?.toString().trim();
  if (partnerName != null && partnerName.isNotEmpty) {
    normalized['partnerName'] ??= partnerName;
  }

  final partnerBirthDate = partner['birthDate']?.toString().trim();
  if (partnerBirthDate != null && partnerBirthDate.isNotEmpty) {
    normalized['partnerBirth'] ??= partnerBirthDate;
  }

  final partnerGender = partner['gender']?.toString().trim();
  if (partnerGender != null && partnerGender.isNotEmpty) {
    normalized['partnerGender'] ??= partnerGender;
  }

  final relationship = partner['relationship']?.toString().trim();
  if ((normalized['relationship'] == null ||
          normalized['relationship'].toString().trim().isEmpty) &&
      relationship != null &&
      relationship.isNotEmpty) {
    normalized['relationship'] = relationship;
  }

  return normalized;
}

String? compatibilityPartnerNameFromAnswers(Map<String, dynamic> answers) {
  final directName = answers['partnerName']?.toString().trim();
  if (directName != null && directName.isNotEmpty) {
    return directName;
  }

  return _asStringKeyedMap(answers['partner'])?['name']?.toString().trim();
}

Map<String, dynamic>? _asStringKeyedMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map(
      (key, item) => MapEntry(key.toString(), item),
    );
  }
  return null;
}
