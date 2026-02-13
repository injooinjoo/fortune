import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_settings_provider.dart';

/// 📄 페이지 넘기기 효과음 서비스
///
/// 한지 스타일의 종이 넘기는 효과음을 재생합니다.
/// FortuneHapticService와 동일한 패턴으로 설계되어 일관성 있는 피드백을 제공합니다.
///
/// ## 사용법
/// ```dart
/// // 1. Provider 사용 (권장)
/// ref.read(pageTurnSoundServiceProvider).playPageTurn();
///
/// // 2. Extension 사용
/// ref.pageTurnSound.playPageTurn();
/// ```
///
/// ## 효과음 파일 추가 필요
/// `assets/sounds/page_turn.mp3` 파일을 추가해주세요.
/// 권장: 부드러운 종이 넘기는 소리 (0.3-0.5초)
class PageTurnSoundService {
  final Ref _ref;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isInitialized = false;

  // 효과음 파일 경로
  static const String _pageTurnSoundPath = 'sounds/page_turn.mp3';

  PageTurnSoundService(this._ref) {
    _initialize();
  }

  /// 초기화
  Future<void> _initialize() async {
    try {
      // 볼륨 설정 (너무 크지 않게)
      await _audioPlayer.setVolume(0.3);
      // release 모드 설정 (재생 완료 후 자원 해제하지 않음)
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      _isInitialized = true;
    } catch (e) {
      debugPrint('PageTurnSoundService 초기화 실패: $e');
      _isInitialized = false;
    }
  }

  /// 효과음 활성화 여부 확인
  bool get isEnabled => _ref.read(userSettingsProvider).soundEnabled;

  /// 효과음 재생 가능 여부 확인
  bool get _canPlay => isEnabled && _isInitialized;

  /// 페이지 넘기기 효과음 재생
  ///
  /// 카드 스와이프, 페이지 전환 시 사용합니다.
  /// 한지 느낌의 부드러운 종이 넘기는 소리를 재생합니다.
  Future<void> playPageTurn() async {
    if (!_canPlay) return;

    try {
      // 이전 재생 중지
      await _audioPlayer.stop();
      // 에셋에서 재생
      await _audioPlayer.play(AssetSource(_pageTurnSoundPath));
    } catch (e) {
      // 효과음 파일이 없거나 재생 실패 시 무시 (햅틱만 동작)
      debugPrint('페이지 넘김 효과음 재생 실패: $e');
    }
  }

  /// 소프트한 페이지 넘기기 (더 작은 볼륨)
  ///
  /// 빠른 연속 스와이프 시 사용합니다.
  Future<void> playPageTurnSoft() async {
    if (!_canPlay) return;

    try {
      await _audioPlayer.stop();
      await _audioPlayer.setVolume(0.15);
      await _audioPlayer.play(AssetSource(_pageTurnSoundPath));
      // 볼륨 복원
      await _audioPlayer.setVolume(0.3);
    } catch (e) {
      debugPrint('페이지 넘김 효과음 재생 실패: $e');
    }
  }

  /// 서비스 종료
  void dispose() {
    _audioPlayer.dispose();
  }
}

/// PageTurnSoundService Provider
final pageTurnSoundServiceProvider = Provider<PageTurnSoundService>((ref) {
  final service = PageTurnSoundService(ref);

  // Provider dispose 시 서비스 정리
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// WidgetRef Extension - 쉬운 접근을 위한 확장
extension PageTurnSoundRef on WidgetRef {
  PageTurnSoundService get pageTurnSound => read(pageTurnSoundServiceProvider);
}

/// Ref Extension - Provider 내부에서 사용
extension PageTurnSoundRefExt on Ref {
  PageTurnSoundService get pageTurnSound => read(pageTurnSoundServiceProvider);
}
