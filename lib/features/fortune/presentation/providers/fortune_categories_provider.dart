import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/remote_config_service.dart';
import '../../domain/entities/fortune_category.dart';

/// 운세 카테고리 Provider
/// Remote Config에서 동적으로 카테고리를 로드하며, 실패 시 기본값 사용
/// 이미지 경로를 CDN URL로 자동 변환
final fortuneCategoriesProvider = Provider<List<FortuneCategory>>((ref) {
  final remoteConfig = ref.watch(remoteConfigProvider);
  final categories = remoteConfig.getFortuneCategories();

  // CDN이 활성화되어 있으면 이미지 경로를 CDN URL로 변환
  if (remoteConfig.useImageCdn()) {
    return categories.map((category) {
      if (category.iconAsset != null) {
        final cdnPath = remoteConfig.resolveImagePath(category.iconAsset!);
        return category.copyWith(iconAsset: cdnPath);
      }
      return category;
    }).toList();
  }

  return categories;
});

/// 운세 카테고리 버전 Provider
/// 카테고리 변경 추적용
final fortuneCategoriesVersionProvider = Provider<int>((ref) {
  final remoteConfig = ref.watch(remoteConfigProvider);
  return remoteConfig.getFortuneCategoriesVersion();
});

/// 이미지 CDN 활성화 여부 Provider
final useImageCdnProvider = Provider<bool>((ref) {
  final remoteConfig = ref.watch(remoteConfigProvider);
  return remoteConfig.useImageCdn();
});
