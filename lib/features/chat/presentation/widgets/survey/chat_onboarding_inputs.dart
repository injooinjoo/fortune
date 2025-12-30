import 'package:flutter/material.dart';
import '../../../../../constants/fortune_constants.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../providers/onboarding_chat_provider.dart';

/// 성별 선택 위젯 (PASS 가능)
class OnboardingGenderSelector extends StatelessWidget {
  final void Function(Gender? gender) onSelect;

  const OnboardingGenderSelector({
    super.key,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 성별 칩들
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: Gender.values.map((gender) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xs),
                child: _SelectionChip(
                  label: gender.label,
                  icon: gender.icon,
                  onTap: () {
                    DSHaptics.light();
                    onSelect(gender);
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: DSSpacing.sm),
          // 건너뛰기 버튼
          TextButton(
            onPressed: () {
              DSHaptics.light();
              onSelect(null);
            },
            child: Text(
              '건너뛰기',
              style: typography.labelMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// MBTI 선택 위젯 (PASS 가능)
class OnboardingMbtiSelector extends StatelessWidget {
  final void Function(String? mbti) onSelect;

  const OnboardingMbtiSelector({
    super.key,
    required this.onSelect,
  });

  static const List<String> mbtiTypes = [
    'ISTJ', 'ISFJ', 'INFJ', 'INTJ',
    'ISTP', 'ISFP', 'INFP', 'INTP',
    'ESTP', 'ESFP', 'ENFP', 'ENTP',
    'ESTJ', 'ESFJ', 'ENFJ', 'ENTJ',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // MBTI 그리드 (4x4)
          Wrap(
            spacing: DSSpacing.xs,
            runSpacing: DSSpacing.xs,
            alignment: WrapAlignment.center,
            children: mbtiTypes.map((type) {
              return _SelectionChip(
                label: type,
                onTap: () {
                  DSHaptics.light();
                  onSelect(type);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: DSSpacing.sm),
          // 건너뛰기 버튼
          TextButton(
            onPressed: () {
              DSHaptics.light();
              onSelect(null);
            },
            child: Text(
              '모르겠어요 / 건너뛰기',
              style: typography.labelMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 혈액형 선택 위젯 (PASS 가능)
class OnboardingBloodTypeSelector extends StatelessWidget {
  final void Function(String? bloodType) onSelect;

  const OnboardingBloodTypeSelector({
    super.key,
    required this.onSelect,
  });

  static const List<String> bloodTypes = ['A형', 'B형', 'O형', 'AB형'];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 혈액형 칩들
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: bloodTypes.map((type) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xs),
                child: _SelectionChip(
                  label: type,
                  onTap: () {
                    DSHaptics.light();
                    onSelect(type);
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: DSSpacing.sm),
          // 건너뛰기 버튼
          TextButton(
            onPressed: () {
              DSHaptics.light();
              onSelect(null);
            },
            child: Text(
              '모르겠어요 / 건너뛰기',
              style: typography.labelMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 정보 확인 카드 (맞아요 / 처음부터)
class OnboardingConfirmationCard extends StatelessWidget {
  final OnboardingState state;
  final VoidCallback onConfirm;
  final VoidCallback onRestart;

  const OnboardingConfirmationCard({
    super.key,
    required this.state,
    required this.onConfirm,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 버튼들
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    DSHaptics.light();
                    onRestart();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textSecondary,
                    side: BorderSide(color: colors.textSecondary.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
                  ),
                  child: Text('처음부터', style: typography.labelLarge),
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    DSHaptics.medium();
                    onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
                  ),
                  child: Text('맞아요!', style: typography.labelLarge),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 로그인/회원가입 유도 카드
class OnboardingLoginPromptCard extends StatelessWidget {
  final VoidCallback onSignUp;
  final VoidCallback onSkip;

  const OnboardingLoginPromptCard({
    super.key,
    required this.onSignUp,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 혜택 아이콘
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _BenefitItem(icon: Icons.cloud_outlined, label: '기록 보관'),
              const SizedBox(width: DSSpacing.lg),
              _BenefitItem(icon: Icons.devices_outlined, label: '기기 동기화'),
              const SizedBox(width: DSSpacing.lg),
              _BenefitItem(icon: Icons.star_outline, label: '프리미엄 기능'),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          // 회원가입 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                DSHaptics.medium();
                onSignUp();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
              ),
              child: Text('회원가입', style: typography.labelLarge),
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          // 나중에 버튼
          TextButton(
            onPressed: () {
              DSHaptics.light();
              onSkip();
            },
            child: Text(
              '나중에 할게요',
              style: typography.labelMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 혜택 아이템 위젯
class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BenefitItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: colors.accentSecondary),
        const SizedBox(height: DSSpacing.xxs),
        Text(
          label,
          style: typography.labelSmall.copyWith(
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// 공통 선택 칩 위젯
class _SelectionChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const _SelectionChip({
    required this.label,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.sm,
            vertical: DSSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isDark ? colors.backgroundSecondary : colors.surface,
            borderRadius: BorderRadius.circular(DSRadius.lg),
            border: Border.all(
              color: colors.textPrimary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: colors.textSecondary),
                const SizedBox(width: DSSpacing.xs),
              ],
              Text(
                label,
                style: typography.labelMedium.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
