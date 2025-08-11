import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

enum LifestyleType {
  health('건강운', 'health', '신체와 정신의 건강 상태를 알아봅니다'),
  biorhythm('바이오리듬', 'biorhythm', '신체, 감성, 지성 리듬을 분석합니다'),
  moving('이사운', 'moving', '이사나 이전에 좋은 시기를 알려드립니다'),
  movingDate('이사 날짜', 'moving_date', '구체적인 이사 길일을 찾아드립니다');

  final String label;
  final String value;
  final String description;
  const LifestyleType(this.label, this.value, this.description);
}

class LifestyleFortunePage extends BaseFortunePage {
  final LifestyleType initialType;
  
  const LifestyleFortunePage({
    Key? key,
    this.initialType = LifestyleType.health}) : super(
          key: key,
          title: '생활 & 건강 운세',
          description: '건강하고 행복한 일상을 위한 운세를 확인하세요',
          fortuneType: 'lifestyle',
          requiresUserInfo: true);

  @override
  ConsumerState<LifestyleFortunePage> createState() => _LifestyleFortunePageState();
}

class _LifestyleFortunePageState extends BaseFortunePageState<LifestyleFortunePage> {
  late LifestyleType _selectedType;
  
  // Health specific
  List<String> _healthConcerns = [];
  String? _activityLevel;
  
  // Biorhythm specific
  DateTime? _checkDate;
  
  // Moving specific
  String? _currentAddress;
  String? _destinationArea;
  String? _movingPurpose;
  List<DateTime> _candidateDates = [];

  // Health concerns options
  final List<String> _healthOptions = [
    '피로감', '스트레스', '수면', '소화', '면역력', '체중관리', '피부', '눈건강', '관절', '호흡기'
  ];

  // Activity level options
  final List<String> _activityLevels = [
    '매우 활동적', '활동적', '보통', '저활동', '매우 저활동'
  ];

  // Moving purpose options
  final List<String> _movingPurposes = [
    '직장 이직', '결혼', '독립', '가족 확대', '환경 개선', '투자 목적'
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _checkDate = DateTime.now();
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final fortuneService = ref.read(fortuneServiceProvider);
    
    // Add lifestyle-specific parameters
    params['lifestyleType'] = _selectedType.value;
    
    switch (_selectedType) {
      case LifestyleType.health:
        params['healthConcerns'] = _healthConcerns;
        params['activityLevel'] = _activityLevel ?? '보통';
        break;
      case LifestyleType.biorhythm:
        params['checkDate'] = _checkDate?.toIso8601String();
        break;
      case LifestyleType.moving:
      case LifestyleType.movingDate:
        params['currentAddress'] = _currentAddress;
        params['destinationArea'] = _destinationArea;
        params['movingPurpose'] = _movingPurpose;
        params['candidateDates'] = _candidateDates.map((d) => d.toIso8601String()).toList();
        break;
    }
    
    final fortune = await fortuneService.getLifestyleFortune(
      userId: params['userId'],
      fortuneType: _selectedType.value,
      params: params
    );
    
    return fortune;
  }

  @override
  Widget buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type Selector
          Text(
            '운세 유형',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold
            )
          ),
          const SizedBox(height: 16),
          ...LifestyleType.values.map((type) {
            final isSelected = _selectedType == type;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedType = type;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary.withOpacity(0.1),
                              AppColors.secondary.withOpacity(0.1)
                            ]
                          )
                        : null,
                    color: isSelected ? null : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? AppColors.primary
                          : AppColors.border,
                      width: isSelected ? 2 : 1
                    )
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.2)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child: Icon(
                          _getIconForType(type),
                          color: isSelected 
                              ? AppColors.primary
                              : AppColors.textSecondary
                        )
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type.label,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isSelected 
                                    ? AppColors.primary
                                    : AppColors.textPrimary
                              )
                            ),
                            const SizedBox(height: 4),
                            Text(
                              type.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary
                              )
                            )
                          ]
                        )
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: AppColors.primary
                        )
                    ]
                  )
                )
              ).animate()
              .fadeIn(duration: 300.ms, delay: (type.index * 50).ms)
              .slideX(begin: 0.1, end: 0)
            );
          }).toList(),
          const SizedBox(height: 24),

          // Type-specific inputs
          _buildTypeSpecificInputs(context),

          const SizedBox(height: 24),

          // Generate Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canGenerate() ? _onGenerateFortune : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)
                )
              ),
              child: const Text(
                '운세 보기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                )
              )
            )
          )
        ]
      )
    );
  }

  Widget _buildTypeSpecificInputs(BuildContext context) {
    switch (_selectedType) {
      case LifestyleType.health:
        return _buildHealthInputs(context);
      case LifestyleType.biorhythm:
        return _buildBiorhythmInputs(context);
      case LifestyleType.moving:
      case LifestyleType.movingDate:
        return _buildMovingInputs(context);
    }
  }

  Widget _buildHealthInputs(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '건강 관심사 (최대 3개)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold
          )
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _healthOptions.map((concern) {
            final isSelected = _healthConcerns.contains(concern);
            return FilterChip(
              label: Text(concern),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected && _healthConcerns.length < 3) {
                    _healthConcerns.add(concern);
                  } else if (!selected) {
                    _healthConcerns.remove(concern);
                  }
                });
              },
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary
            );
          }).toList()
        ),
        const SizedBox(height: 24),
        Text(
          '활동 수준',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold
          )
        ),
        const SizedBox(height: 16),
        SegmentedButton<String>(
          segments: _activityLevels.map((level) {
            return ButtonSegment(
              value: level,
              label: Text(
                level,
                style: const TextStyle(fontSize: 12)
              )
            );
          }).toList(),
          selected: _activityLevel != null ? {_activityLevel!} : {},
          onSelectionChanged: (Set<String> newSelection) {
            setState(() {
              _activityLevel = newSelection.first;
            });
          }
        )
      ]
    );
  }

  Widget _buildBiorhythmInputs(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '확인할 날짜',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold
          )
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _checkDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365))
            );
            if (picked != null) {
              setState(() {
                _checkDate = picked;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12)
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  _checkDate != null
                      ? '${_checkDate!.year}년 ${_checkDate!.month}월 ${_checkDate!.day}일'
                      : '날짜를 선택하세요',
                  style: TextStyle(
                    color: _checkDate != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary
                  )
                )
              ]
            )
          )
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '바이오리듬이란?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary
                    )
                  )
                ]
              ),
              const SizedBox(height: 8),
              Text(
                '• 신체리듬 (23일 주기): 체력, 건강 상태\n'
                '• 감성리듬 (28일 주기): 감정, 기분 상태\n'
                '• 지성리듬 (33일 주기): 사고력, 판단력',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.5
                )
              )
            ]
          )
        ]
      )
    );
  }

  Widget _buildMovingInputs(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '현재 거주지',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold
          )
        ),
        const SizedBox(height: 12),
        TextField(
          onChanged: (value) => _currentAddress = value,
          decoration: InputDecoration(
            hintText: '예: 서울시 강남구',
            prefixIcon: const Icon(Icons.home),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12)
            )
          )
        ),
        const SizedBox(height: 20),
        Text(
          '이사 희망 지역',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold
          )
        ),
        const SizedBox(height: 12),
        TextField(
          onChanged: (value) => _destinationArea = value,
          decoration: InputDecoration(
            hintText: '예: 경기도 성남시',
            prefixIcon: const Icon(Icons.location_on),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12)
            )
          )
        ),
        const SizedBox(height: 20),
        Text(
          '이사 목적',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold
          )
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _movingPurposes.map((purpose) {
            final isSelected = _movingPurpose == purpose;
            return ChoiceChip(
              label: Text(purpose),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _movingPurpose = selected ? purpose : null;
                });
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary
              )
            );
          }).toList()
        ),
        if (_selectedType == LifestyleType.movingDate) ...[
          const SizedBox(height: 20),
          Text(
            '후보 날짜 (최대 3개)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold
            )
          ),
          const SizedBox(height: 12),
          ..._candidateDates.map((date) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border)
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    '${date.year}년 ${date.month}월 ${date.day}일',
                    style: const TextStyle(fontWeight: FontWeight.w500)
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      setState(() {
                        _candidateDates.remove(date);
                      });
                    }
                  )
                ]
              )
            );
          }).toList(),
          if (_candidateDates.length < 3)
            TextButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365))
                );
                if (picked != null && !_candidateDates.contains(picked)) {
                  setState(() {
                    _candidateDates.add(picked);
                  });
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('날짜 추가')
            )
        ]
      ]
    );
  }

  bool _canGenerate() {
    switch (_selectedType) {
      case LifestyleType.health:
        return true; // Health concerns are optional
      case LifestyleType.biorhythm:
        return _checkDate != null;
      case LifestyleType.moving:
        return _currentAddress != null && 
               _currentAddress!.isNotEmpty &&
               _destinationArea != null &&
               _destinationArea!.isNotEmpty;
      case LifestyleType.movingDate:
        return _currentAddress != null && 
               _currentAddress!.isNotEmpty &&
               _destinationArea != null &&
               _destinationArea!.isNotEmpty &&
               _candidateDates.isNotEmpty;
    }
  }

  void _onGenerateFortune() {
    // Get user profile and generate fortune
    final profile = userProfile;
    if (profile != null) {
      final params = {
        'userId': profile.id,
        'name': profile.name,
        'birthDate': profile.birthDate?.toIso8601String(),
        'gender': profile.gender
      };
      generateFortuneAction(params: params);
    }
  }

  @override
  Widget buildFortuneResult() {
    final fortuneData = fortune;
    if (fortuneData == null) return const SizedBox.shrink();
    
    switch (_selectedType) {
      case LifestyleType.health:
        return _buildHealthResult(fortuneData);
      case LifestyleType.biorhythm:
        return _buildBiorhythmResult(fortuneData);
      case LifestyleType.moving:
      case LifestyleType.movingDate:
        return _buildMovingResult(fortuneData);
    }
  }

  Widget _buildHealthResult(Fortune fortune) {
    final healthScore = fortune.score ?? 75;
    final recommendations = fortune.recommendations ?? [];
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Health Score Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getHealthColor(healthScore).withOpacity(0.1),
                  _getHealthColor(healthScore).withOpacity(0.05)
                ]
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getHealthColor(healthScore).withOpacity(0.3),
                width: 1
              )
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite,
                      color: _getHealthColor(healthScore),
                      size: 32
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '건강 점수',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold
                      )
                    )
                  ]
                ),
                const SizedBox(height: 16),
                Text(
                  '$healthScore점',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: _getHealthColor(healthScore),
                    fontWeight: FontWeight.bold
                  )
                ),
                const SizedBox(height: 8),
                Text(
                  _getHealthStatus(healthScore),
                  style: TextStyle(
                    color: _getHealthColor(healthScore),
                    fontWeight: FontWeight.w500
                  )
                ),
                const SizedBox(height: 20),
                Text(
                  fortune.content,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6
                  ),
                  textAlign: TextAlign.center
                )
              ]
            )
          ).animate()
            .fadeIn(duration: 500.ms)
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
            const SizedBox(height: 20),

          // Health Tips
          if (recommendations.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.health_and_safety,
                        color: AppColors.primary,
                        size: 24
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '건강 관리 팁',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold
                        )
                      )
                    ]
                  ),
                  const SizedBox(height: 16),
                  ...recommendations.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 20
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tip,
                            style: Theme.of(context).textTheme.bodyMedium
                          )
                        )
                      ]
                    )
                  )).toList()
                ]
              )
            )
          ]
        ]
      )
    );
  }

  Widget _buildBiorhythmResult(Fortune fortune) {
    final biorhythmData = fortune.additionalInfo?['biorhythm'] ?? {};
    final physical = biorhythmData['physical'] ?? 0;
    final emotional = biorhythmData['emotional'] ?? 0;
    final intellectual = biorhythmData['intellectual'] ?? 0;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Biorhythm Chart
          Container(
            height: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border)
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.border,
                      strokeWidth: 1
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: AppColors.border,
                      strokeWidth: 1
                    );
                  }
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(fontSize: 10)
                        );
                      }
                    )
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false
                    )
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false)
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false)
                  )
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: AppColors.border)
                ),
                minX: 0,
                maxX: 30,
                minY: -100,
                maxY: 100,
                lineBarsData: [
                  // Physical rhythm
                  LineChartBarData(
                    spots: _generateBiorhythmPoints(23, physical),
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false)
                  ),
                  // Emotional rhythm
                  LineChartBarData(
                    spots: _generateBiorhythmPoints(28, emotional),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false)
                  ),
                  // Intellectual rhythm
                  LineChartBarData(
                    spots: _generateBiorhythmPoints(33, intellectual),
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false)
                  )
                ]
              )
            )
          ),
          const SizedBox(height: 16),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBiorhythmLegend('신체', Colors.red, physical),
              _buildBiorhythmLegend('감성', Colors.blue, emotional),
              _buildBiorhythmLegend('지성', Colors.green, intellectual)
            ]
          ),
          const SizedBox(height: 20),

          // Fortune Content
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0.1)
                ]
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1
              )
            ),
            child: Text(
              fortune.content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6
              )
            )
          )
        ]
      )
    );
  }

  Widget _buildMovingResult(Fortune fortune) {
    final luckyDirections = (fortune.luckyItems ?? []) as List<String>;
    final goodDates = (fortune.additionalInfo?['goodDates'] ?? []) as List;
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Moving Fortune Content
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0.1)
                ]
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1
              )
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.home_work,
                      color: AppColors.primary,
                      size: 28
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '이사 운세 결과',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary
                      )
                    )
                  ]
                ),
                const SizedBox(height: 20),
                Text(
                  fortune.content,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6
                  )
                )
              ]
            )
          ),
          const SizedBox(height: 20),

          // Lucky Directions
          if (luckyDirections.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.explore,
                        color: AppColors.secondary,
                        size: 24
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '길한 방향',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold
                        )
                      )
                    ]
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: luckyDirections.map((direction) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.secondary.withOpacity(0.3)
                          )
                        ),
                        child: Text(
                          direction,
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w500
                          )
                        )
                      );
                    }).toList()
                  )
                ]
              )
            )
          ],

          // Good Dates
          if (goodDates.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        color: AppColors.success,
                        size: 24
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '길일 추천',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold
                        )
                      )
                    ]
                  ),
                  const SizedBox(height: 16),
                  ...goodDates.map((date) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.3)
                      )
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check,
                          color: AppColors.success,
                          size: 20
                        ),
                        const SizedBox(width: 8),
                        Text(
                          date,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500
                          )
                        )
                      ]
                    )
                  )).toList()
                ]
              )
            )
          ]
        ]
      )
    );
  }

  List<FlSpot> _generateBiorhythmPoints(int cycle, double currentValue) {
    List<FlSpot> spots = [];
    for (int i = 0; i <= 30; i++) {
      double value = 100 * sin((2 * pi * i) / cycle + (currentValue * pi / 100));
      spots.add(FlSpot(i.toDouble(), value));
    }
    return spots;
  }

  Widget _buildBiorhythmLegend(String label, Color color, double value) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 3,
          color: color
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ${value.toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500
          )
        )
      ]
    );
  }

  Color _getHealthColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getHealthStatus(int score) {
    if (score >= 80) return '매우 건강';
    if (score >= 60) return '건강';
    if (score >= 40) return '주의 필요';
    return '관리 필요';
  }

  IconData _getIconForType(LifestyleType type) {
    switch (type) {
      case LifestyleType.health:
        return Icons.favorite;
      case LifestyleType.biorhythm:
        return Icons.show_chart;
      case LifestyleType.moving:
        return Icons.home;
      case LifestyleType.movingDate:
        return Icons.calendar_today;
    }
  }
}