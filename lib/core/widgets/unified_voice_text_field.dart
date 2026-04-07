import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import '../utils/haptic_utils.dart';
import '../../services/speech_recognition_service.dart';
import '../../features/fortune/presentation/widgets/voice_spectrum_animation.dart';

/// 음성 입력이 가능한 텍스트 필드의 상태
enum VoiceInputState {
  /// 기본 상태: TextField + 마이크 아이콘
  idle,

  /// 녹음 중: 웨이브폼 + 정지 버튼
  recording,

  /// 변환 중: "Transcribing" + 로딩 스피너 + 정지 버튼
  transcribing,

  /// 텍스트 있음: TextField + 전송 버튼
  hasText,
}

/// ChatGPT 스타일의 통합 음성 입력 텍스트 필드
///
/// 레이아웃: [왼쪽 버튼] [가운데 pill] [오른쪽 버튼]
///
/// 기존 VoiceInputTextField, DreamVoiceInputWidget 통합
class UnifiedVoiceTextField extends StatefulWidget {
  /// 텍스트 전송 시 호출되는 콜백
  final Function(String text) onSubmit;

  /// 텍스트 변경 시 호출되는 콜백 (실시간 업데이트용)
  final Function(String text)? onTextChanged;

  /// 녹음 상태 변경 콜백 (Provider 연동용)
  final Function(bool isRecording)? onRecordingChanged;

  /// 기본 상태의 힌트 텍스트
  final String hintText;

  /// 변환 중 표시 텍스트
  final String transcribingText;

  /// 외부에서 주입하는 TextEditingController (선택)
  final TextEditingController? controller;

  /// 활성화 여부
  final bool enabled;

  /// 전송 버튼 표시 여부 (기본 true)
  final bool showSendButton;

  /// 테스트 또는 외부 제어를 위한 음성 인식 서비스 주입점
  final SpeechRecognitionService? speechService;

  /// 웨이브폼 바 개수 (기본 50)
  final int waveformBarCount;

  /// 정지 버튼 색상 (null이면 기본 grey)
  final Color? stopButtonColor;

  const UnifiedVoiceTextField({
    super.key,
    required this.onSubmit,
    this.onTextChanged,
    this.onRecordingChanged,
    this.hintText = 'Ask anything',
    this.transcribingText = '정리 중',
    this.controller,
    this.enabled = true,
    this.showSendButton = true,
    this.speechService,
    this.waveformBarCount = 50,
    this.stopButtonColor,
  });

  @override
  State<UnifiedVoiceTextField> createState() => _UnifiedVoiceTextFieldState();
}

class _UnifiedVoiceTextFieldState extends State<UnifiedVoiceTextField>
    with SingleTickerProviderStateMixin {
  late TextEditingController _textController;
  late final SpeechRecognitionService _speechService;
  late final bool _ownsSpeechService;
  final FocusNode _focusNode = FocusNode(); // 키보드 유지용

  VoiceInputState _state = VoiceInputState.idle;
  bool _isSpeaking = false; // 실제 음성 인식 중인지 (partial result 수신)
  bool _submitPendingAfterStop = false;

  // 로딩 애니메이션용
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _textController = widget.controller ?? TextEditingController();
    _ownsSpeechService = widget.speechService == null;
    _speechService = widget.speechService ?? SpeechRecognitionService();

    // 텍스트 변화 감지
    _textController.addListener(_onTextChanged);

    // 서비스 상태 변화 감지 (UI 동기화)
    _speechService.isListeningNotifier.addListener(_onListeningStateChanged);

    // 로딩 애니메이션 컨트롤러
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  /// 서비스 상태가 변경되면 UI 동기화
  void _onListeningStateChanged() {
    if (!_speechService.isListeningNotifier.value && mounted) {
      // 서비스가 중지되었는데 UI가 아직 recording 상태면 복구
      if (_state == VoiceInputState.recording ||
          _state == VoiceInputState.transcribing) {
        final text = _textController.text.trim();
        // 텍스트가 있으면 hasText, 없으면 idle로 복구
        setState(() {
          _state =
              text.isNotEmpty ? VoiceInputState.hasText : VoiceInputState.idle;
          _isSpeaking = false;
        });

        if (text.isEmpty) {
          _submitPendingAfterStop = false;
        }
      }
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _textController.dispose();
    }
    _textController.removeListener(_onTextChanged);
    _speechService.isListeningNotifier.removeListener(_onListeningStateChanged);
    _loadingController.dispose();
    if (_ownsSpeechService) {
      _speechService.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _textController.text;
    final hasText = text.isNotEmpty;

    // idle 또는 hasText 상태에서만 전환
    if (_state == VoiceInputState.idle && hasText) {
      setState(() => _state = VoiceInputState.hasText);
    } else if (_state == VoiceInputState.hasText && !hasText) {
      setState(() => _state = VoiceInputState.idle);
    }

    // 실시간 텍스트 변경 콜백 호출
    widget.onTextChanged?.call(text);
  }

  /// 마이크 버튼 탭 - 녹음 시작
  Future<void> _startRecording() async {
    if (!widget.enabled) return;

    HapticUtils.lightImpact();

    // 1. 권한 확인
    final permissionStatus = await _speechService.checkPermissionStatus();

    if (permissionStatus != MicrophonePermissionStatus.granted) {
      if (!mounted) return;
      await _showPermissionDialog(permissionStatus);
      return;
    }

    // 2. 녹음 시작
    setState(() {
      _state = VoiceInputState.recording;
      _isSpeaking = false;
      _submitPendingAfterStop = false;
      _textController.clear();
    });

    // 녹음 상태 콜백
    widget.onRecordingChanged?.call(true);

    await _startListeningWithAutoRestart();
  }

  /// 자동 재시작 지원하는 음성 인식 시작
  Future<void> _startListeningWithAutoRestart() async {
    await _speechService.startListening(
      onResult: (text) {
        // Final result - 변환 완료
        if (text.isNotEmpty && mounted) {
          final shouldSubmit = _submitPendingAfterStop;
          setState(() {
            _state = VoiceInputState.hasText;
            _isSpeaking = false;
            _textController.text = text;
            _textController.selection = TextSelection.fromPosition(
              TextPosition(offset: text.length),
            );
          });
          // 녹음 상태 콜백
          widget.onRecordingChanged?.call(false);

          if (shouldSubmit) {
            _submitPendingAfterStop = false;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _submit();
              }
            });
          }
        }
      },
      onPartialResult: (text) {
        // Partial result - 실시간 업데이트 (transcribing 상태로 전환)
        if (text.isNotEmpty && mounted) {
          setState(() {
            _isSpeaking = true; // 말하는 중!
            if (_state == VoiceInputState.recording) {
              _state = VoiceInputState.transcribing;
            }
          });
          _textController.text = text;
          _textController.selection = TextSelection.fromPosition(
            TextPosition(offset: text.length),
          );
        }
      },
      onNoMatch: () {
        // error_no_match 발생 시 자동 재시작
        if (mounted &&
            (_state == VoiceInputState.recording ||
                _state == VoiceInputState.transcribing)) {
          debugPrint('🎤 [UnifiedVoice] Auto-restarting after no_match');
          _startListeningWithAutoRestart();
        } else {
          // stop 버튼 눌렀거나 mounted 아니면 idle로 복구
          if (mounted) {
            setState(() => _state = VoiceInputState.idle);
            widget.onRecordingChanged?.call(false);
          }
        }
      },
    );
  }

  /// 정지 버튼 탭 - 녹음/변환 중지
  Future<void> _stopRecording({bool submitAfterStop = false}) async {
    HapticUtils.lightImpact();
    _submitPendingAfterStop = submitAfterStop;

    await _speechService.stopListening();

    if (!mounted) return;

    final text = _textController.text.trim();
    setState(() {
      _state = text.isEmpty ? VoiceInputState.idle : VoiceInputState.hasText;
      _isSpeaking = false;
    });

    // 녹음 상태 콜백
    widget.onRecordingChanged?.call(false);

    if (submitAfterStop && text.isNotEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (!mounted || !_submitPendingAfterStop) {
        return;
      }

      _submitPendingAfterStop = false;
      _submit();
      return;
    }

    _submitPendingAfterStop = false;
  }

  /// 전송 버튼 탭
  void _submit() {
    HapticUtils.lightImpact();

    final text = _textController.text.trim();
    if (text.isEmpty) return;

    widget.onSubmit(text);

    // 초기화
    _textController.clear();
    setState(() => _state = VoiceInputState.idle);

    // 연속 입력을 위해 포커스 유지 (키보드 유지)
    _focusNode.requestFocus();
  }

  /// 권한 요청 다이얼로그
  Future<void> _showPermissionDialog(MicrophonePermissionStatus status) async {
    final colors = context.colors;
    final typography = context.typography;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.mic, color: colors.textPrimary),
            const SizedBox(width: 8),
            Text(
              '마이크 권한 필요',
              style: typography.headingSmall.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          '음성 입력을 사용하려면 마이크 권한이 필요합니다.',
          style: typography.bodyMedium.copyWith(color: colors.textSecondary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);

              if (status == MicrophonePermissionStatus.permanentlyDenied) {
                await _speechService.openSettings();
              } else {
                final result = await _speechService.requestPermission();
                if (result == MicrophonePermissionStatus.granted) {
                  _startRecording();
                } else if (result ==
                    MicrophonePermissionStatus.permanentlyDenied) {
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: const Text('설정에서 마이크 권한을 허용해주세요'),
                        action: SnackBarAction(
                          label: '설정 열기',
                          onPressed: () => _speechService.openSettings(),
                        ),
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.ctaBackground,
              foregroundColor: colors.ctaForeground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              status == MicrophonePermissionStatus.permanentlyDenied
                  ? '설정으로 이동'
                  : '계속',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final isRecordingOrTranscribing = _state == VoiceInputState.recording ||
        _state == VoiceInputState.transcribing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 가운데: pill 모양 입력 영역 (떠다니는 느낌)
        Expanded(
          child: AnimatedContainer(
            duration: DSAnimation.fast,
            height: 48,
            decoration: BoxDecoration(
              color: context.colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isRecordingOrTranscribing
                    ? context.colors.ctaBackground.withValues(alpha: 0.18)
                    : context.colors.border.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              children: [
                // 상태에 따른 콘텐츠
                Expanded(child: _buildContent(isDark)),
              ],
            ),
          ),
        ),

        // 오른쪽: 액션 버튼 (mic / stop / send)
        if (widget.showSendButton) ...[
          const SizedBox(width: 8),
          _buildActionButton(isDark),
        ],
      ],
    );
  }

  /// 상태에 따른 메인 콘텐츠
  Widget _buildContent(bool isDark) {
    switch (_state) {
      case VoiceInputState.idle:
      case VoiceInputState.hasText:
        return _buildTextField(isDark);

      case VoiceInputState.recording:
      case VoiceInputState.transcribing:
        return _buildListeningContent(isDark);
    }
  }

  /// TextField (idle, hasText 상태)
  Widget _buildTextField(bool isDark) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.only(left: DSSpacing.lg, right: DSSpacing.sm),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        enabled: widget.enabled,
        textAlignVertical: TextAlignVertical.center,
        style: typography.bodyMedium.copyWith(
          color: colors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: typography.bodyMedium.copyWith(
            color: colors.textTertiary,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          isDense: true,
        ),
        maxLines: 1,
        textInputAction: TextInputAction.send,
        onSubmitted: (_) => _submit(),
      ),
    );
  }

  /// 녹음/음성 인식 중 콘텐츠 (웨이브폼)
  Widget _buildListeningContent(bool isDark) {
    final colors = context.colors;
    final typography = context.typography;
    final statusText =
        _state == VoiceInputState.recording ? '듣는 중' : widget.transcribingText;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _loadingController,
            builder: (context, child) {
              final opacity = 0.55 + (_loadingController.value * 0.45);
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.sm,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.ctaBackground.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors.ctaBackground.withValues(alpha: opacity),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: typography.labelMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: DSSpacing.md),
          Expanded(
            child: ValueListenableBuilder<double>(
              valueListenable: _speechService.soundLevelNotifier,
              builder: (context, soundLevel, child) {
                return VoiceSpectrumAnimation(
                  isRecording: true,
                  barCount: widget.waveformBarCount,
                  soundLevel: soundLevel,
                  isSpeaking: _isSpeaking,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 액션 버튼 (마이크 / 정지 / 전송)
  Widget _buildActionButton(bool isDark) {
    final hasText = _textController.text.trim().isNotEmpty;
    final isRecordingOrTranscribing = _state == VoiceInputState.recording ||
        _state == VoiceInputState.transcribing;

    final IconData icon;
    final VoidCallback? onTap;
    final bool isActive;

    if (isRecordingOrTranscribing && !hasText) {
      icon = Icons.stop_rounded;
      onTap = widget.enabled ? () => _stopRecording() : null;
      isActive = true;
    } else if (isRecordingOrTranscribing) {
      icon = Icons.arrow_upward;
      onTap = widget.enabled
          ? () {
              _stopRecording(submitAfterStop: true);
            }
          : null;
      isActive = true;
    } else if (_state == VoiceInputState.hasText) {
      icon = Icons.arrow_upward;
      onTap = widget.enabled ? _submit : null;
      isActive = true;
    } else {
      icon = Icons.mic_none;
      onTap = widget.enabled ? _startRecording : null;
      isActive = false;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive
              ? context.colors.ctaBackground
              : context.colors.surfaceSecondary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive
              ? context.colors.ctaForeground
              : context.colors.textTertiary,
          size: 22,
        ),
      ),
    );
  }
}
