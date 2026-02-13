import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/widgets/unified_button.dart';
import '../../../../../../core/widgets/unified_button_enums.dart';
import '../../../../../../services/health_data_service.dart';

/// Health 액센트 색상 (건강 도메인)
const Color _healthAccent = Color(0xFF38A169); // 고유 색상 - Health 앱 연동 액센트
const Color _healthAccentLight =
    Color(0xFF68D391); // 고유 색상 - Health 앱 연동 액센트 라이트

class HealthAppConnectionSection extends StatelessWidget {
  final bool isPremium;
  final bool isLoadingHealthData;
  final HealthSummary? healthSummary;
  final VoidCallback onConnect;
  final VoidCallback onRefresh;

  const HealthAppConnectionSection({
    super.key,
    required this.isPremium,
    required this.isLoadingHealthData,
    required this.healthSummary,
    required this.onConnect,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    final platformName = Platform.isIOS ? 'Apple Health' : 'Google Fit';
    final platformIcon =
        Platform.isIOS ? Icons.favorite_rounded : Icons.fitness_center_rounded;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isPremium
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _healthAccent.withValues(alpha: 0.08),
                  _healthAccentLight.withValues(alpha: 0.05),
                ],
              )
            : null,
        color: isPremium
            ? null
            : (context.isDark
                ? DSColors.backgroundSecondary.withValues(alpha: 0.5)
                : DSColors.backgroundSecondaryDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPremium
              ? _healthAccent.withValues(alpha: 0.3)
              : (context.isDark
                  ? DSColors.border.withValues(alpha: 0.5)
                  : DSColors.borderDark),
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
                      ? _healthAccent.withValues(alpha: 0.15)
                      : (context.isDark
                          ? DSColors.backgroundSecondary
                          : DSColors.backgroundDark),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  platformIcon,
                  color: isPremium ? _healthAccent : DSColors.textSecondary,
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
                          style: typography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _healthAccent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'PREMIUM',
                            style: typography.labelTiny.copyWith(
                              color: Colors.white,
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
                      style: typography.bodySmall.copyWith(
                        fontWeight: FontWeight.w400,
                        color: context.colors.textSecondary,
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
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _healthAccent,
                          ),
                        )
                      : Icon(platformIcon, size: 18, color: _healthAccent),
                ),
              ),
            ],
          ] else ...[
            // 비프리미엄: 잠금 표시
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.isDark
                    ? DSColors.backgroundSecondary.withValues(alpha: 0.7)
                    : DSColors.backgroundDark.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_rounded,
                    color: context.colors.textSecondary,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '프리미엄 구독 시 사용 가능',
                    style: typography.bodySmall.copyWith(
                      fontWeight: FontWeight.w400,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }
}

class ConnectedHealthDataSummary extends StatelessWidget {
  final HealthSummary healthSummary;
  final VoidCallback onRefresh;

  const ConnectedHealthDataSummary({
    super.key,
    required this.healthSummary,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.isDark
            ? DSColors.backgroundSecondary
            : DSColors.backgroundDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: _healthAccent,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '건강 데이터 연동됨',
                style: typography.bodySmall.copyWith(
                  color: _healthAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onRefresh,
                child: const Icon(
                  Icons.refresh_rounded,
                  color: _healthAccent,
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
                ),
              if (healthSummary.averageSleepHours != null)
                HealthDataChip(
                  text:
                      '😴 ${healthSummary.averageSleepHours!.toStringAsFixed(1)}시간',
                ),
              if (healthSummary.averageHeartRate != null)
                HealthDataChip(
                  text: '❤️ ${healthSummary.averageHeartRate}bpm',
                ),
              if (healthSummary.weightKg != null)
                HealthDataChip(
                  text: '⚖️ ${healthSummary.weightKg!.toStringAsFixed(1)}kg',
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '이 데이터가 건강운세 분석에 활용됩니다',
            style: typography.labelTiny.copyWith(
              fontWeight: FontWeight.w400,
              color: context.colors.textSecondary,
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

  const HealthDataChip({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.isDark
            ? DSColors.border.withValues(alpha: 0.5)
            : DSColors.backgroundSecondaryDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: typography.bodySmall.copyWith(
          color: context.colors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
