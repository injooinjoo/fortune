import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../services/saju_calculation_service.dart';
import '../../../../presentation/widgets/saju_chart_widget.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum TraditionalType {
  saju('사주팔자', 'saju', '생년월일시를 기반으로 한 정통 사주 분석'),
  traditionalSaju('전통사주', 'traditional_saju', '고전 명리학 기반의 사주 해석'),
  tojeong('토정비결', 'tojeong', '조선시대 토정 이지함의 운세 비결'),
  salpuli('살풀이', 'salpuli', '각종 살(煞)의 영향과 해결 방법'),
  fiveBlessings('오복', 'five_blessings', '수명, 부귀, 강녕, 유호덕, 고종명의 오복 운세');

  final String label;
  final String value;
  final String description;
  const TraditionalType(this.label, this.value, this.description);
}

class TraditionalFortunePage extends BaseFortunePage {
  final TraditionalType initialType;
  
  const TraditionalFortunePage({
    Key? key,
    this.initialType = TraditionalType.saju,
  }) : super(
          key: key,
          title: '전통 운세',
          description: '동양 철학 기반의 전통 운세를 확인해보세요',
          fortuneType: 'traditional',
          requiresUserInfo: true,
        );

  @override
  ConsumerState<TraditionalFortunePage> createState() => _TraditionalFortunePageState();
}

class _TraditionalFortunePageState extends BaseFortunePageState<TraditionalFortunePage> {
  late TraditionalType _selectedType;
  TimeOfDay? _birthTime;
  bool _isLunarCalendar = false;
  SajuData? _sajuData;
  final SajuCalculationService _sajuService = SajuCalculationService();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final fortuneService = ref.read(fortuneServiceProvider);
    
    // Add traditional-specific parameters
    params['traditionalType'] = _selectedType.value;
    params['isLunarCalendar'] = _isLunarCalendar;
    
    if (_birthTime != null) {
      params['birthHour'] = _birthTime!.hour;
      params['birthMinute'] = _birthTime!.minute;
    }
    
    // Calculate Saju if needed
    if (_selectedType == TraditionalType.saju || 
        _selectedType == TraditionalType.traditionalSaju) {
      final birthDate = DateTime.parse(params['birthDate']);
      _sajuData = await _sajuService.calculateSaju(
        birthDate: birthDate,
        birthHour: _birthTime?.hour ?? 0,
        birthMinute: _birthTime?.minute ?? 0,
        isLunar: _isLunarCalendar,
      );
      
      if (_sajuData != null) {
        params['sajuData'] = _sajuData!.toJson();
      }
    }
    
    final fortune = await fortuneService.getTraditionalFortune(
      userId: params['userId'],
      fortuneType: _selectedType.value,
      params: params,
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
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: TraditionalType.values.map((type) {
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
                      color: _selectedType == type 
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedType == type 
                            ? AppColors.primary
                            : AppColors.border,
                        width: _selectedType == type ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getIconForType(type),
                          color: _selectedType == type 
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                type.label,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _selectedType == type 
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                type.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: (type.index * 50).ms);
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Birth Time (for Saju)
          if (_requiresBirthTime()) ...[
            Text(
              '출생 시간',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _birthTime ?? const TimeOfDay(hour: 0, minute: 0),
                );
                if (picked != null) {
                  setState(() {
                    _birthTime = picked;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      _birthTime != null
                          ? '${_birthTime!.hour.toString().padLeft(2, '0')}시 ${_birthTime!.minute.toString().padLeft(2, '0')}분'
                          : '시간을 선택하세요 (모르면 생략 가능)',
                      style: TextStyle(
                        color: _birthTime != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Lunar Calendar Option
            Row(
              children: [
                Checkbox(
                  value: _isLunarCalendar,
                  onChanged: (value) {
                    setState(() {
                      _isLunarCalendar = value ?? false;
                    });
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  '음력 생년월일',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // Generate Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onGenerateFortune,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '운세 보기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _requiresBirthTime() {
    return [
      TraditionalType.saju,
      TraditionalType.traditionalSaju,
    ].contains(_selectedType);
  }

  void _onGenerateFortune() {
    // Get user profile and generate fortune
    final profile = userProfile;
    if (profile != null) {
      final params = {
        'userId': profile.id,
        'name': profile.name,
        'birthDate': profile.birthDate?.toIso8601String(),
        'gender': profile.gender,
      };
      onGenerateFortune(params);
    }
  }

  @override
  Widget buildFortuneResult(Fortune fortune) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Saju Chart (if available)
          if (_sajuData != null && _requiresBirthTime()) ...[
            SajuChartWidget(sajuData: _sajuData!),
            const SizedBox(height: 24),
          ],

          // Fortune Content
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getIconForType(_selectedType),
                      color: AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${_selectedType.label} 결과',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  fortune.content,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
                ),
                if (fortune.advice != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.tips_and_updates,
                              color: AppColors.secondary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '조언',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          fortune.advice!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ).animate()
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  IconData _getIconForType(TraditionalType type) {
    switch (type) {
      case TraditionalType.saju:
        return Icons.auto_awesome;
      case TraditionalType.traditionalSaju:
        return Icons.history_edu;
      case TraditionalType.tojeong:
        return Icons.menu_book;
      case TraditionalType.salpuli:
        return Icons.shield;
      case TraditionalType.fiveBlessings:
        return Icons.stars;
    }
  }
}