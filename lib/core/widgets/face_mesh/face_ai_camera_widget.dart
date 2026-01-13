import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'dart:developer' as developer;

import 'face_guide_overlay.dart';
import '../../services/face_detection_service.dart';

/// Face AI 카메라 위젯
/// iOS & Android: MediaPipe Face Mesh로 실시간 468 랜드마크 감지
class FaceAiCameraWidget extends StatefulWidget {
  /// 사진 촬영 완료 콜백 (Base64 인코딩된 이미지)
  final ValueChanged<String> onImageCaptured;

  /// 촬영 취소 콜백
  final VoidCallback? onCancel;

  /// Face 감지 오버레이 표시 여부
  final bool showOverlay;

  /// 액센트 색상
  final Color accentColor;

  const FaceAiCameraWidget({
    super.key,
    required this.onImageCaptured,
    this.onCancel,
    this.showOverlay = true,
    this.accentColor = const Color(0xFF00FFFF),
  });

  @override
  State<FaceAiCameraWidget> createState() => _FaceAiCameraWidgetState();
}

class _FaceAiCameraWidgetState extends State<FaceAiCameraWidget>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isTakingPicture = false;
  bool _isFrontCamera = true;
  String? _errorMessage;

  // Face Detection (MediaPipe)
  final FaceDetectionService _detectionService = FaceDetectionService();
  FaceDetectionResult? _detectionResult;
  Size? _imageSize;
  bool _overlayEnabled = true;
  bool _isStreamingFrames = false;
  int _frameSkipCounter = 0;
  static const int _frameSkipInterval = 3; // 매 3번째 프레임만 처리

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeServices();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopImageStream();
    _controller?.dispose();
    _detectionService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopImageStream();
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeServices() async {
    try {
      // MediaPipe 초기화
      await _detectionService.initialize();

      if (_detectionService.isMeshAvailable) {
        developer.log('✅ FaceAI: MediaPipe 서비스 초기화 완료');
      } else {
        developer.log('📱 FaceAI: 시뮬레이터 모드 (카메라만 표시)');
      }
    } catch (e) {
      developer.log('❌ FaceAI: MediaPipe 초기화 실패 - $e');
    }

    await _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() => _errorMessage = '카메라를 찾을 수 없습니다');
        return;
      }

      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      await _setupCamera(frontCamera);
    } catch (e) {
      developer.log('❌ FaceAiCamera: 카메라 초기화 실패 - $e');
      setState(() => _errorMessage = '카메라 초기화 실패: $e');
    }
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    _stopImageStream();
    _controller?.dispose();

    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isIOS
          ? ImageFormatGroup.bgra8888
          : ImageFormatGroup.yuv420,
    );

    try {
      await _controller!.initialize();

      // 이미지 크기 저장
      final previewSize = _controller!.value.previewSize;
      if (previewSize != null) {
        _imageSize = Size(previewSize.height, previewSize.width);
      }

      developer.log('🚀 FaceAI: 카메라 초기화 완료 - ${_controller!.value.previewSize}');

      // 실시간 얼굴 감지 시작 (MediaPipe 사용 가능할 때만)
      if (widget.showOverlay && _overlayEnabled && _detectionService.isMeshAvailable) {
        _startImageStream();
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isFrontCamera = camera.lensDirection == CameraLensDirection.front;
        });
      }
    } catch (e) {
      developer.log('❌ FaceAiCamera: 카메라 설정 실패 - $e');
      setState(() => _errorMessage = '카메라 설정 실패');
    }
  }

  /// 실시간 이미지 스트림 시작
  void _startImageStream() {
    if (_controller == null || !_controller!.value.isInitialized || _isStreamingFrames) {
      return;
    }

    _isStreamingFrames = true;
    _frameSkipCounter = 0;

    _controller!.startImageStream((CameraImage image) {
      // 프레임 스킵 (성능 최적화)
      _frameSkipCounter++;
      if (_frameSkipCounter < _frameSkipInterval) {
        return;
      }
      _frameSkipCounter = 0;

      if (_detectionService.isProcessing || _isTakingPicture) {
        return;
      }

      _processImage(image);
    });

    developer.log('🎬 FaceAI: 이미지 스트림 시작');
  }

  /// 이미지 스트림 중지
  Future<void> _stopImageStream() async {
    if (_controller != null && _isStreamingFrames) {
      try {
        await _controller!.stopImageStream();
      } catch (e) {
        // 이미 중지됨
      }
      _isStreamingFrames = false;
      developer.log('⏹️ FaceAI: 이미지 스트림 중지');
    }
  }

  /// 카메라 이미지 처리
  void _processImage(CameraImage image) {
    FaceDetectionResult? result;

    if (Platform.isIOS) {
      // iOS: BGRA8888
      result = _detectionService.detectFromBGRA(
        bytes: image.planes[0].bytes,
        width: image.width,
        height: image.height,
        rotationDegrees: 0,
        mirrorHorizontal: _isFrontCamera,
      );
    } else {
      // Android: YUV420
      result = _detectionService.detectFromYUV420(
        yPlane: image.planes[0].bytes,
        uPlane: image.planes.length > 1 ? image.planes[1].bytes : null,
        vPlane: image.planes.length > 2 ? image.planes[2].bytes : null,
        width: image.width,
        height: image.height,
        yRowStride: image.planes[0].bytesPerRow,
        uvRowStride: image.planes.length > 1 ? image.planes[1].bytesPerRow : image.width ~/ 2,
        uvPixelStride: image.planes.length > 1 ? image.planes[1].bytesPerPixel ?? 1 : 1,
        rotationDegrees: _getRotationDegrees(),
        mirrorHorizontal: _isFrontCamera,
      );
    }

    if (mounted) {
      setState(() {
        _detectionResult = result;
      });
    }
  }

  /// 센서 방향에 따른 회전 각도 계산
  int _getRotationDegrees() {
    if (_controller == null) return 0;
    final sensorOrientation = _controller!.description.sensorOrientation;
    // 전면 카메라는 보통 270도 회전 필요
    return _isFrontCamera ? (360 - sensorOrientation) % 360 : sensorOrientation;
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    await _stopImageStream();

    final currentDirection = _controller?.description.lensDirection;
    final newCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection != currentDirection,
      orElse: () => _cameras!.first,
    );

    await _setupCamera(newCamera);
  }

  Future<void> _toggleOverlay() async {
    setState(() {
      _overlayEnabled = !_overlayEnabled;
      if (!_overlayEnabled) {
        _detectionResult = null;
        _stopImageStream();
      } else if (_detectionService.isMeshAvailable) {
        _startImageStream();
      }
    });
  }

  Future<void> _takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isTakingPicture) {
      return;
    }

    setState(() => _isTakingPicture = true);
    await _stopImageStream();

    try {
      final XFile file = await _controller!.takePicture();
      final bytes = await file.readAsBytes();

      // 이미지 최적화 및 Base64 인코딩
      final optimizedBase64 = await _optimizeAndEncode(bytes);

      // 임시 파일 삭제
      await File(file.path).delete();

      widget.onImageCaptured(optimizedBase64);
    } catch (e) {
      developer.log('❌ FaceAiCamera: 촬영 실패 - $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('촬영 실패: $e')),
        );
        // 스트림 재시작 (MediaPipe 사용 가능할 때만)
        if (widget.showOverlay && _overlayEnabled && _detectionService.isMeshAvailable) {
          _startImageStream();
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isTakingPicture = false);
      }
    }
  }

  Future<String> _optimizeAndEncode(List<int> bytes) async {
    final image = img.decodeImage(Uint8List.fromList(bytes));
    if (image == null) {
      throw Exception('이미지 디코딩 실패');
    }

    img.Image resized;
    if (image.width > 1024 || image.height > 1024) {
      if (image.width > image.height) {
        resized = img.copyResize(image, width: 1024);
      } else {
        resized = img.copyResize(image, height: 1024);
      }
    } else {
      resized = image;
    }

    if (_isFrontCamera) {
      resized = img.flipHorizontal(resized);
    }

    final jpegBytes = img.encodeJpg(resized, quality: 80);
    return base64Encode(jpegBytes);
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return _buildErrorView();
    }

    if (!_isInitialized) {
      return _buildLoadingView();
    }

    return _buildCameraView();
  }

  Widget _buildLoadingView() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: widget.accentColor),
            const SizedBox(height: 16),
            Text(
              'Face AI 준비 중...',
              style: TextStyle(color: widget.accentColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeServices,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    final hasFace = _detectionResult != null;
    final isMeshAvailable = _detectionService.isMeshAvailable;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 카메라 프리뷰
        ClipRect(
          child: OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.previewSize?.height ?? 0,
                height: _controller!.value.previewSize?.width ?? 0,
                child: _controller!.buildPreview(),
              ),
            ),
          ),
        ),

        // Face Mesh 오버레이 (MediaPipe 사용 가능할 때만)
        if (widget.showOverlay && _overlayEnabled && _imageSize != null && isMeshAvailable)
          FaceDetectionOverlay(
            detectionResult: _detectionResult,
            imageSize: _imageSize!,
            cameraLensDirection: _isFrontCamera
                ? CameraLensDirection.front
                : CameraLensDirection.back,
            accentColor: widget.accentColor,
            enablePulse: true,
          ),

        // 시뮬레이터 모드 배너
        if (!isMeshAvailable)
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '시뮬레이터 모드: Face Mesh 비활성화\n실제 기기에서 테스트하세요',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // 얼굴 감지 안내 (MediaPipe 가능 + 얼굴 미감지 시)
        if (widget.showOverlay && _overlayEnabled && !hasFace && isMeshAvailable)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.face, color: widget.accentColor, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    '얼굴을 화면에 맞춰주세요',
                    style: TextStyle(color: widget.accentColor),
                  ),
                ],
              ),
            ),
          ),

        // 상단 컨트롤
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 취소 버튼
              _buildControlButton(
                icon: Icons.close,
                onPressed: widget.onCancel ?? () => Navigator.pop(context),
              ),
              Row(
                children: [
                  // 오버레이 토글 버튼
                  _buildControlButton(
                    icon: _overlayEnabled ? Icons.grid_on : Icons.grid_off,
                    onPressed: _toggleOverlay,
                    isActive: _overlayEnabled,
                  ),
                  const SizedBox(width: 12),
                  // 카메라 전환 버튼
                  if (_cameras != null && _cameras!.length > 1)
                    _buildControlButton(
                      icon: Icons.flip_camera_ios,
                      onPressed: _switchCamera,
                    ),
                ],
              ),
            ],
          ),
        ),

        // 하단 컨트롤
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).padding.bottom + 24,
              top: 16,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Face AI 상태 표시
                _buildStatusIndicator(hasFace),
                const SizedBox(height: 24),

                // 촬영 버튼 (시뮬레이터에서는 항상 ready)
                _buildCaptureButton(!isMeshAvailable || hasFace),

                const SizedBox(height: 16),

                // 안내 텍스트
                Text(
                  !_detectionService.isMeshAvailable
                      ? '촬영 후 AI 분석을 진행합니다'
                      : (hasFace ? '얼굴이 감지되었습니다. 촬영해주세요!' : '얼굴이 가이드 안에 들어오도록 해주세요'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(bool hasFace) {
    final isMeshAvailable = _detectionService.isMeshAvailable;

    // 시뮬레이터 모드일 때
    if (!isMeshAvailable) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.orange.withValues(alpha: 0.5),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.phonelink_off, color: Colors.orange, size: 16),
            SizedBox(width: 8),
            Text(
              '시뮬레이터 모드',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: hasFace
            ? widget.accentColor.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasFace
              ? widget.accentColor.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: hasFace ? widget.accentColor : Colors.grey,
              shape: BoxShape.circle,
              boxShadow: hasFace
                  ? [
                      BoxShadow(
                        color: widget.accentColor.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            hasFace
                ? 'Face AI 활성화 (${_detectionResult?.landmarks?.length ?? 0} points)'
                : 'Face AI 대기 중',
            style: TextStyle(
              color: hasFace ? widget.accentColor : Colors.white70,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return Material(
      color: isActive
          ? widget.accentColor.withValues(alpha: 0.3)
          : Colors.black.withValues(alpha: 0.3),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: isActive ? widget.accentColor : Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureButton(bool isReady) {
    return GestureDetector(
      onTap: _isTakingPicture ? null : _takePicture,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isReady ? widget.accentColor : Colors.white,
            width: 4,
          ),
          boxShadow: isReady
              ? [
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.4),
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _isTakingPicture
                ? Colors.grey
                : (isReady ? widget.accentColor : Colors.white),
            shape: BoxShape.circle,
          ),
          child: _isTakingPicture
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
