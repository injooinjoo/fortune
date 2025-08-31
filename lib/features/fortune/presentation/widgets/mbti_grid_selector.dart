import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/toss_design_system.dart';

class MbtiGridSelector extends StatelessWidget {
  final String? selectedType;
  final ValueChanged<String> onTypeSelected;
  
  const MbtiGridSelector({
    Key? key,
    required this.selectedType,
    required this.onTypeSelected,
  }) : super(key: key);
  
  // MBTI 타입을 그룹별로 분류
  static const Map<String, List<String>> mbtiGroups = {
    'Analysts': ['INTJ', 'INTP', 'ENTJ', 'ENTP'],
    'Diplomats': ['INFJ', 'INFP', 'ENFJ', 'ENFP'],
    'Sentinels': ['ISTJ', 'ISFJ', 'ESTJ', 'ESFJ'],
    'Explorers': ['ISTP', 'ISFP', 'ESTP', 'ESFP'],
  };
  
  // 그룹별 색상
  static final Map<String, List<Color>> groupColors = {
    'Analysts': [TossDesignSystem.purple, TossDesignSystem.purple],
    'Diplomats': [TossDesignSystem.successGreen, TossDesignSystem.successGreen],
    'Sentinels': [TossDesignSystem.tossBlue, TossDesignSystem.tossBlue],
    'Explorers': [TossDesignSystem.warningOrange, TossDesignSystem.warningOrange],
  };
  
  // 타입별 아이콘
  static const Map<String, IconData> typeIcons = {
    'INTJ': Icons.architecture,
    'INTP': Icons.science,
    'ENTJ': Icons.business_center,
    'ENTP': Icons.lightbulb,
    'INFJ': Icons.psychology,
    'INFP': Icons.favorite,
    'ENFJ': Icons.group,
    'ENFP': Icons.celebration,
    'ISTJ': Icons.checklist,
    'ISFJ': Icons.shield,
    'ESTJ': Icons.gavel,
    'ESFJ': Icons.people,
    'ISTP': Icons.build,
    'ISFP': Icons.palette,
    'ESTP': Icons.sports,
    'ESFP': Icons.music_note,
  };
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Grid layout - 4x4
        AspectRatio(
          aspectRatio: 1.0,
          child: GridView.count(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            physics: const NeverScrollableScrollPhysics(),
            children: _buildMbtiGrid(context),
          ),
        ),
        const SizedBox(height: TossDesignSystem.spacingM),
        // Group legend
        _buildGroupLegend(context),
      ],
    );
  }
  
  List<Widget> _buildMbtiGrid(BuildContext context) {
    final allTypes = <Widget>[];
    int animationDelay = 0;
    
    // Flatten the groups into a 4x4 grid
    final typesList = [
      'INTJ', 'INTP', 'ENTJ', 'ENTP',
      'INFJ', 'INFP', 'ENFJ', 'ENFP',
      'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
      'ISTP', 'ISFP', 'ESTP', 'ESFP',
    ];
    
    for (final type in typesList) {
      final groupName = _getGroupForType(type);
      final isSelected = selectedType == type;
      final colors = groupColors[groupName] ?? [Colors.grey, Colors.grey];
      
      allTypes.add(
        _MbtiTypeCard(
          type: type,
          isSelected: isSelected,
          colors: colors,
          icon: typeIcons[type] ?? Icons.person,
          onTap: () => onTypeSelected(type),
        ).animate()
          .fadeIn(duration: 300.ms, delay: (animationDelay * 30).ms)
          .scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
            duration: 300.ms,
            delay: (animationDelay * 30).ms,
          ),
      );
      animationDelay++;
    }
    
    return allTypes;
  }
  
  Widget _buildGroupLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: mbtiGroups.entries.map((entry) {
        final groupName = entry.key;
        final colors = groupColors[groupName]!;
        final groupNameKr = _getGroupNameKr(groupName);
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: TossDesignSystem.spacingXS),
            Text(
              groupNameKr,
              style: TossDesignSystem.caption,
            ),
          ],
        );
      }).toList(),
    );
  }
  
  String _getGroupForType(String type) {
    for (final entry in mbtiGroups.entries) {
      if (entry.value.contains(type)) {
        return entry.key;
      }
    }
    return 'Analysts';
  }
  
  String _getGroupNameKr(String groupName) {
    switch (groupName) {
      case 'Analysts':
        return '분석가';
      case 'Diplomats':
        return '외교관';
      case 'Sentinels':
        return '관리자';
      case 'Explorers':
        return '탐험가';
      default:
        return groupName;
    }
  }
}

class _MbtiTypeCard extends StatefulWidget {
  final String type;
  final bool isSelected;
  final List<Color> colors;
  final IconData icon;
  final VoidCallback onTap;
  
  const _MbtiTypeCard({
    Key? key,
    required this.type,
    required this.isSelected,
    required this.colors,
    required this.icon,
    required this.onTap,
  }) : super(key: key);
  
  @override
  State<_MbtiTypeCard> createState() => _MbtiTypeCardState();
}

class _MbtiTypeCardState extends State<_MbtiTypeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }
  
  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }
  
  void _handleTapCancel() {
    _controller.reverse();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: TossDesignSystem.durationMedium,
              decoration: BoxDecoration(
                gradient: widget.isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.colors,
                      )
                    : null,
                color: !widget.isSelected
                    ? (isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray100)
                    : null,
                borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
                border: Border.all(
                  color: widget.isSelected
                      ? widget.colors[0]
                      : (isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200),
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: widget.colors[0].withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.icon,
                        size: 24,
                        color: widget.isSelected
                            ? Colors.white
                            : widget.colors[0],
                      ),
                      const SizedBox(height: TossDesignSystem.spacingXS),
                      Text(
                        widget.type,
                        style: TossDesignSystem.caption.copyWith(
                          color: widget.isSelected
                              ? Colors.white
                              : (isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900),
                        ),
                      ),
                    ],
                  ),
                  if (widget.isSelected)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          size: 10,
                          color: widget.colors[0],
                        ),
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
}