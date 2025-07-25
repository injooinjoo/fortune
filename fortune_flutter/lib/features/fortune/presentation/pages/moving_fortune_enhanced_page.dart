import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:fortune/shared/components/app_header.dart' show FontSize;
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../widgets/enhanced_date_picker.dart';
import '../widgets/map_location_picker.dart';
import '../widgets/enhanced_moving_result.dart';
import '../../../../core/utils/auspicious_days_calculator.dart';

class MovingFortuneEnhancedPage extends ConsumerWidget {
  const MovingFortuneEnhancedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '이사운세 상세진단',
      fortuneType: 'moving-enhanced',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
      ),
      inputBuilder: (context, onSubmit) => _EnhancedMovingInputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, onShare) => _EnhancedMovingFortuneResult(
        result: result,
        onShare: onShare,
      ),
    );
  }
}

class _EnhancedMovingInputForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _EnhancedMovingInputForm({required this.onSubmit});

  @override
  State<_EnhancedMovingInputForm> createState() => _EnhancedMovingInputFormState();
}

class _EnhancedMovingInputFormState extends State<_EnhancedMovingInputForm> 
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  late TabController _tabController;
  
  DateTime? _birthDate;
  DateTime? _plannedDate;
  String? _selectedReason;
  String? _selectedType;
  String? _urgencyLevel;
  
  // Location data
  LatLng? _currentLocation;
  String _currentAddress = '';
  LatLng? _targetLocation;
  String _targetAddress = '';
  
  // Date picker data
  Map<DateTime, double> _luckyScores = {};
  List<DateTime> _auspiciousDays = [];
  
  final List<String> _movingReasons = [
    '직장 이동',
    '결혼',
    '환경 개선',
    '자녀 교육',
    '경제적 이유',
    '건강',
    '가족과 함께',
    '독립',
    '기타',
  ];
  
  final List<String> _movingTypes = [
    '아파트',
    '빌라/연립',
    '단독주택',
    '오피스텔',
    '원룸',
    '기숙사',
    '전원주택',
    '기타',
  ];
  
  final List<String> _urgencyLevels = [
    '여유있게 (3개월 이상)',
    '보통 (1-3개월)',
    '급하게 (1개월 이내)',
    '매우 급하게 (2주 이내)',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _calculateAuspiciousDays();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _calculateAuspiciousDays() {
    final now = DateTime.now();
    _auspiciousDays.clear();
    _luckyScores.clear();
    
    // Calculate for next 3 months
    for (int month = 0; month < 3; month++) {
      final targetMonth = DateTime(now.year, now.month + month, 1);
      final auspiciousDaysInMonth = AuspiciousDaysCalculator.getAuspiciousDays(
        targetMonth.year,
        targetMonth.month,
      );
      _auspiciousDays.addAll(auspiciousDaysInMonth);
      
      // Calculate lucky scores for each day
      final lastDay = DateTime(targetMonth.year, targetMonth.month + 1, 0);
      for (var day = targetMonth; 
           day.isBefore(lastDay.add(const Duration(days: 1))); 
           day = day.add(const Duration(days: 1))) {
        _luckyScores[day] = AuspiciousDaysCalculator.getMovingLuckScore(
          day, 
          _birthDate?.toIso8601String(),
        );
      }
    }
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '상세한 이사 운세 진단을 위해 정보를 입력해주세요.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        
        // Tab Bar
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            tabs: const [
              Tab(text: '기본정보'),
              Tab(text: '위치선택'),
              Tab(text: '날짜선택'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Tab Views
        SizedBox(
          height: 600,
          child: TabBarView(
            controller: _tabController,
            children: [
              // Basic Info Tab
              _buildBasicInfoTab(theme),
              
              // Location Tab
              _buildLocationTab(theme),
              
              // Date Tab
              _buildDateTab(theme),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _validateAndSubmit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: theme.colorScheme.primary,
            ),
            child: Text(
              '상세 이사운세 확인하기',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoTab(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              ),
            ),
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
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _birthDate ?? DateTime(1990, 1, 1),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  _birthDate = picked;
                  _calculateAuspiciousDays(); // Recalculate with birth date
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
                  const SizedBox(width: 12),
                  Text(
                    _birthDate != null
                        ? '${_birthDate!.year}년 ${_birthDate!.month}월 ${_birthDate!.day}일'
                        : '생년월일을 선택하세요',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Moving Reason
          Text(
            '이사 이유',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _movingReasons.map((reason) {
              final isSelected = _selectedReason == reason;
              return ChoiceChip(
                label: Text(reason),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedReason = selected ? reason : null;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          
          // Housing Type
          Text(
            '희망 주거 형태',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _movingTypes.map((type) {
              final isSelected = _selectedType == type;
              return ChoiceChip(
                label: Text(type),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedType = selected ? type : null;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          
          // Urgency Level
          Text(
            '이사 시급성',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: _urgencyLevels.map((level) {
              return RadioListTile<String>(
                title: Text(level),
                value: level,
                groupValue: _urgencyLevel,
                onChanged: (value) {
                  setState(() {
                    _urgencyLevel = value;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTab(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '현재 거주지',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: MapLocationPicker(
              onLocationSelected: (location, address) {
                setState(() {
                  _currentLocation = location;
                  _currentAddress = address;
                });
              },
              initialLocation: _currentLocation,
              initialAddress: _currentAddress,
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        Text(
          '이사 희망 지역',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: MapLocationPicker(
              onLocationSelected: (location, address) {
                setState(() {
                  _targetLocation = location;
                  _targetAddress = address;
                });
              },
              initialLocation: _targetLocation,
              initialAddress: _targetAddress,
              showDirectionOverlay: true,
              auspiciousDirections: const ['동쪽', '남동쪽'], // This will be calculated
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTab(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이사 날짜 선택',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '손없는날과 길일을 확인하여 최적의 이사 날짜를 선택하세요.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          
          EnhancedDatePicker(
            initialDate: _plannedDate ?? DateTime.now().add(const Duration(days: 30)),
            onDateSelected: (date) {
              setState(() {
                _plannedDate = date;
              });
            },
            luckyScores: _luckyScores,
            auspiciousDays: _auspiciousDays,
            holidayMap: {
              // Add Korean holidays here
            },
          ),
        ],
      ),
    );
  }

  void _validateAndSubmit() {
    if (_nameController.text.isEmpty) {
      _showError('이름을 입력해주세요');
      _tabController.animateTo(0);
      return;
    }
    if (_birthDate == null) {
      _showError('생년월일을 선택해주세요');
      _tabController.animateTo(0);
      return;
    }
    if (_currentAddress.isEmpty) {
      _showError('현재 거주지를 선택해주세요');
      _tabController.animateTo(1);
      return;
    }
    if (_plannedDate == null) {
      _showError('이사 예정일을 선택해주세요');
      _tabController.animateTo(2);
      return;
    }
    
    final isAuspicious = AuspiciousDaysCalculator.isAuspiciousDay(_plannedDate!);
    final lunarInfo = AuspiciousDaysCalculator.getLunarDateInfo(_plannedDate!);
    final solarTerm = AuspiciousDaysCalculator.getSolarTerm(_plannedDate!);
    
    widget.onSubmit({
      'name': _nameController.text,
      'birthDate': _birthDate!.toIso8601String(),
      'currentAddress': _currentAddress,
      'currentLocation': _currentLocation != null 
          ? {'lat': _currentLocation!.latitude, 'lng': _currentLocation!.longitude}
          : null,
      'targetAddress': _targetAddress,
      'targetLocation': _targetLocation != null 
          ? {'lat': _targetLocation!.latitude, 'lng': _targetLocation!.longitude}
          : null,
      'plannedDate': _plannedDate!.toIso8601String(),
      'isAuspiciousDay': isAuspicious,
      'lunarDate': lunarInfo,
      'solarTerm': solarTerm,
      'reason': _selectedReason ?? '기타',
      'housingType': _selectedType ?? '아파트',
      'urgencyLevel': _urgencyLevel ?? '보통 (1-3개월)',
      'luckyScore': _luckyScores[_plannedDate] ?? 0.5,
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _EnhancedMovingFortuneResult extends ConsumerWidget {
  final FortuneResult result;
  final VoidCallback onShare;

  const _EnhancedMovingFortuneResult({
    required this.result,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Convert FortuneResult to enhanced format
    final enhancedData = _convertToEnhancedFormat(result);
    
    return EnhancedMovingResult(
      fortuneData: enhancedData,
      selectedDate: result.additionalInfo?['plannedDate'],
      fromAddress: result.additionalInfo?['currentAddress'],
      toAddress: result.additionalInfo?['targetAddress'],
    );
  }

  Map<String, dynamic> _convertToEnhancedFormat(FortuneResult result) {
    // Extract and enhance the fortune data
    final additionalInfo = result.additionalInfo ?? {};
    
    return {
      'overallScore': result.overallScore ?? 75,
      'auspiciousDirections': additionalInfo['auspiciousDirections'] ?? ['동쪽', '남쪽'],
      'avoidDirections': additionalInfo['avoidDirections'] ?? ['서쪽'],
      'primaryDirection': additionalInfo['bestDirection']?['direction'],
      'areaAnalysis': {
        'scores': {
          '교통': 85,
          '교육': 75,
          '편의시설': 80,
          '의료': 70,
          '발전성': 90,
        },
        'transportation': additionalInfo['areaAnalysis']?['transportation'] ?? 
            '대중교통이 편리하고 접근성이 좋습니다.',
        'education': additionalInfo['areaAnalysis']?['education'] ?? 
            '주변에 좋은 학군이 형성되어 있습니다.',
        'convenience': additionalInfo['areaAnalysis']?['convenience'] ?? 
            '생활 편의시설이 잘 갖춰져 있습니다.',
        'medical': additionalInfo['areaAnalysis']?['medical'] ?? 
            '의료 시설 접근성이 양호합니다.',
        'development': additionalInfo['areaAnalysis']?['development'] ?? 
            '향후 발전 가능성이 높은 지역입니다.',
      },
      'dateAnalysis': {
        'isAuspicious': additionalInfo['isAuspiciousDay'] ?? false,
        'lunarDate': additionalInfo['lunarDate']?['lunarMonthInChinese'] != null
            ? '${additionalInfo['lunarDate']['lunarMonthInChinese']}월 ${additionalInfo['lunarDate']['lunarDayInChinese']}'
            : null,
        'solarTerm': additionalInfo['solarTerm'],
        'fiveElements': additionalInfo['lunarDate']?['dayGanZhi'],
      },
      'detailedScores': result.scoreBreakdown ?? {
        '날짜 길흉': 85,
        '방위 조화': 75,
        '지역 적합성': 90,
        '가족 운': 80,
        '재물 운': 70,
      },
      'recommendations': result.recommendations ?? [],
      'cautions': additionalInfo['cautions'] ?? [],
    };
  }
}