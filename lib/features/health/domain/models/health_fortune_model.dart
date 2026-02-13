// 건강운세 관련 모델들

/// 신체 부위 enum
enum BodyPart {
  head('머리', '두통, 어지러움, 스트레스'),
  neck('목', '목의 뻣뻣함, 거북목'),
  shoulders('어깨', '어깨 결림, 오십견'),
  chest('가슴', '심장, 폐 건강'),
  stomach('배', '소화기, 위장 건강'),
  back('등', '척추, 등 근육'),
  arms('팔', '팔목, 팔꿈치 관절'),
  legs('다리', '무릎, 발목, 다리 근육'),
  whole('전체', '전반적인 컨디션');

  const BodyPart(this.displayName, this.description);
  final String displayName;
  final String description;
}

/// 현재 컨디션 상태
enum ConditionState {
  excellent('매우 좋음', 4),
  good('좋음', 3),
  normal('보통', 2),
  tired('피곤함', 1),
  sick('몸이 아픔', 0);

  const ConditionState(this.displayName, this.scoreMultiplier);
  final String displayName;
  final int scoreMultiplier;
}

/// 건강운세 결과
class HealthFortuneResult {
  final String id;
  final String userId;
  final DateTime createdAt;
  final int overallScore; // 0-100 전체 건강 점수
  final String mainMessage; // 메인 메시지
  final List<BodyPartHealth> bodyPartHealthList; // 신체 부위별 상태
  final List<HealthRecommendation> recommendations; // 건강 관리 제안
  final List<String> avoidanceList; // 피해야 할 것들
  final HealthTimeline timeline; // 시간대별 컨디션
  final String? tomorrowPreview; // 내일 컨디션 미리보기
  final Map<String, dynamic>? additionalInfo;

  const HealthFortuneResult({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.overallScore,
    required this.mainMessage,
    required this.bodyPartHealthList,
    required this.recommendations,
    required this.avoidanceList,
    required this.timeline,
    this.tomorrowPreview,
    this.additionalInfo,
  });
}

/// 신체 부위별 건강 상태
class BodyPartHealth {
  final BodyPart bodyPart;
  final int score; // 0-100 점수
  final HealthLevel level; // 위험도 레벨
  final String description; // 해당 부위 상태 설명
  final List<String>? specificTips; // 해당 부위 관리 팁

  const BodyPartHealth({
    required this.bodyPart,
    required this.score,
    required this.level,
    required this.description,
    this.specificTips,
  });
}

/// 건강 레벨 (위험도)
enum HealthLevel {
  excellent('매우 좋음', 90, 0xFF4CAF50), // 초록
  good('좋음', 70, 0xFF2196F3), // 파랑
  caution('주의', 50, 0xFFF44336), // 주황
  warning('경고', 30, 0xFFFF5722); // 빨강

  const HealthLevel(this.displayName, this.minScore, this.colorValue);
  final String displayName;
  final int minScore;
  final int colorValue;
}

/// 건강 관리 추천사항
class HealthRecommendation {
  final HealthRecommendationType type;
  final String title;
  final String description;
  final String? icon; // 아이콘 이름
  final int? priority; // 우선순위 (1이 가장 높음)

  const HealthRecommendation({
    required this.type,
    required this.title,
    required this.description,
    this.icon,
    this.priority,
  });
}

/// 건강 관리 추천 타입
enum HealthRecommendationType {
  food('음식', '🍎'),
  exercise('운동', '🏃‍♂️'),
  rest('휴식', '😴'),
  lifestyle('생활습관', '🌱'),
  medical('의료', '🏥');

  const HealthRecommendationType(this.displayName, this.emoji);
  final String displayName;
  final String emoji;
}

/// 시간대별 건강 컨디션
class HealthTimeline {
  final HealthTimeSlot morning; // 오전 (06-12시)
  final HealthTimeSlot afternoon; // 오후 (12-18시)
  final HealthTimeSlot evening; // 저녁 (18-24시)
  final String? bestTimeActivity; // 최적의 활동 시간

  const HealthTimeline({
    required this.morning,
    required this.afternoon,
    required this.evening,
    this.bestTimeActivity,
  });
}

/// 시간대별 컨디션
class HealthTimeSlot {
  final String timeLabel; // "오전", "오후", "저녁"
  final int conditionScore; // 0-100 컨디션 점수
  final String description; // 해당 시간대 설명
  final List<String>? recommendations; // 해당 시간 추천사항

  const HealthTimeSlot({
    required this.timeLabel,
    required this.conditionScore,
    required this.description,
    this.recommendations,
  });
}

/// 건강운세 입력 파라미터
class HealthFortuneInput {
  final String userId;
  final ConditionState? currentCondition; // 현재 컨디션
  final List<BodyPart>? concernedBodyParts; // 신경쓰이는 부위들
  final String? specificSymptoms; // 구체적인 증상
  final bool? hasChronicCondition; // 만성질환 여부
  final Map<String, dynamic>? additionalInfo;

  const HealthFortuneInput({
    required this.userId,
    this.currentCondition,
    this.concernedBodyParts,
    this.specificSymptoms,
    this.hasChronicCondition,
    this.additionalInfo,
  });
}
