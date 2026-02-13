import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/core/theme/typography_theme.dart';
import 'package:fortune/core/providers/user_settings_provider.dart';
import 'package:fortune/core/design_system/design_system.dart';
import '../../../../core/services/fortune_haptic_service.dart';

/// 폰트 설정 페이지
/// 사용자가 폰트 크기와 글꼴을 조절할 수 있습니다.
class FontSettingsPage extends ConsumerWidget {
  const FontSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(userSettingsProvider);
    final settingsNotifier = ref.read(userSettingsProvider.notifier);
    final typography = ref.watch(typographyThemeProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(
          color: context.colors.textPrimary,
        ),
        title: Text(
          '폰트 설정',
          style: typography.titleLarge.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DSSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========================================
            // 1. 폰트 크기 미리보기
            // ========================================
            Container(
              padding: const EdgeInsets.all(DSSpacing.lg),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(DSRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '미리보기',
                    style: typography.labelMedium.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.md),
                  Text(
                    '제목 텍스트',
                    style: typography.headingMedium.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.sm),
                  Text(
                    '본문 텍스트입니다. 이 텍스트는 일반적인 본문에 사용됩니다.',
                    style: typography.bodyMedium.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.sm),
                  Text(
                    '작은 텍스트 - 캡션이나 부가 설명',
                    style: typography.labelSmall.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: DSSpacing.xl),

            // ========================================
            // 2. 폰트 크기 조절
            // ========================================
            Text(
              '폰트 크기',
              style: typography.titleMedium.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: DSSpacing.md),

            // 폰트 크기 슬라이더
            Container(
              padding: const EdgeInsets.all(DSSpacing.lg),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(DSRadius.md),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '현재 크기',
                        style: typography.labelMedium.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                      Text(
                        '${(settings.fontScale * 100).toInt()}%',
                        style: typography.titleSmall.copyWith(
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DSSpacing.md),
                  Row(
                    children: [
                      // 감소 버튼
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        color: settings.fontScale <= 0.85
                            ? context.colors.textTertiary
                            : DSColors.accentDark,
                        onPressed: settings.fontScale <= 0.85
                            ? null
                            : () {
                                DSHaptics.light();
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
                          activeColor: DSColors.accentDark,
                          inactiveColor: context.colors.divider,
                          onChanged: (value) {
                            // 스냅 포인트 변경 시에만 햅틱 피드백
                            final oldStep =
                                ((settings.fontScale - 0.85) / 0.05).round();
                            final newStep = ((value - 0.85) / 0.05).round();
                            if (oldStep != newStep) {
                              ref
                                  .read(fortuneHapticServiceProvider)
                                  .sliderSnap();
                            }
                            settingsNotifier.setFontScale(value);
                          },
                        ),
                      ),
                      // 증가 버튼
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        color: settings.fontScale >= 1.3
                            ? context.colors.textTertiary
                            : DSColors.accentDark,
                        onPressed: settings.fontScale >= 1.3
                            ? null
                            : () {
                                DSHaptics.light();
                                settingsNotifier.increaseFontScale();
                              },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: DSSpacing.md),

            // 프리셋 버튼들
            Wrap(
              spacing: DSSpacing.sm,
              runSpacing: DSSpacing.sm,
              children: TypographyTheme.fontScalePresets.entries.map((entry) {
                final isSelected =
                    (settings.fontScale - entry.value).abs() < 0.01;
                return _PresetButton(
                  label: TypographyTheme.fontScaleLabels[entry.key]!,
                  isSelected: isSelected,
                  onPressed: () {
                    DSHaptics.medium();
                    settingsNotifier.setFontScalePreset(entry.key);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: DSSpacing.xl),

            // ========================================
            // 3. 리셋 버튼
            // ========================================
            SizedBox(
              width: double.infinity,
              height: 48.0,
              child: OutlinedButton(
                onPressed: () {
                  DSHaptics.medium();
                  settingsNotifier.reset();
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: context.colors.border,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DSRadius.md),
                  ),
                ),
                child: Text(
                  '기본 설정으로 되돌리기',
                  style: typography.labelLarge.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: DSSpacing.lg),

            // 안내 텍스트
            Text(
              '폰트 크기 설정은 앱 전체에 적용됩니다. 가독성을 위해 권장 크기는 100%입니다.',
              style: typography.labelSmall.copyWith(
                color: context.colors.textTertiary,
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
  final VoidCallback onPressed;

  const _PresetButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(DSRadius.smd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? DSColors.accentDark : context.colors.surface,
          borderRadius: BorderRadius.circular(DSRadius.smd),
          border: Border.all(
            color: isSelected ? DSColors.accentDark : context.colors.border,
          ),
        ),
        child: Text(
          label,
          style: context.bodySmall.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : context.colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
