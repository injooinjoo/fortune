import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_settings_provider.dart';

/// 🧘 명상 배경 음악 서비스
///
/// 호흡 명상 중 차분한 앰비언트 배경음악을 재생합니다.
/// 명상 시작/일시정지/종료에 맞춰 음악을 제어합니다.
///
/// ## 사용법
/// ```dart
/// // 1. Provider 사용 (권장)
/// ref.read(meditationSoundServiceProvider).play();
/// ref.read(meditationSoundServiceProvider).pause();
/// ref.read(meditationSoundServiceProvider).stop();
///
/// // 2. Extension 사용
/// ref.meditationSound.play();
/// ```
///
/// ## 음원 파일
/// `assets/sounds/meditation_ambient.mp3`
/// - Mixkit 또는 Pixabay에서 무료 명상 앰비언트 음악 다운로드
/// - 루프 재생에 적합한 2-3분 길이 권장
class MeditationSoundService {
  final Ref _ref;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isInitialized = false;
  bool _isPlaying = false;

  // 음원 파일 경로
  static const String _meditationSoundPath = 'sounds/meditation_ambient.mp3';

  // 기본 볼륨 (0.0 ~ 1.0)
  static const double _defaultVolume = 0.3;

  MeditationSoundService(this._ref) {
    _initialize();
  }

  /// 초기화
  Future<void> _initialize() async {
    try {
      // 루프 모드 설정 (배경음악이므로 계속 반복)
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      // 볼륨 설정 (너무 크지 않게)
      await _audioPlayer.setVolume(_defaultVolume);
      _isInitialized = true;
    } catch (e) {
      debugPrint('MeditationSoundService 초기화 실패: $e');
      _isInitialized = false;
    }
  }

  /// 효과음 활성화 여부 확인
  bool get isEnabled => _ref.read(userSettingsProvider).soundEnabled;

  /// 재생 가능 여부 확인
  bool get _canPlay => isEnabled && _isInitialized;

  /// 현재 재생 중인지 확인
  bool get isPlaying => _isPlaying;

  /// 명상 배경 음악 재생
  ///
  /// 명상 시작 시 호출합니다.
  /// 루프 모드로 재생되어 명상이 끝날 때까지 계속됩니다.
  Future<void> play() async {
    if (!_canPlay) return;
    if (_isPlaying) return; // 이미 재생 중이면 무시

    try {
      await _audioPlayer.play(AssetSource(_meditationSoundPath));
      _isPlaying = true;
    } catch (e) {
      debugPrint('명상 배경 음악 재생 실패: $e');
    }
  }

  /// 일시정지
  ///
  /// 명상 일시정지 시 호출합니다.
  Future<void> pause() async {
    if (!_isPlaying) return;

    try {
      await _audioPlayer.pause();
      _isPlaying = false;
    } catch (e) {
      debugPrint('명상 배경 음악 일시정지 실패: $e');
    }
  }

  /// 재개
  ///
  /// 일시정지 후 재개 시 호출합니다.
  Future<void> resume() async {
    if (!_canPlay) return;
    if (_isPlaying) return;

    try {
      await _audioPlayer.resume();
      _isPlaying = true;
    } catch (e) {
      debugPrint('명상 배경 음악 재개 실패: $e');
    }
  }

  /// 정지
  ///
  /// 명상 종료 또는 리셋 시 호출합니다.
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
    } catch (e) {
      debugPrint('명상 배경 음악 정지 실패: $e');
    }
  }

  /// 볼륨 조절
  ///
  /// [volume] 0.0 (음소거) ~ 1.0 (최대)
  Future<void> setVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _audioPlayer.setVolume(clampedVolume);
    } catch (e) {
      debugPrint('볼륨 조절 실패: $e');
    }
  }

  /// 서비스 종료
  void dispose() {
    _audioPlayer.dispose();
  }
}

/// MeditationSoundService Provider
final meditationSoundServiceProvider = Provider<MeditationSoundService>((ref) {
  final service = MeditationSoundService(ref);

  // Provider dispose 시 서비스 정리
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// WidgetRef Extension - 쉬운 접근을 위한 확장
extension MeditationSoundRef on WidgetRef {
  MeditationSoundService get meditationSound =>
      read(meditationSoundServiceProvider);
}

/// Ref Extension - Provider 내부에서 사용
extension MeditationSoundRefExt on Ref {
  MeditationSoundService get meditationSound =>
      read(meditationSoundServiceProvider);
}
