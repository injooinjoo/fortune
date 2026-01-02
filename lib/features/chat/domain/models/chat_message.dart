import '../../../../domain/entities/fortune.dart';
import '../../../fortune/domain/models/match_insight.dart';
import '../../../fortune/domain/models/past_life_result.dart';

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

  /// 로딩 표시
  loading,

  /// 시스템 메시지 (추천 칩 등)
  system,

  /// 온보딩 입력 요청 (이름, 생년월일, 시간 등)
  onboardingInput,
}

/// 온보딩 입력 타입
enum OnboardingInputType {
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

  /// 블러 처리 여부
  final bool isBlurred;

  /// 블러 처리된 섹션 키 목록
  final List<String> blurredSections;

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

  const ChatMessage({
    required this.id,
    required this.type,
    this.text,
    required this.timestamp,
    this.isBlurred = false,
    this.blurredSections = const [],
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
  });

  ChatMessage copyWith({
    String? id,
    ChatMessageType? type,
    String? text,
    DateTime? timestamp,
    bool? isBlurred,
    List<String>? blurredSections,
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
  }) {
    return ChatMessage(
      id: id ?? this.id,
      type: type ?? this.type,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isBlurred: isBlurred ?? this.isBlurred,
      blurredSections: blurredSections ?? this.blurredSections,
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
    );
  }
}
