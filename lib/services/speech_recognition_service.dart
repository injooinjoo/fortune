import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

/// 마이크 권한 상태
enum MicrophonePermissionStatus {
  granted,
  denied,
  permanentlyDenied,
}

class SpeechRecognitionService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  final ValueNotifier<bool> isListeningNotifier = ValueNotifier(false);
  final ValueNotifier<String> recognizedTextNotifier = ValueNotifier('');
  final ValueNotifier<String> statusNotifier = ValueNotifier('');
  final ValueNotifier<double> soundLevelNotifier = ValueNotifier(0.0);

  /// 마이크 권한 상태만 확인 (요청하지 않음)
  Future<MicrophonePermissionStatus> checkPermissionStatus() async {
    final micPermission = await Permission.microphone.status;
    debugPrint('🎤 [STT] checkPermissionStatus: $micPermission');

    if (micPermission.isGranted) {
      // iOS에서는 음성 인식 권한도 확인
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final speechPermission = await Permission.speech.status;
        if (speechPermission.isGranted) {
          return MicrophonePermissionStatus.granted;
        } else if (speechPermission.isPermanentlyDenied) {
          return MicrophonePermissionStatus.permanentlyDenied;
        } else {
          return MicrophonePermissionStatus.denied;
        }
      }
      return MicrophonePermissionStatus.granted;
    } else if (micPermission.isPermanentlyDenied) {
      return MicrophonePermissionStatus.permanentlyDenied;
    } else {
      return MicrophonePermissionStatus.denied;
    }
  }

  /// 마이크 권한 요청
  Future<MicrophonePermissionStatus> requestPermission() async {
    debugPrint('🎤 [STT] requestPermission called');

    // 마이크 권한 요청
    final micResult = await Permission.microphone.request();
    debugPrint('🎤 [STT] Microphone permission request result: $micResult');

    if (!micResult.isGranted) {
      if (micResult.isPermanentlyDenied) {
        return MicrophonePermissionStatus.permanentlyDenied;
      }
      return MicrophonePermissionStatus.denied;
    }

    // iOS에서 음성 인식 권한 요청
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final speechResult = await Permission.speech.request();
      debugPrint('🎤 [STT] Speech permission request result: $speechResult');

      if (!speechResult.isGranted) {
        if (speechResult.isPermanentlyDenied) {
          return MicrophonePermissionStatus.permanentlyDenied;
        }
        return MicrophonePermissionStatus.denied;
      }
    }

    return MicrophonePermissionStatus.granted;
  }

  /// 설정 앱 열기
  Future<void> openSettings() async {
    await openAppSettings();
  }

  Future<bool> initialize() async {
    try {
      debugPrint('🎤 [STT] Initializing speech recognition...');

      // 마이크 권한 확인
      final micPermission = await Permission.microphone.status;
      debugPrint('🎤 [STT] Microphone permission: $micPermission');
      if (!micPermission.isGranted) {
        // 영구 거부된 경우 설정으로 안내
        if (micPermission.isPermanentlyDenied) {
          statusNotifier.value = '설정에서 마이크 권한을 활성화해주세요';
          debugPrint('🎤 [STT] Microphone permanently denied, opening settings...');
          await openAppSettings();
          return false;
        }
        final result = await Permission.microphone.request();
        debugPrint('🎤 [STT] Microphone permission request result: $result');
        if (!result.isGranted) {
          if (result.isPermanentlyDenied) {
            statusNotifier.value = '설정에서 마이크 권한을 활성화해주세요';
            await openAppSettings();
          } else {
            statusNotifier.value = '마이크 권한이 필요합니다';
          }
          return false;
        }
      }

      // iOS에서 음성 인식 권한 확인
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final speechPermission = await Permission.speech.status;
        debugPrint('🎤 [STT] Speech permission: $speechPermission');
        if (!speechPermission.isGranted) {
          // 영구 거부된 경우 설정으로 안내
          if (speechPermission.isPermanentlyDenied) {
            statusNotifier.value = '설정에서 음성 인식 권한을 활성화해주세요';
            debugPrint('🎤 [STT] Speech permanently denied, opening settings...');
            await openAppSettings();
            return false;
          }
          final result = await Permission.speech.request();
          debugPrint('🎤 [STT] Speech permission request result: $result');
          if (!result.isGranted) {
            if (result.isPermanentlyDenied) {
              statusNotifier.value = '설정에서 음성 인식 권한을 활성화해주세요';
              await openAppSettings();
            } else {
              statusNotifier.value = '음성 인식 권한이 필요합니다';
            }
            return false;
          }
        }
      }

      // 음성 인식 초기화
      _isInitialized = await _speech.initialize(
        onStatus: (status) {
          statusNotifier.value = _getStatusMessage(status);
          debugPrint('🎤 [STT] Status: $status');

          // 음성 인식이 종료되면 상태 업데이트
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            isListeningNotifier.value = false;
            debugPrint('🎤 [STT] Listening stopped automatically (status: $status)');
          }
        },
        onError: (error) {
          statusNotifier.value = '오류: ${error.errorMsg}';
          debugPrint('🎤 [STT] Error: ${error.errorMsg}');
          _isListening = false;
          isListeningNotifier.value = false;
        });

      debugPrint('🎤 [STT] Initialize result: $_isInitialized, isAvailable: ${_speech.isAvailable}');

      if (!_isInitialized) {
        statusNotifier.value = '음성 인식을 초기화할 수 없습니다';
      }

      return _isInitialized;
    } catch (e) {
      debugPrint('🎤 [STT] Initialize error: $e');
      statusNotifier.value = '초기화 중 오류가 발생했습니다';
      return false;
    }
  }
  
  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onPartialResult,
    String locale = 'ko-KR'}) async {
    debugPrint('🎤 [STT] startListening called, isInitialized: $_isInitialized, isListening: $_isListening');

    if (!_isInitialized) {
      debugPrint('🎤 [STT] Not initialized, calling initialize()...');
      final initialized = await initialize();
      if (!initialized) {
        debugPrint('🎤 [STT] Initialize failed, returning');
        return;
      }
    }

    if (_isListening) {
      debugPrint('🎤 [STT] Already listening, returning');
      return;
    }

    try {
      recognizedTextNotifier.value = '';
      String lastFinalResult = '';

      debugPrint('🎤 [STT] Calling _speech.listen() with locale: $locale');

      await _speech.listen(
        onResult: (result) {
          debugPrint('🎤 [STT] onResult called: finalResult=${result.finalResult}, recognizedWords="${result.recognizedWords}"');
          // Partial result 처리
          if (!result.finalResult) {
            // 현재까지 인식된 부분적인 텍스트
            final currentText = result.recognizedWords;
            recognizedTextNotifier.value = currentText;
            debugPrint('🎤 [STT] Partial result: "$currentText"');
            onPartialResult?.call(currentText);
          } else {
            // Final result 처리
            final finalText = result.recognizedWords;
            debugPrint('🎤 [STT] Final result: "$finalText" (lastFinalResult: "$lastFinalResult")');
            if (finalText != lastFinalResult && finalText.isNotEmpty) {
              lastFinalResult = finalText;
              debugPrint('🎤 [STT] Calling onResult callback with: "$finalText"');
              onResult(finalText);
              // Final result 후 recognizedText 초기화
              recognizedTextNotifier.value = '';
            }
          }
        },
        onSoundLevelChange: (level) {
          // 사운드 레벨 업데이트 (너무 많은 로그 방지를 위해 임계값 추가)
          soundLevelNotifier.value = level;
          // 레벨이 0보다 클 때만 로깅 (음성 감지됨)
          if (level > 0) {
            debugPrint('🎤 [STT] Sound Level: $level');
          }
        },
        localeId: locale,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          onDevice: false,
          listenMode: stt.ListenMode.dictation, // confirmation -> dictation으로 변경 (더 연속적인 인식)
        ),
      );

      _isListening = true;
      isListeningNotifier.value = true;
      statusNotifier.value = '듣고 있습니다...';
      debugPrint('🎤 [STT] listen() completed, _speech.isListening: ${_speech.isListening}');
    } catch (e) {
      debugPrint('🎤 [STT] startListening error: $e');
      statusNotifier.value = '음성 인식을 시작할 수 없습니다';
      _isListening = false;
      isListeningNotifier.value = false;
    }
  }
  
  Future<void> stopListening() async {
    debugPrint('🎤 [STT] stopListening called, _isListening: $_isListening');
    if (!_isListening) return;

    try {
      await _speech.stop();
      _isListening = false;
      isListeningNotifier.value = false;
      statusNotifier.value = '음성 인식이 중지되었습니다';
      debugPrint('🎤 [STT] Stopped successfully');
    } catch (e) {
      debugPrint('🎤 [STT] stopListening error: $e');
    }
  }

  Future<void> cancelListening() async {
    debugPrint('🎤 [STT] cancelListening called, _isListening: $_isListening');
    if (!_isListening) return;

    try {
      await _speech.cancel();
      _isListening = false;
      isListeningNotifier.value = false;
      recognizedTextNotifier.value = '';
      statusNotifier.value = '음성 인식이 취소되었습니다';
      debugPrint('🎤 [STT] Cancelled successfully');
    } catch (e) {
      debugPrint('🎤 [STT] cancelListening error: $e');
    }
  }
  
  String _getStatusMessage(String status) {
    switch (status) {
      case 'listening':
        return '듣고 있습니다...';
      case 'notListening':
        return '대기 중';
      case 'done':
        return '완료';
      default:
        return status;
    }
  }
  
  bool get isListening => _isListening;
  bool get isAvailable => _speech.isAvailable;
  bool get isInitialized => _isInitialized;
  
  void dispose() {
    isListeningNotifier.dispose();
    recognizedTextNotifier.dispose();
    statusNotifier.dispose();
    soundLevelNotifier.dispose();
  }
}