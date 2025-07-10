import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/auth_provider.dart';

class LuckyColorFortunePage extends BaseFortunePage {
  const LuckyColorFortunePage({Key? key})
      : super(
          key: key,
          title: '행운의 색깔',
          description: '오늘 당신에게 행운을 가져다줄 색깔을 확인해보세요',
          fortuneType: 'lucky-color',
          requiresUserInfo: true,
        );

  @override
  ConsumerState<LuckyColorFortunePage> createState() => _LuckyColorFortunePageState();
}

class _LuckyColorFortunePageState extends BaseFortunePageState<LuckyColorFortunePage> {
  final Map<String, Map<String, dynamic>> _colorMeanings = {
    '빨강': {
      'color': Colors.red,
      'meaning': '열정과 에너지',
      'description': '활력과 열정이 필요한 날입니다. 중요한 발표나 미팅이 있다면 빨간색이 자신감을 더해줄 것입니다.',
      'items': ['빨간 넥타이', '빨간 립스틱', '빨간 액세서리'],
      'situations': ['프레젠테이션', '첫 만남', '운동'],
    },
    '파랑': {
      'color': Colors.blue,
      'meaning': '평화와 신뢰',
      'description': '차분함과 신중함이 필요한 날입니다. 집중력이 요구되는 업무나 중요한 결정을 내릴 때 도움이 됩니다.',
      'items': ['파란 셔츠', '파란 스카프', '파란 펜'],
      'situations': ['업무 집중', '계약', '공부'],
    },
    '노랑': {
      'color': Colors.yellow,
      'meaning': '창의성과 즐거움',
      'description': '밝고 긍정적인 에너지가 넘치는 날입니다. 새로운 아이디어나 창의적인 작업에 적합합니다.',
      'items': ['노란 액세서리', '노란 노트', '노란 꽃'],
      'situations': ['브레인스토밍', '친목 모임', '창작 활동'],
    },
    '초록': {
      'color': Colors.green,
      'meaning': '성장과 조화',
      'description': '균형과 안정이 필요한 날입니다. 자연과 함께하거나 건강에 신경 쓰기 좋은 시기입니다.',
      'items': ['초록 식물', '초록 가방', '초록 목걸이'],
      'situations': ['건강 관리', '명상', '자연 활동'],
    },
    '보라': {
      'color': Colors.purple,
      'meaning': '직관과 영성',
      'description': '직관력이 높아지는 날입니다. 중요한 결정이나 창의적인 작업에 유리합니다.',
      'items': ['보라 스톤', '보라 향초', '보라 소품'],
      'situations': ['명상', '예술 활동', '중요한 결정'],
    },
    '주황': {
      'color': Colors.orange,
      'meaning': '활력과 사교성',
      'description': '사교적이고 활발한 에너지가 흐르는 날입니다. 네트워킹이나 새로운 만남에 적합합니다.',
      'items': ['주황 스카프', '주황 가방', '주황 액세서리'],
      'situations': ['네트워킹', '파티', '운동'],
    },
    '분홍': {
      'color': Colors.pink,
      'meaning': '사랑과 로맨스',
      'description': '감성적이고 부드러운 에너지가 흐르는 날입니다. 연애운이 상승하고 인간관계가 원만해집니다.',
      'items': ['분홍 옷', '분홍 꽃', '분홍 액세서리'],
      'situations': ['데이트', '화해', '선물'],
    },
    '검정': {
      'color': Colors.black,
      'meaning': '권위와 보호',
      'description': '강인함과 전문성이 돋보이는 날입니다. 중요한 비즈니스 미팅이나 협상에 유리합니다.',
      'items': ['검은 정장', '검은 가방', '검은 시계'],
      'situations': ['비즈니스 미팅', '협상', '면접'],
    },
    '하양': {
      'color': Colors.white,
      'meaning': '순수와 새로움',
      'description': '새로운 시작과 정화의 에너지가 흐르는 날입니다. 마음을 비우고 새롭게 시작하기 좋습니다.',
      'items': ['흰 셔츠', '흰 손수건', '흰 꽃'],
      'situations': ['새 출발', '정리', '치유'],
    },
  };

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    // Get user profile for birth date
    final userProfile = await ref.read(userProfileProvider.future);
    
    // Calculate lucky colors based on user's birth date and current date
    final birthDate = userProfile?.birthDate ?? DateTime.now();
    final today = DateTime.now();
    
    // Primary lucky color
    final colorKeys = _colorMeanings.keys.toList();
    final primaryIndex = (birthDate.day + today.day + today.month) % colorKeys.length;
    final primaryColor = colorKeys[primaryIndex];
    final primaryColorInfo = _colorMeanings[primaryColor]!;
    
    // Secondary lucky color
    final secondaryIndex = (birthDate.month + today.day) % colorKeys.length;
    final secondaryColor = colorKeys[secondaryIndex];
    final secondaryColorInfo = _colorMeanings[secondaryColor]!;
    
    // Avoid color (opposite energy)
    final avoidIndex = (primaryIndex + colorKeys.length ~/ 2) % colorKeys.length;
    final avoidColor = colorKeys[avoidIndex];

    final description = '''오늘의 행운의 색은 ${primaryColor}입니다.

${primaryColorInfo['description']}

보조 행운색인 ${secondaryColor}도 함께 활용하면 더욱 좋은 시너지를 낼 수 있습니다.
${secondaryColorInfo['meaning']}의 에너지가 당신을 도와줄 것입니다.

오늘은 ${avoidColor}색은 피하는 것이 좋겠습니다. 당신의 에너지와 상충할 수 있습니다.

색상 에너지를 최대한 활용하려면:
• 아침에 ${primaryColor}색 아이템을 착용하거나 소지하세요
• 중요한 순간에는 ${primaryColor}색을 시각적으로 떠올리세요
• ${primaryColor}색 음식이나 음료를 섭취하는 것도 도움이 됩니다''';

    final overallScore = 70 + (today.day % 25);

    return Fortune(
      id: 'lucky_color_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      type: widget.fortuneType,
      content: description,
      createdAt: DateTime.now(),
      category: 'lucky-color',
      overallScore: overallScore,
      scoreBreakdown: {
        '전체운': overallScore,
        '색상 에너지': 85 + (today.day % 10),
        '조화도': 75 + (today.day % 15),
        '활용도': 80 + (today.day % 12),
      },
      description: description,
      luckyItems: {
        '주 행운색': primaryColor,
        '보조 행운색': secondaryColor,
        '피해야 할 색': avoidColor,
        '행운의 시간': '${(birthDate.day % 12 + 9)}시',
      },
      recommendations: [
        '${primaryColor}색 ${primaryColorInfo['items'][0]}을(를) 착용해보세요',
        '${primaryColorInfo['situations'][0]}(을)를 할 때 특히 효과적입니다',
        '${secondaryColor}색과 조합하면 시너지 효과가 있습니다',
        '명상이나 시각화를 통해 색상 에너지를 흡수하세요',
      ],
      metadata: {
        'primaryColor': primaryColor,
        'primaryColorInfo': primaryColorInfo,
        'secondaryColor': secondaryColor,
        'secondaryColorInfo': secondaryColorInfo,
        'avoidColor': avoidColor,
        'colorMeanings': _colorMeanings,
        'colorHarmony': _calculateColorHarmony(primaryColor, secondaryColor),
      },
    );
  }

  Map<String, dynamic> _calculateColorHarmony(String color1, String color2) {
    // Simple color harmony calculation
    final harmony = {
      '보색': _getComplementaryColor(color1),
      '유사색': _getAnalogousColors(color1),
      '삼색조화': _getTriadicColors(color1),
    };
    
    return {
      'harmony': harmony,
      'compatibility': _getColorCompatibility(color1, color2),
    };
  }

  String _getComplementaryColor(String color) {
    final complements = {
      '빨강': '초록',
      '파랑': '주황',
      '노랑': '보라',
      '초록': '빨강',
      '보라': '노랑',
      '주황': '파랑',
      '분홍': '초록',
      '검정': '하양',
      '하양': '검정',
    };
    return complements[color] ?? color;
  }

  List<String> _getAnalogousColors(String color) {
    final colorWheel = ['빨강', '주황', '노랑', '초록', '파랑', '보라'];
    final index = colorWheel.indexOf(color);
    if (index == -1) return [color];
    
    final prev = colorWheel[(index - 1 + colorWheel.length) % colorWheel.length];
    final next = colorWheel[(index + 1) % colorWheel.length];
    return [prev, next];
  }

  List<String> _getTriadicColors(String color) {
    final colorWheel = ['빨강', '주황', '노랑', '초록', '파랑', '보라'];
    final index = colorWheel.indexOf(color);
    if (index == -1) return [color];
    
    final color2 = colorWheel[(index + 2) % colorWheel.length];
    final color3 = colorWheel[(index + 4) % colorWheel.length];
    return [color, color2, color3];
  }

  int _getColorCompatibility(String color1, String color2) {
    if (color1 == color2) return 100;
    if (_getComplementaryColor(color1) == color2) return 95;
    if (_getAnalogousColors(color1).contains(color2)) return 85;
    if (_getTriadicColors(color1).contains(color2)) return 80;
    return 60;
  }

  @override
  Widget buildFortuneResult() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildColorPreview(),
          super.buildFortuneResult(),
          _buildColorMeaningCard(),
          _buildColorItemsGrid(),
          _buildColorHarmonyChart(),
          _buildColorTips(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildColorPreview() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final primaryColor = fortune.metadata?['primaryColor'] as String?;
    final primaryColorInfo = fortune.metadata?['primaryColorInfo'] as Map<String, dynamic>?;
    final secondaryColor = fortune.metadata?['secondaryColor'] as String?;
    final secondaryColorInfo = fortune.metadata?['secondaryColorInfo'] as Map<String, dynamic>?;

    if (primaryColor == null || primaryColorInfo == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildColorCircle(
                  primaryColorInfo['color'] as Color,
                  primaryColor,
                  '주 행운색',
                  true,
                ),
                const SizedBox(width: 32),
                if (secondaryColorInfo != null)
                  _buildColorCircle(
                    secondaryColorInfo['color'] as Color,
                    secondaryColor!,
                    '보조 행운색',
                    false,
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (primaryColorInfo['color'] as Color).withOpacity(0.3),
                    (secondaryColorInfo?['color'] as Color? ?? primaryColorInfo['color'] as Color).withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${primaryColorInfo['meaning']} & ${secondaryColorInfo?['meaning'] ?? ''}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorCircle(Color color, String name, String label, bool isPrimary) {
    final size = isPrimary ? 100.0 : 80.0;
    
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
          child: Center(
            child: Text(
              name,
              style: TextStyle(
                color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isPrimary ? 16 : 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildColorMeaningCard() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final primaryColorInfo = fortune.metadata?['primaryColorInfo'] as Map<String, dynamic>?;
    if (primaryColorInfo == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        gradient: LinearGradient(
          colors: [
            (primaryColorInfo['color'] as Color).withOpacity(0.1),
            (primaryColorInfo['color'] as Color).withOpacity(0.05),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette,
                  color: primaryColorInfo['color'] as Color,
                ),
                const SizedBox(width: 8),
                Text(
                  '색상의 의미',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              primaryColorInfo['description'] as String,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (primaryColorInfo['situations'] as List<String>).map((situation) {
                return Chip(
                  label: Text(situation),
                  backgroundColor: (primaryColorInfo['color'] as Color).withOpacity(0.2),
                  side: BorderSide(
                    color: (primaryColorInfo['color'] as Color).withOpacity(0.5),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorItemsGrid() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final primaryColorInfo = fortune.metadata?['primaryColorInfo'] as Map<String, dynamic>?;
    if (primaryColorInfo == null) return const SizedBox.shrink();

    final items = primaryColorInfo['items'] as List<String>;
    final color = primaryColorInfo['color'] as Color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.shopping_bag,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '추천 아이템',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: items.map((item) {
                return GlassContainer(
                  padding: const EdgeInsets.all(16),
                  borderRadius: BorderRadius.circular(16),
                  blur: 10,
                  borderColor: color.withOpacity(0.3),
                  borderWidth: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getItemIcon(item),
                        size: 32,
                        color: color,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getItemIcon(String item) {
    if (item.contains('셔츠') || item.contains('옷')) return Icons.checkroom;
    if (item.contains('가방')) return Icons.shopping_bag;
    if (item.contains('액세서리') || item.contains('목걸이')) return Icons.auto_awesome;
    if (item.contains('시계')) return Icons.watch;
    if (item.contains('꽃')) return Icons.local_florist;
    if (item.contains('펜') || item.contains('노트')) return Icons.edit;
    if (item.contains('립스틱')) return Icons.brush;
    if (item.contains('스카프')) return Icons.dry_cleaning;
    return Icons.star;
  }

  Widget _buildColorHarmonyChart() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final colorHarmony = fortune.metadata?['colorHarmony'] as Map<String, dynamic>?;
    if (colorHarmony == null) return const SizedBox.shrink();

    final harmony = colorHarmony['harmony'] as Map<String, dynamic>;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.color_lens,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '색상 조화',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...harmony.entries.map((entry) {
              final harmonyType = entry.key;
              final harmonyColors = entry.value;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      harmonyType,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (harmonyColors is List)
                      Wrap(
                        spacing: 8,
                        children: harmonyColors.map<Widget>((color) {
                          final colorInfo = _colorMeanings[color];
                          if (colorInfo == null) return const SizedBox.shrink();
                          
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: (colorInfo['color'] as Color).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: (colorInfo['color'] as Color).withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              color,
                              style: TextStyle(
                                color: colorInfo['color'] as Color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    else if (harmonyColors is String)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (_colorMeanings[harmonyColors]?['color'] as Color?)?.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (_colorMeanings[harmonyColors]?['color'] as Color?)?.withOpacity(0.5) ?? Colors.grey,
                          ),
                        ),
                        child: Text(
                          harmonyColors,
                          style: TextStyle(
                            color: _colorMeanings[harmonyColors]?['color'] as Color?,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildColorTips() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '색상 활용 팁',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...[
            '작은 액세서리부터 시작해 색상 에너지를 느껴보세요',
            '중요한 순간 5분 전, 행운색을 시각화하며 명상하세요',
            '행운색 계열의 음식을 섭취하는 것도 효과적입니다',
            '침실이나 작업 공간에 행운색 소품을 배치해보세요',
          ].map((tip) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}