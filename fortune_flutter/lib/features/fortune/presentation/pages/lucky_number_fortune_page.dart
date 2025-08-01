import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/auth_provider.dart';

class LuckyNumberFortunePage extends BaseFortunePage {
  const LuckyNumberFortunePage({Key? key})
      : super(
          key: key,
          title: '오늘의 행운의 숫자',
          description: '오늘 당신에게 행운을 가져다줄 숫자를 확인해보세요',
          fortuneType: 'lucky-number',
          requiresUserInfo: true,
        );

  @override
  ConsumerState<LuckyNumberFortunePage> createState() => _LuckyNumberFortunePageState();
}

class _LuckyNumberFortunePageState extends BaseFortunePageState<LuckyNumberFortunePage> {
  late AnimationController _numberAnimationController;
  late Animation<double> _numberAnimation;
  
  final Map<int, Map<String, dynamic>> _numberMeanings = {
    1: {
      'meaning': '시작과 리더십',
      'description': '새로운 시작을 의미하며, 독립적이고 리더십을 발휘하기 좋은 날입니다.',
      'situations': ['새 프로젝트 시작', '중요한 결정', '리더십 발휘'],
      'color': Colors.red,
    },
    2: {
      'meaning': '협력과 균형',
      'description': '파트너십과 협력이 중요한 날입니다. 타인과의 조화를 추구하세요.',
      'situations': ['팀 프로젝트', '협상', '관계 개선'],
      'color': Colors.orange,
    },
    3: {
      'meaning': '창의성과 소통',
      'description': '창의적인 에너지가 넘치는 날입니다. 자유롭게 표현하고 소통하세요.',
      'situations': ['예술 활동', '프레젠테이션', '사교 모임'],
      'color': Colors.yellow,
    },
    4: {
      'meaning': '안정과 실용성',
      'description': '실용적이고 체계적인 접근이 필요한 날입니다. 계획을 세우고 실행하세요.',
      'situations': ['계획 수립', '정리 정돈', '실무 처리'],
      'color': Colors.green,
    },
    5: {
      'meaning': '자유와 모험',
      'description': '변화와 모험을 추구하기 좋은 날입니다. 새로운 경험에 도전하세요.',
      'situations': ['여행', '새로운 시도', '네트워킹'],
      'color': Colors.blue,
    },
    6: {
      'meaning': '책임과 봉사',
      'description': '가족과 공동체를 위한 봉사와 책임감이 강조되는 날입니다.',
      'situations': ['가족 모임', '봉사 활동', '책임감 있는 결정'],
      'color': Colors.indigo,
    },
    7: {
      'meaning': '내면과 영성',
      'description': '내면의 목소리에 귀 기울이고 영적 성장을 추구하기 좋은 날입니다.',
      'situations': ['명상', '학습', '자기 성찰'],
      'color': Colors.purple,
    },
    8: {
      'meaning': '물질과 성공',
      'description': '물질적 성공과 성취를 이루기 좋은 날입니다. 목표를 향해 전진하세요.',
      'situations': ['사업 결정', '투자', '목표 달성'],
      'color': Colors.pink,
    },
    9: {
      'meaning': '완성과 봉사',
      'description': '한 사이클의 완성과 타인을 위한 봉사가 강조되는 날입니다.',
      'situations': ['프로젝트 마무리', '자선 활동', '지혜 나눔'],
      'color': Colors.amber,
    },
  };

  @override
  void initState() {
    super.initState();
    _numberAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _numberAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _numberAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _numberAnimationController.dispose();
    super.dispose();
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    // Get user profile for birth date
    final userProfile = await ref.read(userProfileProvider.future);
    
    // Calculate lucky numbers based on user's birth date and current date
    final birthDate = userProfile?.birthDate ?? DateTime.now();
    final today = DateTime.now();
    
    // Calculate main lucky number (1-9)
    final mainNumber = _calculateMainNumber(birthDate, today);
    
    // Calculate lottery numbers (1-45)
    final lotteryNumbers = _generateLotteryNumbers(birthDate, today);
    
    // Calculate time-based lucky numbers
    final timeNumbers = _calculateTimeNumbers(birthDate, today);
    
    // Get number meaning
    final numberInfo = _numberMeanings[mainNumber]!;
    
    // Start animation
    _numberAnimationController.forward();

    final description = '''오늘의 메인 행운 숫자는 ${mainNumber}입니다.

${numberInfo['description']}

🎰 로또 행운 번호: ${lotteryNumbers.join(', ')}
⏰ 시간대별 행운 숫자: 
• 오전: ${timeNumbers['morning']}
• 오후: ${timeNumbers['afternoon']}  
• 저녁: ${timeNumbers['evening']}

오늘 ${mainNumber}이라는 숫자를 활용하여:
• 중요한 결정은 ${mainNumber}시 또는 ${mainNumber + 12}시에 하세요
• ${mainNumber}번째 선택지를 고려해보세요
• ${mainNumber}개씩 묶어서 처리하면 효율적입니다

수비학적으로 ${mainNumber}은 ${numberInfo['meaning']}을 상징합니다.
이 에너지를 활용하여 오늘 하루를 성공적으로 만들어보세요.''';

    final overallScore = 70 + (mainNumber * 3) + (today.day % 15);

    return Fortune(
      id: 'lucky_number_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      type: widget.fortuneType,
      content: description,
      createdAt: DateTime.now(),
      category: 'lucky-number',
      overallScore: overallScore,
      scoreBreakdown: {
        '전체운': overallScore,
        '숫자 에너지': 75 + (mainNumber * 2),
        '타이밍': 80 + (today.hour % 10),
        '활용도': 85 + (today.day % 8),
      },
      description: description,
      luckyItems: {
        '메인 숫자': mainNumber.toString(),
        '로또 번호': lotteryNumbers.join(', '),
        '오전 숫자': timeNumbers['morning'].toString(),
        '오후 숫자': timeNumbers['afternoon'].toString(),
        '저녁 숫자': timeNumbers['evening'].toString(),
      },
      recommendations: [
        '${mainNumber}과 관련된 시간이나 날짜를 활용하세요',
        '${numberInfo['situations'][0]}을(를) 할 때 이 숫자를 떠올리세요',
        '중요한 선택에서 ${mainNumber}번째 옵션을 고려해보세요',
        '오늘 하루 ${mainNumber}가지 목표를 세워보세요',
      ],
      metadata: {
        'mainNumber': mainNumber,
        'numberInfo': numberInfo,
        'lotteryNumbers': lotteryNumbers,
        'timeNumbers': timeNumbers,
        'numerologyAnalysis': _getNumerologyAnalysis(birthDate),
      },
    );
  }

  int _calculateMainNumber(DateTime birthDate, DateTime today) {
    // Simple numerology calculation
    int sum = birthDate.day + birthDate.month + birthDate.year +
              today.day + today.month + today.year;
    
    // Reduce to single digit
    while (sum > 9) {
      sum = sum.toString().split('').map(int.parse).reduce((a, b) => a + b);
    }
    
    return sum == 0 ? 9 : sum;
  }

  List<int> _generateLotteryNumbers(DateTime birthDate, DateTime today) {
    final random = math.Random(birthDate.millisecondsSinceEpoch + today.millisecondsSinceEpoch);
    final numbers = <int>{};
    
    // Add birth-based number
    numbers.add((birthDate.day + birthDate.month) % 45 + 1);
    
    // Add today-based number
    numbers.add((today.day + today.month) % 45 + 1);
    
    // Generate random numbers
    while (numbers.length < 6) {
      numbers.add(random.nextInt(45) + 1);
    }
    
    return numbers.toList()..sort();
  }

  Map<String, int> _calculateTimeNumbers(DateTime birthDate, DateTime today) {
    return {
      'morning': ((birthDate.day + today.day) % 9) + 1,
      'afternoon': ((birthDate.month + today.month) % 9) + 1,
      'evening': ((birthDate.year + today.year) % 9) + 1,
    };
  }

  Map<String, dynamic> _getNumerologyAnalysis(DateTime birthDate) {
    // Life path number
    int lifePathNumber = _calculateLifePathNumber(birthDate);
    
    // Destiny number (simplified - normally uses full name)
    int destinyNumber = (birthDate.day + birthDate.month) % 9 + 1;
    
    // Soul number
    int soulNumber = birthDate.day % 9 + 1;
    
    return {
      'lifePathNumber': lifePathNumber,
      'destinyNumber': destinyNumber,
      'soulNumber': soulNumber,
      'analysis': '당신의 생명수 $lifePathNumber는 인생의 방향을, 운명수 $destinyNumber는 목표를, 영혼수 $soulNumber는 내면의 욕구를 나타냅니다.',
    };
  }

  int _calculateLifePathNumber(DateTime date) {
    int sum = date.day + date.month + date.year;
    while (sum > 9 && sum != 11 && sum != 22 && sum != 33) {
      sum = sum.toString().split('').map(int.parse).reduce((a, b) => a + b);
    }
    return sum;
  }

  @override
  Widget buildFortuneResult() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMainNumberDisplay(),
          const SizedBox(height: 16),
          super.buildFortuneResult(),
          _buildLotteryNumbers(),
          _buildTimeNumbers(),
          _buildNumerologyAnalysis(),
          _buildNumberMeaningCard(),
          _buildNumberUsageTips(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMainNumberDisplay() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final mainNumber = fortune.metadata?['mainNumber'] as int?;
    final numberInfo = fortune.metadata?['numberInfo'] as Map<String, dynamic>?;
    
    if (mainNumber == null || numberInfo == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _numberAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_numberAnimation.value * 0.2),
          child: Opacity(
            opacity: _numberAnimation.value,
            child: GlassCard(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Text(
                    '오늘의 메인 행운 숫자',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          (numberInfo['color'] as Color).withValues(alpha: 0.3),
                          (numberInfo['color'] as Color).withValues(alpha: 0.1),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (numberInfo['color'] as Color).withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        mainNumber.toString(),
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: numberInfo['color'] as Color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    numberInfo['meaning'] as String,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLotteryNumbers() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final lotteryNumbers = fortune.metadata?['lotteryNumbers'] as List<int>?;
    if (lotteryNumbers == null) return const SizedBox.shrink();

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
                  Icons.casino,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '로또 행운 번호',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: lotteryNumbers.map((number) {
                return _buildLotteryBall(number);
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              '※ 이 번호들은 오늘의 운세를 기반으로 생성된 것이며, 실제 당첨을 보장하지 않습니다.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLotteryBall(int number) {
    Color ballColor;
    if (number <= 10) {
      ballColor = Colors.yellow.shade700;
    } else if (number <= 20) {
      ballColor = Colors.blue.shade700;
    } else if (number <= 30) {
      ballColor = Colors.red.shade700;
    } else if (number <= 40) {
      ballColor = Colors.grey.shade700;
    } else {
      ballColor = Colors.green.shade700;
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ballColor,
        boxShadow: [
          BoxShadow(
            color: ballColor.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeNumbers() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final timeNumbers = fortune.metadata?['timeNumbers'] as Map<String, int>?;
    if (timeNumbers == null) return const SizedBox.shrink();

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
                  Icons.access_time,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '시간대별 행운 숫자',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeNumberCard('오전', timeNumbers['morning']!, Icons.wb_sunny),
                _buildTimeNumberCard('오후', timeNumbers['afternoon']!, Icons.wb_cloudy),
                _buildTimeNumberCard('저녁', timeNumbers['evening']!, Icons.nightlight_round),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeNumberCard(String time, int number, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              time,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              number.toString(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumerologyAnalysis() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final analysis = fortune.metadata?['numerologyAnalysis'] as Map<String, dynamic>?;
    if (analysis == null) return const SizedBox.shrink();

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
                  Icons.analytics,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '수비학 분석',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildNumerologyItem('생명수', analysis['lifePathNumber'], '인생의 방향'),
            _buildNumerologyItem('운명수', analysis['destinyNumber'], '목표와 사명'),
            _buildNumerologyItem('영혼수', analysis['soulNumber'], '내면의 욕구'),
            const SizedBox(height: 12),
            Text(
              analysis['analysis'] as String,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumerologyItem(String label, int number, String meaning) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  meaning,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberMeaningCard() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final numberInfo = fortune.metadata?['numberInfo'] as Map<String, dynamic>?;
    if (numberInfo == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        gradient: LinearGradient(
          colors: [
            (numberInfo['color'] as Color).withValues(alpha: 0.1),
            (numberInfo['color'] as Color).withValues(alpha: 0.05),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: numberInfo['color'] as Color,
                ),
                const SizedBox(width: 8),
                Text(
                  '숫자의 의미',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              numberInfo['description'] as String,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (numberInfo['situations'] as List<String>).map((situation) {
                return Chip(
                  label: Text(situation),
                  backgroundColor: (numberInfo['color'] as Color).withValues(alpha: 0.2),
                  side: BorderSide(
                    color: (numberInfo['color'] as Color).withValues(alpha: 0.5),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberUsageTips() {
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
                '숫자 활용 팁',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...[
            '중요한 약속은 행운 숫자와 관련된 시간에 잡아보세요',
            '전화번호나 비밀번호에 행운 숫자를 포함시켜보세요',
            '쇼핑이나 투자 시 행운 숫자 단위로 결정해보세요',
            '운동이나 목표 설정 시 행운 숫자를 활용하세요',
            '명상 시 행운 숫자를 반복해서 떠올려보세요',
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