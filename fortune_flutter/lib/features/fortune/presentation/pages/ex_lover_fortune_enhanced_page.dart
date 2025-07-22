import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
  const ExLoverFortuneEnhancedPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ExLoverFortuneEnhancedPage> createState() => _ExLoverFortuneEnhancedPageState();
}

class _ExLoverFortuneEnhancedPageState extends ConsumerState<ExLoverFortuneEnhancedPage> {
  final PageController _pageController = PageController();
  final ImagePicker _imagePicker = ImagePicker();
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            if (currentStep > 0) {
              ref.read(exLoverStepProvider.notifier).previousStep();
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF8B5CF6),
              const Color(0xFFEC4899),
              const Color(0xFF3B82F6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress Indicator
              _buildProgressIndicator(currentStep),
              
              // Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1BasicInfo(),
                    _buildStep2RelationshipInfo(),
                    _buildStep3AdditionalAnalysis(),
                    _buildStep4Confirmation(),
                  ],
                ),
              ),
            ],
          ),
        ),
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
              fontWeight: FontWeight.bold,
            ),
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
                  style: theme.textTheme.headlineSmall,
                ),
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
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface.withOpacity(0.5),
                  ),
                  onChanged: (value) {
                    ref.read(exLoverDataProvider.notifier).update((state) {
                      state.name = value;
                      return state;
                    });
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
                      lastDate: DateTime.now(),
                    );
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
                      ),
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
                      style: theme.textTheme.bodyLarge,
                    ),
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
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface.withOpacity(0.5),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('선택 안함')),
                    ...[
                      'INTJ', 'INTP', 'ENTJ', 'ENTP',
                      'INFJ', 'INFP', 'ENFJ', 'ENFP',
                      'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
                      'ISTP', 'ISFP', 'ESTP', 'ESFP',
                    ].map((mbti) => DropdownMenuItem(
                      value: mbti,
                      child: Text(mbti),
                    )),
                  ],
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
                if (_validateStep1()) {
                  ref.read(exLoverStepProvider.notifier).nextStep();
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '다음',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStep2RelationshipInfo() {
    final theme = Theme.of(context);
    final data = ref.watch(exLoverDataProvider);
    
    final durations = {
      'short': '6개월 미만',
      'medium': '6개월-1년',
      'long': '1-3년',
      'verylong': '3년 이상',
    };
    
    final breakupReasons = {
      'distance': '물리적/정서적 거리',
      'values': '가치관 차이',
      'timing': '시기가 맞지 않음',
      'cheating': '신뢰 문제',
      'family': '가족 반대',
      'growth': '서로 다른 성장',
      'communication': '소통 부재',
      'other': '기타',
    };
    
    final timePeriods = {
      'recent': '1개월 미만',
      'short': '1-3개월',
      'medium': '3-6개월',
      'long': '6개월-1년',
      'verylong': '1년 이상',
    };
    
    final feelings = {
      'miss': '그리움',
      'anger': '분노/원망',
      'sadness': '슬픔',
      'relief': '안도감',
      'indifferent': '무덤덤',
      'grateful': '감사함',
      'confused': '혼란스러움',
    };
    
    final currentStatuses = {
      'single': '싱글',
      'dating': '새로운 사람과 연애 중',
      'healing': '치유 중',
      'confused': '혼란스러운 상태',
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
                      style: theme.textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 교제 기간
                Text(
                  '교제 기간',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                
                // 이별 이유
                Text(
                  '이별 이유',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                
                // 이별 후 시간
                Text(
                  '이별 후 시간',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
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
                      style: theme.textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 현재 감정
                Text(
                  '전 애인에 대한 현재 감정',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                      selectedColor: _getFeelingColor(entry.key).withOpacity(0.2),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                
                // 연락 여부
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '아직 연락하고 있나요?',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    Switch(
                      value: data.stillInContact,
                      onChanged: (value) {
                        ref.read(exLoverDataProvider.notifier).update((state) {
                          state.stillInContact = value;
                          return state;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // 미련 여부
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '아직 미련이 남아있나요?',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    Switch(
                      value: data.hasUnresolvedFeelings,
                      onChanged: (value) {
                        ref.read(exLoverDataProvider.notifier).update((state) {
                          state.hasUnresolvedFeelings = value;
                          return state;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 현재 상태
                Text(
                  '현재 연애 상태',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                    );
                  }).toList(),
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
                if (_validateStep2()) {
                  ref.read(exLoverStepProvider.notifier).nextStep();
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '다음',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
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
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '더 깊이 있는 분석을 원하시면 선택해주세요',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
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
                  },
                ),
                
                if (data.useImageAnalysis) ...[
                  const SizedBox(height: 16),
                  _buildImageUploadSection(),
                ],
                
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
                  },
                ),
                
                if (data.useInstagramAnalysis) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: data.instagramLink,
                    decoration: InputDecoration(
                      labelText: '인스타그램 아이디 또는 링크',
                      hintText: '@username 또는 https://instagram.com/...',
                      prefixIcon: const Icon(Icons.link),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface.withOpacity(0.5),
                    ),
                    onChanged: (value) {
                      ref.read(exLoverDataProvider.notifier).update((state) {
                        state.instagramLink = value;
                        return state;
                      });
                    },
                  ),
                ],
                
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
                  },
                ),
                
                if (data.useStoryConsultation) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: data.detailedStory,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: '사연을 자세히 적어주세요',
                      hintText: '어떤 관계였는지, 왜 헤어졌는지, 현재 마음은 어떤지 자유롭게 작성해주세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface.withOpacity(0.5),
                    ),
                    onChanged: (value) {
                      ref.read(exLoverDataProvider.notifier).update((state) {
                        state.detailedStory = value;
                        return state;
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
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
                      curve: Curves.easeInOut,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Colors.white),
                  ),
                  child: const Text(
                    '건너뛰기',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(exLoverStepProvider.notifier).nextStep();
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '다음',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                
                // 기본 정보 요약
                _buildSummaryItem('이름', data.name),
                _buildSummaryItem(
                  '생년월일', 
                  data.birthDate != null 
                    ? '${data.birthDate!.year}년 ${data.birthDate!.month}월 ${data.birthDate!.day}일' 
                    : '미입력'
                ),
                _buildSummaryItem('성별', data.gender == 'male' ? '남성' : '여성'),
                if (data.mbti != null) 
                  _buildSummaryItem('MBTI', data.mbti!),
                
                const Divider(height: 32),
                
                // 추가 분석 요약
                Text(
                  '선택한 분석',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                _buildAnalysisSummary('기본 분석', 12, true),
                if (data.useImageAnalysis)
                  _buildAnalysisSummary('사진 분석', 10, true),
                if (data.useInstagramAnalysis)
                  _buildAnalysisSummary('인스타그램 분석', 15, true),
                if (data.useStoryConsultation)
                  _buildAnalysisSummary('사연 상담', 30, true),
                
                const Divider(height: 32),
                
                // 총 영혼 소비량
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '총 필요 영혼',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$totalSouls',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                ),
                backgroundColor: theme.colorScheme.primary,
              ),
              child: Text(
                '운세 분석 시작 ($totalSouls 영혼)',
                style: const TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnalysisOption({
    required String title,
    required String description,
    required IconData icon,
    required int soulCost,
    required bool isSelected,
    required Function(bool) onChanged,
  }) {
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
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected 
            ? theme.colorScheme.primary.withOpacity(0.1) 
            : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (value) => onChanged(value ?? false),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+$soulCost',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildImageUploadSection() {
    final theme = Theme.of(context);
    final data = ref.watch(exLoverDataProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사진 업로드 (최대 3장)',
          style: theme.textTheme.bodyMedium,
        ),
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
                        fit: BoxFit.cover,
                      ),
                    ),
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
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              if (data.uploadedImages.length < 3)
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '사진 추가',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
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
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
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
            color: isIncluded ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.favorite,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                '$souls',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  bool _validateStep1() {
    final data = ref.read(exLoverDataProvider);
    
    if (data.name.isEmpty) {
      Toast.error(context, '이름을 입력해주세요');
      return false;
    }
    
    if (data.birthDate == null) {
      Toast.error(context, '생년월일을 선택해주세요');
      return false;
    }
    
    if (data.gender == null) {
      Toast.error(context, '성별을 선택해주세요');
      return false;
    }
    
    return true;
  }
  
  bool _validateStep2() {
    final data = ref.read(exLoverDataProvider);
    
    if (data.relationshipDuration == null) {
      Toast.error(context, '교제 기간을 선택해주세요');
      return false;
    }
    
    if (data.breakupReason == null) {
      Toast.error(context, '이별 이유를 선택해주세요');
      return false;
    }
    
    if (data.timeSinceBreakup == null) {
      Toast.error(context, '이별 후 시간을 선택해주세요');
      return false;
    }
    
    if (data.currentFeeling == null) {
      Toast.error(context, '현재 감정을 선택해주세요');
      return false;
    }
    
    if (data.currentStatus == null) {
      Toast.error(context, '현재 연애 상태를 선택해주세요');
      return false;
    }
    
    return true;
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
      case 'miss':
        return Colors.blue;
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
      case 'confused':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
  
  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    
    if (pickedFile != null) {
      ref.read(exLoverDataProvider.notifier).update((state) {
        if (state.uploadedImages.length < 3) {
          state.uploadedImages.add(File(pickedFile.path));
        }
        return state;
      });
    }
  }
  
  Future<void> _startFortuneTelling() async {
    final data = ref.read(exLoverDataProvider);
    final totalSouls = _calculateTotalSouls();
    
    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: GlassContainer(
          padding: const EdgeInsets.all(32),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              Text(
                '운세를 분석하고 있습니다...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
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
          encodedImages.add(base64Encode(bytes));
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
        'detailedStory': data.detailedStory,
      };
      
      // API 호출
      final fortune = await fortuneService.getFortune(
        fortuneType: 'ex-lover-enhanced',
        userId: user.id,
        params: params,
      );
      
      Navigator.pop(context); // 로딩 닫기
      
      // 결과 페이지로 이동
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExLoverFortuneResultPage(
              fortuneData: fortune.toJson(),
            ),
          ),
        );
      }
      
    } catch (e) {
      Navigator.pop(context); // 로딩 닫기
      Toast.error(context, '운세 분석 중 오류가 발생했습니다: $e');
    }
  }
}