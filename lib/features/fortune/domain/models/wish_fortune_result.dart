/// 소원 빌기 결과 데이터 모델 (공감/희망/조언/응원 중심)
class WishFortuneResult {
  final String empathyMessage;    // 공감 메시지 (150자)
  final String hopeMessage;        // 희망과 격려 (200자)
  final List<String> advice;       // 구체적 조언 3개
  final String encouragement;      // 응원 메시지 (100자)
  final String specialWords;       // 신의 한마디 (50자)

  WishFortuneResult({
    required this.empathyMessage,
    required this.hopeMessage,
    required this.advice,
    required this.encouragement,
    required this.specialWords,
  });

  factory WishFortuneResult.fromJson(Map<String, dynamic> json) {
    return WishFortuneResult(
      empathyMessage: json['empathy_message'] as String,
      hopeMessage: json['hope_message'] as String,
      advice: (json['advice'] as List<dynamic>).map((e) => e as String).toList(),
      encouragement: json['encouragement'] as String,
      specialWords: json['special_words'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'empathy_message': empathyMessage,
      'hope_message': hopeMessage,
      'advice': advice,
      'encouragement': encouragement,
      'special_words': specialWords,
    };
  }
}
