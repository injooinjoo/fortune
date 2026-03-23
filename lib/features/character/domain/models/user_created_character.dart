import 'package:flutter/material.dart';

import 'ai_character.dart';
import 'behavior_pattern.dart';

enum UserCreatedCharacterGender {
  female,
  male,
  other,
}

enum UserCreatedCharacterRelationship {
  friend,
  crush,
  partner,
  colleague,
}

enum UserCreatedCharacterStylePreset {
  warm,
  calm,
  chic,
  dreamy,
}

enum UserCreatedCharacterTimeMode {
  realTime,
  timeless,
}

class UserCreatedCharacter {
  final String id;
  final String name;
  final UserCreatedCharacterGender gender;
  final UserCreatedCharacterRelationship relationship;
  final UserCreatedCharacterStylePreset stylePreset;
  final List<String> personalityTags;
  final List<String> interestTags;
  final String scenario;
  final String memoryNote;
  final UserCreatedCharacterTimeMode timeMode;
  final DateTime createdAt;

  const UserCreatedCharacter({
    required this.id,
    required this.name,
    required this.gender,
    required this.relationship,
    required this.stylePreset,
    required this.personalityTags,
    required this.interestTags,
    required this.scenario,
    required this.memoryNote,
    required this.timeMode,
    required this.createdAt,
  });

  factory UserCreatedCharacter.fromJson(Map<String, dynamic> json) {
    return UserCreatedCharacter(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      gender: _genderFromId(json['gender'] as String?),
      relationship: _relationshipFromId(json['relationship'] as String?),
      stylePreset: _stylePresetFromId(json['stylePreset'] as String?),
      personalityTags: (json['personalityTags'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      interestTags: (json['interestTags'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      scenario: json['scenario'] as String? ?? '',
      memoryNote: json['memoryNote'] as String? ?? '',
      timeMode: _timeModeFromId(json['timeMode'] as String?),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender.name,
      'relationship': relationship.name,
      'stylePreset': stylePreset.name,
      'personalityTags': personalityTags,
      'interestTags': interestTags,
      'scenario': scenario,
      'memoryNote': memoryNote,
      'timeMode': timeMode.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get relationshipLabel {
    switch (relationship) {
      case UserCreatedCharacterRelationship.friend:
        return '친구';
      case UserCreatedCharacterRelationship.crush:
        return '썸';
      case UserCreatedCharacterRelationship.partner:
        return '연인';
      case UserCreatedCharacterRelationship.colleague:
        return '동료';
    }
  }

  String get styleLabel {
    switch (stylePreset) {
      case UserCreatedCharacterStylePreset.warm:
        return '따뜻한 분위기';
      case UserCreatedCharacterStylePreset.calm:
        return '차분한 분위기';
      case UserCreatedCharacterStylePreset.chic:
        return '도시적인 분위기';
      case UserCreatedCharacterStylePreset.dreamy:
        return '몽환적인 분위기';
    }
  }

  String get timeModeLabel {
    switch (timeMode) {
      case UserCreatedCharacterTimeMode.realTime:
        return '현실 시간 반영';
      case UserCreatedCharacterTimeMode.timeless:
        return '상관없이 진행';
    }
  }

  AiCharacter toAiCharacter() {
    final friendConversationSeed = FriendConversationSeed(
      relationshipKey: relationship.name,
      relationshipLabel: relationshipLabel,
      scenario: scenario,
      memoryNote: memoryNote,
      timeModeKey: timeMode.name,
      styleLabel: styleLabel,
      personalityTags: personalityTags,
      interestTags: interestTags,
    );

    final tags = <String>{
      relationshipLabel,
      ...personalityTags,
      ...interestTags,
    }.toList();

    final shortDescriptionParts = <String>[
      relationshipLabel,
      ...personalityTags.take(2),
      ...interestTags.take(1),
    ];

    final worldview = [
      '관계 설정: $scenario',
      if (memoryNote.trim().isNotEmpty) memoryNote.trim(),
    ].join('\n\n');

    final personality = [
      '• 관계: $relationshipLabel',
      '• 성격 키워드: ${personalityTags.join(', ')}',
      '• 관심사: ${interestTags.join(', ')}',
      '• 시간 설정: $timeModeLabel',
      '• 분위기: $styleLabel',
    ].join('\n');

    final systemPrompt = '''
# [AI 페르소나 설정: $name]

## 1. 기본 정체성
- 너는 사용자와 대화하는 '$name'이다.
- AI라고 밝히지 말고, 실제 대화 상대처럼 자연스럽게 반응한다.
- 첫 답변은 짧고 자연스럽게 시작한다.

## 2. 관계 설정
- 사용자와의 관계: $relationshipLabel
- 상황 설정: $scenario
- 기억 노트:
$memoryNote

## 3. 성격 및 관심사
- 성격 키워드: ${personalityTags.join(', ')}
- 관심사: ${interestTags.join(', ')}
- 분위기: $styleLabel
- 시간 설정: $timeModeLabel

## 4. 대화 원칙
- 한 번에 1~3문장으로 답한다.
- 사용자의 마지막 말에 먼저 반응한다.
- 불필요하게 긴 설명은 피한다.
- 과한 상담봇 말투를 쓰지 않는다.
- 관계와 상황을 유지하되, 사용자가 불편해할 표현은 강요하지 않는다.
''';

    return AiCharacter(
      id: id,
      name: name,
      avatarAsset: '',
      shortDescription: shortDescriptionParts.join(' · '),
      worldview: worldview,
      personality: personality,
      firstMessage: friendConversationSeed.buildFirstMeetOpening(name),
      systemPrompt: systemPrompt,
      tags: tags,
      creatorComment: '직접 만든 친구',
      accentColor: _accentColorForStyle(stylePreset),
      friendConversationSeed: friendConversationSeed,
      characterType: CharacterType.story,
      behaviorPattern: BehaviorPattern.defaultPattern,
    );
  }

  static UserCreatedCharacterGender _genderFromId(String? id) {
    return UserCreatedCharacterGender.values.firstWhere(
      (value) => value.name == id,
      orElse: () => UserCreatedCharacterGender.other,
    );
  }

  static UserCreatedCharacterRelationship _relationshipFromId(String? id) {
    return UserCreatedCharacterRelationship.values.firstWhere(
      (value) => value.name == id,
      orElse: () => UserCreatedCharacterRelationship.friend,
    );
  }

  static UserCreatedCharacterStylePreset _stylePresetFromId(String? id) {
    return UserCreatedCharacterStylePreset.values.firstWhere(
      (value) => value.name == id,
      orElse: () => UserCreatedCharacterStylePreset.warm,
    );
  }

  static UserCreatedCharacterTimeMode _timeModeFromId(String? id) {
    return UserCreatedCharacterTimeMode.values.firstWhere(
      (value) => value.name == id,
      orElse: () => UserCreatedCharacterTimeMode.realTime,
    );
  }

  static Color _accentColorForStyle(UserCreatedCharacterStylePreset preset) {
    switch (preset) {
      case UserCreatedCharacterStylePreset.warm:
        return Colors.deepPurple;
      case UserCreatedCharacterStylePreset.calm:
        return Colors.indigo;
      case UserCreatedCharacterStylePreset.chic:
        return Colors.blueGrey;
      case UserCreatedCharacterStylePreset.dreamy:
        return Colors.pinkAccent;
    }
  }
}
