import '../fortune_conditions.dart';

/// 관상 운세 조건
class FaceReadingFortuneConditions extends FortuneConditions {
  final String faceImageHash; // 얼굴 이미지 해시 (동일 이미지 식별용)
  final String? gender;
  final int? age;

  FaceReadingFortuneConditions({
    required this.faceImageHash,
    this.gender,
    this.age,
  });

  @override
  String generateHash() {
    final parts = <String>[
      'img:$faceImageHash',
      if (gender != null) 'gender:${gender!.hashCode}',
      if (age != null) 'age:$age',
    ];
    return parts.join('|');
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'face_image_hash': faceImageHash,
      if (gender != null) 'gender': gender,
      if (age != null) 'age': age,
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      'gender': gender,
      'age_range': age != null ? '${(age! ~/ 10) * 10}대' : null,
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      'face_image_hash': faceImageHash,
      if (gender != null) 'gender': gender,
      if (age != null) 'age': age,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FaceReadingFortuneConditions &&
          runtimeType == other.runtimeType &&
          faceImageHash == other.faceImageHash &&
          gender == other.gender &&
          age == other.age;

  @override
  int get hashCode => faceImageHash.hashCode ^ gender.hashCode ^ age.hashCode;
}
