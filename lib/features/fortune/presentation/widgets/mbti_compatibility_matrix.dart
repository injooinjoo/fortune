import 'package:flutter/material.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../services/mbti_cognitive_functions_service.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_animations.dart';

class MbtiCompatibilityMatrix extends StatefulWidget {
  final String? selectedType1;
  final String? selectedType2;
  final Function(String, String) onPairSelected;
  final bool showAnimation;

  const MbtiCompatibilityMatrix({
    Key? key,
    this.selectedType1,
    this.selectedType2,
    required this.onPairSelected,
    this.showAnimation = true}) : super(key: key);

  @override
  State<MbtiCompatibilityMatrix> createState() => _MbtiCompatibilityMatrixState();
}

class _MbtiCompatibilityMatrixState extends State<MbtiCompatibilityMatrix>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  int? _hoveredRow;
  int? _hoveredCol;
  
  final List<String> _mbtiTypes = [
    'INTJ', 'INTP', 'ENTJ', 'ENTP',
    'INFJ', 'INFP', 'ENFJ', 'ENFP',
    'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
    'ISTP', 'ISFP', 'ESTP', 'ESFP'];

  // MBTI 호환성 데이터 (0.0 ~ 1.0)
  final Map<String, Map<String, double>> _compatibilityScores = {
    // NT 타입들 (분석가)
    'INTJ': {
      'INTJ': 0.7, 'INTP': 0.85, 'ENTJ': 0.8, 'ENTP': 0.9,
      'INFJ': 0.75, 'INFP': 0.7, 'ENFJ': 0.65, 'ENFP': 0.8,
      'ISTJ': 0.6, 'ISFJ': 0.55, 'ESTJ': 0.65, 'ESFJ': 0.5,
      'ISTP': 0.7, 'ISFP': 0.6, 'ESTP': 0.65, 'ESFP': 0.55},
    'INTP': {
      'INTJ': 0.85, 'INTP': 0.75, 'ENTJ': 0.85, 'ENTP': 0.9,
      'INFJ': 0.8, 'INFP': 0.75, 'ENFJ': 0.7, 'ENFP': 0.8,
      'ISTJ': 0.55, 'ISFJ': 0.5, 'ESTJ': 0.6, 'ESFJ': 0.45,
      'ISTP': 0.75, 'ISFP': 0.65, 'ESTP': 0.7, 'ESFP': 0.6},
    'ENTJ': {
      'INTJ': 0.8, 'INTP': 0.85, 'ENTJ': 0.7, 'ENTP': 0.85,
      'INFJ': 0.7, 'INFP': 0.75, 'ENFJ': 0.75, 'ENFP': 0.8,
      'ISTJ': 0.7, 'ISFJ': 0.6, 'ESTJ': 0.75, 'ESFJ': 0.65,
      'ISTP': 0.65, 'ISFP': 0.6, 'ESTP': 0.7, 'ESFP': 0.65},
    'ENTP': {
      'INTJ': 0.9, 'INTP': 0.9, 'ENTJ': 0.85, 'ENTP': 0.75,
      'INFJ': 0.85, 'INFP': 0.8, 'ENFJ': 0.75, 'ENFP': 0.85,
      'ISTJ': 0.5, 'ISFJ': 0.45, 'ESTJ': 0.55, 'ESFJ': 0.5,
      'ISTP': 0.7, 'ISFP': 0.65, 'ESTP': 0.75, 'ESFP': 0.7},
    // NF 타입들 (외교관)
    'INFJ': {
      'INTJ': 0.75, 'INTP': 0.8, 'ENTJ': 0.7, 'ENTP': 0.85,
      'INFJ': 0.7, 'INFP': 0.85, 'ENFJ': 0.8, 'ENFP': 0.9,
      'ISTJ': 0.6, 'ISFJ': 0.7, 'ESTJ': 0.55, 'ESFJ': 0.65,
      'ISTP': 0.55, 'ISFP': 0.75, 'ESTP': 0.5, 'ESFP': 0.65},
    'INFP': {
      'INTJ': 0.7, 'INTP': 0.75, 'ENTJ': 0.75, 'ENTP': 0.8,
      'INFJ': 0.85, 'INFP': 0.75, 'ENFJ': 0.9, 'ENFP': 0.85,
      'ISTJ': 0.5, 'ISFJ': 0.65, 'ESTJ': 0.45, 'ESFJ': 0.6,
      'ISTP': 0.6, 'ISFP': 0.8, 'ESTP': 0.55, 'ESFP': 0.7},
    'ENFJ': {
      'INTJ': 0.65, 'INTP': 0.7, 'ENTJ': 0.75, 'ENTP': 0.75,
      'INFJ': 0.8, 'INFP': 0.9, 'ENFJ': 0.7, 'ENFP': 0.85,
      'ISTJ': 0.65, 'ISFJ': 0.75, 'ESTJ': 0.7, 'ESFJ': 0.8,
      'ISTP': 0.5, 'ISFP': 0.7, 'ESTP': 0.55, 'ESFP': 0.75},
    'ENFP': {
      'INTJ': 0.8, 'INTP': 0.8, 'ENTJ': 0.8, 'ENTP': 0.85,
      'INFJ': 0.9, 'INFP': 0.85, 'ENFJ': 0.85, 'ENFP': 0.75,
      'ISTJ': 0.45, 'ISFJ': 0.6, 'ESTJ': 0.5, 'ESFJ': 0.65,
      'ISTP': 0.6, 'ISFP': 0.75, 'ESTP': 0.65, 'ESFP': 0.8},
    // SJ 타입들 (수호자)
    'ISTJ': {
      'INTJ': 0.6, 'INTP': 0.55, 'ENTJ': 0.7, 'ENTP': 0.5,
      'INFJ': 0.6, 'INFP': 0.5, 'ENFJ': 0.65, 'ENFP': 0.45,
      'ISTJ': 0.7, 'ISFJ': 0.85, 'ESTJ': 0.9, 'ESFJ': 0.8,
      'ISTP': 0.75, 'ISFP': 0.6, 'ESTP': 0.65, 'ESFP': 0.55},
    'ISFJ': {
      'INTJ': 0.55, 'INTP': 0.5, 'ENTJ': 0.6, 'ENTP': 0.45,
      'INFJ': 0.7, 'INFP': 0.65, 'ENFJ': 0.75, 'ENFP': 0.6,
      'ISTJ': 0.85, 'ISFJ': 0.75, 'ESTJ': 0.8, 'ESFJ': 0.9,
      'ISTP': 0.65, 'ISFP': 0.75, 'ESTP': 0.6, 'ESFP': 0.7},
    'ESTJ': {
      'INTJ': 0.65, 'INTP': 0.6, 'ENTJ': 0.75, 'ENTP': 0.55,
      'INFJ': 0.55, 'INFP': 0.45, 'ENFJ': 0.7, 'ENFP': 0.5,
      'ISTJ': 0.9, 'ISFJ': 0.8, 'ESTJ': 0.7, 'ESFJ': 0.85,
      'ISTP': 0.7, 'ISFP': 0.55, 'ESTP': 0.75, 'ESFP': 0.6},
    'ESFJ': {
      'INTJ': 0.5, 'INTP': 0.45, 'ENTJ': 0.65, 'ENTP': 0.5,
      'INFJ': 0.65, 'INFP': 0.6, 'ENFJ': 0.8, 'ENFP': 0.65,
      'ISTJ': 0.8, 'ISFJ': 0.9, 'ESTJ': 0.85, 'ESFJ': 0.75,
      'ISTP': 0.6, 'ISFP': 0.7, 'ESTP': 0.65, 'ESFP': 0.85},
    // SP 타입들 (탐험가)
    'ISTP': {
      'INTJ': 0.7, 'INTP': 0.75, 'ENTJ': 0.65, 'ENTP': 0.7,
      'INFJ': 0.55, 'INFP': 0.6, 'ENFJ': 0.5, 'ENFP': 0.6,
      'ISTJ': 0.75, 'ISFJ': 0.65, 'ESTJ': 0.7, 'ESFJ': 0.6,
      'ISTP': 0.7, 'ISFP': 0.75, 'ESTP': 0.85, 'ESFP': 0.7},
    'ISFP': {
      'INTJ': 0.6, 'INTP': 0.65, 'ENTJ': 0.6, 'ENTP': 0.65,
      'INFJ': 0.75, 'INFP': 0.8, 'ENFJ': 0.7, 'ENFP': 0.75,
      'ISTJ': 0.6, 'ISFJ': 0.75, 'ESTJ': 0.55, 'ESFJ': 0.7,
      'ISTP': 0.75, 'ISFP': 0.7, 'ESTP': 0.7, 'ESFP': 0.85},
    'ESTP': {
      'INTJ': 0.65, 'INTP': 0.7, 'ENTJ': 0.7, 'ENTP': 0.75,
      'INFJ': 0.5, 'INFP': 0.55, 'ENFJ': 0.55, 'ENFP': 0.65,
      'ISTJ': 0.65, 'ISFJ': 0.6, 'ESTJ': 0.75, 'ESFJ': 0.65,
      'ISTP': 0.85, 'ISFP': 0.7, 'ESTP': 0.75, 'ESFP': 0.8},
    'ESFP': {
      'INTJ': 0.55, 'INTP': 0.6, 'ENTJ': 0.65, 'ENTP': 0.7,
      'INFJ': 0.7, 'INFP': 0.75, 'ENFJ': 0.75, 'ENFP': 0.8,
      'ISTJ': 0.55, 'ISFJ': 0.7, 'ESTJ': 0.6, 'ESFJ': 0.8,
      'ISTP': 0.7, 'ISFP': 0.85, 'ESTP': 0.8, 'ESFP': 0.75}};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.durationSkeleton,
      vsync: this);
    
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut));
    
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
        const SizedBox(height: AppSpacing.spacing5),
        _buildMatrix(),
        const SizedBox(height: AppSpacing.spacing5),
        _buildSelectedInfo(),
        const SizedBox(height: AppSpacing.spacing5),
        _buildLegend(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.grid_on,
          color: Colors.purple,
          size: 24),
        const SizedBox(width: AppSpacing.spacing2),
        Text(
          'MBTI 궁합 매트릭스',
          style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildMatrix() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: GlassContainer(
              padding: AppSpacing.paddingAll20,
              child: Column(
                children: [
                  // 상단 헤더
                  Row(
                    children: [
                      const SizedBox(width: AppSpacing.spacing15), // 왼쪽 여백
                      ..._mbtiTypes.map((type) {
                        final col = _mbtiTypes.indexOf(type);
                        return SizedBox(
                          width: 45,
                          child: Center(
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: Text(
                                type,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        );
                      }).toList()]),
                  const SizedBox(height: AppSpacing.spacing2 * 1.25),
                  // 매트릭스 본체
                  ..._mbtiTypes.map((type1) {
                    final row = _mbtiTypes.indexOf(type1);
                    return Row(
                      children: [
                        // 왼쪽 헤더
                        SizedBox(
                          width: 60,
                          child: Text(
                            type1,
                            style: Theme.of(context).textTheme.bodyMedium)),
                        // 셀들
                        ..._mbtiTypes.map((type2) {
                          final col = _mbtiTypes.indexOf(type2);
                          final score = _compatibilityScores[type1]![type2]!;
                          final isSelected = widget.selectedType1 == type1 &&
                              widget.selectedType2 == type2;
                          final isHovered = _hoveredRow == row && _hoveredCol == col;
                          
                          return GestureDetector(
                            onTap: () => widget.onPairSelected(type1, type2),
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
                                duration: AppAnimations.durationShort,
                                width: 45,
                                height: 35,
                                margin: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: _getCompatibilityColor(score)
                                      .withOpacity(_fadeAnimation.value * 0.8),
                                  borderRadius: AppDimensions.borderRadiusSmall,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: isSelected ? 2 : 0),
                                  boxShadow: (isSelected || isHovered) ? [
                                    BoxShadow(
                                      color: _getCompatibilityColor(score)
                                          .withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2)] : []),
                                child: Center(
                                  child: Text(
                                    '${(score * 100).toInt()}',
                                    style: TextStyle(
                                      fontSize: isHovered ? 11 : 10,
                                      fontWeight: isHovered
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedInfo() {
    if (widget.selectedType1 == null || widget.selectedType2 == null) {
      return Container(
        padding: AppSpacing.paddingAll20,
        child: Text(
          '매트릭스에서 두 MBTI 유형을 선택하면 상세 궁합을 확인할 수 있습니다',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize),
          textAlign: TextAlign.center),
      );
    }

    final score = _compatibilityScores[widget.selectedType1]![widget.selectedType2]!;
    final analysis = _getCompatibilityAnalysis(widget.selectedType1!, widget.selectedType2!);

    return GlassContainer(
      padding: AppSpacing.paddingAll20,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTypeInfo(widget.selectedType1!),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing5),
                child: Column(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: _getCompatibilityColor(score),
                      size: 32),
                    const SizedBox(height: AppSpacing.spacing1),
                    Text(
                      '${(score * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodyMedium)])),
              _buildTypeInfo(widget.selectedType2!)]),
          const SizedBox(height: AppSpacing.spacing5),
          Container(
            padding: AppSpacing.paddingAll16,
            decoration: BoxDecoration(
              color: _getCompatibilityColor(score).withOpacity(0.1),
              borderRadius: AppDimensions.borderRadiusMedium,
              border: Border.all(
                color: _getCompatibilityColor(score).withOpacity(0.3),
                width: 1)),
            child: Column(
              children: [
                Text(
                  analysis['title']!,
                  style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.spacing2),
                Text(
                  analysis['description']!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center)])),
          const SizedBox(height: AppSpacing.spacing4),
          _buildCognitiveFunctionComparison()]));
  }

  Widget _buildTypeInfo(String type) {
    final info = MbtiCognitiveFunctionsService.mbtiData[type]!;
    final color = _getTypeColor(type);
    
    return Column(
      children: [
        Container(
          width: 60,
          height: AppSpacing.spacing15,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.8),
                color.withOpacity(0.4)]),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: 2)]),
          child: Center(
            child: Text(
              type,
              style: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
        const SizedBox(height: AppSpacing.spacing2),
        Text(
          info['title']!,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCognitiveFunctionComparison() {
    if (widget.selectedType1 == null || widget.selectedType2 == null) {
      return const SizedBox();
    }

    final functions1 = MbtiCognitiveFunctionsService.mbtiData[widget.selectedType1]!['functions'] as List<String>;
    final functions2 = MbtiCognitiveFunctionsService.mbtiData[widget.selectedType2]!['functions'] as List<String>;
    
    // 공통 기능 찾기
    final commonFunctions = functions1.toSet().intersection(functions2.toSet()).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '인지기능 비교',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.spacing3),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.selectedType1!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.spacing1),
                  ...functions1.map((func) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.spacing0 * 0.5),
                    child: Text(
                      func,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: commonFunctions.contains(func)
                            ? Colors.green
                            : Colors.white.withOpacity(0.8),
                      ),
                    ),
                  )).toList(),
                ],
              ),
            ),
            Container(
              width: 1,
              height: AppSpacing.spacing20,
              color: Colors.white.withOpacity(0.2),
              margin: AppSpacing.paddingHorizontal16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.selectedType2!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.spacing1),
                  ...functions2.map((func) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.spacing0 * 0.5),
                    child: Text(
                      func,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: commonFunctions.contains(func)
                            ? Colors.green
                            : Colors.white.withOpacity(0.8),
                      ),
                    ),
                  )).toList(),
                ],
              ),
            ),
          ],
        ),
        if (commonFunctions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.spacing3),
          Container(
            padding: AppSpacing.paddingAll12,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: AppDimensions.borderRadiusSmall,
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
                width: 1)),
            child: Row(
              children: [
                Icon(
                  Icons.sync,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.spacing2),
                Expanded(
                  child: Text(
                    '인지기능: ${commonFunctions.join(', ')}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing5, vertical: AppSpacing.spacing3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXLarge),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem('최고 궁합', Colors.green, '85% 이상'),
          const SizedBox(width: AppSpacing.spacing5),
          _buildLegendItem('좋은 궁합', Colors.blue, '70-84%'),
          const SizedBox(width: AppSpacing.spacing5),
          _buildLegendItem('보통 궁합', Colors.amber, '55-69%'),
          const SizedBox(width: AppSpacing.spacing5),
          _buildLegendItem('도전적 관계', Colors.orange, '55% 미만')]));
  }

  Widget _buildLegendItem(String label, Color color, String range) {
    return Row(
      children: [
        Container(
          width: 12,
          height: AppSpacing.spacing3,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle)),
        const SizedBox(width: AppSpacing.spacing1),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium),
            Text(
              range,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize))])]);
  }

  Color _getCompatibilityColor(double score) {
    if (score >= 0.85) return Colors.green;
    if (score >= 0.7) return Colors.blue;
    if (score >= 0.55) return Colors.amber;
    return Colors.orange;
}

  Color _getTypeColor(String type) {
    // 타입별 색상
    if (type.contains('NT')) return Colors.purple; // 분석가
    if (type.contains('NF')) return Colors.blue;   // 외교관
    if (type.contains('SJ')) return Colors.green;  // 수호자
    if (type.contains('SP')) return Colors.orange; // 탐험가
    
    // 더 세부적인 분류
    if (['INTJ', 'INTP', 'ENTJ', 'ENTP'].contains(type)) return Colors.purple;
    if (['INFJ', 'INFP', 'ENFJ', 'ENFP'].contains(type)) return Colors.blue;
    if (['ISTJ', 'ISFJ', 'ESTJ', 'ESFJ'].contains(type)) return Colors.green;
    if (['ISTP', 'ISFP', 'ESTP', 'ESFP'].contains(type)) return Colors.orange;
    
    return Colors.grey;
}

  Map<String, String> _getCompatibilityAnalysis(String type1, String type2) {
    final score = _compatibilityScores[type1]![type2]!;
    
    if (score >= 0.85) {
      return {
        'title': '최고의 궁합',
        'description': '서로를 완벽하게 이해하고 보완하는 관계입니다. 깊은 정신적 교감과 자연스러운 소통이 가능합니다.'};
    } else if (score >= 0.7) {
      return {
        'title': '좋은 궁합',
        'description': '서로 잘 맞는 편이며, 건강한 관계를 유지할 수 있습니다. 약간의 차이는 서로의 성장에 도움이 됩니다.'};
    } else if (score >= 0.55) {
      return {
        'title': '보통 궁합',
        'description': '노력하면 좋은 관계를 만들 수 있습니다. 서로의 차이를 인정하고 존중하는 것이 중요합니다.'};
    } else {
      return {
        'title': '도전적인 관계',
        'description': '서로 다른 점이 많아 이해하기 어려울 수 있지만, 그만큼 큰 성장의 기회가 될 수 있습니다.'};
    }
  }
}