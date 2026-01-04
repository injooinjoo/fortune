import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_io/io.dart';

import '../core/design_system/tokens/ds_colors.dart';
import '../presentation/widgets/social_share_bottom_sheet.dart';
import 'user_interaction_service.dart';

/// 인사이트 결과 공유 서비스
/// - 위젯 캡처
/// - SNS 공유 (카카오톡, 인스타그램 등)
/// - 공유 기록 저장
class FortuneShareService {
  static final FortuneShareService _instance = FortuneShareService._internal();
  factory FortuneShareService() => _instance;
  FortuneShareService._internal();

  final _interactionService = UserInteractionService();

  /// 위젯을 이미지로 캡처
  Future<Uint8List?> captureWidget(GlobalKey key) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('[FortuneShareService] captureWidget error: $e');
      return null;
    }
  }

  /// 공유 바텀시트 표시
  Future<void> showShareSheet({
    required BuildContext context,
    required String contentId,
    required String contentType,
    required String title,
    required String content,
    String? userName,
    Uint8List? previewImage,
    String? fortuneHistoryId,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: DSColors.overlay,
      builder: (context) => SocialShareBottomSheet(
        fortuneTitle: title,
        fortuneContent: content,
        userName: userName,
        previewImage: previewImage,
        onShare: (platform) async {
          await shareToPlaftorm(
            platform: platform,
            contentId: contentId,
            contentType: contentType,
            title: title,
            content: content,
            userName: userName,
            imageData: previewImage,
            fortuneHistoryId: fortuneHistoryId,
          );
        },
      ),
    );
  }

  /// 플랫폼별 공유
  Future<void> shareToPlaftorm({
    required SharePlatform platform,
    required String contentId,
    required String contentType,
    required String title,
    required String content,
    String? userName,
    Uint8List? imageData,
    String? fortuneHistoryId,
  }) async {
    try {
      switch (platform) {
        case SharePlatform.kakaoTalk:
          await _shareToKakao(imageData, title, content, userName);
          break;
        case SharePlatform.instagram:
          await _shareToInstagram(imageData, title, content);
          break;
        case SharePlatform.facebook:
        case SharePlatform.twitter:
        case SharePlatform.whatsapp:
        case SharePlatform.other:
          await _shareGeneric(imageData, title, content);
          break;
        case SharePlatform.gallery:
          if (imageData != null) {
            await _saveToGallery(imageData);
          }
          break;
        case SharePlatform.copy:
          // 텍스트 복사는 SocialShareBottomSheet에서 처리
          break;
      }

      // 공유 기록 저장
      await _interactionService.recordShare(
        contentKey: contentId, // contentId를 contentKey로 사용
        contentType: contentType,
        platform: platform.name,
      );
    } catch (e) {
      debugPrint('[FortuneShareService] shareToPlaftorm error: $e');
      rethrow;
    }
  }

  /// 카카오톡 공유
  Future<void> _shareToKakao(
    Uint8List? imageData,
    String title,
    String content,
    String? userName,
  ) async {
    final shareText = userName != null
        ? '$userName님의 $title\n\n$content\n\n#인사이트 #Fortune'
        : '$title\n\n$content\n\n#인사이트 #Fortune';

    if (imageData != null) {
      final tempFile = await _saveImageToTemp(imageData);
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: shareText,
      );
      await tempFile.delete();
    } else {
      await Share.share(shareText);
    }
  }

  /// 인스타그램 공유
  Future<void> _shareToInstagram(
    Uint8List? imageData,
    String title,
    String content,
  ) async {
    if (imageData == null) {
      await Share.share('$title\n\n$content\n\n#인사이트 #Fortune');
      return;
    }

    final tempFile = await _saveImageToTemp(imageData);

    if (Platform.isIOS) {
      // iOS: 갤러리 저장 후 인스타 열기
      await _saveToGallery(imageData);
      final url = Uri.parse('instagram://library');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    } else {
      // Android: 직접 공유
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: '$title\n\n#인사이트 #Fortune',
      );
    }

    await tempFile.delete();
  }

  /// 일반 공유
  Future<void> _shareGeneric(
    Uint8List? imageData,
    String title,
    String content,
  ) async {
    final shareText = '$title\n\n$content\n\n#인사이트 #Fortune';

    if (imageData != null) {
      final tempFile = await _saveImageToTemp(imageData);
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: shareText,
      );
      await tempFile.delete();
    } else {
      await Share.share(shareText);
    }
  }

  /// 갤러리 저장
  Future<void> _saveToGallery(Uint8List imageData) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/fortune_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageData);
      debugPrint('[FortuneShareService] Saved to: $imagePath');
    } catch (e) {
      debugPrint('[FortuneShareService] saveToGallery error: $e');
      rethrow;
    }
  }

  /// 임시 파일로 이미지 저장
  Future<File> _saveImageToTemp(Uint8List imageData) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/fortune_${DateTime.now().millisecondsSinceEpoch}.png');
    await tempFile.writeAsBytes(imageData);
    return tempFile;
  }
}
