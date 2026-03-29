import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/design_system/design_system.dart';
import '../../services/app_version_service.dart';

/// 앱 업데이트 다이얼로그
/// 강제 업데이트, 선택적 업데이트, 점검 모드 지원
class AppUpdateDialog extends StatelessWidget {
  final VersionCheckInfo versionInfo;
  final VoidCallback? onSkip;

  const AppUpdateDialog({
    super.key,
    required this.versionInfo,
    this.onSkip,
  });

  /// 강제 업데이트 다이얼로그 표시
  static Future<void> showForceUpdate(
    BuildContext context,
    VersionCheckInfo versionInfo,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AppUpdateDialog(versionInfo: versionInfo),
      ),
    );
  }

  /// 선택적 업데이트 다이얼로그 표시
  static Future<bool> showOptionalUpdate(
    BuildContext context,
    VersionCheckInfo versionInfo,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AppUpdateDialog(
        versionInfo: versionInfo,
        onSkip: () => Navigator.of(context).pop(false),
      ),
    );
    return result ?? false;
  }

  /// 점검 모드 다이얼로그 표시
  static Future<void> showMaintenance(
    BuildContext context,
    VersionCheckInfo versionInfo,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AppUpdateDialog(versionInfo: versionInfo),
      ),
    );
  }

  bool get _isForceUpdate =>
      versionInfo.result == VersionCheckResult.forceUpdateRequired;

  bool get _isMaintenance =>
      versionInfo.result == VersionCheckResult.maintenance;

  String get _title {
    if (_isMaintenance) return '서비스 점검 중';
    if (_isForceUpdate) return '업데이트 필요';
    return '새로운 버전 출시';
  }

  String get _message {
    if (_isMaintenance) return versionInfo.maintenanceMessage;
    return versionInfo.updateMessage;
  }

  IconData get _icon {
    if (_isMaintenance) return Icons.build_circle_outlined;
    return Icons.system_update_outlined;
  }

  Future<void> _openStore() async {
    final storeUrl = versionInfo.storeUrl;
    if (storeUrl == null || storeUrl.isEmpty) {
      // 기본 스토어 URL
      final defaultUrl = Platform.isIOS
          ? 'https://apps.apple.com/app/id[YOUR_APP_ID]'
          : 'https://play.google.com/store/apps/details?id=com.gwansang.fortune';

      final uri = Uri.parse(defaultUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }

    final uri = Uri.parse(storeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DSRadius.modal),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _isMaintenance
                    ? colors.warning.withValues(alpha: 0.1)
                    : colors.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _icon,
                size: 36,
                color: _isMaintenance ? colors.warning : colors.accent,
              ),
            ),
            const SizedBox(height: DSSpacing.lg),

            // 제목
            Text(
              _title,
              style: typography.headingMedium,
            ),
            const SizedBox(height: DSSpacing.sm),

            // 메시지
            Text(
              _message,
              textAlign: TextAlign.center,
              style: typography.bodyLarge.copyWith(
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),

            // 버전 정보
            if (!_isMaintenance) ...[
              const SizedBox(height: DSSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.sm,
                  vertical: DSSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(DSRadius.sm),
                ),
                child: Text(
                  '현재 버전: ${versionInfo.currentVersion} → 최신: ${versionInfo.appSettings?.latestVersion ?? "-"}',
                  style: typography.labelSmall.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              ),
            ],

            const SizedBox(height: DSSpacing.xl),

            // 버튼들
            if (_isMaintenance)
              // 점검 중: 앱 종료만 가능
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => SystemNavigator.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.surface,
                    foregroundColor: colors.textPrimary,
                    padding: const EdgeInsets.symmetric(
                        vertical: DSSpacing.buttonVertical),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DSRadius.card),
                    ),
                  ),
                  child: const Text('앱 종료'),
                ),
              )
            else ...[
              // 업데이트 버튼
              DSButton.primary(
                text: '업데이트하기',
                onPressed: _openStore,
              ),

              // 나중에 버튼 (선택적 업데이트만)
              if (!_isForceUpdate && onSkip != null) ...[
                const SizedBox(height: DSSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: onSkip,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.textSecondary,
                      padding: const EdgeInsets.symmetric(
                          vertical: DSSpacing.buttonVertical),
                    ),
                    child: const Text('나중에'),
                  ),
                ),
              ],

              // 강제 업데이트: 앱 종료 버튼
              if (_isForceUpdate) ...[
                const SizedBox(height: DSSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => SystemNavigator.pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: colors.textTertiary,
                      padding: const EdgeInsets.symmetric(
                          vertical: DSSpacing.buttonVertical),
                    ),
                    child: const Text('앱 종료'),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
