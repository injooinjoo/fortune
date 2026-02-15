import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'asset_pack.freezed.dart';
part 'asset_pack.g.dart';

/// 스토어/플랫폼별 배포 대상
enum AssetDistributionTarget {
  all,
  ios,
  android,
}

/// 자산 팩 Tier 분류
enum AssetTier {
  /// Tier 1: 앱 번들에 포함 (필수)
  bundled,

  /// Tier 2: 첫 실행 시 백그라운드 다운로드
  essential,

  /// Tier 3: 필요 시 On-Demand 다운로드
  onDemand,
}

/// 자산 팩 상태
enum AssetPackStatus {
  /// 설치되지 않음
  notInstalled,

  /// 다운로드 대기 중
  pending,

  /// 다운로드 중
  downloading,

  /// 설치됨 (로컬에 있음)
  installed,

  /// 다운로드 실패
  failed,
}

/// 자산 팩 모델
@freezed
class AssetPack with _$AssetPack {
  // ignore: unused_element
  const AssetPack._();

  const factory AssetPack({
    /// 팩 고유 ID (예: 'tarot_rider_waite', 'mbti_characters')
    required String id,

    /// 표시 이름 (예: 'Rider Waite 타로 덱')
    required String displayName,

    /// Tier 분류
    required AssetTier tier,

    /// 로컬 자산 경로 목록
    @Default([]) List<String> localPaths,

    /// Supabase Storage 경로 (CDN)
    String? storagePath,

    /// 예상 파일 크기 (bytes)
    @Default(0) int estimatedSize,

    /// 관련 운세 타입 (트리거)
    String? fortuneType,

    /// 현재 상태
    @Default(AssetPackStatus.notInstalled) AssetPackStatus status,

    /// 스토어/플랫폼 지원 대상
    @Default(<AssetDistributionTarget>{AssetDistributionTarget.all})
    Set<AssetDistributionTarget> supportedTargets,

    /// 다운로드 진행률 (0.0 ~ 1.0)
    @Default(0.0) double downloadProgress,

    /// 마지막 접근 시간
    DateTime? lastAccessedAt,

    /// 설치 시간
    DateTime? installedAt,
  }) = _AssetPack;

  factory AssetPack.fromJson(Map<String, dynamic> json) =>
      _$AssetPackFromJson(json);

  bool isSupported(AssetDistributionTarget target) {
    return supportedTargets.contains(AssetDistributionTarget.all) ||
        supportedTargets.contains(target);
  }

  bool isSupportedOnCurrentPlatform() {
    final target = switch (defaultTargetPlatform) {
      TargetPlatform.iOS => AssetDistributionTarget.ios,
      TargetPlatform.android => AssetDistributionTarget.android,
      _ => AssetDistributionTarget.all,
    };
    return isSupported(target);
  }
}

/// 다운로드 진행률 정보
@freezed
class DownloadProgress with _$DownloadProgress {
  const factory DownloadProgress({
    /// 팩 ID
    required String packId,

    /// 상태
    required AssetPackStatus status,

    /// 진행률 (0.0 ~ 1.0)
    @Default(0.0) double progress,

    /// 다운로드된 바이트
    @Default(0) int downloadedBytes,

    /// 전체 바이트
    @Default(0) int totalBytes,

    /// 에러 메시지 (실패 시)
    String? errorMessage,

    /// 남은 예상 시간 (초)
    int? estimatedSecondsRemaining,
  }) = _DownloadProgress;

  factory DownloadProgress.fromJson(Map<String, dynamic> json) =>
      _$DownloadProgressFromJson(json);
}

/// 저장소 사용량 정보
@freezed
class StorageUsage with _$StorageUsage {
  const factory StorageUsage({
    /// 번들 자산 크기
    @Default(0) int bundledSize,

    /// 다운로드된 자산 크기
    @Default(0) int downloadedSize,

    /// 캐시 크기
    @Default(0) int cacheSize,

    /// 전체 사용량
    @Default(0) int totalSize,

    /// 디바이스 가용 공간
    @Default(0) int availableSpace,

    /// 팩별 사용량
    @Default({}) Map<String, int> packSizes,
  }) = _StorageUsage;

  factory StorageUsage.fromJson(Map<String, dynamic> json) =>
      _$StorageUsageFromJson(json);
}
