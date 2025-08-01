import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/auth_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/zodiac_compatibility_wheel.dart';
import '../widgets/zodiac_compatibility_matrix.dart';
import '../widgets/zodiac_element_chart.dart';
import '../../../../services/zodiac_compatibility_service.dart';

class ZodiacAnimalFortunePage extends BaseFortunePage {
  const ZodiacAnimalFortunePage({
    Key? key,
    Map<String, dynamic>? initialParams,
  }) : super(
          key: key,
          title: '띠 운세',
          description: '12간지 띠로 알아보는 오늘의 운세',
          fortuneType: 'zodiac-animal',
          requiresUserInfo: true,
          initialParams: initialParams,
        );

  @override
  ConsumerState<ZodiacAnimalFortunePage> createState() => _ZodiacAnimalFortunePageState();
}

class _ZodiacAnimalFortunePageState extends BaseFortunePageState<ZodiacAnimalFortunePage> {
  String? _selectedAnimal;
  DateTime? _birthDate;
  int? _birthYear;
  String? _selectedCompatibilityZodiac1;
  String? _selectedCompatibilityZodiac2;

  final List<Map<String, dynamic>> _zodiacAnimals = [
    {'key': 'rat', 'name': '쥐띠', 'koreanName': '쥐', 'emoji': '🐭', 'years': [1948, 1960, 1972, 1984, 1996, 2008, 2020]},
    {'key': 'ox', 'name': '소띠', 'koreanName': '소', 'emoji': '🐮', 'years': [1949, 1961, 1973, 1985, 1997, 2009, 2021]},
    {'key': 'tiger', 'name': '호랑이띠', 'koreanName': '호랑이', 'emoji': '🐯', 'years': [1950, 1962, 1974, 1986, 1998, 2010, 2022]},
    {'key': 'rabbit', 'name': '토끼띠', 'koreanName': '토끼', 'emoji': '🐰', 'years': [1951, 1963, 1975, 1987, 1999, 2011, 2023]},
    {'key': 'dragon', 'name': '용띠', 'koreanName': '용', 'emoji': '🐲', 'years': [1952, 1964, 1976, 1988, 2000, 2012, 2024]},
    {'key': 'snake', 'name': '뱀띠', 'koreanName': '뱀', 'emoji': '🐍', 'years': [1953, 1965, 1977, 1989, 2001, 2013, 2025]},
    {'key': 'horse', 'name': '말띠', 'koreanName': '말', 'emoji': '🐴', 'years': [1954, 1966, 1978, 1990, 2002, 2014, 2026]},
    {'key': 'sheep', 'name': '양띠', 'koreanName': '양', 'emoji': '🐑', 'years': [1955, 1967, 1979, 1991, 2003, 2015, 2027]},
    {'key': 'monkey', 'name': '원숭이띠', 'koreanName': '원숭이', 'emoji': '🐵', 'years': [1956, 1968, 1980, 1992, 2004, 2016, 2028]},
    {'key': 'rooster', 'name': '닭띠', 'koreanName': '닭', 'emoji': '🐔', 'years': [1957, 1969, 1981, 1993, 2005, 2017, 2029]},
    {'key': 'dog', 'name': '개띠', 'koreanName': '개', 'emoji': '🐶', 'years': [1958, 1970, 1982, 1994, 2006, 2018, 2030]},
    {'key': 'pig', 'name': '돼지띠', 'koreanName': '돼지', 'emoji': '🐷', 'years': [1959, 1971, 1983, 1995, 2007, 2019, 2031]},
  ];

  @override
  void initState() {
    super.initState();
    _detectZodiacFromBirthDate();
  }

  void _detectZodiacFromBirthDate() async {
    final userProfile = await ref.read(userProfileProvider.future);
    if (userProfile != null && userProfile.birthDate != null) {
      setState(() {
        _birthDate = userProfile.birthDate;
        _birthYear = userProfile.birthDate!.year;
        _selectedAnimal = _getZodiacFromYear(userProfile.birthDate!.year);
      });
    }
  }

  String _getZodiacFromYear(int year) {
    // 12년 주기로 반복되는 띠 계산
    final baseYear = 1948; // 쥐띠 기준년도
    final index = (year - baseYear) % 12;
    return _zodiacAnimals[index]['key'];
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    if (_selectedAnimal == null) {
      throw Exception('띠를 선택해주세요');
    }

    // Use the fortune service to generate zodiac animal fortune
    final fortune = await ref.read(fortuneServiceProvider).getZodiacAnimalFortune(
      userId: user.id,
      zodiacAnimal: _selectedAnimal!,
    );

    return fortune;
  }

  String _getCharacteristic(String animal) {
    final characteristics = {
      'rat': '영리하고 재치있는',
      'ox': '성실하고 인내심 강한',
      'tiger': '용감하고 리더십이 있는',
      'rabbit': '온화하고 예술적인',
      'dragon': '카리스마 있고 야망찬',
      'snake': '지혜롭고 신비로운',
      'horse': '자유롭고 열정적인',
      'sheep': '온순하고 창의적인',
      'monkey': '재치있고 호기심 많은',
      'rooster': '정직하고 부지런한',
      'dog': '충성스럽고 신뢰할 수 있는',
      'pig': '관대하고 정직한',
    };
    return characteristics[animal] ?? '특별한';
  }

  String _getLuckyDirection(String animal) {
    final directions = {
      'rat': '북쪽',
      'ox': '북동쪽',
      'tiger': '동쪽',
      'rabbit': '동쪽',
      'dragon': '동남쪽',
      'snake': '남쪽',
      'horse': '남쪽',
      'sheep': '남서쪽',
      'monkey': '서쪽',
      'rooster': '서쪽',
      'dog': '북서쪽',
      'pig': '북쪽',
    };
    return directions[animal] ?? '중앙';
  }

  String _getLuckyColor(String animal) {
    final colors = {
      'rat': '파란색',
      'ox': '노란색',
      'tiger': '주황색',
      'rabbit': '분홍색',
      'dragon': '금색',
      'snake': '빨간색',
      'horse': '초록색',
      'sheep': '보라색',
      'monkey': '흰색',
      'rooster': '갈색',
      'dog': '검은색',
      'pig': '회색',
    };
    return colors[animal] ?? '무지개색';
  }

  Map<String, dynamic> _getCompatibility(String animal) {
    final compatibility = {
      'rat': {'best': ['dragon', 'monkey', 'ox'], 'worst': ['horse', 'rooster']},
      'ox': {'best': ['rat', 'snake', 'rooster'], 'worst': ['sheep', 'horse']},
      'tiger': {'best': ['horse', 'dog', 'pig'], 'worst': ['monkey', 'snake']},
      'rabbit': {'best': ['sheep', 'pig', 'dog'], 'worst': ['rooster', 'dragon']},
      'dragon': {'best': ['rat', 'monkey', 'rooster'], 'worst': ['dog', 'rabbit']},
      'snake': {'best': ['ox', 'rooster', 'monkey'], 'worst': ['pig', 'tiger']},
      'horse': {'best': ['tiger', 'sheep', 'dog'], 'worst': ['rat', 'ox']},
      'sheep': {'best': ['rabbit', 'horse', 'pig'], 'worst': ['ox', 'dog']},
      'monkey': {'best': ['rat', 'dragon', 'snake'], 'worst': ['tiger', 'pig']},
      'rooster': {'best': ['ox', 'snake', 'dragon'], 'worst': ['rabbit', 'dog']},
      'dog': {'best': ['tiger', 'rabbit', 'horse'], 'worst': ['dragon', 'sheep']},
      'pig': {'best': ['rabbit', 'sheep', 'tiger'], 'worst': ['snake', 'monkey']},
    };

    final animalCompat = compatibility[animal] ?? {'best': [], 'worst': []};
    return {
      'best': animalCompat['best']!.map((key) => 
        _zodiacAnimals.firstWhere((a) => a['key'] == key)
      ).toList(),
      'worst': animalCompat['worst']!.map((key) => 
        _zodiacAnimals.firstWhere((a) => a['key'] == key)
      ).toList(),
    };
  }

  List<double> _getMonthlyTrend() {
    // Generate a trend for the current month
    return List.generate(30, (index) => 55 + (index * 3.5 % 35));
  }

  Map<String, String> _getDetailedCharacteristics(String animal) {
    final details = {
      'rat': {
        '성격': '영리하고 재치있으며 적응력이 뛰어남',
        '장점': '기회를 잘 포착하고 경제관념이 뛰어남',
        '단점': '때로는 너무 계산적이고 신경질적임',
        '직업': '사업가, 기획자, 금융 전문가',
      },
      'ox': {
        '성격': '성실하고 인내심이 강하며 신뢰할 수 있음',
        '장점': '책임감이 강하고 끈기가 있음',
        '단점': '고집이 세고 변화를 싫어함',
        '직업': '건축가, 의사, 농부, 은행가',
      },
      'tiger': {
        '성격': '용감하고 독립적이며 리더십이 강함',
        '장점': '정의감이 강하고 모험을 즐김',
        '단점': '충동적이고 인내심이 부족함',
        '직업': '군인, 경찰, 탐험가, CEO',
      },
      'rabbit': {
        '성격': '온화하고 예민하며 예술적 감각이 뛰어남',
        '장점': '외교적이고 평화를 사랑함',
        '단점': '우유부단하고 현실도피 경향',
        '직업': '예술가, 외교관, 교사, 디자이너',
      },
      'dragon': {
        '성격': '카리스마 있고 야망이 크며 열정적임',
        '장점': '리더십이 뛰어나고 창의적임',
        '단점': '자만심이 강하고 비판을 싫어함',
        '직업': '정치가, 예술가, 발명가, 기업가',
      },
      'snake': {
        '성격': '지혜롭고 직관력이 뛰어나며 신비로움',
        '장점': '분석력이 뛰어나고 결단력이 있음',
        '단점': '의심이 많고 질투심이 강함',
        '직업': '연구원, 심리학자, 점성술사, 탐정',
      },
      'horse': {
        '성격': '자유분방하고 활동적이며 사교적임',
        '장점': '열정적이고 독립심이 강함',
        '단점': '인내심이 부족하고 변덕스러움',
        '직업': '여행가, 기자, 운동선수, 연예인',
      },
      'sheep': {
        '성격': '온순하고 예술적이며 평화를 사랑함',
        '장점': '창의적이고 동정심이 많음',
        '단점': '우유부단하고 비관적임',
        '직업': '예술가, 작가, 요리사, 정원사',
      },
      'monkey': {
        '성격': '재치있고 호기심이 많으며 다재다능함',
        '장점': '문제해결 능력이 뛰어나고 유머러스함',
        '단점': '교활하고 허영심이 있음',
        '직업': '엔지니어, 과학자, 코미디언, 사업가',
      },
      'rooster': {
        '성격': '정직하고 부지런하며 시간관념이 철저함',
        '장점': '관찰력이 뛰어나고 완벽주의적임',
        '단점': '비판적이고 자기중심적임',
        '직업': '군인, 경찰, 언론인, 요리사',
      },
      'dog': {
        '성격': '충성스럽고 정직하며 책임감이 강함',
        '장점': '신뢰할 수 있고 정의감이 강함',
        '단점': '비관적이고 걱정이 많음',
        '직업': '경찰, 변호사, 사회복지사, 의사',
      },
      'pig': {
        '성격': '관대하고 정직하며 낙천적임',
        '장점': '인내심이 강하고 신뢰할 수 있음',
        '단점': '순진하고 게으른 편임',
        '직업': '교사, 요리사, 의사, 공무원',
      },
    };
    return details[animal] ?? {
      '성격': '특별하고 독특한 성격',
      '장점': '많은 장점을 가지고 있음',
      '단점': '약간의 단점도 있음',
      '직업': '다양한 분야에서 성공 가능',
    };
  }

  List<int> _getLuckyYears(String animal) {
    final currentYear = DateTime.now().year;
    final animalData = _zodiacAnimals.firstWhere((a) => a['key'] == animal);
    final years = animalData['years'] as List<int>;
    
    // 현재 연도 기준으로 가까운 년도들 선택
    return years.where((year) => year >= currentYear - 12 && year <= currentYear + 12).toList();
  }

  @override
  Widget buildInputForm() {
    return Column(
      children: [
        if (_birthYear != null)
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cake,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '출생년도: $_birthYear년',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        _buildAnimalSelector(),
      ],
    );
  }

  @override
  Widget buildFortuneResult() {
    return Column(
      children: [
        super.buildFortuneResult(),
        _buildAnimalProfile(),
        _buildCharacteristics(),
        _buildEnhancedCompatibilitySection(),
        _buildMonthlyTrendChart(),
        _buildLuckyYears(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildAnimalSelector() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '띠 선택',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _zodiacAnimals.length,
            itemBuilder: (context, index) {
              final animal = _zodiacAnimals[index];
              final isSelected = _selectedAnimal == animal['key'];
              final isMyZodiac = _birthYear != null && 
                (animal['years'] as List<int>).contains(_birthYear);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAnimal = animal['key'];
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                            ],
                          )
                        : null,
                    color: !isSelected
                        ? Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3)
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : isMyZodiac
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                      width: isSelected || isMyZodiac ? 2 : 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              animal['emoji'],
                              style: const TextStyle(fontSize: 36),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              animal['name'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.white : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isMyZodiac)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '* 별표는 당신의 띠입니다',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalProfile() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final animalInfo = fortune.metadata?['animalInfo'] as Map<String, dynamic>?;
    if (animalInfo == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  animalInfo['emoji'],
                  style: const TextStyle(fontSize: 64),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      animalInfo['name'],
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_getCharacteristic(animalInfo['key'])} 성격',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacteristics() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final characteristics = fortune.metadata?['characteristics'] as Map<String, String>?;
    if (characteristics == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '성격 분석',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...characteristics.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        entry.value,
                        style: Theme.of(context).textTheme.bodyMedium,
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

  Widget _buildEnhancedCompatibilitySection() {
    if (_selectedAnimal == null) return const SizedBox.shrink();
    
    final selectedKoreanName = _zodiacAnimals
        .firstWhere((a) => a['key'] == _selectedAnimal)['koreanName'];
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ZodiacCompatibilityWheel(
            selectedZodiac: selectedKoreanName,
            onZodiacSelected: (zodiac) {
              setState(() {
                _selectedCompatibilityZodiac1 = selectedKoreanName;
                _selectedCompatibilityZodiac2 = zodiac;
              });
            },
            showAnimation: true,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ZodiacCompatibilityMatrix(
            selectedZodiac1: _selectedCompatibilityZodiac1,
            selectedZodiac2: _selectedCompatibilityZodiac2,
            onPairSelected: (zodiac1, zodiac2) {
              setState(() {
                _selectedCompatibilityZodiac1 = zodiac1;
                _selectedCompatibilityZodiac2 = zodiac2;
              });
            },
            showAnimation: true,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ZodiacElementChart(
            selectedZodiac: selectedKoreanName,
            showAnimation: true,
          ),
        ),
      ],
    );
  }

  Widget _buildCompatibilityRow(String label, List animals, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: animals.map((animal) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    animal['emoji'],
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    animal['name'],
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMonthlyTrendChart() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final monthlyTrend = fortune.metadata?['monthlyTrend'] as List<double>?;
    if (monthlyTrend == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '이번 달 운세 흐름',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 20,
                    verticalInterval: 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() % 5 == 0) {
                            return Text(
                              '${value.toInt() + 1}일',
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                  ),
                  minX: 0,
                  maxX: monthlyTrend.length - 1,
                  minY: 40,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: monthlyTrend.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value);
                      }).toList(),
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: false,
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLuckyYears() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final luckyYears = fortune.metadata?['luckyYears'] as List<int>?;
    if (luckyYears == null || luckyYears.isEmpty) return const SizedBox.shrink();

    final currentYear = DateTime.now().year;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.celebration,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  '당신의 띠 년도',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: luckyYears.map((year) {
                final isCurrentYear = year == currentYear;
                final isPastYear = year < currentYear;
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isCurrentYear
                        ? LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.secondary,
                              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.7),
                            ],
                          )
                        : null,
                    color: !isCurrentYear
                        ? isPastYear
                            ? Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3)
                            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                        : null,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isCurrentYear
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                      width: isCurrentYear ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    '$year년',
                    style: TextStyle(
                      color: isCurrentYear
                          ? Colors.white
                          : isPastYear
                              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)
                              : null,
                      fontWeight: isCurrentYear ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              '* 12년마다 돌아오는 당신의 띠 년도입니다',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}