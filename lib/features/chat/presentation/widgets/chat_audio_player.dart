import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';

/// 채팅 오디오 플레이어 위젯
///
/// 음성 메시지 재생을 위한 컴팩트한 오디오 플레이어.
/// - 재생/일시정지 토글
/// - 진행률 바 (드래그 가능)
/// - 남은 시간 표시
/// - 재생 속도 조절 (1x, 1.5x, 2x)
class ChatAudioPlayer extends StatefulWidget {
  /// 오디오 파일 경로 (URL 또는 asset 경로)
  final String audioPath;

  /// 미리 알려진 재생 시간 (초, 선택적)
  final int? durationSeconds;

  /// 재생 완료 시 콜백
  final VoidCallback? onComplete;

  /// 사용자 메시지 여부 (정렬 결정)
  final bool isUser;

  const ChatAudioPlayer({
    super.key,
    required this.audioPath,
    this.durationSeconds,
    this.onComplete,
    this.isUser = false,
  });

  @override
  State<ChatAudioPlayer> createState() => _ChatAudioPlayerState();
}

class _ChatAudioPlayerState extends State<ChatAudioPlayer> {
  late final AudioPlayer _audioPlayer;

  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _playbackSpeed = 1.0;

  static const List<double> _speedOptions = [1.0, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    // 미리 알려진 재생 시간이 있으면 설정
    if (widget.durationSeconds != null) {
      _duration = Duration(seconds: widget.durationSeconds!);
    }

    // 재생 상태 리스너
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          _isLoading =
              state == PlayerState.stopped && _position == Duration.zero;
        });

        if (state == PlayerState.completed) {
          setState(() {
            _position = Duration.zero;
            _isPlaying = false;
          });
          widget.onComplete?.call();
        }
      }
    });

    // 재생 위치 리스너
    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    // 총 재생 시간 리스너
    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_isLoading) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        setState(() => _isLoading = true);

        // URL인지 Asset인지 판단
        if (widget.audioPath.startsWith('http://') ||
            widget.audioPath.startsWith('https://')) {
          await _audioPlayer.play(UrlSource(widget.audioPath));
        } else {
          await _audioPlayer.play(AssetSource(widget.audioPath));
        }

        await _audioPlayer.setPlaybackRate(_playbackSpeed);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('오디오 재생 오류: $e');
    }
  }

  Future<void> _seekTo(double value) async {
    final position = Duration(
      milliseconds: (value * _duration.inMilliseconds).round(),
    );
    await _audioPlayer.seek(position);
  }

  void _cyclePlaybackSpeed() {
    final currentIndex = _speedOptions.indexOf(_playbackSpeed);
    final nextIndex = (currentIndex + 1) % _speedOptions.length;
    setState(() {
      _playbackSpeed = _speedOptions[nextIndex];
    });
    _audioPlayer.setPlaybackRate(_playbackSpeed);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final progress = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: DSSpacing.xxs,
        horizontal: DSSpacing.md,
      ),
      child: Align(
        alignment: widget.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.sm,
            vertical: DSSpacing.xs,
          ),
          decoration: BoxDecoration(
            color:
                widget.isUser ? colors.userBubble : colors.backgroundSecondary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 재생/일시정지 버튼
              _buildPlayButton(colors),
              const SizedBox(width: DSSpacing.xs),

              // 진행률 바 + 시간
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 진행률 바
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 12,
                        ),
                        activeTrackColor: colors.accent,
                        inactiveTrackColor:
                            colors.textTertiary.withValues(alpha: 0.3),
                        thumbColor: colors.accent,
                        overlayColor: colors.accent.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: progress.clamp(0.0, 1.0),
                        onChanged:
                            _duration.inMilliseconds > 0 ? _seekTo : null,
                      ),
                    ),

                    // 시간 표시
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: DSSpacing.xs),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_position),
                            style: context.labelSmall.copyWith(
                              color: colors.textTertiary,
                            ),
                          ),
                          Text(
                            _formatDuration(_duration),
                            style: context.labelSmall.copyWith(
                              color: colors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DSSpacing.xs),

              // 재생 속도 버튼
              _buildSpeedButton(colors),
            ],
          ),
        ),
      ),
    );
  }

  /// 재생/일시정지 버튼
  Widget _buildPlayButton(DSColorScheme colors) {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colors.accent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.ctaForeground,
                  ),
                )
              : Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: colors.ctaForeground,
                  size: 20,
                ),
        ),
      ),
    );
  }

  /// 재생 속도 버튼
  Widget _buildSpeedButton(DSColorScheme colors) {
    return GestureDetector(
      onTap: _cyclePlaybackSpeed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.xs,
          vertical: DSSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: colors.backgroundTertiary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${_playbackSpeed}x',
          style: context.labelSmall.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
