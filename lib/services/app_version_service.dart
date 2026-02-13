import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/logger.dart';

/// 앱 버전 체크 결과
enum VersionCheckResult {
  /// 최신 버전
  upToDate,

  /// 선택적 업데이트 가능
  updateAvailable,

  /// 강제 업데이트 필요
  forceUpdateRequired,

  /// 점검 중
  maintenance,

  /// 체크 실패 (네트워크 오류 등)
  checkFailed,
}

/// 앱 설정 데이터
class AppSettings {
  final String platform;
  final String minVersion;
  final String latestVersion;
  final String? updateMessage;
  final String? storeUrl;
  final bool forceUpdate;
  final bool maintenanceMode;
  final String? maintenanceMessage;

  AppSettings({
    required this.platform,
    required this.minVersion,
    required this.latestVersion,
    this.updateMessage,
    this.storeUrl,
    this.forceUpdate = false,
    this.maintenanceMode = false,
    this.maintenanceMessage,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      platform: json['platform'] as String,
      minVersion: json['min_version'] as String,
      latestVersion: json['latest_version'] as String,
      updateMessage: json['update_message'] as String?,
      storeUrl: json['store_url'] as String?,
      forceUpdate: json['force_update'] as bool? ?? false,
      maintenanceMode: json['maintenance_mode'] as bool? ?? false,
      maintenanceMessage: json['maintenance_message'] as String?,
    );
  }
}

/// 버전 체크 결과 상세 정보
class VersionCheckInfo {
  final VersionCheckResult result;
  final String currentVersion;
  final AppSettings? appSettings;
  final String? errorMessage;

  VersionCheckInfo({
    required this.result,
    required this.currentVersion,
    this.appSettings,
    this.errorMessage,
  });

  /// 업데이트 메시지 가져오기
  String get updateMessage =>
      appSettings?.updateMessage ?? '더 나은 서비스를 위해 최신 버전으로 업데이트해 주세요.';

  /// 스토어 URL 가져오기
  String? get storeUrl => appSettings?.storeUrl;

  /// 점검 메시지 가져오기
  String get maintenanceMessage =>
      appSettings?.maintenanceMessage ?? '서비스 점검 중입니다. 잠시 후 다시 시도해 주세요.';
}

/// 앱 버전 관리 서비스
class AppVersionService {
  static final AppVersionService _instance = AppVersionService._internal();
  factory AppVersionService() => _instance;
  AppVersionService._internal();

  final _supabase = Supabase.instance.client;
  PackageInfo? _packageInfo;

  /// 현재 플랫폼 가져오기
  String get _platform {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'unknown';
  }

  /// 패키지 정보 초기화
  Future<PackageInfo> _getPackageInfo() async {
    _packageInfo ??= await PackageInfo.fromPlatform();
    return _packageInfo!;
  }

  /// 현재 앱 버전 가져오기
  Future<String> getCurrentVersion() async {
    final packageInfo = await _getPackageInfo();
    return packageInfo.version;
  }

  /// 버전 비교 (semantic versioning)
  /// 반환값: -1 (v1 < v2), 0 (v1 == v2), 1 (v1 > v2)
  int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final parts2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // 버전 파트 개수 맞추기
    while (parts1.length < 3) {
      parts1.add(0);
    }
    while (parts2.length < 3) {
      parts2.add(0);
    }

    for (var i = 0; i < 3; i++) {
      if (parts1[i] < parts2[i]) return -1;
      if (parts1[i] > parts2[i]) return 1;
    }
    return 0;
  }

  /// 서버에서 앱 설정 가져오기
  Future<AppSettings?> _fetchAppSettings() async {
    try {
      final response = await _supabase
          .from('app_settings')
          .select()
          .eq('platform', _platform)
          .maybeSingle();

      if (response == null) {
        Logger.warning('[AppVersionService] 플랫폼 설정 없음: $_platform');
        return null;
      }

      return AppSettings.fromJson(response);
    } catch (e) {
      Logger.error('[AppVersionService] 앱 설정 가져오기 실패: $e');
      return null;
    }
  }

  /// 버전 체크 수행
  Future<VersionCheckInfo> checkVersion() async {
    try {
      final currentVersion = await getCurrentVersion();
      final appSettings = await _fetchAppSettings();

      if (appSettings == null) {
        Logger.info('[AppVersionService] 설정 없음, 정상 진행');
        return VersionCheckInfo(
          result: VersionCheckResult.upToDate,
          currentVersion: currentVersion,
        );
      }

      // 1. 점검 모드 체크
      if (appSettings.maintenanceMode) {
        Logger.info('[AppVersionService] 점검 모드');
        return VersionCheckInfo(
          result: VersionCheckResult.maintenance,
          currentVersion: currentVersion,
          appSettings: appSettings,
        );
      }

      // 2. 최소 버전 체크 (강제 업데이트)
      final minCompare =
          _compareVersions(currentVersion, appSettings.minVersion);
      if (minCompare < 0) {
        Logger.info(
            '[AppVersionService] 강제 업데이트 필요: $currentVersion < ${appSettings.minVersion}');
        return VersionCheckInfo(
          result: VersionCheckResult.forceUpdateRequired,
          currentVersion: currentVersion,
          appSettings: appSettings,
        );
      }

      // 3. 최신 버전 체크 (선택적 업데이트)
      final latestCompare =
          _compareVersions(currentVersion, appSettings.latestVersion);
      if (latestCompare < 0) {
        Logger.info(
            '[AppVersionService] 업데이트 가능: $currentVersion < ${appSettings.latestVersion}');
        return VersionCheckInfo(
          result: VersionCheckResult.updateAvailable,
          currentVersion: currentVersion,
          appSettings: appSettings,
        );
      }

      Logger.info('[AppVersionService] 최신 버전: $currentVersion');
      return VersionCheckInfo(
        result: VersionCheckResult.upToDate,
        currentVersion: currentVersion,
        appSettings: appSettings,
      );
    } catch (e) {
      Logger.error('[AppVersionService] 버전 체크 실패: $e');
      return VersionCheckInfo(
        result: VersionCheckResult.checkFailed,
        currentVersion: 'unknown',
        errorMessage: e.toString(),
      );
    }
  }
}
