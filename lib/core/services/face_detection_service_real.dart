// face_detection_service_real.dart
// 실제 기기용 - MediaPipe 사용

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:developer' as developer;
import 'package:mediapipe_face_mesh/mediapipe_face_mesh.dart';

// Re-export MediaPipe types
export 'package:mediapipe_face_mesh/mediapipe_face_mesh.dart'
    show FaceMeshLandmark, MpFaceMeshTriangle;

/// 얼굴 감지 결과 모델 (MediaPipe 468 랜드마크 기반)
class FaceDetectionResult {
  /// 바운딩 박스 좌표 (정규화된 값 0.0 ~ 1.0)
  final double x;
  final double y;
  final double width;
  final double height;

  /// 감지 신뢰도 (0.0 ~ 1.0)
  final double confidence;

  /// 감지된 얼굴 수
  final int faceCount;

  /// 468개 얼굴 랜드마크 포인트 (정규화된 좌표)
  final List<Offset>? landmarks;

  /// 3D 랜드마크 (x, y, z)
  final List<FaceMeshLandmark>? landmarks3D;

  /// 메쉬 삼각형 인덱스
  final List<MpFaceMeshTriangle>? triangles;

  const FaceDetectionResult({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.confidence,
    this.faceCount = 1,
    this.landmarks,
    this.landmarks3D,
    this.triangles,
  });

  /// 바운딩 박스 Rect 반환 (정규화된 좌표)
  Rect get boundingBox => Rect.fromLTWH(x, y, width, height);

  /// MediaPipe FaceMeshResult에서 생성
  factory FaceDetectionResult.fromMediaPipe(FaceMeshResult result) {
    // 468 랜드마크에서 2D 좌표 추출
    final landmarks2D = result.landmarks
        .map((lm) => Offset(lm.x, lm.y))
        .toList();

    // 바운딩 박스 계산 (랜드마크에서)
    double minX = 1.0, minY = 1.0, maxX = 0.0, maxY = 0.0;
    for (final lm in result.landmarks) {
      if (lm.x < minX) minX = lm.x;
      if (lm.y < minY) minY = lm.y;
      if (lm.x > maxX) maxX = lm.x;
      if (lm.y > maxY) maxY = lm.y;
    }

    return FaceDetectionResult(
      x: minX,
      y: minY,
      width: maxX - minX,
      height: maxY - minY,
      confidence: result.score,
      faceCount: 1,
      landmarks: landmarks2D,
      landmarks3D: result.landmarks,
      triangles: result.triangles,
    );
  }

  /// 주요 랜드마크 인덱스 (MediaPipe Face Mesh 기준)
  static const int noseTip = 1;
  static const int leftEyeInner = 133;
  static const int leftEyeOuter = 33;
  static const int rightEyeInner = 362;
  static const int rightEyeOuter = 263;
  static const int leftEyeCenter = 159;
  static const int rightEyeCenter = 386;
  static const int mouthLeft = 61;
  static const int mouthRight = 291;
  static const int mouthTop = 13;
  static const int mouthBottom = 14;
  static const int leftCheek = 50;
  static const int rightCheek = 280;
  static const int chinCenter = 152;
  static const int foreheadCenter = 10;

  @override
  String toString() =>
      'FaceDetectionResult(confidence: ${confidence.toStringAsFixed(2)}, landmarks: ${landmarks?.length ?? 0} points)';
}

/// MediaPipe Face Mesh 기반 얼굴 감지 서비스
/// iOS & Android: MediaPipe Face Mesh (468 랜드마크, 실시간 감지)
/// 시뮬레이터에서는 MediaPipe 미지원 (카메라만 표시)
class FaceDetectionService {
  /// 싱글톤 인스턴스
  static final FaceDetectionService _instance =
      FaceDetectionService._internal();
  factory FaceDetectionService() => _instance;
  FaceDetectionService._internal();

  FaceMeshProcessor? _processor;
  bool _isInitialized = false;
  bool _isProcessing = false;
  bool _isSimulator = false;
  bool _isMeshAvailable = false;

  /// 시뮬레이터 감지
  bool _checkIsSimulator() {
    // iOS 시뮬레이터 감지
    if (Platform.isIOS) {
      final env = Platform.environment;
      return env.containsKey('SIMULATOR_DEVICE_NAME') ||
          env.containsKey('SIMULATOR_HOST_HOME');
    }
    // Android 에뮬레이터 감지
    if (Platform.isAndroid) {
      final env = Platform.environment;
      return env.containsKey('ANDROID_EMULATOR') ||
          env['ANDROID_SDK_ROOT']?.contains('emulator') == true;
    }
    return false;
  }

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isSimulator = _checkIsSimulator();

    // 시뮬레이터에서는 MediaPipe 초기화 스킵
    if (_isSimulator) {
      developer.log('📱 시뮬레이터 감지: Face Mesh 비활성화 (카메라만 표시)');
      _isInitialized = true;
      _isMeshAvailable = false;
      return;
    }

    try {
      developer.log('🚀 MediaPipe: 초기화 시작');

      // iOS: xnnpack (Metal 대신), Android: gpuV2
      _processor = await FaceMeshProcessor.create(
        delegate: Platform.isIOS
            ? FaceMeshDelegate.xnnpack
            : FaceMeshDelegate.gpuV2,
        threads: 2,
        minDetectionConfidence: 0.5,
        minTrackingConfidence: 0.5,
        enableSmoothing: true,
        enableRoiTracking: true,
      );

      _isInitialized = true;
      _isMeshAvailable = true;
      developer.log('✅ MediaPipe: 초기화 완료');
    } catch (e) {
      developer.log('❌ MediaPipe: 초기화 실패 - $e');

      // GPU 실패 시 CPU 폴백
      try {
        developer.log('🔄 MediaPipe: CPU 폴백 시도');
        _processor = await FaceMeshProcessor.create(
          delegate: FaceMeshDelegate.cpu,
          threads: 2,
          minDetectionConfidence: 0.5,
          minTrackingConfidence: 0.5,
          enableSmoothing: true,
          enableRoiTracking: true,
        );
        _isInitialized = true;
        _isMeshAvailable = true;
        developer.log('✅ MediaPipe: CPU 폴백 성공');
      } catch (e2) {
        developer.log('❌ MediaPipe: CPU 폴백도 실패 - $e2 (시뮬레이터일 수 있음)');
        // 실패해도 초기화 완료 처리 (카메라만 사용)
        _isInitialized = true;
        _isMeshAvailable = false;
      }
    }
  }

  /// 플랫폼에서 얼굴 감지 지원 여부
  Future<bool> isSupported() async {
    return _isMeshAvailable;
  }

  /// Face Mesh 사용 가능 여부
  bool get isMeshAvailable => _isMeshAvailable;

  /// 시뮬레이터 여부
  bool get isSimulator => _isSimulator;

  /// iOS용: BGRA 이미지 데이터에서 얼굴 감지
  FaceDetectionResult? detectFromBGRA({
    required Uint8List bytes,
    required int width,
    required int height,
    int rotationDegrees = 0,
    bool mirrorHorizontal = false,
  }) {
    if (!_isInitialized || _isProcessing || _processor == null || !_isMeshAvailable) {
      return null;
    }

    _isProcessing = true;

    try {
      developer.log('🔍 MediaPipe: BGRA 처리 시작 (${width}x$height)');

      final image = FaceMeshImage(
        pixels: bytes,
        width: width,
        height: height,
        pixelFormat: FaceMeshPixelFormat.bgra,
      );

      final result = _processor!.process(
        image,
        boxScale: 1.5,
        boxMakeSquare: true,
        rotationDegrees: rotationDegrees,
        mirrorHorizontal: mirrorHorizontal,
      );

      if (result.landmarks.isEmpty) {
        developer.log('⚪ MediaPipe: 얼굴 미감지');
        return null;
      }

      developer.log('✅ MediaPipe: 얼굴 감지됨 (${result.landmarks.length} landmarks, score: ${result.score})');
      return FaceDetectionResult.fromMediaPipe(result);
    } catch (e) {
      developer.log('❌ MediaPipe: 감지 오류 - $e');
      return null;
    } finally {
      _isProcessing = false;
    }
  }

  /// Android용: NV21 이미지 데이터에서 얼굴 감지
  FaceDetectionResult? detectFromNV21({
    required Uint8List yPlane,
    required Uint8List vuPlane,
    required int width,
    required int height,
    int? yBytesPerRow,
    int? vuBytesPerRow,
    int rotationDegrees = 0,
    bool mirrorHorizontal = false,
  }) {
    if (!_isInitialized || _isProcessing || _processor == null || !_isMeshAvailable) {
      return null;
    }

    _isProcessing = true;

    try {
      developer.log('🔍 MediaPipe: NV21 처리 시작 (${width}x$height)');

      final image = FaceMeshNv21Image(
        yPlane: yPlane,
        vuPlane: vuPlane,
        width: width,
        height: height,
        yBytesPerRow: yBytesPerRow,
        vuBytesPerRow: vuBytesPerRow,
      );

      final result = _processor!.processNv21(
        image,
        boxScale: 1.5,
        boxMakeSquare: true,
        rotationDegrees: rotationDegrees,
        mirrorHorizontal: mirrorHorizontal,
      );

      if (result.landmarks.isEmpty) {
        developer.log('⚪ MediaPipe: 얼굴 미감지');
        return null;
      }

      developer.log('✅ MediaPipe: 얼굴 감지됨 (${result.landmarks.length} landmarks, score: ${result.score})');
      return FaceDetectionResult.fromMediaPipe(result);
    } catch (e) {
      developer.log('❌ MediaPipe: 감지 오류 - $e');
      return null;
    } finally {
      _isProcessing = false;
    }
  }

  /// YUV420용: 카메라 스트림에서 얼굴 감지 (범용)
  FaceDetectionResult? detectFromYUV420({
    required Uint8List yPlane,
    required Uint8List? uPlane,
    required Uint8List? vPlane,
    required int width,
    required int height,
    required int yRowStride,
    required int uvRowStride,
    required int uvPixelStride,
    int rotationDegrees = 0,
    bool mirrorHorizontal = false,
  }) {
    if (!_isInitialized || _isProcessing || _processor == null || !_isMeshAvailable) {
      return null;
    }

    _isProcessing = true;

    try {
      // YUV420을 NV21 형식으로 변환 (VU 인터리브)
      final vuPlane = _convertYUV420toVUPlane(
        uPlane: uPlane,
        vPlane: vPlane,
        width: width,
        height: height,
        uvRowStride: uvRowStride,
        uvPixelStride: uvPixelStride,
      );

      final image = FaceMeshNv21Image(
        yPlane: yPlane,
        vuPlane: vuPlane,
        width: width,
        height: height,
        yBytesPerRow: yRowStride,
        vuBytesPerRow: width,
      );

      final result = _processor!.processNv21(
        image,
        boxScale: 1.5,
        boxMakeSquare: true,
        rotationDegrees: rotationDegrees,
        mirrorHorizontal: mirrorHorizontal,
      );

      if (result.landmarks.isEmpty) {
        return null;
      }

      return FaceDetectionResult.fromMediaPipe(result);
    } catch (e) {
      developer.log('❌ MediaPipe: YUV420 감지 오류 - $e');
      return null;
    } finally {
      _isProcessing = false;
    }
  }

  /// YUV420 U/V 평면을 NV21 VU 인터리브 형식으로 변환
  Uint8List _convertYUV420toVUPlane({
    required Uint8List? uPlane,
    required Uint8List? vPlane,
    required int width,
    required int height,
    required int uvRowStride,
    required int uvPixelStride,
  }) {
    final uvHeight = height ~/ 2;
    final uvWidth = width ~/ 2;
    final vuPlane = Uint8List(width * uvHeight);

    if (uPlane == null || vPlane == null) {
      return vuPlane;
    }

    int vuIndex = 0;
    for (int y = 0; y < uvHeight; y++) {
      for (int x = 0; x < uvWidth; x++) {
        final uvOffset = y * uvRowStride + x * uvPixelStride;
        vuPlane[vuIndex++] = vPlane[uvOffset]; // V first
        vuPlane[vuIndex++] = uPlane[uvOffset]; // then U
      }
    }

    return vuPlane;
  }

  /// 리소스 정리
  void dispose() {
    _processor?.close();
    _processor = null;
    _isInitialized = false;
    developer.log('🧹 MediaPipe: 리소스 정리 완료');
  }

  /// 현재 처리 중인지 확인
  bool get isProcessing => _isProcessing;

  /// 초기화 완료 여부
  bool get isInitialized => _isInitialized;

  /// 가이드 모드인지 확인 (MediaPipe는 실시간 지원하므로 항상 false)
  bool get isGuideMode => false;
}
