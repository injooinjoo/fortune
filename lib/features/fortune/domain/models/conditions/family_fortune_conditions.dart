import '../fortune_conditions.dart';

/// 가족운세 조건 모델
///
/// 4단계 입력 데이터를 담는 조건 객체
/// - Step 1: 주요 관심사 (건강운, 재물운, 자녀운, 관계운, 변화운)
/// - Step 2: 세부 질문 (최대 3개 선택)
/// - Step 3: 가족 정보 (구성원 수, 운세 대상)
/// - Step 4: 특별 질문 (선택)
class FamilyFortuneConditions extends FortuneConditions {
  // Step 1: 주요 관심사
  final String concern; // 'health', 'wealth', 'children', 'relationship', 'change'
  final String concernLabel; // '건강운', '재물운' 등

  // Step 2: 세부 질문 (다중 선택, 최대 3개)
  final List<String> detailedQuestions;

  // Step 3: 가족 정보
  final int familyMemberCount; // 1-10
  final String relationship; // 'self', 'parent', 'child', 'spouse'

  // Step 4: 특별 질문 (선택)
  final String? specialQuestion;

  FamilyFortuneConditions({
    required this.concern,
    required this.concernLabel,
    required this.detailedQuestions,
    required this.familyMemberCount,
    required this.relationship,
    this.specialQuestion,
  });

  @override
  Map<String, dynamic> toJson() => {
        'concern': concern,
        'concern_label': concernLabel,
        'detailed_questions': detailedQuestions,
        'family_member_count': familyMemberCount,
        'relationship': relationship,
        if (specialQuestion != null && specialQuestion!.isNotEmpty)
          'special_question': specialQuestion,
      };

  factory FamilyFortuneConditions.fromJson(Map<String, dynamic> json) {
    return FamilyFortuneConditions(
      concern: json['concern'] as String,
      concernLabel: json['concern_label'] as String,
      detailedQuestions: List<String>.from(json['detailed_questions'] ?? []),
      familyMemberCount: json['family_member_count'] as int? ?? 1,
      relationship: json['relationship'] as String? ?? 'self',
      specialQuestion: json['special_question'] as String?,
    );
  }

  /// Map<String, dynamic>에서 생성 (기존 입력 데이터 호환)
  factory FamilyFortuneConditions.fromInputData(Map<String, dynamic> data) {
    return FamilyFortuneConditions(
      concern: data['concern'] as String? ?? 'health',
      concernLabel: data['concern_label'] as String? ?? '건강운',
      detailedQuestions: List<String>.from(data['detailed_questions'] ?? []),
      familyMemberCount: data['family_member_count'] as int? ?? 1,
      relationship: data['relationship'] as String? ?? 'self',
      specialQuestion: data['special_question'] as String?,
    );
  }

  /// 해시 생성 (DB 캐싱용)
  ///
  /// 동일 조건 판단:
  /// - concern: 어떤 가족 운세인지 (health, wealth 등)
  /// - detailedQuestions: 어떤 세부 질문을 선택했는지
  /// - relationship: 운세 대상 (self, parent, child, spouse)
  ///
  /// 해시에서 제외 (개인화 요소):
  /// - familyMemberCount: 가족 수는 개인정보
  /// - specialQuestion: 자유 텍스트는 항상 다름
  @override
  String generateHash() {
    final sortedQuestions = List<String>.from(detailedQuestions)..sort();
    final parts = <String>[
      'concern:$concern',
      'questions:${sortedQuestions.join(",")}',
      'relationship:$relationship',
    ];
    return parts.join('|');
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      'concern': concern,
      'detailed_questions': detailedQuestions,
      'relationship': relationship,
      // familyMemberCount, specialQuestion은 개인정보이므로 제외
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      'concern': concern,
      'concern_label': concernLabel,
      'detailed_questions': detailedQuestions,
      'family_member_count': familyMemberCount,
      'relationship': relationship,
      if (specialQuestion != null && specialQuestion!.isNotEmpty)
        'special_question': specialQuestion,
    };
  }

  @override
  String toString() {
    return 'FamilyFortuneConditions(concern: $concern, questions: ${detailedQuestions.length}, relationship: $relationship)';
  }
}
