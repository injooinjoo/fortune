import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../core/config/environment.dart';

class SpeechRecognitionService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  
  final ValueNotifier<bool> isListeningNotifier = ValueNotifier(false);
  final ValueNotifier<String> recognizedTextNotifier = ValueNotifier('');
  final ValueNotifier<String> statusNotifier = ValueNotifier('');
  final ValueNotifier<double> soundLevelNotifier = ValueNotifier(0.0);
  
  Future<bool> initialize() async {
    try {
      // 마이크 권한 확인
      final micPermission = await Permission.microphone.status;
      if (!micPermission.isGranted) {
        final result = await Permission.microphone.request();
        if (!result.isGranted) {
          statusNotifier.value = '마이크 권한이 필요합니다';
          return false;
        }
      }
      
      // iOS에서 음성 인식 권한 확인
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final speechPermission = await Permission.speech.status;
        if (!speechPermission.isGranted) {
          final result = await Permission.speech.request();
          if (!result.isGranted) {
            statusNotifier.value = '음성 인식 권한이 필요합니다';
            return false;
          }
        }
      }
      
      // 음성 인식 초기화
      _isInitialized = await _speech.initialize(
        onStatus: (status) {
          statusNotifier.value = _getStatusMessage(status);
          debugPrint('Supabase initialized with URL: ${Environment.supabaseUrl}');
        },
        onError: (error) {
          statusNotifier.value = '오류: ${error.errorMsg}';
          debugPrint('error: ${error.errorMsg}');
          stopListening();
        });
      
      if (!_isInitialized) {
        statusNotifier.value = '음성 인식을 초기화할 수 없습니다';
      }
      
      return _isInitialized;
    } catch (e) {
      debugPrint('Supabase initialized with URL: ${Environment.supabaseUrl}');
      statusNotifier.value = '초기화 중 오류가 발생했습니다';
      return false;
    }
  }
  
  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onPartialResult,
    String locale = 'ko-KR'}) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }
    
    if (_isListening) return;
    
    try {
      recognizedTextNotifier.value = '';
      String lastFinalResult = '';
      
      await _speech.listen(
        onResult: (result) {
          // Partial result 처리
          if (!result.finalResult) {
            // 현재까지 인식된 부분적인 텍스트
            final currentText = result.recognizedWords;
            recognizedTextNotifier.value = currentText;
            onPartialResult?.call(currentText);
          } else {
            // Final result 처리
            final finalText = result.recognizedWords;
            if (finalText != lastFinalResult && finalText.isNotEmpty) {
              lastFinalResult = finalText;
              onResult(finalText);
              // Final result 후 recognizedText 초기화
              recognizedTextNotifier.value = '';
            }
          }
        },
        onSoundLevelChange: (level) {
          // 사운드 레벨 업데이트 (0.0 ~ 1.0)
          soundLevelNotifier.value = level;
          debugPrint('🎤 Sound Level: $level');
        },
        localeId: locale,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        onDevice: false,
        listenMode: stt.ListenMode.confirmation
      );
      
      _isListening = true;
      isListeningNotifier.value = true;
      statusNotifier.value = '듣고 있습니다...';
    } catch (e) {
      debugPrint('Supabase initialized with URL: ${Environment.supabaseUrl}');
      statusNotifier.value = '음성 인식을 시작할 수 없습니다';
    }
  }
  
  Future<void> stopListening() async {
    if (!_isListening) return;
    
    try {
      await _speech.stop();
      _isListening = false;
      isListeningNotifier.value = false;
      statusNotifier.value = '음성 인식이 중지되었습니다';
    } catch (e) {
      debugPrint('Supabase initialized with URL: ${Environment.supabaseUrl}');
    }
  }
  
  Future<void> cancelListening() async {
    if (!_isListening) return;
    
    try {
      await _speech.cancel();
      _isListening = false;
      isListeningNotifier.value = false;
      recognizedTextNotifier.value = '';
      statusNotifier.value = '음성 인식이 취소되었습니다';
    } catch (e) {
      debugPrint('Supabase initialized with URL: ${Environment.supabaseUrl}');
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
  }
}