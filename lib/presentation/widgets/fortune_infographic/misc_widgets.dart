import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/design_system/design_system.dart';

/// Miscellaneous widgets for fortune infographic
class MiscWidgets {
  MiscWidgets._();

  /// Action checklist (placeholder implementation)
  static Widget buildActionChecklist(
    List<Map<String, dynamic>>? actions, {
    required bool isDarkMode,
  }) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? DSColors.surfaceSecondary : DSColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? DSColors.border : DSColors.borderDark,
        ),
      ),
      child: Center(
        child: Text(
          '액션 체크리스트 준비 중...',
          style: TextStyle(
            color: isDarkMode ? DSColors.textTertiary : DSColors.textSecondaryDark,
          ),
        ),
      ),
    );
  }

  /// Weather fortune widget
  static Widget buildWeatherFortune(
    Map<String, dynamic>? weatherSummary,
    int score,
  ) {
    return Builder(
      builder: (context) {
        final isDark = context.isDark;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? DSColors.surfaceSecondary : DSColors.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? DSColors.border : DSColors.borderDark,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.wb_sunny,
                    color: DSColors.warning,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '날씨 운세',
                    style: context.headingSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? DSColors.textPrimary : DSColors.textPrimaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                weatherSummary?['description'] ?? '오늘의 날씨와 함께하는 운세를 확인해보세요.',
                style: context.bodySmall.copyWith(
                  color: isDark ? DSColors.surface : DSColors.textSecondaryDark,
                  height: 1.5,
                ),
              ),
              if (weatherSummary?['temperature'] != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: DSColors.accentDark.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '온도: ${weatherSummary!['temperature']}°C',
                    style: context.labelMedium.copyWith(
                      color: DSColors.accentDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ).animate()
          .fadeIn(duration: 600.ms)
          .slideY(begin: 0.1, curve: Curves.easeOut);
      },
    );
  }

  /// Shareable card (placeholder implementation)
  static Widget buildShareableCard(Map<String, dynamic>? shareCard) {
    return Builder(
      builder: (context) {
        final isDark = context.isDark;

        return Container(
          height: 180,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? DSColors.surfaceSecondary : DSColors.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? DSColors.border : DSColors.borderDark,
            ),
          ),
          child: Center(
            child: Text(
              '공유 카드 준비 중...',
              style: TextStyle(
                color: isDark ? DSColors.textTertiary : DSColors.textSecondaryDark,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Celebrity list (placeholder implementation)
  static Widget buildTossStyleCelebrityList({
    required String title,
    required String subtitle,
    required List<Map<String, dynamic>> celebrities,
  }) {
    return Builder(
      builder: (context) {
        final isDark = context.isDark;

        return Container(
          height: 140,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? DSColors.surfaceSecondary : DSColors.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? DSColors.border : DSColors.borderDark,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [DSColors.warning, DSColors.accentSecondary],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: isDark ? DSColors.textPrimary : DSColors.textPrimaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: isDark ? DSColors.textTertiary : DSColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Celebrity avatars placeholder
              Expanded(
                child: celebrities.isEmpty
                  ? Center(
                      child: Text(
                        '유사 사주 연예인 준비 중...',
                        style: TextStyle(
                          color: isDark ? DSColors.textTertiary : DSColors.textSecondaryDark,
                        ),
                      ),
                    )
                  : Row(
                      children: celebrities.take(4).map((celeb) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: isDark
                                ? DSColors.border
                                : DSColors.borderDark,
                            child: Text(
                              (celeb['name'] as String?)?.substring(0, 1) ?? '?',
                              style: TextStyle(
                                color: isDark ? DSColors.textPrimary : DSColors.textPrimaryDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Age fortune card (placeholder implementation)
  static Widget buildTossStyleAgeFortuneCard({
    required int userAge,
    String? ageDescription,
    int? ageScore,
  }) {
    return Builder(
      builder: (context) {
        final isDark = context.isDark;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? DSColors.surfaceSecondary : DSColors.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? DSColors.border : DSColors.borderDark,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.cake,
                    size: 20,
                    color: isDark ? DSColors.accent : DSColors.accentDark,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$userAge세 운세',
                    style: context.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? DSColors.textPrimary : DSColors.textPrimaryDark,
                    ),
                  ),
                  if (ageScore != null) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: DSColors.accentDark.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$ageScore점',
                        style: context.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: DSColors.accentDark,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Text(
                ageDescription ?? '나이별 운세 정보를 준비 중입니다.',
                style: context.bodySmall.copyWith(
                  color: isDark ? DSColors.textTertiary : DSColors.textSecondaryDark,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Share section (placeholder implementation)
  static Widget buildTossStyleShareSection({
    VoidCallback? onShare,
    VoidCallback? onSaveImage,
  }) {
    return Builder(
      builder: (context) {
        final isDark = context.isDark;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? DSColors.surfaceSecondary : DSColors.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? DSColors.border : DSColors.borderDark,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.share,
                    size: 20,
                    color: isDark ? DSColors.accent : DSColors.accentDark,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '운세 공유하기',
                    style: context.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? DSColors.textPrimary : DSColors.textPrimaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildShareButton(
                      context: context,
                      icon: Icons.share,
                      label: '공유',
                      onTap: onShare,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildShareButton(
                      context: context,
                      icon: Icons.save_alt,
                      label: '이미지 저장',
                      onTap: onSaveImage,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildShareButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: DSColors.accentDark.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: DSColors.accentDark,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: context.labelSmall.copyWith(
                color: DSColors.accentDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
