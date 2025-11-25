import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../services/speech_recognition_service.dart';
import '../providers/dream_voice_provider.dart';
import 'voice_spectrum_animation.dart';

/// 하단 음성 입력 영역 (ChatGPT 스타일)
///
/// 레이아웃: [긴 타원형 (TextField + 마이크)] [검정 동그라미 버튼]
class DreamVoiceInputWidget extends ConsumerStatefulWidget {
  final Function(String) onTextRecognized;

  const DreamVoiceInputWidget({
    super.key,
    required this.onTextRecognized,
  });

  @override
  ConsumerState<DreamVoiceInputWidget> createState() => _DreamVoiceInputWidgetState();
}

class _DreamVoiceInputWidgetState extends ConsumerState<DreamVoiceInputWidget> {
  final _textController = TextEditingController();
  final _speechService = SpeechRecognitionService();
  bool _isRecording = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeechService();

    // 텍스트 변화 감지
    _textController.addListener(() {
      final newHasText = _textController.text.isNotEmpty;
      if (_hasText != newHasText) {
        setState(() {
          _hasText = newHasText;
        });
      }
    });
  }

  Future<void> _initializeSpeechService() async {
    await _speechService.initialize();
  }

  @override
  void dispose() {
    _textController.dispose();
    _speechService.dispose();
    super.dispose();
  }

  /// 마이크 버튼 클릭 - 녹음 시작
  Future<void> _startRecording() async {
    HapticUtils.lightImpact();

    setState(() {
      _isRecording = true;
      _textController.clear();
    });

    // Provider 상태 업데이트
    ref.read(dreamVoiceProvider.notifier).startRecording();

    await _speechService.startListening(
      onResult: (text) {
        // Final result - 녹음 완료
        if (text.isNotEmpty) {
          _textController.text = text;
          // 커서를 끝으로 이동
          _textController.selection = TextSelection.fromPosition(
            TextPosition(offset: text.length),
          );
        }
      },
      onPartialResult: (text) {
        // Partial result - 실시간 업데이트
        if (text.isNotEmpty) {
          // 텍스트 필드 업데이트 (화면에 즉시 반영)
          _textController.text = text;
          _textController.selection = TextSelection.fromPosition(
            TextPosition(offset: text.length),
          );
          
          ref.read(dreamVoiceProvider.notifier).updateRecognizedText(text);
        }
      },
    );
  }

  /// 정지 버튼 클릭 - 녹음 중지 및 전송
  Future<void> _stopRecordingAndSend() async {
    HapticUtils.lightImpact();

    // 녹음 중지
    await _speechService.stopListening();

    // Provider 상태 업데이트
    ref.read(dreamVoiceProvider.notifier).stopRecording();

    // STT 변환 대기 (좀 더 긴 딜레이)
    await Future.delayed(const Duration(milliseconds: 500));

    // 텍스트가 있으면 전송
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      widget.onTextRecognized(text);

      // 입력란 초기화
      setState(() {
        _textController.clear();
        _hasText = false;
        _isRecording = false;
      });
    } else {
      // 텍스트가 없으면 그냥 녹음 중지만
      setState(() {
        _isRecording = false;
      });
    }
  }

  /// 전송 버튼 클릭 - 텍스트 전송
  void _sendText() {
    HapticUtils.lightImpact();

    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      widget.onTextRecognized(text);

      // 입력란 초기화
      setState(() {
        _textController.clear();
        _hasText = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // 버튼 표시 여부
    final hasButton = _hasText || _isRecording;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      bottom: keyboardHeight > 0 ? keyboardHeight : 16,
      left: TossTheme.spacingM,
      right: TossTheme.spacingM,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
            // 왼쪽: 타원형 입력란
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                children: [
                  // TextField (항상 표시)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 8),
                      child: TextField(
                        controller: _textController,
                        style: TypographyUnified.bodyMedium.copyWith(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: _isRecording ? '듣고 있어요...' : '무슨 꿈이었나요?',
                          hintStyle: TypographyUnified.bodyMedium.copyWith(
                            color: _isRecording 
                                ? (isDark ? const Color(0xFF6B4EFF) : const Color(0xFF5835E8)) // 녹음 중 힌트 색상 강조
                                : (isDark ? Colors.grey[500] : Colors.grey[600]),
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
                        // 녹음 중일 때는 읽기 전용으로 설정할 수도 있지만, 
                        // 사용자가 수정하고 싶을 수 있으므로 활성화 유지
                      ),
                    ),
                  ),

                  // 녹음 중일 때 스펙트럼 애니메이션 표시
                  if (_isRecording)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ValueListenableBuilder<double>(
                        valueListenable: _speechService.soundLevelNotifier,
                        builder: (context, soundLevel, child) {
                          return VoiceSpectrumAnimation(
                            isRecording: _isRecording,
                            barCount: 5,
                            soundLevel: soundLevel,
                          );
                        },
                      ),
                    ),

                  // 마이크 버튼 (텍스트 없고 녹음 안할 때만)
                  if (!_hasText && !_isRecording)
                    IconButton(
                      icon: Icon(
                        Icons.mic_none,
                        color: isDark ? Colors.white : Colors.black,
                        size: 24,
                      ),
                      onPressed: _startRecording,
                    ),
                  ],
                ),
              ),
            ),

            // 오른쪽: 전송/정지 버튼 (텍스트 있거나 녹음 중일 때만)
            if (hasButton) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _isRecording ? _stopRecordingAndSend : _sendText,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _isRecording 
                        ? (isDark ? Colors.red[400] : Colors.red) // 녹음 중지 버튼은 빨간색 계열
                        : (isDark ? Colors.white : Colors.black),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.arrow_upward,
                    color: _isRecording 
                        ? Colors.white 
                        : (isDark ? Colors.black : Colors.white),
                    size: 22,
                  ),
                ),
              ),
            ],
          ],
        ),
    );
  }
}
