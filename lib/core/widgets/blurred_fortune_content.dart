import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/toss_design_system.dart';
import '../theme/typography_unified.dart';
import '../models/fortune_result.dart';

/// 블러 처리된 운세 콘텐츠 위젯
///
/// FortuneResult.blurredSections에 명시된 섹션만 블러 처리하고
/// 광고 시청 후 블러 해제 애니메이션 제공
class BlurredFortuneContent extends StatelessWidget {
  final FortuneResult fortuneResult;
  final Widget child;
  final VoidCallback? onUnlockTap;

  const BlurredFortuneContent({
    super.key,
    required this.fortuneResult,
    required this.child,
    this.onUnlockTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 블러 상태가 아니면 그냥 child 반환
    if (!fortuneResult.isBlurred) {
      return child;
    }

    // 블러 처리된 콘텐츠
    return Stack(
      children: [
        // 원본 콘텐츠 (블러 처리)
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),

        // 반투명 오버레이
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  (isDark
                      ? TossDesignSystem.backgroundDark
                      : TossDesignSystem.backgroundLight)
                      .withValues(alpha: 0.3),
                  (isDark
                      ? TossDesignSystem.backgroundDark
                      : TossDesignSystem.backgroundLight)
                      .withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
        ),

        // 중앙 잠금 해제 버튼
        Positioned.fill(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 잠금 아이콘
                Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: (isDark
                      ? TossDesignSystem.textPrimaryDark
                      : TossDesignSystem.textPrimaryLight)
                      .withValues(alpha: 0.6),
                ).animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 2000.ms, color: TossDesignSystem.tossBlue.withValues(alpha: 0.3)),

                const SizedBox(height: 16),

                // 안내 텍스트
                Text(
                  '운세의 중요한 내용이 잠겨있어요',
                  style: TypographyUnified.bodyLarge.copyWith(
                    color: isDark
                        ? TossDesignSystem.textPrimaryDark
                        : TossDesignSystem.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${fortuneResult.blurredSections.length}개의 핵심 정보를 확인하려면\n5초만 기다려주세요',
                  style: TypographyUnified.bodySmall.copyWith(
                    color: (isDark
                        ? TossDesignSystem.textSecondaryDark
                        : TossDesignSystem.textSecondaryLight),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // 잠금 해제 버튼
                if (onUnlockTap != null)
                  ElevatedButton.icon(
                    onPressed: onUnlockTap,
                    icon: const Icon(Icons.play_arrow, size: 20),
                    label: Text(
                      '광고 보고 잠금 해제',
                      style: TypographyUnified.buttonMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TossDesignSystem.tossBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ).animate()
                      .fadeIn(duration: 300.ms)
                      .scale(begin: const Offset(0.8, 0.8), duration: 300.ms),

                const SizedBox(height: 16),

                // 블러된 섹션 목록 표시
                _buildBlurredSectionsList(isDark),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 블러된 섹션 목록 표시
  Widget _buildBlurredSectionsList(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: (isDark
            ? TossDesignSystem.gray900
            : TossDesignSystem.gray100)
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark
              ? TossDesignSystem.gray700
              : TossDesignSystem.gray300)
              .withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Text(
            '🔒 잠긴 정보',
            style: TypographyUnified.labelMedium.copyWith(
              color: isDark
                  ? TossDesignSystem.textSecondaryDark
                  : TossDesignSystem.textSecondaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...fortuneResult.blurredSections.map<Widget>((section) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock,
                    size: 14,
                    color: (isDark
                        ? TossDesignSystem.textTertiaryDark
                        : TossDesignSystem.textTertiaryLight),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getSectionDisplayName(section),
                    style: TypographyUnified.labelSmall.copyWith(
                      color: isDark
                          ? TossDesignSystem.textTertiaryDark
                          : TossDesignSystem.textTertiaryLight,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// 섹션 키를 사용자 친화적 이름으로 변환
  String _getSectionDisplayName(String sectionKey) {
    const Map<String, String> displayNames = {
      'interpretation': '카드 해석',
      'advice': '조언',
      'future_outlook': '미래 전망',
      'today_advice': '오늘의 조언',
      'luck_items': '행운 아이템',
      'warnings': '주의사항',
      'personality_insights': '성격 분석',
      'lucky_color': '행운의 색',
      'compatibility_score': '궁합 점수',
      'relationship_advice': '관계 조언',
      'future_prediction': '미래 예측',
      'direction_analysis': '방향 분석',
      'moving_advice': '이사 조언',
      'auspicious_dates': '길일',
      'career_path': '커리어 경로',
      'success_factors': '성공 요인',
      'growth_advice': '성장 조언',
      'health_advice': '건강 조언',
      'precautions': '주의사항',
      'wellness_tips': '웰니스 팁',
      'study_tips': '공부 팁',
      'success_probability': '성공 확률',
      'recommended_subjects': '추천 과목',
      'details': '상세 내용',
      'recommendations': '추천사항',
    };

    return displayNames[sectionKey] ?? sectionKey;
  }
}

/// 블러 해제 애니메이션 위젯
///
/// 광고 시청 후 블러가 해제되는 애니메이션 효과
class UnblurAnimation extends StatelessWidget {
  final Widget child;
  final bool isUnblurring;

  const UnblurAnimation({
    super.key,
    required this.child,
    this.isUnblurring = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isUnblurring) {
      return child;
    }

    return child
        .animate()
        .fadeIn(duration: 500.ms)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.0, 1.0),
          duration: 500.ms,
        );
  }
}
