import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/models/health_fortune_model.dart';
import '../../../../core/theme/toss_theme.dart';

class BodyPartSelector extends StatefulWidget {
  final List<BodyPart> selectedParts;
  final Function(List<BodyPart>) onSelectionChanged;
  final Map<BodyPart, HealthLevel>? bodyPartHealthMap; // 건강 상태별 색상 표시용

  const BodyPartSelector({
    super.key,
    required this.selectedParts,
    required this.onSelectionChanged,
    this.bodyPartHealthMap,
  });

  @override
  State<BodyPartSelector> createState() => _BodyPartSelectorState();
}

class _BodyPartSelectorState extends State<BodyPartSelector> {
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
        // 설명 텍스트
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Text(
                '특별히 신경쓰이는 부위가 있나요?',
                style: TossTheme.heading3.copyWith(
                  color: TossTheme.textBlack,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '아래 인체 그림에서 해당 부위를 터치해주세요\n(선택하지 않아도 괜찮습니다)',
                style: TossTheme.body3.copyWith(
                  color: TossTheme.textGray600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        // 인체 실루엣과 터치 가능한 영역들
        Container(
          height: 400,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                offset: const Offset(0, 2),
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // 배경 인체 실루엣 (정적)
                Center(
                  child: SvgPicture.asset(
                    'assets/images/health/body_outline.svg',
                    height: 380,
                    fit: BoxFit.fitHeight,
                  ),
                ),
                
                // 터치 가능한 영역들 오버레이
                _buildTouchableAreas(),
              ],
            ),
          ),
        ),
        
        // 선택된 부위 리스트
        if (_selectedParts.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildSelectedPartsList(),
        ],
      ],
    ).animate()
      .fadeIn(duration: 500.ms)
      .slideY(begin: 0.1, end: 0);
  }

  Widget _buildTouchableAreas() {
    return Stack(
      children: BodyPart.values
          .where((part) => part != BodyPart.whole)
          .map((part) => _buildTouchableArea(part))
          .toList(),
    );
  }

  Widget _buildTouchableArea(BodyPart part) {
    final isSelected = _selectedParts.contains(part);
    final healthLevel = widget.bodyPartHealthMap?[part];
    
    // 각 신체 부위별 위치와 크기 정의
    final areaConfig = _getAreaConfig(part);
    
    return Positioned(
      left: areaConfig['left'],
      top: areaConfig['top'],
      child: GestureDetector(
        onTap: () => _toggleBodyPart(part),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: areaConfig['width'],
          height: areaConfig['height'],
          decoration: BoxDecoration(
            color: _getAreaColor(part, isSelected, healthLevel),
            borderRadius: BorderRadius.circular(areaConfig['borderRadius'] ?? 8),
            border: Border.all(
              color: isSelected 
                  ? TossTheme.primaryBlue 
                  : TossTheme.borderGray200.withOpacity(0.5),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: TossTheme.primaryBlue.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 부위 이름 라벨
              if (!isSelected)
                Text(
                  part.displayName,
                  style: TossTheme.caption.copyWith(
                    color: TossTheme.textGray600,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              // 선택 체크마크
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
            ],
          ),
        ),
      ).animate(target: isSelected ? 1 : 0)
        .scale(end: const Offset(1.05, 1.05))
        .then()
        .scale(end: const Offset(1.0, 1.0)),
    );
  }

  Map<String, double> _getAreaConfig(BodyPart part) {
    // 인체 실루엣 기준으로 각 부위별 터치 영역 정의
    switch (part) {
      case BodyPart.head:
        return {'left': 110.0, 'top': 30.0, 'width': 80.0, 'height': 90.0, 'borderRadius': 40.0};
      case BodyPart.neck:
        return {'left': 130.0, 'top': 110.0, 'width': 40.0, 'height': 25.0, 'borderRadius': 12.0};
      case BodyPart.shoulders:
        return {'left': 70.0, 'top': 125.0, 'width': 160.0, 'height': 50.0, 'borderRadius': 25.0};
      case BodyPart.chest:
        return {'left': 90.0, 'top': 130.0, 'width': 120.0, 'height': 80.0, 'borderRadius': 40.0};
      case BodyPart.stomach:
        return {'left': 100.0, 'top': 200.0, 'width': 100.0, 'height': 70.0, 'borderRadius': 35.0};
      case BodyPart.back:
        return {'left': 110.0, 'top': 150.0, 'width': 80.0, 'height': 100.0, 'borderRadius': 40.0};
      case BodyPart.arms:
        return {'left': 40.0, 'top': 160.0, 'width': 220.0, 'height': 90.0, 'borderRadius': 15.0};
      case BodyPart.legs:
        return {'left': 100.0, 'top': 290.0, 'width': 100.0, 'height': 200.0, 'borderRadius': 20.0};
      case BodyPart.whole:
        return {'left': 0.0, 'top': 0.0, 'width': 0.0, 'height': 0.0};
    }
  }

  Color _getAreaColor(BodyPart part, bool isSelected, HealthLevel? healthLevel) {
    if (healthLevel != null) {
      // 건강 상태가 있는 경우 (결과 화면에서)
      switch (healthLevel) {
        case HealthLevel.excellent:
          return Color(0xFF4CAF50).withOpacity(isSelected ? 0.8 : 0.3);
        case HealthLevel.good:
          return Color(0xFF2196F3).withOpacity(isSelected ? 0.8 : 0.3);
        case HealthLevel.caution:
          return Color(0xFFFF9800).withOpacity(isSelected ? 0.8 : 0.3);
        case HealthLevel.warning:
          return Color(0xFFFF5722).withOpacity(isSelected ? 0.8 : 0.3);
      }
    }
    
    // 일반 선택 상태
    if (isSelected) {
      return TossTheme.primaryBlue.withOpacity(0.7);
    } else {
      // 선택되지 않은 영역도 약간 보이도록 설정
      return TossTheme.borderGray200.withOpacity(0.15);
    }
  }

  void _toggleBodyPart(BodyPart part) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedParts.contains(part)) {
        _selectedParts.remove(part);
      } else {
        _selectedParts.add(part);
      }
    });
    
    widget.onSelectionChanged(_selectedParts);
  }

  Widget _buildSelectedPartsList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TossTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '선택된 부위',
            style: TossTheme.body2.copyWith(
              fontWeight: FontWeight.w600,
              color: TossTheme.textBlack,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedParts.map((part) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: TossTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: TossTheme.primaryBlue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      part.displayName,
                      style: TossTheme.caption.copyWith(
                        color: TossTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _toggleBodyPart(part),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: TossTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}