import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_animations.dart';

class PersonalityAnalysisOptions extends StatelessWidget {
  final bool wantRelationshipAnalysis;
  final bool wantCareerGuidance;
  final bool wantPersonalGrowth;
  final bool wantCompatibility;
  final bool wantDailyAdvice;
  final ValueChanged<Map<String, bool>> onOptionsChanged;
  
  const PersonalityAnalysisOptions({
    Key? key,
    required this.wantRelationshipAnalysis,
    required this.wantCareerGuidance,
    required this.wantPersonalGrowth,
    required this.wantCompatibility,
    required this.wantDailyAdvice,
    required this.onOptionsChanged,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final options = [
      {
        'key': 'relationship',
        'title': '인간관계 분석',
        'description': '대인관계 패턴과 소통 방식 분석',
        'icon': Icons.people_alt_rounded,
        'color': Colors.pink,
        'value': wantRelationshipAnalysis,
      },
      {
        'key': 'career',
        'title': '직업 가이드',
        'description': '성격에 맞는 직업과 커리어 조언',
        'icon': Icons.work_rounded,
        'color': Colors.blue,
        'value': wantCareerGuidance,
      },
      {
        'key': 'growth',
        'title': '성장 조언',
        'description': '개인 성장과 자기계발 방향',
        'icon': Icons.trending_up_rounded,
        'color': Colors.green,
        'value': wantPersonalGrowth,
      },
      {
        'key': 'compatibility',
        'title': '궁합 분석',
        'description': '다른 성격 유형과의 궁합',
        'icon': Icons.favorite_rounded,
        'color': Colors.red,
        'value': wantCompatibility,
      },
      {
        'key': 'daily',
        'title': '일일 조언',
        'description': '오늘의 성격 운세와 조언',
        'icon': Icons.today_rounded,
        'color': Colors.orange,
        'value': wantDailyAdvice,
      },
    ];
    
    return Column(
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.spacing3),
          child: _AnalysisOptionCard(
            title: option['title'] as String,
            description: option['description'] as String,
            icon: option['icon'] as IconData,
            color: option['color'] as Color,
            value: option['value'] as bool,
            onChanged: (value) {
              final newOptions = {
                'relationship': wantRelationshipAnalysis,
                'career': wantCareerGuidance,
                'growth': wantPersonalGrowth,
                'compatibility': wantCompatibility,
                'daily': wantDailyAdvice,
              };
              newOptions[option['key'] as String] = value;
              onOptionsChanged(newOptions);
            },
          ).animate()
            .fadeIn(duration: 300.ms, delay: (index * 50).ms)
            .slideX(begin: -0.1, end: 0, duration: 300.ms, delay: (index * 50).ms),
        );
      }).toList(),
    );
  }
}

class _AnalysisOptionCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;
  
  const _AnalysisOptionCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.value,
    required this.onChanged,
  }) : super(key: key);
  
  @override
  State<_AnalysisOptionCard> createState() => _AnalysisOptionCardState();
}

class _AnalysisOptionCardState extends State<_AnalysisOptionCard>
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
      end: 0.98,
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
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: AppAnimations.durationMedium,
              padding: AppSpacing.paddingAll16,
              decoration: BoxDecoration(
                gradient: widget.value
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.color.withOpacity(0.1),
                          widget.color.withOpacity(0.05),
                        ],
                      )
                    : null,
                color: !widget.value
                    ? Theme.of(context).colorScheme.surfaceContainerHighest
                    : null,
                borderRadius: AppDimensions.borderRadiusLarge,
                border: Border.all(
                  color: widget.value
                      ? widget.color
                      : Theme.of(context).dividerColor,
                  width: widget.value ? 2 : 1,
                ),
                boxShadow: widget.value
                    ? [
                        BoxShadow(
                          color: widget.color.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.value
                          ? widget.color.withOpacity(0.2)
                          : widget.color.withOpacity(0.1),
                      borderRadius: AppDimensions.borderRadiusMedium,
                    ),
                    child: Icon(
                      widget.icon,
                      size: 24,
                      color: widget.color,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spacing4),
                  
                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: widget.value ? widget.color : null,
                          ),
                        ),
                        const SizedBox(height: 4 * 0.5),
                        Text(
                          widget.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Checkbox
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: widget.value,
                      onChanged: (value) => widget.onChanged(value ?? false),
                      activeColor: widget.color,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppDimensions.borderRadiusSmall,
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