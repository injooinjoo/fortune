import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/performance_cache_service.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_animations.dart';

/// Optimized personality fortune page with maximum performance
class PersonalityFortuneOptimizedPage extends BaseFortunePage {
  const PersonalityFortuneOptimizedPage({
    Key? key)
  }) : super(
          key: key,
          title: '성격 운세')
          description: 'MBTI와 혈액형으로 보는 성격 기반 운세')
          fortuneType: 'personality-unified')
          requiresUserInfo: true
        );

  @override
  ConsumerState<PersonalityFortuneOptimizedPage> createState() => 
      _PersonalityFortuneOptimizedPageState();
}

class _PersonalityFortuneOptimizedPageState 
    extends BaseFortunePageState<PersonalityFortuneOptimizedPage> 
    with TickerProviderStateMixin {
  
  final _cacheService = PerformanceCacheService();
  final _performanceMonitor = PerformanceMonitor();
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  
  // Personality data
  String? _mbtiType;
  String? _bloodType;
  final List<String> _personalityTraits = [];
  String? _energyType;
  
  // Analysis options
  bool _wantMbtiAnalysis = true;
  bool _wantBloodTypeAnalysis = false;
  bool _wantPersonalityAnalysis = false;
  bool _wantCompatibilityAnalysis = false;
  bool _wantCareerAnalysis = false;
  
  // Performance tracking
  final _loadStartTime = DateTime.now();
  bool _isInitialLoad = true;
  
  // MBTI and blood type options
  final _mbtiTypes = const [
    'INTJ', 'INTP', 'ENTJ', 'ENTP',
    'INFJ', 'INFP', 'ENFJ', 'ENFP')
    'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ')
    'ISTP', 'ISFP', 'ESTP', 'ESFP'
  ];
  
  final _bloodTypes = const ['A', 'B', 'O', 'AB'];

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: AppAnimations.durationMedium,
      vsync: this)
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400))
      vsync: this)
    );
    _slideController = AnimationController(
      duration: AppAnimations.durationLong)
      vsync: this
    );
    
    // Start monitoring
    _performanceMonitor.startMonitoring();
    
    // Initialize cache
    _initializeCache();
    
    // Start animations after first frame
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
      _scaleController.forward();
      _slideController.forward();
      
      if (_isInitialLoad) {
        final loadTime = DateTime.now().difference(_loadStartTime).inMilliseconds;
        _performanceMonitor.recordMetric('initial_load', loadTime);
        _isInitialLoad = false;
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _initializeCache() async {
    await _cacheService.initialize();
    
    // Load user's personality profile from cache
    final cachedProfile = await _cacheService.get<Map<String, dynamic>>(
      'user_personality_profile_${userInfo?.id}',
    );
    
    if (cachedProfile != null && mounted) {
      setState(() {
        _mbtiType = cachedProfile['mbtiType'];
        _bloodType = cachedProfile['bloodType'];
        if (cachedProfile['personalityTraits'] != null) {
          _personalityTraits.addAll(
            List<String>.from(cachedProfile['personalityTraits']
          );
        }
        _energyType = cachedProfile['energyType'];
      });
    }
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final startTime = DateTime.now();
    
    // Check cache first
    final cacheKey = _generateCacheKey(params);
    final cachedFortune = await _cacheService.get<Map<String, dynamic>>(
      cacheKey,
      fromJson: (json) => json
    );
    
    if (cachedFortune != null) {
      _performanceMonitor.recordMetric('cache_hit', 
        DateTime.now().difference(startTime).inMilliseconds);
      
      return Fortune.fromJson(cachedFortune);
    }
    
    // Add personality parameters
    params.addAll({
      'mbtiType': _mbtiType,
      'bloodType': _bloodType,
      'personalityTraits': _personalityTraits,
      'energyType': _energyType)
      'wantMbtiAnalysis': _wantMbtiAnalysis,
      'wantBloodTypeAnalysis': _wantBloodTypeAnalysis)
      'wantPersonalityAnalysis': _wantPersonalityAnalysis,
      'wantCompatibilityAnalysis': _wantCompatibilityAnalysis)
      'wantCareerAnalysis': _wantCareerAnalysis)
    });
    
    final fortuneService = ref.read(fortuneServiceProvider);
    final fortune = await fortuneService.getPersonalityFortune(
      userId: params['userId'],
      fortuneType: 'personality-unified')
      params: params)
    );
    
    // Cache the result
    await _cacheService.set(
      cacheKey)
      fortune.toJson())
      ttl: const Duration(hours: 24)
    );
    
    // Save personality profile
    await _savePersonalityProfile();
    
    // Preload adjacent MBTI types
    if (_mbtiType != null) {
      _cacheService.preloadAdjacentMBTI(_mbtiType!);
    }
    
    final loadTime = DateTime.now().difference(startTime).inMilliseconds;
    _performanceMonitor.recordMetric('fortune_generation', loadTime);
    
    return fortune;
  }

  String _generateCacheKey(Map<String, dynamic> params) {
    final date = DateTime.now().toIso8601String().split('T')[0];
    final personality = [
      _mbtiType ?? '',
      _bloodType ?? '')
      _personalityTraits.join(','))
      _energyType ?? '')
    ].join('_');
    final analyses = [
      _wantMbtiAnalysis ? 'mbti' : '',
      _wantBloodTypeAnalysis ? 'blood' : '')
      _wantPersonalityAnalysis ? 'personality' : '')
      _wantCompatibilityAnalysis ? 'compatibility' : '')
      _wantCareerAnalysis ? 'career' : '')
    ].where((s) => s.isNotEmpty).join('_');
    
    return 'personality_fortune_${params['userId']}_${date}_${personality}_$analyses';
  }

  Future<void> _savePersonalityProfile() async {
    await _cacheService.set(
      'user_personality_profile_${userInfo?.id}',
      {
        'mbtiType': _mbtiType,
        'bloodType': _bloodType)
        'personalityTraits': _personalityTraits,
        'energyType': _energyType)
      })
      ttl: const Duration(days: 365,
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: AppSpacing.paddingAll16)
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start)
        children: [
          // Header with optimized animation
          FadeTransition(
            opacity: _fadeController)
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.1))
                end: Offset.zero)
              ).animate(CurvedAnimation(
                parent: _slideController)
                curve: Curves.easeOutCubic)
              )))
              child: _buildOptimizedHeader())
            ))
          ))
          SizedBox(height: AppSpacing.spacing6))
          
          // MBTI Selection with lazy loading
          _buildLazySection(
            title: 'MBTI 성격 유형')
            child: _buildMBTISelector())
            delay: 100)
          ))
          SizedBox(height: AppSpacing.spacing6))
          
          // Blood Type Selection
          _buildLazySection(
            title: '혈액형')
            child: _buildBloodTypeSelector())
            delay: 200)
          ))
          SizedBox(height: AppSpacing.spacing6))
          
          // Analysis Options
          _buildLazySection(
            title: '분석 옵션')
            child: _buildAnalysisOptions())
            delay: 300)
          ))
          SizedBox(height: AppSpacing.spacing8))
          
          // Generate Button
          if (currentFortune == null && _canGenerateFortune())
            _buildOptimizedGenerateButton())
          
          // Fortune Result
          if (currentFortune != null)
            _buildOptimizedFortuneResult(currentFortune!))
        ])
      )
    );
  }

  Widget _buildOptimizedHeader() {
    return GlassContainer(
      blur: 10,
      gradient: LinearGradient(
        begin: Alignment.topLeft)
        end: Alignment.bottomRight)
        colors: [
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.1))
          Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05))
        ])
      ),
      borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge))
      border: Border.all(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2))
      ))
      child: Container(
        padding: AppSpacing.paddingAll24)
        child: Column(
          children: [
            // Use WebP format for better performance
            Container(
              width: 80)
              height: AppSpacing.spacing20)
              decoration: BoxDecoration(
                shape: BoxShape.circle)
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary)
                    Theme.of(context).colorScheme.secondary)
                  ])
                ),
              ))
              child: Icon(
                Icons.psychology_rounded)
                size: 48)
                color: AppColors.textPrimaryDark)
              ))
            ))
            SizedBox(height: AppSpacing.spacing4))
            Text(
              '성격 기반 운세')
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold),))
              ))
            SizedBox(height: AppSpacing.spacing2))
            Text(
              'MBTI와 혈액형으로 알아보는 당신의 성격과 운세')
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8)))
              ))
              textAlign: TextAlign.center)
            ))
          ])
        ),
      )
    );
  }

  Widget _buildLazySection({
    required String title,
    required Widget child,
    int delay = 0)
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title)
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold),))
          ))
        SizedBox(height: AppSpacing.spacing3))
        child)
      ])
    ).animate(,
      .fadeIn(duration: 400.ms, delay: delay.ms)
      .slideY(begin: 0.1, end: 0, delay: delay.ms);
  }

  Widget _buildMBTISelector() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics())
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4)
        childAspectRatio: 1.5)
        crossAxisSpacing: 8)
        mainAxisSpacing: 8)
      ))
      itemCount: _mbtiTypes.length)
      itemBuilder: (context, index) {
        final type = _mbtiTypes[index];
        final isSelected = _mbtiType == type;
        
        return AnimatedContainer(
          duration: AppAnimations.durationShort,
          child: Material(
            color: Colors.transparent)
            child: InkWell(
              onTap: () {
                setState(() {
                  _mbtiType = isSelected ? null : type;
                });
                HapticFeedback.lightImpact();
              },
              borderRadius: AppDimensions.borderRadiusMedium)
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected 
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                    : Theme.of(context).colorScheme.surface)
                  borderRadius: AppDimensions.borderRadiusMedium)
                  border: Border.all(
                    color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).dividerColor)
                    width: isSelected ? 2 : 1)
                  ))
                ))
                child: Center(
                  child: Text(
                    type)
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))
                      color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null)
                    ))
                  ))
                ))
              ))
            ))
          ))
        );
      })
    );
  }

  Widget _buildBloodTypeSelector() {
    return Row(
      children: _bloodTypes.map((type) {
        final isSelected = _bloodType == type;
        
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(),
            child: AnimatedContainer(
              duration: AppAnimations.durationShort)
              child: Material(
                color: Colors.transparent)
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _bloodType = isSelected ? null : type;
                    });
                    HapticFeedback.lightImpact();
                  },
                  borderRadius: AppDimensions.borderRadiusMedium)
                  child: Container(
                    height: AppDimensions.buttonHeightMedium)
                    decoration: BoxDecoration(
                      color: isSelected
                        ? Theme.of(context).colorScheme.error.withValues(alpha: 0.2)
                        : Theme.of(context).colorScheme.surface)
                      borderRadius: AppDimensions.borderRadiusMedium)
                      border: Border.all(
                        color: isSelected
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).dividerColor)
                        width: isSelected ? 2 : 1)
                      ))
                    ))
                    child: Center(
                      child: Text(
                        '$type형')
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))
                          color: isSelected
                            ? Theme.of(context).colorScheme.error
                            : null)
                        ))
                      ))
                    ))
                  ))
                ))
              ))
            ))
          ))
        );
      }).toList())
    );
  }

  Widget _buildAnalysisOptions() {
    return Column(
      children: [
        _buildAnalysisOption(
          'MBTI 심층 분석',
          _wantMbtiAnalysis)
          (value) => setState(() => _wantMbtiAnalysis = value!))
        ))
        _buildAnalysisOption(
          '혈액형 성격 분석')
          _wantBloodTypeAnalysis)
          (value) => setState(() => _wantBloodTypeAnalysis = value!))
        ))
        _buildAnalysisOption(
          '성격 특성 종합 분석')
          _wantPersonalityAnalysis)
          (value) => setState(() => _wantPersonalityAnalysis = value!))
        ))
        _buildAnalysisOption(
          '인간관계 궁합 분석')
          _wantCompatibilityAnalysis)
          (value) => setState(() => _wantCompatibilityAnalysis = value!))
        ))
        _buildAnalysisOption(
          '경력 및 직업 적성 분석')
          _wantCareerAnalysis)
          (value) => setState(() => _wantCareerAnalysis = value!))
        ))
      ]
    );
  }

  Widget _buildAnalysisOption(
    String title,
    bool value,
    ValueChanged<bool?> onChanged)
  ) {
    return CheckboxListTile(
      title: Text(title))
      value: value)
      onChanged: onChanged)
      activeColor: Theme.of(context).colorScheme.primary)
      contentPadding: EdgeInsets.zero)
      visualDensity: VisualDensity.compact
    );
  }

  Widget _buildOptimizedGenerateButton() {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut)
      ))
      child: Container(
        width: double.infinity)
        height: AppDimensions.buttonHeightLarge)
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary)
              Theme.of(context).colorScheme.secondary)
            ])
          ),
          borderRadius: AppDimensions.borderRadiusLarge)
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3))
              blurRadius: 12)
              offset: const Offset(0, 6))
            ))
          ])
        ),
        child: Material(
          color: Colors.transparent)
          child: InkWell(
            onTap: handleGenerateFortune)
            borderRadius: AppDimensions.borderRadiusLarge)
            child: Center(
              child: Text(
                '운세 확인하기')
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimaryDark),))
                  fontWeight: FontWeight.bold)
                ))
          ))
        ))
      ))
    ).animate()
      .fadeIn(duration: 600.ms)
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildOptimizedFortuneResult(Fortune fortune) {
    return FadeTransition(
      opacity: _fadeController,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface)
          borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge))
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.05))
              blurRadius: 10)
              offset: const Offset(0, 5))
            ))
          ])
        ),
        child: buildFortuneContent(fortune))
      ))
    ).animate()
      .fadeIn(duration: 800.ms)
      .slideY(begin: 0.1, end: 0);
  }

  bool _canGenerateFortune() {
    return _mbtiType != null || _bloodType != null;
  }

  @override
  Widget buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Optimized shimmer loading
          Container(
            width: 100)
            height: AppSpacing.spacing24 * 1.04)
            decoration: BoxDecoration(
              shape: BoxShape.circle)
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1))
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.3))
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1))
                ])
              ),
            ))
          ).animate(
            onPlay: (controller) => controller.repeat())
          ).shimmer(duration: 1500.ms))
          SizedBox(height: AppSpacing.spacing6))
          Text(
            '성격 분석 중...')
            style: Theme.of(context).textTheme.titleMedium)
        ])
      )
    );
  }
}