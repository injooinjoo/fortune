import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/fortune_design_system.dart';

/// 광고 시청 후 구독 유도 스낵바를 표시하는 유틸리티
///
/// 사용법:
/// ```dart
/// SubscriptionSnackbar.showAfterAd(context, hasUnlimitedAccess: tokenState.hasUnlimitedAccess);
/// ```
class SubscriptionSnackbar {
  /// 광고 시청 후 구독 유도 스낵바 표시
  ///
  /// [context] BuildContext
  /// [hasUnlimitedAccess] 구독 중인지 여부 (true면 스낵바 표시 안함)
  /// [duration] 스낵바 표시 시간 (기본 5초)
  static void showAfterAd(
    BuildContext context, {
    required bool hasUnlimitedAccess,
    Duration duration = const Duration(seconds: 5),
  }) {
    // 이미 구독 중이면 표시하지 않음
    if (hasUnlimitedAccess) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            context.push('/subscription');
          },
          child: const Row(
            children: [
              Icon(
                Icons.workspace_premium,
                color: Colors.amber,
                size: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '구독하면 광고 없이 볼 수 있어요',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white70,
                size: 20,
              ),
            ],
          ),
        ),
        backgroundColor: isDark
            ? TossDesignSystem.gray700
            : TossDesignSystem.gray800,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: duration,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }
}
