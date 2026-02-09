/// 캐릭터 호감도/친밀도 모델
class CharacterAffinity {
  /// 현재 호감도 포인트 (0-1000)
  final int lovePoints;

  /// 현재 관계 단계
  final AffinityPhase phase;

  /// 마지막 업데이트 시간
  final DateTime? lastUpdated;

  const CharacterAffinity({
    this.lovePoints = 0,
    this.phase = AffinityPhase.stranger,
    this.lastUpdated,
  });

  /// 호감도 이모지 (포인트에 따라)
  String get loveEmoji {
    final level = lovePoints ~/ 100;
    return switch (level) {
      0 => '💔',
      1 || 2 => '🤍',
      3 || 4 => '💗',
      5 || 6 => '💕',
      7 || 8 => '💖',
      _ => '❤️‍🔥',
    };
  }

  /// 호감도 바 (10칸 기준)
  String get loveBar {
    final filled = (lovePoints / 100).clamp(0, 10).toInt();
    final empty = 10 - filled;
    return '█' * filled + '░' * empty;
  }

  /// 호감도 퍼센트
  int get lovePercent => (lovePoints / 10).clamp(0, 100).toInt();

  /// 단계 이름 (한국어)
  String get phaseName => phase.displayName;

  /// 호감도 증가
  CharacterAffinity addPoints(int points) {
    final newPoints = (lovePoints + points).clamp(0, 1000);
    return copyWith(
      lovePoints: newPoints,
      phase: AffinityPhase.fromPoints(newPoints),
      lastUpdated: DateTime.now(),
    );
  }

  /// 상태창용 문자열
  String toStatusString() {
    return '💕 호감도: $loveBar $lovePercent%\n'
        '🎭 관계: ${phase.displayName}';
  }

  CharacterAffinity copyWith({
    int? lovePoints,
    AffinityPhase? phase,
    DateTime? lastUpdated,
  }) {
    return CharacterAffinity(
      lovePoints: lovePoints ?? this.lovePoints,
      phase: phase ?? this.phase,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lovePoints': lovePoints,
      'phase': phase.name,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory CharacterAffinity.fromJson(Map<String, dynamic> json) {
    return CharacterAffinity(
      lovePoints: json['lovePoints'] as int? ?? 0,
      phase: AffinityPhase.values.firstWhere(
        (p) => p.name == json['phase'],
        orElse: () => AffinityPhase.stranger,
      ),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'] as String)
          : null,
    );
  }
}

/// 관계 단계
enum AffinityPhase {
  stranger('낯선 사이', 0),
  acquaintance('아는 사이', 100),
  friend('친한 사이', 300),
  closeFriend('특별한 사이', 500),
  romantic('연인', 700),
  soulmate('소울메이트', 900);

  final String displayName;
  final int minPoints;

  const AffinityPhase(this.displayName, this.minPoints);

  /// 포인트로 단계 결정
  static AffinityPhase fromPoints(int points) {
    if (points >= 900) return AffinityPhase.soulmate;
    if (points >= 700) return AffinityPhase.romantic;
    if (points >= 500) return AffinityPhase.closeFriend;
    if (points >= 300) return AffinityPhase.friend;
    if (points >= 100) return AffinityPhase.acquaintance;
    return AffinityPhase.stranger;
  }
}

/// 호감도 변화 이벤트
enum AffinityEvent {
  /// 일반 대화
  normalChat(5, '대화'),

  /// 달달한 대화
  sweetTalk(15, '달달한 대화'),

  /// 비밀 공유
  sharedSecret(25, '비밀 공유'),

  /// 위로/공감
  comfort(20, '위로'),

  /// 선물
  gift(30, '선물'),

  /// 특별 이벤트
  specialEvent(50, '특별한 순간'),

  /// 갈등 발생
  conflict(-20, '갈등'),

  /// 오해
  misunderstanding(-10, '오해'),

  /// 이별 위기
  breakupThreat(-50, '위기');

  final int points;
  final String description;

  const AffinityEvent(this.points, this.description);
}
