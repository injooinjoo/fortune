import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/tokens/ds_spacing.dart';
import 'package:fortune/core/design_system/theme/ds_extensions.dart';

/// 카테고리 막대 차트 위젯
///
/// 여러 카테고리의 점수를 막대 그래프로 표현합니다.
/// 수평/수직 레이아웃을 지원합니다.
class CategoryBarChart extends StatefulWidget {
  const CategoryBarChart({
    super.key,
    required this.categories,
    this.maxValue = 100,
    this.barHeight = 8,
    this.showValues = true,
    this.showIcons = true,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 600),
    this.compact = false,
  });

  /// 카테고리 목록
  final List<CategoryData> categories;

  /// 최대값
  final int maxValue;

  /// 막대 높이
  final double barHeight;

  /// 값 표시 여부
  final bool showValues;

  /// 아이콘 표시 여부
  final bool showIcons;

  /// 애니메이션 활성화
  final bool animate;

  /// 애니메이션 시간
  final Duration animationDuration;

  /// 컴팩트 모드 (작은 공간용)
  final bool compact;

  @override
  State<CategoryBarChart> createState() => _CategoryBarChartState();
}

class _CategoryBarChartState extends State<CategoryBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return _buildCompactLayout(context);
    }
    return _buildDefaultLayout(context);
  }

  Widget _buildDefaultLayout(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widget.categories.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < widget.categories.length - 1 ? DSSpacing.sm : 0,
          ),
          child: _CategoryBarItem(
            category: category,
            maxValue: widget.maxValue,
            barHeight: widget.barHeight,
            showValue: widget.showValues,
            showIcon: widget.showIcons,
            animation: _animation,
            delay: index * 0.1,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    return Row(
      children: widget.categories.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index < widget.categories.length - 1 ? DSSpacing.xs : 0,
            ),
            child: _CompactCategoryItem(
              category: category,
              maxValue: widget.maxValue,
              animation: _animation,
              delay: index * 0.1,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// 개별 카테고리 막대 아이템
class _CategoryBarItem extends StatelessWidget {
  const _CategoryBarItem({
    required this.category,
    required this.maxValue,
    required this.barHeight,
    required this.showValue,
    required this.showIcon,
    required this.animation,
    required this.delay,
  });

  final CategoryData category;
  final int maxValue;
  final double barHeight;
  final bool showValue;
  final bool showIcon;
  final Animation<double> animation;
  final double delay;

  @override
  Widget build(BuildContext context) {
    final progress = category.value / maxValue;

    return Row(
      children: [
        // 아이콘
        if (showIcon && category.icon != null) ...[
          Icon(
            category.icon,
            size: 18,
            color: category.color ?? context.colors.accent,
          ),
          const SizedBox(width: DSSpacing.xs),
        ],

        // 라벨
        SizedBox(
          width: 48,
          child: Text(
            category.label,
            style: context.typography.labelSmall.copyWith(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: DSSpacing.sm),

        // 막대
        Expanded(
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              final animatedProgress =
                  progress * _getDelayedProgress(animation.value, delay);
              return Container(
                height: barHeight,
                decoration: BoxDecoration(
                  color: context.colors.border.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(barHeight / 2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: animatedProgress.clamp(0, 1),
                  child: Container(
                    decoration: BoxDecoration(
                      color: category.color ??
                          _getProgressColor(context, progress),
                      borderRadius: BorderRadius.circular(barHeight / 2),
                      gradient: category.gradient,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // 값
        if (showValue) ...[
          const SizedBox(width: DSSpacing.sm),
          SizedBox(
            width: 32,
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                final animatedValue = (category.value *
                        _getDelayedProgress(animation.value, delay))
                    .round();
                return Text(
                  '$animatedValue',
                  style: context.typography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                  textAlign: TextAlign.right,
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  double _getDelayedProgress(double animationValue, double delay) {
    final adjustedValue = (animationValue - delay) / (1 - delay);
    return adjustedValue.clamp(0, 1);
  }

  Color _getProgressColor(BuildContext context, double progress) {
    if (progress >= 0.8) return context.colors.success;
    if (progress >= 0.6) return context.colors.accentTertiary;
    if (progress >= 0.4) return context.colors.warning;
    return context.colors.error;
  }
}

/// 컴팩트 카테고리 아이템 (수직 레이아웃)
class _CompactCategoryItem extends StatelessWidget {
  const _CompactCategoryItem({
    required this.category,
    required this.maxValue,
    required this.animation,
    required this.delay,
  });

  final CategoryData category;
  final int maxValue;
  final Animation<double> animation;
  final double delay;

  @override
  Widget build(BuildContext context) {
    final progress = category.value / maxValue;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 아이콘/라벨
        if (category.icon != null)
          Icon(
            category.icon,
            size: 16,
            color: category.color ?? context.colors.accent,
          )
        else
          Text(
            category.label,
            style: context.typography.labelSmall.copyWith(
              fontSize: 10,
              color: context.colors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: DSSpacing.xxs),

        // 값
        AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final animatedValue =
                (category.value * _getDelayedProgress(animation.value, delay))
                    .round();
            return Text(
              '$animatedValue',
              style: context.typography.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
            );
          },
        ),
        const SizedBox(height: DSSpacing.xxs),

        // 세로 막대
        SizedBox(
          height: 40,
          width: 8,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              final animatedProgress =
                  progress * _getDelayedProgress(animation.value, delay);
              return Container(
                decoration: BoxDecoration(
                  color: context.colors.border.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.bottomCenter,
                  heightFactor: animatedProgress.clamp(0, 1),
                  child: Container(
                    decoration: BoxDecoration(
                      color: category.color ??
                          _getProgressColor(context, progress),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  double _getDelayedProgress(double animationValue, double delay) {
    final adjustedValue = (animationValue - delay) / (1 - delay);
    return adjustedValue.clamp(0, 1);
  }

  Color _getProgressColor(BuildContext context, double progress) {
    if (progress >= 0.8) return context.colors.success;
    if (progress >= 0.6) return context.colors.accentTertiary;
    if (progress >= 0.4) return context.colors.warning;
    return context.colors.error;
  }
}

/// 카테고리 데이터
class CategoryData {
  const CategoryData({
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.gradient,
  });

  /// 카테고리 이름
  final String label;

  /// 점수 (0~maxValue)
  final int value;

  /// 아이콘 (선택)
  final IconData? icon;

  /// 커스텀 색상 (선택)
  final Color? color;

  /// 그라데이션 (선택)
  final Gradient? gradient;
}

/// 일일 운세용 카테고리 프리셋
class DailyFortuneCategories {
  DailyFortuneCategories._();

  static List<CategoryData> fromScores({
    required int love,
    required int money,
    required int health,
    required int study,
    required int social,
  }) {
    return [
      CategoryData(label: '연애', value: love, icon: Icons.favorite_rounded),
      CategoryData(
          label: '재물', value: money, icon: Icons.monetization_on_rounded),
      CategoryData(
          label: '건강', value: health, icon: Icons.favorite_border_rounded),
      CategoryData(label: '학업', value: study, icon: Icons.school_rounded),
      CategoryData(label: '대인', value: social, icon: Icons.people_rounded),
    ];
  }
}
