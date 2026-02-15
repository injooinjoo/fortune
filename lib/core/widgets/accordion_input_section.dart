import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_system/design_system.dart';
import '../utils/haptic_utils.dart';

/// 아코디언 방식 입력 섹션 모델
class AccordionInputSection {
  final String id;
  final String title;
  final IconData icon;
  final String? imagePath; // ✅ 추가: 이미지 에셋 지원
  final Widget Function(BuildContext, Function(dynamic)) inputWidgetBuilder;
  bool isCompleted;
  dynamic value;
  String? displayValue;

  /// 다중 선택 섹션인 경우 true (선택 후에도 닫히지 않음)
  final bool isMultiSelect;

  AccordionInputSection({
    required this.id,
    required this.title,
    required this.icon,
    this.imagePath,
    required this.inputWidgetBuilder,
    this.isCompleted = false,
    this.value,
    this.displayValue,
    this.isMultiSelect = false,
  });

  String get displayText {
    if (displayValue != null) return displayValue!;
    if (value == null) return title;
    return '$title: $value';
  }

  /// copyWith 메서드 추가
  AccordionInputSection copyWith({
    String? id,
    String? title,
    IconData? icon,
    String? imagePath,
    Widget Function(BuildContext, Function(dynamic))? inputWidgetBuilder,
    bool? isCompleted,
    dynamic value,
    String? displayValue,
    bool? isMultiSelect,
  }) {
    return AccordionInputSection(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      imagePath: imagePath ?? this.imagePath,
      inputWidgetBuilder: inputWidgetBuilder ?? this.inputWidgetBuilder,
      isCompleted: isCompleted ?? this.isCompleted,
      value: value ?? this.value,
      displayValue: displayValue ?? this.displayValue,
      isMultiSelect: isMultiSelect ?? this.isMultiSelect,
    );
  }
}

/// 아코디언 방식 입력 폼 위젯
class AccordionInputForm extends StatefulWidget {
  final List<AccordionInputSection> sections;
  final VoidCallback? onAllCompleted;
  final String? completionButtonText;
  final Widget? header;

  const AccordionInputForm({
    super.key,
    required this.sections,
    this.onAllCompleted,
    this.completionButtonText,
    this.header,
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
    // 첫 미완료 섹션 찾기
    _activeIndex = _findFirstIncompleteSection();
  }

  int _findFirstIncompleteSection() {
    for (int i = 0; i < widget.sections.length; i++) {
      if (!widget.sections[i].isCompleted) {
        return i;
      }
    }
    return -1; // 모두 완료됨
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
    HapticUtils.mediumImpact();

    setState(() {
      widget.sections[index].value = value;
      widget.sections[index].isCompleted = true;
    });

    // 다중 선택 섹션은 닫지 않고 현재 섹션 유지
    if (widget.sections[index].isMultiSelect) {
      // 현재 섹션 열린 상태 유지
      return;
    }

    // 단일 선택 섹션은 다음 섹션으로 이동
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
      HapticUtils.lightImpact();
      _moveToSection(index);
    }
  }

  void _moveToSection(int targetIndex) {
    setState(() {
      _activeIndex = targetIndex;
    });

    // 섹션으로 스크롤 (화면 중앙에 오도록)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      final RenderBox? renderBox = _sectionKeys[targetIndex]
          .currentContext
          ?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final screenHeight = MediaQuery.of(context).size.height;

        // 섹션을 화면 중앙에 위치시키기 위한 오프셋 계산
        // 현재 스크롤 위치 + 섹션의 Y 좌표 - 화면 중앙 위치
        final offset =
            _scrollController.offset + position.dy - (screenHeight / 2) + 100;

        _scrollController.animateTo(
          offset.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // 헤더 (있는 경우)
        if (widget.header != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: widget.header!,
            ),
          ),
        // 아코디언 섹션들
        SliverPadding(
          padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: widget.header != null ? 0 : 20,
              bottom: 120),
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
    final colors = context.colors;
    final typography = context.typography;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.lg - 4, vertical: DSSpacing.md),
        decoration: BoxDecoration(
          color: section.isCompleted ? colors.surfaceSecondary : colors.surface,
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: section.isCompleted
                ? colors.accent.withValues(alpha: 0.3)
                : colors.border,
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
                    ? colors.accent.withValues(alpha: 0.1)
                    : colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(DSRadius.md),
              ),
              child: section.imagePath != null
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        section.imagePath!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            section.icon,
                            color: section.isCompleted
                                ? colors.accent
                                : colors.textTertiary,
                            size: 20,
                          );
                        },
                      ),
                    )
                  : Icon(
                      section.icon,
                      color: section.isCompleted
                          ? colors.accent
                          : colors.textTertiary,
                      size: 20,
                    ),
            ),
            const SizedBox(width: DSSpacing.sm + 4),
            Expanded(
              child: Text(
                section.isCompleted ? section.displayText : section.title,
                style: typography.bodyMedium.copyWith(
                  color: section.isCompleted
                      ? colors.textPrimary
                      : colors.textTertiary,
                  fontWeight:
                      section.isCompleted ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (section.isCompleted)
              Icon(
                Icons.check_circle,
                color: colors.accent,
                size: 24,
              )
            else
              Icon(
                Icons.chevron_right,
                color: colors.textTertiary,
                size: 24,
              ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideY(begin: 0.1, end: 0, duration: 200.ms);
  }

  Widget _buildExpandedContent(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.xl),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.accent.withValues(alpha: 0.08),
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
                  color: colors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DSRadius.md + 2),
                ),
                child: section.imagePath != null
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          section.imagePath!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              section.icon,
                              color: colors.accent,
                              size: 24,
                            );
                          },
                        ),
                      )
                    : Icon(
                        section.icon,
                        color: colors.accent,
                        size: 24,
                      ),
              ),
              const SizedBox(width: DSSpacing.sm + 4),
              Expanded(
                child: Text(
                  section.title,
                  style: typography.headingSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.lg),
          section.inputWidgetBuilder(context, onComplete),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: -0.1, end: 0, duration: 300.ms, curve: Curves.easeOut)
        .scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1, 1),
            duration: 300.ms);
  }
}

/// 헤더가 포함된 아코디언 입력 폼 위젯
class AccordionInputFormWithHeader extends StatefulWidget {
  final Widget header;
  final List<AccordionInputSection> sections;
  final VoidCallback? onAllCompleted;
  final String? completionButtonText;

  const AccordionInputFormWithHeader({
    super.key,
    required this.header,
    required this.sections,
    this.onAllCompleted,
    this.completionButtonText,
  });

  @override
  State<AccordionInputFormWithHeader> createState() =>
      _AccordionInputFormWithHeaderState();
}

class _AccordionInputFormWithHeaderState
    extends State<AccordionInputFormWithHeader> {
  final ScrollController _scrollController = ScrollController();
  int _activeIndex = 0;
  final List<GlobalKey> _sectionKeys = [];
  final GlobalKey _headerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // 섹션별 GlobalKey 생성
    for (int i = 0; i < widget.sections.length; i++) {
      _sectionKeys.add(GlobalKey());
    }
    // 첫 미완료 섹션 찾기
    _activeIndex = _findFirstIncompleteSection();
  }

  int _findFirstIncompleteSection() {
    for (int i = 0; i < widget.sections.length; i++) {
      if (!widget.sections[i].isCompleted) {
        return i;
      }
    }
    return -1; // 모두 완료됨
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
    HapticUtils.mediumImpact();

    setState(() {
      widget.sections[index].value = value;
      widget.sections[index].isCompleted = true;
    });

    // 다중 선택 섹션은 닫지 않고 현재 섹션 유지
    if (widget.sections[index].isMultiSelect) {
      // 현재 섹션 열린 상태 유지
      return;
    }

    // 단일 선택 섹션은 다음 섹션으로 이동
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
      HapticUtils.lightImpact();
      _moveToSection(index);
    }
  }

  void _moveToSection(int targetIndex) {
    setState(() {
      _activeIndex = targetIndex;
    });

    // 섹션으로 스크롤 (헤더를 고려하여 충분한 여유 공간 확보)
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;

      final RenderBox? renderBox = _sectionKeys[targetIndex]
          .currentContext
          ?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);

        // 헤더 높이(약 80-120px) + SafeArea(약 44px) + 여유 공간(40px) = 약 164px
        // 헤더가 잘리지 않도록 충분한 오프셋 확보
        final offset = _scrollController.offset + position.dy - 180;

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
        // 헤더 영역 (스크롤 가능)
        SliverToBoxAdapter(
          child: Padding(
            key: _headerKey,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: widget.header,
          ),
        ),

        // Accordion 섹션들
        SliverPadding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 120),
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
