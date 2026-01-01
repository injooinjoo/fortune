import 'package:equatable/equatable.dart';

/// 다른 사람 프로필 (가족/친구 운세 조회용)
///
/// 사용자가 등록한 가족이나 친구의 프로필 정보를 담는 모델.
/// 운세 조회 시 해당 프로필의 생년월일/성별 정보를 사용.
class SecondaryProfile extends Equatable {
  /// 프로필 고유 ID (UUID)
  final String id;

  /// 소유자 ID (auth.users.id)
  final String ownerId;

  /// 이름
  final String name;

  /// 생년월일 (YYYY-MM-DD 형식)
  final String birthDate;

  /// 태어난 시간 (HH:MM 형식, 선택)
  final String? birthTime;

  /// 성별 ("male" | "female")
  final String gender;

  /// 음력 여부
  final bool isLunar;

  /// 관계 ("family" | "friend" | "lover" | "other")
  final String? relationship;

  /// MBTI 성격유형 (선택)
  final String? mbti;

  /// 혈액형 (선택)
  final String? bloodType;

  /// 아바타 이미지 인덱스
  final int avatarIndex;

  /// 생성일시
  final DateTime createdAt;

  /// 수정일시
  final DateTime updatedAt;

  const SecondaryProfile({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.birthDate,
    this.birthTime,
    required this.gender,
    this.isLunar = false,
    this.relationship,
    this.mbti,
    this.bloodType,
    this.avatarIndex = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON으로부터 생성
  factory SecondaryProfile.fromJson(Map<String, dynamic> json) {
    return SecondaryProfile(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      birthDate: json['birth_date'] as String,
      birthTime: json['birth_time'] as String?,
      gender: json['gender'] as String,
      isLunar: json['is_lunar'] as bool? ?? false,
      relationship: json['relationship'] as String?,
      mbti: json['mbti'] as String?,
      bloodType: json['blood_type'] as String?,
      avatarIndex: json['avatar_index'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  /// JSON으로 변환 (DB 저장용)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'birth_date': birthDate,
      'birth_time': birthTime,
      'gender': gender,
      'is_lunar': isLunar,
      'relationship': relationship,
      'mbti': mbti,
      'blood_type': bloodType,
      'avatar_index': avatarIndex,
    };
  }

  /// 운세 조회용 파라미터 추출
  ///
  /// FortuneConditions나 Edge Function 호출 시 사용
  Map<String, dynamic> toFortuneParams() {
    return {
      'birthDate': birthDate,
      'birthTime': birthTime,
      'gender': gender,
      'isLunar': isLunar,
    };
  }

  /// 생년월일을 DateTime으로 변환
  DateTime? get birthDateTime {
    try {
      return DateTime.parse(birthDate);
    } catch (_) {
      return null;
    }
  }

  /// 관계 표시 텍스트
  String get relationshipText {
    switch (relationship) {
      case 'lover':
        return '애인';
      case 'family':
        return '가족';
      case 'friend':
        return '친구';
      case 'crush':
        return '짝사랑';
      case 'other':
        return '기타';
      default:
        return '기타';
    }
  }

  /// 이름 첫 글자 (아바타용)
  String get initial => name.isNotEmpty ? name.substring(0, 1) : '?';

  /// 복사본 생성
  SecondaryProfile copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? birthDate,
    String? birthTime,
    String? gender,
    bool? isLunar,
    String? relationship,
    String? mbti,
    String? bloodType,
    int? avatarIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SecondaryProfile(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      gender: gender ?? this.gender,
      isLunar: isLunar ?? this.isLunar,
      relationship: relationship ?? this.relationship,
      mbti: mbti ?? this.mbti,
      bloodType: bloodType ?? this.bloodType,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        name,
        birthDate,
        birthTime,
        gender,
        isLunar,
        relationship,
        mbti,
        bloodType,
        avatarIndex,
      ];

  @override
  String toString() {
    return 'SecondaryProfile(id: $id, name: $name, birthDate: $birthDate, '
        'gender: $gender, relationship: $relationship)';
  }
}
