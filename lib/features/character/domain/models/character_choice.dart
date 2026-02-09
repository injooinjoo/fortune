/// 캐릭터 대화 중 선택지 모델
class CharacterChoice {
  /// 선택지 ID
  final String id;

  /// 선택지 텍스트
  final String text;

  /// 선택 시 호감도 변화
  final int affinityChange;

  /// 선택지 타입 (긍정/중립/부정)
  final ChoiceType type;

  /// 선택지 힌트 (옵션)
  final String? hint;

  const CharacterChoice({
    required this.id,
    required this.text,
    this.affinityChange = 0,
    this.type = ChoiceType.neutral,
    this.hint,
  });

  /// 이모지 표시
  String get emoji => switch (type) {
        ChoiceType.positive => '💕',
        ChoiceType.neutral => '💬',
        ChoiceType.negative => '💔',
        ChoiceType.bold => '🔥',
        ChoiceType.shy => '😊',
      };

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'affinityChange': affinityChange,
      'type': type.name,
      'hint': hint,
    };
  }

  factory CharacterChoice.fromJson(Map<String, dynamic> json) {
    return CharacterChoice(
      id: json['id'] as String,
      text: json['text'] as String,
      affinityChange: json['affinityChange'] as int? ?? 0,
      type: ChoiceType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ChoiceType.neutral,
      ),
      hint: json['hint'] as String?,
    );
  }
}

/// 선택지 타입
enum ChoiceType {
  /// 긍정적 (호감도 상승)
  positive,

  /// 중립적
  neutral,

  /// 부정적 (호감도 하락)
  negative,

  /// 대담한 선택
  bold,

  /// 수줍은 선택
  shy,
}

/// 선택지 세트 (2-3개의 선택지)
class ChoiceSet {
  /// 선택지 목록
  final List<CharacterChoice> choices;

  /// 상황 설명 (옵션)
  final String? situation;

  /// 타임아웃 (초, 옵션)
  final int? timeoutSeconds;

  /// 기본 선택 인덱스 (타임아웃 시)
  final int? defaultChoiceIndex;

  const ChoiceSet({
    required this.choices,
    this.situation,
    this.timeoutSeconds,
    this.defaultChoiceIndex,
  });

  /// 선택지가 유효한지 확인
  bool get isValid => choices.length >= 2 && choices.length <= 4;

  Map<String, dynamic> toJson() {
    return {
      'choices': choices.map((c) => c.toJson()).toList(),
      'situation': situation,
      'timeoutSeconds': timeoutSeconds,
      'defaultChoiceIndex': defaultChoiceIndex,
    };
  }

  factory ChoiceSet.fromJson(Map<String, dynamic> json) {
    return ChoiceSet(
      choices: (json['choices'] as List)
          .map((c) => CharacterChoice.fromJson(c as Map<String, dynamic>))
          .toList(),
      situation: json['situation'] as String?,
      timeoutSeconds: json['timeoutSeconds'] as int?,
      defaultChoiceIndex: json['defaultChoiceIndex'] as int?,
    );
  }
}
