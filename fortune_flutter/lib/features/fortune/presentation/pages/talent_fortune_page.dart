import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../../shared/components/app_header.dart' show FontSize;

class TalentFortunePage extends ConsumerWidget {
  const TalentFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '재능 운세',
      fortuneType: 'talent',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF10B981), Color(0xFF3B82F6)],
      ),
      inputBuilder: (context, onSubmit) => _TalentInputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, onShare) => _TalentFortuneResult(
        result: result,
        onShare: onShare,
      ),
    );
  }
}

class _TalentInputForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _TalentInputForm({required this.onSubmit});

  @override
  State<_TalentInputForm> createState() => _TalentInputFormState();
}

class _TalentInputFormState extends State<_TalentInputForm> {
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  String? _gender;
  final List<String> _selectedInterests = [];
  final List<String> _selectedSkills = [];
  String? _currentOccupation;
  String? _dreamJob;
  
  final List<String> _interestAreas = [
    '예술/창작',
    '과학/기술',
    '비즈니스',
    '교육/연구',
    '스포츠/운동',
    '음악/공연',
    '언어/문학',
    '수학/논리',
    '의료/건강',
    '사회봉사',
    '디자인',
    '요리/음식',
    '자연/환경',
    '미디어/방송',
    '금융/투자',
  ];
  
  final List<String> _currentSkills = [
    '커뮤니케이션',
    '리더십',
    '분석력',
    '창의력',
    '문제해결',
    '협업능력',
    '기획력',
    '실행력',
    '학습능력',
    '적응력',
    '인내심',
    '디테일',
    '공감능력',
    '시간관리',
    '혁신성',
  ];
  
  final List<String> _occupations = [
    '학생',
    '직장인',
    '프리랜서',
    '사업가',
    '예술가',
    '전문직',
    '서비스업',
    '교육자',
    '연구원',
    '주부',
    '은퇴자',
    '구직중',
  ];

  @override
  void dispose() {
    _nameController.dispose();
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
              primary: const Color(0xFF10B981),
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
            '당신의 숨겨진 재능과 잠재력을 발견하고\n미래의 성공 가능성을 예측해드립니다.',
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
          
          // Current Occupation
          Text(
            '현재 직업/상태',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _occupations.map((occupation) {
              final isSelected = _currentOccupation == occupation;
              return ChoiceChip(
                label: Text(occupation),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _currentOccupation = selected ? occupation : null;
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
          
          // Interest Areas Selection
          Text(
            '관심 분야 (최대 5개)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _interestAreas.map((interest) {
              final isSelected = _selectedInterests.contains(interest);
              return FilterChip(
                label: Text(interest),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected && _selectedInterests.length < 5) {
                      _selectedInterests.add(interest);
                    } else if (!selected) {
                      _selectedInterests.remove(interest);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('최대 5개까지 선택 가능합니다')),
                      );
                    }
                  });
                },
                selectedColor: theme.colorScheme.secondary.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? theme.colorScheme.secondary : theme.colorScheme.onSurface,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          
          // Current Skills Selection
          Text(
            '현재 보유 능력 (최대 5개)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _currentSkills.map((skill) {
              final isSelected = _selectedSkills.contains(skill);
              return FilterChip(
                label: Text(skill),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected && _selectedSkills.length < 5) {
                      _selectedSkills.add(skill);
                    } else if (!selected) {
                      _selectedSkills.remove(skill);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('최대 5개까지 선택 가능합니다')),
                      );
                    }
                  });
                },
                selectedColor: Colors.green.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.green[700] : theme.colorScheme.onSurface,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          
          // Dream Job Input
          Text(
            '꿈꾸는 직업 (선택사항)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) {
              _dreamJob = value;
            },
            decoration: InputDecoration(
              hintText: '예: CEO, 예술가, 개발자 등',
              prefixIcon: const Icon(Icons.star_outline),
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
                
                widget.onSubmit({
                  'name': _nameController.text,
                  'gender': _gender,
                  'birthDate': _birthDate!.toIso8601String(),
                  'currentOccupation': _currentOccupation ?? '미정',
                  'interests': _selectedInterests.isEmpty ? ['예술/창작'] : _selectedInterests,
                  'skills': _selectedSkills.isEmpty ? ['창의력'] : _selectedSkills,
                  'dreamJob': _dreamJob ?? '',
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
                '재능 발견하기',
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

class _TalentFortuneResult extends ConsumerWidget {
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

  const _TalentFortuneResult({
    required this.result,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fontSizeEnum = ref.watch(fontSizeProvider);
    final fontSize = _getFontSizeOffset(fontSizeEnum);
    
    // Extract talent data from result
    final talentScore = result.overallScore ?? 85;
    final hiddenTalents = result.additionalInfo?['hiddenTalents'] ?? [];
    final talentCategories = result.scoreBreakdown ?? {};
    final developmentPlan = result.additionalInfo?['developmentPlan'] ?? [];
    final careerPaths = result.additionalInfo?['careerPaths'] ?? [];
    final strengthsWeaknesses = result.additionalInfo?['strengthsWeaknesses'] ?? {};
    final learningRecommendations = result.additionalInfo?['learningRecommendations'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall Talent Score Card
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
                          colors: [Color(0xFF10B981), Color(0xFF3B82F6)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.auto_awesome,
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
                            '재능 잠재력 점수',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '$talentScore점',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: _getScoreColor(talentScore),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24 + fontSize,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getScoreColor(talentScore).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getTalentLevel(talentScore),
                                  style: TextStyle(
                                    color: _getScoreColor(talentScore),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12 + fontSize,
                                  ),
                                ),
                              ),
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
        
        // Hidden Talents
        if (hiddenTalents.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.visibility,
                        color: Colors.purple,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '숨겨진 재능',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...hiddenTalents.map((talent) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.1),
                            theme.colorScheme.secondary.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                talent['name'] ?? '',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14 + fontSize,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            talent['description'] ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 12 + fontSize,
                            ),
                          ),
                          if (talent['potential'] != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  '잠재력: ',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ...List.generate(5, (index) => Icon(
                                  Icons.star,
                                  size: 16,
                                  color: index < talent['potential'] 
                                      ? Colors.amber 
                                      : Colors.grey[300],
                                )),
                              ],
                            ),
                          ],
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
        
        // Talent Categories Chart
        if (talentCategories.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.pie_chart,
                        color: Colors.blue,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '재능 분야별 분석',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 250,
                    child: _buildTalentRadarChart(talentCategories, theme),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Career Paths
        if (careerPaths.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.route,
                        color: Colors.green,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '추천 진로',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...careerPaths.map((path) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.work_outline,
                              color: Colors.green,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  path['title'] ?? '',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14 + fontSize,
                                  ),
                                ),
                                if (path['match'] != null)
                                  Text(
                                    '적합도: ${path['match']}%',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.green,
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
        
        // Development Plan
        if (developmentPlan.isNotEmpty) ...[
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
                        color: Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '재능 개발 계획',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...developmentPlan.asMap().entries.map((entry) => Padding(
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
                              '${entry.key + 1}단계',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
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
                                entry.value['phase'] ?? '',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13 + fontSize,
                                ),
                              ),
                              if (entry.value['action'] != null)
                                Text(
                                  entry.value['action'],
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
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
        
        // Learning Recommendations
        if (learningRecommendations.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.school,
                        color: Colors.indigo,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '학습 추천',
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
                    children: learningRecommendations.map<Widget>((skill) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.indigo.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        skill,
                        style: TextStyle(
                          color: Colors.indigo,
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
                        '재능 개발 조언',
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
            label: const Text('운세 공유하기'),
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
  
  Widget _buildTalentRadarChart(Map<String, dynamic> categories, ThemeData theme) {
    final dataEntries = <RadarDataSet>[];
    final titles = <RadarChartTitle>[];
    
    int index = 0;
    categories.forEach((key, value) {
      titles.add(
        RadarChartTitle(
          text: key,
          angle: 360 * index / categories.length,
        ),
      );
      index++;
    });
    
    final values = categories.values.map((v) => (v as num).toDouble()).toList();
    
    dataEntries.add(
      RadarDataSet(
        fillColor: theme.colorScheme.primary.withOpacity(0.3),
        borderColor: theme.colorScheme.primary,
        borderWidth: 2,
        dataEntries: values.map((v) => RadarEntry(value: v)).toList(),
      ),
    );
    
    return RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon,
        radarBackgroundColor: Colors.transparent,
        borderData: FlBorderData(show: false),
        gridBorderData: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        tickBorderData: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        tickCount: 5,
        titlePositionPercentageOffset: 0.2,
        dataSets: dataEntries,
        getTitle: (index, angle) {
          if (index < titles.length) {
            return titles[index];
          }
          return const RadarChartTitle(text: '');
        },
        titleTextStyle: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 12,
        ),
        ticksTextStyle: TextStyle(
          color: theme.colorScheme.onSurface.withOpacity(0.5),
          fontSize: 10,
        ),
      ),
    );
  }
  
  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.purple;
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
  
  String _getTalentLevel(int score) {
    if (score >= 90) return '천재적 재능';
    if (score >= 80) return '뛰어난 재능';
    if (score >= 60) return '우수한 잠재력';
    if (score >= 40) return '평균적 능력';
    return '개발 필요';
  }
}