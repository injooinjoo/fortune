import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:fortune/shared/components/app_header.dart' show FontSize;
import '../../../../shared/components/toss_button.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../widgets/enhanced_date_picker.dart';
import '../widgets/map_location_picker.dart';
import '../widgets/enhanced_moving_result.dart';
import '../../../../core/utils/auspicious_days_calculator.dart';
import '../../../../core/theme/toss_design_system.dart';

class MovingFortunePage extends ConsumerWidget {
  const MovingFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '이사 운세',
      fortuneType: 'moving',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)]),
      inputBuilder: (context, onSubmit) => _MovingInputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, onShare) => _MovingFortuneResult(
        result: result,
        onShare: onShare));
  }
}

class _MovingInputForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _MovingInputForm({required this.onSubmit});

  @override
  State<_MovingInputForm> createState() => _MovingInputFormState();
}

class _MovingInputFormState extends State<_MovingInputForm> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _currentAddressController = TextEditingController();
  DateTime? _birthDate;
  DateTime? _plannedDate;
  String? _selectedReason;
  String? _selectedType;
  String? _urgencyLevel;
  bool _showAdvanced = false;
  
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
    '매우 급하게 (2주 이내)'
  ];

  @override
  void initState() {
    super.initState();
    _calculateAuspiciousDays();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentAddressController.dispose();
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
        targetMonth.month
      );
      _auspiciousDays.addAll(auspiciousDaysInMonth);
      
      // Calculate lucky scores for each day
      final lastDay = DateTime(targetMonth.year, targetMonth.month + 1, 0);
      for (var day = targetMonth; 
           day.isBefore(lastDay.add(const Duration(days: 1))); 
           day = day.add(const Duration(days: 1))) {
        _luckyScores[day] = AuspiciousDaysCalculator.getMovingLuckScore(
          day, 
          _birthDate?.toIso8601String());
      }
    }
    
    if (mounted) setState(() {});
  }

  Future<void> _selectDate(bool isPlannedDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isPlannedDate 
          ? (_plannedDate ?? DateTime.now().add(const Duration(days: 30)))
          : (_birthDate ?? DateTime(1990, 1, 1)),
      firstDate: isPlannedDate ? DateTime.now() : DateTime(1900),
      lastDate: isPlannedDate 
          ? DateTime.now().add(const Duration(days: 365))
          : DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF3A7BD5),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isPlannedDate) {
          _plannedDate = picked;
        } else {
          _birthDate = picked;
          _calculateAuspiciousDays(); // Recalculate with birth date
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '이사를 계획 중이신가요?\n최적의 이사 시기와 방향을 알려드립니다.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha:0.8),
            height: 1.5)),
        const SizedBox(height: 16),
        
        // 상세 설정 토글
        Row(
          children: [
            Icon(
              _showAdvanced ? Icons.expand_less : Icons.expand_more,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _showAdvanced = !_showAdvanced;
                });
              },
              child: Text(
                _showAdvanced ? '간단 입력으로 변경' : '상세 설정',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
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
              borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha:0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha:0.3)),
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
          onTap: () => _selectDate(false),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline.withValues(alpha:0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: theme.colorScheme.primary.withValues(alpha:0.7)),
                const SizedBox(width: 12),
                Text(
                  _birthDate != null
                      ? '${_birthDate!.year}년 ${_birthDate!.month}월 ${_birthDate!.day}일'
                      : '생년월일을 선택하세요',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: _birthDate != null 
                        ? theme.colorScheme.onSurface 
                        : theme.colorScheme.onSurface.withValues(alpha:0.5)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Current Address
        Text(
          _showAdvanced ? '현재 거주지' : '현재 거주지 (시/구 단위)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (_showAdvanced) ...[
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline.withValues(alpha:0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: MapLocationPicker(
                onLocationSelected: (location, address) {
                  setState(() {
                    _currentLocation = location;
                    _currentAddress = address;
                    _currentAddressController.text = address;
                  });
                },
                initialLocation: _currentLocation,
                initialAddress: _currentAddress,
              ),
            ),
          ),
        ] else ...[
          TextField(
            controller: _currentAddressController,
            onChanged: (value) {
              _currentAddress = value;
            },
            decoration: InputDecoration(
              hintText: '예: 서울시 강남구',
              prefixIcon: const Icon(Icons.home_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha:0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha:0.3)),
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        
        // Target Address (only in advanced mode)
        if (_showAdvanced) ...[
          Text(
            '이사 희망 지역',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline.withValues(alpha:0.3)),
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
                auspiciousDirections: const ['동쪽', '남동쪽'],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        // Planned Moving Date
        Text(
          _showAdvanced ? '이사 날짜 선택 (손없는날 표시)' : '예상 이사 시기',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (_showAdvanced) ...[
          Text(
            '손없는날과 길일을 확인하여 최적의 이사 날짜를 선택하세요.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha:0.7),
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
            holidayMap: {},
          ),
        ] else ...[
          InkWell(
            onTap: () => _selectDate(true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha:0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.event, color: theme.colorScheme.primary.withValues(alpha:0.7)),
                  const SizedBox(width: 12),
                  Text(
                    _plannedDate != null
                        ? '${_plannedDate!.year}년 ${_plannedDate!.month}월 ${_plannedDate!.day}일'
                        : '예상 이사 날짜를 선택하세요',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _plannedDate != null 
                          ? theme.colorScheme.onSurface 
                          : theme.colorScheme.onSurface.withValues(alpha:0.5)),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        // Moving Reason Selection
        Text(
          '이사 이유',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
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
              selectedColor: theme.colorScheme.primary.withValues(alpha:0.2),
              labelStyle: TextStyle(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface));
          }).toList(),
          ),
          const SizedBox(height: 20),
        // Housing Type Selection
        Text(
          '희망 주거 형태',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
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
              selectedColor: theme.colorScheme.primary.withValues(alpha:0.2),
              labelStyle: TextStyle(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        
        // Urgency Level (only in advanced mode)
        if (_showAdvanced) ...[
          Text(
            '이사 시급성',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold)),
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
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
        
        const SizedBox(height: 32),
        // Submit Button
        SizedBox(
          width: double.infinity,
          child: TossButton(
            text: '이사 운세 확인하기',
            onPressed: () {
              if (_nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('이름을 입력해주세요')),
                );
                return;
              }
              if (_birthDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('생년월일을 선택해주세요')),
                );
                return;
              }
              if (_currentAddress.isEmpty && _currentAddressController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('현재 거주지를 입력해주세요')),
                );
                return;
              }
              
              final currentAddr = _currentAddress.isNotEmpty ? _currentAddress : _currentAddressController.text;
              final isAuspicious = _plannedDate != null ? AuspiciousDaysCalculator.isAuspiciousDay(_plannedDate!) : false;
              final lunarInfo = _plannedDate != null ? AuspiciousDaysCalculator.getLunarDateInfo(_plannedDate!) : null;
              final solarTerm = _plannedDate != null ? AuspiciousDaysCalculator.getSolarTerm(_plannedDate!) : null;
              
              widget.onSubmit({
                'name': _nameController.text,
                'birthDate': _birthDate!.toIso8601String(),
                'currentAddress': currentAddr,
                'currentLocation': _currentLocation != null
                    ? {'lat': _currentLocation!.latitude, 'lng': _currentLocation!.longitude}
                    : null,
                'targetAddress': _targetAddress,
                'targetLocation': _targetLocation != null 
                    ? {'lat': _targetLocation!.latitude, 'lng': _targetLocation!.longitude}
                    : null,
                'plannedDate': _plannedDate?.toIso8601String() ?? '',
                'isAuspiciousDay': isAuspicious,
                'lunarDate': lunarInfo,
                'solarTerm': solarTerm,
                'reason': _selectedReason ?? '기타',
                'housingType': _selectedType ?? '아파트',
                'urgencyLevel': _urgencyLevel ?? '보통 (1-3개월)',
                'luckyScore': _plannedDate != null ? _luckyScores[_plannedDate] : null,
                'isAdvancedMode': _showAdvanced,
              });
            },
            style: TossButtonStyle.primary,
            size: TossButtonSize.large,
          ),
        ),
      ],
    );
  }
}

class _MovingFortuneResult extends ConsumerWidget {
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

  const _MovingFortuneResult({
    required this.result,
    required this.onShare});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fontSizeEnum = ref.watch(fontSizeProvider);
    final fontSize = _getFontSizeOffset(fontSizeEnum);
    
    // Check if this was an advanced mode request
    final isAdvancedMode = result.additionalInfo?['isAdvancedMode'] ?? false;
    
    // Extract moving fortune data from result
    final bestDirection = result.additionalInfo?['bestDirection'] ?? {};
    final bestTiming = result.additionalInfo?['bestTiming'] ?? {};
    final avoidDirection = result.additionalInfo?['avoidDirection'] ?? {};
    final movingTips = result.recommendations ?? [];
    final compatibility = result.scoreBreakdown ?? {};
    
    // Enhanced data for advanced mode
    final areaAnalysis = result.additionalInfo?['areaAnalysis'];
    final dateAnalysis = result.additionalInfo?['dateAnalysis'];
    final detailedScores = result.additionalInfo?['detailedScores'];
    final isAuspiciousDay = result.additionalInfo?['isAuspiciousDay'] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Best Direction Card
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
                        color: theme.colorScheme.primary.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                        Icons.explore,
                        color: theme.colorScheme.primary,
                        size: 28)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '최적의 이사 방향',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            bestDirection['direction'] ?? '동쪽',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 20 + fontSize)),
                        ],
                      ),
                    ),
                  ],
                ),
                if (bestDirection['description'] != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    bestDirection['description'],
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      fontSize: 14 + fontSize))],
                if (bestDirection['areas'] != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    '지역: ${bestDirection['areas']}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w600)),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Best Timing Card
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
                      color: TossDesignSystem.success,
                      size: 24),
                    const SizedBox(width: 12),
                    Text(
                      '최적의 이사 시기',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold))]),
                const SizedBox(height: 16),
                Text(
                  bestTiming['period'] ?? '다음 달',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16 + fontSize)),
                if (bestTiming['reason'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    bestTiming['reason'],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                      fontSize: 14 + fontSize)),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Compatibility Scores
        if (compatibility.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        color: TossDesignSystem.tossBlue,
                        size: 24),
                      const SizedBox(width: 12),
                      Text(
                        '이사 운세 분석',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 16),
                  ...compatibility.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 14 + fontSize),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 100,
                              child: LinearProgressIndicator(
                                value: entry.value / 100,
                                backgroundColor: theme.colorScheme.primary.withValues(alpha:0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getScoreColor(entry.value)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${entry.value}점',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getScoreColor(entry.value)),
                            ),
                          ],
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
        
        // Moving Tips
        if (movingTips.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates_outlined,
                        color: TossDesignSystem.warningOrange,
                        size: 24),
                      const SizedBox(width: 12),
                      Text(
                        '이사 준비 팁',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 16),
                  ...movingTips.map((tip) => Padding(
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
                            shape: BoxShape.circle)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tip,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.5,
                              fontSize: 14 + fontSize),
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
        
        // Direction to Avoid
        if (avoidDirection.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_outlined,
                        color: TossDesignSystem.warningOrange,
                        size: 24),
                      const SizedBox(width: 12),
                      Text(
                        '피해야 할 방향',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    avoidDirection['direction'] ?? '',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14 + fontSize),
                  ),
                  if (avoidDirection['reason'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      avoidDirection['reason'],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                        fontSize: 12 + fontSize),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
        
        // Advanced Mode Additional Information
        if (isAdvancedMode) ...[
          // Date Analysis Card
          if (dateAnalysis != null || isAuspiciousDay) ...[
            const SizedBox(height: 20),
            GlassContainer(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isAuspiciousDay ? Icons.calendar_today : Icons.event_busy,
                          color: isAuspiciousDay ? TossDesignSystem.success : TossDesignSystem.warningOrange,
                          size: 24),
                        const SizedBox(width: 12),
                        Text(
                          '날짜 분석',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isAuspiciousDay ? TossDesignSystem.success.withValues(alpha:0.1) : TossDesignSystem.warningOrange.withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            isAuspiciousDay ? '손없는날 ✓' : '일반날짜',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isAuspiciousDay ? TossDesignSystem.success : TossDesignSystem.warningOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (dateAnalysis?['lunarDate'] != null)
                          Text(
                            '음력: ${dateAnalysis['lunarDate']}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                            ),
                          ),
                      ],
                    ),
                    if (dateAnalysis?['solarTerm'] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '절기: ${dateAnalysis['solarTerm']}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          
          // Area Analysis Card (if target location was selected)
          if (areaAnalysis != null) ...[
            const SizedBox(height: 20),
            GlassContainer(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_city,
                          color: TossDesignSystem.tossBlue,
                          size: 24),
                        const SizedBox(width: 12),
                        Text(
                          '지역 분석',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (areaAnalysis['scores'] != null) ...[
                      ...areaAnalysis['scores'].entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 14 + fontSize,
                              ),
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: LinearProgressIndicator(
                                    value: entry.value / 100,
                                    backgroundColor: theme.colorScheme.primary.withValues(alpha:0.1),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _getScoreColor(entry.value)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${entry.value}점',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _getScoreColor(entry.value)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )).toList(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
        
        const SizedBox(height: 20),
        
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
  
  Color _getScoreColor(int score) {
    if (score >= 80) return TossDesignSystem.success;
    if (score >= 60) return TossDesignSystem.tossBlue;
    if (score >= 40) return TossDesignSystem.warningOrange;
    return TossDesignSystem.error;
  }
}