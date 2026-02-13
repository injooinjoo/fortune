import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../domain/models/recommendation_chip.dart';

/// 운세 추천 칩 그리드
class FortuneChipGrid extends StatefulWidget {
  final List<RecommendationChip> chips;
  final void Function(RecommendationChip chip) onChipTap;
  final VoidCallback? onViewAllTap;
  final bool showViewAll;

  const FortuneChipGrid({
    super.key,
    required this.chips,
    required this.onChipTap,
    this.onViewAllTap,
    this.showViewAll = false,
  });

  @override
  State<FortuneChipGrid> createState() => _FortuneChipGridState();
}

class _FortuneChipGridState extends State<FortuneChipGrid>
    with TickerProviderStateMixin {
  final Map<String, GlobalKey> _chipKeys = {};
  final Map<String, _ChipFlightAnimation> _activeAnimations = {};

  @override
  void initState() {
    super.initState();
    _syncChipKeys();
  }

  @override
  void didUpdateWidget(covariant FortuneChipGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncChipKeys();
  }

  void _syncChipKeys() {
    final chipIds = widget.chips.map((chip) => chip.id).toSet();
    for (final chip in widget.chips) {
      _chipKeys.putIfAbsent(chip.id, () => GlobalKey());
    }
    _chipKeys.removeWhere((key, _) => !chipIds.contains(key));
  }

  @override
  void dispose() {
    for (final animation in _activeAnimations.values) {
      animation.dispose();
    }
    _activeAnimations.clear();
    super.dispose();
  }

  void _handleChipTap(RecommendationChip chip) {
    if (_activeAnimations.containsKey(chip.id)) {
      return;
    }

    final chipKey = _chipKeys[chip.id];
    final chipContext = chipKey?.currentContext;
    if (chipContext == null) {
      DSHaptics.light();
      widget.onChipTap(chip);
      return;
    }

    final renderBox = chipContext.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(chipContext, rootOverlay: true);

    if (renderBox == null || !renderBox.hasSize) {
      DSHaptics.light();
      widget.onChipTap(chip);
      return;
    }

    final startOffset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final mediaQuery = MediaQuery.of(chipContext);
    final targetX = (mediaQuery.size.width - size.width - DSSpacing.md)
        .clamp(DSSpacing.md, mediaQuery.size.width);
    final minY = mediaQuery.padding.top + DSSpacing.sm;
    final targetY =
        (startOffset.dy - size.height * 1.4).clamp(minY, startOffset.dy);

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    );
    final offsetTween = Tween<Offset>(
      begin: startOffset,
      end: Offset(targetX.toDouble(), targetY.toDouble()),
    );
    final scaleTween = Tween<double>(begin: 1.0, end: 0.94);
    final opacityTween = Tween<double>(begin: 1.0, end: 0.0);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (overlayContext) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final offset = offsetTween.evaluate(animation);
            return Positioned(
              left: offset.dx,
              top: offset.dy,
              child: IgnorePointer(
                child: Opacity(
                  opacity: opacityTween.evaluate(animation),
                  child: Transform.scale(
                    scale: scaleTween.evaluate(animation),
                    alignment: Alignment.centerRight,
                    child: child,
                  ),
                ),
              ),
            );
          },
          child: Material(
            type: MaterialType.transparency,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: _buildChip(
                overlayContext,
                chip,
                isInteractive: false,
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);

    final activeAnimation = _ChipFlightAnimation(
      controller: controller,
      entry: entry,
    );
    _activeAnimations[chip.id] = activeAnimation;
    setState(() {});

    DSHaptics.light();
    controller.forward();

    Future.delayed(const Duration(milliseconds: 160), () {
      if (mounted) {
        widget.onChipTap(chip);
      }
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _activeAnimations.remove(chip.id)?.dispose();
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  Widget _buildChip(
    BuildContext context,
    RecommendationChip chip, {
    Key? key,
    VoidCallback? onPressed,
    bool isInteractive = true,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return GestureDetector(
      key: key,
      onTap: isInteractive ? onPressed : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.sm + 4,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(DSRadius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              chip.icon,
              size: 18,
              color: chip.color,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chip.label,
                    style: typography.labelMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (chip.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      chip.subtitle!,
                      style: typography.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Wrap(
      spacing: DSSpacing.sm,
      runSpacing: DSSpacing.sm,
      alignment: WrapAlignment.center,
      children: [
        ...widget.chips.map((chip) {
          final chipKey = _chipKeys[chip.id]!;
          final isAnimating = _activeAnimations.containsKey(chip.id);

          return AnimatedOpacity(
            opacity: isAnimating ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: IgnorePointer(
              ignoring: isAnimating,
              child: _buildChip(
                context,
                chip,
                key: chipKey,
                onPressed: () => _handleChipTap(chip),
              ),
            ),
          );
        }),
        // 더보기 버튼
        if (widget.showViewAll && widget.onViewAllTap != null)
          GestureDetector(
            onTap: () {
              DSHaptics.light();
              widget.onViewAllTap?.call();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.md,
                vertical: DSSpacing.sm + 4,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(DSRadius.md),
              ),
              child: Text(
                '더보기',
                style: typography.labelMedium.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ChipFlightAnimation {
  final AnimationController controller;
  final OverlayEntry entry;
  bool _disposed = false;

  _ChipFlightAnimation({
    required this.controller,
    required this.entry,
  });

  void dispose() {
    if (_disposed) {
      return;
    }
    if (entry.mounted) {
      entry.remove();
    }
    controller.dispose();
    _disposed = true;
  }
}
