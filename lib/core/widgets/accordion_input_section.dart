import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/toss_design_system.dart';
import '../theme/typography_unified.dart';

/// 아코디언 방식 입력 섹션 모델
class AccordionInputSection {
  final String id;
  final String title;
  final IconData icon;
  final Widget Function(BuildContext, Function(dynamic)) inputWidgetBuilder;
  bool isCompleted;
  dynamic value;

  AccordionInputSection({
    required this.id,
    required this.title,
    required this.icon,
    required this.inputWidgetBuilder,
    this.isCompleted = false,
    this.value,
  });

  String get displayValue {
    if (value == null) return title;
    return '$title: $value';
  }
}

/// 아코디언 방식 입력 폼 위젯
class AccordionInputForm extends StatefulWidget {
  final List<AccordionInputSection> sections;
  final VoidCallback? onAllCompleted;
  final String? completionButtonText;

  const AccordionInputForm({
    super.key,
    required this.sections,
    this.onAllCompleted,
    this.completionButtonText,
  });

  @override
  State<AccordionInputForm> createState() => _AccordionInputFormState();
}

class _AccordionInputFormState extends State<AccordionInputForm> {
  final ScrollController _scrollController = ScrollController();
  int _activeIndex = 0;
  final List<GlobalKey> _sectionKeys = [];

  @override
  void initState() {
    super.initState();
    // 섹션별 GlobalKey 생성
    for (int i = 0; i < widget.sections.length; i++) {
      _sectionKeys.add(GlobalKey());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool get _allCompleted {
    return widget.sections.every((section) => section.isCompleted);
  }

  void _onSectionComplete(int index, dynamic value) {
    HapticFeedback.mediumImpact();

    setState(() {
      widget.sections[index].value = value;
      widget.sections[index].isCompleted = true;
    });

    // 다음 섹션으로 이동
    if (index < widget.sections.length - 1) {
      _moveToSection(index + 1);
    } else {
      // 마지막 섹션 완료 시 모두 축소
      setState(() {
        _activeIndex = -1;
      });

      if (_allCompleted && widget.onAllCompleted != null) {
        widget.onAllCompleted!();
      }
    }
  }

  void _onSectionTap(int index) {
    if (_activeIndex != index) {
      HapticFeedback.lightImpact();
      _moveToSection(index);
    }
  }

  void _moveToSection(int targetIndex) {
    setState(() {
      _activeIndex = targetIndex;
    });

    // 섹션으로 스크롤
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;

      final RenderBox? renderBox = _sectionKeys[targetIndex].currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final offset = _scrollController.offset + position.dy - 120; // AppBar 높이 고려

        _scrollController.animateTo(
          offset.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 120),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final section = widget.sections[index];
                final isActive = _activeIndex == index;

                return Padding(
                  key: _sectionKeys[index],
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AnimatedAccordionSection(
                    section: section,
                    isActive: isActive,
                    onTap: () => _onSectionTap(index),
                    onComplete: (value) => _onSectionComplete(index, value),
                  ),
                );
              },
              childCount: widget.sections.length,
            ),
          ),
        ),
      ],
    );
  }
}

/// 개별 아코디언 섹션 위젯
class AnimatedAccordionSection extends StatelessWidget {
  final AccordionInputSection section;
  final bool isActive;
  final VoidCallback onTap;
  final ValueChanged<dynamic> onComplete;

  const AnimatedAccordionSection({
    super.key,
    required this.section,
    required this.isActive,
    required this.onTap,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: isActive
        ? _buildExpandedContent(context)
        : _buildCollapsedHeader(context),
    );
  }

  Widget _buildCollapsedHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: section.isCompleted
            ? (isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray100)
            : (isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray50),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: section.isCompleted
              ? TossDesignSystem.tossBlue.withValues(alpha: 0.3)
              : (isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray200),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: section.isCompleted
                  ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                  : (isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray100),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                section.icon,
                color: section.isCompleted
                  ? TossDesignSystem.tossBlue
                  : (isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray500),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                section.isCompleted
                  ? section.displayValue
                  : section.title,
                style: context.bodyMedium.copyWith(
                  color: section.isCompleted
                    ? (isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight)
                    : (isDark ? TossDesignSystem.textTertiaryDark : TossDesignSystem.textTertiaryLight),
                  fontWeight: section.isCompleted ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (section.isCompleted)
              Icon(
                Icons.check_circle,
                color: TossDesignSystem.tossBlue,
                size: 24,
              )
            else
              Icon(
                Icons.chevron_right,
                color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray400,
                size: 24,
              ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: 200.ms)
      .slideY(begin: 0.1, end: 0, duration: 200.ms);
  }

  Widget _buildExpandedContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: TossDesignSystem.tossBlue.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.tossBlue.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  section.icon,
                  color: TossDesignSystem.tossBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  section.title,
                  style: context.heading3.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          section.inputWidgetBuilder(context, onComplete),
        ],
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideY(begin: -0.1, end: 0, duration: 300.ms, curve: Curves.easeOut)
      .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 300.ms);
  }
}
