import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../domain/models/face_reading_result_v2.dart';

/// Apple Watch 데이터 미리보기 카드
/// Watch에서 표시될 정보를 앱에서 미리 보여줍니다.
///
/// 핵심 가치: 위로·공감·공유 (자기계발 ❌)
/// 타겟: 2-30대 여성
class WatchDataPreviewCard extends StatelessWidget {
  /// Watch 데이터
  final WatchFaceReadingData watchData;

  /// Watch 앱 연결 상태
  final bool isWatchConnected;

  /// Watch로 동기화 콜백
  final VoidCallback? onSyncToWatch;

  const WatchDataPreviewCard({
    super.key,
    required this.watchData,
    this.isWatchConnected = false,
    this.onSyncToWatch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A1A), // Watch 배경 느낌
            Color(0xFF2A2A2A),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          _buildHeader(context),
          const SizedBox(height: 20),

          // Watch 미리보기
          _buildWatchPreview(context),
          const SizedBox(height: 20),

          // 리마인더 메시지
          _buildReminderMessage(context),
          const SizedBox(height: DSSpacing.md),

          // 동기화 버튼
          if (onSyncToWatch != null) _buildSyncButton(context),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  /// 헤더 빌드
  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        // Watch 아이콘
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.watch,
            color: colors.textPrimary,
            size: 20,
          ),
        ),
        const SizedBox(width: DSSpacing.sm + 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apple Watch',
                style: context.labelMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '오늘의 행운 정보',
                style: context.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // 연결 상태
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isWatchConnected
                ? DSColors.success.withValues(alpha: 0.2)
                : colors.surface.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isWatchConnected ? DSColors.success : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: DSSpacing.xs),
              Text(
                isWatchConnected ? '연결됨' : '연결 안됨',
                style: context.labelSmall.copyWith(
                  color: isWatchConnected
                      ? DSColors.success
                      : colors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Watch 미리보기
  Widget _buildWatchPreview(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          color: colors.background,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.shade800,
            width: 8,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 행운 방향
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.explore,
                    color: colors.textSecondary,
                    size: 14,
                  ),
                  const SizedBox(width: DSSpacing.xs),
                  Text(
                    watchData.luckyDirection,
                    style: context.labelSmall.copyWith(
                      color: colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DSSpacing.sm),

              // 행운 색상
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _parseColor(watchData.luckyColor.colorCode),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.border,
                        width: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    watchData.luckyColor.colorName,
                    style: context.labelSmall.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 컨디션 점수
              Text(
                '${watchData.conditionScore}',
                style: context.displaySmall.copyWith(
                  color: DSColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '컨디션',
                style: context.labelSmall.copyWith(
                  color: colors.textSecondary,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: DSSpacing.sm),

              // 행운 시간
              Text(
                watchData.luckyTimePeriods.isNotEmpty
                    ? watchData.luckyTimePeriods.first
                    : '',
                style: context.labelSmall.copyWith(
                  color: colors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 리마인더 메시지
  Widget _buildReminderMessage(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DSColors.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('🧘', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: DSSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 리마인더',
                  style: context.labelSmall.copyWith(
                    color: colors.textSecondary,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: DSSpacing.xxs),
                Text(
                  watchData.dailyReminderMessage,
                  style: context.bodySmall.copyWith(
                    color: colors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 동기화 버튼
  Widget _buildSyncButton(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onSyncToWatch,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [DSColors.accent, DSColors.accentSecondary],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sync,
              color: colors.textPrimary,
              size: 18,
            ),
            const SizedBox(width: DSSpacing.sm),
            Text(
              'Watch에 동기화',
              style: context.labelMedium.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 색상 파싱
  Color _parseColor(String colorCode) {
    try {
      if (colorCode.startsWith('#')) {
        return Color(int.parse(colorCode.replaceFirst('#', '0xFF')));
      }
      return DSColors.accent;
    } catch (e) {
      return DSColors.accent;
    }
  }
}

/// 간단한 Watch 컴플리케이션 위젯
class WatchComplicationWidget extends StatelessWidget {
  /// 컨디션 점수
  final int conditionScore;

  /// 행운 색상 코드
  final String luckyColorCode;

  /// 크기
  final double size;

  const WatchComplicationWidget({
    super.key,
    required this.conditionScore,
    required this.luckyColorCode,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        shape: BoxShape.circle,
        border: Border.all(
          color: _parseColor(luckyColorCode).withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$conditionScore',
              style: TextStyle(
                color: _parseColor(luckyColorCode),
                fontSize: size * 0.3,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '컨디션',
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: size * 0.12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String colorCode) {
    try {
      if (colorCode.startsWith('#')) {
        return Color(int.parse(colorCode.replaceFirst('#', '0xFF')));
      }
      return DSColors.accent;
    } catch (e) {
      return DSColors.accent;
    }
  }
}

/// Watch 행운 정보 요약 위젯
class WatchLuckySummary extends StatelessWidget {
  final WatchFaceReadingData watchData;

  const WatchLuckySummary({
    super.key,
    required this.watchData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.isDark ? DSColors.surfaceDark : DSColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.isDark ? DSColors.borderDark : DSColors.border,
        ),
      ),
      child: Row(
        children: [
          // 방향
          _buildItem(
            context,
            icon: Icons.explore,
            label: '방향',
            value: watchData.luckyDirection,
          ),
          _buildDivider(context),
          // 색상
          _buildColorItem(context),
          _buildDivider(context),
          // 시간
          _buildItem(
            context,
            icon: Icons.access_time,
            label: '행운 시간',
            value: watchData.luckyTimePeriods.isNotEmpty
                ? watchData.luckyTimePeriods.first
                : '-',
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: DSColors.accent,
            size: 18,
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            value,
            style: context.labelSmall.copyWith(
              color: context.isDark
                  ? DSColors.textPrimaryDark
                  : DSColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: context.labelSmall.copyWith(
              color: context.isDark
                  ? DSColors.textSecondaryDark
                  : DSColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorItem(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: _parseColor(watchData.luckyColor.colorCode),
              shape: BoxShape.circle,
              border: Border.all(
                color: context.isDark ? DSColors.borderDark : DSColors.border,
              ),
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            watchData.luckyColor.colorName,
            style: context.labelSmall.copyWith(
              color: context.isDark
                  ? DSColors.textPrimaryDark
                  : DSColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '행운 색상',
            style: context.labelSmall.copyWith(
              color: context.isDark
                  ? DSColors.textSecondaryDark
                  : DSColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: context.isDark ? DSColors.borderDark : DSColors.border,
    );
  }

  Color _parseColor(String colorCode) {
    try {
      if (colorCode.startsWith('#')) {
        return Color(int.parse(colorCode.replaceFirst('#', '0xFF')));
      }
      return DSColors.accent;
    } catch (e) {
      return DSColors.accent;
    }
  }
}
