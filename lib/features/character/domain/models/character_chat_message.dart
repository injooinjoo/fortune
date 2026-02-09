import 'package:uuid/uuid.dart';
import 'character_choice.dart';

/// 메시지 유형
enum CharacterChatMessageType {
  user,       // 사용자 메시지
  character,  // 캐릭터 응답
  system,     // 시스템 메시지
  narration,  // 나레이션 (소설체)
  choice,     // 선택지 메시지
}

/// 메시지 전송/읽음 상태 (인스타그램 DM 스타일)
enum MessageStatus {
  sending,    // 전송 중
  sent,       // 전송됨 (1 표시)
  read,       // 읽음 (숫자 사라짐)
}

/// 캐릭터 채팅 메시지 모델
class CharacterChatMessage {
  final String id;
  final CharacterChatMessageType type;
  final String text;
  final DateTime timestamp;
  final String? characterId;
  final ChoiceSet? choiceSet;
  final MessageStatus status;  // 전송/읽음 상태
  final DateTime? readAt;      // 읽음 시간

  CharacterChatMessage({
    String? id,
    required this.type,
    required this.text,
    DateTime? timestamp,
    this.characterId,
    this.choiceSet,
    this.status = MessageStatus.read,  // 기본값: 읽음 (캐릭터 메시지용)
    this.readAt,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  /// 사용자 메시지 생성 (status: sent로 시작 - "1" 표시)
  factory CharacterChatMessage.user(String text) {
    return CharacterChatMessage(
      type: CharacterChatMessageType.user,
      text: text,
      status: MessageStatus.sent,  // 전송됨 (1 표시)
    );
  }

  /// 캐릭터 메시지 생성
  factory CharacterChatMessage.character(String text, String characterId) {
    return CharacterChatMessage(
      type: CharacterChatMessageType.character,
      text: text,
      characterId: characterId,
    );
  }

  /// 시스템 메시지 생성
  factory CharacterChatMessage.system(String text) {
    return CharacterChatMessage(
      type: CharacterChatMessageType.system,
      text: text,
    );
  }

  /// 나레이션 메시지 생성
  factory CharacterChatMessage.narration(String text) {
    return CharacterChatMessage(
      type: CharacterChatMessageType.narration,
      text: text,
    );
  }

  /// 선택지 메시지 생성
  factory CharacterChatMessage.choice(ChoiceSet choiceSet, {String? situation}) {
    return CharacterChatMessage(
      type: CharacterChatMessageType.choice,
      text: situation ?? '선택지',
      choiceSet: choiceSet,
    );
  }

  /// LLM API용 role 변환
  String get role {
    switch (type) {
      case CharacterChatMessageType.user:
        return 'user';
      case CharacterChatMessageType.character:
      case CharacterChatMessageType.narration:
      case CharacterChatMessageType.choice:
        return 'assistant';
      case CharacterChatMessageType.system:
        return 'system';
    }
  }

  /// 선택지 메시지 여부
  bool get isChoice => type == CharacterChatMessageType.choice;

  CharacterChatMessage copyWith({
    String? id,
    CharacterChatMessageType? type,
    String? text,
    DateTime? timestamp,
    String? characterId,
    ChoiceSet? choiceSet,
    MessageStatus? status,
    DateTime? readAt,
  }) {
    return CharacterChatMessage(
      id: id ?? this.id,
      type: type ?? this.type,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      characterId: characterId ?? this.characterId,
      choiceSet: choiceSet ?? this.choiceSet,
      status: status ?? this.status,
      readAt: readAt ?? this.readAt,
    );
  }

  /// JSON 직렬화 (DB 저장용)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'content': text,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      if (characterId != null) 'characterId': characterId,
      if (choiceSet != null) 'choiceSet': choiceSet!.toJson(),
      if (readAt != null) 'readAt': readAt!.toIso8601String(),
    };
  }

  /// JSON 역직렬화 (DB 로드용)
  factory CharacterChatMessage.fromJson(Map<String, dynamic> json) {
    return CharacterChatMessage(
      id: json['id'] as String?,
      type: CharacterChatMessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CharacterChatMessageType.system,
      ),
      text: json['content'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      characterId: json['characterId'] as String?,
      choiceSet: json['choiceSet'] != null
          ? ChoiceSet.fromJson(json['choiceSet'] as Map<String, dynamic>)
          : null,
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.read,  // 기존 메시지는 읽음 처리
      ),
      readAt: json['readAt'] != null
          ? DateTime.tryParse(json['readAt'] as String)
          : null,
    );
  }
}
