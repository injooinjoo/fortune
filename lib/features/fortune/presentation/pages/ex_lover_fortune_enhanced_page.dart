import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';

import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/toast.dart';
import '../../../../core/theme/app_theme.dart';
import 'ex_lover_fortune_result_page.dart';

// Step 관리를 위한 StateNotifier
class ExLoverStepNotifier extends StateNotifier<int> {
  ExLoverStepNotifier() : super(0);
  
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

final exLoverStepProvider = StateNotifierProvider<ExLoverStepNotifier, int>((ref) {
  return ExLoverStepNotifier();
});

// 데이터 모델
class ExLoverFortuneData {
  // Step 1: 기본 정보
  String name = '';
  DateTime? birthDate;
  String? gender;
  String? mbti;
  
  // Step 2: 관계 정보
  String? relationshipDuration;
  String? breakupReason;
  String? timeSinceBreakup;
  String? currentFeeling;
  bool stillInContact = false;
  bool hasUnresolvedFeelings = false;
  List<String> lessonsLearned = [];
  String? currentStatus;
  bool readyForNewRelationship = false;
  
  // Step 3: 추가 분석
  List<File> uploadedImages = [];
  String? instagramLink;
  String? detailedStory;
  
  // 선택한 추가 분석 옵션
  bool useImageAnalysis = false;
  bool useInstagramAnalysis = false;
  bool useStoryConsultation = false;
}

final exLoverDataProvider = StateProvider<ExLoverFortuneData>((ref) {
  return ExLoverFortuneData();
});

class ExLoverFortuneEnhancedPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extras;
  
  const ExLoverFortuneEnhancedPage({Key? key, this.extras}) : super(key: key);

  @override
  ConsumerState<ExLoverFortuneEnhancedPage> createState() => _ExLoverFortuneEnhancedPageState();
}

class _ExLoverFortuneEnhancedPageState extends ConsumerState<ExLoverFortuneEnhancedPage> 
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploadingImage = false;
  
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this);
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut));
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack));
    
    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    
    // Check if we should auto-generate
    if (widget.extras?['autoGenerate'] == true) {
      // Skip to the last step if we have the necessary data
      _handleAutoGenerate();
    } else {
      // Load saved progress if exists
      _loadSavedProgress();
    }
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
  
  void _handleAutoGenerate() async {
    // Get user profile data from extras if available
    final fortuneParams = widget.extras?['fortuneParams'] as Map<String, dynamic>?;
    
    if (fortuneParams != null) {
      // Update the provider with basic info from user profile
      ref.read(exLoverDataProvider.notifier).update((state) {
        // The SimpleFortunInfoSheet would have passed basic user info
        // For ex-lover fortune, we need more specific data, so just set basics
        return state;
      });
    }
    
    // For ex-lover fortune, we can't auto-generate without the specific relationship data
    // So just load saved progress if any
    _loadSavedProgress();
  }
  
  Future<void> _loadSavedProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedDataJson = prefs.getString('ex_lover_fortune_progress');
      
      if (savedDataJson != null) {
        final savedData = jsonDecode(savedDataJson);
        final currentStep = savedData['currentStep'] ?? 0;
        
        // Restore step
        ref.read(exLoverStepProvider.notifier).setStep(currentStep);
        
        // Restore data
        ref.read(exLoverDataProvider.notifier).update((state) {
          state.name = savedData['name'] ?? '';
          if (savedData['birthDate'] != null) {
            state.birthDate = DateTime.parse(savedData['birthDate']);
          }
          state.gender = savedData['gender'];
          state.mbti = savedData['mbti'];
          state.relationshipDuration = savedData['relationshipDuration'];
          state.breakupReason = savedData['breakupReason'];
          state.timeSinceBreakup = savedData['timeSinceBreakup'];
          state.currentFeeling = savedData['currentFeeling'];
          state.stillInContact = savedData['stillInContact'] ?? false;
          state.hasUnresolvedFeelings = savedData['hasUnresolvedFeelings'] ?? false;
          state.currentStatus = savedData['currentStatus'];
          state.readyForNewRelationship = savedData['readyForNewRelationship'] ?? false;
          state.useImageAnalysis = savedData['useImageAnalysis'] ?? false;
          state.useInstagramAnalysis = savedData['useInstagramAnalysis'] ?? false;
          state.useStoryConsultation = savedData['useStoryConsultation'] ?? false;
          state.instagramLink = savedData['instagramLink'];
          state.detailedStory = savedData['detailedStory'];
          return state;
        });
        
        // Navigate to saved step
        if (currentStep > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _pageController.jumpToPage(currentStep);
          });
        }
        
        // Show restored message
        if (mounted) {
          Toast.success(context, '이전 진행상황을 불러왔습니다');
        }
      }
    } catch (e) {
      print('Fortune cached');
    }
  }
  
  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = ref.read(exLoverDataProvider);
      final currentStep = ref.read(exLoverStepProvider);
      
      final saveData = {
        'currentStep': currentStep,
        'name': data.name,
        'birthDate': data.birthDate?.toIso8601String(),
        'gender': data.gender,
        'mbti': data.mbti,
        'relationshipDuration': data.relationshipDuration,
        'breakupReason': data.breakupReason,
        'timeSinceBreakup': data.timeSinceBreakup,
        'currentFeeling': data.currentFeeling,
        'stillInContact': data.stillInContact,
        'hasUnresolvedFeelings': data.hasUnresolvedFeelings,
        'currentStatus': data.currentStatus,
        'readyForNewRelationship': data.readyForNewRelationship,
        'useImageAnalysis': data.useImageAnalysis,
        'useInstagramAnalysis': data.useInstagramAnalysis,
        'useStoryConsultation': data.useStoryConsultation,
        'instagramLink': data.instagramLink,
        'detailedStory': data.detailedStory,
        'savedAt': null};
      
      await prefs.setString('ex_lover_fortune_progress', jsonEncode(saveData));
    } catch (e) {
      print('Fortune cached');
    }
  }
  
  Future<void> _clearSavedProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('ex_lover_fortune_progress');
    } catch (e) {
      print('Fortune cached');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = ref.watch(exLoverStepProvider);
    final theme = Theme.of(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '헤어진 애인 운세',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            if (currentStep > 0) {
              ref.read(exLoverStepProvider.notifier).previousStep();
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut
              );
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getGradientColors(ref.watch(exLoverDataProvider).currentFeeling),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Progress Indicator with animation
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: _buildProgressIndicator(currentStep));
                      }),
                    
                    // Content with page transitions
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (index) {
                          // Trigger animation on page change
                          _scaleController.forward(from: 0.0);
                          _saveProgress(); // Auto-save progress
                        },
                        children: [
                          _buildAnimatedStep(_buildStep1BasicInfo()),
                          _buildAnimatedStep(_buildStep2RelationshipInfo()),
                          _buildAnimatedStep(_buildStep3AdditionalAnalysis()),
                          _buildAnimatedStep(_buildStep4Confirmation()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildProgressIndicator(int currentStep) {
    final theme = Theme.of(context);
    final steps = ['기본 정보', '관계 정보', '추가 분석', '확인'];
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: List.generate(4, (index) {
              final isActive = index <= currentStep;
              final isCompleted = index < currentStep;
              
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: isActive 
                            ? Colors.white 
                            : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (index < 3) const SizedBox(width: 8),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            steps[currentStep],
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStep1BasicInfo() {
    final theme = Theme.of(context);
    final data = ref.watch(exLoverDataProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '기본 정보를 입력해주세요',
                  style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  '정확한 운세 분석을 위해 필요합니다',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Name Input
                TextFormField(
                  initialValue: data.name,
                  decoration: InputDecoration(
                    labelText: '이름',
                    hintText: '이름을 입력하세요',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    filled: true,
                    fillColor: theme.colorScheme.surface.withOpacity(0.5),
                  ),
                  onChanged: (value) {
                    ref.read(exLoverDataProvider.notifier).update((state) {
                      state.name = value;
                      return state;
                    });
                    _saveProgress();
                  },
                ),
                const SizedBox(height: 16),
                
                // Birth Date Picker
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: data.birthDate ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now());
                    if (date != null) {
                      ref.read(exLoverDataProvider.notifier).update((state) {
                        state.birthDate = date;
                        return state;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: '생년월일',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      filled: true,
                      fillColor: theme.colorScheme.surface.withOpacity(0.5),
                    ),
                    child: Text(
                      data.birthDate != null
                          ? '${data.birthDate!.year}년 ${data.birthDate!.month}월 ${data.birthDate!.day}일'
                          : '생년월일을 선택하세요',
                      style: TextStyle(
                        color: data.birthDate != null
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
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
                          child: GestureDetector(
                            onTap: () {
                              ref.read(exLoverDataProvider.notifier).update((state) {
                                state.gender = 'male';
                                return state;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: data.gender == 'male'
                                    ? theme.colorScheme.primary.withOpacity(0.2)
                                    : theme.colorScheme.surface.withOpacity(0.5),
                                border: Border.all(
                                  color: data.gender == 'male'
                                      ? theme.colorScheme.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  '남성',
                                  style: TextStyle(
                                    fontWeight: data.gender == 'male' 
                                        ? FontWeight.bold 
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              ref.read(exLoverDataProvider.notifier).update((state) {
                                state.gender = 'female';
                                return state;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: data.gender == 'female'
                                    ? theme.colorScheme.primary.withOpacity(0.2)
                                    : theme.colorScheme.surface.withOpacity(0.5),
                                border: Border.all(
                                  color: data.gender == 'female'
                                      ? theme.colorScheme.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  '여성',
                                  style: TextStyle(
                                    fontWeight: data.gender == 'female' 
                                        ? FontWeight.bold 
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // MBTI Selection (Optional)
                DropdownButtonFormField<String>(
                  value: data.mbti,
                  decoration: InputDecoration(
                    labelText: 'MBTI (선택)',
                    prefixIcon: const Icon(Icons.psychology),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    filled: true,
                    fillColor: theme.colorScheme.surface.withOpacity(0.5)),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('선택 안함')),
                    ...[
                      'INTJ', 'INTP', 'ENTJ', 'ENTP',
                      'INFJ', 'INFP', 'ENFJ', 'ENFP',
                      'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
                      'ISTP', 'ISFP', 'ESTP', 'ESFP'].map((mbti) => DropdownMenuItem(
                      value: mbti,
                      child: Text(mbti))).toList()],
                  onChanged: (value) {
                    ref.read(exLoverDataProvider.notifier).update((state) {
                      state.mbti = value;
                      return state;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Next Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_validateStep1(), {
                  ref.read(exLoverStepProvider.notifier).nextStep();
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
              child: const Text(
                '다음',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]);
  }
  
  Widget _buildStep2RelationshipInfo() {
    final theme = Theme.of(context);
    final data = ref.watch(exLoverDataProvider);
    
    final durations = {
      'short': '6개월 미만',
      'medium': '6개월-1년',
      'long': '1-3년',
      'verylong': '3년 이상'
  };
    
    final breakupReasons = {
      'distance': '물리적/정서적 거리',
      'values': '가치관 차이',
      'timing': '시기가 맞지 않음',
      'cheating': '신뢰 문제',
      'family': '가족 반대',
      'growth': '서로 다른 성장',
      'communication': '소통 부재',
      'other': '기타'
  };
    
    final timePeriods = {
      'recent': '1개월 미만',
      'short': '1-3개월',
      'medium': '3-6개월',
      'long': '6개월-1년',
      'verylong': '1년 이상'
  };
    
    final feelings = {
      'miss': '그리움',
      'anger': '분노/원망',
      'sadness': '슬픔',
      'relief': '안도감',
      'indifferent': '무덤덤',
      'grateful': '감사함',
      'confused': '혼란스러움'
  };
    
    final currentStatuses = {
      'single': '싱글',
      'dating': '새로운 사람과 연애 중',
      'healing': '치유 중',
      'confused': '혼란스러운 상태'
  };
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 관계 기간
          GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.favorite, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '관계 정보',
                      style: theme.textTheme.headlineSmall)])),
                const SizedBox(height: 16),
                
                // 교제 기간
                Text(
                  '교제 기간',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: durations.entries.map((entry) {
                    final isSelected = data.relationshipDuration == entry.key;
                    
                    return ChoiceChip(
                      label: Text(entry.value),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(exLoverDataProvider.notifier).update((state) {
                            state.relationshipDuration = entry.key;
                            return state;
                          });
                        }
                      },
                      selectedColor: theme.colorScheme.primary.withOpacity(0.2));
                  }).toList(),
                const SizedBox(height: 16),
                
                // 이별 이유
                Text(
                  '이별 이유',
                  style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: breakupReasons.entries.map((entry) {
                    final isSelected = data.breakupReason == entry.key;
                    
                    return ChoiceChip(
                      label: Text(entry.value),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(exLoverDataProvider.notifier).update((state) {
                            state.breakupReason = entry.key;
                            return state;
                          });
                        }
                      },
                      selectedColor: theme.colorScheme.primary.withOpacity(0.2));
                  }).toList(),
                const SizedBox(height: 16),
                
                // 이별 후 시간
                Text(
                  '이별 후 시간',
                  style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: timePeriods.entries.map((entry) {
                    final isSelected = data.timeSinceBreakup == entry.key;
                    
                    return ChoiceChip(
                      label: Text(entry.value),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(exLoverDataProvider.notifier).update((state) {
                            state.timeSinceBreakup = entry.key;
                            return state;
                          });
                        }
                      },
                      selectedColor: theme.colorScheme.primary.withOpacity(0.2));
                  }).toList()),
          const SizedBox(height: 16),
          
          // 현재 감정
          GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.mood, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '현재 상태',
                      style: theme.textTheme.headlineSmall)])),
                const SizedBox(height: 16),
                
                // 현재 감정
                Text(
                  '전 애인에 대한 현재 감정',
                  style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: feelings.entries.map((entry) {
                    final isSelected = data.currentFeeling == entry.key;
                    
                    return ChoiceChip(
                      label: Text(entry.value),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(exLoverDataProvider.notifier).update((state) {
                            state.currentFeeling = entry.key;
                            return state;
                          });
                        }
                      },
                      selectedColor: _getFeelingColor(entry.key).withOpacity(0.2));
                  }).toList(),
                const SizedBox(height: 16),
                
                // 연락 여부
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '아직 연락하고 있나요?',
                        style: theme.textTheme.bodyLarge)),
                    Switch(
                      value: data.stillInContact,
                      onChanged: (value) {
                        ref.read(exLoverDataProvider.notifier).update((state) {
                          state.stillInContact = value;
                          return state;
                        });
                      })]),
                const SizedBox(height: 8),
                
                // 미련 여부
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '아직 미련이 남아있나요?',
                        style: theme.textTheme.bodyLarge)),
                    Switch(
                      value: data.hasUnresolvedFeelings,
                      onChanged: (value) {
                        ref.read(exLoverDataProvider.notifier).update((state) {
                          state.hasUnresolvedFeelings = value;
                          return state;
                        });
                      })]),
                const SizedBox(height: 16),
                
                // 현재 상태
                Text(
                  '현재 연애 상태',
                  style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: currentStatuses.entries.map((entry) {
                    final isSelected = data.currentStatus == entry.key;
                    
                    return ChoiceChip(
                      label: Text(entry.value),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(exLoverDataProvider.notifier).update((state) {
                            state.currentStatus = entry.key;
                            return state;
                          });
                        }
                      },
                      selectedColor: theme.colorScheme.primary.withOpacity(0.2));
                  }).toList()),
          const SizedBox(height: 24),
          
          // Next Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_validateStep2(), {
                  ref.read(exLoverStepProvider.notifier).nextStep();
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
              child: const Text(
                '다음',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]);
  }
  
  Widget _buildStep3AdditionalAnalysis() {
    final theme = Theme.of(context);
    final data = ref.watch(exLoverDataProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '추가 분석 옵션',
                  style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  '더 깊이 있는 분석을 원하시면 선택해주세요',
                  style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7)),
                const SizedBox(height: 24),
                
                // 이미지 분석
                _buildAnalysisOption(
                  title: '사진 분석',
                  description: 'AI가 사진을 분석하여 감정 상태를 파악합니다',
                  icon: Icons.photo_camera,
                  soulCost: 10,
                  isSelected: data.useImageAnalysis,
                  onChanged: (value) {
                    ref.read(exLoverDataProvider.notifier).update((state) {
                      state.useImageAnalysis = value;
                      return state;
                    });
                  }),
                
                if (data.useImageAnalysis) ...[
                  const SizedBox(height: 16),
                  _buildImageUploadSection()],
                
                const SizedBox(height: 16),
                
                // 인스타그램 분석
                _buildAnalysisOption(
                  title: '인스타그램 분석',
                  description: '공개 프로필을 분석하여 현재 상태를 파악합니다',
                  icon: Icons.camera_alt,
                  soulCost: 15,
                  isSelected: data.useInstagramAnalysis,
                  onChanged: (value) {
                    ref.read(exLoverDataProvider.notifier).update((state) {
                      state.useInstagramAnalysis = value;
                      return state;
                    });
                  }),
                
                if (data.useInstagramAnalysis) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: data.instagramLink,
                    decoration: InputDecoration(
                      labelText: '인스타그램 아이디 또는 링크',
                      hintText: '),
    https://instagram.com/...',
                      prefixIcon: const Icon(Icons.link),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      filled: true,
                      fillColor: theme.colorScheme.surface.withOpacity(0.5),
                      errorText: _validateInstagramLink(data.instagramLink)),
                    onChanged: (value) {
                      ref.read(exLoverDataProvider.notifier).update((state) {
                        state.instagramLink = value;
                        return state;
                      });
                      _saveProgress();
                    })],
                
                const SizedBox(height: 16),
                
                // 사연 상담
                _buildAnalysisOption(
                  title: '사연 상담',
                  description: 'AI 상담사가 깊이 있는 상담을 제공합니다',
                  icon: Icons.chat,
                  soulCost: 30,
                  isSelected: data.useStoryConsultation,
                  onChanged: (value) {
                    ref.read(exLoverDataProvider.notifier).update((state) {
                      state.useStoryConsultation = value;
                      return state;
                    });
                  }),
                
                if (data.useStoryConsultation) ...[
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        initialValue: data.detailedStory,
                        maxLines: 5,
                        maxLength: 1000,
                        buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '$currentLength / $maxLength',
                              style: theme.textTheme.bodySmall?.copyWith(
            color: currentLength > maxLength! * 0.9
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.onSurface.withOpacity(0.6)));
                        },
                        decoration: InputDecoration(
                          labelText: '사연을 자세히 적어주세요',
                          hintText: '어떤 관계였는지, 왜 헤어졌는지, 현재 마음은 어떤지 자유롭게 작성해주세요',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          filled: true,
                          fillColor: theme.colorScheme.surface.withOpacity(0.5)),
                        onChanged: (value) {
                          ref.read(exLoverDataProvider.notifier).update((state) {
                            state.detailedStory = value;
                            return state;
                          });
                          _saveProgress();
                        })])]])),
          const SizedBox(height: 24),
          
          // Skip & Next Button
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(exLoverStepProvider.notifier).nextStep();
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.white)),
                  child: const Text(
                    '건너뛰기',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(exLoverStepProvider.notifier).nextStep();
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                  child: const Text(
                    '다음',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))])]));
  }
  
  Widget _buildStep4Confirmation() {
    final theme = Theme.of(context);
    final data = ref.watch(exLoverDataProvider);
    final totalSouls = _calculateTotalSouls();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '운세 분석 확인',
                  style: theme.textTheme.headlineSmall),
                const SizedBox(height: 24),
                
                // 기본 정보 요약
                _buildSummaryItem('이름': null,
                _buildSummaryItem(
                  '생년월일': data.birthDate != null }
                    ? '${data.birthDate!.year}년 ${data.birthDate!.month}월 ${data.birthDate!.day}일' 
                    : '미입력'
                ,
                _buildSummaryItem('성별': data.gender == 'male' ? '남성' : '여성',
                if (data.mbti != null),
                  _buildSummaryItem('MBTI': data.mbti!,
                
                const Divider(height: 32),
                
                // 추가 분석 요약
                Text(
                  '선택한 분석',
                  style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                
                _buildAnalysisSummary('기본 분석'),
                if (data.useImageAnalysis)
                  _buildAnalysisSummary('사진 분석'),
                if (data.useInstagramAnalysis)
                  _buildAnalysisSummary('인스타그램 분석'),
                if (data.useStoryConsultation)
                  _buildAnalysisSummary('사연 상담': 30, true,
                
                const Divider(height: 32),
                
                // 총 영혼 소비량
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '총 필요 영혼',
                        style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: theme.colorScheme.primary,
                            size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '$totalSouls',
                            style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold))])])]),
          const SizedBox(height: 24),
          
          // 분석 시작 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startFortuneTelling,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                backgroundColor: theme.colorScheme.primary),
              child: Text(
                '운세 분석 시작 ($totalSouls 영혼)',
                style: const TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: Colors.white))]);
  }
  
  Widget _buildAnalysisOption({
    required String title,
    required String description,
    required IconData icon,
    required int soulCost,
    required bool isSelected,
    required Function(bool) onChanged}) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () => onChanged(!isSelected),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.onSurface.withOpacity(0.3),
            width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
          color: isSelected 
            ? theme.colorScheme.primary.withOpacity(0.1) 
            : null),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.onSurface.withOpacity(0.6)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold)),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7)]),
            Column(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (value) => onChanged(value ?? false)),
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 16,
                      color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      '+$soulCost',
                      style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary))])])]));
  }
  
  Widget _buildImageUploadSection() {
    final theme = Theme.of(context);
    final data = ref.watch(exLoverDataProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사진 업로드 (최대 3장)',
          style: theme.textTheme.bodyMedium)),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...data.uploadedImages.map((image) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        image,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover)),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          ref.read(exLoverDataProvider.notifier).update((state) {
                            state.uploadedImages.remove(image);
                            return state;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white))]),
              if (data.uploadedImages.length < 3),
            GestureDetector(
                  onTap: _isUploadingImage ? null : _pickImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                        width: 2,
                        style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(8),
                    child: _isUploadingImage
                        ? Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary)),
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                color: theme.colorScheme.onSurface.withOpacity(0.6)),
                              const SizedBox(height: 4),
                              Text(
                                '사진 추가',
                                style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6)])]))]);
  }
  
  Widget _buildSummaryItem(String label, String value) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7)),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold)]);
  }
  
  Widget _buildAnalysisSummary(String name, int souls, bool isIncluded) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isIncluded ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: isIncluded ? Colors.green : Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: theme.textTheme.bodyMedium)),
          Row(
            children: [
              Icon(
                Icons.favorite,
                size: 16,
                color: theme.colorScheme.primary),
              const SizedBox(width: 4),
              Text(
                '$souls',
                style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary))])]));
  }
  
  bool _validateStep1() {
    final data = ref.read(exLoverDataProvider);
    
    if (data.name.isEmpty) {
      _showValidationError('이름을 입력해주세요': '상대방의 이름은 운세 분석에 중요한 정보입니다.');
      return false;
    }
    
    if (data.name.length < 2) {
      _showValidationError('올바른 이름을 입력해주세요': '이름은 2글자 이상이어야 합니다.');
      return false;
    }
    
    if (data.birthDate == null) {
      _showValidationError('생년월일을 선택해주세요': '정확한 운세 분석을 위해 필요합니다.');
      return false;
    }
    
    if (data.gender == null) {
      _showValidationError('성별을 선택해주세요': '맞춤형 조언을 위해 필요합니다.');
      return false;
    }
    
    return true;
  }
  
  void _showValidationError(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: theme.textTheme.titleMedium)])),
          content: Text(
            message,
            style: theme.textTheme.bodyMedium)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'))]);
      }
    );
  }
  
  bool _validateStep2() {
    final data = ref.read(exLoverDataProvider);
    
    if (data.relationshipDuration == null) {
      _showValidationError('교제 기간을 선택해주세요': '관계의 깊이를 이해하는데 필요합니다.');
      return false;
    }
    
    if (data.breakupReason == null) {
      _showValidationError('이별 이유를 선택해주세요': '상황을 정확히 분석하기 위해 필요합니다.');
      return false;
    }
    
    if (data.timeSinceBreakup == null) {
      _showValidationError('이별 후 시간을 선택해주세요': '치유 단계를 파악하는데 중요합니다.');
      return false;
    }
    
    if (data.currentFeeling == null) {
      _showValidationError('현재 감정을 선택해주세요': '맞춤형 조언을 위해 필요합니다.');
      return false;
    }
    
    if (data.currentStatus == null) {
      _showValidationError('현재 연애 상태를 선택해주세요': '적절한 조언을 위해 필요합니다.');
      return false;
    }
    
    return true;
  }
  
  String? _validateInstagramLink(String? value) {
    if (value == null || value.isEmpty) {
      return '인스타그램 아이디나 링크를 입력해주세요';
    }
    
    // Check if it's a username (starts with @),
            if (value.startsWith('@'), {
      final username = value.substring(1);
      if (username.isEmpty) {
        return '올바른 아이디를 입력해주세요';
      }
      // Instagram username validation
      final usernameRegex = RegExp(r'^[a-zA-Z0-9._]{1,30}$');
      if (!usernameRegex.hasMatch(username), {
        return '올바른 인스타그램 아이디 형식이 아닙니다';
      }
      return null;
    }
    
    // Check if it's a URL
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?instagram\.com\/[a-zA-Z0-9._]{1,30}\/?',
      caseSensitive: false
    );
    
    if (!urlRegex.hasMatch(value), {
      return '),
    https://instagram.com/username 형식으로 입력해주세요';
    }
    
    return null;
  }
  
  int _calculateTotalSouls() {
    final data = ref.read(exLoverDataProvider);
    int total = 12; // 기본 분석
    
    if (data.useImageAnalysis) total += 10;
    if (data.useInstagramAnalysis) total += 15;
    if (data.useStoryConsultation) total += 30;
    
    return total;
  }
  
  Color _getFeelingColor(String feeling) {
    switch (feeling) {
      case 'miss': return Colors.blue;
      case 'anger':
        return Colors.red;
      case 'sadness':
        return Colors.indigo;
      case 'relief':
        return Colors.green;
      case 'indifferent':
        return Colors.grey;
      case 'grateful':
        return Colors.amber;
      case , 'confused': return Colors.purple;
      default:
        return Colors.grey;}
    }
  }
  
  List<Color> _getGradientColors(String? feeling) {
    if (feeling == null) {
      return [
        const Color(0xFF8B5CF6),
        const Color(0xFFEC4899),
        const Color(0xFF3B82F6)];
    }
    
    switch (feeling) {
      case 'miss':
        return [
          const Color(0xFF5B8DEE),
          const Color(0xFF3F51B5),
          const Color(0xFF7986CB)];
      case 'anger':
        return [
          const Color(0xFFE91E63),
          const Color(0xFFF44336),
          const Color(0xFFFF5252)];
      case 'sadness':
        return [
          const Color(0xFF3F51B5),
          const Color(0xFF303F9F),
          const Color(0xFF5C6BC0)];
      case 'relief':
        return [
          const Color(0xFF4CAF50),
          const Color(0xFF66BB6A),
          const Color(0xFF81C784)];
      case 'grateful':
        return [
          const Color(0xFFFFC107),
          const Color(0xFFFFB300),
          const Color(0xFFFFD54F)];
      case 'confused': return [}
          const Color(0xFF9C27B0),
          const Color(0xFF8E24AA),
          const Color(0xFFBA68C8)];
      default:
        return [
          const Color(0xFF8B5CF6),
          const Color(0xFFEC4899),
          const Color(0xFF3B82F6)];
    }
  }
  
  Widget _buildAnimatedStep(Widget child) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, _) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: 1.0,
            child: child));
      }
    );
  }
  
  Future<void> _pickImage() async {
    // Show bottom sheet to choose between camera and gallery
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라로 촬영'),
              onTap: () => Navigator.pop(context, ImageSource.camera)),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리에서 선택'),
              onTap: () => Navigator.pop(context, ImageSource.gallery)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('취소'),
              onTap: () => Navigator.pop(context)]);
    
    if (source == null) return;
    
    setState(() {
      _isUploadingImage = true;
    });
    
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85);
      
      if (pickedFile != null) {
        // Simulate processing time for better UX
        await Future.delayed(const Duration(milliseconds: 500),;
        
        ref.read(exLoverDataProvider.notifier).update((state) {
          if (state.uploadedImages.length < 3) {
            state.uploadedImages.add(File(pickedFile.path),;
          }
          return state;
        });
        _saveProgress();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('이미지가 추가되었습니다'),
              duration: Duration(seconds: 1));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('없습니다: $e'),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }
  
  Future<void> _startFortuneTelling() async {
    final data = ref.read(exLoverDataProvider);
    final totalSouls = _calculateTotalSouls();
    
    // 로딩 다이얼로그 표시 with comforting messages
    final loadingMessages = [
      '당신의 마음을 읽고 있어요...': '깊은 감정을 분석하고 있어요...',
      '최선의 조언을 준비하고 있어요...': '당신을 위한 메시지를 만들고 있어요...'
  ];
    
    int messageIndex = 0;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Change message every 2 seconds
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted && Navigator.canPop(context), {
                setState(() {
                  messageIndex = (messageIndex + 1) % loadingMessages.length;
                });
              }
            });
            
            return Center(
              child: GlassContainer(
                padding: const EdgeInsets.all(32),
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3),
                    const SizedBox(height: 24),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        loadingMessages[messageIndex],
                        key: ValueKey(messageIndex),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white,
                          fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center)),
                    const SizedBox(height: 8),
                    Text(
                      '잠시만 기다려주세요',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.8)]);
          });
      }
    );
    
    try {
      // Fortune API Service Provider 가져오기
      final fortuneService = ref.read(fortuneServiceProvider);
      final user = ref.read(userProvider).value;
      
      if (user == null) {
        Navigator.pop(context); // 로딩 닫기
        Toast.error(context, '로그인이 필요합니다');
        return;
      }
      
      // 이미지를 Base64로 인코딩
      List<String>? encodedImages;
      if (data.useImageAnalysis && data.uploadedImages.isNotEmpty) {
        encodedImages = [];
        for (final image in data.uploadedImages) {
          final bytes = await image.readAsBytes();
          encodedImages.add(base64Encode(bytes),;
        }
      }
      
      // API 요청 파라미터 구성
      final params = {
        'name': data.name,
        'birthDate': data.birthDate?.toIso8601String(),
        'gender': data.gender,
        'mbtiType': data.mbti,
        'relationshipDuration': data.relationshipDuration,
        'breakupReason': data.breakupReason,
        'timeSinceBreakup': data.timeSinceBreakup,
        'currentFeeling': data.currentFeeling,
        'stillInContact': data.stillInContact,
        'hasUnresolvedFeelings': data.hasUnresolvedFeelings,
        'lessonsLearned': data.lessonsLearned,
        'currentStatus': data.currentStatus,
        'readyForNewRelationship': data.readyForNewRelationship,
        'useImageAnalysis': data.useImageAnalysis,
        'uploadedImages': encodedImages,
        'useInstagramAnalysis': data.useInstagramAnalysis,
        'instagramLink': data.instagramLink,
        'useStoryConsultation': data.useStoryConsultation,
        'detailedStory': null};
      
      // API 호출
      final fortune = await fortuneService.getFortune(
        fortuneType: 'ex-lover-enhanced',
        userId: user.id,
        params: params);
      
      Navigator.pop(context); // 로딩 닫기
      
      // Clear saved progress after successful completion
      await _clearSavedProgress();
      
      // 결과 페이지로 이동
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExLoverFortuneResultPage(
              fortuneData: fortune.toJson());
      }
      
    } catch (e) {
      Navigator.pop(context); // 로딩 닫기
      
      // Enhanced error handling with specific messages
      String errorMessage = '운세 분석 중 오류가 발생했습니다';
      String errorDetails = e.toString();
      
      if (errorDetails.contains('Insufficient soul balance'), {
        errorMessage = '영혼이 부족합니다. 영혼을 충전해주세요.';
        _showSoulRechargeDialog();
      } else if (errorDetails.contains('Network') || errorDetails.contains('SocketException'), {
        errorMessage = '네트워크 연결을 확인해주세요.';
        _showErrorRecoveryDialog(
          title: '네트워크 오류',
          message: errorMessage,
          retryAction: () => _startFortuneTelling();
      } else if (errorDetails.contains('timeout'), {
        errorMessage = '요청 시간이 초과되었습니다. 다시 시도해주세요.';
        _showErrorRecoveryDialog(
          title: '시간 초과',
          message: errorMessage,
          retryAction: () => _startFortuneTelling();
      } else {
        _showErrorRecoveryDialog(
          title: '오류 발생',
          message: errorMessage,
          details: errorDetails,
          retryAction: () => _startFortuneTelling();
      }
    }
  }
  
  void _showErrorRecoveryDialog({
    required String title,
    required String message,
    String? details,
    VoidCallback? retryAction}) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: theme.colorScheme.error,
                size: 28),
              const SizedBox(width: 12),
              Text(title)]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: theme.textTheme.bodyLarge)),
              if (details != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  child: Text(
                    details,
                    style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onErrorContainer),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis))]]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('닫기')),
            if (retryAction != null),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  retryAction();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                child: const Text('다시 시도'))]);
      }
    );
  }
  
  void _showSoulRechargeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          title: Row(
            children: [
              Icon(Icons.favorite, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              const Text('영혼 충전 필요')]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '운세를 보기 위해서는 영혼이 필요합니다.',
                style: theme.textTheme.bodyLarge)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite,
                      color: theme.colorScheme.primary,
                      size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '영혼: ${_calculateTotalSouls()}개',
                      style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary)])]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to soul recharge page
                context.go('/soul-recharge');
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
              child: const Text('영혼 충전하기'))]);
      }
    );
  }
}