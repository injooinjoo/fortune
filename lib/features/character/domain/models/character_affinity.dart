/// 캐릭터 호감도/친밀도 모델
/// 영속성 지원: 로컬(Hive) + 서버(Supabase) 동기화
class CharacterAffinity {
  /// 현재 호감도 포인트 (0-1000)
  final int lovePoints;

  /// 현재 관계 단계
  final AffinityPhase phase;

  /// 마지막 업데이트 시간
  final DateTime? lastUpdated;

  // ========== 신규 필드 (영속성 지원) ==========

  /// 총 메시지 수
  final int totalMessages;

  /// 긍정적 상호작용 횟수
  final int positiveInteractions;

  /// 부정적 상호작용 횟수
  final int negativeInteractions;

  /// 첫 상호작용 시간
  final DateTime? firstInteraction;

  /// 오늘 획득한 포인트 (일일 한도 체크용)
  final int dailyPointsEarned;

  /// 마지막 일일 리셋 날짜
  final DateTime? lastDailyReset;

  /// 현재 연속 접속일
  final int currentStreak;

  /// 최장 연속 접속 기록
  final int longestStreak;

  /// 마지막 대화 날짜 (스트릭 계산용)
  final DateTime? lastChatDate;

  /// 각 단계 최초 달성 시간 기록
  final Map<String, DateTime> phaseHistory;

  /// 일일 포인트 한도
  static const int dailyPointLimit = 100;

  const CharacterAffinity({
    this.lovePoints = 0,
    this.phase = AffinityPhase.stranger,
    this.lastUpdated,
    // 신규 필드
    this.totalMessages = 0,
    this.positiveInteractions = 0,
    this.negativeInteractions = 0,
    this.firstInteraction,
    this.dailyPointsEarned = 0,
    this.lastDailyReset,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastChatDate,
    this.phaseHistory = const {},
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

  /// 다음 단계까지 필요 포인트
  int get pointsToNextPhase {
    final nextPhase = phase.nextPhase;
    if (nextPhase == null) return 0;
    return nextPhase.minPoints - lovePoints;
  }

  /// 다음 단계 진행률 (0.0 ~ 1.0)
  double get progressToNextPhase {
    final nextPhase = phase.nextPhase;
    if (nextPhase == null) return 1.0;

    final currentPhaseMin = phase.minPoints;
    final nextPhaseMin = nextPhase.minPoints;
    final range = nextPhaseMin - currentPhaseMin;

    if (range == 0) return 1.0;
    return ((lovePoints - currentPhaseMin) / range).clamp(0.0, 1.0);
  }

  /// 오늘 추가 획득 가능 포인트
  int get remainingDailyPoints {
    final today = DateTime.now();
    final resetDate = lastDailyReset;

    // 날짜가 바뀌었으면 한도 리셋
    if (resetDate == null || !_isSameDay(resetDate, today)) {
      return dailyPointLimit;
    }

    return (dailyPointLimit - dailyPointsEarned).clamp(0, dailyPointLimit);
  }

  /// 일일 한도 도달 여부
  bool get isDailyLimitReached => remainingDailyPoints <= 0;

  /// 스트릭 활성 여부 (오늘 또는 어제 대화)
  bool get isStreakActive {
    if (lastChatDate == null) return false;
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    return _isSameDay(lastChatDate!, today) ||
        _isSameDay(lastChatDate!, yesterday);
  }

  /// 호감도 증가 (기존 메서드 - 하위 호환)
  CharacterAffinity addPoints(int points) {
    return addPointsWithTracking(points);
  }

  /// 호감도 증가 (트래킹 포함)
  CharacterAffinity addPointsWithTracking(
    int points, {
    AffinityInteractionType interactionType = AffinityInteractionType.neutral,
  }) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // 일일 리셋 체크
    final needsReset =
        lastDailyReset == null || !_isSameDay(lastDailyReset!, today);
    var newDailyEarned = needsReset ? 0 : dailyPointsEarned;

    // 양수 포인트만 일일 한도 적용
    int effectivePoints = points;
    if (points > 0) {
      final available = dailyPointLimit - newDailyEarned;
      effectivePoints = points.clamp(-1000, available);
      newDailyEarned += effectivePoints;
    }

    final newPoints = (lovePoints + effectivePoints).clamp(0, 1000);
    final newPhase = AffinityPhase.fromPoints(newPoints);

    // 단계 상승 시 phaseHistory 업데이트
    final newPhaseHistory = Map<String, DateTime>.from(phaseHistory);
    if (newPhase != phase && newPhase.index > phase.index) {
      if (!newPhaseHistory.containsKey(newPhase.name)) {
        newPhaseHistory[newPhase.name] = today;
      }
    }

    // 스트릭 계산
    int newStreak = currentStreak;
    int newLongestStreak = longestStreak;

    if (lastChatDate != null) {
      final yesterday = today.subtract(const Duration(days: 1));
      if (_isSameDay(lastChatDate!, yesterday)) {
        // 연속 접속
        newStreak = currentStreak + 1;
      } else if (!_isSameDay(lastChatDate!, today)) {
        // 스트릭 끊김
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }
    newLongestStreak = newStreak > longestStreak ? newStreak : longestStreak;

    return copyWith(
      lovePoints: newPoints,
      phase: newPhase,
      lastUpdated: today,
      totalMessages: totalMessages + 1,
      positiveInteractions: interactionType == AffinityInteractionType.positive
          ? positiveInteractions + 1
          : positiveInteractions,
      negativeInteractions: interactionType == AffinityInteractionType.negative
          ? negativeInteractions + 1
          : negativeInteractions,
      firstInteraction: firstInteraction ?? today,
      dailyPointsEarned: newDailyEarned,
      lastDailyReset: todayDate,
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      lastChatDate: todayDate,
      phaseHistory: newPhaseHistory,
    );
  }

  /// 첫 대화 보너스 (+10)
  CharacterAffinity applyFirstChatBonus() {
    final today = DateTime.now();
    if (lastChatDate != null && _isSameDay(lastChatDate!, today)) {
      return this; // 이미 오늘 대화함
    }
    return addPointsWithTracking(10,
        interactionType: AffinityInteractionType.positive);
  }

  /// 스트릭 보너스 (7일마다 +5)
  CharacterAffinity applyStreakBonus() {
    if (currentStreak > 0 && currentStreak % 7 == 0) {
      return copyWith(
        lovePoints: (lovePoints + 5).clamp(0, 1000),
        phase: AffinityPhase.fromPoints((lovePoints + 5).clamp(0, 1000)),
        lastUpdated: DateTime.now(),
      );
    }
    return this;
  }

  /// 장기 부재 패널티 (-5/주, 최대 -50)
  CharacterAffinity applyAbsencePenalty() {
    if (lastChatDate == null) return this;

    final today = DateTime.now();
    final daysSince = today.difference(lastChatDate!).inDays;

    if (daysSince <= 7) return this;

    final weeksAbsent = (daysSince - 7) ~/ 7;
    final penalty = (weeksAbsent * 5).clamp(0, 50);

    if (penalty == 0) return this;

    final newPoints = (lovePoints - penalty).clamp(0, 1000);
    return copyWith(
      lovePoints: newPoints,
      phase: AffinityPhase.fromPoints(newPoints),
      lastUpdated: today,
    );
  }

  /// 상태창용 문자열
  String toStatusString() {
    return '💕 호감도: $loveBar $lovePercent%\n'
        '🎭 관계: ${phase.displayName}\n'
        '🔥 연속: $currentStreak일';
  }

  /// 상세 통계 문자열
  String toDetailedStats() {
    return '''
💕 호감도: $lovePoints/1000 ($lovePercent%)
🎭 관계: ${phase.displayName}
📊 다음 단계: ${pointsToNextPhase > 0 ? '$pointsToNextPhase점 필요' : '최고 단계'}
💬 총 대화: $totalMessages회
🔥 연속 접속: $currentStreak일 (최장 $longestStreak일)
📅 오늘 획득: $dailyPointsEarned/$dailyPointLimit점
''';
  }

  CharacterAffinity copyWith({
    int? lovePoints,
    AffinityPhase? phase,
    DateTime? lastUpdated,
    int? totalMessages,
    int? positiveInteractions,
    int? negativeInteractions,
    DateTime? firstInteraction,
    int? dailyPointsEarned,
    DateTime? lastDailyReset,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastChatDate,
    Map<String, DateTime>? phaseHistory,
  }) {
    return CharacterAffinity(
      lovePoints: lovePoints ?? this.lovePoints,
      phase: phase ?? this.phase,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      totalMessages: totalMessages ?? this.totalMessages,
      positiveInteractions: positiveInteractions ?? this.positiveInteractions,
      negativeInteractions: negativeInteractions ?? this.negativeInteractions,
      firstInteraction: firstInteraction ?? this.firstInteraction,
      dailyPointsEarned: dailyPointsEarned ?? this.dailyPointsEarned,
      lastDailyReset: lastDailyReset ?? this.lastDailyReset,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastChatDate: lastChatDate ?? this.lastChatDate,
      phaseHistory: phaseHistory ?? this.phaseHistory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lovePoints': lovePoints,
      'phase': phase.name,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'totalMessages': totalMessages,
      'positiveInteractions': positiveInteractions,
      'negativeInteractions': negativeInteractions,
      'firstInteraction': firstInteraction?.toIso8601String(),
      'dailyPointsEarned': dailyPointsEarned,
      'lastDailyReset': lastDailyReset?.toIso8601String(),
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastChatDate': lastChatDate?.toIso8601String(),
      'phaseHistory': phaseHistory.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      ),
    };
  }

  /// Supabase 행 데이터로 변환
  Map<String, dynamic> toSupabaseRow(String characterId) {
    return {
      'character_id': characterId,
      'love_points': lovePoints,
      'phase': phase.name,
      'total_messages': totalMessages,
      'positive_interactions': positiveInteractions,
      'negative_interactions': negativeInteractions,
      'first_interaction': firstInteraction?.toIso8601String(),
      'daily_points_earned': dailyPointsEarned,
      'last_daily_reset': lastDailyReset != null
          ? '${lastDailyReset!.year}-${lastDailyReset!.month.toString().padLeft(2, '0')}-${lastDailyReset!.day.toString().padLeft(2, '0')}'
          : null,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_chat_date': lastChatDate != null
          ? '${lastChatDate!.year}-${lastChatDate!.month.toString().padLeft(2, '0')}-${lastChatDate!.day.toString().padLeft(2, '0')}'
          : null,
      'phase_history': phaseHistory.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      ),
    };
  }

  factory CharacterAffinity.fromJson(Map<String, dynamic> json) {
    return CharacterAffinity(
      lovePoints:
          json['lovePoints'] as int? ?? json['love_points'] as int? ?? 0,
      phase: AffinityPhase.values.firstWhere(
        (p) => p.name == json['phase'],
        orElse: () => AffinityPhase.stranger,
      ),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'] as String)
          : json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'] as String)
              : null,
      totalMessages:
          json['totalMessages'] as int? ?? json['total_messages'] as int? ?? 0,
      positiveInteractions: json['positiveInteractions'] as int? ??
          json['positive_interactions'] as int? ??
          0,
      negativeInteractions: json['negativeInteractions'] as int? ??
          json['negative_interactions'] as int? ??
          0,
      firstInteraction: json['firstInteraction'] != null
          ? DateTime.tryParse(json['firstInteraction'] as String)
          : json['first_interaction'] != null
              ? DateTime.tryParse(json['first_interaction'] as String)
              : null,
      dailyPointsEarned: json['dailyPointsEarned'] as int? ??
          json['daily_points_earned'] as int? ??
          0,
      lastDailyReset: json['lastDailyReset'] != null
          ? DateTime.tryParse(json['lastDailyReset'] as String)
          : json['last_daily_reset'] != null
              ? DateTime.tryParse(json['last_daily_reset'] as String)
              : null,
      currentStreak:
          json['currentStreak'] as int? ?? json['current_streak'] as int? ?? 0,
      longestStreak:
          json['longestStreak'] as int? ?? json['longest_streak'] as int? ?? 0,
      lastChatDate: json['lastChatDate'] != null
          ? DateTime.tryParse(json['lastChatDate'] as String)
          : json['last_chat_date'] != null
              ? DateTime.tryParse(json['last_chat_date'] as String)
              : null,
      phaseHistory:
          _parsePhaseHistory(json['phaseHistory'] ?? json['phase_history']),
    );
  }

  static Map<String, DateTime> _parsePhaseHistory(dynamic data) {
    if (data == null) return {};
    if (data is Map<String, dynamic>) {
      return data.map((key, value) {
        final dateTime = value is String ? DateTime.tryParse(value) : null;
        return MapEntry(key, dateTime ?? DateTime.now());
      });
    }
    return {};
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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

  /// 다음 단계
  AffinityPhase? get nextPhase {
    final currentIndex = AffinityPhase.values.indexOf(this);
    if (currentIndex >= AffinityPhase.values.length - 1) return null;
    return AffinityPhase.values[currentIndex + 1];
  }

  /// 이전 단계
  AffinityPhase? get previousPhase {
    final currentIndex = AffinityPhase.values.indexOf(this);
    if (currentIndex <= 0) return null;
    return AffinityPhase.values[currentIndex - 1];
  }

  /// 단계별 해금 기능 설명
  String get unlockDescription {
    return switch (this) {
      AffinityPhase.stranger => '대화 시작하기',
      AffinityPhase.acquaintance => '이름 기억',
      AffinityPhase.friend => '반말 전환 가능',
      AffinityPhase.closeFriend => '특별 이모지 반응',
      AffinityPhase.romantic => '로맨틱 대화 옵션',
      AffinityPhase.soulmate => '독점 콘텐츠 해금',
    };
  }

  /// 단계 전환 조건 (추가 요구사항)
  PhaseRequirement get requirements {
    return switch (this) {
      AffinityPhase.stranger => const PhaseRequirement(messages: 0, streak: 0),
      AffinityPhase.acquaintance =>
        const PhaseRequirement(messages: 3, streak: 0),
      AffinityPhase.friend => const PhaseRequirement(messages: 20, streak: 3),
      AffinityPhase.closeFriend =>
        const PhaseRequirement(messages: 50, streak: 7),
      AffinityPhase.romantic =>
        const PhaseRequirement(messages: 100, streak: 14),
      AffinityPhase.soulmate =>
        const PhaseRequirement(messages: 200, streak: 30),
    };
  }
}

/// 단계 전환 요구사항
class PhaseRequirement {
  final int messages;
  final int streak;

  const PhaseRequirement({required this.messages, required this.streak});

  /// 조건 충족 여부
  bool isMet(CharacterAffinity affinity) {
    return affinity.totalMessages >= messages &&
        affinity.currentStreak >= streak;
  }
}

/// 상호작용 타입 (포인트 트래킹용)
enum AffinityInteractionType {
  positive,
  neutral,
  negative,
}

/// 호감도 변화 이벤트 (AI 평가 결과 매핑)
enum AffinityEvent {
  /// 기본 대화 (+3~8)
  basicChat(5, '대화'),

  /// 품질 높은 대화 (+10~15)
  qualityEngagement(12, '좋은 대화'),

  /// 감정적 지지 (+15~20)
  emotionalSupport(17, '위로'),

  /// 개인 이야기 공유 (+20~25)
  personalDisclosure(22, '비밀 공유'),

  /// 첫 대화 보너스 (+10)
  firstChatBonus(10, '첫 인사'),

  /// 스트릭 보너스 (+5)
  streakBonus(5, '연속 접속'),

  /// 선택지 긍정 (+5~20)
  choicePositive(10, '좋은 선택'),

  /// 선택지 부정 (-5~20)
  choiceNegative(-10, '나쁜 선택'),

  /// 무례한 언행 (-10)
  disrespectful(-10, '무례'),

  /// 갈등 (-15~30)
  conflict(-20, '갈등'),

  /// 스팸 (0)
  spam(0, '스팸'),

  // 기존 호환용 (deprecated)
  @Deprecated('Use basicChat instead')
  normalChat(5, '대화'),
  @Deprecated('Use qualityEngagement instead')
  sweetTalk(15, '달달한 대화'),
  @Deprecated('Use personalDisclosure instead')
  sharedSecret(25, '비밀 공유'),
  @Deprecated('Use emotionalSupport instead')
  comfort(20, '위로'),
  @Deprecated('Use choicePositive with higher value instead')
  gift(30, '선물'),
  @Deprecated('Use specialEvent for milestones')
  specialEvent(50, '특별한 순간'),
  @Deprecated('Use disrespectful instead')
  misunderstanding(-10, '오해'),
  @Deprecated('Use conflict with higher value instead')
  breakupThreat(-50, '위기');

  final int points;
  final String description;

  const AffinityEvent(this.points, this.description);

  /// AI 응답의 reason 문자열로부터 이벤트 매핑
  static AffinityEvent fromReason(String reason) {
    return switch (reason.toLowerCase()) {
      'basic_chat' => AffinityEvent.basicChat,
      'quality_engagement' => AffinityEvent.qualityEngagement,
      'emotional_support' => AffinityEvent.emotionalSupport,
      'personal_disclosure' => AffinityEvent.personalDisclosure,
      'disrespectful' => AffinityEvent.disrespectful,
      'conflict_detected' => AffinityEvent.conflict,
      'spam_detected' => AffinityEvent.spam,
      _ => AffinityEvent.basicChat,
    };
  }

  /// 상호작용 타입
  AffinityInteractionType get interactionType {
    if (points > 0) return AffinityInteractionType.positive;
    if (points < 0) return AffinityInteractionType.negative;
    return AffinityInteractionType.neutral;
  }
}

/// 단계 전환 결과
class PhaseTransitionResult {
  final AffinityPhase previousPhase;
  final AffinityPhase newPhase;

  const PhaseTransitionResult({
    required this.previousPhase,
    required this.newPhase,
  });

  /// 단계 상승 여부
  bool get isUpgrade => newPhase.index > previousPhase.index;

  /// 축하 메시지
  String get celebrationMessage {
    if (!isUpgrade) return '';
    return switch (newPhase) {
      AffinityPhase.acquaintance => '이제 서로를 알아가기 시작했어요!',
      AffinityPhase.friend => '우리 이제 친구가 되었네요!',
      AffinityPhase.closeFriend => '특별한 사이가 되었어요!',
      AffinityPhase.romantic => '드디어 연인이 되었어요! 💕',
      AffinityPhase.soulmate => '소울메이트가 되었습니다! ❤️‍🔥',
      _ => '',
    };
  }

  /// 해금 설명
  String get unlockDescription => newPhase.unlockDescription;
}
