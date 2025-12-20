import 'dart:async';
import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';  // AGP 8.x compatibility issue
import '../core/utils/logger.dart';
import '../core/services/resilient_service.dart';
import '../core/theme/toss_design_system.dart';
import 'native_platform_service.dart';
import '../presentation/widgets/enhanced_shareable_fortune_card.dart';
import '../presentation/widgets/social_share_bottom_sheet.dart';

/// Provider for screenshot detection service
final screenshotDetectionServiceProvider = Provider<ScreenshotDetectionService>((ref) {
  return ScreenshotDetectionService();
});

/// 강화된 스크린샷 감지 및 공유 서비스
///
/// KAN-77: 스크린샷 감지 연결 안정성 문제 해결
/// - ResilientService 패턴 적용
/// - 네이티브 플랫폼 연결 실패 대응
/// - 공유 기능 오류 처리 강화
/// - 플랫폼별 권한 문제 자동 복구
class ScreenshotDetectionService extends ResilientService {
  @override
  String get serviceName => 'ScreenshotDetectionService';

  StreamSubscription<dynamic>? _screenshotSubscription;
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isListening = false;
  void Function(BuildContext context)? onScreenshotDialogRequested;
  
  /// 강화된 스크린샷 감지 초기화 (ResilientService 패턴)
  Future<void> initialize() async {
    if (_isListening) return;

    // Skip initialization on web
    if (kIsWeb) {
      Logger.info('Screenshot detection service skipped on web');
      return;
    }

    await safeExecute(
      () async {
        // Listen to native screenshot events
        _screenshotSubscription = NativePlatformService.nativeEventStream.listen((event) {
          if (event is Map && event['type'] == 'screenshot_detected') {
            _handleScreenshotDetected(event['data']);
          }
        });

        // Request native platform to start screenshot detection
        if (Platform.isAndroid) {
          await NativePlatformService.android.startScreenshotDetection();
        } else if (Platform.isIOS) {
          await NativePlatformService.ios.startScreenshotDetection();
        }

        _isListening = true;
        Logger.info('Screenshot detection service initialized');
      },
      '스크린샷 감지 서비스 초기화',
      '스크린샷 감지 비활성화 (공유 기능은 정상 작동)'
    );
  }
  
  /// Stop screenshot detection
  void dispose() {
    _screenshotSubscription?.cancel();
    _isListening = false;
    
    // Skip platform-specific cleanup on web
    if (kIsWeb) return;
    
    if (Platform.isAndroid) {
      NativePlatformService.android.stopScreenshotDetection();
    } else if (Platform.isIOS) {
      NativePlatformService.ios.stopScreenshotDetection();
    }
  }
  
  /// Handle screenshot detected event
  void _handleScreenshotDetected(Map<String, dynamic>? data) {
    Logger.info('Screenshot detected');
    // Notify UI through callback if provided
    if (onScreenshotDialogRequested != null && data?['context'] is BuildContext) {
      onScreenshotDialogRequested!(data!['context'] as BuildContext);
    }
  }
  
  /// Show screenshot sharing dialog
  Future<void> showScreenshotSharingDialog({
    required BuildContext context,
    required String fortuneType,
    required String fortuneTitle,
    required String fortuneContent,
    String? userName,
    Map<String, dynamic>? additionalInfo}) async {
    // First capture preview image
    final previewImage = await _captureFortuneImage(
      fortuneType: fortuneType,
      title: fortuneTitle,
      content: fortuneContent,
      userName: userName,
      additionalInfo: additionalInfo,
      template: ShareCardTemplate.modern);

    if (!context.mounted) return;

    // Show bottom sheet
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: TossDesignSystem.transparent,
      builder: (context) => SocialShareBottomSheet(
        fortuneTitle: fortuneTitle,
        fortuneContent: fortuneContent,
        userName: userName,
        previewImage: previewImage,
        onShare: (platform) async {
          await _handlePlatformShare(
            platform: platform,
            fortuneType: fortuneType,
            fortuneTitle: fortuneTitle,
            fortuneContent: fortuneContent,
            userName: userName,
            additionalInfo: additionalInfo,
            context: context);
        }));
  }

  /// 강화된 운세 이미지 캡처 (ResilientService 패턴)
  Future<Uint8List?> _captureFortuneImage({
    required String fortuneType,
    required String title,
    required String content,
    String? userName,
    Map<String, dynamic>? additionalInfo,
    required ShareCardTemplate template}) async {
    return await safeExecuteWithNull(
      () async {
        final image = await _screenshotController.captureFromWidget(
          EnhancedShareableFortuneCard(
            fortuneType: fortuneType,
            title: title,
            content: content,
            userName: userName,
            date: DateTime.now(),
            additionalInfo: additionalInfo,
            template: template),
          delay: const Duration(milliseconds: 100),
          pixelRatio: 3.0);
        return image;
      },
      '운세 이미지 캡처: $fortuneType',
      '이미지 캡처 실패, 텍스트로 공유'
    );
  }

  /// Handle platform-specific sharing
  Future<void> _handlePlatformShare({
    required SharePlatform platform,
    required String fortuneType,
    required String fortuneTitle,
    required String fortuneContent,
    String? userName,
    Map<String, dynamic>? additionalInfo,
    required BuildContext context}) async {
    try {
      // Show loading
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator()));
      }

      ShareCardTemplate template = ShareCardTemplate.modern;
      if (platform == SharePlatform.instagram) {
        template = ShareCardTemplate.instagram;
      }

      // Capture image with appropriate template
      final image = await _captureFortuneImage(
        fortuneType: fortuneType,
        title: fortuneTitle,
        content: fortuneContent,
        userName: userName,
        additionalInfo: additionalInfo,
        template: template);

      if (image == null) {
        throw Exception('Failed to capture image');
      }
      // Save to temporary directory (skip on web,
      String? imagePath;
      File? imageFile;
      
      if (!kIsWeb) {
        final directory = await getTemporaryDirectory();
        imagePath = '${directory.path}/fortune_${DateTime.now().millisecondsSinceEpoch}.png';
        imageFile = File(imagePath);
        await imageFile.writeAsBytes(image);
      }

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Handle platform-specific sharing
      switch (platform) {
        case SharePlatform.kakaoTalk:
          if (imagePath != null) {
            await _shareToKakaoTalk(imagePath, fortuneTitle, fortuneContent);
          } else {
            // On web, just copy text
            if (context.mounted) {
              await _copyToClipboard(fortuneTitle, fortuneContent, context);
            }
          }
          break;
        case SharePlatform.instagram:
          if (imagePath != null) {
            await _shareToInstagram(imagePath);
          } else {
            // On web, just copy text
            if (context.mounted) {
              await _copyToClipboard(fortuneTitle, fortuneContent, context);
            }
          }
          break;
        case SharePlatform.facebook:
          if (imagePath != null) {
            await _shareToFacebook(imagePath, fortuneTitle);
          } else {
            // On web, just copy text
            if (context.mounted) {
              await _copyToClipboard(fortuneTitle, fortuneContent, context);
            }
          }
          break;
        case SharePlatform.twitter:
          if (imagePath != null) {
            await _shareToTwitter(imagePath, fortuneTitle);
          } else {
            // On web, just copy text
            if (context.mounted) {
              await _copyToClipboard(fortuneTitle, fortuneContent, context);
            }
          }
          break;
        case SharePlatform.whatsapp:
          if (imagePath != null) {
            await _shareToWhatsApp(imagePath, fortuneTitle);
          } else {
            // On web, just copy text
            if (context.mounted) {
              await _copyToClipboard(fortuneTitle, fortuneContent, context);
            }
          }
          break;
        case SharePlatform.gallery:
          if (!kIsWeb && context.mounted) {
            await _saveToGallery(image, context);
          } else if (context.mounted) {
            // On web, just copy text
            await _copyToClipboard(fortuneTitle, fortuneContent, context);
          }
          break;
        case SharePlatform.copy:
          if (context.mounted) {
            await _copyToClipboard(fortuneTitle, fortuneContent, context);
          }
          break;
        default:
          // Use system share dialog
          if (imagePath != null) {
            await Share.shareXFiles(
              [XFile(imagePath)],
              text: '$fortuneTitle\n\nFortune 신점 앱에서 확인하세요!'
            );
          } else {
            // On web, just share text
            await Share.share('$fortuneTitle\n\nFortune 신점 앱에서 확인하세요!');
          }
      }

      // Clean up temporary file
      if (imageFile != null) {
        Future.delayed(const Duration(seconds: 5), () {
          if (imageFile?.existsSync() ?? false) {
            imageFile?.deleteSync();
          }
        });
      }
    } catch (e) {
      Logger.warning('[ScreenshotService] 운세 공유 실패 (사용자에게 알림): $e');
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('운세 공유 중 오류가 발생했습니다')));
      }
    }
  }

  /// 강화된 카카오톡 공유 (ResilientService 패턴)
  Future<void> _shareToKakaoTalk(String imagePath, String title, String content) async {
    await safeExecute(
      () async {
        // KakaoTalk sharing would require Kakao SDK integration
        // For now, use system share with pre-filled text
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: '🌟 $title\n\n$content\n\n#운세 #Fortune신점 #오늘의운세'
        );
      },
      '카카오톡 공유: $title',
      '카카오톡 공유 실패, 대체 방법 사용'
    );
  }

  /// 강화된 인스타그램 공유 (ResilientService 패턴)
  Future<void> _shareToInstagram(String imagePath) async {
    await safeExecute(
      () async {
        // Instagram Stories sharing
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: '나만의 운세를 확인해보세요! 🔮'
        );
      },
      '인스타그램 공유',
      '인스타그램 공유 실패, 대체 방법 사용'
    );
  }

  /// 강화된 페이스북 공유 (ResilientService 패턴)
  Future<void> _shareToFacebook(String imagePath, String title) async {
    await safeExecute(
      () async {
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: '🌟 $title - Fortune 신점에서 확인한 오늘의 운세'
        );
      },
      '페이스북 공유: $title',
      '페이스북 공유 실패, 대체 방법 사용'
    );
  }

  /// 강화된 트위터 공유 (ResilientService 패턴)
  Future<void> _shareToTwitter(String imagePath, String title) async {
    await safeExecute(
      () async {
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: '🌟 $title\n\n#운세 #Fortune신점 #오늘의운세 #신점운세'
        );
      },
      '트위터 공유: $title',
      '트위터 공유 실패, 대체 방법 사용'
    );
  }

  /// 강화된 WhatsApp 공유 (ResilientService 패턴)
  Future<void> _shareToWhatsApp(String imagePath, String title) async {
    await safeExecute(
      () async {
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: '🌟 $title\n\nFortune 신점에서 확인한 오늘의 운세입니다!'
        );
      },
      'WhatsApp 공유: $title',
      'WhatsApp 공유 실패, 대체 방법 사용'
    );
  }

  /// 강화된 갤러리 저장 (ResilientService 패턴)
  Future<void> _saveToGallery(Uint8List image, BuildContext context) async {
    await safeExecute(
      () async {
        // Temporarily disabled due to AGP 8.x compatibility issue
        // final result = await ImageGallerySaver.saveImage(
        //   image,
        //   quality: 100,
        //   name: 'fortune_${DateTime.now().millisecondsSinceEpoch}');

        // Temporary workaround: Save to app's document directory
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = '${directory.path}/fortune_${DateTime.now().millisecondsSinceEpoch}.png';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(image);
        final result = {'isSuccess': true};  // Mock success result

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['isSuccess'] == true
                  ? '이미지가 저장되었습니다'
                  : '저장 중 오류가 발생했습니다'),
              backgroundColor: result['isSuccess'] == true ? TossDesignSystem.gray600 : TossDesignSystem.gray600));
        }
      },
      '갤러리 저장',
      '갤러리 저장 실패, 문서 폴더에 저장'
    );
  }

  /// 강화된 클립보드 복사 (ResilientService 패턴)
  Future<void> _copyToClipboard(String title, String content, BuildContext context) async {
    await safeExecute(
      () async {
        await Clipboard.setData(ClipboardData(text: '$title\n\n$content'));

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('운세가 클립보드에 복사되었습니다'),
              backgroundColor: TossDesignSystem.gray600));
        }
      },
      '클립보드 복사: $title',
      '클립보드 복사 실패, 권한 확인 필요'
    );
  }
  
  /// Capture and share fortune with custom styling (legacy method for compatibility,
  Future<void> captureAndShareFortune({
    required GlobalKey captureKey,
    required String fortuneTitle,
    required String fortuneContent,
    String? userName,
    BuildContext? context}) async {
    if (context != null && context.mounted) {
      await showScreenshotSharingDialog(
        context: context,
        fortuneType: 'daily',
        fortuneTitle: fortuneTitle,
        fortuneContent: fortuneContent,
        userName: userName);
    }
  }
  /// Save fortune image to gallery (legacy method for compatibility,
  Future<bool> saveFortuneToGallery({
    required GlobalKey captureKey,
    required String fortuneTitle,
    required String fortuneContent,
    String? userName,
    BuildContext? context}) async {
    try {
      final image = await _captureFortuneImage(
        fortuneType: 'daily',
        title: fortuneTitle,
        content: fortuneContent,
        userName: userName,
        template: ShareCardTemplate.modern);
      
      if (image == null) return false;
      
      // Temporarily disabled due to AGP 8.x compatibility issue
      // final result = await ImageGallerySaver.saveImage(
      //   image,
      //   quality: 100,
      //   name: 'fortune_${DateTime.now().millisecondsSinceEpoch}');
      // return result['isSuccess'] ?? false;
      
      // Temporary workaround: Save to app's document directory
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/fortune_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);
      return true;
    } catch (e) {
      Logger.warning('[ScreenshotService] 운세 갤러리 저장 실패 (문서 폴더로 저장): $e');
      return false;
    }
  }
}

/// Extension methods for Android-specific functionality with ResilientService pattern
extension AndroidScreenshotDetection on Android {
  /// 강화된 Android 스크린샷 감지 시작 (ResilientService 패턴)
  Future<void> startScreenshotDetection() async {
    final tempService = _TempResilientService();
    await tempService.safeExecute(
      () async {
        await NativePlatformService.androidChannel.invokeMethod('startScreenshotDetection');
        Logger.info('Android screenshot detection started');
      },
      'Android 스크린샷 감지 시작',
      'Android 스크린샷 감지 비활성화 (선택적 기능)'
    );
  }

  /// 강화된 Android 스크린샷 감지 중지 (ResilientService 패턴)
  Future<void> stopScreenshotDetection() async {
    final tempService = _TempResilientService();
    await tempService.safeExecute(
      () async {
        await NativePlatformService.androidChannel.invokeMethod('stopScreenshotDetection');
        Logger.info('Android screenshot detection stopped');
      },
      'Android 스크린샷 감지 중지',
      'Android 스크린샷 감지 중지 대기 (무시)'
    );
  }
}

/// Extension methods for iOS-specific functionality with ResilientService pattern
extension IOSScreenshotDetection on iOS {
  /// 강화된 iOS 스크린샷 감지 시작 (ResilientService 패턴)
  Future<void> startScreenshotDetection() async {
    final tempService = _TempResilientService();
    await tempService.safeExecute(
      () async {
        await NativePlatformService.iosChannel.invokeMethod('startScreenshotDetection');
        Logger.info('iOS screenshot detection started');
      },
      'iOS 스크린샷 감지 시작',
      'iOS 스크린샷 감지 비활성화 (선택적 기능)'
    );
  }

  /// 강화된 iOS 스크린샷 감지 중지 (ResilientService 패턴)
  Future<void> stopScreenshotDetection() async {
    final tempService = _TempResilientService();
    await tempService.safeExecute(
      () async {
        await NativePlatformService.iosChannel.invokeMethod('stopScreenshotDetection');
        Logger.info('iOS screenshot detection stopped');
      },
      'iOS 스크린샷 감지 중지',
      'iOS 스크린샷 감지 중지 대기 (무시)'
    );
  }
}

/// Static 메서드에서 ResilientService 패턴 사용을 위한 임시 클래스
class _TempResilientService extends ResilientService {
  @override
  String get serviceName => 'TempScreenshotResilientService';
}