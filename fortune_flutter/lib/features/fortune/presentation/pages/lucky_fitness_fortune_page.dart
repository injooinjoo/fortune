import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/toast.dart';

class LuckyFitnessFortunePage extends BaseFortunePage {
  const LuckyFitnessFortunePage({Key? key})
      : super(
          key: key,
          title: '헬스 운세',
          description: '오늘의 운동을 위한 최적의 가이드',
          fortuneType: 'lucky-fitness',
          requiresUserInfo: true,
        );

  @override
  ConsumerState<LuckyFitnessFortunePage> createState() => _LuckyFitnessFortunePageState();
}

class _LuckyFitnessFortunePageState extends BaseFortunePageState<LuckyFitnessFortunePage> {
  // User fitness info
  String? _fitnessLevel;
  String? _workoutFrequency;
  String? _preferredTime;
  String? _workoutGoal;
  List<String> _focusMuscles = [];
  bool _hasGymMembership = false;
  String? _workoutStyle;
  String? _restDay;
  
  final Map<String, String> _levels = {
    'beginner': '초급 (6개월 미만)',
    'intermediate': '중급 (6개월-2년)',
    'advanced': '고급 (2-5년)',
    'expert': '전문가 (5년 이상)',
    'athlete': '선수급',
  };
  
  final Map<String, String> _frequencies = {
    'rarely': '주 1-2회',
    'moderate': '주 3-4회',
    'frequent': '주 5-6회',
    'daily': '매일',
    'twice_daily': '하루 2회',
  };
  
  final Map<String, String> _times = {
    'early_morning': '새벽 (5-7시)',
    'morning': '아침 (7-10시)',
    'lunch': '점심 (11-14시)',
    'afternoon': '오후 (14-17시)',
    'evening': '저녁 (17-20시)',
    'night': '밤 (20시 이후)',
  };
  
  final Map<String, String> _goals = {
    'muscle': '근육 증가',
    'strength': '근력 향상',
    'weight_loss': '체중 감량',
    'endurance': '지구력 향상',
    'definition': '근육 선명도',
    'health': '건강 유지',
    'performance': '운동 능력 향상',
    'rehabilitation': '재활/회복',
  };
  
  final List<String> _muscleOptions = [
    '가슴',
    '등',
    '어깨',
    '이두',
    '삼두',
    '복근',
    '하체',
    '둔근',
    '종아리',
    '전신',
  ];
  
  final Map<String, String> _styles = {
    'bodybuilding': '보디빌딩',
    'powerlifting': '파워리프팅',
    'crossfit': '크로스핏',
    'functional': '기능성 운동',
    'calisthenics': '맨몸 운동',
    'circuit': '서킷 트레이닝',
    'hiit': 'HIIT',
    'traditional': '전통적 웨이트',
  };
  
  final Map<String, String> _restDays = {
    'none': '휴식일 없음',
    'one': '주 1일',
    'two': '주 2일',
    'three': '주 3일',
    'flexible': '유동적',
  };

  // User info form state
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  String? _gender;
  String? _mbti;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final fortuneService = ref.read(fortuneServiceProvider);
    
    return await fortuneService.getFortune(
      fortuneType: widget.fortuneType,
      userId: ref.read(userProvider).value?.id ?? 'anonymous',
      params: params,
    );
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    if (_nameController.text.isEmpty || _birthDate == null || _gender == null) {
      Toast.warning(context, '기본 정보를 입력해주세요.');
      return null;
    }

    return {
      'name': _nameController.text,
      'birthDate': _birthDate!.toIso8601String(),
      'gender': _gender,
      'mbti': _mbti,
    };
  }

  @override
  Future<Map<String, dynamic>?> getFortuneParams() async {
    final userInfo = await getUserInfo();
    if (userInfo == null) return null;

    if (_fitnessLevel == null || _workoutFrequency == null || 
        _preferredTime == null || _workoutGoal == null ||
        _workoutStyle == null || _restDay == null) {
      Toast.warning(context, '모든 필수 정보를 입력해주세요.');
      return null;
    }

    return {
      ...userInfo,
      'fitnessLevel': _fitnessLevel,
      'workoutFrequency': _workoutFrequency,
      'preferredTime': _preferredTime,
      'workoutGoal': _workoutGoal,
      'focusMuscles': _focusMuscles,
      'hasGymMembership': _hasGymMembership,
      'workoutStyle': _workoutStyle,
      'restDay': _restDay,
    };
  }

  Widget buildUserInfoForm() {
    final theme = Theme.of(context);
    
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '기본 정보',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          // Name Input
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: '이름',
              hintText: '이름을 입력하세요',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Birth Date Picker
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _birthDate ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _birthDate = date);
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: '생년월일',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _birthDate != null
                    ? '${_birthDate!.year}년 ${_birthDate!.month}월 ${_birthDate!.day}일'
                    : '생년월일을 선택하세요',
                style: TextStyle(
                  color: _birthDate != null
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
                    child: RadioListTile<String>(
                      title: const Text('남성'),
                      value: 'male',
                      groupValue: _gender,
                      onChanged: (value) => setState(() => _gender = value),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('여성'),
                      value: 'female',
                      groupValue: _gender,
                      onChanged: (value) => setState(() => _gender = value),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget buildInputForm() {
    final theme = Theme.of(context);

    return Column(
      children: [
        // User Info Form
        buildUserInfoForm(),
        const SizedBox(height: 16),
        
        // Fitness Experience Info
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.fitness_center, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '운동 경험',
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Fitness Level
              DropdownButtonFormField<String>(
                value: _fitnessLevel,
                decoration: InputDecoration(
                  labelText: '운동 수준',
                  prefixIcon: const Icon(Icons.trending_up),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _levels.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _fitnessLevel = value),
              ),
              const SizedBox(height: 16),
              
              // Workout Frequency
              DropdownButtonFormField<String>(
                value: _workoutFrequency,
                decoration: InputDecoration(
                  labelText: '운동 빈도',
                  prefixIcon: const Icon(Icons.calendar_month),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _frequencies.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _workoutFrequency = value),
              ),
              const SizedBox(height: 16),
              
              // Preferred Time
              DropdownButtonFormField<String>(
                value: _preferredTime,
                decoration: InputDecoration(
                  labelText: '선호 시간대',
                  prefixIcon: const Icon(Icons.access_time),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _times.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _preferredTime = value),
              ),
              const SizedBox(height: 16),
              
              // Workout Style
              DropdownButtonFormField<String>(
                value: _workoutStyle,
                decoration: InputDecoration(
                  labelText: '운동 스타일',
                  prefixIcon: const Icon(Icons.sports_gymnastics),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _styles.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _workoutStyle = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Goals and Target Muscles
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.flag, color: theme.colorScheme.secondary),
                  const SizedBox(width: 8),
                  Text(
                    '운동 목표',
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Workout Goal
              DropdownButtonFormField<String>(
                value: _workoutGoal,
                decoration: InputDecoration(
                  labelText: '주요 목표',
                  prefixIcon: const Icon(Icons.track_changes),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _goals.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _workoutGoal = value),
              ),
              const SizedBox(height: 16),
              
              // Rest Days
              DropdownButtonFormField<String>(
                value: _restDay,
                decoration: InputDecoration(
                  labelText: '휴식일',
                  prefixIcon: const Icon(Icons.hotel),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _restDays.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _restDay = value),
              ),
              const SizedBox(height: 16),
              
              // Focus Muscles
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '집중 근육 부위 (복수 선택 가능)',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _muscleOptions.map((muscle) {
                      final isSelected = _focusMuscles.contains(muscle);
                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _focusMuscles.remove(muscle);
                            } else {
                              _focusMuscles.add(muscle);
                            }
                          });
                        },
                        child: Chip(
                          label: Text(muscle),
                          backgroundColor: isSelected
                              ? theme.colorScheme.primary.withOpacity(0.2)
                              : theme.colorScheme.surface.withOpacity(0.5),
                          side: BorderSide(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Gym Membership
              _buildSwitchTile(
                '헬스장 회원권 보유',
                _hasGymMembership,
                (value) => setState(() => _hasGymMembership = value),
                Icons.card_membership,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged, IconData icon) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodyLarge,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget buildFortuneResult() {
    return Column(
      children: [
        super.buildFortuneResult(),
        _buildWorkoutIntensity(),
        _buildTodaysWorkoutPlan(),
        _buildExerciseRecommendations(),
        _buildNutritionTips(),
        _buildRecoveryAdvice(),
        _buildMotivationalQuote(),
      ],
    );
  }

  Widget _buildWorkoutIntensity() {
    final theme = Theme.of(context);
    final intensity = _calculateWorkoutIntensity();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '오늘의 운동 강도',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _getIntensityColor(intensity).withOpacity(0.3),
                    _getIntensityColor(intensity).withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: _getIntensityColor(intensity),
                  width: 3,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${intensity}%',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getIntensityColor(intensity),
                      ),
                    ),
                    Text(
                      _getIntensityMessage(intensity),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ).animate()
                .scale(duration: 600.ms)
                .then()
                .shimmer(duration: 1000.ms),
            
            const SizedBox(height: 16),
            Text(
              '오늘은 ${_getWorkoutMessage(intensity)}',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysWorkoutPlan() {
    final theme = Theme.of(context);
    final workoutPlan = _getWorkoutPlan();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_note, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  '오늘의 운동 계획',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...workoutPlan.asMap().entries.map((entry) => 
              _buildWorkoutPhase(entry.value, index: entry.key)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutPhase(Map<String, String> phase, {int index = 0}) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.secondary.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    phase['order']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  phase['name']!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              phase['description']!,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '시간: ${phase['duration']}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ).animate()
          .fadeIn(delay: (index * 100).ms)
          .slideX(begin: -0.1, end: 0),
    );
  }

  Widget _buildExerciseRecommendations() {
    final theme = Theme.of(context);
    final exercises = _getRecommendedExercises();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fitness_center, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  '오늘의 추천 운동',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...exercises.map((exercise) => _buildExerciseItem(
              exercise['name']!,
              exercise['sets']!,
              exercise['reps']!,
              Icons.fitness_center,
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseItem(String name, String sets, String reps, IconData icon) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 24, color: theme.colorScheme.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$sets x $reps',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionTips() {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  '영양 섭취 가이드',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildNutritionItem('운동 전', '바나나 1개 + 아몬드 10알', Icons.breakfast_dining),
            _buildNutritionItem('운동 중', '스포츠 음료 500ml', Icons.local_drink),
            _buildNutritionItem('운동 후', '닭가슴살 150g + 고구마 1개', Icons.lunch_dining),
            _buildNutritionItem('수분 섭취', '체중 1kg당 30ml 이상', Icons.water_drop),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionItem(String timing, String food, IconData icon) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 24, color: Colors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timing,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  food,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryAdvice() {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.healing, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  '회복 전략',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildRecoveryItem('수면', '8시간', Icons.bedtime, Colors.indigo),
                      _buildRecoveryItem('스트레칭', '15분', Icons.accessibility, Colors.green),
                      _buildRecoveryItem('마사지', '권장', Icons.spa, Colors.purple),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '충분한 휴식이 근육 성장의 핵심입니다',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecoveryItem(String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    ).animate()
        .scale(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildMotivationalQuote() {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.format_quote,
              color: theme.colorScheme.primary,
              size: 40,
            ),
            const SizedBox(height: 16),
            Text(
              _getMotivationalQuote(),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '- Arnold Schwarzenegger',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateWorkoutIntensity() {
    // Calculate based on fitness level and goal
    final baseIntensity = switch (_fitnessLevel) {
      'beginner' => 60,
      'intermediate' => 70,
      'advanced' => 80,
      'expert' => 85,
      'athlete' => 90,
      _ => 70,
    };
    
    // Add goal-based modifier
    final goalModifier = switch (_workoutGoal) {
      'muscle' => 5,
      'strength' => 10,
      'weight_loss' => -5,
      'endurance' => -10,
      _ => 0,
    };
    
    // Add randomness for daily variation
    final today = DateTime.now();
    final random = math.Random(today.day + today.month);
    final variation = random.nextInt(15) - 7;
    
    return (baseIntensity + goalModifier + variation).clamp(40, 100);
  }

  List<Map<String, String>> _getWorkoutPlan() {
    return [
      {
        'order': '1',
        'name': '워밍업',
        'description': '가벼운 유산소와 동적 스트레칭으로 몸을 준비합니다',
        'duration': '10분',
      },
      {
        'order': '2',
        'name': '메인 운동',
        'description': '오늘의 타겟 근육을 집중적으로 자극합니다',
        'duration': '45분',
      },
      {
        'order': '3',
        'name': '보조 운동',
        'description': '협응근과 코어를 강화하는 운동을 수행합니다',
        'duration': '15분',
      },
      {
        'order': '4',
        'name': '쿨다운',
        'description': '정적 스트레칭과 폼롤러로 근육을 이완합니다',
        'duration': '10분',
      },
    ];
  }

  List<Map<String, String>> _getRecommendedExercises() {
    final exercises = [
      {'name': '벤치 프레스', 'sets': '4세트', 'reps': '8-10회'},
      {'name': '데드리프트', 'sets': '4세트', 'reps': '6-8회'},
      {'name': '스쿼트', 'sets': '4세트', 'reps': '10-12회'},
      {'name': '풀업', 'sets': '3세트', 'reps': '최대 반복'},
      {'name': '숄더 프레스', 'sets': '3세트', 'reps': '10-12회'},
      {'name': '바벨 로우', 'sets': '3세트', 'reps': '10-12회'},
    ];
    
    // Return 3-4 random exercises
    final today = DateTime.now();
    final random = math.Random(today.day + today.month);
    final count = random.nextInt(2) + 3;
    
    exercises.shuffle(random);
    return exercises.take(count).toList();
  }

  String _getMotivationalQuote() {
    final quotes = [
      '고통은 일시적이지만, 포기는 영원하다',
      '강해지고 싶다면 약한 모습을 받아들여라',
      '한계는 마음속에만 존재한다',
      '오늘의 고통이 내일의 힘이 된다',
      '성공은 매일의 작은 노력의 합이다',
    ];
    
    final today = DateTime.now();
    final index = (today.day + today.month) % quotes.length;
    return quotes[index];
  }

  Color _getIntensityColor(int intensity) {
    if (intensity >= 85) return Colors.red;
    if (intensity >= 70) return Colors.orange;
    if (intensity >= 55) return Colors.green;
    return Colors.blue;
  }

  String _getIntensityMessage(int intensity) {
    if (intensity >= 85) return '최고 강도';
    if (intensity >= 70) return '고강도';
    if (intensity >= 55) return '중강도';
    return '저강도';
  }

  String _getWorkoutMessage(int intensity) {
    if (intensity >= 85) return '한계에 도전하는 하드코어 트레이닝 데이입니다!';
    if (intensity >= 70) return '집중력을 발휘해 강도 높은 운동을 수행하세요.';
    if (intensity >= 55) return '적당한 강도로 꾸준히 운동하는 날입니다.';
    return '가벼운 운동으로 몸을 회복시키는 날입니다.';
  }
}