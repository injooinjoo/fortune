import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/models/health_fortune_model.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../shared/components/floating_bottom_button.dart';

class BodyPartGridSelector extends StatefulWidget {
  final List<BodyPart> selectedParts;
  final Function(List<BodyPart>) onSelectionChanged;
  final int maxSelection;

  const BodyPartGridSelector({
    super.key,
    required this.selectedParts,
    required this.onSelectionChanged,
    this.maxSelection = 3,
  });

  @override
  State<BodyPartGridSelector> createState() => _BodyPartGridSelectorState();
}

class _BodyPartGridSelectorState extends State<BodyPartGridSelector> {
  List<BodyPart> _selectedParts = [];

  @override
  void initState() {
    super.initState();
    _selectedParts = List.from(widget.selectedParts);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '특별히 신경쓰이는 부위가 있나요?',
                    style: TossTheme.heading3.copyWith(
                      color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                    ),
                  ),
                  if (_selectedParts.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: TossTheme.primaryBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_selectedParts.length}',
                        style: TossTheme.caption.copyWith(
                          color: TossDesignSystem.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '최대 ${widget.maxSelection}개까지 선택 가능합니다',
                style: TossTheme.body3.copyWith(
                  color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                ),
              ),
              if (_selectedParts.isNotEmpty) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _clearSelection,
                  child: Text(
                    '선택 모두 해제',
                    style: TossTheme.body3.copyWith(
                      color: TossTheme.primaryBlue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // 그리드 선택기
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildBodyPartGrid(isDark),
          ),
        ),

        // 선택된 부위 요약
        if (_selectedParts.isNotEmpty)
          _buildSelectedSummary(isDark),
      ],
    );
  }

  Widget _buildBodyPartGrid(bool isDark) {
    final bodyParts = BodyPart.values.where((part) => part != BodyPart.whole).toList();

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: bodyParts.length,
          itemBuilder: (context, index) {
            final part = bodyParts[index];
            return _buildBodyPartCard(part, index, isDark);
          },
        ),

        // Bottom button spacing
        const BottomButtonSpacing(),
      ],
    );
  }

  Widget _buildBodyPartCard(BodyPart part, int index, bool isDark) {
    final isSelected = _selectedParts.contains(part);
    final canSelect = _selectedParts.length < widget.maxSelection || isSelected;

    return GestureDetector(
      onTap: canSelect ? () => _toggleBodyPart(part) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? TossTheme.primaryBlue.withValues(alpha: 0.1)
              : (isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? TossTheme.primaryBlue
                : canSelect
                    ? (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200)
                    : (isDark ? TossDesignSystem.borderDark.withValues(alpha: 0.5) : TossTheme.borderGray200.withValues(alpha: 0.5)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: TossTheme.primaryBlue.withValues(alpha: 0.2),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
              : [
                  BoxShadow(
                    color: TossDesignSystem.black.withValues(alpha: 0.04),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: Opacity(
          opacity: canSelect ? 1.0 : 0.5,
          child: Stack(
            children: [
              // 내용
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 아이콘
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? TossTheme.primaryBlue.withValues(alpha: 0.2)
                            : (isDark ? TossDesignSystem.surfaceBackgroundDark : TossTheme.backgroundSecondary),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getBodyPartIcon(part),
                        color: isSelected
                            ? TossTheme.primaryBlue
                            : (isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600),
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 부위 이름
                    Text(
                      part.displayName,
                      style: TossTheme.body2.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? TossTheme.primaryBlue
                            : (isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // 설명
                    Text(
                      _getShortDescription(part),
                      style: TossTheme.caption.copyWith(
                        color: isDark ? TossDesignSystem.textTertiaryDark : TossTheme.textGray500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // 선택 체크마크
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: TossTheme.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: TossDesignSystem.white,
                      size: 16,
                    ),
                  ).animate()
                    .scale(duration: 200.ms, curve: Curves.elasticOut),
                ),
            ],
          ),
        ),
      ),
    ).animate(delay: (index * 50).ms)
      .fadeIn(duration: 300.ms)
      .slideY(begin: 0.1, end: 0);
  }

  Widget _buildSelectedSummary(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TossTheme.primaryBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TossTheme.primaryBlue.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: TossTheme.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '선택된 부위',
                style: TossTheme.body2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                ),
              ),
              const Spacer(),
              Text(
                '${_selectedParts.length}/${widget.maxSelection}',
                style: TossTheme.caption.copyWith(
                  color: TossTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedParts.map((part) {
              return Chip(
                label: Text(
                  part.displayName,
                  style: TossTheme.caption.copyWith(
                    color: TossTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: TossTheme.primaryBlue.withValues(alpha: 0.1),
                deleteIcon: Icon(
                  Icons.close,
                  size: 16,
                  color: TossTheme.primaryBlue,
                ),
                onDeleted: () => _toggleBodyPart(part),
                side: BorderSide(
                  color: TossTheme.primaryBlue.withValues(alpha: 0.3),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideY(begin: 0.1, end: 0);
  }

  IconData _getBodyPartIcon(BodyPart part) {
    switch (part) {
      case BodyPart.head:
        return Icons.face;
      case BodyPart.neck:
        return Icons.accessibility_new;
      case BodyPart.shoulders:
        return Icons.fitness_center;
      case BodyPart.chest:
        return Icons.favorite;
      case BodyPart.stomach:
        return Icons.restaurant;
      case BodyPart.back:
        return Icons.airline_seat_recline_normal;
      case BodyPart.arms:
        return Icons.pan_tool;
      case BodyPart.legs:
        return Icons.directions_walk;
      case BodyPart.whole:
        return Icons.person;
    }
  }

  String _getShortDescription(BodyPart part) {
    switch (part) {
      case BodyPart.head:
        return '두통, 어지러움';
      case BodyPart.neck:
        return '목 뻣뻣함';
      case BodyPart.shoulders:
        return '어깨 결림';
      case BodyPart.chest:
        return '가슴 답답함';
      case BodyPart.stomach:
        return '소화 불량';
      case BodyPart.back:
        return '허리 통증';
      case BodyPart.arms:
        return '팔 저림';
      case BodyPart.legs:
        return '다리 피로';
      case BodyPart.whole:
        return '전체';
    }
  }

  void _toggleBodyPart(BodyPart part) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedParts.contains(part)) {
        _selectedParts.remove(part);
      } else if (_selectedParts.length < widget.maxSelection) {
        _selectedParts.add(part);
      }
    });
    widget.onSelectionChanged(_selectedParts);
  }

  void _clearSelection() {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedParts.clear();
    });
    widget.onSelectionChanged(_selectedParts);
  }
}