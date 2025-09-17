import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:flutter/material.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import '../../../../../core/theme/toss_design_system.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../shared/glassmorphism/glass_container.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/haptic_utils.dart';
import '../../../domain/models/talisman_models.dart';

class TalismanTypeSelectionStep extends StatefulWidget {
  final Function(TalismanType) onTypeSelected;

  const TalismanTypeSelectionStep({
    super.key,
    required this.onTypeSelected});

  @override
  State<TalismanTypeSelectionStep> createState() =>
      _TalismanTypeSelectionStepState();
}

class _TalismanTypeSelectionStepState extends State<TalismanTypeSelectionStep> {
  TalismanType? _hoveredType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.shield_rounded,
                  size: 60,
                  color: theme.primaryColor).animate().fadeIn(duration: 600.ms).scale(
                    begin: const Offset(0.5, 0.5), end: const Offset(1, 1),
                const SizedBox(height: 16),
                Text(
                  '어떤 부적을 만들고 싶으신가요?',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                const SizedBox(height: 8),
                Text(
                  '당신의 소원에 맞는 부적을 선택해주세요',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: TossDesignSystem.gray600),
                  textAlign: TextAlign.center).animate().fadeIn(duration: 600.ms, delay: 400.ms)])),
          const SizedBox(height: 32),

          // Talisman type grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12),
            itemCount: TalismanType.values.length,
            itemBuilder: (context, index) {
              final type = TalismanType.values[index];
              return _buildTalismanTypeCard(type, index);
            }),

          const SizedBox(height: 40)]));
  }

  Widget _buildTalismanTypeCard(TalismanType type, int index) {
    final isHovered = _hoveredType == type;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _hoveredType = type);
        HapticUtils.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _hoveredType = null);
        widget.onTypeSelected(type);
      },
      onTapCancel: () {
        setState(() => _hoveredType = null);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(isHovered ? 0.95 : 1.0),
        child: GlassContainer(
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.all(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              type.gradientColors[0].withOpacity(0.1),
              type.gradientColors[1].withOpacity(0.05)]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: type.gradientColors),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: type.gradientColors[0].withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4))]),
                child: Icon(
                  type.icon,
                  color: TossDesignSystem.white,
                  size: 28)),
              const SizedBox(height: 12),
              Text(
                type.displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(
                type.description,
                style: TextStyle(
                  fontSize: 12,
                  color: TossDesignSystem.gray600,
                  height: 1.2),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis)])))
          .animate()
          .fadeIn(
            duration: 600.ms,
            delay: Duration(milliseconds: 100 * index))
          .slideY(
            begin: 0.2,
            end: 0,
            duration: 600.ms,
            delay: Duration(milliseconds: 100 * index),
            curve: Curves.easeOutCubic));
  }
}
