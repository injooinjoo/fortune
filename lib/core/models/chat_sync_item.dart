import 'dart:convert';

/// 채팅 동기화 상태
enum SyncStatus {
  pending,   // 대기 중
  syncing,   // 동기화 중
  failed,    // 실패
  completed, // 완료
}

/// 채팅 동기화 항목 모델
/// 오프라인 큐에 저장되어 나중에 DB로 동기화됨
class ChatSyncItem {
  final String id;
  final String chatId;      // characterId 또는 'general'
  final String chatType;    // 'character' | 'general'
  final List<Map<String, dynamic>> messages;
  final DateTime createdAt;
  final DateTime? lastAttemptAt;
  final int attemptCount;
  final String? userId;     // null이면 게스트
  final SyncStatus status;
  final String? errorMessage;

  const ChatSyncItem({
    required this.id,
    required this.chatId,
    required this.chatType,
    required this.messages,
    required this.createdAt,
    this.lastAttemptAt,
    this.attemptCount = 0,
    this.userId,
    this.status = SyncStatus.pending,
    this.errorMessage,
  });

  /// JSON에서 생성
  factory ChatSyncItem.fromJson(Map<String, dynamic> json) {
    return ChatSyncItem(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      chatType: json['chatType'] as String,
      messages: (json['messages'] as List)
          .map((m) => m as Map<String, dynamic>)
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastAttemptAt: json['lastAttemptAt'] != null
          ? DateTime.parse(json['lastAttemptAt'] as String)
          : null,
      attemptCount: json['attemptCount'] as int? ?? 0,
      userId: json['userId'] as String?,
      status: SyncStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => SyncStatus.pending,
      ),
      errorMessage: json['errorMessage'] as String?,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'chatType': chatType,
      'messages': messages,
      'createdAt': createdAt.toIso8601String(),
      'lastAttemptAt': lastAttemptAt?.toIso8601String(),
      'attemptCount': attemptCount,
      'userId': userId,
      'status': status.name,
      'errorMessage': errorMessage,
    };
  }

  /// JSON 문자열로 변환
  String toJsonString() => jsonEncode(toJson());

  /// JSON 문자열에서 생성
  factory ChatSyncItem.fromJsonString(String jsonString) {
    return ChatSyncItem.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  /// 복사본 생성
  ChatSyncItem copyWith({
    String? id,
    String? chatId,
    String? chatType,
    List<Map<String, dynamic>>? messages,
    DateTime? createdAt,
    DateTime? lastAttemptAt,
    int? attemptCount,
    String? userId,
    SyncStatus? status,
    String? errorMessage,
  }) {
    return ChatSyncItem(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      chatType: chatType ?? this.chatType,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      attemptCount: attemptCount ?? this.attemptCount,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// 재시도 가능 여부 (최대 3회)
  bool get canRetry => attemptCount < 3;

  /// 게스트 사용자 여부
  bool get isGuest => userId == null;

  @override
  String toString() {
    return 'ChatSyncItem(id: $id, chatId: $chatId, chatType: $chatType, '
        'status: $status, attemptCount: $attemptCount)';
  }
}
