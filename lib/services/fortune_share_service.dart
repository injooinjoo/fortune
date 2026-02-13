import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_io/io.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/design_system/tokens/ds_colors.dart';
import '../core/utils/logger.dart';
import '../presentation/widgets/social_share_bottom_sheet.dart';
import 'instagram_share_service.dart';
import 'kakao_share_service.dart';
import 'user_interaction_service.dart';

/// iOS에서 공유 시트 위치를 가져오는 헬퍼 함수
Rect? _getSharePositionOrigin(BuildContext context) {
  if (!kIsWeb && Platform.isIOS) {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null) {
      final position = box.localToGlobal(Offset.zero);
      return Rect.fromLTWH(
        position.dx,
        position.dy,
        box.size.width,
        box.size.height,
      );
    }
    // 폴백: 화면 중앙
    final size = MediaQuery.of(context).size;
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 100,
      height: 100,
    );
  }
  return null;
}

/// 인사이트 결과 공유 서비스
/// - 위젯 캡처
/// - SNS 공유 (카카오톡, 인스타그램 등)
/// - 공유 기록 저장
class FortuneShareService {
  static final FortuneShareService _instance = FortuneShareService._internal();
  factory FortuneShareService() => _instance;
  FortuneShareService._internal();

  final _interactionService = UserInteractionService();
  final _kakaoShareService = KakaoShareService();
  final _instagramShareService = InstagramShareService();

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
    String? fortuneType,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: DSColors.overlay,
      builder: (sheetContext) => SocialShareBottomSheet(
        fortuneTitle: title,
        fortuneContent: content,
        userName: userName,
        previewImage: previewImage,
        onShare: (platform) async {
          await shareToPlaftorm(
            context: sheetContext,
            platform: platform,
            contentId: contentId,
            contentType: contentType,
            title: title,
            content: content,
            userName: userName,
            imageData: previewImage,
            fortuneHistoryId: fortuneHistoryId,
            fortuneType: fortuneType,
          );
        },
      ),
    );
  }

  /// 플랫폼별 공유
  Future<void> shareToPlaftorm({
    required BuildContext context,
    required SharePlatform platform,
    required String contentId,
    required String contentType,
    required String title,
    required String content,
    String? userName,
    Uint8List? imageData,
    String? fortuneHistoryId,
    String? fortuneType,
  }) async {
    try {
      switch (platform) {
        case SharePlatform.kakaoTalk:
          await _shareToKakao(context, imageData, title, content, userName, fortuneType);
          break;
        case SharePlatform.instagram:
          await _shareToInstagram(context, imageData, title, content);
          break;
        case SharePlatform.facebook:
        case SharePlatform.twitter:
        case SharePlatform.whatsapp:
        case SharePlatform.other:
          await _shareGeneric(context, imageData, title, content);
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

  /// 카카오톡 공유 (SDK 직접 연동)
  Future<void> _shareToKakao(
    BuildContext context,
    Uint8List? imageData,
    String title,
    String content,
    String? userName,
    String? fortuneType,
  ) async {
    // iOS용 sharePositionOrigin을 미리 계산 (async 갭 전에)
    final shareOrigin = _getSharePositionOrigin(context);

    // 카카오 SDK 직접 공유 시도
    final success = await _kakaoShareService.shareFortuneResult(
      context: context,
      title: title,
      description: content.length > 200 ? '${content.substring(0, 197)}...' : content,
      imageData: imageData,
      fortuneType: fortuneType,
    );

    // SDK 공유 실패 시 일반 공유로 폴백
    if (!success) {
      Logger.warning('카카오 SDK 공유 실패, 일반 공유로 폴백');
      final shareText = userName != null
          ? '$userName님의 $title\n\n$content\n\n#인사이트 #ZPZG'
          : '$title\n\n$content\n\n#인사이트 #ZPZG';

      if (imageData != null) {
        final tempFile = await _saveImageToTemp(imageData);
        await Share.shareXFiles(
          [XFile(tempFile.path)],
          text: shareText,
          sharePositionOrigin: shareOrigin,
        );
        await tempFile.delete();
      } else {
        await Share.share(
          shareText,
          sharePositionOrigin: shareOrigin,
        );
      }
    }
  }

  /// 인스타그램 공유 (스토리 직접 공유)
  Future<void> _shareToInstagram(
    BuildContext context,
    Uint8List? imageData,
    String title,
    String content,
  ) async {
    // iOS용 sharePositionOrigin을 미리 계산 (async 갭 전에)
    final shareOrigin = _getSharePositionOrigin(context);

    if (imageData == null) {
      await Share.share(
        '$title\n\n$content\n\n#인사이트 #ZPZG',
        sharePositionOrigin: shareOrigin,
      );
      return;
    }

    // 인스타그램 스토리 직접 공유 시도
    final success = await _instagramShareService.shareToStory(
      imageData: imageData,
      topBackgroundColor: '#1A1A1A',
      bottomBackgroundColor: '#1A1A1A',
    );

    // 직접 공유 실패 시 폴백
    if (!success) {
      Logger.warning('인스타그램 스토리 직접 공유 실패, 폴백 사용');
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
          text: '$title\n\n#인사이트 #ZPZG',
          sharePositionOrigin: shareOrigin,
        );
      }

      await tempFile.delete();
    }
  }

  /// 일반 공유
  Future<void> _shareGeneric(
    BuildContext context,
    Uint8List? imageData,
    String title,
    String content,
  ) async {
    // iOS용 sharePositionOrigin을 미리 계산 (async 갭 전에)
    final shareOrigin = _getSharePositionOrigin(context);
    final shareText = '$title\n\n$content\n\n#인사이트 #Fortune';

    if (imageData != null) {
      final tempFile = await _saveImageToTemp(imageData);
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: shareText,
        sharePositionOrigin: shareOrigin,
      );
      await tempFile.delete();
    } else {
      await Share.share(
        shareText,
        sharePositionOrigin: shareOrigin,
      );
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
