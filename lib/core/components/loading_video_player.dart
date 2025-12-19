import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// 로딩 화면용 비디오 플레이어 위젯
/// 스플래시, 운세 로딩 등에서 재사용
class LoadingVideoPlayer extends StatefulWidget {
  const LoadingVideoPlayer({
    super.key,
    this.width = 200,
    this.height = 200,
    this.onVideoEnd,
    this.loop = true,
  });

  final double width;
  final double height;
  final VoidCallback? onVideoEnd;
  final bool loop;

  @override
  State<LoadingVideoPlayer> createState() => _LoadingVideoPlayerState();
}

class _LoadingVideoPlayerState extends State<LoadingVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset('assets/videos/loading.mp4');

    try {
      await _controller.initialize();

      if (!mounted) return;

      _controller.setLooping(widget.loop);
      _controller.setVolume(0); // 무음 재생
      _controller.play();

      // 비디오 종료 리스너
      if (widget.onVideoEnd != null && !widget.loop) {
        _controller.addListener(() {
          if (_controller.value.position >= _controller.value.duration) {
            widget.onVideoEnd?.call();
          }
        });
      }

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('LoadingVideoPlayer: Failed to initialize video: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      // 비디오 로딩 중에는 앱 아이콘 표시
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Image.asset(
          'assets/images/app_icon.png',
          fit: BoxFit.contain,
        ),
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        ),
      ),
    );
  }
}
