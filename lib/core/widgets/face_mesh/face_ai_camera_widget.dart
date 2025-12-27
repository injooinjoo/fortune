import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:image/image.dart' as img;
import 'dart:developer' as developer;

import 'face_mesh_painter.dart';
import '../../services/face_mesh_service.dart';

/// Face AI 카메라 위젯
/// 실시간 Face Mesh 오버레이가 적용된 카메라 프리뷰
class FaceAiCameraWidget extends StatefulWidget {
  /// 사진 촬영 완료 콜백 (Base64 인코딩된 이미지)
  final ValueChanged<String> onImageCaptured;

  /// 촬영 취소 콜백
  final VoidCallback? onCancel;

  /// Face Mesh 표시 여부
  final bool showMesh;

  /// 메쉬 색상
  final Color meshColor;

  const FaceAiCameraWidget({
    super.key,
    required this.onImageCaptured,
    this.onCancel,
    this.showMesh = true,
    this.meshColor = const Color(0xFF00FFFF),
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

  // Face Mesh
  final FaceMeshService _meshService = FaceMeshService();
  List<FaceMesh> _meshes = [];
  Size? _imageSize;
  InputImageRotation _rotation = InputImageRotation.rotation0deg;
  bool _meshEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _meshService.initialize();
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _meshService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
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
    _controller?.dispose();

    _controller = CameraController(
      camera,
      ResolutionPreset.medium, // 성능을 위해 medium 사용
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21, // ML Kit 호환 포맷
    );

    try {
      await _controller!.initialize();

      // 이미지 스트림 시작 (Face Mesh 감지용)
      if (widget.showMesh && _meshEnabled) {
        await _controller!.startImageStream(_processImage);
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

  /// 카메라 이미지 처리 (Face Mesh 감지)
  Future<void> _processImage(CameraImage image) async {
    if (!_meshEnabled || _controller == null) return;

    final camera = _controller!.description;
    final meshes = await _meshService.detectFromCameraImage(image, camera);

    if (mounted) {
      setState(() {
        _meshes = meshes;
        _imageSize = Size(image.width.toDouble(), image.height.toDouble());
        _rotation = _getRotation(camera);
      });
    }
  }

  InputImageRotation _getRotation(CameraDescription camera) {
    final sensorOrientation = camera.sensorOrientation;
    switch (sensorOrientation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    // 이미지 스트림 중지
    if (_controller?.value.isStreamingImages ?? false) {
      await _controller?.stopImageStream();
    }

    final currentDirection = _controller?.description.lensDirection;
    final newCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection != currentDirection,
      orElse: () => _cameras!.first,
    );

    await _setupCamera(newCamera);
  }

  Future<void> _toggleMesh() async {
    setState(() {
      _meshEnabled = !_meshEnabled;
      if (!_meshEnabled) {
        _meshes = [];
      }
    });

    if (_controller?.value.isStreamingImages ?? false) {
      await _controller?.stopImageStream();
    }

    if (_meshEnabled && widget.showMesh) {
      await _controller?.startImageStream(_processImage);
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isTakingPicture) {
      return;
    }

    setState(() => _isTakingPicture = true);

    try {
      // 이미지 스트림 중지
      if (_controller?.value.isStreamingImages ?? false) {
        await _controller?.stopImageStream();
      }

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
            CircularProgressIndicator(color: widget.meshColor),
            const SizedBox(height: 16),
            Text(
              'Face AI 준비 중...',
              style: TextStyle(color: widget.meshColor),
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
              onPressed: _initializeCamera,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
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

        // Face Mesh 오버레이
        if (widget.showMesh && _meshEnabled && _meshes.isNotEmpty && _imageSize != null)
          FaceMeshOverlay(
            meshes: _meshes,
            imageSize: _imageSize!,
            rotation: _rotation,
            cameraLensDirection: _isFrontCamera
                ? CameraLensDirection.front
                : CameraLensDirection.back,
            meshColor: widget.meshColor,
            enablePulse: true,
          ),

        // 얼굴 감지 안내
        if (widget.showMesh && _meshEnabled && _meshes.isEmpty)
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
                  Icon(Icons.face, color: widget.meshColor, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    '얼굴을 화면에 맞춰주세요',
                    style: TextStyle(color: widget.meshColor),
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
                  // 메쉬 토글 버튼
                  _buildControlButton(
                    icon: _meshEnabled ? Icons.grid_on : Icons.grid_off,
                    onPressed: _toggleMesh,
                    isActive: _meshEnabled,
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
                _buildStatusIndicator(),
                const SizedBox(height: 24),

                // 촬영 버튼
                _buildCaptureButton(),

                const SizedBox(height: 16),

                // 안내 텍스트
                Text(
                  _meshes.isNotEmpty
                      ? '얼굴이 감지되었습니다. 촬영해주세요!'
                      : '얼굴이 가이드 안에 들어오도록 해주세요',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14, // 예외: 카메라 UI
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    final hasface = _meshes.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: hasface
            ? widget.meshColor.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasface
              ? widget.meshColor.withValues(alpha: 0.5)
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
              color: hasface ? widget.meshColor : Colors.grey,
              shape: BoxShape.circle,
              boxShadow: hasface
                  ? [
                      BoxShadow(
                        color: widget.meshColor.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            hasface ? 'Face AI 활성화' : 'Face AI 대기 중',
            style: TextStyle(
              color: hasface ? widget.meshColor : Colors.white70,
              fontWeight: FontWeight.w500,
              fontSize: 12, // 예외: 카메라 UI
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
          ? widget.meshColor.withValues(alpha: 0.3)
          : Colors.black.withValues(alpha: 0.3),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: isActive ? widget.meshColor : Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    final hasFace = _meshes.isNotEmpty;
    return GestureDetector(
      onTap: _isTakingPicture ? null : _takePicture,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: hasFace ? widget.meshColor : Colors.white,
            width: 4,
          ),
          boxShadow: hasFace
              ? [
                  BoxShadow(
                    color: widget.meshColor.withValues(alpha: 0.4),
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
                : (hasFace ? widget.meshColor : Colors.white),
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
