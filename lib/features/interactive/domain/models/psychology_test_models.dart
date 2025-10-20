// Psychology Test Models
//
// 심리 테스트 관련 데이터 모델 정의

// ============================================================================
// Question Models
// ============================================================================

class PsychologyQuestion {
  final String id;
  final String question;
  final List<QuestionOption> options;

  const PsychologyQuestion({
    required this.id,
    required this.question,
    required this.options,
  });
}

class QuestionOption {
  final String value;
  final String label;

  const QuestionOption({
    required this.value,
    required this.label,
  });
}

// ============================================================================
// Test Input/Result Models
// ============================================================================

class PsychologyTestInput {
  final String name;
  final String birthDate;
  final Map<String, String> answers;

  PsychologyTestInput({
    required this.name,
    required this.birthDate,
    required this.answers,
  });
}

class PsychologyTestResult {
  final int overallLuck;
  final String testResultType;
  final String resultSummary;
  final String resultDetails;
  final String advice;
  final List<String> luckyElements;

  PsychologyTestResult({
    required this.overallLuck,
    required this.testResultType,
    required this.resultSummary,
    required this.resultDetails,
    required this.advice,
    required this.luckyElements,
  });

  factory PsychologyTestResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return PsychologyTestResult(
      overallLuck: data['overall_luck'],
      testResultType: data['test_result_type'] ?? '',
      resultSummary: data['result_summary'] ?? '',
      resultDetails: data['result_details'] ?? '',
      advice: data['advice'] ?? '',
      luckyElements: List<String>.from(data['lucky_elements'] ?? []),
    );
  }
}

// ============================================================================
// Question Data
// ============================================================================

final psychologyQuestions = [
  PsychologyQuestion(
    id: 'q1',
    question: '새로운 환경에 놓였을 때 당신의 반응은?',
    options: [
      QuestionOption(value: 'a', label: '적극적으로 탐색하고 새로운 사람들과 어울린다'),
      QuestionOption(value: 'b', label: '조심스럽게 관찰하며 천천히 적응한다'),
      QuestionOption(value: 'c', label: '익숙한 것을 찾아 안정감을 찾는다'),
      QuestionOption(value: 'd', label: '불안하지만 필요한 것만 빠르게 파악한다'),
    ],
  ),
  PsychologyQuestion(
    id: 'q2',
    question: '스트레스를 받을 때 주로 어떻게 해소하나요?',
    options: [
      QuestionOption(value: 'a', label: '운동이나 활동적인 취미로 해소한다'),
      QuestionOption(value: 'b', label: '혼자만의 시간을 가지며 휴식한다'),
      QuestionOption(value: 'c', label: '친구나 가족과 대화를 나눈다'),
      QuestionOption(value: 'd', label: '취미 활동에 몰두한다'),
    ],
  ),
  PsychologyQuestion(
    id: 'q3',
    question: '중요한 결정을 내릴 때 당신의 방식은?',
    options: [
      QuestionOption(value: 'a', label: '직감과 감정을 따른다'),
      QuestionOption(value: 'b', label: '논리적으로 분석하고 계산한다'),
      QuestionOption(value: 'c', label: '다른 사람들의 조언을 구한다'),
      QuestionOption(value: 'd', label: '과거 경험을 바탕으로 판단한다'),
    ],
  ),
  PsychologyQuestion(
    id: 'q4',
    question: '팀 프로젝트에서 당신의 역할은?',
    options: [
      QuestionOption(value: 'a', label: '리더가 되어 방향을 제시한다'),
      QuestionOption(value: 'b', label: '아이디어를 제공하고 창의적인 해결책을 찾는다'),
      QuestionOption(value: 'c', label: '팀원들 사이의 조율자 역할을 한다'),
      QuestionOption(value: 'd', label: '맡은 일을 꼼꼼하게 완수한다'),
    ],
  ),
  PsychologyQuestion(
    id: 'q5',
    question: '휴일을 보내는 이상적인 방법은?',
    options: [
      QuestionOption(value: 'a', label: '새로운 장소를 탐험하거나 모험을 한다'),
      QuestionOption(value: 'b', label: '집에서 편안하게 휴식을 취한다'),
      QuestionOption(value: 'c', label: '친구들과 만나 시간을 보낸다'),
      QuestionOption(value: 'd', label: '계획한 취미 활동을 실행한다'),
    ],
  ),
];
