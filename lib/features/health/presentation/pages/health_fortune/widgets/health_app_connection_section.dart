import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/theme/toss_theme.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/widgets/unified_button.dart';
import '../../../../../../core/widgets/unified_button_enums.dart';
import '../../../../../../services/health_data_service.dart';

class HealthAppConnectionSection extends StatelessWidget {
  final bool isDark;
  final bool isPremium;
  final bool isLoadingHealthData;
  final HealthSummary? healthSummary;
  final VoidCallback onConnect;
  final VoidCallback onRefresh;

  const HealthAppConnectionSection({
    super.key,
    required this.isDark,
    required this.isPremium,
    required this.isLoadingHealthData,
    required this.healthSummary,
    required this.onConnect,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final platformName = Platform.isIOS ? 'Apple Health' : 'Google Fit';
    final platformIcon = Platform.isIOS ? Icons.favorite_rounded : Icons.fitness_center_rounded;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isPremium
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  TossTheme.primaryBlue.withValues(alpha: 0.1),
                  TossTheme.success.withValues(alpha: 0.1),
                ],
              )
            : null,
        color: isPremium ? null : (isDark ? TossDesignSystem.surfaceBackgroundDark : TossTheme.backgroundSecondary),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPremium
              ? TossTheme.primaryBlue.withValues(alpha: 0.3)
              : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isPremium
                      ? TossTheme.primaryBlue.withValues(alpha: 0.15)
                      : (isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  platformIcon,
                  color: isPremium ? TossTheme.primaryBlue : TossTheme.textGray600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$platformName 연동',
                          style: TossTheme.body2.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: TossTheme.primaryBlue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'PREMIUM',
                            style: TossTheme.caption.copyWith(
                              color: TossDesignSystem.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '건강 데이터로 더 정확한 분석',
                      style: TossTheme.caption.copyWith(
                        color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 프리미엄 사용자: 연결 버튼 또는 데이터 표시
          if (isPremium) ...[
            const SizedBox(height: 16),
            if (healthSummary != null) ...[
              // 연결된 건강 데이터 표시
              ConnectedHealthDataSummary(
                isDark: isDark,
                healthSummary: healthSummary!,
                onRefresh: onRefresh,
              ),
            ] else ...[
              // 연결 버튼
              SizedBox(
                width: double.infinity,
                child: UnifiedButton(
                  text: isLoadingHealthData ? '연결 중...' : '건강앱 연결하기',
                  onPressed: isLoadingHealthData ? null : onConnect,
                  style: UnifiedButtonStyle.secondary,
                  icon: isLoadingHealthData
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(platformIcon, size: 18),
                ),
              ),
            ],
          ] else ...[
            // 비프리미엄: 잠금 표시
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_rounded,
                    color: TossTheme.textGray600,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '프리미엄 구독 시 사용 가능',
                    style: TossTheme.caption.copyWith(
                      color: TossTheme.textGray600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate()
      .fadeIn(duration: 400.ms)
      .slideY(begin: -0.1, end: 0);
  }
}

class ConnectedHealthDataSummary extends StatelessWidget {
  final bool isDark;
  final HealthSummary healthSummary;
  final VoidCallback onRefresh;

  const ConnectedHealthDataSummary({
    super.key,
    required this.isDark,
    required this.healthSummary,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: TossTheme.success,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '건강 데이터 연동됨',
                style: TossTheme.caption.copyWith(
                  color: TossTheme.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onRefresh,
                child: Icon(
                  Icons.refresh_rounded,
                  color: TossTheme.primaryBlue,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 건강 데이터 요약
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (healthSummary.todaySteps != null)
                HealthDataChip(
                  text: '👣 ${_formatNumber(healthSummary.todaySteps!)}보',
                  isDark: isDark,
                ),
              if (healthSummary.averageSleepHours != null)
                HealthDataChip(
                  text: '😴 ${healthSummary.averageSleepHours!.toStringAsFixed(1)}시간',
                  isDark: isDark,
                ),
              if (healthSummary.averageHeartRate != null)
                HealthDataChip(
                  text: '❤️ ${healthSummary.averageHeartRate}bpm',
                  isDark: isDark,
                ),
              if (healthSummary.weightKg != null)
                HealthDataChip(
                  text: '⚖️ ${healthSummary.weightKg!.toStringAsFixed(1)}kg',
                  isDark: isDark,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '이 데이터가 건강운세 분석에 활용됩니다',
            style: TossTheme.caption.copyWith(
              color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}

class HealthDataChip extends StatelessWidget {
  final String text;
  final bool isDark;

  const HealthDataChip({
    super.key,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.surfaceBackgroundDark : TossTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TossTheme.caption.copyWith(
          color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
