import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../../shared/components/app_header.dart' show FontSize;

class WishFortunePage extends ConsumerWidget {
  const WishFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '소원 운세',
      fortuneType: 'wish',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
      ),
      inputBuilder: (context, onSubmit) => _WishInputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, onShare) => _WishFortuneResult(
        result: result,
        onShare: onShare,
      ),
    );
  }
}

class _WishInputForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _WishInputForm({required this.onSubmit});

  @override
  State<_WishInputForm> createState() => _WishInputFormState();
}

class _WishInputFormState extends State<_WishInputForm> {
  final _nameController = TextEditingController();
  final _wishController = TextEditingController();
  DateTime? _birthDate;
  String? _gender;
  String? _wishCategory;
  String? _wishImportance;
  String? _currentEffort;
  final List<String> _selectedObstacles = [];
  
  final List<String> _wishCategories = [
    '사랑',
    '건강',
    '돈/재물',
    '직업/커리어',
    '가족',
    '학업/시험',
    '인간관계',
    '자기계발',
    '여행/경험',
    '소유물',
    '명예/인정',
    '기타',
  ];
  
  final List<String> _importanceLevels = [
    '인생 최고의 소원',
    '매우 중요',
    '중요',
    '있으면 좋음',
    '가벼운 바람',
  ];
  
  final List<String> _effortLevels = [
    '전력을 다하고 있음',
    '열심히 노력 중',
    '가끔 노력함',
    '막 시작함',
    '아직 시작 안 함',
  ];
  
  final List<String> _obstacles = [
    '경제적 어려움',
    '시간 부족',
    '자신감 부족',
    '주변 반대',
    '기회 부족',
    '능력/실력 부족',
    '건강 문제',
    '정보 부족',
    '두려움',
    '확신 부족',
    '경쟁자',
    '환경적 제약',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _wishController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFFF59E0B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '간절한 소원의 성취 가능성을 예측하고\n이루기 위한 구체적인 방법을 알려드립니다.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          
          // Name Input
          Text(
            '이름',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: '이름을 입력하세요',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Gender Selection
          Text(
            '성별',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('남성'),
                  value: '남성',
                  groupValue: _gender,
                  onChanged: (value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                  activeColor: theme.colorScheme.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('여성'),
                  value: '여성',
                  groupValue: _gender,
                  onChanged: (value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                  activeColor: theme.colorScheme.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Birth Date Selection
          Text(
            '생년월일',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: theme.colorScheme.primary.withOpacity(0.7)),
                  const SizedBox(width: 12),
                  Text(
                    _birthDate != null
                        ? '${_birthDate!.year}년 ${_birthDate!.month}월 ${_birthDate!.day}일'
                        : '생년월일을 선택하세요',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _birthDate != null 
                          ? theme.colorScheme.onSurface 
                          : theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Wish Input
          Text(
            '소원 내용',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _wishController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '간절히 이루고 싶은 소원을 구체적으로 적어주세요',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 60),
                child: Icon(Icons.star_outline),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Wish Category
          Text(
            '소원 분야',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _wishCategories.map((category) {
              final isSelected = _wishCategory == category;
              return ChoiceChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _wishCategory = selected ? category : null;
                  });
                },
                selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          
          // Importance Level
          Text(
            '소원의 중요도',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: _importanceLevels.map((level) {
              final isSelected = _wishImportance == level;
              return RadioListTile<String>(
                title: Text(level),
                value: level,
                groupValue: _wishImportance,
                onChanged: (value) {
                  setState(() {
                    _wishImportance = value;
                  });
                },
                activeColor: theme.colorScheme.primary,
                contentPadding: EdgeInsets.zero,
                dense: true,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          
          // Current Effort
          Text(
            '현재 노력 정도',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _currentEffort,
            decoration: InputDecoration(
              hintText: '선택하세요',
              prefixIcon: const Icon(Icons.fitness_center),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
              ),
            ),
            items: _effortLevels.map((level) => DropdownMenuItem(
              value: level,
              child: Text(level),
            )).toList(),
            onChanged: (value) {
              setState(() {
                _currentEffort = value;
              });
            },
          ),
          const SizedBox(height: 20),
          
          // Obstacles
          Text(
            '현재 장애물 (최대 3개)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _obstacles.map((obstacle) {
              final isSelected = _selectedObstacles.contains(obstacle);
              return FilterChip(
                label: Text(obstacle),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected && _selectedObstacles.length < 3) {
                      _selectedObstacles.add(obstacle);
                    } else if (!selected) {
                      _selectedObstacles.remove(obstacle);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('최대 3개까지 선택 가능합니다')),
                      );
                    }
                  });
                },
                selectedColor: Colors.red.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.red : theme.colorScheme.onSurface,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('이름을 입력해주세요')),
                  );
                  return;
                }
                if (_gender == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('성별을 선택해주세요')),
                  );
                  return;
                }
                if (_birthDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('생년월일을 선택해주세요')),
                  );
                  return;
                }
                if (_wishController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('소원을 입력해주세요')),
                  );
                  return;
                }
                
                widget.onSubmit({
                  'name': _nameController.text,
                  'gender': _gender,
                  'birthDate': _birthDate!.toIso8601String(),
                  'wish': _wishController.text,
                  'category': _wishCategory ?? '기타',
                  'importance': _wishImportance ?? '중요',
                  'effort': _currentEffort ?? '가끔 노력함',
                  'obstacles': _selectedObstacles,
                });
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: theme.colorScheme.primary,
              ),
              child: Text(
                '소원 성취 가능성 보기',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WishFortuneResult extends ConsumerWidget {
  double _getFontSizeOffset(FontSize fontSize) {
    switch (fontSize) {
      case FontSize.small:
        return -2.0;
      case FontSize.medium:
        return 0.0;
      case FontSize.large:
        return 2.0;
    }
  }
  final FortuneResult result;
  final VoidCallback onShare;

  const _WishFortuneResult({
    required this.result,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fontSizeEnum = ref.watch(fontSizeProvider);
    final fontSize = _getFontSizeOffset(fontSizeEnum);
    
    // Extract wish data from result
    final achievementProbability = result.overallScore ?? 75;
    final wishAnalysis = result.additionalInfo?['wishAnalysis'] ?? {};
    final achievementFactors = result.additionalInfo?['achievementFactors'] ?? [];
    final blockingFactors = result.additionalInfo?['blockingFactors'] ?? [];
    final actionSteps = result.additionalInfo?['actionSteps'] ?? [];
    final timeline = result.additionalInfo?['timeline'] ?? {};
    final luckySupports = result.additionalInfo?['luckySupports'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Achievement Probability Card
        GlassContainer(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.stars,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '소원 성취 가능성',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '$achievementProbability%',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: _getScoreColor(achievementProbability),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24 + fontSize,
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildStarRating(achievementProbability),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (result.summary != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    result.summary!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      fontSize: 14 + fontSize,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        // Wish Analysis
        if (wishAnalysis.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics,
                        color: Colors.purple,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '소원 분석',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...wishAnalysis.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          child: Text(
                            entry.key,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              fontSize: 12 + fontSize,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.value.toString(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 12 + fontSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Achievement Factors Chart
        if (achievementFactors.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: Colors.green,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '성취 긍정 요인',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: _buildFactorsChart(achievementFactors, true, theme),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Blocking Factors
        if (blockingFactors.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.block,
                        color: Colors.red,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '극복해야 할 장애물',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...blockingFactors.map((factor) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  factor['obstacle'] ?? '',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13 + fontSize,
                                  ),
                                ),
                                if (factor['solution'] != null)
                                  Text(
                                    '해결책: ${factor['solution']}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontSize: 11 + fontSize,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Action Steps
        if (actionSteps.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.checklist,
                        color: Colors.blue,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '실행 계획',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...actionSteps.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
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
                                entry.value['action'] ?? '',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13 + fontSize,
                                ),
                              ),
                              if (entry.value['deadline'] != null)
                                Text(
                                  '기한: ${entry.value['deadline']}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.orange,
                                    fontSize: 11 + fontSize,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Timeline
        if (timeline.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: Colors.indigo,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '예상 소요 시간',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '최소 기간',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              timeline['minimum'] ?? '',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '평균 기간',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              timeline['average'] ?? '',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '최대 기간',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              timeline['maximum'] ?? '',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Lucky Supports
        if (luckySupports.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.amber,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '행운의 도우미',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: luckySupports.map<Widget>((support) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.withOpacity(0.2),
                            Colors.orange.withOpacity(0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        support,
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontWeight: FontWeight.w500,
                          fontSize: 12 + fontSize,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Recommendations
        if (result.recommendations?.isNotEmpty ?? false) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.amber,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '소원 성취 조언',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...(result.recommendations ?? []).map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tip,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.5,
                              fontSize: 14 + fontSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Share Button
        Center(
          child: OutlinedButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.share),
            label: const Text('소원 운세 공유하기'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStarRating(int score) {
    final starCount = (score / 20).round();
    return Row(
      children: List.generate(5, (index) => Icon(
        index < starCount ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 20,
      )),
    );
  }
  
  Widget _buildFactorsChart(List<dynamic> factors, bool isPositive, ThemeData theme) {
    final colors = isPositive 
        ? [Colors.green, Colors.teal, Colors.blue, Colors.indigo, Colors.purple]
        : [Colors.red, Colors.orange, Colors.pink, Colors.deepOrange, Colors.brown];
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() < factors.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      factors[value.toInt()]['name'] ?? '',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  '${value.toInt()}',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 10,
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.colorScheme.outline.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: factors.asMap().entries.map((entry) {
          final index = entry.key;
          final factor = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: (factor['value'] ?? 0).toDouble(),
                color: colors[index % colors.length],
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
  
  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}