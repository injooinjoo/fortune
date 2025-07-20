import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/saju_element_explanations.dart';
import '../../shared/glassmorphism/glass_container.dart';

class SajuElementExplanationBottomSheet extends StatefulWidget {
  final String element;
  final String elementHanja;
  final bool isCheongan;
  final String elementType; // 오행 (목, 화, 토, 금, 수)
  
  const SajuElementExplanationBottomSheet({
    super.key,
    required this.element,
    required this.elementHanja,
    required this.isCheongan,
    required this.elementType,
  });

  static Future<void> show(
    BuildContext context, {
    required String element,
    required String elementHanja,
    required bool isCheongan,
    required String elementType,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => SajuElementExplanationBottomSheet(
        element: element,
        elementHanja: elementHanja,
        isCheongan: isCheongan,
        elementType: elementType,
      ),
    );
  }

  @override
  State<SajuElementExplanationBottomSheet> createState() => _SajuElementExplanationBottomSheetState();
}

class _SajuElementExplanationBottomSheetState extends State<SajuElementExplanationBottomSheet> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Color _getElementColor(String element) {
    switch (element) {
      case '목':
        return const Color(0xFF4CAF50);
      case '화':
        return const Color(0xFFFF5722);
      case '토':
        return const Color(0xFFFFB300);
      case '금':
        return const Color(0xFF9E9E9E);
      case '수':
        return const Color(0xFF2196F3);
      default:
        return Colors.grey;
    }
  }

  IconData _getElementIcon(String element) {
    switch (element) {
      case '목':
        return Icons.park;
      case '화':
        return Icons.local_fire_department;
      case '토':
        return Icons.landscape;
      case '금':
        return Icons.diamond;
      case '수':
        return Icons.water_drop;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final explanation = SajuElementExplanations.getExplanation(widget.element, widget.isCheongan);
    
    if (explanation == null) {
      return Container();
    }
    
    final elementColor = _getElementColor(widget.elementType);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          height: screenHeight * 0.85,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHandle(),
              _buildHeader(theme, elementColor, explanation),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBasicInfo(theme, elementColor, explanation),
                      const SizedBox(height: 24),
                      _buildCharacteristics(theme, elementColor, explanation),
                      const SizedBox(height: 24),
                      _buildPersonality(theme, elementColor, explanation),
                      const SizedBox(height: 24),
                      _buildRelationships(theme, elementColor, explanation),
                      const SizedBox(height: 24),
                      _buildLuckyTips(theme, elementColor, explanation),
                      if (!widget.isCheongan) ...[
                        const SizedBox(height: 24),
                        _buildAnimalInfo(theme, elementColor, explanation),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, Color elementColor, Map<String, dynamic> explanation) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            elementColor.withValues(alpha: 0.1),
            elementColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: elementColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: elementColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.elementHanja,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.element,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ).animate()
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      duration: 300.ms,
                      curve: Curves.elasticOut,
                    ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isCheongan ? '천간 (天干)' : '지지 (地支)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        explanation['basicMeaning'] ?? '',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  shape: const CircleBorder(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo(ThemeData theme, Color elementColor, Map<String, dynamic> explanation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: elementColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: elementColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _getElementIcon(widget.elementType),
                color: elementColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '기본 정보',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(theme, '오행', '${explanation['elementName']} (${explanation['element']})'),
          if (widget.isCheongan) ...[
            _buildInfoRow(theme, '음양', explanation['yinYang']),
            _buildInfoRow(theme, '계절', explanation['season']),
            _buildInfoRow(theme, '방향', explanation['direction']),
          ] else ...[
            _buildInfoRow(theme, '띠', explanation['animal']),
            _buildInfoRow(theme, '시간', explanation['timeRange']),
            _buildInfoRow(theme, '계절', explanation['season']),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacteristics(ThemeData theme, Color elementColor, Map<String, dynamic> explanation) {
    final characteristics = List<String>.from(explanation['characteristics'] ?? []);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: elementColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.star,
                color: elementColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '주요 특징',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...characteristics.map((characteristic) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle,
                size: 20,
                color: elementColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  characteristic,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildPersonality(ThemeData theme, Color elementColor, Map<String, dynamic> explanation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: elementColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.psychology,
                color: elementColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '성격과 성향',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            explanation['personality'] ?? '',
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRelationships(ThemeData theme, Color elementColor, Map<String, dynamic> explanation) {
    final relationships = widget.isCheongan 
        ? explanation['relationships'] as Map<String, dynamic>?
        : explanation['compatibility'] as Map<String, dynamic>?;
    
    if (relationships == null || relationships.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: elementColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.people,
                color: elementColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.isCheongan ? '다른 천간과의 관계' : '다른 지지와의 궁합',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...relationships.entries.map((entry) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                elementColor.withValues(alpha: 0.05),
                elementColor.withValues(alpha: 0.02),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: elementColor.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: elementColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      color: elementColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entry.value,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildLuckyTips(ThemeData theme, Color elementColor, Map<String, dynamic> explanation) {
    final luckyTips = List<String>.from(explanation['luckyTips'] ?? []);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.lightbulb,
                color: Colors.amber,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '행운을 부르는 팁',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.withValues(alpha: 0.1),
                Colors.amber.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.amber.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: luckyTips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.stars,
                    size: 16,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimalInfo(ThemeData theme, Color elementColor, Map<String, dynamic> explanation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getAnimalEmoji(explanation['animal'] ?? ''),
                style: const TextStyle(fontSize: 30),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${explanation['animal']}띠',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${explanation['timeRange']} 시간대에 태어난 사람',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getAnimalEmoji(String animal) {
    switch (animal) {
      case '쥐':
        return '🐭';
      case '소':
        return '🐮';
      case '호랑이':
        return '🐯';
      case '토끼':
        return '🐰';
      case '용':
        return '🐲';
      case '뱀':
        return '🐍';
      case '말':
        return '🐴';
      case '양':
        return '🐑';
      case '원숭이':
        return '🐵';
      case '닭':
        return '🐓';
      case '개':
        return '🐕';
      case '돼지':
        return '🐷';
      default:
        return '🔮';
    }
  }
}