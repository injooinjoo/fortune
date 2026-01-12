import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

/// 얼굴 감지 결과 모델
class FaceDetectionResult {
  /// 바운딩 박스 좌표
  final double x;
  final double y;
  final double width;
  final double height;

  /// 감지 신뢰도 (0.0 ~ 1.0)
  final double confidence;

  /// 감지된 얼굴 수
  final int faceCount;

  /// 얼굴 랜드마크 포인트 (눈, 코, 입, 얼굴 윤곽 등)
  final List<Offset>? landmarks;

  const FaceDetectionResult({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.confidence,
    this.faceCount = 1,
    this.landmarks,
  });

  /// 바운딩 박스 Rect 반환
  Rect get boundingBox => Rect.fromLTWH(x, y, width, height);

  /// Map에서 생성 (iOS MethodChannel용)
  factory FaceDetectionResult.fromMap(Map<String, dynamic> map) {
    final boundingBox = map['boundingBox'] as Map<String, dynamic>;

    // landmarks 파싱
    List<Offset>? landmarks;
    if (map['landmarks'] != null) {
      final landmarksList = map['landmarks'] as List;
      landmarks = landmarksList.map((p) {
        final point = p as Map<dynamic, dynamic>;
        return Offset(
          (point['x'] as num).toDouble(),
          (point['y'] as num).toDouble(),
        );
      }).toList();
    }

    return FaceDetectionResult(
      x: (boundingBox['x'] as num).toDouble(),
      y: (boundingBox['y'] as num).toDouble(),
      width: (boundingBox['width'] as num).toDouble(),
      height: (boundingBox['height'] as num).toDouble(),
      confidence: (map['confidence'] as num).toDouble(),
      faceCount: map['faceCount'] as int? ?? 1,
      landmarks: landmarks,
    );
  }

  @override
  String toString() =>
      'FaceDetectionResult(x: $x, y: $y, w: $width, h: $height, confidence: $confidence, landmarks: ${landmarks?.length ?? 0} points)';
}

/// 얼굴 감지 서비스
/// iOS: Apple Vision Framework (VNDetectFaceLandmarksRequest) - 실시간 랜드마크 감지
/// Android: 가이드 모드 (Firebase 호환성 문제로 ML Kit 제거됨)
class FaceDetectionService {
  static const _channel = MethodChannel('com.fortune.fortune/ios');

  /// 싱글톤 인스턴스
  static final FaceDetectionService _instance =
      FaceDetectionService._internal();
  factory FaceDetectionService() => _instance;
  FaceDetectionService._internal();

  bool _isProcessing = false;

  /// 플랫폼에서 얼굴 감지 지원 여부
  Future<bool> isSupported() async {
    if (Platform.isIOS) {
      try {
        final result =
            await _channel.invokeMethod<bool>('isFaceDetectionSupported');
        return result ?? false;
      } catch (e) {
        developer.log('FaceDetectionService: 지원 확인 실패 - $e');
        return false;
      }
    }
    // Android: 가이드 모드 사용 (ML Kit 제거됨)
    return false;
  }

  /// 이미지 데이터에서 얼굴 감지
  /// iOS: Vision Framework (MethodChannel) - 실시간 랜드마크 감지
  /// Android: 가이드 모드 사용 (null 반환)
  Future<FaceDetectionResult?> detectFromImageData(Uint8List imageData) async {
    if (_isProcessing) return null;

    // Android는 가이드 모드 사용 (ML Kit 제거됨)
    if (Platform.isAndroid) {
      return null;
    }

    _isProcessing = true;

    try {
      return await _detectWithVision(imageData);
    } catch (e) {
      developer.log('FaceDetectionService: 감지 오류 - $e');
      return null;
    } finally {
      _isProcessing = false;
    }
  }

  /// iOS Vision Framework를 사용한 얼굴 감지
  Future<FaceDetectionResult?> _detectWithVision(Uint8List imageData) async {
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'detectFace',
      {'imageData': imageData},
    );

    if (result == null) {
      return null;
    }

    final map = Map<String, dynamic>.from(result);
    if (map['detected'] != true) {
      return null;
    }

    return FaceDetectionResult.fromMap(map);
  }

  /// 리소스 정리
  void dispose() {
    // No resources to clean up after ML Kit removal
  }

  /// 현재 처리 중인지 확인
  bool get isProcessing => _isProcessing;

  /// 가이드 모드인지 확인
  /// iOS: 실시간 감지 (false)
  /// Android: 가이드 모드 (true) - ML Kit 제거로 인해
  bool get isGuideMode => Platform.isAndroid;
}
