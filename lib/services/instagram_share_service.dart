import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:social_share_plugin/social_share_plugin.dart' as social;
import 'package:url_launcher/url_launcher.dart';

import '../core/services/resilient_service.dart';
import '../core/utils/logger.dart';

/// 인스타그램 공유 서비스
/// 인스타그램 피드 및 스토리에 이미지 공유 기능 구현
class InstagramShareService extends ResilientService {
  static final InstagramShareService _instance =
      InstagramShareService._internal();
  factory InstagramShareService() => _instance;
  InstagramShareService._internal();

  @override
  String get serviceName => 'InstagramShareService';

  /// 인스타그램 설치 여부 확인
  Future<bool> isInstagramAvailable() async {
    if (kIsWeb) return false;

    return await safeExecuteWithFallback<bool>(
      () async {
        final uri = Uri.parse('instagram://');
        return await canLaunchUrl(uri);
      },
      false,
      '인스타그램 설치 확인',
      '인스타그램 설치 여부 확인 실패',
    );
  }

  /// 인스타그램 스토리/피드에 이미지 공유 (Instagram 앱 직접 열림)
  ///
  /// [imageData] 공유할 이미지 데이터 (Uint8List)
  /// [topBackgroundColor] 스토리 상단 배경색 (미사용, 호환성 유지)
  /// [bottomBackgroundColor] 스토리 하단 배경색 (미사용, 호환성 유지)
  Future<bool> shareToStory({
    required Uint8List imageData,
    String? topBackgroundColor,
    String? bottomBackgroundColor,
  }) async {
    return await safeExecuteWithFallback<bool>(
      () async {
        // 인스타그램 설치 확인
        final isAvailable = await isInstagramAvailable();
        if (!isAvailable) {
          Logger.warning('인스타그램이 설치되어 있지 않습니다');
          return false;
        }

        // 임시 파일로 저장
        final tempDir = await getTemporaryDirectory();
        final tempFile = File(
            '${tempDir.path}/instagram_story_${DateTime.now().millisecondsSinceEpoch}.png');
        await tempFile.writeAsBytes(imageData);

        try {
          // social_share_plugin으로 Instagram 앱 직접 열기
          // iOS, Android 모두 Instagram 앱이 이미지와 함께 열림
          await social.shareToFeedInstagram(path: tempFile.path);

          Logger.info('인스타그램 공유 성공 - 앱이 열림');
          return true;
        } finally {
          // 임시 파일 삭제 (약간의 딜레이 후)
          Future.delayed(const Duration(seconds: 5), () async {
            if (await tempFile.exists()) {
              await tempFile.delete();
            }
          });
        }
      },
      false,
      '인스타그램 스토리 공유',
      '인스타그램 스토리 공유 실패',
    );
  }

  /// 인스타그램 피드로 이미지 공유
  ///
  /// [imageData] 공유할 이미지 데이터 (Uint8List)
  Future<bool> shareToFeed({
    required Uint8List imageData,
  }) async {
    return await safeExecuteWithFallback<bool>(
      () async {
        // 인스타그램 설치 확인
        final isAvailable = await isInstagramAvailable();
        if (!isAvailable) {
          Logger.warning('인스타그램이 설치되어 있지 않습니다');
          return false;
        }

        // 임시 파일로 저장
        final tempDir = await getTemporaryDirectory();
        final tempFile = File(
            '${tempDir.path}/instagram_feed_${DateTime.now().millisecondsSinceEpoch}.png');
        await tempFile.writeAsBytes(imageData);

        try {
          // social_share_plugin을 사용하여 인스타그램에 공유
          await social.shareToFeedInstagram(path: tempFile.path);

          Logger.info('인스타그램 피드 공유 시작');
          return true;
        } finally {
          // 임시 파일 삭제 (약간의 딜레이 후)
          Future.delayed(const Duration(seconds: 5), () async {
            if (await tempFile.exists()) {
              await tempFile.delete();
            }
          });
        }
      },
      false,
      '인스타그램 피드 공유',
      '인스타그램 피드 공유 실패',
    );
  }

  /// 인스타그램 앱 열기
  Future<bool> openInstagram() async {
    return await safeExecuteWithFallback<bool>(
      () async {
        final uri = Uri.parse('instagram://');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
          return true;
        }
        return false;
      },
      false,
      '인스타그램 앱 열기',
      '인스타그램 앱 열기 실패',
    );
  }
}
