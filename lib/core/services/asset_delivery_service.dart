import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/asset_pack_config.dart';
import '../models/asset_pack.dart';

/// 자산 배포 서비스
///
/// On-Demand 리소스 시스템의 핵심 서비스
/// - Supabase Storage에서 자산 다운로드
/// - 로컬 캐시 관리 (영구 캐시)
/// - 자산 경로 해결 (로컬 vs CDN)
/// - 다운로드 진행률 스트림
class AssetDeliveryService {
  static final AssetDeliveryService _instance = AssetDeliveryService._internal();
  factory AssetDeliveryService() => _instance;
  AssetDeliveryService._internal();

  // Hive 박스 (자산 팩 상태 저장)
  static const String _boxName = 'asset_packs';
  late Box<Map> _packStatusBox;

  // 다운로드 진행률 스트림
  final _downloadProgressController =
      StreamController<DownloadProgress>.broadcast();
  Stream<DownloadProgress> get downloadProgress =>
      _downloadProgressController.stream;

  // 현재 다운로드 중인 팩
  final Set<String> _downloadingPacks = {};

  // 캐시 디렉토리
  Directory? _cacheDirectory;

  // 초기화 여부
  bool _initialized = false;

  // ============================================================
  // 초기화
  // ============================================================

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Hive 박스 열기
      _packStatusBox = await Hive.openBox<Map>(_boxName);

      // 캐시 디렉토리 설정
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDirectory = Directory('${appDir.path}/asset_packs');
      if (!await _cacheDirectory!.exists()) {
        await _cacheDirectory!.create(recursive: true);
      }

      _initialized = true;
      debugPrint('📦 [AssetDeliveryService] 초기화 완료');
    } catch (e) {
      debugPrint('📦 [AssetDeliveryService] ❌ 초기화 실패: $e');
      rethrow;
    }
  }

  // ============================================================
  // 자산 팩 상태 관리
  // ============================================================

  /// 자산 팩 설치 여부 확인
  Future<bool> isPackInstalled(String packId) async {
    await _ensureInitialized();

    // Tier 1 (번들)은 항상 설치됨
    final pack = AssetPackConfig.packs[packId];
    if (pack?.tier == AssetTier.bundled) return true;

    // Hive에서 상태 확인
    final status = _packStatusBox.get(packId);
    if (status == null) return false;

    return status['status'] == AssetPackStatus.installed.index;
  }

  /// 자산 팩 상태 가져오기
  Future<AssetPackStatus> getPackStatus(String packId) async {
    await _ensureInitialized();

    final pack = AssetPackConfig.packs[packId];
    if (pack?.tier == AssetTier.bundled) {
      return AssetPackStatus.installed;
    }

    if (_downloadingPacks.contains(packId)) {
      return AssetPackStatus.downloading;
    }

    final status = _packStatusBox.get(packId);
    if (status == null) return AssetPackStatus.notInstalled;

    return AssetPackStatus.values[status['status'] as int];
  }

  /// 자산 팩 상태 업데이트
  Future<void> _updatePackStatus(
    String packId,
    AssetPackStatus status, {
    DateTime? installedAt,
    DateTime? lastAccessedAt,
  }) async {
    final existing = _packStatusBox.get(packId) ?? {};
    await _packStatusBox.put(packId, {
      ...existing,
      'status': status.index,
      if (installedAt != null) 'installedAt': installedAt.toIso8601String(),
      if (lastAccessedAt != null)
        'lastAccessedAt': lastAccessedAt.toIso8601String(),
    });
  }

  // ============================================================
  // 자산 다운로드
  // ============================================================

  /// 자산 팩 다운로드 요청
  Future<void> requestAssetPack(String packId) async {
    await _ensureInitialized();

    final pack = AssetPackConfig.packs[packId];
    if (pack == null) {
      debugPrint('📦 [AssetDeliveryService] ❌ 알 수 없는 팩: $packId');
      return;
    }

    // 이미 설치됨
    if (await isPackInstalled(packId)) {
      debugPrint('📦 [AssetDeliveryService] ✅ 이미 설치됨: $packId');
      _downloadProgressController.add(DownloadProgress(
        packId: packId,
        status: AssetPackStatus.installed,
        progress: 1.0,
      ));
      return;
    }

    // 이미 다운로드 중
    if (_downloadingPacks.contains(packId)) {
      debugPrint('📦 [AssetDeliveryService] ⏳ 다운로드 중: $packId');
      return;
    }

    // 다운로드 시작
    _downloadingPacks.add(packId);
    await _updatePackStatus(packId, AssetPackStatus.downloading);

    _downloadProgressController.add(DownloadProgress(
      packId: packId,
      status: AssetPackStatus.downloading,
      progress: 0.0,
    ));

    try {
      await _downloadPack(pack);

      // 완료
      _downloadingPacks.remove(packId);
      await _updatePackStatus(
        packId,
        AssetPackStatus.installed,
        installedAt: DateTime.now(),
      );

      _downloadProgressController.add(DownloadProgress(
        packId: packId,
        status: AssetPackStatus.installed,
        progress: 1.0,
      ));

      debugPrint('📦 [AssetDeliveryService] ✅ 다운로드 완료: $packId');
    } catch (e) {
      _downloadingPacks.remove(packId);
      await _updatePackStatus(packId, AssetPackStatus.failed);

      _downloadProgressController.add(DownloadProgress(
        packId: packId,
        status: AssetPackStatus.failed,
        errorMessage: e.toString(),
      ));

      debugPrint('📦 [AssetDeliveryService] ❌ 다운로드 실패: $packId - $e');
    }
  }

  /// 실제 다운로드 수행
  Future<void> _downloadPack(AssetPack pack) async {
    if (pack.storagePath == null) {
      throw Exception('Storage path not defined for pack: ${pack.id}');
    }

    final supabase = Supabase.instance.client;
    final packDir = Directory('${_cacheDirectory!.path}/${pack.id}');

    if (!await packDir.exists()) {
      await packDir.create(recursive: true);
    }

    // Supabase Storage에서 파일 목록 가져오기
    final files = await supabase.storage
        .from(AssetPackConfig.storageBucket)
        .list(path: pack.storagePath!);

    if (files.isEmpty) {
      debugPrint(
          '📦 [AssetDeliveryService] ⚠️ 파일 없음: ${pack.storagePath}');
      // 빈 팩도 설치 완료로 처리
      return;
    }

    int downloadedCount = 0;
    final totalCount = files.length;

    for (final file in files) {
      if (file.name.isEmpty) continue;

      final remotePath = '${pack.storagePath}${file.name}';
      final localPath = '${packDir.path}/${file.name}';

      try {
        // 파일 다운로드
        final response = await supabase.storage
            .from(AssetPackConfig.storageBucket)
            .download(remotePath);

        // 로컬에 저장
        final localFile = File(localPath);
        await localFile.writeAsBytes(response);

        downloadedCount++;

        // 진행률 업데이트
        final progress = downloadedCount / totalCount;
        _downloadProgressController.add(DownloadProgress(
          packId: pack.id,
          status: AssetPackStatus.downloading,
          progress: progress,
          downloadedBytes: downloadedCount,
          totalBytes: totalCount,
        ));
      } catch (e) {
        debugPrint(
            '📦 [AssetDeliveryService] ⚠️ 파일 다운로드 실패: $remotePath - $e');
        // 개별 파일 실패는 무시하고 계속 진행
      }
    }

    // 하위 디렉토리도 처리 (재귀적)
    await _downloadSubdirectories(pack, packDir);
  }

  /// 하위 디렉토리 다운로드
  Future<void> _downloadSubdirectories(
      AssetPack pack, Directory packDir) async {
    final supabase = Supabase.instance.client;

    // 타로 덱 같은 경우 major/, cups/, pentacles/ 등 하위 폴더가 있음
    final subdirs = ['major', 'cups', 'pentacles', 'swords', 'wands'];

    for (final subdir in subdirs) {
      final remotePath = '${pack.storagePath}$subdir/';

      try {
        final files = await supabase.storage
            .from(AssetPackConfig.storageBucket)
            .list(path: remotePath);

        if (files.isEmpty) continue;

        final localSubdir = Directory('${packDir.path}/$subdir');
        if (!await localSubdir.exists()) {
          await localSubdir.create(recursive: true);
        }

        for (final file in files) {
          if (file.name.isEmpty) continue;

          final fileRemotePath = '$remotePath${file.name}';
          final localPath = '${localSubdir.path}/${file.name}';

          try {
            final response = await supabase.storage
                .from(AssetPackConfig.storageBucket)
                .download(fileRemotePath);

            final localFile = File(localPath);
            await localFile.writeAsBytes(response);
          } catch (e) {
            debugPrint(
                '📦 [AssetDeliveryService] ⚠️ 하위 파일 실패: $fileRemotePath');
          }
        }
      } catch (e) {
        // 해당 하위 디렉토리가 없으면 무시
      }
    }
  }

  // ============================================================
  // 자산 경로 해결
  // ============================================================

  /// 자산 경로 해결 (로컬 캐시 또는 CDN URL 반환)
  ///
  /// [assetPath] 원본 자산 경로 (예: 'assets/images/tarot/decks/rider_waite/major/00_fool.webp')
  /// [packId] 자산 팩 ID (선택적, 미지정 시 자동 감지)
  Future<String> resolveAssetPath(String assetPath, {String? packId}) async {
    await _ensureInitialized();

    // Tier 1 (번들) 자산은 그대로 반환
    if (_isBundledAsset(assetPath)) {
      return assetPath;
    }

    // 팩 ID 자동 감지
    packId ??= _detectPackId(assetPath);
    if (packId == null) {
      // 알 수 없는 자산은 원본 경로 반환
      return assetPath;
    }

    // 설치 여부 확인
    if (await isPackInstalled(packId)) {
      // 로컬 캐시 경로 반환
      final localPath = _getLocalCachePath(assetPath, packId);
      final file = File(localPath);
      if (await file.exists()) {
        // 마지막 접근 시간 업데이트
        await _updatePackStatus(
          packId,
          AssetPackStatus.installed,
          lastAccessedAt: DateTime.now(),
        );
        return localPath;
      }
    }

    // CDN URL 반환 (설치되지 않은 경우)
    return _getCdnUrl(assetPath, packId);
  }

  /// 번들 자산 여부 확인
  bool _isBundledAsset(String assetPath) {
    for (final pack in AssetPackConfig.bundledPacks) {
      for (final localPath in pack.localPaths) {
        if (assetPath.startsWith(localPath)) {
          return true;
        }
      }
    }
    return false;
  }

  /// 자산 경로에서 팩 ID 감지
  String? _detectPackId(String assetPath) {
    for (final entry in AssetPackConfig.packs.entries) {
      final pack = entry.value;
      for (final localPath in pack.localPaths) {
        if (assetPath.startsWith(localPath)) {
          return entry.key;
        }
      }
    }
    return null;
  }

  /// 로컬 캐시 경로 생성
  String _getLocalCachePath(String assetPath, String packId) {
    // assets/images/tarot/decks/rider_waite/major/00_fool.webp
    // -> /path/to/cache/tarot_rider_waite/major/00_fool.webp
    final pack = AssetPackConfig.packs[packId];
    if (pack == null) return assetPath;

    // 상대 경로 추출
    String relativePath = assetPath;
    for (final localPath in pack.localPaths) {
      if (assetPath.startsWith(localPath)) {
        relativePath = assetPath.substring(localPath.length);
        break;
      }
    }

    return '${_cacheDirectory!.path}/$packId/$relativePath';
  }

  /// Supabase CDN URL 생성
  String _getCdnUrl(String assetPath, String packId) {
    final pack = AssetPackConfig.packs[packId];
    if (pack?.storagePath == null) return assetPath;

    // 상대 경로 추출
    String relativePath = assetPath;
    for (final localPath in pack!.localPaths) {
      if (assetPath.startsWith(localPath)) {
        relativePath = assetPath.substring(localPath.length);
        break;
      }
    }

    final supabase = Supabase.instance.client;
    return supabase.storage
        .from(AssetPackConfig.storageBucket)
        .getPublicUrl('${pack.storagePath}$relativePath');
  }

  // ============================================================
  // 타로 덱 관련
  // ============================================================

  /// 오늘의 타로 덱 다운로드 및 준비
  Future<String?> prepareTodaysTarotDeck() async {
    final todaysDeck = AssetPackConfig.getTodaysDeck();
    final packId = 'tarot_$todaysDeck';

    // 이미 설치되어 있으면 바로 반환
    if (await isPackInstalled(packId)) {
      return todaysDeck;
    }

    // 다운로드 요청
    await requestAssetPack(packId);

    // 설치될 때까지 대기
    await for (final progress in downloadProgress) {
      if (progress.packId == packId) {
        if (progress.status == AssetPackStatus.installed) {
          return todaysDeck;
        }
        if (progress.status == AssetPackStatus.failed) {
          return null;
        }
      }
    }

    return null;
  }

  /// 특정 타로 덱 준비
  Future<bool> prepareTarotDeck(String deckId) async {
    final packId = 'tarot_$deckId';

    if (await isPackInstalled(packId)) {
      return true;
    }

    await requestAssetPack(packId);

    // 설치될 때까지 대기 (타임아웃 30초)
    final completer = Completer<bool>();
    Timer? timeout;

    timeout = Timer(const Duration(seconds: 30), () {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    final subscription = downloadProgress.listen((progress) {
      if (progress.packId == packId) {
        if (progress.status == AssetPackStatus.installed) {
          timeout?.cancel();
          if (!completer.isCompleted) completer.complete(true);
        }
        if (progress.status == AssetPackStatus.failed) {
          timeout?.cancel();
          if (!completer.isCompleted) completer.complete(false);
        }
      }
    });

    final result = await completer.future;
    await subscription.cancel();
    return result;
  }

  // ============================================================
  // 저장소 관리
  // ============================================================

  /// 저장소 사용량 계산
  Future<StorageUsage> getStorageUsage() async {
    await _ensureInitialized();

    int downloadedSize = 0;
    final packSizes = <String, int>{};

    if (_cacheDirectory != null && await _cacheDirectory!.exists()) {
      await for (final entity in _cacheDirectory!.list(recursive: true)) {
        if (entity is File) {
          final size = await entity.length();
          downloadedSize += size;

          // 팩별 크기 계산
          final pathParts = entity.path.split('/');
          final cacheIndex = pathParts.indexOf('asset_packs');
          if (cacheIndex >= 0 && cacheIndex + 1 < pathParts.length) {
            final packId = pathParts[cacheIndex + 1];
            packSizes[packId] = (packSizes[packId] ?? 0) + size;
          }
        }
      }
    }

    // 번들 자산 크기 (추정)
    final bundledSize = AssetPackConfig.getEstimatedSizeByTier(AssetTier.bundled);

    return StorageUsage(
      bundledSize: bundledSize,
      downloadedSize: downloadedSize,
      totalSize: bundledSize + downloadedSize,
      packSizes: packSizes,
    );
  }

  /// 특정 자산 팩 삭제
  Future<void> deleteAssetPack(String packId) async {
    await _ensureInitialized();

    final pack = AssetPackConfig.packs[packId];
    if (pack?.tier == AssetTier.bundled) {
      debugPrint('📦 [AssetDeliveryService] ⚠️ 번들 자산은 삭제 불가: $packId');
      return;
    }

    // 로컬 캐시 삭제
    final packDir = Directory('${_cacheDirectory!.path}/$packId');
    if (await packDir.exists()) {
      await packDir.delete(recursive: true);
    }

    // 상태 업데이트
    await _packStatusBox.delete(packId);

    debugPrint('📦 [AssetDeliveryService] 🗑️ 자산 팩 삭제됨: $packId');
  }

  /// 모든 다운로드된 자산 삭제
  Future<void> clearAllDownloadedAssets() async {
    await _ensureInitialized();

    if (_cacheDirectory != null && await _cacheDirectory!.exists()) {
      await _cacheDirectory!.delete(recursive: true);
      await _cacheDirectory!.create(recursive: true);
    }

    // 상태 초기화 (번들 제외)
    final keysToDelete = <String>[];
    for (final key in _packStatusBox.keys) {
      final pack = AssetPackConfig.packs[key];
      if (pack?.tier != AssetTier.bundled) {
        keysToDelete.add(key as String);
      }
    }

    for (final key in keysToDelete) {
      await _packStatusBox.delete(key);
    }

    debugPrint('📦 [AssetDeliveryService] 🗑️ 모든 다운로드 자산 삭제됨');
  }

  // ============================================================
  // 유틸리티
  // ============================================================

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  /// 리소스 정리
  void dispose() {
    _downloadProgressController.close();
  }
}
