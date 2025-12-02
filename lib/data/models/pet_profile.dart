class PetProfile {
  final String? id;
  final String userId;
  final String species;
  final String name;
  final int age;
  final String gender;          // ✅ 성별 (수컷/암컷/모름)
  final String? breed;          // ✅ 품종 (선택)
  final String? personality;    // ✅ 성격 (선택)
  final String? healthNotes;    // ✅ 건강 특이사항 (선택)
  final bool? isNeutered;       // ✅ 중성화 여부 (선택)
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PetProfile({
    this.id,
    required this.userId,
    required this.species,
    required this.name,
    required this.age,
    this.gender = '모름',
    this.breed,
    this.personality,
    this.healthNotes,
    this.isNeutered,
    required this.createdAt,
    this.updatedAt,
  });

  factory PetProfile.fromJson(Map<String, dynamic> json) {
    return PetProfile(
      id: json['id'],
      userId: json['user_id'],
      species: json['species'],
      name: json['name'],
      age: json['age'],
      gender: json['gender'] ?? '모름',
      breed: json['breed'],
      personality: json['personality'],
      healthNotes: json['health_notes'],
      isNeutered: json['is_neutered'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'species': species,
      'name': name,
      'age': age,
      'gender': gender,
      if (breed != null) 'breed': breed,
      if (personality != null) 'personality': personality,
      if (healthNotes != null) 'health_notes': healthNotes,
      if (isNeutered != null) 'is_neutered': isNeutered,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  PetProfile copyWith({
    String? id,
    String? userId,
    String? species,
    String? name,
    int? age,
    String? gender,
    String? breed,
    String? personality,
    String? healthNotes,
    bool? isNeutered,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PetProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      species: species ?? this.species,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      breed: breed ?? this.breed,
      personality: personality ?? this.personality,
      healthNotes: healthNotes ?? this.healthNotes,
      isNeutered: isNeutered ?? this.isNeutered,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          species == other.species &&
          name == other.name &&
          age == other.age &&
          gender == other.gender &&
          breed == other.breed &&
          personality == other.personality;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      species.hashCode ^
      name.hashCode ^
      age.hashCode ^
      gender.hashCode ^
      breed.hashCode ^
      personality.hashCode;

  @override
  String toString() {
    return 'PetProfile(id: $id, name: $name, species: $species, age: $age, gender: $gender, breed: $breed, personality: $personality)';
  }
}

/// 반려동물 종류
enum PetSpecies {
  dog('강아지', '🐕'),
  cat('고양이', '🐈'),
  rabbit('토끼', '🐰'),
  hamster('햄스터', '🐹'),
  bird('새', '🦜'),
  fish('물고기', '🐠'),
  turtle('거북이', '🐢'),
  lizard('도마뱀', '🦎'),
  other('기타', '🐾');

  const PetSpecies(this.displayName, this.emoji);

  final String displayName;
  final String emoji;

  static PetSpecies fromString(String species) {
    switch (species) {
      case '강아지':
        return PetSpecies.dog;
      case '고양이':
        return PetSpecies.cat;
      case '토끼':
        return PetSpecies.rabbit;
      case '햄스터':
        return PetSpecies.hamster;
      case '새':
        return PetSpecies.bird;
      case '물고기':
        return PetSpecies.fish;
      case '거북이':
        return PetSpecies.turtle;
      case '도마뱀':
        return PetSpecies.lizard;
      default:
        return PetSpecies.other;
    }
  }
}

/// 반려동물 성별
enum PetGender {
  male('수컷', '♂'),
  female('암컷', '♀'),
  unknown('모름', '?');

  const PetGender(this.displayName, this.symbol);

  final String displayName;
  final String symbol;

  static PetGender fromString(String gender) {
    switch (gender) {
      case '수컷':
        return PetGender.male;
      case '암컷':
        return PetGender.female;
      default:
        return PetGender.unknown;
    }
  }
}

/// 반려동물 성격
enum PetPersonality {
  energetic('활발함', '⚡', '에너지가 넘치고 놀기 좋아해요'),
  calm('차분함', '🧘', '조용하고 안정적이에요'),
  shy('수줍음', '🙈', '낯을 가리고 조심스러워요'),
  affectionate('애교쟁이', '💕', '애교가 많고 사랑스러워요'),
  curious('호기심쟁이', '🔍', '새로운 것에 관심이 많아요'),
  independent('독립적', '🦁', '혼자서도 잘 지내요');

  const PetPersonality(this.displayName, this.emoji, this.description);

  final String displayName;
  final String emoji;
  final String description;

  static PetPersonality? fromString(String? personality) {
    if (personality == null) return null;
    switch (personality) {
      case '활발함':
        return PetPersonality.energetic;
      case '차분함':
        return PetPersonality.calm;
      case '수줍음':
        return PetPersonality.shy;
      case '애교쟁이':
        return PetPersonality.affectionate;
      case '호기심쟁이':
        return PetPersonality.curious;
      case '독립적':
        return PetPersonality.independent;
      default:
        return null;
    }
  }
}

/// 품종 데이터 (주요 품종만)
class PetBreeds {
  static const List<String> dogBreeds = [
    '믹스견',
    '말티즈',
    '푸들',
    '시츄',
    '포메라니안',
    '치와와',
    '요크셔테리어',
    '비숑프리제',
    '웰시코기',
    '골든리트리버',
    '래브라도리트리버',
    '보더콜리',
    '진돗개',
    '시바견',
    '프렌치불독',
    '닥스훈트',
    '슈나우저',
    '사모예드',
    '허스키',
    '기타',
  ];

  static const List<String> catBreeds = [
    '믹스묘',
    '코리안숏헤어',
    '러시안블루',
    '페르시안',
    '브리티쉬숏헤어',
    '스코티쉬폴드',
    '아메리칸숏헤어',
    '터키쉬앙고라',
    '랙돌',
    '메인쿤',
    '벵갈',
    '아비시니안',
    '노르웨이숲',
    '샴',
    '먼치킨',
    '기타',
  ];

  static const List<String> rabbitBreeds = [
    '믹스',
    '네덜란드드워프',
    '롭이어',
    '미니렉스',
    '라이온헤드',
    '앙고라',
    '기타',
  ];

  static const List<String> hamsterBreeds = [
    '골든햄스터',
    '드워프햄스터',
    '로보로브스키',
    '윈터화이트',
    '기타',
  ];

  static const List<String> birdBreeds = [
    '잉꼬',
    '앵무새',
    '카나리아',
    '핀치',
    '러브버드',
    '모란앵무',
    '기타',
  ];

  static List<String> getBreedsForSpecies(String species) {
    switch (species) {
      case '강아지':
        return dogBreeds;
      case '고양이':
        return catBreeds;
      case '토끼':
        return rabbitBreeds;
      case '햄스터':
        return hamsterBreeds;
      case '새':
        return birdBreeds;
      default:
        return ['기타'];
    }
  }
}
