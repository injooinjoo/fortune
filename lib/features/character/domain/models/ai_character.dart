import 'package:flutter/material.dart';
import 'behavior_pattern.dart';

/// 캐릭터 유형
enum CharacterType {
  story, // 스토리/로맨스 캐릭터
  fortune, // 운세 전문가 캐릭터
}

class FriendConversationSeed {
  final String relationshipKey;
  final String relationshipLabel;
  final String scenario;
  final String memoryNote;
  final String timeModeKey;
  final String styleLabel;
  final List<String> personalityTags;
  final List<String> interestTags;

  const FriendConversationSeed({
    required this.relationshipKey,
    required this.relationshipLabel,
    required this.scenario,
    required this.memoryNote,
    required this.timeModeKey,
    required this.styleLabel,
    this.personalityTags = const [],
    this.interestTags = const [],
  });

  String buildFirstMeetOpening(
    String characterName, {
    String? userName,
  }) {
    final cleanedName =
        characterName.trim().isEmpty ? '친구' : characterName.trim();
    final cleanedUserName = _sanitizeText(userName);
    final quotedContext = _buildQuotedContext();
    final primaryInterest = _firstMeaningful(interestTags);
    final primaryTone = _firstMeaningful(personalityTags);

    final opener = switch (relationshipKey) {
      'crush' => cleanedUserName != null
          ? '$cleanedUserName, 왔네요. 오늘은 괜히 더 반갑네요.'
          : '왔네요. 오늘은 괜히 더 반갑네요.',
      'partner' => cleanedUserName != null
          ? '$cleanedUserName, 왔네요. 오늘 하루도 같이 정리해보고 싶었어요.'
          : '왔네요. 오늘 하루도 같이 정리해보고 싶었어요.',
      'colleague' => cleanedUserName != null
          ? '$cleanedUserName, 반가워요. 잠깐 쉬어가듯 이야기 나눠봐요.'
          : '반가워요. 잠깐 쉬어가듯 이야기 나눠봐요.',
      _ => cleanedUserName != null
          ? '$cleanedUserName, 반가워요. 저는 $cleanedName이에요.'
          : '반가워요. 저는 $cleanedName이에요.',
    };

    final contextLine = quotedContext != null
        ? '"$quotedContext" 같은 분위기로 오늘 대화를 시작해 볼까요?'
        : primaryTone != null
            ? '오늘은 ${_appendMoodSuffix(primaryTone)} 분위기로 편하게 이야기 나눠봐요.'
            : '$relationshipLabel답게 편하게 마음 가는 이야기부터 꺼내봐요.';

    final invitationLine = primaryInterest != null
        ? timeModeKey == 'timeless'
            ? '$primaryInterest 이야기부터, 아니면 지금 마음에 남은 일부터 들려줘도 좋아요.'
            : '지금 이 시간에 떠오른 $primaryInterest 이야기부터 들려줘도 좋아요.'
        : timeModeKey == 'timeless'
            ? '시간은 잠깐 잊고 우리 호흡대로 이야기해도 좋아요.'
            : '지금 떠오른 이야기부터 천천히 들려줘요.';

    return [opener, contextLine, invitationLine]
        .where((part) => part.trim().isNotEmpty)
        .join(' ');
  }

  String? _buildQuotedContext() {
    final scenarioSnippet = _summarizeText(scenario, maxLength: 34);
    if (scenarioSnippet != null) {
      return scenarioSnippet;
    }

    final memorySnippet = _summarizeText(memoryNote, maxLength: 38);
    return memorySnippet;
  }

  static String? _summarizeText(
    String? value, {
    required int maxLength,
  }) {
    final cleaned = _sanitizeText(value);
    if (cleaned == null) return null;
    if (cleaned.length <= maxLength) return cleaned;
    return '${cleaned.substring(0, maxLength).trimRight()}...';
  }

  static String? _sanitizeText(String? value) {
    final cleaned = value?.replaceAll(RegExp(r'\s+'), ' ').trim() ?? '';
    return cleaned.isEmpty ? null : cleaned;
  }

  static String? _firstMeaningful(List<String> values) {
    for (final value in values) {
      final cleaned = _sanitizeText(value);
      if (cleaned != null) {
        return cleaned;
      }
    }
    return null;
  }

  static String _appendMoodSuffix(String tone) {
    if (tone.endsWith('한') || tone.endsWith('로운')) {
      return tone;
    }
    return '$tone한';
  }
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
  final FriendConversationSeed? friendConversationSeed;

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
    this.friendConversationSeed,
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
    FriendConversationSeed? friendConversationSeed,
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
      friendConversationSeed:
          friendConversationSeed ?? this.friendConversationSeed,
      characterType: characterType ?? this.characterType,
      specialties: specialties ?? this.specialties,
      specialtyCategory: specialtyCategory ?? this.specialtyCategory,
      canCallFortune: canCallFortune ?? this.canCallFortune,
      behaviorPattern: behaviorPattern ?? this.behaviorPattern,
    );
  }
}
