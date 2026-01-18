// face_detection_service_stub.dart
// 시뮬레이터용 스텁 - mediapipe 없이 동작

import 'dart:typed_data';
import 'dart:ui';

/// MediaPipe 타입 스텁 (시뮬레이터용)
class FaceMeshLandmark {
  final double x;
  final double y;
  final double z;
  const FaceMeshLandmark({required this.x, required this.y, required this.z});
}

class MpFaceMeshTriangle {
  final int a;
  final int b;
  final int c;
  const MpFaceMeshTriangle({required this.a, required this.b, required this.c});
}

/// 얼굴 감지 결과 모델 (MediaPipe 468 랜드마크 기반)
class FaceDetectionResult {
  final double x;
  final double y;
  final double width;
  final double height;
  final double confidence;
  final int faceCount;
  final List<Offset>? landmarks;
  final List<FaceMeshLandmark>? landmarks3D;
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

  Rect get boundingBox => Rect.fromLTWH(x, y, width, height);

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

/// 시뮬레이터용 Face Detection Service (MediaPipe 없이)
class FaceDetectionService {
  static final FaceDetectionService _instance = FaceDetectionService._internal();
  factory FaceDetectionService() => _instance;
  FaceDetectionService._internal();

  bool _isInitialized = false;

  Future<void> initialize() async {
    _isInitialized = true;
  }

  Future<bool> isSupported() async => false;
  bool get isMeshAvailable => false;
  bool get isSimulator => true;
  bool get isProcessing => false;
  bool get isInitialized => _isInitialized;
  bool get isGuideMode => false;

  FaceDetectionResult? detectFromBGRA({
    required Uint8List bytes,
    required int width,
    required int height,
    int rotationDegrees = 0,
    bool mirrorHorizontal = false,
  }) => null;

  FaceDetectionResult? detectFromNV21({
    required Uint8List yPlane,
    required Uint8List vuPlane,
    required int width,
    required int height,
    int? yBytesPerRow,
    int? vuBytesPerRow,
    int rotationDegrees = 0,
    bool mirrorHorizontal = false,
  }) => null;

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
  }) => null;

  void dispose() {
    _isInitialized = false;
  }
}
