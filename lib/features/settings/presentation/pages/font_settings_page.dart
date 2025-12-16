import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/typography_theme.dart';
import 'package:fortune/core/providers/user_settings_provider.dart';
import '../../../../core/design_system/design_system.dart';

/// 폰트 설정 페이지
/// 사용자가 폰트 크기와 글꼴을 조절할 수 있습니다.
class FontSettingsPage extends ConsumerWidget {
  const FontSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(userSettingsProvider);
    final settingsNotifier = ref.read(userSettingsProvider.notifier);
    final typography = ref.watch(typographyThemeProvider);

    return Scaffold(
      backgroundColor: isDark
          ? TossDesignSystem.backgroundDark
          : TossDesignSystem.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark
            ? TossDesignSystem.backgroundDark
            : TossDesignSystem.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(
          color: isDark
              ? TossDesignSystem.textPrimaryDark
              : TossDesignSystem.textPrimaryLight,
        ),
        title: Text(
          '폰트 설정',
          style: typography.titleLarge.copyWith(
            color: isDark
                ? TossDesignSystem.textPrimaryDark
                : TossDesignSystem.textPrimaryLight,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TossDesignSystem.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========================================
            // 1. 폰트 크기 미리보기
            // ========================================
            Container(
              padding: const EdgeInsets.all(TossDesignSystem.spacingL),
              decoration: BoxDecoration(
                color: isDark
                    ? TossDesignSystem.cardBackgroundDark
                    : TossDesignSystem.cardBackgroundLight,
                borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '미리보기',
                    style: typography.labelMedium.copyWith(
                      color: isDark
                          ? TossDesignSystem.textSecondaryDark
                          : TossDesignSystem.textSecondaryLight,
                    ),
                  ),
                  SizedBox(height: TossDesignSystem.spacingM),
                  Text(
                    '제목 텍스트',
                    style: typography.headingMedium.copyWith(
                      color: isDark
                          ? TossDesignSystem.textPrimaryDark
                          : TossDesignSystem.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: TossDesignSystem.spacingS),
                  Text(
                    '본문 텍스트입니다. 이 텍스트는 일반적인 본문에 사용됩니다.',
                    style: typography.bodyMedium.copyWith(
                      color: isDark
                          ? TossDesignSystem.textPrimaryDark
                          : TossDesignSystem.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: TossDesignSystem.spacingS),
                  Text(
                    '작은 텍스트 - 캡션이나 부가 설명',
                    style: typography.labelSmall.copyWith(
                      color: isDark
                          ? TossDesignSystem.textSecondaryDark
                          : TossDesignSystem.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: TossDesignSystem.spacingXL),

            // ========================================
            // 2. 폰트 크기 조절
            // ========================================
            Text(
              '폰트 크기',
              style: typography.titleMedium.copyWith(
                color: isDark
                    ? TossDesignSystem.textPrimaryDark
                    : TossDesignSystem.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: TossDesignSystem.spacingM),

            // 폰트 크기 슬라이더
            Container(
              padding: const EdgeInsets.all(TossDesignSystem.spacingL),
              decoration: BoxDecoration(
                color: isDark
                    ? TossDesignSystem.cardBackgroundDark
                    : TossDesignSystem.cardBackgroundLight,
                borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '현재 크기',
                        style: typography.labelMedium.copyWith(
                          color: isDark
                              ? TossDesignSystem.textSecondaryDark
                              : TossDesignSystem.textSecondaryLight,
                        ),
                      ),
                      Text(
                        '${(settings.fontScale * 100).toInt()}%',
                        style: typography.titleSmall.copyWith(
                          color: isDark
                              ? TossDesignSystem.textPrimaryDark
                              : TossDesignSystem.textPrimaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TossDesignSystem.spacingM),
                  Row(
                    children: [
                      // 감소 버튼
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        color: settings.fontScale <= 0.85
                            ? (isDark
                                ? TossDesignSystem.textTertiaryDark
                                : TossDesignSystem.textTertiaryLight)
                            : TossDesignSystem.tossBlue,
                        onPressed: settings.fontScale <= 0.85
                            ? null
                            : () {
                                TossDesignSystem.hapticLight();
                                settingsNotifier.decreaseFontScale();
                              },
                      ),
                      // 슬라이더
                      Expanded(
                        child: Slider(
                          value: settings.fontScale,
                          min: 0.85,
                          max: 1.3,
                          divisions: 9,
                          activeColor: TossDesignSystem.tossBlue,
                          inactiveColor: isDark
                              ? TossDesignSystem.dividerDark
                              : TossDesignSystem.dividerLight,
                          onChanged: (value) {
                            TossDesignSystem.hapticSelection();
                            settingsNotifier.setFontScale(value);
                          },
                        ),
                      ),
                      // 증가 버튼
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        color: settings.fontScale >= 1.3
                            ? (isDark
                                ? TossDesignSystem.textTertiaryDark
                                : TossDesignSystem.textTertiaryLight)
                            : TossDesignSystem.tossBlue,
                        onPressed: settings.fontScale >= 1.3
                            ? null
                            : () {
                                TossDesignSystem.hapticLight();
                                settingsNotifier.increaseFontScale();
                              },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: TossDesignSystem.spacingM),

            // 프리셋 버튼들
            Wrap(
              spacing: TossDesignSystem.spacingS,
              runSpacing: TossDesignSystem.spacingS,
              children: TypographyTheme.fontScalePresets.entries.map((entry) {
                final isSelected =
                    (settings.fontScale - entry.value).abs() < 0.01;
                return _PresetButton(
                  label: TypographyTheme.fontScaleLabels[entry.key]!,
                  isSelected: isSelected,
                  isDark: isDark,
                  onPressed: () {
                    TossDesignSystem.hapticMedium();
                    settingsNotifier.setFontScalePreset(entry.key);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: TossDesignSystem.spacingXL),

            // ========================================
            // 3. 리셋 버튼
            // ========================================
            SizedBox(
              width: double.infinity,
              height: TossDesignSystem.buttonHeightMedium,
              child: OutlinedButton(
                onPressed: () {
                  TossDesignSystem.hapticMedium();
                  settingsNotifier.reset();
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isDark
                        ? TossDesignSystem.borderDark
                        : TossDesignSystem.borderLight,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(TossDesignSystem.radiusM),
                  ),
                ),
                child: Text(
                  '기본 설정으로 되돌리기',
                  style: typography.labelLarge.copyWith(
                    color: isDark
                        ? TossDesignSystem.textPrimaryDark
                        : TossDesignSystem.textPrimaryLight,
                  ),
                ),
              ),
            ),

            const SizedBox(height: TossDesignSystem.spacingL),

            // 안내 텍스트
            Text(
              '폰트 크기 설정은 앱 전체에 적용됩니다. 가독성을 위해 권장 크기는 100%입니다.',
              style: typography.labelSmall.copyWith(
                color: isDark
                    ? TossDesignSystem.textTertiaryDark
                    : TossDesignSystem.textTertiaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 프리셋 버튼 위젯
class _PresetButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onPressed;

  const _PresetButton({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(TossDesignSystem.radiusS),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TossDesignSystem.spacingM,
          vertical: TossDesignSystem.spacingS,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? TossDesignSystem.tossBlue
              : (isDark
                  ? TossDesignSystem.cardBackgroundDark
                  : TossDesignSystem.cardBackgroundLight),
          borderRadius: BorderRadius.circular(TossDesignSystem.radiusS),
          border: Border.all(
            color: isSelected
                ? TossDesignSystem.tossBlue
                : (isDark
                    ? TossDesignSystem.borderDark
                    : TossDesignSystem.borderLight),
          ),
        ),
        child: Text(
          label,
          style: DSTypography.bodySmall.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? TossDesignSystem.white
                : (isDark
                    ? TossDesignSystem.textPrimaryDark
                    : TossDesignSystem.textPrimaryLight),
          ),
        ),
      ),
    );
  }
}
