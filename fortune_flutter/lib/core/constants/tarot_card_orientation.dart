import 'dart:math' as math;

enum CardOrientation {
  upright,
  reversed;

  String get displayName {
    switch (this) {
      case CardOrientation.upright:
        return '정방향';
      case CardOrientation.reversed:
        return '역방향';
    }
  }

  String get symbol {
    switch (this) {
      case CardOrientation.upright:
        return '↑';
      case CardOrientation.reversed:
        return '↓';
    }
  }
}

class TarotCardState {
  final int cardIndex;
  final CardOrientation orientation;
  final DateTime selectedAt;

  TarotCardState({
    required this.cardIndex,
    required this.orientation,
    required this.selectedAt,
  });

  // 랜덤하게 카드 방향 결정 (70% 정방향, 30% 역방향)
  static CardOrientation getRandomOrientation() {
    final random = math.Random();
    return random.nextDouble() < 0.7 
        ? CardOrientation.upright 
        : CardOrientation.reversed;
  }

  // 카드 선택 시 상태 생성
  factory TarotCardState.fromSelection(int cardIndex) {
    return TarotCardState(
      cardIndex: cardIndex,
      orientation: getRandomOrientation(),
      selectedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardIndex': cardIndex,
      'orientation': orientation.name,
      'selectedAt': selectedAt.toIso8601String(),
    };
  }

  factory TarotCardState.fromJson(Map<String, dynamic> json) {
    return TarotCardState(
      cardIndex: json['cardIndex'],
      orientation: CardOrientation.values.firstWhere(
        (e) => e.name == json['orientation'],
        orElse: () => CardOrientation.upright,
      ),
      selectedAt: DateTime.parse(json['selectedAt']),
    );
  }
}

// 카드 해석 확장
extension TarotCardInterpretation on TarotCardState {
  String getMeaning({
    required String uprightMeaning,
    required String reversedMeaning,
  }) {
    return orientation == CardOrientation.upright
        ? uprightMeaning
        : reversedMeaning;
  }

  String getOrientedName(String baseName) {
    return '$baseName (${orientation.displayName})';
  }

  // 역방향일 때 의미 변환 규칙
  String getModifiedKeywords(List<String> baseKeywords) {
    if (orientation == CardOrientation.upright) {
      return baseKeywords.join(', ');
    }

    // 역방향 키워드 변환
    final reversedKeywords = baseKeywords.map((keyword) {
      // 긍정적 키워드를 부정적으로 변환
      final reversalMap = {
        '사랑': '이별',
        '성공': '좌절',
        '행운': '불운',
        '성장': '정체',
        '조화': '불화',
        '평화': '갈등',
        '희망': '절망',
        '자유': '속박',
        '창의성': '막힘',
        '안정': '불안정',
        '풍요': '결핍',
        '지혜': '혼란',
        '용기': '두려움',
        '신뢰': '의심',
        '치유': '상처',
      };

      // 부정적 키워드를 더 강화
      final intensificationMap = {
        '도전': '심각한 위기',
        '변화': '급격한 변화',
        '종료': '완전한 끝',
        '갈등': '심한 갈등',
        '어려움': '극심한 어려움',
      };

      if (reversalMap.containsKey(keyword)) {
        return reversalMap[keyword]!;
      } else if (intensificationMap.containsKey(keyword)) {
        return intensificationMap[keyword]!;
      } else {
        // 기본적으로 '~의 부족' 또는 '~의 문제'로 변환
        return '$keyword의 부족';
      }
    }).toList();

    return reversedKeywords.join(', ');
  }
}