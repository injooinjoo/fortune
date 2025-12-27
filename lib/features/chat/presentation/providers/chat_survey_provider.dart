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
      activeProgress: clearProgress ? null : (activeProgress ?? this.activeProgress),
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
  void startSurvey(FortuneSurveyType type) {
    final config = surveyConfigs[type];
    if (config == null) return;

    state = ChatSurveyState(
      activeProgress: SurveyProgress(config: config),
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
      if (previousAnswer != null && currentStep.id == 'position') {
        return getPositionsForField(previousAnswer.toString());
      }
    }

    return currentStep.options;
  }
}

/// Provider
final chatSurveyProvider =
    StateNotifierProvider<ChatSurveyNotifier, ChatSurveyState>((ref) {
  return ChatSurveyNotifier();
});
