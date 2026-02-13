// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_pack.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AssetPackImpl _$$AssetPackImplFromJson(Map<String, dynamic> json) =>
    _$AssetPackImpl(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      tier: $enumDecode(_$AssetTierEnumMap, json['tier']),
      localPaths: (json['localPaths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      storagePath: json['storagePath'] as String?,
      estimatedSize: (json['estimatedSize'] as num?)?.toInt() ?? 0,
      fortuneType: json['fortuneType'] as String?,
      status: $enumDecodeNullable(_$AssetPackStatusEnumMap, json['status']) ??
          AssetPackStatus.notInstalled,
      downloadProgress: (json['downloadProgress'] as num?)?.toDouble() ?? 0.0,
      lastAccessedAt: json['lastAccessedAt'] == null
          ? null
          : DateTime.parse(json['lastAccessedAt'] as String),
      installedAt: json['installedAt'] == null
          ? null
          : DateTime.parse(json['installedAt'] as String),
    );

Map<String, dynamic> _$$AssetPackImplToJson(_$AssetPackImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'tier': _$AssetTierEnumMap[instance.tier]!,
      'localPaths': instance.localPaths,
      'storagePath': instance.storagePath,
      'estimatedSize': instance.estimatedSize,
      'fortuneType': instance.fortuneType,
      'status': _$AssetPackStatusEnumMap[instance.status]!,
      'downloadProgress': instance.downloadProgress,
      'lastAccessedAt': instance.lastAccessedAt?.toIso8601String(),
      'installedAt': instance.installedAt?.toIso8601String(),
    };

const _$AssetTierEnumMap = {
  AssetTier.bundled: 'bundled',
  AssetTier.essential: 'essential',
  AssetTier.onDemand: 'onDemand',
};

const _$AssetPackStatusEnumMap = {
  AssetPackStatus.notInstalled: 'notInstalled',
  AssetPackStatus.pending: 'pending',
  AssetPackStatus.downloading: 'downloading',
  AssetPackStatus.installed: 'installed',
  AssetPackStatus.failed: 'failed',
};

_$DownloadProgressImpl _$$DownloadProgressImplFromJson(
        Map<String, dynamic> json) =>
    _$DownloadProgressImpl(
      packId: json['packId'] as String,
      status: $enumDecode(_$AssetPackStatusEnumMap, json['status']),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      downloadedBytes: (json['downloadedBytes'] as num?)?.toInt() ?? 0,
      totalBytes: (json['totalBytes'] as num?)?.toInt() ?? 0,
      errorMessage: json['errorMessage'] as String?,
      estimatedSecondsRemaining:
          (json['estimatedSecondsRemaining'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$DownloadProgressImplToJson(
        _$DownloadProgressImpl instance) =>
    <String, dynamic>{
      'packId': instance.packId,
      'status': _$AssetPackStatusEnumMap[instance.status]!,
      'progress': instance.progress,
      'downloadedBytes': instance.downloadedBytes,
      'totalBytes': instance.totalBytes,
      'errorMessage': instance.errorMessage,
      'estimatedSecondsRemaining': instance.estimatedSecondsRemaining,
    };

_$StorageUsageImpl _$$StorageUsageImplFromJson(Map<String, dynamic> json) =>
    _$StorageUsageImpl(
      bundledSize: (json['bundledSize'] as num?)?.toInt() ?? 0,
      downloadedSize: (json['downloadedSize'] as num?)?.toInt() ?? 0,
      cacheSize: (json['cacheSize'] as num?)?.toInt() ?? 0,
      totalSize: (json['totalSize'] as num?)?.toInt() ?? 0,
      availableSpace: (json['availableSpace'] as num?)?.toInt() ?? 0,
      packSizes: (json['packSizes'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
    );

Map<String, dynamic> _$$StorageUsageImplToJson(_$StorageUsageImpl instance) =>
    <String, dynamic>{
      'bundledSize': instance.bundledSize,
      'downloadedSize': instance.downloadedSize,
      'cacheSize': instance.cacheSize,
      'totalSize': instance.totalSize,
      'availableSpace': instance.availableSpace,
      'packSizes': instance.packSizes,
    };
