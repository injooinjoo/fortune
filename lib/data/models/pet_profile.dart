class PetProfile {
  final String? id;
  final String userId;
  final String species;
  final String name;
  final int age;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PetProfile({
    this.id,
    required this.userId,
    required this.species,
    required this.name,
    required this.age,
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PetProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      species: species ?? this.species,
      name: name ?? this.name,
      age: age ?? this.age,
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
          age == other.age;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      species.hashCode ^
      name.hashCode ^
      age.hashCode;

  @override
  String toString() {
    return 'PetProfile(id: $id, userId: $userId, species: $species, name: $name, age: $age)';
  }
}

enum PetSpecies {
  dog('강아지', '🐶'),
  cat('고양이', '🐱'),
  rabbit('토끼', '🐰'),
  hamster('햄스터', '🐹'),
  bird('새', '🐦'),
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