import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/models/health_fortune_model.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/unified_button.dart';

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
                    style: context.heading3.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  if (_selectedParts.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.colors.accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_selectedParts.length}',
                        style: context.bodySmall.copyWith(
                          color: Colors.white,
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
                style: context.buttonMedium.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              if (_selectedParts.isNotEmpty) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _clearSelection,
                  child: Text(
                    '선택 모두 해제',
                    style: context.buttonMedium.copyWith(
                      color: context.colors.accent,
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
            child: _buildBodyPartGrid(),
          ),
        ),

        // 선택된 부위 요약
        if (_selectedParts.isNotEmpty) _buildSelectedSummary(),
      ],
    );
  }

  Widget _buildBodyPartGrid() {
    final bodyParts =
        BodyPart.values.where((part) => part != BodyPart.whole).toList();

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
            return _buildBodyPartCard(part, index);
          },
        ),

        // Bottom button spacing
        const BottomButtonSpacing(),
      ],
    );
  }

  Widget _buildBodyPartCard(BodyPart part, int index) {
    final isSelected = _selectedParts.contains(part);
    final canSelect = _selectedParts.length < widget.maxSelection || isSelected;

    return GestureDetector(
      onTap: canSelect ? () => _toggleBodyPart(part) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.accent.withValues(alpha: 0.1)
              : context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? context.colors.accent
                : canSelect
                    ? context.colors.divider
                    : context.colors.divider.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: context.colors.accent.withValues(alpha: 0.2),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
              : null,
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
                            ? context.colors.accent.withValues(alpha: 0.2)
                            : context.colors.backgroundSecondary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getBodyPartIcon(part),
                        color: isSelected
                            ? context.colors.accent
                            : context.colors.textSecondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 부위 이름
                    Text(
                      part.displayName,
                      style: context.heading3.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? context.colors.accent
                            : context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // 설명
                    Text(
                      _getShortDescription(part),
                      style: context.bodySmall.copyWith(
                        color: context.colors.textTertiary,
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
                      color: context.colors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ).animate().scale(duration: 200.ms, curve: Curves.elasticOut),
                ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: (index * 50).ms)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildSelectedSummary() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.accent.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: context.colors.accent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '선택된 부위',
                style: context.heading3.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${_selectedParts.length}/${widget.maxSelection}',
                style: context.bodySmall.copyWith(
                  color: context.colors.accent,
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
                  style: context.bodySmall.copyWith(
                    color: context.colors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: context.colors.accent.withValues(alpha: 0.1),
                deleteIcon: Icon(
                  Icons.close,
                  size: 16,
                  color: context.colors.accent,
                ),
                onDeleted: () => _toggleBodyPart(part),
                side: BorderSide(
                  color: context.colors.accent.withValues(alpha: 0.3),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
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
