import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../services/zodiac_compatibility_service.dart';

class ZodiacCompatibilityMatrix extends StatefulWidget {
  final String? selectedZodiac1;
  final String? selectedZodiac2;
  final Function(String, String) onPairSelected;
  final bool showAnimation;

  const ZodiacCompatibilityMatrix({
    super.key,
    this.selectedZodiac1,
    this.selectedZodiac2,
    required this.onPairSelected,
    this.showAnimation = true,
  });

  @override
  State<ZodiacCompatibilityMatrix> createState() => _ZodiacCompatibilityMatrixState();
}

class _ZodiacCompatibilityMatrixState extends State<ZodiacCompatibilityMatrix>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int? _hoveredRow;
  int? _hoveredCol;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.showAnimation) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        _buildMatrix(),
        const SizedBox(height: 20),
        _buildSelectedInfo(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.grid_on,
          color: DSColors.accentSecondary,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          '띠별 궁합 매트릭스',
          style: DSTypography.headingMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildMatrix() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 상단 띠 라벨
              Row(
                children: [
                  const SizedBox(width: 40), // 왼쪽 여백
                  ...List.generate(12, (col) {
                    final zodiac = ZodiacCompatibilityService.zodiacAnimals[col];
                    return Expanded(
                      child: Center(
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Text(
                            zodiac,
                            style: DSTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _hoveredCol == col
                                  ? DSColors.accentTertiary
                                  : Colors.white.withValues(alpha: 0.8)),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 10),
              // 매트릭스 본체
              ...List.generate(12, (row) {
                final zodiac1 = ZodiacCompatibilityService.zodiacAnimals[row];
                return Row(
                  children: [
                    // 왼쪽 띠 라벨
                    SizedBox(
                      width: 40,
                      child: Text(
                        zodiac1,
                        style: DSTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _hoveredRow == row
                              ? DSColors.accentTertiary
                              : Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    // 궁합 셀들
                    ...List.generate(12, (col) {
                      final zodiac2 = ZodiacCompatibilityService.zodiacAnimals[col];
                      final compatibility = ZodiacCompatibilityService.calculateCompatibility(
                        zodiac1,
                        zodiac2);
                      final isSelected = widget.selectedZodiac1 == zodiac1 &&
                          widget.selectedZodiac2 == zodiac2;
                      final isHovered = _hoveredRow == row && _hoveredCol == col;
                      
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => widget.onPairSelected(zodiac1, zodiac2),
                          child: MouseRegion(
                            onEnter: (_) => setState(() {
                              _hoveredRow = row;
                              _hoveredCol = col;
                            }),
                            onExit: (_) => setState(() {
                              _hoveredRow = null;
                              _hoveredCol = null;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 35,
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: _getCompatibilityColor(compatibility)
                                    .withValues(alpha: _fadeAnimation.value * 0.8),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: isSelected ? 2 : 0),
                                boxShadow: (isSelected || isHovered) ? [
                                  BoxShadow(
                                    color: _getCompatibilityColor(compatibility)
                                        .withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2)] : []),
                              child: Center(
                                child: Text(
                                  '${(compatibility * 100).toInt()}',
                                  style: TextStyle(
                                    fontSize: isHovered ? 12 : 10,
                                    fontWeight: isHovered
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedInfo() {
    if (widget.selectedZodiac1 == null || widget.selectedZodiac2 == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Text(
          '매트릭스에서 두 띠를 선택하면 상세 궁합을 확인할 수 있습니다',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final compatibility = ZodiacCompatibilityService.calculateCompatibility(
      widget.selectedZodiac1!,
      widget.selectedZodiac2!);
    final description = ZodiacCompatibilityService.getRelationshipDescription(
      widget.selectedZodiac1!,
      widget.selectedZodiac2!);

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildZodiacInfo(widget.selectedZodiac1!),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: _getCompatibilityColor(compatibility),
                      size: 32),
                    const SizedBox(height: 4),
                    Text(
                      '${(compatibility * 100).toInt()}%',
                      style: DSTypography.displaySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getCompatibilityColor(compatibility)),
                    ),
                  ],
                ),
              ),
              _buildZodiacInfo(widget.selectedZodiac2!),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getCompatibilityColor(compatibility).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getCompatibilityColor(compatibility).withValues(alpha: 0.3),
                width: 1)),
            child: Text(
              description,
              style: DSTypography.labelMedium.copyWith(
                color: Colors.white,
                height: 1.5),
              textAlign: TextAlign.center)),
          const SizedBox(height: 16),
          _buildDetailedAnalysis()]));
  }

  Widget _buildZodiacInfo(String zodiac) {
    final info = ZodiacCompatibilityService.zodiacInfo[zodiac]!;
    
    return Column(
      children: [
        Text(
          _getZodiacEmoji(zodiac),
          style: DSTypography.displayLarge),
        const SizedBox(height: 8),
        Text(
          zodiac,
          style: DSTypography.headingSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white)),
        Text(
          '${info['hanja']} · ${info['element']}',
          style: DSTypography.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.8)))]);
  }

  Widget _buildDetailedAnalysis() {
    final info1 = ZodiacCompatibilityService.zodiacInfo[widget.selectedZodiac1!]!;
    final info2 = ZodiacCompatibilityService.zodiacInfo[widget.selectedZodiac2!]!;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildAnalysisItem(
              '성격 궁합',
              _analyzeTraitCompatibility(
                info1['traits'],
                info2['traits']),
              Icons.psychology),
            _buildAnalysisItem(
              '오행 궁합',
              _analyzeElementCompatibility(
                info1['element'],
                info2['element']),
              Icons.whatshot),
            _buildAnalysisItem(
              '음양 궁합',
              _analyzeYinYangCompatibility(
                info1['yin_yang'],
                info2['yin_yang']),
              Icons.sync),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalysisItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.6), size: 24),
        const SizedBox(height: 4),
        Text(
          title,
          style: DSTypography.labelMedium.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: DSTypography.bodySmall.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white))]);
  }

  String _analyzeTraitCompatibility(List<String> traits1, List<String> traits2) {
    // 간단한 성격 궁합 분석
    final commonTraits = traits1.toSet().intersection(traits2.toSet());
    if (commonTraits.length >= 2) return '매우 좋음';
    if (commonTraits.length == 1) return '좋음';
    return '보통';
  }

  String _analyzeElementCompatibility(String element1, String element2) {
    if (element1 == element2) return '같은 기운';
    
    // 상생 관계 확인
    final generating = {
      '목(木)': '화(火)',
      '화(火)': '토(土)',
      '토(土)': '금(金)',
      '금(金)': '수(水)',
      '수(水)': '목(木)'};
    
    if (generating[element1] == element2) return '상생 관계';
    if (generating[element2] == element1) return '상생 관계';
    
    return '상극 관계';
  }

  String _analyzeYinYangCompatibility(String yinYang1, String yinYang2) {
    if (yinYang1 != yinYang2) return '조화로움';
    return '같은 에너지';
  }

  Color _getCompatibilityColor(double compatibility) {
    if (compatibility >= 0.9) return DSColors.success;
    if (compatibility >= 0.8) return DSColors.accent;
    if (compatibility >= 0.6) return DSColors.accentTertiary;
    if (compatibility >= 0.4) return DSColors.warning;
    return DSColors.error;
  }

  String _getZodiacEmoji(String zodiac) {
    const emojiMap = {
      '쥐': '🐭',
      '소': '🐮',
      '호랑이': '🐯',
      '토끼': '🐰',
      '용': '🐲',
      '뱀': '🐍',
      '말': '🐴',
      '양': '🐑',
      '원숭이': '🐵',
      '닭': '🐓',
      '개': '🐕',
      '돼지': '🐷'};
    return emojiMap[zodiac] ?? '🌟';
  }
}