import 'package:flutter/material.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../core/theme/toss_design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/providers.dart';

class BirthdateFortunePage extends ConsumerStatefulWidget {
  const BirthdateFortunePage({super.key});

  @override
  ConsumerState<BirthdateFortunePage> createState() => _BirthdateFortunePageState();
}

class _BirthdateFortunePageState extends ConsumerState<BirthdateFortunePage> {
  DateTime? _selectedDate;
  bool _isLunar = false;
  
  // 생일 수 계산 (1-9로 축약)
  int calculateLifePathNumber(DateTime date) {
    int sum = date.year + date.month + date.day;
    
    // 단일 숫자가 될 때까지 반복
    while (sum > 9 && sum != 11 && sum != 22 && sum != 33) {
      sum = sum.toString().split('').map(int.parse).reduce((a, b) => a + b);
    }
    
    return sum;
  }
  
  // 생일 요일의 의미
  final Map<int, Map<String, dynamic>> weekdayMeanings = {
    1: {
      'day': '월요일', 'planet': '달', 'element': '물', 'characteristics': ['감성적', '직관적', '배려심', '창의적'],
      'color': TossDesignSystem.tossBlue,
      'gemstone': '진주',
    },
    2: {
      'day': '화요일', 'planet': '화성', 'element': '불', 'characteristics': ['열정적', '도전적', '리더십', '용기'],
      'color': TossDesignSystem.error,
      'gemstone': '루비',
    },
    3: {
      'day': '수요일', 'planet': '수성', 'element': '공기', 'characteristics': ['지적', '소통', '적응력', '다재다능'],
      'color': TossDesignSystem.success,
      'gemstone': '에메랄드',
    },
    4: {
      'day': '목요일', 'planet': '목성', 'element': '나무', 'characteristics': ['관대함', '낙천적', '성장', '지혜'],
      'color': TossDesignSystem.purple,
      'gemstone': '자수정',
    },
    5: {
      'day': '금요일', 'planet': '금성', 'element': '금속', 'characteristics': ['예술적', '조화', '사랑', '아름다움'],
      'color': TossDesignSystem.pinkPrimary,
      'gemstone': '다이아몬드',
    },
    6: {
      'day': '토요일', 'planet': '토성', 'element': '흙', 'characteristics': ['책임감', '인내심', '실용적', '안정'],
      'color': TossDesignSystem.brownPrimary,
      'gemstone': '흑요석',
    },
    7: {
      'day': '일요일', 'planet': '태양', 'element': '빛', 'characteristics': ['활력', '자신감', '창조성', '카리스마'],
      'color': TossDesignSystem.warningOrange,
      'gemstone': '토파즈',
    },
  };
  
  // 생일 수의 의미
  final Map<int, Map<String, String>> lifePathMeanings = {
    1: {
      'title': '개척자', 'description': '독립적이고 창의적인 리더십을 가진 사람', 'strength': '독창성, 결단력, 추진력', 'weakness': '고집, 이기심, 성급함', 'advice': '타인의 의견을 경청하고 협력하는 자세를 기르세요',
    },
    2: {
      'title': '조화로운 협력자', 'description': '평화를 사랑하고 타인과의 조화를 중시하는 사람', 'strength': '협동심, 외교력, 섬세함', 'weakness': '우유부단, 의존성, 소극성', 'advice': '자신감을 가지고 주도적으로 행동하세요',
    },
    3: {
      'title': '창의적 표현가', 'description': '예술적 감각과 표현력이 뛰어난 사람', 'strength': '창의성, 소통능력, 낙천성', 'weakness': '산만함, 과장, 변덕', 'advice': '집중력을 기르고 끈기 있게 노력하세요',
    },
    4: {
      'title': '실용적 건설자', 'description': '체계적이고 실용적인 접근을 하는 사람', 'strength': '성실성, 신뢰성, 조직력', 'weakness': '융통성 부족, 완고함, 비관주의', 'advice': '변화를 받아들이고 유연한 사고를 가지세요',
    },
    5: {
      'title': '자유로운 모험가', 'description': '변화와 자유를 추구하는 역동적인 사람', 'strength': '적응력, 호기심, 다재다능', 'weakness': '무책임, 충동성, 불안정', 'advice': '책임감을 가지고 한 가지에 집중하세요',
    },
    6: {
      'title': '헌신적 봉사자', 'description': '가족과 공동체를 위해 헌신하는 사람', 'strength': '책임감, 사랑, 봉사정신', 'weakness': '간섭, 걱정, 자기희생', 'advice': '자신을 먼저 돌보고 균형을 찾으세요',
    },
    7: {
      'title': '영적 탐구자', 'description': '내면의 지혜와 영적 성장을 추구하는 사람', 'strength': '직관력, 분석력, 영성', 'weakness': '고립, 비판적, 은둔', 'advice': '타인과 소통하고 현실과 균형을 맞추세요',
    },
    8: {
      'title': '물질적 성취자', 'description': '목표 달성과 물질적 성공을 추구하는 사람', 'strength': '야망, 조직력, 판단력', 'weakness': '물질주의, 권위주의, 냉정함', 'advice': '영적 가치를 인정하고 나눔을 실천하세요',
    },
    9: {
      'title': '인류애적 봉사자', 'description': '인류 전체를 위한 큰 뜻을 품은 사람', 'strength': '이타심, 지혜, 이해심', 'weakness': '이상주의, 감정기복, 분산', 'advice': '현실적 목표를 세우고 자기관리에 힘쓰세요',
    },
    11: {
      'title': '영감의 메신저', 'description': '높은 직관력과 영감을 가진 특별한 사람', 'strength': '영감, 이상주의, 카리스마', 'weakness': '신경과민, 자기의심, 긴장', 'advice': '내면의 평화를 찾고 실천에 옮기세요',
    },
    22: {
      'title': '마스터 빌더', 'description': '큰 비전을 현실로 만드는 능력을 가진 사람', 'strength': '비전, 실행력, 리더십', 'weakness': '압박감, 완벽주의, 고립', 'advice': '작은 성취도 인정하고 과정을 즐기세요',
    },
    33: {
      'title': '마스터 티처', 'description': '사랑과 봉사로 세상을 가르치는 사람', 'strength': '무조건적 사랑, 치유력, 영적 지도력', 'weakness': '자기희생, 부담감, 이상과 현실의 괴리', 'advice': '자신의 한계를 인정하고 휴식을 취하세요',
    },
  };

  @override
  void initState() {
    super.initState();
    _loadProfileBirthDate();
  }

  void _loadProfileBirthDate() {
    final profileAsync = ref.read(userProfileProvider);
    final profile = profileAsync.value;
    if (profile?.birthDate != null) {
      setState(() {
        _selectedDate = profile!.birthDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BaseFortunePageV2(
      title: '생일 운세',
      fortuneType: 'birthdate',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFEC4899), Color(0xFFDB2777)]
      ),
      inputBuilder: (context, onSubmit) => _buildInputSection(onSubmit),
      resultBuilder: (context, result, onShare) => _buildResult(context, result)
    );
  }

  Widget _buildInputSection(Function(Map<String, dynamic>) onSubmit) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '생년월일 선택',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Date display
          Center(
            child: Column(
              children: [
                if (_selectedDate != null) ...[
                  Icon(
                    Icons.cake,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    weekdayMeanings[_selectedDate!.weekday]!['day'],
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray600,
                    ),
                  ),
                ] else ...[
                  Icon(
                    Icons.calendar_today,
                    size: 48,
                    color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray500,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '생년월일을 선택해주세요',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          // Date picker button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  locale: const Locale('ko', 'KR')
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
              icon: const Icon(Icons.calendar_month),
              label: Text(_selectedDate == null ? '날짜 선택' : '날짜 변경'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16)
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          // Lunar calendar checkbox
          Row(
            children: [
              Checkbox(
                value: _isLunar,
                onChanged: (value) {
                  setState(() {
                    _isLunar = value ?? false;
                  });
                },
              ),
              const Text('음력 생일입니다')
            ],
          ),
          
          // Preview info
          if (_selectedDate != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '생일 정보',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('인생수', calculateLifePathNumber(_selectedDate!).toString()),
                  _buildInfoRow('요일', weekdayMeanings[_selectedDate!.weekday]!['day']),
                  _buildInfoRow('지배 행성', weekdayMeanings[_selectedDate!.weekday]!['planet']),
                  _buildInfoRow('원소', weekdayMeanings[_selectedDate!.weekday]!['element']),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          // Submit button
          TossButton(
            text: '생일 운세 확인하기',
            onPressed: _selectedDate != null 
              ? () => onSubmit({
                  'birthdate': _selectedDate!.toIso8601String(),
                  'isLunar': _isLunar,
                })
              : null,
            style: TossButtonStyle.primary,
            size: TossButtonSize.large,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray600)
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500)
          )
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context, FortuneResult result) {
    final data = result.details ?? {};
    
    // Extract birthdate info from result
    DateTime? birthDate;
    if (data['birthdate'] != null) {
      birthDate = DateTime.parse(data['birthdate']);
    } else if (_selectedDate != null) {
      birthDate = _selectedDate;
    }
    
    if (birthDate == null) {
      return const Center(child: Text('생일 정보를 불러올 수 없습니다.'));
    }
    
    final lifePathNumber = calculateLifePathNumber(birthDate);
    final weekdayInfo = weekdayMeanings[birthDate.weekday]!;
    final lifePathInfo = lifePathMeanings[lifePathNumber]!;
    
    return Column(
      children: [
        // Life path number card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1)
              ]
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle
                ),
                child: Center(
                  child: Text(
                    lifePathNumber.toString(),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                lifePathInfo['title']!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lifePathInfo['description']!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray600
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        // Weekday info
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: weekdayInfo['color'],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${weekdayInfo['day']} 출생',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (weekdayInfo['characteristics'] as List<String>)
                    .map((trait) => Chip(
                          label: Text(trait),
                          backgroundColor: (weekdayInfo['color'] as Color).withValues(alpha: 0.3),
                        )).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoChip(context, '행성', weekdayInfo['planet']),
                  _buildInfoChip(context, '원소', weekdayInfo['element']),
                  _buildInfoChip(context, '보석', weekdayInfo['gemstone']),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        // Strengths and weaknesses
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '성격 분석',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildAnalysisRow('강점', lifePathInfo['strength']!, TossDesignSystem.success),
              const SizedBox(height: 12),
              _buildAnalysisRow('약점', lifePathInfo['weakness']!, TossDesignSystem.warningOrange),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: TossDesignSystem.tossBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        lifePathInfo['advice']!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Additional content from API
        if (result.mainFortune != null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '오늘의 운세',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  result.mainFortune!,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray600
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisRow(String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14)
          ),
        ),
      ],
    );
  }
}