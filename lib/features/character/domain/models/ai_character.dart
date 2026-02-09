import 'package:flutter/material.dart';

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
  final List<String> galleryAssets;  // 갤러리 이미지 에셋들
  final String? coverImage;           // 커버 이미지

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
  });

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
    );
  }
}
