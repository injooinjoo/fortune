import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import '../utils/haptic_utils.dart';
import '../../services/speech_recognition_service.dart';
import '../../features/fortune/presentation/widgets/voice_spectrum_animation.dart';
import 'chat_bubble.dart';

/// 버블 스타일 음성 입력 위젯
///
/// 특징:
/// - 음성 입력 후 ChatBubble에 텍스트 표시
/// - 내장 전송 버튼 없음 (외부 버튼 사용)
/// - 정지 버튼으로 녹음 종료
///
/// 기존 WishVoiceInput 통합
class UnifiedVoiceBubbleInput extends StatefulWidget {
  /// 텍스트 컨트롤러
  final TextEditingController controller;

  /// 텍스트 변경 콜백
  final VoidCallback? onTextChanged;

  /// 녹음 상태 변경 콜백 (Provider 연동용)
  final Function(bool isRecording)? onRecordingChanged;

  /// 힌트 텍스트
  final String hintText;

  /// 녹음 중 텍스트
  final String transcribingText;

  /// 활성화 여부
  final bool enabled;

  /// 글자수 표시 여부 (기본 true)
  final bool showCharacterCount;

  /// 수정/삭제 버튼 표시 여부 (기본 true)
  final bool showEditDeleteButtons;

  /// 웨이브폼 바 개수 (기본 50)
  final int waveformBarCount;

  const UnifiedVoiceBubbleInput({
    super.key,
    required this.controller,
    this.onTextChanged,
    this.onRecordingChanged,
    this.hintText = '소원을 말하거나 적어주세요',
    this.transcribingText = '듣고 있어요...',
    this.enabled = true,
    this.showCharacterCount = true,
    this.showEditDeleteButtons = true,
    this.waveformBarCount = 50,
  });

  @override
  State<UnifiedVoiceBubbleInput> createState() => _UnifiedVoiceBubbleInputState();
}

class _UnifiedVoiceBubbleInputState extends State<UnifiedVoiceBubbleInput>
    with SingleTickerProviderStateMixin {
  final SpeechRecognitionService _speechService = SpeechRecognitionService();

  bool _isRecording = false;
  bool _isSpeaking = false;

  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(_onTextChanged);

    _speechService.isListeningNotifier.addListener(_onListeningStateChanged);

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  void _onTextChanged() {
    widget.onTextChanged?.call();
    if (mounted) setState(() {});
  }

  void _onListeningStateChanged() {
    if (!_speechService.isListeningNotifier.value && mounted) {
      if (_isRecording) {
        setState(() => _isRecording = false);
        widget.onRecordingChanged?.call(false);
      }
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _speechService.isListeningNotifier.removeListener(_onListeningStateChanged);
    _loadingController.dispose();
    _speechService.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (!widget.enabled) return;

    HapticUtils.lightImpact();

    final permissionStatus = await _speechService.checkPermissionStatus();

    if (permissionStatus != MicrophonePermissionStatus.granted) {
      if (!mounted) return;
      await _showPermissionDialog(permissionStatus);
      return;
    }

    setState(() {
      _isRecording = true;
      _isSpeaking = false;
    });

    widget.onRecordingChanged?.call(true);

    await _startListeningWithAutoRestart();
  }

  Future<void> _startListeningWithAutoRestart() async {
    await _speechService.startListening(
      onResult: (text) {
        if (text.isNotEmpty && mounted) {
          setState(() {
            _isRecording = false;
            _isSpeaking = false;
            widget.controller.text = text;
            widget.controller.selection = TextSelection.fromPosition(
              TextPosition(offset: text.length),
            );
          });
          widget.onRecordingChanged?.call(false);
        }
      },
      onPartialResult: (text) {
        if (text.isNotEmpty && mounted) {
          setState(() {
            _isSpeaking = true;
          });
          widget.controller.text = text;
          widget.controller.selection = TextSelection.fromPosition(
            TextPosition(offset: text.length),
          );
        }
      },
      onNoMatch: () {
        if (mounted && _isRecording) {
          debugPrint('🎤 [UnifiedVoiceBubble] Auto-restarting after no_match');
          _startListeningWithAutoRestart();
        }
      },
    );
  }

  Future<void> _stopRecording() async {
    HapticUtils.lightImpact();

    await _speechService.stopListening();

    if (!mounted) return;

    setState(() {
      _isRecording = false;
      _isSpeaking = false;
    });

    widget.onRecordingChanged?.call(false);
  }

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
    final colors = context.colors;
    final hasText = widget.controller.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 녹음 중이면 웨이브폼 + 정지 버튼
        if (_isRecording)
          _buildRecordingUI(isDark, colors)
        // 텍스트가 있으면 ChatBubble로 표시
        else if (hasText)
          _buildBubbleUI(isDark, colors)
        // 기본 상태면 입력 필드
        else
          _buildInputUI(isDark, colors),
      ],
    );
  }

  /// 녹음 중 UI
  Widget _buildRecordingUI(bool isDark, DSColorScheme colors) {
    return Row(
      children: [
        // 정지 버튼
        GestureDetector(
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
        ),
        const SizedBox(width: DSSpacing.sm),

        // 웨이브폼
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(24),
            ),
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
        ),
      ],
    );
  }

  /// 텍스트가 있을 때 ChatBubble UI
  Widget _buildBubbleUI(bool isDark, DSColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ChatBubble (화살표 없음)
        ChatBubble(
          showTail: false,
          backgroundColor: colors.backgroundSecondary,
          borderColor: colors.border,
          borderWidth: 1,
          padding: const EdgeInsets.all(DSSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.controller.text,
                style: DSTypography.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  height: 1.5,
                ),
              ),
              if (widget.showEditDeleteButtons) ...[
                const SizedBox(height: DSSpacing.sm),
                // 수정/삭제 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 수정 버튼 (다시 입력)
                    GestureDetector(
                      onTap: () {
                        setState(() {});
                        _showEditSheet();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DSSpacing.sm,
                          vertical: DSSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: colors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(DSRadius.sm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit,
                              size: 14,
                              color: colors.accent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '수정',
                              style: DSTypography.labelSmall.copyWith(
                                color: colors.accent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: DSSpacing.sm),
                    // 삭제 버튼
                    GestureDetector(
                      onTap: () {
                        widget.controller.clear();
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DSSpacing.sm,
                          vertical: DSSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: colors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(DSRadius.sm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 14,
                              color: colors.error,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '삭제',
                              style: DSTypography.labelSmall.copyWith(
                                color: colors.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (widget.showCharacterCount) ...[
          const SizedBox(height: DSSpacing.sm),
          // 글자수 표시
          Padding(
            padding: const EdgeInsets.only(left: DSSpacing.sm),
            child: Text(
              '${widget.controller.text.length}자',
              style: DSTypography.labelSmall.copyWith(
                color: colors.textTertiary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// 기본 입력 UI
  Widget _buildInputUI(bool isDark, DSColorScheme colors) {
    return Row(
      children: [
        // 입력 필드
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: DSSpacing.lg,
                      right: DSSpacing.sm,
                    ),
                    child: TextField(
                      controller: widget.controller,
                      enabled: widget.enabled,
                      style: DSTypography.bodyMedium.copyWith(
                        color: colors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: DSTypography.bodyMedium.copyWith(
                          color: colors.textTertiary,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                        isDense: true,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
                // 마이크 버튼
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
      ],
    );
  }

  /// 수정 바텀시트
  void _showEditSheet() {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final editController =
        TextEditingController(text: widget.controller.text);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(DSRadius.xl),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DSSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 핸들
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: DSSpacing.lg),
              Text(
                '내용 수정',
                style: DSTypography.headingSmall.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: DSSpacing.md),
              // 입력 필드
              TextField(
                controller: editController,
                autofocus: true,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: '내용을 입력하세요',
                  filled: true,
                  fillColor: colors.backgroundSecondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DSRadius.md),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: DSSpacing.lg),
              // 버튼들
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DSRadius.md),
                        ),
                      ),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: DSSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.controller.text = editController.text;
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.accent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DSRadius.md),
                        ),
                      ),
                      child: const Text('확인'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DSSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
