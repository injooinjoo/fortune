import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/toast.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/mbti_grid_selector.dart';
import '../widgets/blood_type_card_selector.dart';
import '../widgets/personality_traits_chips.dart';
import '../widgets/personality_analysis_options.dart';
import 'personality_fortune_result_page.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_animations.dart';
import 'package:fortune/core/theme/app_colors.dart';

// Step 관리를 위한 StateNotifier
class PersonalityStepNotifier extends StateNotifier<int> {
  PersonalityStepNotifier() : super(0);
  
  void nextStep() {
    if (state < 3) state++;
  }
  
  void previousStep() {
    if (state > 0) state--;
  }
  
  void setStep(int step) {
    state = step.clamp(0, 3);
  }
}

final personalityStepProvider = StateNotifierProvider<PersonalityStepNotifier, int>((ref) {
  return PersonalityStepNotifier();
});

// 성격 데이터 모델
class PersonalityFortuneData {
  // Step 1: MBTI 유형
  String? mbtiType;
  Map<String, int> mbtiDimensions = {
    'E-I': 50, // Extraversion-Introversion
    'S-N': 50, // Sensing-Intuition
    'T-F': 50, // Thinking-Feeling
    'J-P': 50, // Judging-Perceiving
  };
  
  // Step 2: 추가 정보
  String? bloodType;
  List<String> selectedTraits = [];
  String? lifePattern; // morning, night, irregular
  String? stressResponse; // fight, flight, freeze, fawn
  
  // Step 3: 분석 옵션
  bool wantRelationshipAnalysis = true;
  bool wantCareerGuidance = true;
  bool wantPersonalGrowth = true;
  bool wantCompatibility = true;
  bool wantDailyAdvice = false;
  String? specificQuestion;
  
  // 사용자 정보
  String? userId;
  String? name;
  DateTime? birthDate;
  String? gender;
  String? birthTime;
}

final personalityDataProvider = StateProvider<PersonalityFortuneData>((ref) {
  return PersonalityFortuneData();
});

class PersonalityFortuneEnhancedPage extends ConsumerStatefulWidget {
  const PersonalityFortuneEnhancedPage({Key? key}) : super(key: key);

  @override
  ConsumerState<PersonalityFortuneEnhancedPage> createState() => _PersonalityFortuneEnhancedPageState();
}

class _PersonalityFortuneEnhancedPageState extends ConsumerState<PersonalityFortuneEnhancedPage> 
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: AppAnimations.durationLong,
      vsync: this)
    );
    
    _scaleController = AnimationController(
      duration: AppAnimations.durationMedium)
      vsync: this
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0)
      end: 1.0)
    ).animate(CurvedAnimation(
      parent: _fadeController)
      curve: Curves.easeInOut)
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.95)
      end: 1.0)
    ).animate(CurvedAnimation(
      parent: _scaleController)
      curve: Curves.easeOutBack)
    ));
    
    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    
    // Initialize user data
    _initializeUserData();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
  
  void _initializeUserData() {
    final userProfile = ref.read(userProfileProvider).value;
    if (userProfile != null) {
      final data = ref.read(personalityDataProvider);
      data.userId = userProfile.id;
      data.name = userProfile.name;
      data.birthDate = userProfile.birthDate;
      data.gender = userProfile.gender;
      data.birthTime = userProfile.birthTime;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final currentStep = ref.watch(personalityStepProvider);
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft)
            end: Alignment.bottomRight)
            colors: [
              AppColors.background)
              AppColors.primary.withValues(alpha: 0.05))
              AppColors.secondary.withValues(alpha: 0.05))
            ])
          ),
        ))
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button and progress
              _buildHeader(context, currentStep))
              
              // Step indicator
              _buildStepIndicator(currentStep))
              
              // Content
              Expanded(
                child: PageView(
                  controller: _pageController)
                  physics: const NeverScrollableScrollPhysics())
                  children: [
                    _buildStep1())
                    _buildStep2())
                    _buildStep3())
                    _buildStep4())
                  ])
                ),
              ))
              
              // Bottom navigation
              _buildBottomNavigation(context, currentStep))
            ])
          ),
        ))
      )
    );
  }
  
  Widget _buildHeader(BuildContext context, int currentStep) {
    return Container(
      padding: AppSpacing.paddingAll16,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded))
            onPressed: () {
              if (currentStep > 0) {
                ref.read(personalityStepProvider.notifier).previousStep();
                _pageController.previousPage(
                  duration: AppAnimations.durationMedium)
                  curve: Curves.easeOut
                );
              } else {
                context.pop();
              }
            },
          ))
          Expanded(
            child: Text(
              '성격 운세')
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold),))
                background: Paint()
                  ..shader = LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary])
                  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
              ))
              textAlign: TextAlign.center)
            ))
          ))
          SizedBox(width: AppSpacing.spacing12), // Balance the back button
        ])
      )
    );
  }
  
  Widget _buildStepIndicator(int currentStep) {
    final steps = [
      'MBTI 유형',
      '추가 정보')
      '분석 옵션')
      '운세 확인')
    ];
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing6, vertical: AppSpacing.spacing4),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index == currentStep;
          final isCompleted = index < currentStep;
          
          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    if (index > 0)
                      Expanded(
                        child: Container(
                          height: AppSpacing.spacing0 * 0.5)
                          decoration: BoxDecoration(
                            gradient: isCompleted
                                ? LinearGradient(
                                    colors: [AppColors.primary, AppColors.secondary])
                                  )
                                : null,
                            color: !isCompleted ? Theme.of(context).dividerColor : null)
                          ))
                        ))
                      ))
                    Container(
                      width: AppSpacing.spacing8)
                      height: AppDimensions.buttonHeightXSmall)
                      decoration: BoxDecoration(
                        shape: BoxShape.circle)
                        gradient: isActive || isCompleted
                            ? LinearGradient(
                                begin: Alignment.topLeft)
                                end: Alignment.bottomRight)
                                colors: [AppColors.primary, AppColors.secondary])
                              )
                            : null,
                        color: !isActive && !isCompleted
                            ? Theme.of(context).colorScheme.surfaceContainerHighest
                            : null)
                      ))
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, size: AppDimensions.iconSizeXSmall, color: AppColors.textPrimaryDark)
                            : Text(
                                '${index + 1}')
                                style: TextStyle(
                                  color: isActive ? AppColors.textPrimaryDark : Theme.of(context).colorScheme.onSurfaceVariant),
                                  fontWeight: FontWeight.bold)
                                ))
                              ))
                      ))
                    ))
                    if (index < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: AppSpacing.spacing0 * 0.5)
                          decoration: BoxDecoration(
                            gradient: isCompleted
                                ? LinearGradient(
                                    colors: [AppColors.primary, AppColors.secondary])
                                  )
                                : null,
                            color: !isCompleted ? Theme.of(context).dividerColor : null)
                          ))
                        ))
                      ))
                  ])
                ),
                SizedBox(height: AppSpacing.spacing2))
                Text(
                  steps[index])
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant),
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal)
                  ))
                ))
              ])
            ),
          );
        }))
      )
    );
  }
  
  Widget _buildBottomNavigation(BuildContext context, int currentStep) {
    final data = ref.watch(personalityDataProvider);
    final isValid = _validateStep(currentStep, data);
    
    return Container(
      padding: AppSpacing.paddingAll16,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface)
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.1))
            blurRadius: 10)
            offset: const Offset(0, -5))
          ))
        ])
      ),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ref.read(personalityStepProvider.notifier).previousStep();
                  _pageController.previousPage(
                    duration: AppAnimations.durationMedium)
                    curve: Curves.easeOut
                  );
                })
                style: OutlinedButton.styleFrom(
                  padding: AppSpacing.paddingVertical16,
                  side: BorderSide(color: Theme.of(context).colorScheme.primary))
                ))
                child: const Text('이전'))
              ))
            ))
          if (currentStep > 0) SizedBox(width: AppSpacing.spacing4))
          Expanded(
            flex: currentStep == 0 ? 1 : 2)
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary])
                ),
                borderRadius: AppDimensions.borderRadiusMedium)
              ))
              child: ElevatedButton(
                onPressed: isValid
                    ? () {
                        if (currentStep < 3) {
                          ref.read(personalityStepProvider.notifier).nextStep();
                          _pageController.nextPage(
                            duration: AppAnimations.durationMedium)
                            curve: Curves.easeOut)
                          );
                        } else {
                          _generateFortune();
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent)
                  shadowColor: Colors.transparent)
                  padding: AppSpacing.paddingVertical16)
                ))
                child: Text(
                  currentStep == 3 ? '운세 보기' : '다음')
                  style: Theme.of(context).textTheme.titleMedium)
            ))
          ))
        ])
      )
    );
  }
  
  bool _validateStep(int step, PersonalityFortuneData data) {
    switch (step) {
      case 0:
        return data.mbtiType != null;
      case 1:
        return data.bloodType != null && data.selectedTraits.isNotEmpty;
      case 2:
        return true; // Step 3 is optional
      case 3:
        return true; // Ready to generate
      default:
        return false;
    }
  }
  
  // Step 1: MBTI 유형 선택
  Widget _buildStep1() {
    final data = ref.watch(personalityDataProvider);
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation)
        child: SingleChildScrollView(
          padding: AppSpacing.paddingAll24)
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start)
            children: [
              Text(
                'MBTI 유형을 선택하세요')
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold),))
                ))
              SizedBox(height: AppSpacing.spacing2))
              Text(
                '당신의 성격 유형을 알려주세요')
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant))
                ))
              ))
              SizedBox(height: AppSpacing.spacing8))
              
              // MBTI Grid Selector
              MbtiGridSelector(
                selectedType: data.mbtiType)
                onTypeSelected: (type) {
                  ref.read(personalityDataProvider.notifier).update((state) {
                    state.mbtiType = type;
                    return state;
                  });
                },
              ))
              
              SizedBox(height: AppSpacing.spacing8))
              
              // MBTI Dimension Sliders
              _buildDimensionSliders(data))
              
              SizedBox(height: AppSpacing.spacing6))
              
              // MBTI 설명
              if (data.mbtiType != null)
                GlassContainer(
                  padding: AppSpacing.paddingAll16)
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start)
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline)
                            color: Theme.of(context).colorScheme.primary)
                          ))
                          SizedBox(width: AppSpacing.spacing2))
                          Text(
                            '${data.mbtiType} 타입')
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold),))
                            ),
                        ])
                      ),
                      SizedBox(height: AppSpacing.spacing2))
                      Text(
                        _getMbtiDescription(data.mbtiType!))
                        style: Theme.of(context).textTheme.bodyMedium)
                    ])
                  ),
                ))
            ])
          ),
        ))
      )
    );
  }
  
  Widget _buildDimensionSliders(PersonalityFortuneData data) {
    final dimensions = [
      {'key': 'E-I', 'left': '외향적 (E)', 'right': '내향적 (I)', 'color': AppColors.primary},
      {'key': 'S-N', 'left': '감각적 (S)', 'right': '직관적 (N)', 'color': AppColors.success},
      {'key': 'T-F', 'left': '사고적 (T)', 'right': '감정적 (F)', 'color': AppColors.warning},
      {'key': 'J-P', 'left': '판단적 (J)', 'right': '인식적 (P)', 'color': Colors.purple},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '성향 세부 조정')
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold),))
          ))
        SizedBox(height: AppSpacing.spacing4))
        ...dimensions.map((dimension) {
          final value = data.mbtiDimensions[dimension['key']]?.toDouble() ?? 50.0;
          final color = dimension['color'] as Color;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xLarge),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween)
                  children: [
                    Text(
                      dimension['left'] as String,
                      style: Theme.of(context).textTheme.bodySmall,
                    Text(
                      '${value.round()}%')
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color)
                      )))
                    Text(
                      dimension['right'] as String,
                      style: Theme.of(context).textTheme.bodySmall,
                  ])
                ),
                SizedBox(height: AppSpacing.spacing2))
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: color)
                    inactiveTrackColor: color.withValues(alpha: 0.3))
                    thumbColor: color)
                    overlayColor: color.withValues(alpha: 0.3))
                  ))
                  child: Slider(
                    value: value)
                    min: 0)
                    max: 100)
                    divisions: 20)
                    onChanged: (newValue) {
                      ref.read(personalityDataProvider.notifier).update((state) {
                        state.mbtiDimensions[dimension['key'] as String] = newValue.round();
                        // Update MBTI type based on dimensions
                        state.mbtiType = _calculateMbtiType(state.mbtiDimensions);
                        return state;
                      });
                    },
                  ))
                ))
              ])
            ),
          );
        }).toList())
      ]
    );
  }
  
  // Step 2: 추가 정보
  Widget _buildStep2() {
    final data = ref.watch(personalityDataProvider);
    
    return SingleChildScrollView(
      padding: AppSpacing.paddingAll24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start)
        children: [
          Text(
            '추가 정보를 입력하세요')
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold),))
            ))
          SizedBox(height: AppSpacing.spacing2))
          Text(
            '더 정확한 성격 분석을 위해 필요합니다')
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant))
            ))
          ))
          SizedBox(height: AppSpacing.spacing8))
          
          // Blood Type Selection
          Text(
            '혈액형')
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold),))
            ))
          SizedBox(height: AppSpacing.spacing4))
          BloodTypeCardSelector(
            selectedType: data.bloodType)
            onTypeSelected: (type) {
              ref.read(personalityDataProvider.notifier).update((state) {
                state.bloodType = type;
                return state;
              });
            },
          ))
          SizedBox(height: AppSpacing.spacing8))
          
          // Personality Traits
          Text(
            '성격 특성 (최대 5개)')
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold),))
            ))
          SizedBox(height: AppSpacing.spacing4))
          PersonalityTraitsChips(
            selectedTraits: data.selectedTraits)
            onTraitsChanged: (traits) {
              ref.read(personalityDataProvider.notifier).update((state) {
                state.selectedTraits = traits;
                return state;
              });
            },
          ))
          SizedBox(height: AppSpacing.spacing8))
          
          // Life Pattern
          Text(
            '생활 패턴')
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold),))
            ))
          SizedBox(height: AppSpacing.spacing4))
          _buildLifePatternSelector(data))
          SizedBox(height: AppSpacing.spacing8))
          
          // Stress Response
          Text(
            '스트레스 대응 방식')
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold),))
            ))
          SizedBox(height: AppSpacing.spacing4))
          _buildStressResponseSelector(data))
        ])
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideY(begin: 0.1, end: 0, duration: 300.ms);
  }
  
  Widget _buildLifePatternSelector(PersonalityFortuneData data) {
    final patterns = [
      {'value': 'morning', 'label': '아침형', 'icon': Icons.wb_sunny_rounded, 'color': AppColors.warning},
      {'value': 'night', 'label': '저녁형', 'icon': Icons.nights_stay_rounded, 'color': Colors.indigo},
      {'value': 'irregular', 'label': '불규칙형', 'icon': Icons.schedule_rounded, 'color': Colors.purple},
    ];
    
    return Row(
      children: patterns.map((pattern) {
        final isSelected = data.lifePattern == pattern['value'];
        final color = pattern['color'] as Color;
        
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing1),
            child: InkWell(
              onTap: () {
                ref.read(personalityDataProvider.notifier).update((state) {
                  state.lifePattern = pattern['value'] as String;
                  return state;
                });
              },
              borderRadius: AppDimensions.borderRadiusMedium)
              child: AnimatedContainer(
                duration: AppAnimations.durationMedium)
                padding: EdgeInsets.symmetric(vertical: AppSpacing.spacing5))
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [color, color.withValues(alpha: 0.8)],
                        )
                      : null)
                  color: !isSelected
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                      : null)
                  borderRadius: AppDimensions.borderRadiusMedium)
                  border: Border.all(
                    color: isSelected ? Colors.transparent : Theme.of(context).dividerColor)
                  ))
                ))
                child: Column(
                  children: [
                    Icon(
                      pattern['icon'] as IconData,
                      size: AppDimensions.iconSizeXLarge,
                      color: isSelected ? AppColors.textPrimaryDark : color)
                    ))
                    SizedBox(height: AppSpacing.spacing2))
                    Text(
                      pattern['label'] as String,
                      style: TextStyle(
                        color: isSelected ? AppColors.textPrimaryDark : Theme.of(context).colorScheme.onSurface),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)
                      ))
                    ))
                  ])
                ),
              ))
            ))
          ))
        );
      }).toList()
    );
  }
  
  Widget _buildStressResponseSelector(PersonalityFortuneData data) {
    final responses = [
      {'value': 'fight', 'label': '직면형', 'description': '문제에 맞서 해결', 'icon': Icons.flash_on},
      {'value': 'flight', 'label': '회피형', 'description': '상황을 벗어남', 'icon': Icons.directions_run},
      {'value': 'freeze', 'label': '정지형', 'description': '상황을 관찰', 'icon': Icons.pause_circle},
      {'value': 'fawn', 'label': '순응형', 'description': '상황에 적응', 'icon': Icons.handshake},
    ];
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics())
      crossAxisCount: 2)
      mainAxisSpacing: 12)
      crossAxisSpacing: 12)
      childAspectRatio: 1.5)
      children: responses.map((response) {
        final isSelected = data.stressResponse == response['value'];
        
        return InkWell(
          onTap: () {
            ref.read(personalityDataProvider.notifier).update((state) {
              state.stressResponse = response['value'] as String;
              return state;
            });
          },
          borderRadius: AppDimensions.borderRadiusMedium)
          child: Container(
            padding: AppSpacing.paddingAll12)
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary)
                        Theme.of(context).colorScheme.secondary)
                      ])
                    )
                  : null,
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : Theme.of(context).dividerColor)
              ))
              borderRadius: AppDimensions.borderRadiusMedium)
            ))
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center)
              children: [
                Icon(
                  response['icon'] as IconData,
                  size: AppDimensions.iconSizeLarge,
                  color: isSelected
                      ? AppColors.textPrimaryDark
                      : Theme.of(context).colorScheme.onSurfaceVariant)
                ))
                SizedBox(height: AppSpacing.spacing1))
                Text(
                  response['label'] as String,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.textPrimaryDark
                        : Theme.of(context).colorScheme.onSurface),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)
                  ))
                ))
                Text(
                  response['description'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isSelected
                        ? AppColors.textPrimaryDark.withValues(alpha: 0.9,
                        : Theme.of(context).colorScheme.onSurfaceVariant))
                  ))
                ))
              ])
            ),
          ))
        );
      }).toList()
    );
  }
  
  // Step 3: 분석 옵션
  Widget _buildStep3() {
    final data = ref.watch(personalityDataProvider);
    
    return SingleChildScrollView(
      padding: AppSpacing.paddingAll24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start)
        children: [
          Text(
            '분석하고 싶은 항목을 선택하세요')
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold),))
            ))
          SizedBox(height: AppSpacing.spacing2))
          Text(
            '원하는 분석을 선택해주세요')
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant))
            ))
          ))
          SizedBox(height: AppSpacing.spacing8))
          
          // Analysis Options
          PersonalityAnalysisOptions(
            wantRelationshipAnalysis: data.wantRelationshipAnalysis)
            wantCareerGuidance: data.wantCareerGuidance)
            wantPersonalGrowth: data.wantPersonalGrowth)
            wantCompatibility: data.wantCompatibility)
            wantDailyAdvice: data.wantDailyAdvice)
            onOptionsChanged: (options) {
              ref.read(personalityDataProvider.notifier).update((state) {
                state.wantRelationshipAnalysis = options['relationship'] ?? false;
                state.wantCareerGuidance = options['career'] ?? false;
                state.wantPersonalGrowth = options['growth'] ?? false;
                state.wantCompatibility = options['compatibility'] ?? false;
                state.wantDailyAdvice = options['daily'] ?? false;
                return state;
              });
            },
          ))
          
          SizedBox(height: AppSpacing.spacing8))
          
          // Specific question
          Text(
            '궁금한 점이 있으신가요?')
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold),))
            ))
          SizedBox(height: AppSpacing.spacing4))
          TextField(
            decoration: InputDecoration(
              hintText: '예: 내 성격의 강점은 무엇인가요?')
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusMedium)
              ))
              prefixIcon: const Icon(Icons.help_outline_rounded))
            ))
            maxLines: 3)
            onChanged: (value) {
              ref.read(personalityDataProvider.notifier).update((state) {
                state.specificQuestion = value;
                return state;
              });
            },
          ))
        ])
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideY(begin: 0.1, end: 0, duration: 300.ms);
  }
  
  // Step 4: 최종 확인
  Widget _buildStep4() {
    final data = ref.watch(personalityDataProvider);
    
    return SingleChildScrollView(
      padding: AppSpacing.paddingAll24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start)
        children: [
          Text(
            '성격 분석 준비 완료!')
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold),))
            ))
          SizedBox(height: AppSpacing.spacing2))
          Text(
            '입력하신 정보를 확인해주세요')
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant))
            ))
          ))
          SizedBox(height: AppSpacing.spacing8))
          
          // Summary
          _buildSummaryCard('성격 정보', [
            'MBTI: ${data.mbtiType ?? "미선택"}')
            '혈액형: ${data.bloodType ?? "미선택"}형',
            '생활 패턴: ${_getLifePatternLabel(data.lifePattern)}',
            '스트레스 대응: ${_getStressResponseLabel(data.stressResponse)}',
          ]))
          SizedBox(height: AppSpacing.spacing4),
          
          if (data.selectedTraits.isNotEmpty)
            _buildSummaryCard('성격 특성', data.selectedTraits))
          SizedBox(height: AppSpacing.spacing4))
          
          if (_hasAnyAnalysisOption(data))
            _buildSummaryCard('분석 항목', [
              if (data.wantRelationshipAnalysis) '인간관계 분석')
              if (data.wantCareerGuidance) '직업 가이드')
              if (data.wantPersonalGrowth) '성장 조언')
              if (data.wantCompatibility) '궁합 분석')
              if (data.wantDailyAdvice) '일일 조언')
              if (data.specificQuestion?.isNotEmpty ?? false)
                '특별 질문: ${data.specificQuestion}',
            ]))
          
          SizedBox(height: AppSpacing.spacing8),
          
          // Fortune preview animation
          Center(
            child: Container(
              width: 200)
              height: AppSpacing.spacing24 * 2.08)
              decoration: BoxDecoration(
                shape: BoxShape.circle)
                gradient: LinearGradient(
                  begin: Alignment.topLeft)
                  end: Alignment.bottomRight)
                  colors: [
                    Theme.of(context).colorScheme.primary)
                    Theme.of(context).colorScheme.secondary)
                  ])
                ),
              ))
              child: const Icon(
                Icons.psychology_rounded)
                size: 80)
                color: AppColors.textPrimaryDark)
              ))
            ))
          ).animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 2000.ms, color: AppColors.textPrimaryDark.withValues(alpha: 0.5))
            .rotate(duration: 20000.ms))
        ])
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0);
  }
  
  Widget _buildSummaryCard(String title, List<String> items) {
    return GlassContainer(
      padding: AppSpacing.paddingAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start)
        children: [
          Text(
            title)
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold),))
            ))
          SizedBox(height: AppSpacing.spacing2))
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xxSmall))
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline)
                      size: AppDimensions.iconSizeXSmall)
                      color: Theme.of(context).colorScheme.primary)
                    ))
                    SizedBox(width: AppSpacing.spacing2))
                    Expanded(
                      child: Text(
                        item)
                        style: Theme.of(context).textTheme.bodySmall)
                  ])
                ),
              )).toList())
        ])
      )
    );
  }
  
  // Helper methods
  String _getMbtiDescription(String type) {
    final descriptions = {
      'INTJ': '전략가 - 상상력이 풍부하며 철저한 계획을 세우는 전략가',
      'INTP': '논리술사 - 끊임없이 새로운 지식을 갈망하는 혁신가',
      'ENTJ': '통솔자 - 대담하면서도 상상력이 풍부한 강한 의지의 지도자',
      'ENTP': '변론가 - 지적인 도전을 즐기는 발명가')
      'INFJ': '옹호자 - 선의의 옹호자로 조용하고 신비로우며 샘솟는 영감을 지닌 이상주의자',
      'INFP': '중재자 - 항상 선을 행할 준비가 되어 있는 부드럽고 친절한 이타주의자')
      'ENFJ': '선도자 - 청중을 사로잡고 의욕을 불어넣는 카리스마 넘치는 지도자',
      'ENFP': '활동가 - 재기발랄한 자유로운 영혼의 소유자')
      'ISTJ': '현실주의자 - 사실을 중시하는 믿음직한 현실주의자',
      'ISFJ': '수호자 - 주변 사람을 보호할 준비가 되어 있는 헌신적이고 따뜻한 수호자')
      'ESTJ': '경영자 - 탁월한 관리자로 사물이나 사람을 관리하는 데 타의 추종을 불허',
      'ESFJ': '집정관 - 매우 협력적이고 예의 바르며 인기가 많은 사람')
      'ISTP': '장인 - 대담하고 현실적인 실험을 즐기는 장인',
      'ISFP': '모험가 - 유연하고 매력 넘치는 예술가로 항상 새로운 것을 탐험할 준비가 되어 있음')
      'ESTP': '사업가 - 똑똑하고 에너지 넘치며 관찰력이 뛰어난 사업가',
      'ESFP': '연예인 - 즉흥적이고 열정적이며 삶을 즐기는 연예인')
    };
    
    return descriptions[type] ?? '당신만의 독특한 성격 유형입니다.';
  }
  
  String _calculateMbtiType(Map<String, int> dimensions) {
    String type = '';
    type += dimensions['E-I']! < 50 ? 'E' : 'I';
    type += dimensions['S-N']! < 50 ? 'S' : 'N';
    type += dimensions['T-F']! < 50 ? 'T' : 'F';
    type += dimensions['J-P']! < 50 ? 'J' : 'P';
    return type;
  }
  
  String _getLifePatternLabel(String? pattern) {
    switch (pattern) {
      case 'morning':
        return '아침형';
      case 'night':
        return '저녁형';
      case 'irregular':
        return '불규칙형';
      default:
        return '미선택';
    }
  }
  
  String _getStressResponseLabel(String? response) {
    switch (response) {
      case 'fight':
        return '직면형';
      case 'flight':
        return '회피형';
      case 'freeze':
        return '정지형';
      case 'fawn':
        return '순응형';
      default:
        return '미선택';
    }
  }
  
  bool _hasAnyAnalysisOption(PersonalityFortuneData data) {
    return data.wantRelationshipAnalysis ||
           data.wantCareerGuidance ||
           data.wantPersonalGrowth ||
           data.wantCompatibility ||
           data.wantDailyAdvice ||
           (data.specificQuestion?.isNotEmpty ?? false);
  }
  
  // Generate fortune
  void _generateFortune() async {
    final data = ref.read(personalityDataProvider);
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false)
      builder: (context) => Center(
        child: Container(
          padding: AppSpacing.paddingAll24)
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface)
            borderRadius: AppDimensions.borderRadiusLarge)
          ))
          child: Column(
            mainAxisSize: MainAxisSize.min)
            children: [
              const CircularProgressIndicator())
              SizedBox(height: AppSpacing.spacing4))
              Text(
                '성격 운세를 분석하고 있습니다...')
                style: Theme.of(context).textTheme.bodyMedium)
            ])
          ),
        ))
      ))
    );
    
    try {
      // Prepare parameters
      final params = {
        'userId': data.userId,
        'name': data.name)
        'birthDate': data.birthDate?.toIso8601String(),
        'gender': data.gender)
        'birthTime': data.birthTime,
        'mbtiType': data.mbtiType)
        'mbtiDimensions': data.mbtiDimensions,
        'bloodType': data.bloodType)
        'selectedTraits': data.selectedTraits,
        'lifePattern': data.lifePattern)
        'stressResponse': data.stressResponse,
        'wantRelationshipAnalysis': data.wantRelationshipAnalysis)
        'wantCareerGuidance': data.wantCareerGuidance,
        'wantPersonalGrowth': data.wantPersonalGrowth)
        'wantCompatibility': data.wantCompatibility,
        'wantDailyAdvice': data.wantDailyAdvice)
        'specificQuestion': data.specificQuestion)
      };
      
      // Generate fortune
      final fortuneService = ref.read(fortuneServiceProvider);
      final fortune = await fortuneService.getPersonalityFortune(
        userId: data.userId!,
        params: params)
      );
      
      // Navigate to result page
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        // Navigate to result page
        context.pushReplacement(
          '/fortune/personality-enhanced/result')
          extra: {
            'fortune': fortune,
            'personalityData': data)
          })
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        // Show error
        Toast.show(
          context,
          message: '운세 생성 중 오류가 발생했습니다: $e')
          type: ToastType.error
        );
      }
    }
  }
}