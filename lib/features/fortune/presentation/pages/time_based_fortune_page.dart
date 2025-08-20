import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../data/models/user_profile.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../presentation/widgets/hexagon_chart.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/components/loading_elevated_button.dart';
import '../../../../services/ad_service.dart';
import '../../../../shared/glassmorphism/glass_container.dart';

enum TimePeriod {
  tomorrow('내일', 'tomorrow'),
  weekly('이번주', 'weekly'),
  monthly('이번달', 'monthly'),
  yearly('올해', 'yearly'),
  custom('선택한 날', 'custom');
  
  final String label;
  final String value;
  const TimePeriod(this.label, this.value);
}

class TimeBasedFortunePage extends BaseFortunePage {
  final TimePeriod initialPeriod;
  
  const TimeBasedFortunePage({
    Key? key,
    this.initialPeriod = TimePeriod.tomorrow,
    Map<String, dynamic>? initialParams,
  }) : super(
    key: key,
    title: '시간별 운세',
    description: '원하는 기간의 운세를 확인해보세요',
    fortuneType: 'time_based',
    requiresUserInfo: false,
    initialParams: initialParams,
  );

  @override
  ConsumerState<TimeBasedFortunePage> createState() => _TimeBasedFortunePageState();
}

class _TimeBasedFortunePageState extends BaseFortunePageState<TimeBasedFortunePage> {
  late TimePeriod _selectedPeriod;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _isGeneratingFortune = false;

  @override
  void initState() {
    super.initState();
    final periodParam = widget.initialParams?['fortuneParams']?['period'] as String?;
    if (periodParam != null) {
      _selectedPeriod = TimePeriod.values.firstWhere(
        (period) => period.value == periodParam,
        orElse: () => widget.initialPeriod,
      );
    } else {
      _selectedPeriod = widget.initialPeriod;
    }

    Logger.debug('🕐 [TimeBasedFortunePage] Initialized with period', {
      'selectedPeriod': _selectedPeriod.value,
      'periodParam': periodParam,
      'initialParams': widget.initialParams
    });
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    Logger.info('🎲 [TimeBasedFortunePage] generateFortune called', {
      'selectedPeriod': _selectedPeriod.value,
      'selectedDate': _selectedDate.toIso8601String(),
      'params': params
    });

    final fortuneService = ref.read(fortuneServiceProvider);

    // Wait for user profile if not yet loaded
    UserProfile? profile = userProfile;
    if (profile == null) {
      Logger.debug('🔄 [TimeBasedFortunePage] Waiting for user profile...');
      final userProfileAsync = await ref.read(userProfileProvider.future);
      profile = userProfileAsync;
      Logger.debug('✅ [TimeBasedFortunePage] User profile loaded', {
        'profileName': profile?.name,
        'profileId': profile?.id
      });
    }

    final userId = params['userId'] ?? profile?.id;
    if (userId == null) {
      Logger.error('❌ [TimeBasedFortunePage] User ID not found', {
        'params': params,
        'profile': profile
      });
      throw Exception('User ID not found after waiting for profile');
    }

    params['period'] = _selectedPeriod.value;
    params['date'] = _selectedDate.toIso8601String();

    Logger.debug('📝 [TimeBasedFortunePage] Final params prepared', {
      'userId': userId,
      'period': params['period'],
      'date': params['date'],
      'allParams': params
    });

    try {
      final fortune = await fortuneService.getTimeFortune(
        userId: userId,
        fortuneType: 'time_based',
        params: {
          'period': _selectedPeriod.value,
          'date': _selectedDate.toIso8601String()
        },
      );

      Logger.info('✅ [TimeBasedFortunePage] Fortune generated successfully', {
        'fortuneId': fortune.id,
        'fortuneType': fortune.type,
        'score': fortune.score,
        'metadata': fortune.metadata
      });

      return fortune;
    } catch (error, stackTrace) {
      Logger.error('❌ [TimeBasedFortunePage] Fortune generation failed', {
        'error': error.toString(),
        'stackTrace': stackTrace.toString(),
        'userId': userId,
        'period': _selectedPeriod.value
      });
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> getFortuneParams() async {
    final profile = userProfile;
    if (profile == null) return null;
    
    return {
      'userId': profile.id,
      'name': profile.name,
      'birthDate': profile.birthDate?.toIso8601String(),
      'gender': profile.gender,
      'period': _selectedPeriod.value,
      'date': _selectedDate.toIso8601String()
    };
  }

  Future<void> _onGenerateFortuneWithAd() async {
    if (_isGeneratingFortune) return;
    
    setState(() {
      _isGeneratingFortune = true;
    });

    try {
      // Get user profile
      final profile = userProfile;
      if (profile == null) {
        Logger.error('❌ [TimeBasedFortunePage] User profile not available');
        setState(() {
          _isGeneratingFortune = false;
        });
        return;
      }

      final params = {
        'userId': profile.id,
        'name': profile.name,
        'birthDate': profile.birthDate?.toIso8601String(),
        'gender': profile.gender,
        'period': _selectedPeriod.value,
        'date': _selectedDate.toIso8601String()
      };

      // Show ad and wait for completion
      await AdService.instance.showInterstitialAdWithCallback(
        onAdCompleted: () async {
          try {
            await generateFortuneAction(params: params);
            if (mounted) {
              setState(() {
                _isGeneratingFortune = false;
              });
            }
          } catch (e) {
            Logger.error('❌ [TimeBasedFortunePage] Fortune generation failed', e);
            if (mounted) {
              setState(() {
                _isGeneratingFortune = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('운세 생성 중 오류가 발생했습니다: $e')),
              );
            }
          }
        },
        onAdFailed: () async {
          try {
            await generateFortuneAction(params: params);
            if (mounted) {
              setState(() {
                _isGeneratingFortune = false;
              });
            }
          } catch (e) {
            Logger.error('❌ [TimeBasedFortunePage] Fortune generation failed', e);
            if (mounted) {
              setState(() {
                _isGeneratingFortune = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('운세 생성 중 오류가 발생했습니다: $e')),
              );
            }
          }
        },
      );
    } catch (e) {
      Logger.error('❌ [TimeBasedFortunePage] Error in _onGenerateFortuneWithAd', e);
      if (mounted) {
        setState(() {
          _isGeneratingFortune = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: isLoading || _isGeneratingFortune
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                      ? _buildErrorState()
                      : fortune != null
                          ? buildFortuneResult()
                          : _buildInitialState(),
            ),
            if (fortune == null && !isLoading && !_isGeneratingFortune && error == null) 
              _buildGenerateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPeriodSelector(),
          const SizedBox(height: 20),
          if (_showDateSelector()) ...[
            _buildDateSelector(),
            const SizedBox(height: 20),
          ],
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor.withOpacity(0.1),
                  AppTheme.primaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  _getPeriodIcon(_selectedPeriod),
                  size: 64,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  '${_selectedPeriod.label} 운세',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '원하는 기간의 운세를 확인해보세요',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '오류가 발생했습니다',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error ?? '알 수 없는 오류',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            LoadingElevatedButton(
              isLoading: _isGeneratingFortune,
              loadingText: '재시도 중...',
              onPressed: _onGenerateFortuneWithAd,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: LoadingElevatedButton(
          isLoading: _isGeneratingFortune,
          loadingText: '광고 로딩 중',
          onPressed: _onGenerateFortuneWithAd,
          child: Text('${_selectedPeriod.label} 운세 확인하기'),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final isAutoGenerated = widget.initialParams?['autoGenerate'] as bool? ?? false;
    final hasFortune = fortune != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isAutoGenerated && hasFortune) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor.withOpacity(0.1),
                  AppTheme.primaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getPeriodIcon(_selectedPeriod),
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '선택된 기간',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _selectedPeriod.label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('다시 선택'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.isDarkMode ? Colors.grey[900] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: TimePeriod.values.length,
              itemBuilder: (context, index) {
                final period = TimePeriod.values[index];
                final isSelected = period == _selectedPeriod;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: ChoiceChip(
                    label: Text(period.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected && !_isGeneratingFortune) {
                        setState(() {
                          _selectedPeriod = period;
                        });
                      }
                    },
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  bool _showDateSelector() {
    return [
      TimePeriod.tomorrow,
      TimePeriod.weekly,
      TimePeriod.monthly,
      TimePeriod.custom,
    ].contains(_selectedPeriod);
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () async {
        final picked = await _showDatePickerBottomSheet();
        if (picked != null && !_isGeneratingFortune) {
          setState(() {
            _selectedDate = picked;
            // custom 기간 선택 시 자동으로 custom으로 변경
            if (_selectedPeriod != TimePeriod.custom) {
              _selectedPeriod = TimePeriod.custom;
            }
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '선택된 날짜',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 14,
              ),
            ),
            Row(
              children: [
                Text(
                  DateFormat('yyyy년 MM월 dd일').format(_selectedDate),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPeriodIcon(TimePeriod period) {
    switch (period) {
      case TimePeriod.tomorrow:
        return Icons.event;
      case TimePeriod.weekly:
        return Icons.date_range;
      case TimePeriod.monthly:
        return Icons.calendar_month;
      case TimePeriod.yearly:
        return Icons.calendar_today;
      case TimePeriod.custom:
        return Icons.calendar_month;
    }
  }

  Future<DateTime?> _showDatePickerBottomSheet() async {
    return await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('취소'),
                  ),
                  Text(
                    '날짜 선택',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(_selectedDate),
                    child: const Text('확인'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime.now().add(const Duration(days: 1)), // 내일부터
                lastDate: DateTime.now().add(const Duration(days: 365)), // 1년 후까지
                onDateChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}