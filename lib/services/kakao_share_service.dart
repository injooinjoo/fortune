import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'package:path_provider/path_provider.dart';

import '../core/config/environment.dart';
import '../core/services/resilient_service.dart';
import '../core/utils/logger.dart';

/// 카카오톡 공유 서비스
/// 카카오 SDK를 사용하여 카드형 공유 (FeedTemplate) 구현
class KakaoShareService extends ResilientService {
  static final KakaoShareService _instance = KakaoShareService._internal();
  factory KakaoShareService() => _instance;
  KakaoShareService._internal();

  @override
  String get serviceName => 'KakaoShareService';

  /// 카카오톡 설치 여부 확인
  Future<bool> isKakaoTalkAvailable() async {
    if (kIsWeb) return false;

    return await safeExecuteWithFallback<bool>(
      () async {
        return await ShareClient.instance.isKakaoTalkSharingAvailable();
      },
      false,
      '카카오톡 설치 확인',
      '카카오톡 설치 여부 확인 실패',
    );
  }

  /// 운세 결과 공유 (FeedTemplate)
  ///
  /// [title] 공유 제목 (예: "오늘의 운세")
  /// [description] 공유 설명 (예: "운수대통! 좋은 하루가 될 것 같아요")
  /// [imageData] 공유할 이미지 데이터 (Uint8List)
  /// [linkUrl] 앱 링크 URL (선택)
  /// [fortuneType] 운세 타입 (딥링크용, 예: "daily", "love", "tarot")
  Future<bool> shareFortuneResult({
    required BuildContext context,
    required String title,
    required String description,
    Uint8List? imageData,
    String? linkUrl,
    String? fortuneType,
  }) async {
    return await safeExecuteWithFallback<bool>(
      () async {
        // 이미지 URL 생성 (Kakao 서버 업로드)
        Uri? imageUrl;
        if (imageData != null) {
          imageUrl = await _uploadImage(imageData);
        }

        // 딥링크 파라미터 구성
        final executionParams = <String, String>{
          'screen': 'chat',
          if (fortuneType != null) 'fortuneType': fortuneType,
        };

        // FeedTemplate 생성
        final baseUrl = Environment.appBaseUrl;
        final template = FeedTemplate(
          content: Content(
            title: title,
            description: description,
            imageUrl: imageUrl ?? Uri.parse(Environment.defaultShareImageUrl),
            link: Link(
              webUrl: Uri.parse(linkUrl ?? baseUrl),
              mobileWebUrl: Uri.parse(linkUrl ?? baseUrl),
              androidExecutionParams: executionParams,
              iosExecutionParams: executionParams,
            ),
          ),
          social: Social(
            likeCount: 0,
            commentCount: 0,
            sharedCount: 0,
          ),
          buttons: [
            Button(
              title: '나도 해보기',
              link: Link(
                webUrl: Uri.parse(linkUrl ?? baseUrl),
                mobileWebUrl: Uri.parse(linkUrl ?? baseUrl),
                androidExecutionParams: executionParams,
                iosExecutionParams: executionParams,
              ),
            ),
          ],
        );

        // 카카오톡 설치 여부 확인
        final isAvailable = await isKakaoTalkAvailable();

        if (isAvailable) {
          // 카카오톡 앱으로 공유
          final uri =
              await ShareClient.instance.shareDefault(template: template);
          await ShareClient.instance.launchKakaoTalk(uri);
          Logger.info('카카오톡 공유 성공');
          return true;
        } else {
          // 웹 브라우저로 공유 (앱 미설치)
          final uri =
              await WebSharerClient.instance.makeDefaultUrl(template: template);
          await launchBrowserTab(uri);
          Logger.info('카카오톡 웹 공유 성공');
          return true;
        }
      },
      false,
      '카카오톡 공유: $title',
      '카카오톡 공유 실패, 대체 방법 사용',
    );
  }

  /// 이미지를 카카오 서버에 업로드
  Future<Uri?> _uploadImage(Uint8List imageData) async {
    return await safeExecuteWithNull(
      () async {
        // 임시 파일로 저장
        final tempDir = await getTemporaryDirectory();
        final tempFile = File(
            '${tempDir.path}/kakao_share_${DateTime.now().millisecondsSinceEpoch}.png');
        await tempFile.writeAsBytes(imageData);

        try {
          // 카카오 서버에 이미지 업로드
          final imageUploadResult = await ShareClient.instance.uploadImage(
            image: tempFile,
          );

          Logger.info(
              '카카오 이미지 업로드 성공: ${imageUploadResult.infos.original.url}');
          return Uri.parse(imageUploadResult.infos.original.url);
        } finally {
          // 임시 파일 삭제
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        }
      },
      '카카오 이미지 업로드',
      '이미지 업로드 실패, 기본 이미지 사용',
    );
  }

  /// 사용자 지정 메시지와 함께 공유 (텍스트 중심)
  Future<bool> shareWithText({
    required BuildContext context,
    required String title,
    required String content,
    String? userName,
  }) async {
    final shareText = userName != null
        ? '$userName님의 $title\n\n$content'
        : '$title\n\n$content';

    return await shareFortuneResult(
      context: context,
      title: title,
      description: shareText.length > 200
          ? '${shareText.substring(0, 197)}...'
          : shareText,
    );
  }

  /// 커스텀 템플릿으로 공유 (Kakao Developers에서 등록한 템플릿)
  Future<bool> shareWithCustomTemplate({
    required int templateId,
    Map<String, String>? templateArgs,
  }) async {
    return await safeExecuteWithFallback<bool>(
      () async {
        final isAvailable = await isKakaoTalkAvailable();

        if (isAvailable) {
          final uri = await ShareClient.instance.shareCustom(
            templateId: templateId,
            templateArgs: templateArgs,
          );
          await ShareClient.instance.launchKakaoTalk(uri);
          return true;
        } else {
          final uri = await WebSharerClient.instance.makeCustomUrl(
            templateId: templateId,
            templateArgs: templateArgs,
          );
          await launchBrowserTab(uri);
          return true;
        }
      },
      false,
      '카카오톡 커스텀 템플릿 공유',
      '커스텀 템플릿 공유 실패',
    );
  }
}
