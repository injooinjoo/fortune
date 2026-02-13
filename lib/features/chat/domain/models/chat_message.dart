import '../../../../domain/entities/fortune.dart';
import '../../../../core/models/personality_dna_model.dart';
import '../../../fortune/domain/models/match_insight.dart';
import '../../../fortune/domain/models/past_life_result.dart';
import '../../../fortune/domain/models/yearly_encounter_result.dart';
import '../../../chat_insight/data/models/chat_insight_result.dart';

/// 채팅 메시지 유형
enum ChatMessageType {
  /// 사용자 입력
  user,

  /// AI 텍스트 응답
  ai,

  /// 운세 결과 (섹션별)
  fortuneResult,

  /// 사주 분석 결과 (풍부한 위젯 표시)
  sajuResult,

  /// 성격 DNA 결과 (채팅 카드 표시)
  personalityDnaResult,

  /// 부적 결과 (이미지 + 짧은 설명)
  talismanResult,

  /// 감사일기 결과 (일기장 스타일 카드)
  gratitudeResult,

  /// AI 코칭 결과 (코칭 어드바이스 + 액션 아이템)
  coachingResult,

  /// 결정 분석 결과 (선택지별 장단점 + 추천)
  decisionResult,

  /// 하루 회고 결과 (일일 리뷰 인사이트)
  dailyReviewResult,

  /// 주간 리포트 결과 (주간 트렌드 + 인사이트)
  weeklyReviewResult,

  /// 카톡 대화 분석 인사이트 결과 (5종 카드)
  chatInsightResult,

  /// 로딩 표시
  loading,

  /// 시스템 메시지 (추천 칩 등)
  system,

  /// 온보딩 입력 요청 (이름, 생년월일, 시간 등)
  onboardingInput,
}

/// 온보딩 입력 타입
enum OnboardingInputType {
  /// 인생 컨설팅 대분류 선택 (연애, 돈, 커리어, 건강)
  lifeCategory,

  /// 세부 고민 선택
  subConcern,

  /// 이름 입력 (텍스트)
  name,

  /// 생년월일 입력 (DatePicker)
  birthDate,

  /// 태어난 시간 입력 (TimePicker)
  birthTime,

  /// 성별 선택 (Chips)
  gender,

  /// MBTI 선택 (16가지 Chips)
  mbti,

  /// 혈액형 선택 (A/B/O/AB Chips)
  bloodType,

  /// 정보 확인 화면 (맞아요/처음부터 버튼)
  confirmation,

  /// 로그인/회원가입 유도 화면
  loginPrompt,
}

/// 채팅 메시지 모델
class ChatMessage {
  final String id;
  final ChatMessageType type;
  final String? text;
  final DateTime timestamp;

  /// 운세 결과용: 운세 유형
  final String? fortuneType;

  /// 운세 결과용: 섹션 키 (summary, content, advice 등)
  final String? sectionKey;

  /// 시스템 메시지용: 추천 칩 목록
  final List<String>? chipIds;

  /// 운세 결과 데이터 (리치 카드 표시용)
  final Fortune? fortune;

  /// 사주 분석 결과: 사주 데이터 (명식, 오행, 지장간 등)
  final Map<String, dynamic>? sajuData;

  /// 사주 분석 결과: LLM 운세 응답 (질문 탭 답변)
  final Map<String, dynamic>? sajuFortuneResult;

  /// 온보딩용: 입력 타입
  final OnboardingInputType? onboardingInputType;

  /// 경기 인사이트 결과 데이터
  final MatchInsight? matchInsight;

  /// 전생탐험 결과 데이터
  final PastLifeResult? pastLifeResult;

  /// 기간별 인사이트: 선택한 날짜 (결과 제목에 표시)
  final DateTime? selectedDate;

  /// 성격 DNA 결과 데이터
  final PersonalityDNA? personalityDna;

  /// 부적 결과: 이미지 URL
  final String? talismanImageUrl;

  /// 부적 결과: 카테고리 한글명 (예: 재물운)
  final String? talismanCategoryName;

  /// 부적 결과: 100자 내외 효능 + 사용법
  final String? talismanShortDescription;

  /// 감사일기 결과: 첫 번째 감사
  final String? gratitude1;

  /// 감사일기 결과: 두 번째 감사
  final String? gratitude2;

  /// 감사일기 결과: 세 번째 감사
  final String? gratitude3;

  /// 감사일기 결과: 작성 날짜
  final DateTime? gratitudeDate;

  /// 올해의 인연 결과 데이터
  final YearlyEncounterResult? yearlyEncounterResult;

  // ============ AI 코칭/저널링 결과 필드 ============

  /// 코칭 결과: 사용자가 입력한 상황
  final String? coachingSituation;

  /// 코칭 결과: AI 코칭 어드바이스
  final String? coachingAdvice;

  /// 코칭 결과: 실천 항목 목록
  final List<String>? coachingActionItems;

  /// 결정 분석 결과: 고민 중인 질문
  final String? decisionQuestion;

  /// 결정 분석 결과: 선택지별 분석 (JSON 형태: [{option, pros, cons}])
  final List<Map<String, dynamic>>? decisionOptions;

  /// 결정 분석 결과: AI 추천
  final String? decisionRecommendation;

  /// 결정 분석 결과: 확신을 가질 수 있는 포인트 목록
  final List<String>? decisionConfidenceFactors;

  /// 결정 분석 결과: 다음 단계 액션 목록
  final List<String>? decisionNextSteps;

  /// 결정 분석 결과: 결정 유형 (dating, career, money 등)
  final String? decisionType;

  /// 결정 분석 결과: 저장된 결정 기록 ID (팔로업 연동용)
  final String? decisionReceiptId;

  /// 하루 회고 결과: 오늘의 하이라이트
  final String? dailyReviewHighlight;

  /// 하루 회고 결과: 배운 점
  final String? dailyReviewLearning;

  /// 하루 회고 결과: 내일을 위한 한 마디
  final String? dailyReviewTomorrow;

  /// 주간 리포트 결과: 이번 주 요약
  final String? weeklyReviewSummary;

  /// 주간 리포트 결과: 성장 트렌드
  final List<String>? weeklyReviewTrends;

  /// 주간 리포트 결과: 다음 주 액션 제안
  final List<String>? weeklyReviewActions;

  /// 카톡 대화 분석 인사이트 결과 데이터
  final ChatInsightResult? chatInsight;

  const ChatMessage({
    required this.id,
    required this.type,
    this.text,
    required this.timestamp,
    this.fortuneType,
    this.sectionKey,
    this.chipIds,
    this.fortune,
    this.sajuData,
    this.sajuFortuneResult,
    this.onboardingInputType,
    this.matchInsight,
    this.pastLifeResult,
    this.selectedDate,
    this.personalityDna,
    this.talismanImageUrl,
    this.talismanCategoryName,
    this.talismanShortDescription,
    this.gratitude1,
    this.gratitude2,
    this.gratitude3,
    this.gratitudeDate,
    this.yearlyEncounterResult,
    // AI 코칭/저널링 필드
    this.coachingSituation,
    this.coachingAdvice,
    this.coachingActionItems,
    this.decisionQuestion,
    this.decisionOptions,
    this.decisionRecommendation,
    this.decisionConfidenceFactors,
    this.decisionNextSteps,
    this.decisionType,
    this.decisionReceiptId,
    this.dailyReviewHighlight,
    this.dailyReviewLearning,
    this.dailyReviewTomorrow,
    this.weeklyReviewSummary,
    this.weeklyReviewTrends,
    this.weeklyReviewActions,
    this.chatInsight,
  });

  ChatMessage copyWith({
    String? id,
    ChatMessageType? type,
    String? text,
    DateTime? timestamp,
    String? fortuneType,
    String? sectionKey,
    List<String>? chipIds,
    Fortune? fortune,
    Map<String, dynamic>? sajuData,
    Map<String, dynamic>? sajuFortuneResult,
    OnboardingInputType? onboardingInputType,
    MatchInsight? matchInsight,
    PastLifeResult? pastLifeResult,
    DateTime? selectedDate,
    PersonalityDNA? personalityDna,
    String? talismanImageUrl,
    String? talismanCategoryName,
    String? talismanShortDescription,
    String? gratitude1,
    String? gratitude2,
    String? gratitude3,
    DateTime? gratitudeDate,
    YearlyEncounterResult? yearlyEncounterResult,
    // AI 코칭/저널링 필드
    String? coachingSituation,
    String? coachingAdvice,
    List<String>? coachingActionItems,
    String? decisionQuestion,
    List<Map<String, dynamic>>? decisionOptions,
    String? decisionRecommendation,
    List<String>? decisionConfidenceFactors,
    List<String>? decisionNextSteps,
    String? decisionType,
    String? decisionReceiptId,
    String? dailyReviewHighlight,
    String? dailyReviewLearning,
    String? dailyReviewTomorrow,
    String? weeklyReviewSummary,
    List<String>? weeklyReviewTrends,
    List<String>? weeklyReviewActions,
    ChatInsightResult? chatInsight,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      type: type ?? this.type,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      fortuneType: fortuneType ?? this.fortuneType,
      sectionKey: sectionKey ?? this.sectionKey,
      chipIds: chipIds ?? this.chipIds,
      fortune: fortune ?? this.fortune,
      sajuData: sajuData ?? this.sajuData,
      sajuFortuneResult: sajuFortuneResult ?? this.sajuFortuneResult,
      onboardingInputType: onboardingInputType ?? this.onboardingInputType,
      matchInsight: matchInsight ?? this.matchInsight,
      pastLifeResult: pastLifeResult ?? this.pastLifeResult,
      selectedDate: selectedDate ?? this.selectedDate,
      personalityDna: personalityDna ?? this.personalityDna,
      talismanImageUrl: talismanImageUrl ?? this.talismanImageUrl,
      talismanCategoryName: talismanCategoryName ?? this.talismanCategoryName,
      talismanShortDescription: talismanShortDescription ?? this.talismanShortDescription,
      gratitude1: gratitude1 ?? this.gratitude1,
      gratitude2: gratitude2 ?? this.gratitude2,
      gratitude3: gratitude3 ?? this.gratitude3,
      gratitudeDate: gratitudeDate ?? this.gratitudeDate,
      yearlyEncounterResult: yearlyEncounterResult ?? this.yearlyEncounterResult,
      // AI 코칭/저널링 필드
      coachingSituation: coachingSituation ?? this.coachingSituation,
      coachingAdvice: coachingAdvice ?? this.coachingAdvice,
      coachingActionItems: coachingActionItems ?? this.coachingActionItems,
      decisionQuestion: decisionQuestion ?? this.decisionQuestion,
      decisionOptions: decisionOptions ?? this.decisionOptions,
      decisionRecommendation: decisionRecommendation ?? this.decisionRecommendation,
      decisionConfidenceFactors: decisionConfidenceFactors ?? this.decisionConfidenceFactors,
      decisionNextSteps: decisionNextSteps ?? this.decisionNextSteps,
      decisionType: decisionType ?? this.decisionType,
      decisionReceiptId: decisionReceiptId ?? this.decisionReceiptId,
      dailyReviewHighlight: dailyReviewHighlight ?? this.dailyReviewHighlight,
      dailyReviewLearning: dailyReviewLearning ?? this.dailyReviewLearning,
      dailyReviewTomorrow: dailyReviewTomorrow ?? this.dailyReviewTomorrow,
      weeklyReviewSummary: weeklyReviewSummary ?? this.weeklyReviewSummary,
      weeklyReviewTrends: weeklyReviewTrends ?? this.weeklyReviewTrends,
      weeklyReviewActions: weeklyReviewActions ?? this.weeklyReviewActions,
      chatInsight: chatInsight ?? this.chatInsight,
    );
  }

  /// 로컬 저장 가능 여부 (user, ai, system 메시지만 저장)
  /// Fortune, MatchInsight 등 복잡한 객체는 세션 내에서만 유효
  bool get isPersistable =>
      type == ChatMessageType.user ||
      type == ChatMessageType.ai ||
      type == ChatMessageType.system;

  /// JSON 직렬화 (로컬 저장용)
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
        'chipIds': chipIds,
      };

  /// JSON 역직렬화 (로컬 로드용)
  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        type: ChatMessageType.values.byName(json['type'] as String),
        text: json['text'] as String?,
        timestamp: DateTime.parse(json['timestamp'] as String),
        chipIds: (json['chipIds'] as List<dynamic>?)?.cast<String>(),
      );
}
