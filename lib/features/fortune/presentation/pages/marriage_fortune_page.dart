import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/toast.dart';

class MarriageFortunePage extends BaseFortunePage {
  const MarriageFortunePage({Key? key})
      : super(
          key: key,
          title: '결혼운',
          description: '운명의 배우자와 결혼 시기 예측',
          fortuneType: 'marriage',
          requiresUserInfo: true
        );

  @override
  ConsumerState<MarriageFortunePage> createState() => _MarriageFortunePageState();
}

class _MarriageFortunePageState extends BaseFortunePageState<MarriageFortunePage> {
  String? _currentStatus;
  String? _idealType;
  String? _priorities;
  List<String> _selectedValues = [];
  String? _readinessLevel;
  bool _hasParentalPressure = false;
  bool _hasFinancialPreparation = false;
  String? _relationshipExperience;

  final Map<String, String> _statusOptions = {
    'single': '미혼 (연애 안함)': 'dating': '연애 중': 'engaged': '약혼': 'divorced': '이혼': 'widowed': '사별',
  };

  final Map<String, String> _idealTypes = {
    'caring': '다정다감한 사람': 'stable': '경제적 안정된 사람': 'humorous': '유머러스한 사람': 'mature': '성숙한 사람': 'passionate': '열정적인 사람': 'intellectual': '지적인 사람',
  };

  final Map<String, String> _priorityOptions = {
    'love': '사랑이 최우선': 'stability': '안정성이 중요': 'family': '가정적인 면이 중요': 'growth': '함께 성장하는 관계': 'compatibility': '가치관 일치',
  };

  final List<String> _values = [
    '정직': '신뢰',
    '소통': '존중',
    '독립성': '가족중시',
    '성장': '유머',
    '열정': '안정'
  ];

  final Map<String, String> _readinessLevels = {
    'not_ready': '아직 준비 안됨': 'thinking': '고민 중': 'somewhat_ready': '어느 정도 준비됨': 'ready': '준비됨': 'very_ready': '매우 준비됨',
  };

  // User info form state
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  String? _gender;
  String? _mbti;
  
  @override
  void initState() {
    super.initState();
    
    // Pre-fill user data with profile if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userProfile != null) {
        setState(() {
          _nameController.text = userProfile!.name ?? '';
          _birthDate = userProfile!.birthDate;
          _gender = userProfile!.gender;
          _mbti = userProfile!.mbtiType;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    if (_nameController.text.isEmpty || _birthDate == null || _gender == null) {
      Toast.warning(context, '기본 정보를 입력해주세요.');
      return null;
    }

    return {
      'name': _nameController.text,
      'birthDate': _birthDate!.toIso8601String(),
      'gender': _gender,
      'mbti': null};
  }

  Widget buildUserInfoForm() {
    final theme = Theme.of(context);
    
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '기본 정보',
            style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          
          // Name Input
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: '이름',
              hintText: '이름을 입력하세요',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
          
          // Birth Date Picker
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _birthDate ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now();
              if (date != null) {
                setState(() => _birthDate = date);
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: '생년월일',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _birthDate != null
                    ? '${_birthDate!.year}년 ${_birthDate!.month}월 ${_birthDate!.day}일'
                    : '생년월일을 선택하세요',
                style: TextStyle(
                  color: _birthDate != null
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withOpacity(0.6)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Gender Selection
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '성별',
                style: theme.textTheme.bodyLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('남성'),
                      value: 'male',
                      groupValue: _gender,
                      onChanged: (value) => setState(() => _gender = value),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('여성'),
                      value: 'female',
                      groupValue: _gender,
                      onChanged: (value) => setState(() => _gender = value),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final fortuneService = ref.read(fortuneServiceProvider);
    
    return await fortuneService.getFortune(
      fortuneType: widget.fortuneType,
      userId: ref.read(userProvider).value?.id ?? 'anonymous',
      params: params
    );
  }

  @override
  Future<Map<String, dynamic>?> getFortuneParams() async {
    final userInfo = await getUserInfo();
    if (userInfo == null) return null;

    if (_currentStatus == null || _idealType == null || 
        _priorities == null || _selectedValues.isEmpty || 
        _readinessLevel == null) {
      Toast.warning(context, '모든 필수 정보를 입력해주세요.');
      return null;
    }

    return {
      ...userInfo,
      'currentStatus': _currentStatus,
      'idealType': _idealType,
      'priorities': _priorities,
      'values': _selectedValues,
      'readinessLevel': _readinessLevel,
      'hasParentalPressure': _hasParentalPressure,
      'hasFinancialPreparation': _hasFinancialPreparation,
      'relationshipExperience': null};
  }

  @override
  Widget buildInputForm() {
    final theme = Theme.of(context);

    return Column(
      children: [
        // User Info Form
        buildUserInfoForm(),
        const SizedBox(height: 16),
        
        // Current Status
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '현재 상태',
                style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              ..._statusOptions.entries.map((entry) {
                final isSelected = _currentStatus == entry.key;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _currentStatus = entry.key;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16),
                      borderRadius: BorderRadius.circular(12),
                      blur: 10,
                      borderColor: isSelected
                          ? theme.colorScheme.primary.withOpacity(0.5)
                          : Colors.transparent,
                      borderWidth: isSelected ? 2 : 0,
                      child: Row(
                        children: [
                          Radio<String>(
                            value: entry.key,
                            groupValue: _currentStatus,
                            onChanged: (value) {
                              setState(() {
                                _currentStatus = value;
                              });
                            }),
                          Text(
                            entry.value,
                            style: theme.textTheme.bodyLarge),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Ideal Type & Priorities
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '이상형과 우선순위',
                style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              
              // Ideal Type
              Text(
                '이상형',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _idealType,
                decoration: InputDecoration(
                  hintText: '이상형을 선택하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  filled: true,
                  fillColor: theme.colorScheme.surface.withOpacity(0.5)),
                items: _idealTypes.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _idealType = value;
                  });
                }),
              const SizedBox(height: 16),
              
              // Priorities
              Text(
                '결혼에서 중요한 것',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _priorities,
                decoration: InputDecoration(
                  hintText: '우선순위를 선택하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  filled: true,
                  fillColor: theme.colorScheme.surface.withOpacity(0.5)),
                items: _priorityOptions.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _priorities = value;
                  });
                })])),
        const SizedBox(height: 16),
        
        // Values
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '중요하게 생각하는 가치관',
                style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                '3개 이상 선택해주세요',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7)),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _values.map((value) {
                  final isSelected = _selectedValues.contains(value);
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedValues.remove(value);
                        } else {
                          _selectedValues.add(value);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Chip(
                      label: Text(value),
                      backgroundColor: isSelected
                          ? theme.colorScheme.primary.withOpacity(0.2)
                          : theme.colorScheme.surface.withOpacity(0.5),
                      side: BorderSide(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.3)),
                      deleteIcon: isSelected
                          ? const Icon(Icons.check_circle, size: 18)
                          : null,
                      onDeleted: isSelected ? () {} : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Marriage Readiness
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '결혼 준비도',
                style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              ..._readinessLevels.entries.map((entry) {
                final isSelected = _readinessLevel == entry.key;
                final index = _readinessLevels.keys.toList().indexOf(entry.key);
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _readinessLevel = entry.key;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(16),
                      borderRadius: BorderRadius.circular(12),
                      blur: 10,
                      borderColor: isSelected
                          ? theme.colorScheme.primary.withOpacity(0.5)
                          : Colors.transparent,
                      borderWidth: isSelected ? 2 : 0,
                      child: Row(
                        children: [
                          // Readiness indicator
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getReadinessColor(index).withOpacity(0.2),
                              border: Border.all(
                                color: _getReadinessColor(index),
                                width: 2)),
                            child: Center(
                              child: Text(
                                '${(index + 1) * 20}%',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _getReadinessColor(index)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: theme.textTheme.bodyLarge)),
                          if (isSelected),
            Icon(
                              Icons.check_circle,
                              color: theme.colorScheme.primary),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Additional Info
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildSwitchTile(
                '부모님의 결혼 압박이 있나요?',
                _hasParentalPressure,
                (value) => setState(() => _hasParentalPressure = value),
                Icons.family_restroom),
              const SizedBox(height: 12),
              _buildSwitchTile(
                '경제적 준비가 되어 있나요?',
                _hasFinancialPreparation,
                (value) => setState(() => _hasFinancialPreparation = value),
                Icons.account_balance_wallet)]))]
    );
  }

  Color _getReadinessColor(int index) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.lightGreen,
      Colors.green];
    return colors[index];
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged, IconData icon) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodyLarge)),
        Switch(
          value: value,
          onChanged: onChanged)]);
  }

  @override
  Widget buildFortuneResult() {
    return Column(
      children: [
        super.buildFortuneResult(),
        _buildMarriageTimeline(),
        _buildCompatibilityAnalysis(),
        _buildIdealPartnerProfile(),
        _buildMarriageReadinessAssessment(),
        _buildActionPlan()]
    );
  }

  Widget _buildMarriageTimeline() {
    final theme = Theme.of(context);
    
    // Mock data for timeline
    final timelineEvents = [
      {'age': 28, 'event': '인연 만남': 'probability': 65},
      {'age': 29, 'event': '연애 시작': 'probability': 75},
      {'age': 31, 'event': '결혼 적기': 'probability': 85},
      {'age': 33, 'event': '안정기': 'probability': 70}];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timeline_rounded,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '결혼 타임라인',
                  style: theme.textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 20,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.onSurface.withOpacity(0.1),
                        strokeWidth: 1);
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.onSurface.withOpacity(0.1),
                        strokeWidth: 1
                      );
                    }),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final age = value.toInt() + 27;
                          return Text(
                            '$age세',
                            style: theme.textTheme.bodySmall,
                          );
                        })),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: theme.textTheme.bodySmall,
                          );
                        })),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: theme.colorScheme.onSurface.withOpacity(0.2)),
                  ),
                  minX: 0,
                  maxX: timelineEvents.length - 1.0,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: timelineEvents.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          (entry.value['probability'] as num).toDouble();
                      }).toList(),
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary]),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: theme.colorScheme.primary
                          );
                        }),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.2),
                            theme.colorScheme.secondary.withOpacity(0.1)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...timelineEvents.map((event) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary)),
                  const SizedBox(width: 8),
                  Text(
                    '${event['age']}세',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event['event'] as String,
                      style: theme.textTheme.bodyMedium)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4),
                    decoration: BoxDecoration(
                      color: _getProbabilityColor(event['probability'] as int),
                      borderRadius: BorderRadius.circular(12),
                    child: Text(
                      '${event['probability']}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getProbabilityColor(event['probability'] as int),
                        fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Color _getProbabilityColor(int probability) {
    if (probability >= 80) return Colors.green;
    if (probability >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _buildCompatibilityAnalysis() {
    final theme = Theme.of(context);
    
    final compatibilityFactors = [
      {'factor': '성격': 'score': 85, 'icon': Icons.person},
      {'factor': '가치관': 'score': 90, 'icon': Icons.favorite},
      {'factor': '생활습관': 'score': 75, 'icon': Icons.schedule},
      {'factor': '미래계획': 'score': 80, 'icon': Icons.trending_up},
      {'factor': '가족관계': 'score': 70, 'icon': Icons.family_restroom}];
    
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
                  Icons.favorite_rounded,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '이상적 궁합 분석',
                  style: theme.textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 16),
            ...compatibilityFactors.map((factor) {
              final score = factor['score'] as int;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          factor['icon'] as IconData,
                          size: 20,
                          color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            factor['factor'] as String,
                            style: theme.textTheme.bodyMedium)),
                        Text(
                          '$score%',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getProbabilityColor(score)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: score / 100,
                        minHeight: 8,
                        backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getProbabilityColor(score)),
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

  Widget _buildIdealPartnerProfile() {
    final theme = Theme.of(context);
    
    final partnerTraits = [
      {'trait': '나이': 'description': '당신보다 2-5살 연상/연하'},
      {'trait': '성격': 'description': '차분하고 이해심 많은 성격'},
      {'trait': '직업': 'description': '안정적인 직업 또는 전문직'},
      {'trait': '취미': 'description': '문화생활을 즐기는 타입'},
      {'trait': '가족관': 'description': '가족을 중시하는 가치관'},
      {'trait': '생활': 'description': '규칙적이고 건강한 생활습관'}];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_search_rounded,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '이상적인 배우자 프로필',
                  style: theme.textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.secondary.withOpacity(0.1)]),
                borderRadius: BorderRadius.circular(12),
              child: Column(
                children: partnerTraits.map((trait) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 60,
                        child: Text(
                          trait['trait'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: Text(
                          trait['description'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.8)),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarriageReadinessAssessment() {
    final theme = Theme.of(context);
    
    final assessmentCategories = [
      {
        'category': '정서적 준비': 'items': [
          '자신을 충분히 이해하고 있음': '타인과의 깊은 관계 형성 가능',
          '갈등 해결 능력 보유'],
        'score': null},
      {
        'category': '경제적 준비': 'items': [
          '안정적인 수입원': '기본적인 저축',
          '미래 계획 수립'],
        'score': null},
      {
        'category': '사회적 준비': 'items': [
          '독립적인 생활 가능': '가족과의 관계 정립',
          '사회적 네트워크 구축'],
        'score': null}];
    
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
                  Icons.checklist_rounded,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '결혼 준비도 평가',
                  style: theme.textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 16),
            ...assessmentCategories.map((category) {
              final score = category['score'] as int;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.onSurface.withOpacity(0.1)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              category['category'] as String,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6),
                            decoration: BoxDecoration(
                              color: _getProbabilityColor(score).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            child: Text(
                              '$score%',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: _getProbabilityColor(score),
                                fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...(category['items'] as List).map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 16,
                              color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              item as String,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      )).toList(),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionPlan() {
    final theme = Theme.of(context);
    
    final actionSteps = [
      {
        'phase': '1단계 (1-3개월)': 'actions': [
          '자기 자신에 대한 깊은 성찰': '이상적인 관계에 대한 명확한 정의',
          '개인적 성장을 위한 노력'],
        'icon': null},
      {
        'phase': '2단계 (3-6개월)': 'actions': [
          '적극적인 사회활동 참여': '새로운 사람들과의 네트워킹',
          '취미나 관심사 기반 모임 참여'],
        'icon': null},
      {
        'phase': '3단계 (6개월 이후)': 'actions': [
          '진지한 만남 시작': '서로를 깊이 알아가는 시간',
          '미래 계획 논의'],
        'icon': null}];
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.rocket_launch_rounded,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '행동 계획',
                  style: theme.textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 16),
            ...actionSteps.map((step) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.05),
                      theme.colorScheme.secondary.withOpacity(0.05)]),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(11),
                          topRight: Radius.circular(11)),
                      child: Row(
                        children: [
                          Icon(
                            step['icon'] as IconData,
                            size: 20,
                            color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            step['phase'] as String,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: (step['actions'] as List).map((action) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.primary)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  action as String,
                                  style: theme.textTheme.bodyMedium)),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}