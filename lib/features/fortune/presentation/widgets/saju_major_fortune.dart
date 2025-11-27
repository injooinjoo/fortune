import 'package:flutter/material.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/components/app_card.dart';

/// 대운 타임라인 위젯
class SajuMajorFortune extends StatefulWidget {
  final List<Map<String, dynamic>> majorFortunes;
  final AnimationController animationController;

  const SajuMajorFortune({
    super.key,
    required this.majorFortunes,
    required this.animationController,
  });

  @override
  State<SajuMajorFortune> createState() => _SajuMajorFortuneState();
}

class _SajuMajorFortuneState extends State<SajuMajorFortune> {
  late Animation<double> _titleAnimation;
  late List<Animation<double>> _fortuneAnimations;

  @override
  void initState() {
    super.initState();
    
    _titleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: const Interval(0.5, 0.7, curve: Curves.easeOut),
    ));

    _fortuneAnimations = List.generate(
      widget.majorFortunes.take(6).length, // 6개 대운만 표시
      (index) {
        return Tween<double>(
          begin: 0,
          end: 1,
        ).animate(CurvedAnimation(
          parent: widget.animationController,
          curve: Interval(
            0.7 + index * 0.03,
            0.9 + index * 0.03,
            curve: Curves.easeOutBack,
          ),
        ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayFortunes = widget.majorFortunes.take(6).toList();
    
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        return AppCard(
          padding: const EdgeInsets.all(TossTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              FadeTransition(
                opacity: _titleAnimation,
                child: Row(
                  children: [
                    Icon(
                      Icons.timeline_outlined,
                      color: TossTheme.brandBlue,
                      size: 24,
                    ),
                    const SizedBox(width: TossTheme.spacingS),
                    Text(
                      '대운의 흐름',
                      style: TossTheme.heading2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: TossTheme.spacingS),
              
              FadeTransition(
                opacity: _titleAnimation,
                child: Text(
                  '10년 단위로 흘러가는 인생의 대운을 확인해보세요',
                  style: TossTheme.caption.copyWith(
                    color: TossTheme.textGray600,
                  ),
                ),
              ),
              
              const SizedBox(height: TossTheme.spacingL),
              
              // 대운 타임라인
              ...displayFortunes.asMap().entries.map((entry) {
                final index = entry.key;
                final fortune = entry.value;
                return _buildFortuneItem(fortune, index);
              }),
              
              const SizedBox(height: TossTheme.spacingM),
              
              // 대운 설명
              _buildFortuneExplanation(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFortuneItem(Map<String, dynamic> fortune, int index) {
    final startAge = fortune['startAge'] as int;
    final endAge = fortune['endAge'] as int;
    final name = fortune['name'] as String;
    final isCurrent = fortune['isCurrent'] as bool? ?? false;
    final interpretation = fortune['interpretation'] as String? ?? '';
    
    final isLast = index == widget.majorFortunes.take(6).length - 1;
    
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : TossTheme.spacingM),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-0.3, 0),
          end: Offset.zero,
        ).animate(index < _fortuneAnimations.length ? _fortuneAnimations[index] : _titleAnimation),
        child: ScaleTransition(
          scale: index < _fortuneAnimations.length ? _fortuneAnimations[index] : _titleAnimation,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 타임라인 인디케이터
              Column(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: isCurrent ? TossTheme.brandBlue : TossTheme.backgroundSecondary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCurrent ? TossTheme.brandBlue : TossTheme.borderPrimary,
                        width: isCurrent ? 3 : 2,
                      ),
                      boxShadow: isCurrent ? [
                        BoxShadow(
                          color: TossTheme.brandBlue.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ] : null,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 60,
                      decoration: BoxDecoration(
                        color: TossTheme.borderPrimary,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(width: TossTheme.spacingM),
              
              // 대운 내용
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(TossTheme.spacingM),
                  decoration: BoxDecoration(
                    color: isCurrent 
                        ? TossTheme.brandBlue.withValues(alpha: 0.08)
                        : TossTheme.backgroundSecondary,
                    borderRadius: BorderRadius.circular(TossTheme.radiusM),
                    border: isCurrent 
                        ? Border.all(color: TossTheme.brandBlue.withValues(alpha: 0.3))
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 연령대와 현재 표시
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$startAge세 - $endAge세',
                            style: TossTheme.body2.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isCurrent ? TossTheme.brandBlue : TossTheme.textBlack,
                            ),
                          ),
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: TossTheme.brandBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '현재',
                                style: TossTheme.caption.copyWith(
                                  color: TossDesignSystem.white,
                                  fontWeight: FontWeight.bold,
                                  
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: TossTheme.spacingS),
                      
                      // 대운 이름
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getFortuneColor(name, index).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getFortuneColor(name, index).withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              name,
                              style: TossTheme.caption.copyWith(
                                color: _getFortuneColor(name, index),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: TossTheme.spacingS),
                          Icon(
                            _getFortuneIcon(interpretation),
                            color: _getFortuneColor(name, index),
                            size: 16,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: TossTheme.spacingS),
                      
                      // 해석
                      Text(
                        interpretation,
                        style: TossTheme.caption.copyWith(
                          color: TossTheme.textGray600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFortuneExplanation() {
    return FadeTransition(
      opacity: _titleAnimation,
      child: Container(
        padding: const EdgeInsets.all(TossTheme.spacingM),
        decoration: BoxDecoration(
          color: TossTheme.backgroundSecondary,
          borderRadius: BorderRadius.circular(TossTheme.radiusM),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: TossTheme.brandBlue,
                  size: 20,
                ),
                const SizedBox(width: TossTheme.spacingS),
                Text(
                  '대운 활용법',
                  style: TossTheme.body2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: TossTheme.spacingM),
            
            ..._buildUsageTips(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildUsageTips() {
    final tips = [
      '현재 대운의 특성을 파악하여 중요한 결정을 내리세요',
      '좋은 대운일 때는 적극적인 도전을, 어려운 대운일 때는 인내를',
      '대운의 변화 시기에는 새로운 계획을 세워보세요',
      '장기적인 목표는 대운의 흐름에 맞춰 단계적으로 추진하세요',
    ];

    return tips.map((tip) {
      return Padding(
        padding: const EdgeInsets.only(bottom: TossTheme.spacingS),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: TossTheme.brandBlue,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: TossTheme.spacingM),
            Expanded(
              child: Text(
                tip,
                style: TossTheme.caption.copyWith(
                  color: TossTheme.textGray600,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Color _getFortuneColor(String fortuneName, int index) {
    // 천간지지에 따른 색상 결정
    if (fortuneName.contains('갑') || fortuneName.contains('을')) {
      return TossTheme.success; // 목
    } else if (fortuneName.contains('병') || fortuneName.contains('정')) {
      return TossTheme.error; // 화
    } else if (fortuneName.contains('무') || fortuneName.contains('기')) {
      return TossTheme.warning; // 토
    } else if (fortuneName.contains('경') || fortuneName.contains('신')) {
      return TossTheme.textGray600; // 금
    } else if (fortuneName.contains('임') || fortuneName.contains('계')) {
      return TossTheme.brandBlue; // 수
    } else {
      // 기본 색상 패턴
      final colors = [
        TossTheme.brandBlue,
        TossTheme.success,
        TossTheme.warning,
        TossTheme.error,
        TossTheme.textGray600,
      ];
      return colors[index % colors.length];
    }
  }

  IconData _getFortuneIcon(String interpretation) {
    if (interpretation.contains('성장') || interpretation.contains('발전')) {
      return Icons.trending_up;
    } else if (interpretation.contains('안정') || interpretation.contains('기반')) {
      return Icons.foundation;
    } else if (interpretation.contains('도전') || interpretation.contains('변화')) {
      return Icons.flash_on;
    } else if (interpretation.contains('수확') || interpretation.contains('결실')) {
      return Icons.eco;
    } else if (interpretation.contains('지혜') || interpretation.contains('성숙')) {
      return Icons.psychology;
    } else if (interpretation.contains('화합') || interpretation.contains('조화')) {
      return Icons.favorite;
    } else if (interpretation.contains('재물') || interpretation.contains('성공')) {
      return Icons.star;
    } else if (interpretation.contains('휴식') || interpretation.contains('재충전')) {
      return Icons.spa;
    } else {
      return Icons.circle_outlined;
    }
  }
}