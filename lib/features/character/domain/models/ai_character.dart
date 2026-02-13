import 'package:flutter/material.dart';
import 'behavior_pattern.dart';

/// 캐릭터 유형
enum CharacterType {
  story, // 스토리/로맨스 캐릭터
  fortune, // 운세 전문가 캐릭터
}

/// AI 캐릭터 데이터 모델
class AiCharacter {
  final String id;
  final String name;
  final String avatarAsset;
  final String shortDescription;
  final String worldview;
  final String personality;
  final String firstMessage;
  final String systemPrompt;
  final List<String> tags;
  final String creatorComment;
  final String? oocInstructions;
  final Map<String, String>? npcProfiles;
  final Color accentColor;
  final List<String> galleryAssets; // 갤러리 이미지 에셋들
  final String? coverImage; // 커버 이미지

  // 운세 전문가 캐릭터용 필드
  final CharacterType characterType; // 캐릭터 유형: story | fortune
  final List<String> specialties; // 전문 운세 타입 목록 (예: ['daily', 'weekly'])
  final String? specialtyCategory; // 전문 카테고리 (예: 'lifestyle', 'love')
  final bool canCallFortune; // 운세 호출 가능 여부

  // 행동 패턴 (페르소나 차별화)
  final BehaviorPattern behaviorPattern; // Follow-up, 이모티콘, 응답 속도 등

  const AiCharacter({
    required this.id,
    required this.name,
    required this.avatarAsset,
    required this.shortDescription,
    required this.worldview,
    required this.personality,
    required this.firstMessage,
    required this.systemPrompt,
    required this.tags,
    required this.creatorComment,
    this.oocInstructions,
    this.npcProfiles,
    required this.accentColor,
    this.galleryAssets = const [],
    this.coverImage,
    this.characterType = CharacterType.story, // 기본값: 스토리 캐릭터
    this.specialties = const [],
    this.specialtyCategory,
    this.canCallFortune = false,
    this.behaviorPattern = BehaviorPattern.defaultPattern,
  });

  /// 운세 전문가인지 확인
  bool get isFortuneExpert => characterType == CharacterType.fortune;

  /// 이니셜 (아바타 대체용)
  String get initial => name.isNotEmpty ? name[0] : '?';

  /// 태그 문자열 (표시용)
  String get tagsDisplay => tags.map((t) => '#$t').join(' ');

  AiCharacter copyWith({
    String? id,
    String? name,
    String? avatarAsset,
    String? shortDescription,
    String? worldview,
    String? personality,
    String? firstMessage,
    String? systemPrompt,
    List<String>? tags,
    String? creatorComment,
    String? oocInstructions,
    Map<String, String>? npcProfiles,
    Color? accentColor,
    List<String>? galleryAssets,
    String? coverImage,
    CharacterType? characterType,
    List<String>? specialties,
    String? specialtyCategory,
    bool? canCallFortune,
    BehaviorPattern? behaviorPattern,
  }) {
    return AiCharacter(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      shortDescription: shortDescription ?? this.shortDescription,
      worldview: worldview ?? this.worldview,
      personality: personality ?? this.personality,
      firstMessage: firstMessage ?? this.firstMessage,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      tags: tags ?? this.tags,
      creatorComment: creatorComment ?? this.creatorComment,
      oocInstructions: oocInstructions ?? this.oocInstructions,
      npcProfiles: npcProfiles ?? this.npcProfiles,
      accentColor: accentColor ?? this.accentColor,
      galleryAssets: galleryAssets ?? this.galleryAssets,
      coverImage: coverImage ?? this.coverImage,
      characterType: characterType ?? this.characterType,
      specialties: specialties ?? this.specialties,
      specialtyCategory: specialtyCategory ?? this.specialtyCategory,
      canCallFortune: canCallFortune ?? this.canCallFortune,
      behaviorPattern: behaviorPattern ?? this.behaviorPattern,
    );
  }
}
