import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ondo/core/design_system/theme/ds_theme.dart';
import 'package:ondo/core/widgets/unified_voice_text_field.dart';
import 'package:ondo/services/speech_recognition_service.dart';

class _FakeSpeechRecognitionService extends SpeechRecognitionService {
  _FakeSpeechRecognitionService({
    required this.permissionStatus,
    required this.requestResult,
  });

  MicrophonePermissionStatus permissionStatus;
  final MicrophonePermissionStatus requestResult;
  int requestPermissionCallCount = 0;
  int openSettingsCallCount = 0;
  int startListeningCallCount = 0;
  int stopListeningCallCount = 0;
  Function(String text)? _onResultCallback;
  Function(String text)? _onPartialResultCallback;

  @override
  Future<MicrophonePermissionStatus> checkPermissionStatus() async {
    return permissionStatus;
  }

  @override
  Future<MicrophonePermissionStatus> requestPermission() async {
    requestPermissionCallCount++;
    permissionStatus = requestResult;
    return requestResult;
  }

  @override
  Future<void> openSettings() async {
    openSettingsCallCount++;
  }

  @override
  Future<bool> initialize() async => true;

  @override
  Future<void> startListening({
    required Function(String text) onResult,
    Function(String text)? onPartialResult,
    Function()? onNoMatch,
    String locale = 'ko-KR',
  }) async {
    startListeningCallCount++;
    _onResultCallback = onResult;
    _onPartialResultCallback = onPartialResult;
    isListeningNotifier.value = true;
  }

  @override
  Future<void> stopListening() async {
    stopListeningCallCount++;
    isListeningNotifier.value = false;
  }

  void emitPartialResult(String text) {
    _onPartialResultCallback?.call(text);
  }

  void emitFinalResult(String text) {
    _onResultCallback?.call(text);
    isListeningNotifier.value = false;
  }

  @override
  void dispose() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpVoiceField(
    WidgetTester tester, {
    required SpeechRecognitionService speechService,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DSTheme.light(),
        home: Scaffold(
          body: UnifiedVoiceTextField(
            onSubmit: (_) {},
            speechService: speechService,
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets(
      'microphone pre-prompt uses continue CTA and immediately proceeds to permission request',
      (tester) async {
    final speechService = _FakeSpeechRecognitionService(
      permissionStatus: MicrophonePermissionStatus.denied,
      requestResult: MicrophonePermissionStatus.denied,
    );

    await pumpVoiceField(tester, speechService: speechService);

    await tester.tap(find.byIcon(Icons.mic_none));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('마이크 권한 필요'), findsOneWidget);
    expect(find.text('계속'), findsOneWidget);
    expect(find.text('취소'), findsNothing);

    await tester.tapAt(const Offset(5, 5));
    await tester.pump();
    expect(find.text('마이크 권한 필요'), findsOneWidget);

    await tester.tap(find.text('계속'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(speechService.requestPermissionCallCount, 1);
  });

  testWidgets(
      'permanently denied microphone permission routes users to settings',
      (tester) async {
    final speechService = _FakeSpeechRecognitionService(
      permissionStatus: MicrophonePermissionStatus.permanentlyDenied,
      requestResult: MicrophonePermissionStatus.permanentlyDenied,
    );

    await pumpVoiceField(tester, speechService: speechService);

    await tester.tap(find.byIcon(Icons.mic_none));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('설정으로 이동'), findsOneWidget);

    await tester.tap(find.text('설정으로 이동'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(speechService.openSettingsCallCount, 1);
    expect(speechService.requestPermissionCallCount, 0);
  });

  testWidgets('voice action button flows from mic to stop to send', (
    tester,
  ) async {
    final speechService = _FakeSpeechRecognitionService(
      permissionStatus: MicrophonePermissionStatus.granted,
      requestResult: MicrophonePermissionStatus.granted,
    );
    String? submittedText;

    await tester.pumpWidget(
      MaterialApp(
        theme: DSTheme.light(),
        home: Scaffold(
          body: UnifiedVoiceTextField(
            onSubmit: (text) {
              submittedText = text;
            },
            speechService: speechService,
          ),
        ),
      ),
    );

    await tester.pump();

    await tester.tap(find.byIcon(Icons.mic_none));
    await tester.pump();

    expect(speechService.startListeningCallCount, 1);
    expect(find.byIcon(Icons.stop_rounded), findsOneWidget);

    speechService.emitPartialResult('안녕하세요');
    await tester.pump();

    expect(find.byIcon(Icons.arrow_upward), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(speechService.stopListeningCallCount, 1);
    expect(submittedText, '안녕하세요');
  });
}
