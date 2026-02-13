import 'package:flutter/material.dart';
import '../../design_system/design_system.dart';

/// 에너지/진행률을 수평 게이지로 표시하는 인포그래픽 위젯
///
/// 사용 예시:
/// ```dart
/// EnergyGauge(
///   value: 82,
///   maxValue: 100,
///   label: '에너지',
///   icon: '⚡',
/// )
/// ```
class EnergyGauge extends StatelessWidget {
  /// 현재 값
  final int value;

  /// 최대 값 (기본값: 100)
  final int maxValue;

  /// 라벨 텍스트
  final String? label;

  /// 아이콘 (이모지 또는 텍스트)
  final String? icon;

  /// 값 표시 여부 (기본값: true)
  final bool showValue;

  /// 퍼센트 표시 여부 (기본값: false)
  final bool showPercent;

  /// 게이지 높이 (기본값: 12)
  final double height;

  /// 게이지 색상 (null이면 값에 따라 자동)
  final Color? color;

  /// 배경 색상
  final Color? backgroundColor;

  /// 애니메이션 적용 여부
  final bool animate;

  /// 애니메이션 지속 시간
  final Duration animationDuration;

  /// 그라데이션 사용 여부 (기본값: false)
  final bool useGradient;

  const EnergyGauge({
    super.key,
    required this.value,
    this.maxValue = 100,
    this.label,
    this.icon,
    this.showValue = true,
    this.showPercent = false,
    this.height = 12,
    this.color,
    this.backgroundColor,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 800),
    this.useGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 라벨 행
        if (label != null || showValue) ...[
          Row(
            children: [
              if (icon != null) ...[
                Text(icon!, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
              ],
              if (label != null)
                Text(
                  label!,
                  style: context.labelMedium.copyWith(
                    color: isDark ? DSColors.textSecondaryDark : DSColors.textSecondary,
                  ),
                ),
              const Spacer(),
              if (showValue)
                Text(
                  showPercent ? '${_percentage.round()}%' : '$value/$maxValue',
                  style: context.numberSmall.copyWith(
                    color: isDark ? DSColors.textPrimaryDark : DSColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        // 게이지 바
        _AnimatedGaugeBar(
          value: value,
          maxValue: maxValue,
          height: height,
          color: color ?? _getValueColor(isDark),
          backgroundColor: backgroundColor ??
              (isDark ? DSColors.backgroundSecondaryDark : DSColors.backgroundSecondary),
          animate: animate,
          animationDuration: animationDuration,
          useGradient: useGradient,
        ),
      ],
    );
  }

  double get _percentage => (value / maxValue) * 100;

  Color _getValueColor(bool isDark) {
    final percent = _percentage;
    if (percent >= 80) {
      return isDark ? DSColors.successDark : DSColors.success;
    } else if (percent >= 60) {
      return isDark ? DSColors.accentTertiaryDark : DSColors.accentTertiary;
    } else if (percent >= 40) {
      return isDark ? DSColors.warningDark : DSColors.warning;
    } else {
      return isDark ? DSColors.errorDark : DSColors.error;
    }
  }
}

/// 애니메이션이 적용된 게이지 바
class _AnimatedGaugeBar extends StatefulWidget {
  final int value;
  final int maxValue;
  final double height;
  final Color color;
  final Color backgroundColor;
  final bool animate;
  final Duration animationDuration;
  final bool useGradient;

  const _AnimatedGaugeBar({
    required this.value,
    required this.maxValue,
    required this.height,
    required this.color,
    required this.backgroundColor,
    required this.animate,
    required this.animationDuration,
    required this.useGradient,
  });

  @override
  State<_AnimatedGaugeBar> createState() => _AnimatedGaugeBarState();
}

class _AnimatedGaugeBarState extends State<_AnimatedGaugeBar>
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

    _animation = Tween<double>(
      begin: 0,
      end: widget.value / widget.maxValue,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_AnimatedGaugeBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value || oldWidget.maxValue != widget.maxValue) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.value / widget.maxValue,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          children: [
            // 배경 바
            Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(widget.height / 2),
              ),
            ),
            // 진행 바
            FractionallySizedBox(
              widthFactor: _animation.value.clamp(0.0, 1.0),
              child: Container(
                height: widget.height,
                decoration: BoxDecoration(
                  color: widget.useGradient ? null : widget.color,
                  gradient: widget.useGradient
                      ? LinearGradient(
                          colors: [
                            widget.color.withValues(alpha: 0.7),
                            widget.color,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(widget.height / 2),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 듀얼 게이지 - 두 개의 값을 나란히 비교 표시
class DualGauge extends StatelessWidget {
  final int value1;
  final int value2;
  final String label1;
  final String label2;
  final int maxValue;
  final String? icon1;
  final String? icon2;

  const DualGauge({
    super.key,
    required this.value1,
    required this.value2,
    required this.label1,
    required this.label2,
    this.maxValue = 100,
    this.icon1,
    this.icon2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GaugeBox(
            value: value1,
            maxValue: maxValue,
            label: label1,
            icon: icon1,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _GaugeBox(
            value: value2,
            maxValue: maxValue,
            label: label2,
            icon: icon2,
          ),
        ),
      ],
    );
  }
}

/// 개별 게이지 박스 (DualGauge 용)
class _GaugeBox extends StatelessWidget {
  final int value;
  final int maxValue;
  final String label;
  final String? icon;

  const _GaugeBox({
    required this.value,
    required this.maxValue,
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DSColors.surfaceDark : DSColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? DSColors.borderDark : DSColors.border,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: context.labelMedium.copyWith(
              color: isDark ? DSColors.textSecondaryDark : DSColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$value%',
            style: context.numberLarge.copyWith(
              color: isDark ? DSColors.textPrimaryDark : DSColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (icon != null) ...[
            const SizedBox(height: 8),
            Text(icon!, style: const TextStyle(fontSize: 24)),
          ],
        ],
      ),
    );
  }
}
