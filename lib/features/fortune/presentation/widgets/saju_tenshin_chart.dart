import 'package:flutter/material.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/components/app_card.dart';

/// 십신 분포 차트 위젯
class SajuTenshinChart extends StatefulWidget {
  final Map<String, dynamic> tenshinDistribution;
  final AnimationController animationController;

  const SajuTenshinChart({
    super.key,
    required this.tenshinDistribution,
    required this.animationController,
  });

  @override
  State<SajuTenshinChart> createState() => _SajuTenshinChartState();
}

class _SajuTenshinChartState extends State<SajuTenshinChart> {
  late Animation<double> _titleAnimation;
  late List<Animation<double>> _barAnimations;

  // 십신 정보
  final Map<String, Map<String, dynamic>> _tenshinInfo = {
    '비견': {
      'meaning': '형제, 동료, 경쟁자',
      'description': '협력과 경쟁을 통한 성장',
      'color': TossTheme.brandBlue,
      'icon': Icons.people_outline,
    },
    '겁재': {
      'meaning': '도전, 투쟁, 변화',
      'description': '역경을 통한 강화',
      'color': TossTheme.error,
      'icon': Icons.trending_up,
    },
    '식신': {
      'meaning': '재능, 표현, 창조',
      'description': '타고난 재능과 창의력',
      'color': TossTheme.success,
      'icon': Icons.palette_outlined,
    },
    '상관': {
      'meaning': '예술, 기술, 창의',
      'description': '특별한 기술과 예술성',
      'color': TossDesignSystem.purple,
      'icon': Icons.auto_awesome,
    },
    '편재': {
      'meaning': '사업, 투자, 변화',
      'description': '유동적인 재물과 기회',
      'color': TossTheme.warning,
      'icon': Icons.trending_up,
    },
    '정재': {
      'meaning': '안정된 재물, 근면',
      'description': '꾸준한 노력으로 얻는 재물',
      'color': TossDesignSystem.warningYellow,
      'icon': Icons.savings_outlined,
    },
    '편관': {
      'meaning': '권력, 도전, 변혁',
      'description': '강력한 추진력과 개혁',
      'color': TossDesignSystem.infoBlue,
      'icon': Icons.flash_on_outlined,
    },
    '정관': {
      'meaning': '명예, 지위, 책임',
      'description': '사회적 인정과 명예',
      'color': TossDesignSystem.tossBlue,
      'icon': Icons.workspace_premium_outlined,
    },
    '편인': {
      'meaning': '학문, 종교, 직관',
      'description': '특별한 지식과 영적 성장',
      'color': TossDesignSystem.gray600,
      'icon': Icons.school_outlined,
    },
    '정인': {
      'meaning': '어머니, 교육, 보호',
      'description': '체계적인 교육과 보살핌',
      'color': TossDesignSystem.pinkPrimary,
      'icon': Icons.favorite_outline,
    },
  };

  @override
  void initState() {
    super.initState();
    
    _titleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: const Interval(0.4, 0.6, curve: Curves.easeOut),
    ));

    // 십신별 애니메이션 생성 (존재하는 십신만)
    final existingTenshin = widget.tenshinDistribution.entries
        .where((entry) => entry.value > 0)
        .toList();
    
    _barAnimations = List.generate(existingTenshin.length, (index) {
      return Tween<double>(
        begin: 0,
        end: 1,
      ).animate(CurvedAnimation(
        parent: widget.animationController,
        curve: Interval(
          0.6 + index * 0.05,
          0.8 + index * 0.05,
          curve: Curves.elasticOut,
        ),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    // 값이 0보다 큰 십신만 필터링
    final activeTenshin = widget.tenshinDistribution.entries
        .where((entry) => entry.value > 0)
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value)); // 내림차순 정렬

    if (activeTenshin.isEmpty) {
      return const SizedBox.shrink();
    }

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
                      Icons.psychology_outlined,
                      color: TossTheme.brandBlue,
                      size: 24,
                    ),
                    const SizedBox(width: TossTheme.spacingS),
                    Text(
                      '십신 분포',
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
                  '당신의 성격과 재능을 나타내는 십신 분석입니다',
                  style: TossTheme.caption.copyWith(
                    color: TossTheme.textGray600,
                  ),
                ),
              ),
              
              const SizedBox(height: TossTheme.spacingL),
              
              // 십신 차트
              ...activeTenshin.asMap().entries.map((entry) {
                final index = entry.key;
                final tenshinEntry = entry.value;
                final tenshin = tenshinEntry.key;
                final count = tenshinEntry.value as int;
                
                return _buildTenshinBar(tenshin, count, index);
              }),
              
              const SizedBox(height: TossTheme.spacingL),
              
              // 십신 해석
              _buildTenshinInterpretation(activeTenshin),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTenshinBar(String tenshin, int count, int index) {
    final info = _tenshinInfo[tenshin];
    if (info == null) return const SizedBox.shrink();
    
    final maxCount = widget.tenshinDistribution.values
        .where((v) => v > 0)
        .fold<int>(0, (max, v) => v > max ? v : max);
    final progress = count / maxCount;
    final color = info['color'] as Color;
    
    return Container(
      margin: const EdgeInsets.only(bottom: TossTheme.spacingM),
      child: Column(
        children: [
          Row(
            children: [
              // 십신 아이콘과 이름
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(TossTheme.radiusS),
                ),
                child: Icon(
                  info['icon'] as IconData,
                  color: color,
                  size: 20,
                ),
              ),
              
              const SizedBox(width: TossTheme.spacingM),
              
              // 십신 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tenshin,
                          style: TossTheme.body2.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$count',
                            style: TossTheme.caption.copyWith(
                              color: TossDesignSystem.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      info['meaning'] as String,
                      style: TossTheme.caption.copyWith(
                        color: TossTheme.textGray600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: TossTheme.spacingS),
          
          // 진행 바
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: TossTheme.backgroundSecondary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                if (index < _barAnimations.length)
                  AnimatedBuilder(
                    animation: _barAnimations[index],
                    builder: (context, child) {
                      return FractionallySizedBox(
                        widthFactor: progress * _barAnimations[index].value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                color,
                                color.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTenshinInterpretation(List<MapEntry<String, dynamic>> activeTenshin) {
    if (activeTenshin.isEmpty) return const SizedBox.shrink();
    
    final dominantTenshin = activeTenshin.first.key;
    final dominantInfo = _tenshinInfo[dominantTenshin];
    
    if (dominantInfo == null) return const SizedBox.shrink();
    
    return FadeTransition(
      opacity: _titleAnimation,
      child: Container(
        padding: const EdgeInsets.all(TossTheme.spacingM),
        decoration: BoxDecoration(
          color: (dominantInfo['color'] as Color).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(TossTheme.radiusM),
          border: Border.all(
            color: (dominantInfo['color'] as Color).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star_outlined,
                  color: dominantInfo['color'] as Color,
                  size: 20,
                ),
                const SizedBox(width: TossTheme.spacingS),
                Text(
                  '주요 성향',
                  style: TossTheme.body2.copyWith(
                    fontWeight: FontWeight.bold,
                    color: dominantInfo['color'] as Color,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: TossTheme.spacingS),
            
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: dominantTenshin,
                    style: TossTheme.body2.copyWith(
                      fontWeight: FontWeight.bold,
                      color: dominantInfo['color'] as Color,
                    ),
                  ),
                  TextSpan(
                    text: '이 강하게 나타나는 당신은 ',
                    style: TossTheme.body2.copyWith(
                      color: TossTheme.textBlack,
                    ),
                  ),
                  TextSpan(
                    text: dominantInfo['description'] as String,
                    style: TossTheme.body2.copyWith(
                      color: TossTheme.textBlack,
                    ),
                  ),
                  TextSpan(
                    text: '의 특성을 가지고 있습니다.',
                    style: TossTheme.body2.copyWith(
                      color: TossTheme.textBlack,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: TossTheme.spacingM),
            
            // 십신별 조언
            _buildTenshinAdvice(dominantTenshin),
          ],
        ),
      ),
    );
  }

  Widget _buildTenshinAdvice(String dominantTenshin) {
    final adviceMap = {
      '비견': '동료들과의 협력을 통해 더 큰 성과를 이룰 수 있습니다',
      '겁재': '도전을 두려워하지 말고 변화를 받아들이세요',
      '식신': '창의적인 활동과 자기표현을 통해 성취감을 얻으세요',
      '상관': '예술이나 기술 분야에서 특별한 능력을 발휘할 수 있습니다',
      '편재': '다양한 투자와 사업 기회를 적극적으로 모색하세요',
      '정재': '꾸준한 노력과 저축을 통해 안정된 재물을 축적하세요',
      '편관': '리더십을 발휘하여 조직을 이끌어갈 수 있습니다',
      '정관': '사회적 명예와 지위를 얻기 위해 노력하세요',
      '편인': '학문이나 영적 성장에 관심을 가져보세요',
      '정인': '교육이나 보살핌과 관련된 일에서 보람을 찾으세요',
    };

    final advice = adviceMap[dominantTenshin] ?? '균형잡힌 삶을 추구하세요';

    return Container(
      padding: const EdgeInsets.all(TossTheme.spacingS),
      decoration: BoxDecoration(
        color: TossTheme.backgroundPrimary,
        borderRadius: BorderRadius.circular(TossTheme.radiusS),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: TossTheme.warning,
            size: 16,
          ),
          const SizedBox(width: TossTheme.spacingS),
          Expanded(
            child: Text(
              advice,
              style: TossTheme.caption.copyWith(
                color: TossTheme.textGray600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}