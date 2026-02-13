import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';

/// 결제 진행 중 로딩 오버레이
///
/// 결제 중 화면을 가리고 사용자에게 안내 메시지를 표시합니다.
/// - "화면을 닫지 마세요" 안내
/// - 진행 상태 메시지
/// - 로딩 인디케이터
class PurchaseLoadingOverlay extends StatelessWidget {
  final bool isVisible;
  final String? message;

  const PurchaseLoadingOverlay({
    super.key,
    required this.isVisible,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    final colors = context.colors;

    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: DSSpacing.xxl),
            padding: const EdgeInsets.all(DSSpacing.xl),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(DSRadius.lg),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 로딩 인디케이터
                const SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      DSColors.warning,
                    ),
                  ),
                ),

                const SizedBox(height: DSSpacing.lg),

                // 메인 메시지
                Text(
                  message ?? '결제 처리 중...',
                  style: context.bodyLarge.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: DSSpacing.md),

                // 안내 메시지
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.md,
                    vertical: DSSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: DSColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DSRadius.sm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 18,
                        color: DSColors.warning,
                      ),
                      const SizedBox(width: DSSpacing.xs),
                      Text(
                        '화면을 닫지 마세요',
                        style: context.bodySmall.copyWith(
                          color: DSColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: DSSpacing.sm),

                // 보조 안내
                Text(
                  '결제가 완료될 때까지 잠시 기다려주세요',
                  style: context.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 오버레이를 Stack과 함께 사용하는 헬퍼 메서드
  static Widget wrapWithOverlay({
    required Widget child,
    required bool isLoading,
    String? loadingMessage,
  }) {
    return Stack(
      children: [
        child,
        PurchaseLoadingOverlay(
          isVisible: isLoading,
          message: loadingMessage,
        ),
      ],
    );
  }
}
