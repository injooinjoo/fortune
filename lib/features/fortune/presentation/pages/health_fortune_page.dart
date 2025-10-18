import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../shared/components/toss_floating_progress_button.dart';
import '../../../../core/components/toss_card.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/providers.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/services/unified_fortune_service.dart';

class HealthFortunePage extends BaseFortunePage {
  const HealthFortunePage({super.key})
      : super(
          title: '건강 운세',
          description: '오늘의 건강 상태와 주의사항을 확인하세요',
          fortuneType: 'health',
          requiresUserInfo: false,
        );

  @override
  ConsumerState<HealthFortunePage> createState() => _HealthFortunePageState();
}

class _HealthFortunePageState extends BaseFortunePageState<HealthFortunePage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1: 건강 고민
  String _healthConcern = '';
  final List<String> _symptoms = [];

  // Step 2: 생활습관
  int _sleepQuality = 3;
  int _exerciseFrequency = 3;
  int _stressLevel = 3;

  // Step 3: 식습관
  int _mealRegularity = 3;
  bool _hasChronicCondition = false;
  String _chronicCondition = '';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _generateFortune();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _generateFortune() async {
    final params = {
      'healthConcern': _healthConcern,
      'symptoms': _symptoms,
      'sleepQuality': _sleepQuality,
      'exerciseFrequency': _exerciseFrequency,
      'stressLevel': _stressLevel,
      'mealRegularity': _mealRegularity,
      'hasChronicCondition': _hasChronicCondition,
      'chronicCondition': _chronicCondition,
    };

    await generateFortuneAction(params: params);
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    Logger.info('🔮 [HealthFortune] UnifiedFortuneService 호출', {'params': params});

    try {
      final fortuneService = UnifiedFortuneService(Supabase.instance.client);

      final inputConditions = {
        'healthConcern': params['healthConcern'] ?? '',
        'symptoms': params['symptoms'] ?? [],
        'sleepQuality': params['sleepQuality'] ?? 3,
        'exerciseFrequency': params['exerciseFrequency'] ?? 3,
        'stressLevel': params['stressLevel'] ?? 3,
        'mealRegularity': params['mealRegularity'] ?? 3,
        'hasChronicCondition': params['hasChronicCondition'] ?? false,
        'chronicCondition': params['chronicCondition'] ?? '',
      };

      final result = await fortuneService.getFortune(
        fortuneType: widget.fortuneType,
        dataSource: FortuneDataSource.api,
        inputConditions: inputConditions,
      );

      return result.toFortune();
    } catch (e) {
      Logger.error('❌ [HealthFortune] 운세 생성 실패', e);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (fortune != null) {
      return super.build(context);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios, color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight),
                onPressed: _previousStep,
              )
            : IconButton(
                icon: Icon(Icons.arrow_back_ios, color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight),
                onPressed: () => Navigator.of(context).pop(),
              ),
        title: Text(
          widget.title,
          style: TextStyle(
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / 3,
              backgroundColor: (isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight).withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(TossDesignSystem.primary),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: TossFloatingProgressButtonPositioned(
        text: _currentStep == 2 ? '건강 운세 보기' : '다음',
        isEnabled: _isStepValid(),
        showProgress: false,
        isVisible: true,
        onPressed: _nextStep,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  bool _isStepValid() {
    switch (_currentStep) {
      case 0:
        return _healthConcern.isNotEmpty;
      case 1:
        return true;
      case 2:
        return true;
      default:
        return false;
    }
  }

  Widget _buildStep1() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '건강 고민',
            style: context.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            '현재 가장 걱정되는 건강 문제를 알려주세요',
            style: context.bodyMedium.copyWith(
              color: (isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight).withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          TossCard(
            child: TextField(
              decoration: const InputDecoration(
                hintText: '예: 피로감, 소화불량, 두통 등',
                border: InputBorder.none,
              ),
              maxLines: 3,
              onChanged: (value) => setState(() => _healthConcern = value),
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '생활습관',
            style: context.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            '평소 생활습관을 알려주세요',
            style: context.bodyMedium.copyWith(
              color: (isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight).withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          TossCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('수면 질', style: context.bodyLarge),
                Slider(
                  value: _sleepQuality.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: _sleepQuality.toString(),
                  onChanged: (value) => setState(() => _sleepQuality = value.toInt()),
                ),
                const SizedBox(height: 16),
                Text('운동 빈도', style: context.bodyLarge),
                Slider(
                  value: _exerciseFrequency.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: _exerciseFrequency.toString(),
                  onChanged: (value) => setState(() => _exerciseFrequency = value.toInt()),
                ),
                const SizedBox(height: 16),
                Text('스트레스 수준', style: context.bodyLarge),
                Slider(
                  value: _stressLevel.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: _stressLevel.toString(),
                  onChanged: (value) => setState(() => _stressLevel = value.toInt()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '식습관 및 기타',
            style: context.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            '식습관과 기타 건강 정보를 알려주세요',
            style: context.bodyMedium.copyWith(
              color: (isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight).withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          TossCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('식사 규칙성', style: context.bodyLarge),
                Slider(
                  value: _mealRegularity.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: _mealRegularity.toString(),
                  onChanged: (value) => setState(() => _mealRegularity = value.toInt()),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: Text('만성 질환이 있습니다', style: context.bodyMedium),
                  value: _hasChronicCondition,
                  onChanged: (value) => setState(() => _hasChronicCondition = value ?? false),
                  contentPadding: EdgeInsets.zero,
                ),
                if (_hasChronicCondition) ...[
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: '만성 질환명을 입력하세요',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => _chronicCondition = value),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}
