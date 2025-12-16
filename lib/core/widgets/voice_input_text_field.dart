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

/// ChatGPT 스타일의 음성 입력 텍스트 필드
///
/// 레이아웃: [왼쪽 버튼] [가운데 pill] [오른쪽 버튼]
class VoiceInputTextField extends StatefulWidget {
  /// 텍스트 전송 시 호출되는 콜백
  final Function(String text) onSubmit;

  /// 기본 상태의 힌트 텍스트
  final String hintText;

  /// 변환 중 표시 텍스트
  final String transcribingText;

  /// 외부에서 주입하는 TextEditingController (선택)
  final TextEditingController? controller;

  /// 활성화 여부
  final bool enabled;

  const VoiceInputTextField({
    super.key,
    required this.onSubmit,
    this.hintText = 'Ask anything',
    this.transcribingText = 'Transcribing',
    this.controller,
    this.enabled = true,
  });

  @override
  State<VoiceInputTextField> createState() => _VoiceInputTextFieldState();
}

class _VoiceInputTextFieldState extends State<VoiceInputTextField>
    with SingleTickerProviderStateMixin {
  late TextEditingController _textController;
  final SpeechRecognitionService _speechService = SpeechRecognitionService();

  VoiceInputState _state = VoiceInputState.idle;

  // 로딩 애니메이션용
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _textController = widget.controller ?? TextEditingController();

    // 텍스트 변화 감지
    _textController.addListener(_onTextChanged);

    // 로딩 애니메이션 컨트롤러
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _textController.dispose();
    }
    _textController.removeListener(_onTextChanged);
    _loadingController.dispose();
    _speechService.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _textController.text.isNotEmpty;

    // idle 또는 hasText 상태에서만 전환
    if (_state == VoiceInputState.idle && hasText) {
      setState(() => _state = VoiceInputState.hasText);
    } else if (_state == VoiceInputState.hasText && !hasText) {
      setState(() => _state = VoiceInputState.idle);
    }
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
      _textController.clear();
    });

    await _speechService.startListening(
      onResult: (text) {
        // Final result - 변환 완료
        if (text.isNotEmpty && mounted) {
          setState(() {
            _state = VoiceInputState.hasText;
            _textController.text = text;
            _textController.selection = TextSelection.fromPosition(
              TextPosition(offset: text.length),
            );
          });
        }
      },
      onPartialResult: (text) {
        // Partial result - 실시간 업데이트 (transcribing 상태로 전환)
        if (text.isNotEmpty && mounted) {
          // 아직 recording이면 transcribing으로 전환
          if (_state == VoiceInputState.recording) {
            setState(() => _state = VoiceInputState.transcribing);
          }
          _textController.text = text;
          _textController.selection = TextSelection.fromPosition(
            TextPosition(offset: text.length),
          );
        }
      },
    );
  }

  /// 정지 버튼 탭 - 녹음/변환 중지
  Future<void> _stopRecording() async {
    HapticUtils.lightImpact();

    await _speechService.stopListening();

    if (!mounted) return;

    final text = _textController.text.trim();
    setState(() {
      _state = text.isEmpty ? VoiceInputState.idle : VoiceInputState.hasText;
    });
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
  }

  /// 권한 요청 다이얼로그
  Future<void> _showPermissionDialog(MicrophonePermissionStatus status) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.mic, color: isDark ? Colors.white : Colors.black),
            const SizedBox(width: 8),
            Text(
              '마이크 권한 필요',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          '음성 입력을 사용하려면 마이크 권한이 필요합니다.',
          style: TextStyle(
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
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
              backgroundColor: isDark ? Colors.white : Colors.black,
              foregroundColor: isDark ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              status == MicrophonePermissionStatus.permanentlyDenied
                  ? '설정으로 이동'
                  : '권한 허용하기',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRecordingOrTranscribing =
        _state == VoiceInputState.recording || _state == VoiceInputState.transcribing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 왼쪽: 정지 버튼 (recording/transcribing 상태에서만)
        if (isRecordingOrTranscribing) ...[
          _buildStopButton(isDark),
          const SizedBox(width: 8),
        ],

        // 가운데: pill 모양 입력 영역
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                // 상태에 따른 콘텐츠
                Expanded(child: _buildContent(isDark)),

                // 마이크 버튼 (idle 상태에서만)
                if (_state == VoiceInputState.idle)
                  IconButton(
                    icon: Icon(
                      Icons.mic_none,
                      color: isDark ? Colors.white : Colors.black,
                      size: 24,
                    ),
                    onPressed: widget.enabled ? _startRecording : null,
                  ),
              ],
            ),
          ),
        ),

        // 오른쪽: 전송 버튼 (hasText 또는 recording/transcribing 상태에서)
        if (_state == VoiceInputState.hasText || isRecordingOrTranscribing) ...[
          const SizedBox(width: 8),
          _buildSendButton(isDark),
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
        return _buildRecordingContent(isDark);

      case VoiceInputState.transcribing:
        return _buildTranscribingContent(isDark);
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
        enabled: widget.enabled,
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

  /// 녹음 중 콘텐츠 (웨이브폼)
  Widget _buildRecordingContent(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ValueListenableBuilder<double>(
        valueListenable: _speechService.soundLevelNotifier,
        builder: (context, soundLevel, child) {
          return VoiceSpectrumAnimation(
            isRecording: true,
            barCount: 50,
            soundLevel: soundLevel,
          );
        },
      ),
    );
  }

  /// 변환 중 콘텐츠 (로딩 스피너 + 텍스트)
  Widget _buildTranscribingContent(bool isDark) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.lg),
      child: Row(
        children: [
          // 로딩 스피너 (점 깜빡임)
          AnimatedBuilder(
            animation: _loadingController,
            builder: (context, child) {
              final opacity = 0.3 + (_loadingController.value * 0.7);
              return Icon(
                Icons.auto_awesome,
                size: 16,
                color: colors.textTertiary.withValues(alpha: opacity),
              );
            },
          ),
          const SizedBox(width: DSSpacing.sm),
          Text(
            widget.transcribingText,
            style: typography.bodyMedium.copyWith(
              color: colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  /// 정지 버튼 (왼쪽, 회색 스타일)
  Widget _buildStopButton(bool isDark) {
    return GestureDetector(
      onTap: _stopRecording,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[700] : Colors.grey[300],
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.stop,
          color: isDark ? Colors.grey[300] : Colors.grey[700],
          size: 20,
        ),
      ),
    );
  }

  /// 전송 버튼 (오른쪽)
  Widget _buildSendButton(bool isDark) {
    final isActive = _state == VoiceInputState.hasText;

    return GestureDetector(
      onTap: isActive ? _submit : null,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? Colors.white : Colors.black)
              : (isDark ? Colors.grey[700] : Colors.grey[400]),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.arrow_upward,
          color: isActive
              ? (isDark ? Colors.black : Colors.white)
              : (isDark ? Colors.grey[500] : Colors.grey[600]),
          size: 22,
        ),
      ),
    );
  }
}
