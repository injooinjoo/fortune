import 'dart:ui' show Size;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'dart:developer' as developer;

/// Face Mesh 감지 서비스
/// 카메라 이미지에서 실시간으로 얼굴 메쉬를 감지합니다.
class FaceMeshService {
  FaceMeshDetector? _detector;
  bool _isProcessing = false;

  /// 싱글톤 인스턴스
  static final FaceMeshService _instance = FaceMeshService._internal();
  factory FaceMeshService() => _instance;
  FaceMeshService._internal();

  /// 감지기 초기화
  void initialize() {
    _detector ??= FaceMeshDetector(
      option: FaceMeshDetectorOptions.faceMesh,
    );
  }

  /// 리소스 해제
  Future<void> dispose() async {
    await _detector?.close();
    _detector = null;
  }

  /// 카메라 이미지에서 Face Mesh 감지
  Future<List<FaceMesh>> detectFromCameraImage(CameraImage image, CameraDescription camera) async {
    if (_detector == null || _isProcessing) {
      return [];
    }

    _isProcessing = true;

    try {
      final inputImage = _convertCameraImage(image, camera);
      if (inputImage == null) {
        return [];
      }

      final meshes = await _detector!.processImage(inputImage);
      return meshes;
    } catch (e) {
      developer.log('FaceMeshService: 감지 오류 - $e');
      return [];
    } finally {
      _isProcessing = false;
    }
  }

  /// CameraImage → InputImage 변환
  InputImage? _convertCameraImage(CameraImage image, CameraDescription camera) {
    try {
      // 이미지 회전 계산
      final rotation = _getImageRotation(camera);
      if (rotation == null) return null;

      // 이미지 포맷 확인
      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      if (format == null) return null;

      // 바이트 데이터 결합
      final bytes = Uint8List.fromList(
        image.planes.fold<List<int>>(
          [],
          (List<int> previousValue, element) =>
            previousValue..addAll(element.bytes),
        ),
      );

      // bytesPerRow는 첫 번째 plane에서 가져옴
      final bytesPerRow = image.planes.first.bytesPerRow;

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: bytesPerRow,
        ),
      );
    } catch (e) {
      developer.log('FaceMeshService: 이미지 변환 오류 - $e');
      return null;
    }
  }

  /// 카메라 회전값 계산
  InputImageRotation? _getImageRotation(CameraDescription camera) {
    // iOS에서는 회전이 필요 없음
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return InputImageRotation.rotation0deg;
    }

    // Android 센서 방향에 따른 회전
    final sensorOrientation = camera.sensorOrientation;

    switch (sensorOrientation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return null;
    }
  }

  /// 현재 처리 중인지 확인
  bool get isProcessing => _isProcessing;
}
