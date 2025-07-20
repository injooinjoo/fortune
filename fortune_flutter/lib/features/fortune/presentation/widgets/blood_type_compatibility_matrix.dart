import 'package:flutter/material.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../services/blood_type_analysis_service.dart';

class BloodTypeCompatibilityMatrix extends StatefulWidget {
  final String? selectedType1;
  final String? selectedRh1;
  final String? selectedType2;
  final String? selectedRh2;
  final Function(String, String, String, String) onPairSelected;
  final bool showAnimation;

  const BloodTypeCompatibilityMatrix({
    Key? key,
    this.selectedType1,
    this.selectedRh1,
    this.selectedType2,
    this.selectedRh2,
    required this.onPairSelected,
    this.showAnimation = true,
  }) : super(key: key);

  @override
  State<BloodTypeCompatibilityMatrix> createState() => _BloodTypeCompatibilityMatrixState();
}

class _BloodTypeCompatibilityMatrixState extends State<BloodTypeCompatibilityMatrix>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  int? _hoveredRow;
  int? _hoveredCol;
  
  final List<String> _bloodTypes = ['A', 'B', 'O', 'AB'];
  final List<String> _rhTypes = ['+', '-'];

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
        const SizedBox(height: 20),
        _buildLegend(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.bloodtype,
          color: Colors.red,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          '혈액형 궁합 매트릭스',
          style: TextStyle(
            fontSize: 20,
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
              // 상단 헤더
              Row(
                children: [
                  const SizedBox(width: 50), // 왼쪽 여백
                  ..._buildColumnHeaders(),
                ],
              ),
              const SizedBox(height: 10),
              // 매트릭스 본체
              ..._buildMatrixRows(),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildColumnHeaders() {
    final headers = <Widget>[];
    
    for (final bloodType in _bloodTypes) {
      for (final rh in _rhTypes) {
        final col = _bloodTypes.indexOf(bloodType) * 2 + _rhTypes.indexOf(rh);
        headers.add(
          Expanded(
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _hoveredCol == col
                      ? Colors.red
                      : Colors.white.withOpacity(0.8),
                ),
                child: Text('$bloodType$rh'),
              ),
            ),
          ),
        );
      }
    }
    
    return headers;
  }

  List<Widget> _buildMatrixRows() {
    final rows = <Widget>[];
    
    for (final bloodType1 in _bloodTypes) {
      for (final rh1 in _rhTypes) {
        final row = _bloodTypes.indexOf(bloodType1) * 2 + _rhTypes.indexOf(rh1);
        
        rows.add(
          Row(
            children: [
              // 행 헤더
              SizedBox(
                width: 50,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _hoveredRow == row
                        ? Colors.red
                        : Colors.white.withOpacity(0.8),
                  ),
                  child: Text('$bloodType1$rh1'),
                ),
              ),
              // 셀들
              ..._buildMatrixCells(bloodType1, rh1, row),
            ],
          ),
        );
        
        if (row < 7) {
          rows.add(const SizedBox(height: 2));
        }
      }
    }
    
    return rows;
  }

  List<Widget> _buildMatrixCells(String bloodType1, String rh1, int row) {
    final cells = <Widget>[];
    
    for (final bloodType2 in _bloodTypes) {
      for (final rh2 in _rhTypes) {
        final col = _bloodTypes.indexOf(bloodType2) * 2 + _rhTypes.indexOf(rh2);
        final compatibility = BloodTypeAnalysisService.calculateCompatibility(
          bloodType1, rh1, bloodType2, rh2,
        );
        
        final isSelected = widget.selectedType1 == bloodType1 &&
            widget.selectedRh1 == rh1 &&
            widget.selectedType2 == bloodType2 &&
            widget.selectedRh2 == rh2;
        
        final isHovered = _hoveredRow == row && _hoveredCol == col;
        
        cells.add(
          Expanded(
            child: GestureDetector(
              onTap: () => widget.onPairSelected(bloodType1, rh1, bloodType2, rh2),
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
                  height: 40,
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: _getCompatibilityColor(compatibility)
                        .withOpacity(_fadeAnimation.value * 0.8),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : Colors.transparent,
                      width: isSelected ? 2 : 0,
                    ),
                    boxShadow: (isSelected || isHovered) ? [
                      BoxShadow(
                        color: _getCompatibilityColor(compatibility)
                            .withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ] : [],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(compatibility * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: isHovered ? 12 : 10,
                            fontWeight: isHovered
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: Colors.white,
                          ),
                        ),
                        if (isHovered)
                          Text(
                            '$bloodType1$rh1 × $bloodType2$rh2',
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.white70,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    
    return cells;
  }

  Widget _buildSelectedInfo() {
    if (widget.selectedType1 == null || widget.selectedType2 == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Text(
          '매트릭스에서 두 혈액형을 선택하면 상세 궁합을 확인할 수 있습니다',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final compatibility = BloodTypeAnalysisService.calculateCompatibility(
      widget.selectedType1!,
      widget.selectedRh1!,
      widget.selectedType2!,
      widget.selectedRh2!,
    );
    
    final synergy = BloodTypeAnalysisService.getSpecialSynergy(
      widget.selectedType1!,
      widget.selectedRh1!,
      widget.selectedType2!,
      widget.selectedRh2!,
    );
    
    final dynamics = BloodTypeAnalysisService.analyzeRelationshipDynamics(
      widget.selectedType1!,
      widget.selectedRh1!,
      widget.selectedType2!,
      widget.selectedRh2!,
    );

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBloodTypeInfo(widget.selectedType1!, widget.selectedRh1!),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: _getCompatibilityColor(compatibility),
                      size: 32,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(compatibility * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getCompatibilityColor(compatibility),
                      ),
                    ),
                  ],
                ),
              ),
              _buildBloodTypeInfo(widget.selectedType2!, widget.selectedRh2!),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getCompatibilityColor(compatibility).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getCompatibilityColor(compatibility).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  synergy['type'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getCompatibilityColor(compatibility),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  synergy['description'],
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildDynamicsInfo(dynamics),
        ],
      ),
    );
  }

  Widget _buildBloodTypeInfo(String bloodType, String rh) {
    final characteristics = BloodTypeAnalysisService.bloodTypeCharacteristics[bloodType]!;
    final rhData = BloodTypeAnalysisService.rhCharacteristics[rh]!;
    
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.red.shade400,
                Colors.red.shade600,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$bloodType$rh',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          characteristics['element'],
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicsInfo(Map<String, dynamic> dynamics) {
    final communication = dynamics['communication'] as Map<String, dynamic>;
    final conflict = dynamics['conflict_resolution'] as Map<String, dynamic>;
    final growth = dynamics['growth_potential'] as Map<String, dynamic>;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDynamicItem(
              '소통',
              communication['compatibility'],
              Icons.chat,
              Colors.blue,
            ),
            _buildDynamicItem(
              '갈등해결',
              conflict['compatibility'],
              Icons.handshake,
              Colors.green,
            ),
            _buildDynamicItem(
              '성장가능성',
              growth['score'],
              Icons.trending_up,
              Colors.purple,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dynamics['advice'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicItem(String label, double value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.2),
          ),
          child: Center(
            child: Icon(icon, color: color, size: 24),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${(value * 100).toInt()}%',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem('최고 궁합', Colors.green, '90% 이상'),
          const SizedBox(width: 20),
          _buildLegendItem('좋은 궁합', Colors.blue, '70-89%'),
          const SizedBox(width: 20),
          _buildLegendItem('보통 궁합', Colors.amber, '50-69%'),
          const SizedBox(width: 20),
          _buildLegendItem('도전적 관계', Colors.orange, '50% 미만'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String range) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              range,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getCompatibilityColor(double compatibility) {
    if (compatibility >= 0.9) return Colors.green;
    if (compatibility >= 0.7) return Colors.blue;
    if (compatibility >= 0.5) return Colors.amber;
    return Colors.orange;
  }
}