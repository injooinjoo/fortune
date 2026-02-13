import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/fortune_survey_config.dart';
import '../../domain/configs/survey_configs.dart';

/// 설문조사 상태
class ChatSurveyState {
  final SurveyProgress? activeProgress;
  final bool isCompleted;
  final Map<String, dynamic>? completedData;
  final FortuneSurveyType? completedType;

  const ChatSurveyState({
    this.activeProgress,
    this.isCompleted = false,
    this.completedData,
    this.completedType,
  });

  bool get isActive => activeProgress != null && !isCompleted;

  ChatSurveyState copyWith({
    SurveyProgress? activeProgress,
    bool? isCompleted,
    Map<String, dynamic>? completedData,
    FortuneSurveyType? completedType,
    bool clearProgress = false,
  }) {
    return ChatSurveyState(
      activeProgress:
          clearProgress ? null : (activeProgress ?? this.activeProgress),
      isCompleted: isCompleted ?? this.isCompleted,
      completedData: completedData ?? this.completedData,
      completedType: completedType ?? this.completedType,
    );
  }
}

/// 설문조사 관리 Notifier
class ChatSurveyNotifier extends StateNotifier<ChatSurveyState> {
  ChatSurveyNotifier() : super(const ChatSurveyState());

  /// 설문 시작
  /// [initialAnswers]: 프로필에서 자동으로 가져온 값 (예: 성별)
  void startSurvey(FortuneSurveyType type,
      {Map<String, dynamic>? initialAnswers}) {
    final config = surveyConfigs[type];
    if (config == null) return;

    var progress = SurveyProgress(
      config: config,
      answers: initialAnswers ?? {},
    );

    // initialAnswers가 있으면 해당 스텝들 건너뛰기
    progress = _skipConditionalSteps(progress);

    state = ChatSurveyState(
      activeProgress: progress,
    );
  }

  /// 현재 단계 답변 및 다음 단계로 이동
  void answerCurrentStep(dynamic answer) {
    if (state.activeProgress == null) return;

    final progress = state.activeProgress!;
    final currentStep = progress.currentStep;

    // 답변 저장하고 다음 단계로
    var newProgress = progress.answerAndNext(currentStep.id, answer);

    // 조건부 단계 스킵: showWhen 조건이 맞지 않으면 건너뛰기
    newProgress = _skipConditionalSteps(newProgress);

    // 완료 확인
    if (newProgress.isComplete) {
      state = state.copyWith(
        activeProgress: newProgress,
        isCompleted: true,
        completedData: newProgress.answers,
        completedType: progress.config.fortuneType,
      );
    } else {
      state = state.copyWith(activeProgress: newProgress);
    }
  }

  /// 조건부 단계 스킵 (showWhen 조건 미충족 시)
  SurveyProgress _skipConditionalSteps(SurveyProgress progress) {
    var current = progress;

    // 완료 상태가 아니고 현재 단계의 조건이 맞지 않으면 스킵
    while (!current.isComplete) {
      final step = current.currentStep;
      if (step.shouldShow(current.answers)) {
        break; // 조건이 맞으면 이 단계에서 멈춤
      }
      // 조건 불충족 → 스킵
      current = SurveyProgress(
        config: current.config,
        currentStepIndex: current.currentStepIndex + 1,
        answers: current.answers,
      );
    }

    return current;
  }

  /// 현재 단계 스킵 (선택적 단계만)
  void skipCurrentStep() {
    if (state.activeProgress == null) return;

    final progress = state.activeProgress!;
    final currentStep = progress.currentStep;

    // 필수 단계는 스킵 불가
    if (currentStep.isRequired) return;

    // 다음 단계로 이동 (답변 없이)
    final newProgress = SurveyProgress(
      config: progress.config,
      currentStepIndex: progress.currentStepIndex + 1,
      answers: progress.answers,
    );

    if (newProgress.isComplete) {
      state = state.copyWith(
        activeProgress: newProgress,
        isCompleted: true,
        completedData: newProgress.answers,
        completedType: progress.config.fortuneType,
      );
    } else {
      state = state.copyWith(activeProgress: newProgress);
    }
  }

  /// 설문 취소
  void cancelSurvey() {
    state = const ChatSurveyState();
  }

  /// 완료 상태 초기화 (운세 결과 표시 후)
  void clearCompleted() {
    state = const ChatSurveyState();
  }

  /// 현재 단계의 동적 옵션 가져오기 (dependsOn 처리)
  List<SurveyOption> getCurrentStepOptions() {
    if (state.activeProgress == null) return [];

    final progress = state.activeProgress!;
    final currentStep = progress.currentStep;

    // 동적 옵션인 경우 (dependsOn이 있는 경우)
    if (currentStep.dependsOn != null) {
      final previousAnswer = progress.answers[currentStep.dependsOn];

      // position 필드 (야구 포지션 등)
      if (previousAnswer != null && currentStep.id == 'position') {
        return getPositionsForField(previousAnswer.toString());
      }

      // favoriteTeam 필드 (경기 선택 후 팀 선택)
      if (currentStep.id == 'favoriteTeam' && previousAnswer != null) {
        return _getTeamOptionsFromMatch(previousAnswer);
      }
    }

    return currentStep.options;
  }

  /// 선택한 경기에서 팀 옵션 추출
  List<SurveyOption> _getTeamOptionsFromMatch(dynamic matchAnswer) {
    // matchAnswer가 Map인 경우 (SportsGame 객체가 저장된 경우)
    if (matchAnswer is Map<String, dynamic>) {
      final homeTeam = matchAnswer['homeTeam'] as String?;
      final awayTeam = matchAnswer['awayTeam'] as String?;

      if (homeTeam != null && awayTeam != null) {
        return [
          SurveyOption(id: 'home', label: homeTeam, emoji: '🏠'),
          SurveyOption(id: 'away', label: awayTeam, emoji: '✈️'),
          const SurveyOption(id: 'none', label: '그냥 볼게요', emoji: '👀'),
        ];
      }
    }

    // matchAnswer가 String인 경우 (matchTitle 형식: "TeamA vs TeamB")
    if (matchAnswer is String && matchAnswer.contains(' vs ')) {
      final teams = matchAnswer.split(' vs ');
      if (teams.length == 2) {
        return [
          SurveyOption(id: 'home', label: teams[0].trim(), emoji: '🏠'),
          SurveyOption(id: 'away', label: teams[1].trim(), emoji: '✈️'),
          const SurveyOption(id: 'none', label: '그냥 볼게요', emoji: '👀'),
        ];
      }
    }

    // 기본값 (파싱 실패 시)
    return const [
      SurveyOption(id: 'none', label: '그냥 볼게요', emoji: '👀'),
    ];
  }
}

/// Provider
final chatSurveyProvider =
    StateNotifierProvider<ChatSurveyNotifier, ChatSurveyState>((ref) {
  return ChatSurveyNotifier();
});
