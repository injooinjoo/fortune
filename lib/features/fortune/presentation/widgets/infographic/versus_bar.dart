import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/tokens/ds_spacing.dart';
import 'package:fortune/core/design_system/theme/ds_extensions.dart';

/// 대결 바 위젯
///
/// 두 팀/항목의 승률이나 점수를 비교하는 양방향 바 차트입니다.
/// 스포츠 경기 분석, 궁합 비교 등에 사용됩니다.
class VersusBar extends StatefulWidget {
  const VersusBar({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.leftValue,
    required this.rightValue,
    this.leftColor,
    this.rightColor,
    this.leftIcon,
    this.rightIcon,
    this.leftImage,
    this.rightImage,
    this.height = 40,
    this.showPercentage = true,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 600),
    this.centerDivider = true,
  });

  /// 왼쪽 라벨
  final String leftLabel;

  /// 오른쪽 라벨
  final String rightLabel;

  /// 왼쪽 값 (0-100)
  final double leftValue;

  /// 오른쪽 값 (0-100)
  final double rightValue;

  /// 왼쪽 색상
  final Color? leftColor;

  /// 오른쪽 색상
  final Color? rightColor;

  /// 왼쪽 아이콘
  final IconData? leftIcon;

  /// 오른쪽 아이콘
  final IconData? rightIcon;

  /// 왼쪽 이미지 (아이콘 대신)
  final ImageProvider? leftImage;

  /// 오른쪽 이미지 (아이콘 대신)
  final ImageProvider? rightImage;

  /// 바 높이
  final double height;

  /// 퍼센트 표시 여부
  final bool showPercentage;

  /// 애니메이션 활성화
  final bool animate;

  /// 애니메이션 시간
  final Duration animationDuration;

  /// 중앙 구분선 표시
  final bool centerDivider;

  @override
  State<VersusBar> createState() => _VersusBarState();
}

class _VersusBarState extends State<VersusBar>
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

  double get _total => widget.leftValue + widget.rightValue;
  double get _leftRatio =>
      _total > 0 ? widget.leftValue / _total : 0.5;

  @override
  Widget build(BuildContext context) {
    final leftColor = widget.leftColor ?? context.colors.accent;
    final rightColor = widget.rightColor ?? context.colors.accentSecondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 라벨 행
        Row(
          children: [
            // 왼쪽 라벨
            Expanded(
              child: Row(
                children: [
                  _buildIcon(
                    context,
                    widget.leftIcon,
                    widget.leftImage,
                    leftColor,
                  ),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      widget.leftLabel,
                      style: context.typography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // VS 텍스트
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm),
              child: Text(
                'VS',
                style: context.typography.labelSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: context.colors.textTertiary,
                ),
              ),
            ),

            // 오른쪽 라벨
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      widget.rightLabel,
                      style: context.typography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: DSSpacing.xs),
                  _buildIcon(
                    context,
                    widget.rightIcon,
                    widget.rightImage,
                    rightColor,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.sm),

        // 바 차트
        AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            final animatedLeftRatio = _leftRatio * _animation.value +
                0.5 * (1 - _animation.value);
            return Container(
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.height / 2),
                color: context.colors.border.withOpacity(0.2),
              ),
              child: Stack(
                children: [
                  // 왼쪽 바
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: animatedLeftRatio.clamp(0, 1),
                    child: Container(
                      decoration: BoxDecoration(
                        color: leftColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(widget.height / 2),
                          bottomLeft: Radius.circular(widget.height / 2),
                          topRight: animatedLeftRatio >= 0.95
                              ? Radius.circular(widget.height / 2)
                              : Radius.zero,
                          bottomRight: animatedLeftRatio >= 0.95
                              ? Radius.circular(widget.height / 2)
                              : Radius.zero,
                        ),
                      ),
                    ),
                  ),

                  // 오른쪽 바
                  FractionallySizedBox(
                    alignment: Alignment.centerRight,
                    widthFactor: (1 - animatedLeftRatio).clamp(0, 1),
                    child: Container(
                      decoration: BoxDecoration(
                        color: rightColor,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(widget.height / 2),
                          bottomRight: Radius.circular(widget.height / 2),
                          topLeft: animatedLeftRatio <= 0.05
                              ? Radius.circular(widget.height / 2)
                              : Radius.zero,
                          bottomLeft: animatedLeftRatio <= 0.05
                              ? Radius.circular(widget.height / 2)
                              : Radius.zero,
                        ),
                      ),
                    ),
                  ),

                  // 중앙 구분선
                  if (widget.centerDivider)
                    Center(
                      child: Container(
                        width: 2,
                        height: widget.height,
                        color: context.colors.surface.withOpacity(0.5),
                      ),
                    ),

                  // 퍼센트 표시
                  if (widget.showPercentage)
                    Positioned.fill(
                      child: Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                '${(widget.leftValue / _total * 100).round()}%',
                                style: context.typography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: _getContrastColor(leftColor),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                '${(widget.rightValue / _total * 100).round()}%',
                                style: context.typography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: _getContrastColor(rightColor),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildIcon(
    BuildContext context,
    IconData? icon,
    ImageProvider? image,
    Color color,
  ) {
    if (image != null) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          image: DecorationImage(
            image: image,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    if (icon != null) {
      return Icon(
        icon,
        size: 20,
        color: color,
      );
    }

    return const SizedBox(width: 20);
  }

  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}

/// 다중 비교 바 (여러 항목 비교)
class MultiVersusBar extends StatefulWidget {
  const MultiVersusBar({
    super.key,
    required this.items,
    this.height = 24,
    this.showLabels = true,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 600),
  });

  /// 비교 항목들
  final List<VersusItem> items;

  /// 바 높이
  final double height;

  /// 라벨 표시 여부
  final bool showLabels;

  /// 애니메이션 활성화
  final bool animate;

  /// 애니메이션 시간
  final Duration animationDuration;

  @override
  State<MultiVersusBar> createState() => _MultiVersusBarState();
}

class _MultiVersusBarState extends State<MultiVersusBar>
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

  double get _total =>
      widget.items.fold(0, (sum, item) => sum + item.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 바
        AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            return Container(
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.height / 2),
                color: context.colors.border.withOpacity(0.2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.height / 2),
                child: Row(
                  children: widget.items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final ratio = _total > 0 ? item.value / _total : 0;
                    final animatedRatio = ratio * _animation.value;

                    return Expanded(
                      flex: (animatedRatio * 1000).round().clamp(1, 1000),
                      child: Container(
                        color: item.color ??
                            _getDefaultColor(context, index),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),

        // 범례
        if (widget.showLabels) ...[
          const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.md,
            runSpacing: DSSpacing.xs,
            alignment: WrapAlignment.center,
            children: widget.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final color = item.color ?? _getDefaultColor(context, index);
              final percentage =
                  _total > 0 ? (item.value / _total * 100).round() : 0;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item.label} ($percentage%)',
                    style: context.typography.labelSmall.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Color _getDefaultColor(BuildContext context, int index) {
    final colors = [
      context.colors.accent,
      context.colors.accentSecondary,
      context.colors.accentTertiary,
      context.colors.success,
      context.colors.warning,
    ];
    return colors[index % colors.length];
  }
}

/// 비교 항목 데이터
class VersusItem {
  const VersusItem({
    required this.label,
    required this.value,
    this.color,
    this.icon,
  });

  /// 라벨
  final String label;

  /// 값
  final double value;

  /// 색상 (선택)
  final Color? color;

  /// 아이콘 (선택)
  final IconData? icon;
}

/// 궁합 비교 바
class CompatibilityBar extends StatefulWidget {
  const CompatibilityBar({
    super.key,
    required this.score,
    this.maxScore = 100,
    this.label,
    this.showScore = true,
    this.height = 8,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 600),
  });

  /// 궁합 점수
  final int score;

  /// 최대 점수
  final int maxScore;

  /// 라벨
  final String? label;

  /// 점수 표시 여부
  final bool showScore;

  /// 바 높이
  final double height;

  /// 애니메이션 활성화
  final bool animate;

  /// 애니메이션 시간
  final Duration animationDuration;

  @override
  State<CompatibilityBar> createState() => _CompatibilityBarState();
}

class _CompatibilityBarState extends State<CompatibilityBar>
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

  Color _getScoreColor(BuildContext context) {
    final ratio = widget.score / widget.maxScore;
    if (ratio >= 0.8) return context.colors.success;
    if (ratio >= 0.6) return context.colors.accentTertiary;
    if (ratio >= 0.4) return context.colors.warning;
    return context.colors.error;
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.score / widget.maxScore;

    return Row(
      children: [
        // 라벨
        if (widget.label != null)
          SizedBox(
            width: 48,
            child: Text(
              widget.label!,
              style: context.typography.labelSmall.copyWith(
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        if (widget.label != null) const SizedBox(width: DSSpacing.sm),

        // 바
        Expanded(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, _) {
              final animatedProgress = progress * _animation.value;
              return Container(
                height: widget.height,
                decoration: BoxDecoration(
                  color: context.colors.border.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(widget.height / 2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: animatedProgress.clamp(0, 1),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getScoreColor(context),
                      borderRadius: BorderRadius.circular(widget.height / 2),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // 점수
        if (widget.showScore) ...[
          const SizedBox(width: DSSpacing.sm),
          SizedBox(
            width: 32,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                final animatedScore =
                    (widget.score * _animation.value).round();
                return Text(
                  '$animatedScore',
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
}
