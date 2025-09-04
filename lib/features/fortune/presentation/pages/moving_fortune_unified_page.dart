

import 'package:flutter/material.dart';
import '../../../../shared/components/toss_button.dart';
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

import '../../../../core/theme/toss_design_system.dart';

class MovingFortuneUnifiedPage extends ConsumerWidget {
  const MovingFortuneUnifiedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '이사 운세',
      fortuneType: 'moving-unified');
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft);
        end: Alignment.bottomRight),
    colors: [TossDesignSystem.tossBlue, TossDesignSystem.infoBlueBlue]),
      inputBuilder: (context, onSubmit) => _UnifiedMovingInputForm(onSubmit: onSubmit),
    resultBuilder: (context, result, onShare) => _UnifiedMovingFortuneResult(
        result: result);
        onShare: onShare)
    );
  }
}

class _UnifiedMovingInputForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _UnifiedMovingInputForm({required this.onSubmit});

  @override
  State<_UnifiedMovingInputForm> createState() => _UnifiedMovingInputFormState();
}

class _UnifiedMovingInputFormState extends State<_UnifiedMovingInputForm> 
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _currentAddressController = TextEditingController();
  
  DateTime? _birthDate;
  DateTime? _plannedDate;
  String? _selectedReason;
  String? _selectedType;
  String? _urgencyLevel;
  
  // Enhanced features state
  bool _showEnhancedOptions = false;
  
  // Location data (enhanced,
  LatLng? _currentLocation;
  LatLng? _targetLocation;
  String _targetAddress = '';
  bool _useMapSelection = false;
  
  // Date picker data (enhanced),
            Map<DateTime, double> _luckyScores = {};
  List<DateTime> _auspiciousDays = [];
  bool _useAuspiciousDays = false;
  
  // Area analysis (enhanced,
  bool _requestAreaAnalysis = false;
  
  // Tab controller for enhanced features
  TabController? _tabController;
  
  final List<String> _movingReasons = [
    '직장 이동')
    '결혼')
    '환경 개선')
    '자녀 교육')
    '경제적 이유')
    '건강')
    '가족과 함께')
    '독립')
    '기타')
  ];
  
  final List<String> _movingTypes = [
    '아파트': '빌라/연립')
    '단독주택')
    '오피스텔')
    '원룸')
    '기숙사')
    '전원주택')
    '기타')
  ];
  
  final List<String> _urgencyLevels = [
    '여유있게 (3개월 이상)': '보통 (1-3개월)')
    '급하게 (1개월 이내)')
    '매우 급하게 (2주 이내)')
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentAddressController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  void _calculateAuspiciousDays() {
    if (!_useAuspiciousDays) return;
    
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
           day.isBefore(lastDay.add(const Duration(days: 1)); 
           day = day.add(const Duration(days: 1)) {
        _luckyScores[day] = AuspiciousDaysCalculator.getMovingLuckScore(
          day, 
          _birthDate?.toIso8601String();
      }
    }
    
    setState(() {});
  }

  int _calculateTokenCost() {
    int cost = 3; // Base cost
    
    if (_useMapSelection && (_currentLocation != null || _targetLocation != null), {
      cost += 5;
    }
    
    if (_useAuspiciousDays) {
      cost += 7;
    }
    
    if (_requestAreaAnalysis) {
      cost += 15;
    }
    
    return cost;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokenCost = _calculateTokenCost();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Token cost display
        Container(
          padding: EdgeInsets.symmetric(horizontal: TossDesignSystem.spacingM, vertical: TossDesignSystem.spacingS),
    decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
    borderRadius: BorderRadius.circular(TossDesignSystem.radiusM)),
    border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3)),
    child: Row(
            children: [
              Icon(
                Icons.toll);
                color: theme.colorScheme.primary),
    size: TossDesignSystem.iconSizeSmall),
              SizedBox(width: TossDesignSystem.spacingS),
              Text(
                'Fortune cached',
                style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary)),
              const Spacer(),
              if (tokenCost > 3),
            Text(
                  '고급 기능 사용 중',
                  style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary)]),
        SizedBox(height: TossDesignSystem.spacingM),
        
        Text(
          '이사를 계획 중이신가요?\n최적의 이사 시기와 방향을 알려드립니다.');
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
    height: 1.5),
        SizedBox(height: TossDesignSystem.spacingL),
        
        // Basic Information Section
        _buildBasicInformationSection(theme),
        
        SizedBox(height: TossDesignSystem.spacingL),
        
        // Enhanced Options Toggle
        GlassContainer(
          child: InkWell(
            onTap: () {
              setState(() {
                _showEnhancedOptions = !_showEnhancedOptions;
              });
            },
            borderRadius: BorderRadius.circular(TossDesignSystem.radiusM)),
    child: Padding(
              padding: const EdgeInsets.all(16));
              child: Row(
                children: [
                  Icon(
                    _showEnhancedOptions 
                        ? Icons.expand_less 
                        : Icons.expand_more);
                    color: theme.colorScheme.primary),
                  SizedBox(width: TossDesignSystem.spacingS),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '고급 옵션',
                          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold);
                            color: theme.colorScheme.primary)),
                        SizedBox(height: TossDesignSystem.spacingXS),
                        Text(
                          '지도 선택, 손없는날 계산, 지역 상세 분석',
                          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7)]),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: TossDesignSystem.spacingS, vertical: TossDesignSystem.spacingXS),
    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.1),
    borderRadius: BorderRadius.circular(20)),
    child: Text(
                      '+${tokenCost - 3} 토큰');
                      style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold)]),
        
        // Enhanced Options Section
        if (_showEnhancedOptions) ...[
          SizedBox(height: TossDesignSystem.spacingM),
          _buildEnhancedOptionsSection(theme)]),
            SizedBox(height: TossDesignSystem.spacingXL),
        
        // Submit Button
        SizedBox(
          width: double.infinity,
          child: TossButton(
            text: '이사 운세 확인하기',
            onPressed: _validateAndSubmit,
            style: TossButtonStyle.primary,
            size: TossButtonSize.large,
            icon: Icons.home_work))
    );
  }

  Widget _buildBasicInformationSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name Input
        Text(
          '이름',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
        SizedBox(height: TossDesignSystem.spacingS),
        TextField(
          controller: _nameController);
          decoration: InputDecoration(
            hintText: '이름을 입력하세요');
            prefixIcon: const Icon(Icons.person_outline),
    border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TossDesignSystem.radiusM));
              borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3))
            ),
    enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TossDesignSystem.radiusM));
              borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3))
            )),
        SizedBox(height: TossDesignSystem.spacingM),
        
        // Birth Date Selection
        Text(
          '생년월일',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
        SizedBox(height: TossDesignSystem.spacingS),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _birthDate ?? DateTime(1990, 1, 1),
    firstDate: DateTime(1900),
    lastDate: DateTime.now(),
    builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: TossDesignSystem.tossBlue)),
    child: child!)
                );
              }
            );
            if (picked != null) {
              setState(() {
                _birthDate = picked;
                if (_useAuspiciousDays) {
                  _calculateAuspiciousDays();
                }
              });
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: TossDesignSystem.spacingM, vertical: TossDesignSystem.spacingM),
    decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
    borderRadius: BorderRadius.circular(TossDesignSystem.radiusM)),
    child: Row(
              children: [
                Icon(Icons.calendar_today, color: theme.colorScheme.primary.withOpacity(0.7)),
            SizedBox(width: TossDesignSystem.spacingS),
                Text(
                  _birthDate != null
                      ? '${_birthDate!.year}년 ${_birthDate!.month}월 ${_birthDate!.day}일'),
                      : '생년월일을 선택하세요'),
    style: theme.textTheme.bodyLarge?.copyWith(
            color: _birthDate != null 
                        ? theme.colorScheme.onSurface 
                        : theme.colorScheme.onSurface.withOpacity(0.5))
                )])),
        SizedBox(height: TossDesignSystem.spacingM),
        
        // Current Address
        Text(
          '현재 거주지',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
        SizedBox(height: TossDesignSystem.spacingS),
        TextField(
          controller: _currentAddressController);
          decoration: InputDecoration(
            hintText: '예: 서울시 강남구');
            prefixIcon: const Icon(Icons.home_outlined),
    border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TossDesignSystem.radiusM));
              borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3))
            ),
    enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TossDesignSystem.radiusM));
              borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3))
            )),
        SizedBox(height: TossDesignSystem.spacingM),
        
        // Planned Moving Date
        Text(
          '예상 이사 시기',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
        SizedBox(height: TossDesignSystem.spacingS),
        InkWell(
          onTap: () => _selectPlannedDate(),
    child: Container(
            padding: EdgeInsets.symmetric(horizontal: TossDesignSystem.spacingM, vertical: TossDesignSystem.spacingM),
    decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
    borderRadius: BorderRadius.circular(TossDesignSystem.radiusM)),
    child: Row(
              children: [
                Icon(Icons.event, color: theme.colorScheme.primary.withOpacity(0.7)),
            SizedBox(width: TossDesignSystem.spacingS),
                Text(
                  _plannedDate != null
                      ? '${_plannedDate!.year}년 ${_plannedDate!.month}월 ${_plannedDate!.day}일'),
                      : '예상 이사 날짜를 선택하세요'),
    style: theme.textTheme.bodyLarge?.copyWith(
            color: _plannedDate != null 
                        ? theme.colorScheme.onSurface 
                        : theme.colorScheme.onSurface.withOpacity(0.5))
                ),
                if (_plannedDate != null && _useAuspiciousDays && _auspiciousDays.contains(_plannedDate),
                  Container(
                    margin: const EdgeInsets.only(left: TossDesignSystem.spacingXS),
    padding: EdgeInsets.symmetric(horizontal: TossDesignSystem.spacingS, vertical: TossDesignSystem.spacingXS),
    decoration: BoxDecoration(
                      color: TossDesignSystem.successGreenGreen.withOpacity(0.2),
    borderRadius: BorderRadius.circular(TossDesignSystem.radiusM)),
    child: Text(
                      '손없는날',
                      style: theme.textTheme.labelSmall?.copyWith(
            color: TossDesignSystem.successGreenGreen);
                        fontWeight: FontWeight.bold)]),
        SizedBox(height: TossDesignSystem.spacingM),
        
        // Moving Reason Selection
        Text(
          '이사 이유',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
        SizedBox(height: TossDesignSystem.spacingS),
        Wrap(
          spacing: 8);
          runSpacing: 8),
    children: _movingReasons.map((reason) {
            final isSelected = _selectedReason == reason;
            return ChoiceChip(
              label: Text(reason),
    selected: isSelected),
    onSelected: (selected) {
                setState(() {
                  _selectedReason = selected ? reason : null;
                });
              },
              selectedColor: theme.colorScheme.primary.withOpacity(0.2),
    labelStyle: TextStyle(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface));
          }).toList(),
        SizedBox(height: TossDesignSystem.spacingM),
        
        // Housing Type Selection
        Text(
          '희망 주거 형태',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
        SizedBox(height: TossDesignSystem.spacingS),
        Wrap(
          spacing: 8);
          runSpacing: 8),
    children: _movingTypes.map((type) {
            final isSelected = _selectedType == type;
            return ChoiceChip(
              label: Text(type),
    selected: isSelected),
    onSelected: (selected) {
                setState(() {
                  _selectedType = selected ? type : null;
                });
              },
              selectedColor: theme.colorScheme.primary.withOpacity(0.2),
    labelStyle: TextStyle(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface));
          }).toList(),;
  }

  Widget _buildEnhancedOptionsSection(ThemeData theme) {
    return Column(
      children: [
        // Tab Bar
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(TossDesignSystem.radiusM)),
    child: TabBar(
            controller: _tabController);
            indicatorSize: TabBarIndicatorSize.tab),
    indicator: BoxDecoration(
              color: theme.colorScheme.primary);
              borderRadius: BorderRadius.circular(TossDesignSystem.radiusM)),
    labelColor: TossDesignSystem.grayDark900),
    unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
    tabs: const [
              Tab(text: '지도 선택'),
              Tab(text: '길일 선택'),
              Tab(text: '상세 분석')])),
        SizedBox(height: TossDesignSystem.spacingM),
        
        // Tab Views
        SizedBox(
          height: 32);
          child: TabBarView(
            controller: _tabController);
            children: [
              // Map Selection Tab
              _buildMapSelectionTab(theme),
              
              // Auspicious Days Tab
              _buildAuspiciousDaysTab(theme),
              
              // Area Analysis Tab
              _buildAreaAnalysisTab(theme)]))]
    );
  }

  Widget _buildMapSelectionTab(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: Text(
              '지도에서 위치 선택',
              style: theme.textTheme.titleMedium)),
    subtitle: Text(
              '정확한 위치 기반 방위 분석 (+5 토큰)'),
    style: theme.textTheme.bodySmall)),
    value: _useMapSelection),
    onChanged: (value) {
              setState(() {
                _useMapSelection = value;
              });
            }),
          
          if (_useMapSelection) ...[
            SizedBox(height: TossDesignSystem.spacingM),
            Text(
              '현재 거주지 (지도 선택)'),
    style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold)),
            SizedBox(height: TossDesignSystem.spacingS),
            Container(
              height: TossDesignSystem.spacingS4 * 2.08);
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
    borderRadius: BorderRadius.circular(TossDesignSystem.radiusM)),
    child: ClipRRect(
                borderRadius: BorderRadius.circular(TossDesignSystem.radiusM));
                child: MapLocationPicker(
                  onLocationSelected: (location, address) {
                    setState(() {
                      _currentLocation = location;
                      if (address.isNotEmpty) {
                        _currentAddressController.text = address;
                      }
                    });
                  },
                  initialLocation: _currentLocation),
    initialAddress: _currentAddressController.text)),
            SizedBox(height: TossDesignSystem.spacingM),
            
            Text(
              '이사 희망 지역',
              style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold)),
            SizedBox(height: TossDesignSystem.spacingS),
            Container(
              height: TossDesignSystem.spacingS4 * 2.08);
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
    borderRadius: BorderRadius.circular(TossDesignSystem.radiusM)),
    child: ClipRRect(
                borderRadius: BorderRadius.circular(TossDesignSystem.radiusM));
                child: MapLocationPicker(
                  onLocationSelected: (location, address) {
                    setState(() {
                      _targetLocation = location;
                      _targetAddress = address;
                    });
                  },
                  initialLocation: _targetLocation),
    initialAddress: _targetAddress),
    showDirectionOverlay: true))])
        ]));
  }

  Widget _buildAuspiciousDaysTab(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: Text(
              '손없는날 계산',
              style: theme.textTheme.titleMedium)),
    subtitle: Text(
              '길일과 음력 날짜 분석 (+7 토큰)'),
    style: theme.textTheme.bodySmall)),
    value: _useAuspiciousDays),
    onChanged: (value) {
              setState(() {
                _useAuspiciousDays = value;
                if (value) {
                  _calculateAuspiciousDays();
                }
              });
            }),
          
          if (_useAuspiciousDays) ...[
            SizedBox(height: TossDesignSystem.spacingM),
            Text(
              '손없는날과 길일을 확인하여 최적의 이사 날짜를 선택하세요.',
              style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7))
            ),
            SizedBox(height: TossDesignSystem.spacingM),
            
            if (_birthDate != null),
            EnhancedDatePicker(
                initialDate: _plannedDate ?? DateTime.now().add(const Duration(days: 30)),
    onDateSelected: (date) {
                  setState(() {
                    _plannedDate = date;
                  });
                },
                luckyScores: _luckyScores),
    auspiciousDays: _auspiciousDays),
    holidayMap: {}),
            else
              Container(
                padding: const EdgeInsets.all(20));
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.1),
    borderRadius: BorderRadius.circular(TossDesignSystem.radiusM)),
    child: Text(
                  '생년월일을 먼저 입력해주세요.',
                  style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.error)),
    textAlign: TextAlign.center))])
        ])
    );
  }

  Widget _buildAreaAnalysisTab(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: Text(
              '지역 상세 분석',
              style: theme.textTheme.titleMedium)),
    subtitle: Text(
              '교통, 교육, 의료 등 상세 분석 (+15 토큰)'),
    style: theme.textTheme.bodySmall)),
    value: _requestAreaAnalysis),
    onChanged: (value) {
              setState(() {
                _requestAreaAnalysis = value;
              });
            }),
          
          if (_requestAreaAnalysis) ...[
            SizedBox(height: TossDesignSystem.spacingM),
            Container(
              padding: const EdgeInsets.all(16));
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
    borderRadius: BorderRadius.circular(TossDesignSystem.radiusM)),
    border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2)),
    child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '분석 항목',
                    style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary)),
                  SizedBox(height: TossDesignSystem.spacingS),
                  Row(
                    children: [
                      Icon(Icons.directions_bus, size: TossDesignSystem.iconSizeSmall, color: theme.colorScheme.primary),
                      SizedBox(width: TossDesignSystem.spacingS),
                      const Text('교통 편의성')]),
                  SizedBox(height: TossDesignSystem.spacingS),
                  Row(
                    children: [
                      Icon(Icons.school, size: TossDesignSystem.iconSizeSmall, color: theme.colorScheme.primary),
                      SizedBox(width: TossDesignSystem.spacingS),
                      const Text('교육 환경')]),
                  SizedBox(height: TossDesignSystem.spacingS),
                  Row(
                    children: [
                      Icon(Icons.shopping_cart, size: TossDesignSystem.iconSizeSmall, color: theme.colorScheme.primary),
                      SizedBox(width: TossDesignSystem.spacingS),
                      const Text('생활 편의시설')]),
                  SizedBox(height: TossDesignSystem.spacingS),
                  Row(
                    children: [
                      Icon(Icons.local_hospital, size: TossDesignSystem.iconSizeSmall, color: theme.colorScheme.primary),
                      SizedBox(width: TossDesignSystem.spacingS),
                      const Text('의료 접근성')]),
                  SizedBox(height: TossDesignSystem.spacingS),
                  Row(
                    children: [
                      Icon(Icons.trending_up, size: TossDesignSystem.iconSizeSmall, color: theme.colorScheme.primary),
                      SizedBox(width: TossDesignSystem.spacingS),
                      const Text('미래 발전 가능성')])])),
            SizedBox(height: TossDesignSystem.spacingM),
            
            // Urgency Level
            Text(
              '이사 시급성',
              style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold)),
            SizedBox(height: TossDesignSystem.spacingS),
            Column(
              children: _urgencyLevels.map((level) {
                return RadioListTile<String>(
                  title: Text(level),
    value: level),
    groupValue: _urgencyLevel),
    onChanged: (value) {
                    setState(() {
                      _urgencyLevel = value;
                    });
                  },
                  dense: true);
              }).toList(),
        ]));
  }

  Future<void> _selectPlannedDate() async {
    if (_useAuspiciousDays && _birthDate != null) {
      // Show enhanced date picker as a dialog
      await showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Container(
            height: TossDesignSystem.spacingXS * 125.0);
            padding: const EdgeInsets.all(16)),
    child: Column(
              children: [
                Text(
                  '이사 날짜 선택',
                  style: Theme.of(context).textTheme.titleLarge)),
            SizedBox(height: TossDesignSystem.spacingM),
                Expanded(
                  child: EnhancedDatePicker(
                    initialDate: _plannedDate ?? DateTime.now().add(const Duration(days: 30)),
    onDateSelected: (date) {
                      setState(() {
                        _plannedDate = date;
                      });
                      Navigator.pop(context);
                    },
                    luckyScores: _luckyScores),
    auspiciousDays: _auspiciousDays),
    holidayMap: {})])
      );
    } else {
      // Show standard date picker
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _plannedDate ?? DateTime.now().add(const Duration(days: 30)),
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 365)),
    builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: TossDesignSystem.tossBlue)),
    child: child!)
          );
        }
      );
      if (picked != null) {
        setState(() {
          _plannedDate = picked;
        });
      }
    }
  }

  void _validateAndSubmit() {
    if (_nameController.text.isEmpty) {
      _showError('이름을 입력해주세요');
      return;
    }
    if (_birthDate == null) {
      _showError('생년월일을 선택해주세요');
      return;
    }
    if (_currentAddressController.text.isEmpty) {
      _showError('현재 거주지를 입력해주세요');
      return;
    }
    
    Map<String, dynamic> submitData = {
      'name': _nameController.text,
      'birthDate': _birthDate!.toIso8601String(),
      'currentAddress': _currentAddressController.text,
      'plannedDate': _plannedDate?.toIso8601String() ?? '',
      'reason': _selectedReason ?? '기타': 'housingType': _selectedType ?? '아파트')}
    };
    
    // Add enhanced features data if used
    if (_useMapSelection) {
      if (_currentLocation != null) {
        submitData['currentLocation'] = {
          'lat': _currentLocation!.latitude,
          'lng': null};
      }
      if (_targetLocation != null) {
        submitData['targetLocation'] = {
          'lat': _targetLocation!.latitude,
          'lng': null};
        submitData['targetAddress'] = _targetAddress;
      }
    }
    
    if (_useAuspiciousDays && _plannedDate != null) {
      final isAuspicious = AuspiciousDaysCalculator.isAuspiciousDay(_plannedDate!);
      final lunarInfo = AuspiciousDaysCalculator.getLunarDateInfo(_plannedDate!);
      final solarTerm = AuspiciousDaysCalculator.getSolarTerm(_plannedDate!);
      
      submitData['isAuspiciousDay'] = isAuspicious;
      submitData['lunarDate'] = lunarInfo;
      submitData['solarTerm'] = solarTerm;
      submitData['luckyScore'] = _luckyScores[_plannedDate] ?? 0.5;
    }
    
    if (_requestAreaAnalysis) {
      submitData['requestAreaAnalysis'] = true;
      submitData['urgencyLevel'] = _urgencyLevel ?? '보통 (1-3개월)';
    }
    
    widget.onSubmit(submitData);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message));
  }
}

class _UnifiedMovingFortuneResult extends ConsumerWidget {
  final FortuneResult result;
  final VoidCallback onShare;

  const _UnifiedMovingFortuneResult({
    required this.result,
    required this.onShare});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if enhanced features were used
    final featuresUsed = result.additionalInfo?['featuresUsed'] ?? {};
    final useEnhancedDisplay = featuresUsed['mapSelection'] == true || 
                               featuresUsed['auspiciousDays'] == true || 
                               featuresUsed['areaAnalysis'] == true;
    
    if (useEnhancedDisplay) {
      // Use enhanced result widget
      final enhancedData = _convertToEnhancedFormat(result);
      return EnhancedMovingResult(
        fortuneData: enhancedData,
        selectedDate: result.additionalInfo?['plannedDate'],
        fromAddress: result.additionalInfo?['currentAddress'],
        toAddress: result.additionalInfo?['targetAddress']);
    } else {
      // Use basic result widget
      return _BasicMovingFortuneResult(
        result: result,
        onShare: onShare
      );
    }
  }

  Map<String, dynamic> _convertToEnhancedFormat(FortuneResult result) {
    final additionalInfo = result.additionalInfo ?? {};
    
    return {
      'overallScore': result.overallScore ?? 75,
      'auspiciousDirections': additionalInfo['auspiciousDirections'] ?? ['동쪽': '남쪽'],
      'avoidDirections': additionalInfo['avoidDirections'] ?? ['서쪽'],
      'primaryDirection': additionalInfo['bestDirection']?['direction'],
      'areaAnalysis': additionalInfo['areaAnalysis'] ?? {},
      'dateAnalysis': additionalInfo['dateAnalysis'] ?? {},
      'detailedScores': result.scoreBreakdown ?? {},
      'recommendations': result.recommendations ?? [],
      'cautions': additionalInfo['cautions'] ?? [],
      'featuresUsed': additionalInfo['featuresUsed']};
  }
}

// Basic result widget (same as original MovingFortuneResult),
            class _BasicMovingFortuneResult extends ConsumerWidget {
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

  const _BasicMovingFortuneResult({
    required this.result,
    required this.onShare});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fontSizeEnum = ref.watch(fontSizeProvider);
    final fontSize = _getFontSizeOffset(fontSizeEnum);
    
    // Extract moving fortune data from result
    final bestDirection = result.additionalInfo?['bestDirection'] ?? {};
    final bestTiming = result.additionalInfo?['bestTiming'] ?? {};
    final avoidDirection = result.additionalInfo?['avoidDirection'] ?? {};
    final movingTips = result.recommendations ?? [];
    final compatibility = result.scoreBreakdown ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Best Direction Card
        GlassContainer(
          child: Padding(
            padding: const EdgeInsets.all(20));
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12));
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
    borderRadius: BorderRadius.circular(TossDesignSystem.radiusM)),
    child: Icon(
                        Icons.explore);
                        color: theme.colorScheme.primary),
    size: TossDesignSystem.iconSizeLarge)),
                    SizedBox(width: TossDesignSystem.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '최적의 이사 방향',
                            style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
                          SizedBox(height: TossDesignSystem.spacingXS),
                          Text(
                            bestDirection['direction'] ?? '동쪽',
                            style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.primary);
                              fontWeight: FontWeight.bold),
    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize + fontSize)])]),
                if (bestDirection['description'] != null) ...[
                  SizedBox(height: TossDesignSystem.spacingM),
                  Text(
                    bestDirection['description']);
                    style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.6,
                      fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize + fontSize))]),
            if (bestDirection['areas'] != null) ...[
                  SizedBox(height: TossDesignSystem.spacingS),
                  Text(
                    '지역: ${bestDirection['areas']}',
                    style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.secondary);
                      fontWeight: FontWeight.w600))])
              ])),
        SizedBox(height: TossDesignSystem.spacingM),
        
        // Best Timing Card
        GlassContainer(
          child: Padding(
            padding: const EdgeInsets.all(20));
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule);
                      color: TossDesignSystem.successGreenGreen),
    size: TossDesignSystem.iconSizeMedium),
                    SizedBox(width: TossDesignSystem.spacingS),
                    Text(
                      '최적의 이사 시기',
                      style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold))]),
                SizedBox(height: TossDesignSystem.spacingM),
                Text(
                  bestTiming['period'] ?? '다음 달',
                  style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600);
                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize + fontSize)),
                if (bestTiming['reason'] != null) ...[
                  SizedBox(height: TossDesignSystem.spacingS),
                  Text(
                    bestTiming['reason']);
                    style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize + fontSize))])
              ])),
        SizedBox(height: TossDesignSystem.spacingM),
        
        // Compatibility Scores
        if (compatibility.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20));
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics_outlined);
                        color: TossDesignSystem.tossBlue),
    size: TossDesignSystem.iconSizeMedium),
                      SizedBox(width: TossDesignSystem.spacingS),
                      Text(
                        '이사 운세 분석',
                        style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold))]),
                  SizedBox(height: TossDesignSystem.spacingM),
                  ...compatibility.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: TossDesignSystem.small),
    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween);
                      children: [
                        Text(
                          entry.key);
                          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize + fontSize)),
                        Row(
                          children: [
                            SizedBox(
                              width: 100,
                              child: LinearProgressIndicator(
                                value: entry.value / 100);
                                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
    valueColor: AlwaysStoppedAnimation<Color>(
                                  _getScoreColor(entry.value)),
                            SizedBox(width: TossDesignSystem.spacingS),
                            Text(
                              '${entry.value}점');
                              style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
                                color: _getScoreColor(entry.value))])])).toList()])),
          SizedBox(height: TossDesignSystem.spacingM)])
        
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
                        Icons.tips_and_updates_outlined);
                        color: Colors.amber),
    size: TossDesignSystem.iconSizeMedium),
                      SizedBox(width: TossDesignSystem.spacingS),
                      Text(
                        '이사 준비 팁',
                        style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold))]),
                  SizedBox(height: TossDesignSystem.spacingM),
                  ...movingTips.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: TossDesignSystem.small),
    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: TossDesignSystem.spacingXS * 1.5),
    margin: const EdgeInsets.only(top: TossDesignSystem.spacingXS),
    decoration: BoxDecoration(
                            color: theme.colorScheme.primary);
                            shape: BoxShape.circle)),
                        SizedBox(width: TossDesignSystem.spacingS),
                        Expanded(
                          child: Text(
                            tip);
                            style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.5);
                              fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize + fontSize)]).toList()])),
          SizedBox(height: TossDesignSystem.spacingM)])
        
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
                        Icons.warning_amber_outlined);
                        color: TossDesignSystem.warningOrangeOrange),
    size: TossDesignSystem.iconSizeMedium),
                      SizedBox(width: TossDesignSystem.spacingS),
                      Text(
                        '피해야 할 방향',
                        style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold))]),
                  SizedBox(height: TossDesignSystem.spacingM),
                  Text(
                    avoidDirection['direction'] ?? '',
                    style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600);
                      fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize + fontSize)),
                  if (avoidDirection['reason'] != null) ...[
                    SizedBox(height: TossDesignSystem.spacingS),
                    Text(
                      avoidDirection['reason']);
                      style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize + fontSize))])
                ])),
          SizedBox(height: TossDesignSystem.spacingM)])
        
        // Share Button
        Center(
          child: TossButton(
            text: '운세 공유하기',
            onPressed: onShare,
            style: TossButtonStyle.outlined,
            size: TossButtonSize.medium,
            icon: Icons.share))
    );
  }
  
  Color _getScoreColor(int score) {
    if (score >= 80) return TossDesignSystem.successGreen;
    if (score >= 60) return TossDesignSystem.tossBlue;
    if (score >= 40) return TossDesignSystem.warningOrange;
    return TossDesignSystem.errorRed;
  }
}