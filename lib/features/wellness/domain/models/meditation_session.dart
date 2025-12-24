/// 호흡 패턴 종류
enum BreathingPattern {
  /// 4-7-8 호흡법 (수면 유도, 긴장 완화)
  pattern478(
    name: '4-7-8 호흡법',
    description: '수면과 긴장 완화에 효과적인 호흡법',
    inhale: 4,
    hold: 7,
    exhale: 8,
  ),

  /// 박스 호흡법 (집중력 향상)
  boxBreathing(
    name: '박스 호흡법',
    description: '집중력 향상과 스트레스 해소',
    inhale: 4,
    hold: 4,
    exhale: 4,
    holdAfterExhale: 4,
  ),

  /// 릴렉스 호흡법 (빠른 진정)
  relaxBreathing(
    name: '릴렉스 호흡법',
    description: '빠르게 마음을 진정시키는 호흡법',
    inhale: 4,
    hold: 2,
    exhale: 6,
  );

  const BreathingPattern({
    required this.name,
    required this.description,
    required this.inhale,
    required this.hold,
    required this.exhale,
    this.holdAfterExhale,
  });

  final String name;
  final String description;
  final int inhale; // 들숨 (초)
  final int hold; // 멈춤 (초)
  final int exhale; // 날숨 (초)
  final int? holdAfterExhale; // 날숨 후 멈춤 (초, 박스 호흡용)

  /// 한 사이클의 총 시간 (초)
  int get cycleDuration => inhale + hold + exhale + (holdAfterExhale ?? 0);
}

/// 호흡 단계
enum BreathingPhase {
  inhale('들숨'),
  hold('멈춤'),
  exhale('날숨'),
  holdAfterExhale('멈춤');

  const BreathingPhase(this.label);
  final String label;
}

/// 무드 레벨
enum MoodLevel {
  veryBad(-2, 'very_bad', '매우 나쁨'),
  bad(-1, 'bad', '나쁨'),
  neutral(0, 'neutral', '보통'),
  good(1, 'good', '좋음'),
  veryGood(2, 'very_good', '매우 좋음');

  const MoodLevel(this.value, this.key, this.label);
  final int value;
  final String key;
  final String label;
}

/// 명상 세션
class MeditationSession {
  final String id;
  final BreathingPattern pattern;
  final int durationMinutes;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int completedCycles;

  const MeditationSession({
    required this.id,
    required this.pattern,
    required this.durationMinutes,
    required this.startedAt,
    this.completedAt,
    this.completedCycles = 0,
  });
}

/// 무드 기록
class MoodEntry {
  final String id;
  final DateTime date;
  final MoodLevel mood;
  final String? note;
  final List<String> tags;

  const MoodEntry({
    required this.id,
    required this.date,
    required this.mood,
    this.note,
    this.tags = const [],
  });
}

/// 감사 일기 항목
class GratitudeEntry {
  final String id;
  final DateTime date;
  final List<String> items; // 최대 3개
  final String? reflection;

  const GratitudeEntry({
    required this.id,
    required this.date,
    required this.items,
    this.reflection,
  });
}
