import 'dart:math';
import 'package:uuid/uuid.dart';

import '../../data/models/chat_insight_result.dart';
import 'anonymizer.dart';

/// 로컬 룰 기반 대화 분석기
/// 서버 전송 없이 기기에서 직접 분석
class FeatureExtractor {
  static const _uuid = Uuid();

  /// 익명화된 메시지로부터 ChatInsightResult 생성
  static ChatInsightResult analyze(
    AnonymizedResult anonymized,
    AnalysisConfig config,
  ) {
    final messages = anonymized.messages;
    final userLabel = anonymized.senderMapping.userLabel;

    final userMessages = messages.where((m) => m.sender == userLabel).toList();
    final otherMessages = messages.where((m) => m.sender != userLabel).toList();

    final temperatureScore = _calcTemperature(messages);
    final stabilityScore = _calcStability(messages);
    final initiativeScore = _calcInitiative(userMessages, otherMessages);
    final riskScore = _calcRisk(messages, userMessages, otherMessages);

    final timeline = _buildTimeline(messages);
    final patterns = _detectPatterns(messages, userMessages, otherMessages);
    final highlights = _buildHighlights(
      messages,
      userMessages,
      otherMessages,
      temperatureScore,
      stabilityScore,
      initiativeScore,
      riskScore,
      patterns,
    );
    final triggers = _extractTriggers(messages, config.intensity);
    final guidance = _buildGuidance(patterns, config.relationType);

    final dateFrom =
        messages.isNotEmpty ? messages.first.timestamp : DateTime.now();
    final dateTo =
        messages.isNotEmpty ? messages.last.timestamp : DateTime.now();

    return ChatInsightResult(
      analysisMeta: AnalysisMeta(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        relationType: config.relationType,
        range: config.dateRange,
        intensity: config.intensity,
        privacy: const PrivacyConfig(),
        messageCount: messages.length,
        dateFrom: dateFrom,
        dateTo: dateTo,
      ),
      scores: InsightScores(
        temperature: ScoreItem(
          value: temperatureScore,
          label: _tempLabel(temperatureScore),
          trend: _calcTrend(messages, _sentimentScore),
        ),
        stability: ScoreItem(
          value: stabilityScore,
          label: _stabilityLabel(stabilityScore),
          trend: ScoreTrend.stable,
        ),
        initiative: ScoreItem(
          value: initiativeScore,
          label: _initiativeLabel(initiativeScore),
          trend: ScoreTrend.stable,
        ),
        risk: ScoreItem(
          value: riskScore,
          label: _riskLabel(riskScore),
          trend: riskScore > 50 ? ScoreTrend.up : ScoreTrend.stable,
        ),
      ),
      highlights: highlights,
      timeline: timeline,
      patterns: InsightPatterns(items: patterns),
      triggers: triggers,
      guidance: guidance,
      followupMemory: FollowupMemory(
        safeNotes: _buildSafeNotes(
          config,
          messages.length,
          temperatureScore,
          stabilityScore,
          initiativeScore,
          riskScore,
          patterns,
        ),
        userQuestions: [],
      ),
    );
  }

  // --- Score Calculations ---

  /// 관계 온도: 긍정 키워드 비율 기반
  static int _calcTemperature(List<AnonymizedMessage> messages) {
    if (messages.isEmpty) return 50;

    int positiveCount = 0;
    int negativeCount = 0;

    for (final msg in messages) {
      final text = msg.text;
      positiveCount += _positiveKeywords.where((k) => text.contains(k)).length;
      negativeCount += _negativeKeywords.where((k) => text.contains(k)).length;
    }

    final total = positiveCount + negativeCount;
    if (total == 0) return 50;

    final ratio = positiveCount / total;
    return (ratio * 100).round().clamp(0, 100);
  }

  /// 안정성: 대화 빈도 변동성 (낮을수록 안정)
  static int _calcStability(List<AnonymizedMessage> messages) {
    if (messages.length < 10) return 50;

    // 일별 메시지 수 계산
    final dailyCounts = <String, int>{};
    for (final msg in messages) {
      final key =
          '${msg.timestamp.year}-${msg.timestamp.month}-${msg.timestamp.day}';
      dailyCounts[key] = (dailyCounts[key] ?? 0) + 1;
    }

    if (dailyCounts.length < 3) return 50;

    final counts = dailyCounts.values.toList();
    final mean = counts.reduce((a, b) => a + b) / counts.length;
    final variance =
        counts.map((c) => pow(c - mean, 2)).reduce((a, b) => a + b) /
            counts.length;
    final stdDev = sqrt(variance);
    final cv = mean > 0 ? stdDev / mean : 0; // 변동계수

    // CV가 낮을수록 안정 → 높은 점수
    final score = ((1 - cv.clamp(0, 2) / 2) * 100).round();
    return score.clamp(0, 100);
  }

  /// 주도권: 사용자가 먼저 연락하는 비율
  static int _calcInitiative(
    List<AnonymizedMessage> userMsgs,
    List<AnonymizedMessage> otherMsgs,
  ) {
    if (userMsgs.isEmpty && otherMsgs.isEmpty) return 50;

    final allMessages = [...userMsgs, ...otherMsgs]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    int userInitCount = 0;
    int otherInitCount = 0;
    String? lastSender;
    DateTime? lastTime;

    for (final msg in allMessages) {
      final gap =
          lastTime != null ? msg.timestamp.difference(lastTime).inMinutes : 999;

      // 2시간 이상 공백 후 첫 메시지 = 대화 시작
      if (gap > 120 || lastSender == null) {
        if (msg.sender == 'A') {
          userInitCount++;
        } else {
          otherInitCount++;
        }
      }

      lastSender = msg.sender;
      lastTime = msg.timestamp;
    }

    final total = userInitCount + otherInitCount;
    if (total == 0) return 50;

    // 50 = 균형, 100 = 사용자 완전 주도, 0 = 상대 완전 주도
    return ((userInitCount / total) * 100).round().clamp(0, 100);
  }

  /// 위험도: 부정 신호 복합 판단
  static int _calcRisk(
    List<AnonymizedMessage> all,
    List<AnonymizedMessage> userMsgs,
    List<AnonymizedMessage> otherMsgs,
  ) {
    if (all.isEmpty) return 0;

    double risk = 0;

    // 응답 시간 비대칭
    final userAvgReply = _avgReplyTime(all, 'A');
    final otherAvgReply = _avgReplyTime(all, 'B');
    if (userAvgReply > 0 && otherAvgReply > 0) {
      final replyRatio = otherAvgReply / userAvgReply;
      if (replyRatio > 3) {
        risk += 20;
      } else if (replyRatio > 2) {
        risk += 10;
      }
    }

    // 대화량 감소 추세 (후반 30% vs 전반 30%)
    final splitPoint = (all.length * 0.3).round();
    if (splitPoint > 0 && all.length - splitPoint > 0) {
      final earlyCount = splitPoint;
      final lateCount = all.length - (all.length - splitPoint);
      if (earlyCount > 0) {
        final ratio = lateCount / earlyCount;
        if (ratio < 0.5) {
          risk += 20;
        } else if (ratio < 0.7) {
          risk += 10;
        }
      }
    }

    // 부정 키워드 빈도
    int negCount = 0;
    for (final msg in all) {
      negCount += _negativeKeywords.where((k) => msg.text.contains(k)).length;
    }
    final negRatio = negCount / all.length;
    if (negRatio > 0.3) {
      risk += 20;
    } else if (negRatio > 0.15) {
      risk += 10;
    }

    // 단답 비율 (상대)
    if (otherMsgs.isNotEmpty) {
      final shortReplies = otherMsgs.where((m) => m.text.length <= 5).length;
      final shortRatio = shortReplies / otherMsgs.length;
      if (shortRatio > 0.5) {
        risk += 15;
      } else if (shortRatio > 0.3) {
        risk += 8;
      }
    }

    return risk.round().clamp(0, 100);
  }

  /// 평균 응답 시간 (분)
  static double _avgReplyTime(List<AnonymizedMessage> messages, String sender) {
    final sorted = [...messages]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final replyTimes = <int>[];

    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i].sender == sender && sorted[i - 1].sender != sender) {
        final gap =
            sorted[i].timestamp.difference(sorted[i - 1].timestamp).inMinutes;
        if (gap > 0 && gap < 1440) {
          // 24시간 이내만
          replyTimes.add(gap);
        }
      }
    }

    if (replyTimes.isEmpty) return 0;
    return replyTimes.reduce((a, b) => a + b) / replyTimes.length;
  }

  // --- Timeline ---

  static InsightTimeline _buildTimeline(List<AnonymizedMessage> messages) {
    if (messages.isEmpty) {
      return const InsightTimeline(points: [], dips: [], spikes: []);
    }

    // 주 단위로 감정 점수 집계
    final weeklyScores = <DateTime, List<double>>{};
    for (final msg in messages) {
      // 주의 시작일 (월요일)
      final weekStart = msg.timestamp.subtract(
        Duration(days: msg.timestamp.weekday - 1),
      );
      final key = DateTime(weekStart.year, weekStart.month, weekStart.day);

      weeklyScores.putIfAbsent(key, () => []);
      weeklyScores[key]!.add(_sentimentScore(msg.text));
    }

    final points = <TimelinePoint>[];
    final sortedWeeks = weeklyScores.keys.toList()..sort();

    for (final week in sortedWeeks) {
      final scores = weeklyScores[week]!;
      final avg = scores.reduce((a, b) => a + b) / scores.length;
      points.add(TimelinePoint(time: week, sentiment: avg));
    }

    // Dips & Spikes 탐지
    final dips = <TimelineEvent>[];
    final spikes = <TimelineEvent>[];

    for (int i = 1; i < points.length; i++) {
      final diff = points[i].sentiment - points[i - 1].sentiment;
      if (diff < -0.3) {
        dips.add(TimelineEvent(
          time: points[i].time,
          label: '감정 점수 급락',
        ));
      } else if (diff > 0.3) {
        spikes.add(TimelineEvent(
          time: points[i].time,
          label: '감정 점수 급등',
        ));
      }
    }

    return InsightTimeline(points: points, dips: dips, spikes: spikes);
  }

  // --- Patterns ---

  static List<PatternItem> _detectPatterns(
    List<AnonymizedMessage> all,
    List<AnonymizedMessage> userMsgs,
    List<AnonymizedMessage> otherMsgs,
  ) {
    final patterns = <PatternItem>[];

    // 응답 비대칭
    final userAvg = _avgReplyTime(all, 'A');
    final otherAvg = _avgReplyTime(all, 'B');
    if (userAvg > 0 && otherAvg > 0 && (otherAvg / userAvg) > 1.5) {
      final ratio = (userMsgs.length / max(otherMsgs.length, 1) * 100).round();
      patterns.add(PatternItem(
        tag: '응답 비대칭',
        evidenceCount: userMsgs.length,
        description: 'A가 먼저 연락하는 비율이 $ratio%로, 대화 주도권이 한쪽에 치우쳐 있어요',
      ));
    }

    // 시간대 패턴
    final hourCounts = List.filled(24, 0);
    for (final msg in all) {
      hourCounts[msg.timestamp.hour]++;
    }
    final peakHour = hourCounts.indexOf(hourCounts.reduce(max));
    final peakCount = hourCounts[peakHour];
    if (peakCount > all.length * 0.15) {
      patterns.add(PatternItem(
        tag: '시간대 집중',
        evidenceCount: peakCount,
        description: '$peakHour시 전후로 대화가 집중되는 패턴이에요',
      ));
    }

    // 주말 공백
    final weekdayMsgs = all.where((m) => m.timestamp.weekday <= 5).length;
    final weekendMsgs = all.where((m) => m.timestamp.weekday > 5).length;
    if (weekdayMsgs > 0 && weekendMsgs < weekdayMsgs * 0.2) {
      patterns.add(PatternItem(
        tag: '주말 공백',
        evidenceCount: weekendMsgs,
        description:
            '주말 대화가 평일의 ${(weekendMsgs / max(weekdayMsgs, 1) * 100).round()}% 수준으로 적어요',
      ));
    }

    // 감정 표현 패턴
    int emojiCount = 0;
    final emojiPattern = RegExp(
        r'[\u{1F600}-\u{1F64F}\u{2764}\u{1F495}-\u{1F49F}❤️💕💗💓💖]',
        unicode: true);
    for (final msg in all) {
      if (emojiPattern.hasMatch(msg.text)) emojiCount++;
    }
    if (emojiCount > all.length * 0.1) {
      patterns.add(PatternItem(
        tag: '감정 표현 활발',
        evidenceCount: emojiCount,
        description: '이모지/하트 사용 빈도가 높아 감정 표현이 활발한 편이에요',
      ));
    }

    // 배려 표현 유지
    int careCount = 0;
    for (final msg in all) {
      if (_careKeywords.any((k) => msg.text.contains(k))) careCount++;
    }
    if (careCount > 10) {
      patterns.add(PatternItem(
        tag: '배려 유지',
        evidenceCount: careCount,
        description: '\'고마워\', \'잘 자\', \'밥 먹었어?\' 등 일상 배려 표현이 꾸준해요',
      ));
    }

    return patterns;
  }

  // --- Highlights ---

  static InsightHighlights _buildHighlights(
    List<AnonymizedMessage> all,
    List<AnonymizedMessage> userMsgs,
    List<AnonymizedMessage> otherMsgs,
    int temperature,
    int stability,
    int initiative,
    int risk,
    List<PatternItem> patterns,
  ) {
    final bullets = <String>[];

    bullets.add('총 ${all.length}개의 메시지를 분석했어요');

    if (all.length >= 10) {
      final days = all.last.timestamp.difference(all.first.timestamp).inDays;
      if (days > 0) {
        final avgPerDay = (all.length / days).toStringAsFixed(1);
        bullets.add('하루 평균 $avgPerDay개의 메시지를 주고받았어요');
      }
    }

    if (initiative < 40) {
      bullets.add('상대방이 대화를 주도하는 경향이 있어요');
    } else if (initiative > 60) {
      bullets.add('주로 A가 먼저 연락하는 패턴이에요');
    }

    for (final pattern in patterns.take(2)) {
      bullets.add(pattern.description);
    }

    // Red flags
    final redFlags = <RedFlag>[];
    if (risk > 50) {
      redFlags.add(const RedFlag(
        text: '대화 패턴에서 주의가 필요한 신호가 감지되었어요',
        severity: Severity.medium,
      ));
    }

    final userAvg = _avgReplyTime(all, 'A');
    final otherAvg = _avgReplyTime(all, 'B');
    if (otherAvg > userAvg * 2 && userAvg > 0) {
      redFlags.add(RedFlag(
        text:
            '응답 시간 격차가 벌어지고 있어요 (A: ${userAvg.round()}분, B: ${otherAvg.round()}분)',
        severity: Severity.medium,
      ));
    }

    // Green flags
    final greenFlags = <GreenFlag>[];
    final carePattern = patterns.where((p) => p.tag == '배려 유지');
    if (carePattern.isNotEmpty) {
      greenFlags.add(const GreenFlag(
        text: '일상 배려 표현이 꾸준히 유지되고 있어요',
        strength: Severity.high,
      ));
    }

    if (stability > 60) {
      greenFlags.add(const GreenFlag(
        text: '대화 빈도가 안정적으로 유지되고 있어요',
        strength: Severity.medium,
      ));
    }

    return InsightHighlights(
      summaryBullets: bullets.take(5).toList(),
      redFlags: redFlags,
      greenFlags: greenFlags,
    );
  }

  // --- Triggers ---

  static InsightTriggers _extractTriggers(
    List<AnonymizedMessage> messages,
    AnalysisIntensity intensity,
  ) {
    if (intensity == AnalysisIntensity.light || messages.isEmpty) {
      return const InsightTriggers(items: []);
    }

    final triggers = <TriggerItem>[];

    // 대화 흐름에서 감정 변화가 큰 지점 탐지
    for (int i = 1; i < messages.length && triggers.length < 5; i++) {
      final prev = _sentimentScore(messages[i - 1].text);
      final curr = _sentimentScore(messages[i].text);

      if ((prev - curr).abs() > 0.5 && messages[i].text.length > 10) {
        triggers.add(TriggerItem(
          maskedQuote:
              '${messages[i - 1].sender}: \'${_truncate(messages[i - 1].text, 30)}\' → '
              '${messages[i].sender}: \'${_truncate(messages[i].text, 30)}\'',
          whyItMatters:
              curr < prev ? '대화 흐름에서 감정 톤이 급변한 지점이에요' : '긍정적인 전환이 일어난 대화예요',
          time: messages[i].timestamp,
        ));
      }
    }

    return InsightTriggers(items: triggers);
  }

  // --- Guidance ---

  static InsightGuidance _buildGuidance(
    List<PatternItem> patterns,
    RelationType relationType,
  ) {
    final doList = <GuidanceItem>[];
    final dontList = <GuidanceItem>[];

    // 패턴 기반 가이던스
    for (final pattern in patterns) {
      switch (pattern.tag) {
        case '응답 비대칭':
          doList.add(const GuidanceItem(
            text: '상대가 짧게 답할 때 추가 질문 대신, 자신의 이야기를 먼저 공유해보세요',
            expectedEffect: '대화 부담을 줄이면서 자연스러운 소통을 유도할 수 있어요',
          ));
          dontList.add(const GuidanceItem(
            text: '읽씹 시간을 체크하거나 언급하지 마세요',
            expectedEffect: '감시받는 느낌을 주면 자연스러운 소통이 어려워져요',
          ));
        case '주말 공백':
          doList.add(const GuidanceItem(
            text: '주말에 구체적인 활동을 제안해보세요',
            expectedEffect: '주말 공백 패턴을 자연스럽게 확인할 수 있어요',
          ));
        case '배려 유지':
          doList.add(const GuidanceItem(
            text: '감사 표현을 더 구체적으로 해보세요',
            expectedEffect: '이미 유지되는 배려 패턴을 강화할 수 있어요',
          ));
      }
    }

    // 기본 가이던스
    if (doList.isEmpty) {
      doList.add(const GuidanceItem(
        text: '상대의 이야기에 구체적으로 반응해보세요',
        expectedEffect: '상대방이 경청받고 있다고 느낄 수 있어요',
      ));
    }

    if (dontList.isEmpty) {
      dontList.add(const GuidanceItem(
        text: '\'왜 연락 안 해?\' 같은 직접적 추궁은 피해주세요',
        expectedEffect: '방어적 반응을 유발하고 대화 빈도가 더 줄 수 있어요',
      ));
    }

    return InsightGuidance(doList: doList, dontList: dontList);
  }

  // --- Safe Notes ---

  static String _buildSafeNotes(
    AnalysisConfig config,
    int messageCount,
    int temp,
    int stability,
    int initiative,
    int risk,
    List<PatternItem> patterns,
  ) {
    final patternTags = patterns.map((p) => p.tag).join(', ');
    return '${config.relationType.name} 관계 분석. '
        '메시지 $messageCount개. '
        '온도 $temp점, 안정성 $stability점, 주도권 $initiative점, 위험 $risk점. '
        '패턴: $patternTags';
  }

  // --- Helpers ---

  static double _sentimentScore(String text) {
    final pos = _positiveKeywords.where((k) => text.contains(k)).length;
    final neg = _negativeKeywords.where((k) => text.contains(k)).length;
    if (pos + neg == 0) return 0.0;
    return ((pos - neg) / (pos + neg)).clamp(-1.0, 1.0);
  }

  static ScoreTrend _calcTrend(
    List<AnonymizedMessage> messages,
    double Function(String) scorer,
  ) {
    if (messages.length < 20) return ScoreTrend.stable;

    final half = messages.length ~/ 2;
    final firstHalf = messages.sublist(0, half);
    final secondHalf = messages.sublist(half);

    double firstAvg = 0;
    for (final m in firstHalf) {
      firstAvg += scorer(m.text);
    }
    firstAvg /= firstHalf.length;

    double secondAvg = 0;
    for (final m in secondHalf) {
      secondAvg += scorer(m.text);
    }
    secondAvg /= secondHalf.length;

    final diff = secondAvg - firstAvg;
    if (diff > 0.1) return ScoreTrend.up;
    if (diff < -0.1) return ScoreTrend.down;
    return ScoreTrend.stable;
  }

  static String _truncate(String text, int maxLen) {
    if (text.length <= maxLen) return text;
    return '${text.substring(0, maxLen)}...';
  }

  static String _tempLabel(int score) {
    if (score >= 80) return '매우 따뜻함';
    if (score >= 60) return '따뜻한 편';
    if (score >= 40) return '보통';
    if (score >= 20) return '다소 차가움';
    return '차가운 편';
  }

  static String _stabilityLabel(int score) {
    if (score >= 70) return '안정적';
    if (score >= 40) return '보통';
    return '다소 불안정';
  }

  static String _initiativeLabel(int score) {
    if (score >= 70) return '내가 주도적';
    if (score >= 40) return '균형적';
    return '상대 주도적';
  }

  static String _riskLabel(int score) {
    if (score >= 60) return '주의 필요';
    if (score >= 30) return '관찰 중';
    return '안정';
  }

  // --- Keyword Dictionaries ---

  static const _positiveKeywords = [
    '고마워',
    '감사',
    '사랑해',
    '좋아해',
    '보고싶',
    '보고 싶',
    '행복',
    '기뻐',
    '좋아',
    '최고',
    '대단해',
    '잘했',
    '수고했',
    '응원',
    '파이팅',
    '화이팅',
    '힘내',
    '걱정',
    '괜찮아',
    '맛있',
    '재밌',
    '웃기',
    '귀여',
    '예쁘',
    '멋지',
    'ㅋㅋ',
    'ㅎㅎ',
    '하하',
    '히히',
    '❤',
    '♥',
    '💕',
  ];

  static const _negativeKeywords = [
    '싫어',
    '짜증',
    '화나',
    '화 나',
    '미안',
    '슬퍼',
    '슬프',
    '힘들',
    '지쳐',
    '지겨',
    '피곤',
    '귀찮',
    '싫다',
    '걱정',
    '불안',
    '무서',
    '두려',
    '외로',
    '그만',
    '됐어',
    '몰라',
    '아 진짜',
    '헐',
    '에휴',
  ];

  static const _careKeywords = [
    '잘 자',
    '잘자',
    '좋은 꿈',
    '밥 먹었',
    '밥먹었',
    '조심해',
    '조심히',
    '고마워',
    '수고했어',
    '수고',
    '걱정돼',
    '괜찮아',
    '아프지 마',
    '건강',
    '따뜻하게',
  ];
}
