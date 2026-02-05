import 'package:flutter/material.dart';
import '../../../../../constants/fortune_constants.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../domain/models/life_category.dart';
import '../../providers/onboarding_chat_provider.dart';

/// 인생 컨설팅 대분류 선택 위젯
class OnboardingLifeCategorySelector extends StatelessWidget {
  final void Function(LifeCategory category) onSelect;

  const OnboardingLifeCategorySelector({
    super.key,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 2x2 그리드
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: DSSpacing.sm,
            crossAxisSpacing: DSSpacing.sm,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.2,
            children: LifeCategory.values.map((category) {
              return _LifeCategoryChip(
                category: category,
                onTap: () {
                  DSHaptics.medium();
                  onSelect(category);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// 인생 컨설팅 대분류 칩
class _LifeCategoryChip extends StatelessWidget {
  final LifeCategory category;
  final VoidCallback onTap;

  const _LifeCategoryChip({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = context.isDark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.md,
            vertical: DSSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? category.color.withValues(alpha: 0.15)
                : category.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DSRadius.lg),
            border: Border.all(
              color: category.color.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                category.icon,
                size: 20,
                color: category.color,
              ),
              const SizedBox(width: DSSpacing.xs),
              Text(
                category.label,
                style: typography.labelLarge.copyWith(
                  color: isDark ? colors.textPrimary : category.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 세부 고민 선택 위젯
class OnboardingSubConcernSelector extends StatelessWidget {
  final LifeCategory category;
  final void Function(String concernId) onSelect;

  const OnboardingSubConcernSelector({
    super.key,
    required this.category,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final concerns = subConcernsByCategory[category] ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: DSSpacing.xs,
            runSpacing: DSSpacing.xs,
            alignment: WrapAlignment.center,
            children: concerns.map((concern) {
              return _SubConcernChip(
                label: concern.label,
                color: category.color,
                onTap: () {
                  DSHaptics.light();
                  onSelect(concern.id);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// 세부 고민 칩
class _SubConcernChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SubConcernChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = context.isDark;

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
            color: isDark
                ? color.withValues(alpha: 0.1)
                : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(DSRadius.lg),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: typography.labelMedium.copyWith(
              color: isDark ? colors.textPrimary : color,
            ),
          ),
        ),
      ),
    );
  }
}

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
    final isDark = context.isDark;

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
