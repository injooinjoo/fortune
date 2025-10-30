import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 음성 페이지 상태
enum VoicePageState {
  initial,    // 초기 화면 (Tip 표시)
  recording,  // 녹음 중
  processing, // API 호출 중
  result,     // 결과 표시
}

/// 음성 페이지 상태 데이터
class DreamVoiceState {
  final VoicePageState state;
  final String recognizedText;
  final bool isRecording;

  const DreamVoiceState({
    required this.state,
    required this.recognizedText,
    required this.isRecording,
  });

  factory DreamVoiceState.initial() {
    return const DreamVoiceState(
      state: VoicePageState.initial,
      recognizedText: '',
      isRecording: false,
    );
  }

  DreamVoiceState copyWith({
    VoicePageState? state,
    String? recognizedText,
    bool? isRecording,
  }) {
    return DreamVoiceState(
      state: state ?? this.state,
      recognizedText: recognizedText ?? this.recognizedText,
      isRecording: isRecording ?? this.isRecording,
    );
  }
}

/// 음성 페이지 상태 관리 Provider
class DreamVoiceNotifier extends StateNotifier<DreamVoiceState> {
  DreamVoiceNotifier() : super(DreamVoiceState.initial());

  /// 상태 변경
  void setState(VoicePageState newState) {
    state = state.copyWith(state: newState);
  }

  /// 녹음 시작
  void startRecording() {
    state = state.copyWith(
      state: VoicePageState.recording,
      isRecording: true,
    );
  }

  /// 녹음 정지
  void stopRecording() {
    state = state.copyWith(
      isRecording: false,
    );
  }

  /// 인식된 텍스트 업데이트
  void updateRecognizedText(String text) {
    state = state.copyWith(
      recognizedText: text,
    );
  }

  /// 초기 상태로 리셋
  void reset() {
    state = DreamVoiceState.initial();
  }
}

final dreamVoiceProvider = StateNotifierProvider<DreamVoiceNotifier, DreamVoiceState>((ref) {
  return DreamVoiceNotifier();
});
