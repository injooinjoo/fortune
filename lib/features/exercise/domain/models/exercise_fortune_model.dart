// 운동 운세 도메인 모델
//
// 12가지 운동 종목별 전문 가이드를 위한 모델 정의

// ============================================================================
// 운동 목표
// ============================================================================

/// 운동 목표 타입
enum ExerciseGoal {
  flexibility('유연성', '스트레칭, 요가로 몸을 부드럽게'),
  strength('근력', '근육을 키우고 힘을 강화'),
  endurance('체력/지구력', '심폐 기능과 지구력 향상'),
  diet('다이어트', '체중 감량과 체형 관리'),
  stressRelief('스트레스 해소', '심리적 안정과 이완');

  const ExerciseGoal(this.nameKo, this.description);
  final String nameKo;
  final String description;

  String toApiValue() {
    switch (this) {
      case ExerciseGoal.flexibility:
        return 'flexibility';
      case ExerciseGoal.strength:
        return 'strength';
      case ExerciseGoal.endurance:
        return 'endurance';
      case ExerciseGoal.diet:
        return 'diet';
      case ExerciseGoal.stressRelief:
        return 'stress_relief';
    }
  }

  static ExerciseGoal fromApiValue(String value) {
    switch (value) {
      case 'flexibility':
        return ExerciseGoal.flexibility;
      case 'strength':
        return ExerciseGoal.strength;
      case 'endurance':
        return ExerciseGoal.endurance;
      case 'diet':
        return ExerciseGoal.diet;
      case 'stress_relief':
        return ExerciseGoal.stressRelief;
      default:
        return ExerciseGoal.strength;
    }
  }
}

// ============================================================================
// 운동 종목
// ============================================================================

/// 운동 종목 카테고리
enum SportCategory {
  gym,
  yoga,
  cardio,
  sports,
}

/// 운동 종목 타입
enum SportType {
  gym('헬스/웨이트', '💪', SportCategory.gym, '근력 운동, 분할 루틴'),
  yoga('요가', '🧘', SportCategory.yoga, '유연성, 마음 챙김'),
  running('러닝', '🏃', SportCategory.cardio, '유산소, 페이스 관리'),
  swimming('수영', '🏊', SportCategory.cardio, '전신 운동, 관절 부담 적음'),
  cycling('자전거', '🚴', SportCategory.cardio, '하체 강화, 유산소'),
  climbing('클라이밍', '🧗', SportCategory.sports, '전신 근력, 문제 해결'),
  martialArts('격투기', '🥊', SportCategory.sports, 'MMA, 복싱, 유도'),
  tennis('테니스', '🎾', SportCategory.sports, '민첩성, 전신 운동'),
  golf('골프', '⛳', SportCategory.sports, '집중력, 유연성'),
  pilates('필라테스', '🤸', SportCategory.yoga, '코어, 자세 교정'),
  crossfit('크로스핏', '🏋️', SportCategory.gym, '고강도, 기능성 운동'),
  dance('댄스', '💃', SportCategory.cardio, '리듬감, 전신 유산소');

  const SportType(this.nameKo, this.emoji, this.category, this.description);
  final String nameKo;
  final String emoji;
  final SportCategory category;
  final String description;

  String toApiValue() {
    switch (this) {
      case SportType.martialArts:
        return 'martial_arts';
      default:
        return name;
    }
  }

  static SportType fromApiValue(String value) {
    switch (value) {
      case 'martial_arts':
        return SportType.martialArts;
      default:
        return SportType.values.firstWhere(
          (e) => e.name == value,
          orElse: () => SportType.gym,
        );
    }
  }
}

// ============================================================================
// 운동 경력
// ============================================================================

/// 운동 경력 레벨
enum ExperienceLevel {
  beginner('입문자', '0-6개월'),
  intermediate('중급자', '6개월-2년'),
  advanced('상급자', '2-5년'),
  expert('전문가', '5년 이상');

  const ExperienceLevel(this.nameKo, this.period);
  final String nameKo;
  final String period;
}

// ============================================================================
// 부상 부위
// ============================================================================

/// 부상 부위
enum InjuryArea {
  none('부상 없음', ''),
  knee('무릎', '🦵'),
  shoulder('어깨', '💪'),
  back('허리/등', '🔙'),
  wrist('손목', '✋'),
  ankle('발목', '🦶'),
  neck('목', '🦒'),
  hip('고관절', '🦴');

  const InjuryArea(this.nameKo, this.emoji);
  final String nameKo;
  final String emoji;
}

// ============================================================================
// 선호 시간대
// ============================================================================

/// 선호 시간대
enum PreferredTime {
  morning('아침 (06-09시)', '🌅'),
  afternoon('낮 (12-15시)', '☀️'),
  evening('저녁 (17-20시)', '🌆'),
  night('밤 (21시 이후)', '🌙');

  const PreferredTime(this.nameKo, this.emoji);
  final String nameKo;
  final String emoji;
}

// ============================================================================
// 운동 강도
// ============================================================================

/// 운동 강도
enum ExerciseIntensity {
  low('가벼움'),
  medium('중간'),
  high('높음');

  const ExerciseIntensity(this.nameKo);
  final String nameKo;

  static ExerciseIntensity fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
      case '가벼움':
        return ExerciseIntensity.low;
      case 'medium':
      case '중간':
        return ExerciseIntensity.medium;
      case 'high':
      case '높음':
        return ExerciseIntensity.high;
      default:
        return ExerciseIntensity.medium;
    }
  }
}

// ============================================================================
// 추천 운동
// ============================================================================

/// 추천 운동
class RecommendedExercise {
  final String name;
  final String category;
  final String description;
  final String duration;
  final ExerciseIntensity intensity;
  final List<String> benefits;
  final List<String> precautions;

  RecommendedExercise({
    required this.name,
    required this.category,
    required this.description,
    required this.duration,
    required this.intensity,
    required this.benefits,
    required this.precautions,
  });

  factory RecommendedExercise.fromJson(Map<String, dynamic> json) {
    return RecommendedExercise(
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      intensity: ExerciseIntensity.fromString(json['intensity'] as String? ?? 'medium'),
      benefits: (json['benefits'] as List<dynamic>?)?.cast<String>() ?? [],
      precautions: (json['precautions'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}

/// 대체 운동
class AlternativeExercise {
  final String name;
  final String category;
  final String reason;

  AlternativeExercise({
    required this.name,
    required this.category,
    required this.reason,
  });

  factory AlternativeExercise.fromJson(Map<String, dynamic> json) {
    return AlternativeExercise(
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
    );
  }
}

// ============================================================================
// 헬스 루틴
// ============================================================================

/// 헬스 운동 항목
class GymExerciseItem {
  final int order;
  final String name;
  final String targetMuscle;
  final int sets;
  final String reps;
  final int restSeconds;
  final String tips;

  GymExerciseItem({
    required this.order,
    required this.name,
    required this.targetMuscle,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    required this.tips,
  });

  factory GymExerciseItem.fromJson(Map<String, dynamic> json) {
    return GymExerciseItem(
      order: json['order'] as int? ?? 1,
      name: json['name'] as String? ?? '',
      targetMuscle: json['targetMuscle'] as String? ?? '',
      sets: json['sets'] as int? ?? 3,
      reps: json['reps'] as String? ?? '10-12',
      restSeconds: json['restSeconds'] as int? ?? 60,
      tips: json['tips'] as String? ?? '',
    );
  }
}

/// 헬스 루틴
class GymRoutine {
  final String splitType; // 3split, 4split, 5split, fullbody
  final String todayFocus;
  final List<GymExerciseItem> exercises;
  final String warmupDuration;
  final List<String> warmupActivities;
  final String cooldownDuration;
  final List<String> cooldownActivities;

  GymRoutine({
    required this.splitType,
    required this.todayFocus,
    required this.exercises,
    required this.warmupDuration,
    required this.warmupActivities,
    required this.cooldownDuration,
    required this.cooldownActivities,
  });

  factory GymRoutine.fromJson(Map<String, dynamic> json) {
    final warmup = json['warmup'] as Map<String, dynamic>? ?? {};
    final cooldown = json['cooldown'] as Map<String, dynamic>? ?? {};

    return GymRoutine(
      splitType: json['splitType'] as String? ?? '3split',
      todayFocus: json['todayFocus'] as String? ?? '',
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => GymExerciseItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      warmupDuration: warmup['duration'] as String? ?? '10분',
      warmupActivities: (warmup['activities'] as List<dynamic>?)?.cast<String>() ?? [],
      cooldownDuration: cooldown['duration'] as String? ?? '5분',
      cooldownActivities: (cooldown['activities'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  String get splitTypeKo {
    switch (splitType) {
      case '3split':
        return '3분할';
      case '4split':
        return '4분할';
      case '5split':
        return '5분할';
      case 'fullbody':
        return '전신 운동';
      default:
        return splitType;
    }
  }
}

// ============================================================================
// 요가 루틴
// ============================================================================

/// 요가 포즈
class YogaPose {
  final int order;
  final String name;
  final String? sanskritName;
  final String duration;
  final String benefits;
  final String? modification;

  YogaPose({
    required this.order,
    required this.name,
    this.sanskritName,
    required this.duration,
    required this.benefits,
    this.modification,
  });

  factory YogaPose.fromJson(Map<String, dynamic> json) {
    return YogaPose(
      order: json['order'] as int? ?? 1,
      name: json['name'] as String? ?? '',
      sanskritName: json['sanskritName'] as String?,
      duration: json['duration'] as String? ?? '30초',
      benefits: json['benefits'] as String? ?? '',
      modification: json['modification'] as String?,
    );
  }
}

/// 요가 루틴
class YogaRoutine {
  final String sequenceName;
  final String duration;
  final List<YogaPose> poses;
  final String breathingFocus;

  YogaRoutine({
    required this.sequenceName,
    required this.duration,
    required this.poses,
    required this.breathingFocus,
  });

  factory YogaRoutine.fromJson(Map<String, dynamic> json) {
    return YogaRoutine(
      sequenceName: json['sequenceName'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      poses: (json['poses'] as List<dynamic>?)
              ?.map((e) => YogaPose.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      breathingFocus: json['breathingFocus'] as String? ?? '',
    );
  }
}

// ============================================================================
// 유산소 루틴
// ============================================================================

/// 유산소 인터벌
class CardioInterval {
  final String phase;
  final String duration;
  final String intensity;
  final int? heartRateZone;

  CardioInterval({
    required this.phase,
    required this.duration,
    required this.intensity,
    this.heartRateZone,
  });

  factory CardioInterval.fromJson(Map<String, dynamic> json) {
    return CardioInterval(
      phase: json['phase'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      intensity: json['intensity'] as String? ?? '',
      heartRateZone: json['heartRateZone'] as int?,
    );
  }
}

/// 유산소 루틴
class CardioRoutine {
  final String type; // running, cycling, swimming
  final String totalDistance;
  final String totalDuration;
  final String? targetPace;
  final List<CardioInterval> intervals;
  final List<String> technique;

  CardioRoutine({
    required this.type,
    required this.totalDistance,
    required this.totalDuration,
    this.targetPace,
    required this.intervals,
    required this.technique,
  });

  factory CardioRoutine.fromJson(Map<String, dynamic> json) {
    return CardioRoutine(
      type: json['type'] as String? ?? '',
      totalDistance: json['totalDistance'] as String? ?? '',
      totalDuration: json['totalDuration'] as String? ?? '',
      targetPace: json['targetPace'] as String?,
      intervals: (json['intervals'] as List<dynamic>?)
              ?.map((e) => CardioInterval.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      technique: (json['technique'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}

// ============================================================================
// 스포츠 루틴
// ============================================================================

/// 스포츠 드릴
class SportsDrill {
  final int order;
  final String name;
  final String duration;
  final String purpose;
  final String tips;

  SportsDrill({
    required this.order,
    required this.name,
    required this.duration,
    required this.purpose,
    required this.tips,
  });

  factory SportsDrill.fromJson(Map<String, dynamic> json) {
    return SportsDrill(
      order: json['order'] as int? ?? 1,
      name: json['name'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      purpose: json['purpose'] as String? ?? '',
      tips: json['tips'] as String? ?? '',
    );
  }
}

/// 스포츠 루틴
class SportsRoutine {
  final String sportName;
  final String focusArea;
  final List<SportsDrill> drills;

  SportsRoutine({
    required this.sportName,
    required this.focusArea,
    required this.drills,
  });

  factory SportsRoutine.fromJson(Map<String, dynamic> json) {
    return SportsRoutine(
      sportName: json['sportName'] as String? ?? '',
      focusArea: json['focusArea'] as String? ?? '',
      drills: (json['drills'] as List<dynamic>?)
              ?.map((e) => SportsDrill.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// ============================================================================
// 오늘의 루틴
// ============================================================================

/// 오늘의 루틴 (종목별 분기)
class TodayRoutine {
  final GymRoutine? gymRoutine;
  final YogaRoutine? yogaRoutine;
  final CardioRoutine? cardioRoutine;
  final SportsRoutine? sportsRoutine;

  TodayRoutine({
    this.gymRoutine,
    this.yogaRoutine,
    this.cardioRoutine,
    this.sportsRoutine,
  });

  factory TodayRoutine.fromJson(Map<String, dynamic> json) {
    return TodayRoutine(
      gymRoutine: json['gymRoutine'] != null
          ? GymRoutine.fromJson(json['gymRoutine'] as Map<String, dynamic>)
          : null,
      yogaRoutine: json['yogaRoutine'] != null
          ? YogaRoutine.fromJson(json['yogaRoutine'] as Map<String, dynamic>)
          : null,
      cardioRoutine: json['cardioRoutine'] != null
          ? CardioRoutine.fromJson(json['cardioRoutine'] as Map<String, dynamic>)
          : null,
      sportsRoutine: json['sportsRoutine'] != null
          ? SportsRoutine.fromJson(json['sportsRoutine'] as Map<String, dynamic>)
          : null,
    );
  }

  SportCategory? get activeCategory {
    if (gymRoutine != null) return SportCategory.gym;
    if (yogaRoutine != null) return SportCategory.yoga;
    if (cardioRoutine != null) return SportCategory.cardio;
    if (sportsRoutine != null) return SportCategory.sports;
    return null;
  }
}

// ============================================================================
// 주간 계획
// ============================================================================

/// 주간 계획
class WeeklyPlan {
  final String summary;
  final Map<String, String> schedule; // mon, tue, wed, thu, fri, sat, sun

  WeeklyPlan({
    required this.summary,
    required this.schedule,
  });

  factory WeeklyPlan.fromJson(Map<String, dynamic> json) {
    final scheduleData = json['schedule'] as Map<String, dynamic>? ?? {};
    return WeeklyPlan(
      summary: json['summary'] as String? ?? '',
      schedule: scheduleData.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  String getDay(String day) => schedule[day] ?? '휴식';
}

// ============================================================================
// 부상 예방
// ============================================================================

/// 부상 예방 정보
class InjuryPrevention {
  final List<String> warnings;
  final List<String> stretches;
  final List<String> recoveryTips;

  InjuryPrevention({
    required this.warnings,
    required this.stretches,
    required this.recoveryTips,
  });

  factory InjuryPrevention.fromJson(Map<String, dynamic> json) {
    return InjuryPrevention(
      warnings: (json['warnings'] as List<dynamic>?)?.cast<String>() ?? [],
      stretches: (json['stretches'] as List<dynamic>?)?.cast<String>() ?? [],
      recoveryTips: (json['recoveryTips'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}

// ============================================================================
// 영양 팁
// ============================================================================

/// 영양 팁
class NutritionTip {
  final String preworkout;
  final String postworkout;

  NutritionTip({
    required this.preworkout,
    required this.postworkout,
  });

  factory NutritionTip.fromJson(Map<String, dynamic> json) {
    return NutritionTip(
      preworkout: json['preworkout'] as String? ?? '',
      postworkout: json['postworkout'] as String? ?? '',
    );
  }
}

// ============================================================================
// 최적 시간
// ============================================================================

/// 최적 시간
class OptimalTime {
  final String time;
  final String reason;

  OptimalTime({
    required this.time,
    required this.reason,
  });

  factory OptimalTime.fromJson(Map<String, dynamic> json) {
    return OptimalTime(
      time: json['time'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
    );
  }
}

// ============================================================================
// 운동 운세 결과
// ============================================================================

/// 운동 운세 결과
class ExerciseFortuneResult {
  final int score;
  final String content;
  final String summary;

  // 입력 데이터
  final ExerciseGoal exerciseGoal;
  final SportType sportType;
  final int weeklyFrequency;
  final ExperienceLevel experienceLevel;
  final int fitnessLevel;
  final List<InjuryArea> injuryHistory;
  final PreferredTime preferredTime;

  // 결과 데이터
  final RecommendedExercise? primaryExercise;
  final List<AlternativeExercise> alternatives;
  final TodayRoutine? todayRoutine;
  final OptimalTime? optimalTime;
  final WeeklyPlan? weeklyPlan;
  final InjuryPrevention? injuryPrevention;
  final NutritionTip? nutritionTip;
  final String? exerciseKeyword;

  // 메타데이터
  final int? percentile;
  final DateTime timestamp;

  ExerciseFortuneResult({
    required this.score,
    required this.content,
    required this.summary,
    required this.exerciseGoal,
    required this.sportType,
    required this.weeklyFrequency,
    required this.experienceLevel,
    required this.fitnessLevel,
    required this.injuryHistory,
    required this.preferredTime,
    this.primaryExercise,
    this.alternatives = const [],
    this.todayRoutine,
    this.optimalTime,
    this.weeklyPlan,
    this.injuryPrevention,
    this.nutritionTip,
    this.exerciseKeyword,
    this.percentile,
    required this.timestamp,
  });

  factory ExerciseFortuneResult.fromJson(Map<String, dynamic> json) {
    // 추천 운동 파싱
    final recommendedExerciseData = json['recommendedExercise'] as Map<String, dynamic>?;
    final primaryData = recommendedExerciseData?['primary'] as Map<String, dynamic>?;
    final alternativesData = recommendedExerciseData?['alternatives'] as List<dynamic>? ?? [];

    // 부상 이력 파싱
    final injuryHistoryData = json['injuryHistory'] as List<dynamic>? ?? [];
    final injuryHistory = injuryHistoryData.map((e) {
      final value = e.toString();
      return InjuryArea.values.firstWhere(
        (area) => area.name == value,
        orElse: () => InjuryArea.none,
      );
    }).toList();

    return ExerciseFortuneResult(
      score: json['score'] as int? ?? 70,
      content: json['content'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      exerciseGoal: ExerciseGoal.fromApiValue(json['exerciseGoal'] as String? ?? 'strength'),
      sportType: SportType.fromApiValue(json['sportType'] as String? ?? 'gym'),
      weeklyFrequency: json['weeklyFrequency'] as int? ?? 3,
      experienceLevel: ExperienceLevel.values.firstWhere(
        (e) => e.name == (json['experienceLevel'] as String? ?? 'intermediate'),
        orElse: () => ExperienceLevel.intermediate,
      ),
      fitnessLevel: json['fitnessLevel'] as int? ?? 3,
      injuryHistory: injuryHistory,
      preferredTime: PreferredTime.values.firstWhere(
        (e) => e.name == (json['preferredTime'] as String? ?? 'evening'),
        orElse: () => PreferredTime.evening,
      ),
      primaryExercise:
          primaryData != null ? RecommendedExercise.fromJson(primaryData) : null,
      alternatives: alternativesData
          .map((e) => AlternativeExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      todayRoutine: json['todayRoutine'] != null
          ? TodayRoutine.fromJson(json['todayRoutine'] as Map<String, dynamic>)
          : null,
      optimalTime: json['optimalTime'] != null
          ? OptimalTime.fromJson(json['optimalTime'] as Map<String, dynamic>)
          : null,
      weeklyPlan: json['weeklyPlan'] != null
          ? WeeklyPlan.fromJson(json['weeklyPlan'] as Map<String, dynamic>)
          : null,
      injuryPrevention: json['injuryPrevention'] != null
          ? InjuryPrevention.fromJson(json['injuryPrevention'] as Map<String, dynamic>)
          : null,
      nutritionTip: json['nutritionTip'] != null
          ? NutritionTip.fromJson(json['nutritionTip'] as Map<String, dynamic>)
          : null,
      exerciseKeyword: json['exerciseKeyword'] as String?,
      percentile: json['percentile'] as int?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

}
