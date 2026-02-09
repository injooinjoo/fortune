import 'dart:math';

/// 감정 유형 (Edge Function에서 반환)
enum EmotionType {
  embarrassed,  // 당황
  thinking,     // 고민
  angry,        // 분노
  affection,    // 애정
  happy,        // 기쁨
  casual,       // 일상
}

/// 응답 딜레이 설정 (인스타그램 DM 스타일 - 리얼리스틱)
class ResponseDelayConfig {
  /// 감정별 딜레이 범위 (밀리초) - 실제 사람처럼 충분히 긴 딜레이
  static const Map<EmotionType, (int min, int max)> delayRanges = {
    EmotionType.embarrassed: (5000, 12000),  // 5-12초 (당황 - 뭐라고 해야할지 고민)
    EmotionType.thinking: (4000, 9000),      // 4-9초 (고민 - 신중하게 생각)
    EmotionType.angry: (2500, 5000),         // 2.5-5초 (분노 - 감정적이지만 시간 필요)
    EmotionType.affection: (2500, 5000),     // 2.5-5초 (애정 - 조심스럽게)
    EmotionType.happy: (1500, 3500),         // 1.5-3.5초 (기쁨 - 빠르지만 적당히)
    EmotionType.casual: (2000, 4500),        // 2-4.5초 (일상 - 평범한 속도)
  };

  /// 메시지 길이 기반 추가 딜레이 (글자당 밀리초)
  static const int msPerCharacter = 25;

  /// 최대 딜레이 (밀리초)
  static const int maxDelay = 15000;

  /// 읽음 딜레이 확률 분포 (리얼리스틱)
  /// - 빠른 응답: 2-5초 (30%) - 마침 폰 보고 있었음
  /// - 보통: 5-20초 (35%) - 알림 보고 확인
  /// - 조금 바쁨: 30초-1분 (20%) - 하던 일 마무리 후 확인
  /// - 많이 바쁨: 1-3분 (10%) - 바빠서 나중에 확인
  /// - 매우 바쁨: 3-5분 (5%) - 정말 바쁘거나 고민 중
  static const List<(int probability, int minMs, int maxMs)> readDelayDistribution = [
    (30, 2000, 5000),      // 30%: 2-5초
    (35, 5000, 20000),     // 35%: 5-20초
    (20, 30000, 60000),    // 20%: 30초-1분
    (10, 60000, 180000),   // 10%: 1-3분
    (5, 180000, 300000),   // 5%: 3-5분
  ];

  static final _random = Random();

  /// 감정 문자열을 EmotionType으로 변환
  static EmotionType parseEmotion(String? emotionTag) {
    if (emotionTag == null) return EmotionType.casual;

    final tag = emotionTag.toLowerCase();
    if (tag.contains('embarrass') || tag.contains('당황')) {
      return EmotionType.embarrassed;
    } else if (tag.contains('think') || tag.contains('고민')) {
      return EmotionType.thinking;
    } else if (tag.contains('angry') || tag.contains('분노') || tag.contains('화')) {
      return EmotionType.angry;
    } else if (tag.contains('affection') || tag.contains('애정') || tag.contains('사랑')) {
      return EmotionType.affection;
    } else if (tag.contains('happy') || tag.contains('기쁨') || tag.contains('행복')) {
      return EmotionType.happy;
    }
    return EmotionType.casual;
  }

  /// 타이핑 딜레이 계산 (감정 + 메시지 길이 기반)
  static int calculateTypingDelay({
    required EmotionType emotion,
    required int responseLength,
  }) {
    final (min, max) = delayRanges[emotion] ?? (1000, 2000);
    final baseDelay = min + _random.nextInt(max - min);

    // 메시지 길이 보정 (긴 메시지 = 더 긴 타이핑 시간)
    final lengthBonus = (responseLength * msPerCharacter).clamp(0, 6000);

    return (baseDelay + lengthBonus).clamp(500, maxDelay);
  }

  /// 읽음 딜레이 계산 (확률 분포 기반 - 리얼리스틱)
  static int calculateReadDelay() {
    final roll = _random.nextInt(100);
    int cumulative = 0;

    for (final (probability, minMs, maxMs) in readDelayDistribution) {
      cumulative += probability;
      if (roll < cumulative) {
        return minMs + _random.nextInt(maxMs - minMs);
      }
    }

    // 기본값 (도달하지 않음)
    return 5000;
  }
}
