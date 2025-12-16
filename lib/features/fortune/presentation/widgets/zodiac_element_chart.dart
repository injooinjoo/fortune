import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../services/zodiac_compatibility_service.dart';
import '../../../../core/design_system/design_system.dart';

class ZodiacElementChart extends StatefulWidget {
  final String selectedZodiac;
  final bool showAnimation;

  const ZodiacElementChart({
    super.key,
    required this.selectedZodiac,
    this.showAnimation = true,
  });

  @override
  State<ZodiacElementChart> createState() => _ZodiacElementChartState();
}

class _ZodiacElementChartState extends State<ZodiacElementChart>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  
  String? _selectedElement;
  
  // 오행 데이터
  final Map<String, ElementData> _elementData = {
    '목(木)': ElementData(
      color: DSColors.success,
      icon: Icons.park,
      zodiacs: ['호랑이', '토끼'],
      description: '생명력과 성장을 상징하며, 인내심과 유연성을 나타냅니다.',
      characteristics: ['성장', '유연성', '인내', '창조'],
      season: '봄',
      direction: '동쪽'),
    '화(火)': ElementData(
      color: DSColors.error,
      icon: Icons.local_fire_department,
      zodiacs: ['뱀', '말'],
      description: '열정과 활력을 상징하며, 리더십과 표현력을 나타냅니다.',
      characteristics: ['열정', '활력', '리더십', '표현'],
      season: '여름',
      direction: '남쪽'),
    '토(土)': ElementData(
      color: DSColors.warning,
      icon: Icons.landscape,
      zodiacs: ['소', '용', '양', '개'],
      description: '안정과 신뢰를 상징하며, 실용성과 책임감을 나타냅니다.',
      characteristics: ['안정', '신뢰', '실용', '책임'],
      season: '환절기',
      direction: '중앙'),
    '금(金)': ElementData(
      color: DSColors.textTertiary,
      icon: Icons.diamond,
      zodiacs: ['원숭이', '닭'],
      description: '정확성과 결단력을 상징하며, 정의감과 규율을 나타냅니다.',
      characteristics: ['정확', '결단', '정의', '규율'],
      season: '가을',
      direction: '서쪽'),
    '수(水)': ElementData(
      color: DSColors.accent,
      icon: Icons.water_drop,
      zodiacs: ['쥐', '돼지'],
      description: '지혜와 유동성을 상징하며, 적응력과 통찰력을 나타냅니다.',
      characteristics: ['지혜', '유동성', '적응', '통찰'],
      season: '겨울',
      direction: '북쪽')
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this)..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.showAnimation) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
    
    // 선택된 띠의 오행 찾기
    final zodiacInfo = ZodiacCompatibilityService.zodiacInfo[widget.selectedZodiac];
    if (zodiacInfo != null) {
      _selectedElement = zodiacInfo['element'] as String;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        _buildElementWheel(),
        const SizedBox(height: 20),
        _buildElementDetails(),
        const SizedBox(height: 20),
        _buildElementRelationships(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.category,
          color: DSColors.warning,
          size: 24,
        ),
        SizedBox(width: 8),
        Text(
          '오행 분석',
          style: DSTypography.headingSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildElementWheel() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GlassContainer(
          width: 350,
          height: 350,
          padding: const EdgeInsets.all(20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 오행 상생상극 관계선
              CustomPaint(
                size: const Size(310, 310),
                painter: _ElementRelationshipPainter(
                  animationValue: _animationController.value,
                  selectedElement: _selectedElement,
                ),
              ),
              // 오행 원소들
              ..._buildElementNodes(),
              // 중앙 정보
              _buildCenterInfo(),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildElementNodes() {
    final elements = _elementData.entries.toList();
    final List<Widget> nodes = [];
    
    for (int i = 0; i < elements.length; i++) {
      final angle = (i * 72 - 90) * 3.14159 / 180;
      final radius = 120.0;
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);
      
      final element = elements[i];
      final isSelected = _selectedElement == element.key;
      
      nodes.add(
        Transform.translate(
          offset: Offset(x, y),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildElementNode(element.key, element.value, isSelected),
          ),
        ),
      );
    }
    
    return nodes;
  }

  Widget _buildElementNode(String elementName, ElementData data, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedElement = elementName),
      child: AnimatedBuilder(
        animation: isSelected ? _pulseAnimation : _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isSelected ? _pulseAnimation.value : 1.0,
            child: Container(
              width: isSelected ? 80 : 70,
              height: isSelected ? 80 : 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    data.color.withValues(alpha:0.8),
                    data.color.withValues(alpha:0.4),
                  ],
                ),
                border: Border.all(
                  color: isSelected ? Colors.white : data.color,
                  width: isSelected ? 3 : 2,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: data.color.withValues(alpha:0.6),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ] : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    data.icon,
                    color: Colors.white,
                    size: isSelected ? 28 : 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    elementName,
                    style: TextStyle(
                      fontSize: isSelected ? 14 : 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCenterInfo() {
    if (_selectedElement == null) return const SizedBox();
    
    final data = _elementData[_selectedElement]!;
    final zodiacInfo = ZodiacCompatibilityService.zodiacInfo[widget.selectedZodiac];
    final isMyElement = zodiacInfo != null && zodiacInfo['element'] == _selectedElement;
    
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            data.color.withValues(alpha:0.3),
            data.color.withValues(alpha:0.1),
          ],
        ),
        border: Border.all(
          color: data.color.withValues(alpha:0.5),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.selectedZodiac,
            style: DSTypography.headingSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white)),
          SizedBox(height: 4),
          Text(
            _selectedElement!,
            style: DSTypography.labelMedium.copyWith(
              color: data.color,
              fontWeight: FontWeight.bold)),
          if (isMyElement) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: data.color.withValues(alpha:0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '나의 오행',
                style: DSTypography.labelSmall.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildElementDetails() {
    if (_selectedElement == null) return const SizedBox();
    
    final data = _elementData[_selectedElement]!;
    
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(data.icon, color: data.color, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedElement!,
                      style: DSTypography.headingSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: data.color,
                      ),
                    ),
                    Text(
                      '${data.season} · ${data.direction}',
                      style: DSTypography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha:0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            data.description,
            style: DSTypography.labelMedium.copyWith(
              color: Colors.white,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: data.characteristics.map((trait) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: data.color.withValues(alpha:0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  trait,
                  style: DSTypography.bodySmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withValues(alpha:0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.pets,
                  color: data.color,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  '띠: ',
                  style: DSTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha:0.8),
                  ),
                ),
                ...data.zodiacs.map((zodiac) {
                  final isCurrentZodiac = zodiac == widget.selectedZodiac;
                  return Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      zodiac,
                      style: DSTypography.bodySmall.copyWith(
                        fontWeight: isCurrentZodiac ? FontWeight.bold : FontWeight.normal,
                        color: isCurrentZodiac ? data.color : Colors.white,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElementRelationships() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sync_alt,
                color: DSColors.warning,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                '오행 상생상극',
                style: DSTypography.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRelationshipRow(
            '상생',
            Icons.favorite,
            DSColors.success,
            _getGeneratingRelation(),
          ),
          const SizedBox(height: 12),
          _buildRelationshipRow(
            '상극',
            Icons.flash_on,
            DSColors.error,
            _getOvercomingRelation(),
          ),
        ],
      ),
    );
  }

  Widget _buildRelationshipRow(String title, IconData icon, Color color, String relation) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha:0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: DSTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                relation,
                style: DSTypography.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha:0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getGeneratingRelation() {
    if (_selectedElement == null) return '';
    
    final relations = {
      '목(木)': '목(木) → 화(火) : 나무가 불을 일으킨다',
      '화(火)': '화(火) → 토(土) : 불이 재가 되어 흙이 된다',
      '토(土)': '토(土) → 금(金) : 흙에서 금속이 나온다',
      '금(金)': '금(金) → 수(水) : 금속 표면에 이슬이 맺힌다',
      '수(水)': '수(水) → 목(木) : 물이 나무를 자라게 한다'};
    
    return relations[_selectedElement] ?? '';
  }

  String _getOvercomingRelation() {
    if (_selectedElement == null) return '';
    
    final relations = {
      '목(木)': '목(木) ← 금(金) : 금속이 나무를 자른다',
      '화(火)': '화(火) ← 수(水) : 물이 불을 끈다',
      '토(土)': '토(土) ← 목(木) : 나무가 흙의 양분을 빼앗는다',
      '금(金)': '금(金) ← 화(火) : 불이 금속을 녹인다',
      '수(水)': '수(水) ← 토(土) : 흙이 물을 막는다'};
    
    return relations[_selectedElement] ?? '';
  }
}

class ElementData {
  final Color color;
  final IconData icon;
  final List<String> zodiacs;
  final String description;
  final List<String> characteristics;
  final String season;
  final String direction;

  ElementData({
    required this.color,
    required this.icon,
    required this.zodiacs,
    required this.description,
    required this.characteristics,
    required this.season,
    required this.direction});
}

class _ElementRelationshipPainter extends CustomPainter {
  final double animationValue;
  final String? selectedElement;

  _ElementRelationshipPainter({
    required this.animationValue,
    this.selectedElement});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    
    // 오행 위치
    final elements = ['목(木)', '화(火)', '토(土)', '금(金)', '수(水)'];
    final Map<String, Offset> positions = {};
    
    for (int i = 0; i < elements.length; i++) {
      final angle = (i * 72 - 90) * 3.14159 / 180;
      positions[elements[i]] = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle));
    }
    
    // 상생 관계 그리기 (오각형)
    _drawGeneratingCycle(canvas, positions, elements);
    
    // 상극 관계 그리기 (별모양)
    _drawOvercomingCycle(canvas, positions);
  }

  void _drawGeneratingCycle(Canvas canvas, Map<String, Offset> positions, List<String> elements) {
    final paint = Paint()
      ..color = DSColors.success.withValues(alpha:0.3 * animationValue)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    for (int i = 0; i < elements.length; i++) {
      final element = elements[i];
      final pos = positions[element]!;
      if (i == 0) {
        path.moveTo(pos.dx, pos.dy);
      } else {
        path.lineTo(pos.dx, pos.dy);
      }
    }
    path.close();
    
    canvas.drawPath(path, paint);
  }

  void _drawOvercomingCycle(Canvas canvas, Map<String, Offset> positions) {
    final paint = Paint()
      ..color = DSColors.error.withValues(alpha:0.2 * animationValue)
      ..strokeWidth = 1.5
     
   
    ..style = PaintingStyle.stroke;
    
    // 상극 관계 (별모양)
    final overcoming = {
      '목(木)': '토(土)',
      '토(土)': '수(水)',
      '수(水)': '화(火)',
      '화(火)': '금(金)',
      '금(金)': '목(木)'};
    
    overcoming.forEach((from, to) {
      if (positions.containsKey(from) && positions.containsKey(to)) {
        _drawDashedLine(canvas, positions[from]!, positions[to]!, paint);
      }
    });
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    final distance = (p2 - p1).distance;
    final dashLength = 5.0;
    final dashSpace = 5.0;
    final dashCount = (distance / (dashLength + dashSpace)).floor();
    
    for (int i = 0; i < dashCount; i++) {
      final start = p1 + (p2 - p1) * (i * (dashLength + dashSpace) / distance);
      final end = p1 + (p2 - p1) * ((i * (dashLength + dashSpace) + dashLength) / distance);
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

