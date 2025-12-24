import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'dart:developer' as developer;
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/design_system/design_system.dart';
import 'face_zone_overlay.dart';
import 'privacy_notice_banner.dart';
import 'privacy_confirmation_modal.dart';

/// 카메라 촬영 위젯
/// 실시간 카메라 프리뷰와 얼굴 가이드 오버레이를 통합합니다.
class CameraCaptureWidget extends StatefulWidget {
  /// 사진 촬영 완료 콜백 (Base64 인코딩된 이미지)
  final ValueChanged<String> onImageCaptured;

  /// 촬영 취소 콜백
  final VoidCallback? onCancel;

  /// 얼굴 존 오버레이 표시 여부
  final bool showFaceZones;

  /// 개인정보 동의 확인 여부
  final bool requirePrivacyConfirmation;

  const CameraCaptureWidget({
    super.key,
    required this.onImageCaptured,
    this.onCancel,
    this.showFaceZones = true,
    this.requirePrivacyConfirmation = true,
  });

  @override
  State<CameraCaptureWidget> createState() => _CameraCaptureWidgetState();
}

class _CameraCaptureWidgetState extends State<CameraCaptureWidget>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isTakingPicture = false;
  bool _isFrontCamera = true;
  String? _errorMessage;
  bool _privacyConfirmed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
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

      // 전면 카메라 찾기
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      await _setupCamera(frontCamera);
    } catch (e) {
      developer.log('❌ CameraCaptureWidget: 카메라 초기화 실패 - $e');
      setState(() => _errorMessage = '카메라 초기화 실패: $e');
    }
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    _controller?.dispose();

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isFrontCamera = camera.lensDirection == CameraLensDirection.front;
        });
      }
    } catch (e) {
      developer.log('❌ CameraCaptureWidget: 카메라 설정 실패 - $e');
      setState(() => _errorMessage = '카메라 설정 실패');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    final currentDirection = _controller?.description.lensDirection;
    final newCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection != currentDirection,
      orElse: () => _cameras!.first,
    );

    await _setupCamera(newCamera);
  }

  Future<void> _takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isTakingPicture) {
      return;
    }

    // 개인정보 동의 확인
    if (widget.requirePrivacyConfirmation && !_privacyConfirmed) {
      final confirmed = await PrivacyConfirmationModal.show(
        context,
        onDontShowAgainChanged: (dontShow) {
          if (dontShow) {
            _privacyConfirmed = true;
            // TODO: 설정에 저장
          }
        },
      );
      if (!confirmed) return;
      _privacyConfirmed = true;
    }

    setState(() => _isTakingPicture = true);

    try {
      final XFile file = await _controller!.takePicture();
      final bytes = await file.readAsBytes();

      // 이미지 최적화 및 Base64 인코딩
      final optimizedBase64 = await _optimizeAndEncode(bytes);

      // 임시 파일 삭제
      await File(file.path).delete();

      widget.onImageCaptured(optimizedBase64);
    } catch (e) {
      developer.log('❌ CameraCaptureWidget: 촬영 실패 - $e');
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
    // 이미지 디코딩
    final image = img.decodeImage(Uint8List.fromList(bytes));
    if (image == null) {
      throw Exception('이미지 디코딩 실패');
    }

    // 크기 조정 (최대 1024px)
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

    // 전면 카메라면 좌우 반전
    if (_isFrontCamera) {
      resized = img.flipHorizontal(resized);
    }

    // JPEG 품질 80%로 인코딩
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
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              '카메라 준비 중...',
              style: TextStyle(color: Colors.white),
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

        // 얼굴 가이드 오버레이
        if (widget.showFaceZones)
          const FaceZoneOverlay(
            showLabels: true,
            animate: true,
          )
        else
          const SimpleFaceFrameOverlay(),

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
              // 카메라 전환 버튼
              if (_cameras != null && _cameras!.length > 1)
                _buildControlButton(
                  icon: Icons.flip_camera_ios,
                  onPressed: _switchCamera,
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
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 개인정보 안내
                const PrivacyNoticeInline(),
                const SizedBox(height: 24),

                // 촬영 버튼
                _buildCaptureButton(),

                const SizedBox(height: 16),

                // 안내 텍스트
                Text(
                  '얼굴이 가이드 안에 들어오도록 해주세요',
                  style: context.labelMedium.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.black.withOpacity(0.3),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _isTakingPicture ? null : _takePicture,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _isTakingPicture ? Colors.grey : Colors.white,
            shape: BoxShape.circle,
          ),
          child: _isTakingPicture
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(strokeWidth: 3),
                )
              : null,
        ),
      ),
    );
  }
}

/// 갤러리에서 이미지 선택 버튼
class GalleryPickerButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GalleryPickerButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.3),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.photo_library, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                '갤러리에서 선택',
                style: context.labelMedium.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
