/// 피해야 할 사람 분석 모델
class AvoidPersonAnalysis {
  final AvoidPersonType type;
  final String title;
  final String description;
  final List<String> characteristics;
  final List<String> behaviors;
  final String timeOfDay;
  final List<String> copingStrategies;
  final int riskLevel; // 1-5
  final String warningMessage;
  final String colorToAvoid;
  final String location;

  AvoidPersonAnalysis({
    required this.type,
    required this.title,
    required this.description,
    required this.characteristics,
    required this.behaviors,
    required this.timeOfDay,
    required this.copingStrategies,
    required this.riskLevel,
    required this.warningMessage,
    required this.colorToAvoid,
    required this.location,
  });
}

/// 피해야 할 사람 타입
enum AvoidPersonType {
  energyVampire('에너지 뱀파이어', '당신의 긍정 에너지를 빼앗는 사람'),
  critic('비판자', '모든 것을 부정적으로 보는 사람'),
  dramaMaker('드라마 메이커', '불필요한 갈등을 만드는 사람'),
  manipulator('조종자', '당신을 이용하려는 사람'),
  gossiper('가십퍼', '뒷담화를 즐기는 사람');

  final String korean;
  final String description;

  const AvoidPersonType(this.korean, this.description);
}

/// 사용자 입력 데이터
class AvoidPersonInput {
  final String environment; // 직장, 학교, 모임, 가족
  final String importantSchedule; // 면접, 미팅, 데이트 등
  final int moodLevel; // 1-5
  final int stressLevel; // 1-5
  final int socialFatigue; // 1-5
  final bool hasImportantDecision;
  final bool hasSensitiveConversation;
  final bool hasTeamProject;

  AvoidPersonInput({
    required this.environment,
    required this.importantSchedule,
    required this.moodLevel,
    required this.stressLevel,
    required this.socialFatigue,
    required this.hasImportantDecision,
    required this.hasSensitiveConversation,
    required this.hasTeamProject,
  });
}