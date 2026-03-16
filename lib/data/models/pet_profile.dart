import 'package:equatable/equatable.dart';

/// 반려동물 프로필
///
/// 사용자가 저장한 반려동물 정보를 담고, 반려동물 분석 설문에서 사용한다.
class PetProfile extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String species;
  final int? age;
  final String? gender;
  final String? breed;
  final String? personality;
  final String? healthNotes;
  final bool? isNeutered;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PetProfile({
    required this.id,
    required this.userId,
    required this.name,
    required this.species,
    this.age,
    this.gender,
    this.breed,
    this.personality,
    this.healthNotes,
    this.isNeutered,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PetProfile.fromJson(Map<String, dynamic> json) {
    return PetProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      species: json['species'] as String? ?? '기타',
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      breed: json['breed'] as String?,
      personality: json['personality'] as String?,
      healthNotes: json['health_notes'] as String?,
      isNeutered: json['is_neutered'] as bool?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  String get detailLabel {
    final breedText = breed?.trim();
    if (breedText != null && breedText.isNotEmpty) {
      return '$species · $breedText';
    }
    return species;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        species,
        age,
        gender,
        breed,
        personality,
        healthNotes,
        isNeutered,
        createdAt,
        updatedAt,
      ];
}
