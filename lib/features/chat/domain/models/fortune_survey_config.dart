import 'package:flutter/material.dart';

/// 설문 입력 타입
enum SurveyInputType {
  chips,       // 단일 선택 칩
  multiSelect, // 다중 선택 칩
  slider,      // 슬라이더
  text,        // 텍스트 입력
  grid,        // 그리드 선택
  image,       // 이미지 업로드 (관상)
  profile,     // 프로필 선택 (궁합)
  petProfile,  // 펫 프로필 선택 (반려동물)
  voice,       // 음성/텍스트 입력 (꿈분석, 소원)
  date,        // 날짜 선택 (바이오리듬, 스포츠) - 기존 다이얼로그
  calendar,    // 인라인 캘린더 (기간별 운세) - 채팅 내 캘린더 표시
  birthDateTime, // 생년월일+시간 롤링 피커 (사주용)
  tarot,       // 타로 카드 선택 플로우
  faceReading, // AI 관상 분석 플로우
  investmentCategory, // 투자 카테고리 선택 (코인, 주식, ETF 등)
  investmentTicker,   // 투자 종목 선택 (티커 검색)
  celebritySelection, // 유명인 선택 (검색 + 그리드)
  matchSelection,     // 경기 선택 (스포츠 경기 목록)
  location,           // 지역 선택 (GPS + 검색 + 드롭다운 + 지도)
}

/// 설문 선택지
class SurveyOption {
  final String id;
  final String label;
  final IconData? icon;
  final String? emoji;

  const SurveyOption({
    required this.id,
    required this.label,
    this.icon,
    this.emoji,
  });
}

/// 설문 단계
class SurveyStep {
  final String id;
  final String question;
  final SurveyInputType inputType;
  final List<SurveyOption> options;
  final bool isRequired;
  final String? dependsOn; // 이전 답변에 따라 동적 표시
  final double? minValue;  // slider용
  final double? maxValue;  // slider용
  final String? unit;      // slider용 단위
  final Map<String, dynamic>? showWhen; // 조건부 표시: {'stepId': 'expectedValue'}

  const SurveyStep({
    required this.id,
    required this.question,
    required this.inputType,
    this.options = const [],
    this.isRequired = true,
    this.dependsOn,
    this.minValue,
    this.maxValue,
    this.unit,
    this.showWhen,
  });

  /// 조건부 표시 확인
  bool shouldShow(Map<String, dynamic> answers) {
    if (showWhen == null || showWhen!.isEmpty) return true;

    for (final entry in showWhen!.entries) {
      final answerValue = answers[entry.key];
      if (answerValue == null) return false;

      // 배열로 여러 값 허용: {'stepId': ['value1', 'value2']}
      if (entry.value is List) {
        if (!(entry.value as List).contains(answerValue)) return false;
      } else {
        if (answerValue != entry.value) return false;
      }
    }
    return true;
  }

  /// 동적 옵션을 가져오는 함수 (dependsOn 값에 따라)
  List<SurveyOption> getOptionsForAnswer(String? previousAnswer) {
    // 기본 옵션 반환 (하위 클래스나 config에서 오버라이드)
    return options;
  }
}

/// 운세 타입 (30개 + 유틸리티)
enum FortuneSurveyType {
  // 유틸리티 (채팅 내 프로필 생성)
  profileCreation, // 궁합용 프로필 생성 플로우

  // 기존 6개
  career,   // 커리어/직업운
  love,     // 연애운
  talent,   // 적성/재능
  daily,    // 오늘의 운세 (달력)
  tarot,    // 타로
  mbti,     // MBTI

  // 시간 기반 (2개)
  newYear,       // 새해 운세
  dailyCalendar, // 기간별 운세 (캘린더)

  // 전통 분석 (3개)
  traditional,  // 전통 사주 분석
  faceReading,  // AI 관상 분석
  talisman,     // 부적

  // 성격/개성 (2개)
  personalityDna, // 성격 DNA
  biorhythm,      // 바이오리듬

  // 연애/관계 (4개 추가)
  compatibility,  // 궁합
  avoidPeople,    // 경계 대상
  exLover,        // 재회 운세
  blindDate,      // 소개팅 운세

  // 재물 (1개)
  money,          // 재물운 (프리미엄)

  // 라이프스타일 (4개)
  luckyItems,     // 행운 아이템
  lotto,          // 로또 번호
  wish,           // 소원
  fortuneCookie,  // 오늘의 메시지

  // 건강/스포츠 (3개)
  health,         // 건강 운세
  exercise,       // 운동 추천
  sportsGame,     // 스포츠 경기

  // 인터랙티브 (3개)
  dream,          // 꿈 해몽
  celebrity,      // 유명인 궁합
  pastLife,       // 전생탐험

  // 가족/반려동물 (3개)
  pet,            // 반려동물 궁합
  family,         // 가족 운세
  naming,         // 작명

  // 스타일/패션 (1개)
  ootdEvaluation, // OOTD 평가

  // 실용/결정 (2개)
  exam,           // 시험운
  moving,         // 이사/이직운

  // 웰니스 (1개)
  gratitude,      // 감사일기
}

/// 설문 설정
class FortuneSurveyConfig {
  final FortuneSurveyType fortuneType;
  final String title;
  final String description;
  final IconData? icon;
  final String? emoji;
  final Color? accentColor;
  final List<SurveyStep> steps;

  const FortuneSurveyConfig({
    required this.fortuneType,
    required this.title,
    required this.description,
    this.icon,
    this.emoji,
    this.accentColor,
    required this.steps,
  });

  int get totalSteps => steps.length;
}

/// 설문 진행 상태
class SurveyProgress {
  final FortuneSurveyConfig config;
  final int currentStepIndex;
  final Map<String, dynamic> answers;

  const SurveyProgress({
    required this.config,
    this.currentStepIndex = 0,
    this.answers = const {},
  });

  SurveyStep get currentStep => config.steps[currentStepIndex];

  bool get isComplete => currentStepIndex >= config.steps.length;

  bool get isLastStep => currentStepIndex == config.steps.length - 1;

  double get progress => config.steps.isEmpty
      ? 0.0
      : (currentStepIndex + 1) / config.steps.length;

  SurveyProgress copyWith({
    FortuneSurveyConfig? config,
    int? currentStepIndex,
    Map<String, dynamic>? answers,
  }) {
    return SurveyProgress(
      config: config ?? this.config,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      answers: answers ?? this.answers,
    );
  }

  /// 답변 추가하고 다음 단계로 이동
  SurveyProgress answerAndNext(String stepId, dynamic answer) {
    final newAnswers = Map<String, dynamic>.from(answers);
    newAnswers[stepId] = answer;

    return SurveyProgress(
      config: config,
      currentStepIndex: currentStepIndex + 1,
      answers: newAnswers,
    );
  }
}
