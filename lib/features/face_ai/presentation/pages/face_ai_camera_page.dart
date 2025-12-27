import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/widgets/face_mesh/face_ai_camera_widget.dart';
import '../../../../core/design_system/design_system.dart';

/// Face AI 카메라 페이지
/// Google Face Mesh 오버레이가 적용된 카메라 화면
class FaceAiCameraPage extends ConsumerStatefulWidget {
  const FaceAiCameraPage({super.key});

  @override
  ConsumerState<FaceAiCameraPage> createState() => _FaceAiCameraPageState();
}

class _FaceAiCameraPageState extends ConsumerState<FaceAiCameraPage> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Face AI 카메라 위젯 (Face Mesh 포함)
          FaceAiCameraWidget(
            onImageCaptured: _onImageCaptured,
            onCancel: () => context.pop(),
            showMesh: true,
            meshColor: const Color(0xFF00FFFF), // Cyan 색상
          ),

          // 처리 중 오버레이
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFF9C27B0),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '이미지 처리 중...',
                      style: DSTypography.bodyMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 이미지 촬영 완료 콜백
  Future<void> _onImageCaptured(String base64Image) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      // Base64 이미지를 파일로 저장
      final bytes = base64Decode(base64Image);
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/face_ai_capture_$timestamp.jpg');
      await file.writeAsBytes(bytes);

      if (mounted) {
        // Face Reading 분석 페이지로 이동
        context.push('/face-reading', extra: {
          'capturedImageFile': file,
          'fromFaceAi': true,
        });
      }
    } catch (e) {
      debugPrint('❌ [FaceAiCameraPage] 이미지 처리 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 처리에 실패했습니다: $e'),
            backgroundColor: DSColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
