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

class LuckyYogaFortunePage extends BaseFortunePage {
  const LuckyYogaFortunePage({Key? key})
      : super(
          key: key,
          title: '요가 운세',
          description: '오늘의 요가 수련을 위한 운세와 가이드',
          fortuneType: 'lucky-yoga',
          requiresUserInfo: true,
        );

  @override
  ConsumerState<LuckyYogaFortunePage> createState() => _LuckyYogaFortunePageState();
}

class _LuckyYogaFortunePageState extends BaseFortunePageState<LuckyYogaFortunePage> {
  // User yoga info
  String? _practiceLevel;
  String? _preferredStyle;
  String? _practiceTime;
  String? _practiceGoal;
  List<String> _focusAreas = [];
  bool _hasInjury = false;
  String? _sessionDuration;
  
  final Map<String, String> _levels = {
    'beginner': '초급 (1년 미만)',
    'intermediate': '중급 (1-3년)',
    'advanced': '고급 (3-5년)',
    'expert': '전문가 (5년 이상)',
    'instructor': '강사/지도자',
  };
  
  final Map<String, String> _styles = {
    'hatha': '하타 요가',
    'vinyasa': '빈야사 요가',
    'ashtanga': '아쉬탕가 요가',
    'yin': '인 요가',
    'hot': '핫 요가',
    'power': '파워 요가',
    'restorative': '회복 요가',
    'kundalini': '쿤달리니 요가',
  };
  
  final Map<String, String> _times = {
    'early_morning': '새벽 (5-7시)',
    'morning': '아침 (7-9시)',
    'mid_morning': '오전 (9-12시)',
    'afternoon': '오후 (12-17시)',
    'evening': '저녁 (17-20시)',
    'night': '밤 (20시 이후)',
  };
  
  final Map<String, String> _goals = {
    'flexibility': '유연성 향상',
    'strength': '근력 강화',
    'balance': '균형 개선',
    'meditation': '명상과 집중',
    'stress': '스트레스 해소',
    'energy': '활력 증진',
    'healing': '치유와 회복',
    'spiritual': '영적 성장',
  };
  
  final List<String> _focusOptions = [
    '목과 어깨',
    '등과 척추',
    '코어',
    '골반과 힙',
    '다리와 발목',
    '팔과 손목',
    '호흡',
    '차크라',
    '마음챙김',
  ];
  
  final Map<String, String> _durations = {
    '15min': '15분',
    '30min': '30분',
    '45min': '45분',
    '60min': '60분',
    '90min': '90분',
    '120min': '120분 이상',
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

    if (_practiceLevel == null || _preferredStyle == null || 
        _practiceTime == null || _practiceGoal == null ||
        _sessionDuration == null) {
      Toast.warning(context, '모든 필수 정보를 입력해주세요.');
      return null;
    }

    return {
      ...userInfo,
      'practiceLevel': _practiceLevel,
      'preferredStyle': _preferredStyle,
      'practiceTime': _practiceTime,
      'practiceGoal': _practiceGoal,
      'focusAreas': _focusAreas,
      'hasInjury': _hasInjury,
      'sessionDuration': _sessionDuration,
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
        
        // Yoga Practice Info
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.self_improvement, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '요가 수련 정보',
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Practice Level
              DropdownButtonFormField<String>(
                value: _practiceLevel,
                decoration: InputDecoration(
                  labelText: '수련 수준',
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
                onChanged: (value) => setState(() => _practiceLevel = value),
              ),
              const SizedBox(height: 16),
              
              // Preferred Style
              DropdownButtonFormField<String>(
                value: _preferredStyle,
                decoration: InputDecoration(
                  labelText: '선호 요가 스타일',
                  prefixIcon: const Icon(Icons.spa),
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
                onChanged: (value) => setState(() => _preferredStyle = value),
              ),
              const SizedBox(height: 16),
              
              // Practice Time
              DropdownButtonFormField<String>(
                value: _practiceTime,
                decoration: InputDecoration(
                  labelText: '수련 시간대',
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
                onChanged: (value) => setState(() => _practiceTime = value),
              ),
              const SizedBox(height: 16),
              
              // Session Duration
              DropdownButtonFormField<String>(
                value: _sessionDuration,
                decoration: InputDecoration(
                  labelText: '수련 시간',
                  prefixIcon: const Icon(Icons.timer),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _durations.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _sessionDuration = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Goals and Focus Areas
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
                    '수련 목표',
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Practice Goal
              DropdownButtonFormField<String>(
                value: _practiceGoal,
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
                onChanged: (value) => setState(() => _practiceGoal = value),
              ),
              const SizedBox(height: 16),
              
              // Focus Areas
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '집중하고 싶은 부위 (복수 선택 가능)',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _focusOptions.map((area) {
                      final isSelected = _focusAreas.contains(area);
                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _focusAreas.remove(area);
                            } else {
                              _focusAreas.add(area);
                            }
                          });
                        },
                        child: Chip(
                          label: Text(area),
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
              
              // Injury Status
              _buildSwitchTile(
                '부상이나 불편한 부위가 있나요?',
                _hasInjury,
                (value) => setState(() => _hasInjury = value),
                Icons.healing,
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
        _buildYogaFlowPrediction(),
        _buildChakraBalance(),
        _buildAsanaRecommendations(),
        _buildBreathingExercises(),
        _buildMeditationGuidance(),
        _buildYogaWisdom(),
      ],
    );
  }

  Widget _buildYogaFlowPrediction() {
    final theme = Theme.of(context);
    final flowEnergy = _calculateFlowEnergy();
    
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
                  Icons.self_improvement,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '오늘의 수련 에너지',
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
                    _getEnergyColor(flowEnergy).withOpacity(0.3),
                    _getEnergyColor(flowEnergy).withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: _getEnergyColor(flowEnergy),
                  width: 3,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${flowEnergy}%',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getEnergyColor(flowEnergy),
                      ),
                    ),
                    Text(
                      _getEnergyMessage(flowEnergy),
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
              '오늘은 ${_getFlowMessage(flowEnergy)}',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChakraBalance() {
    final theme = Theme.of(context);
    final chakras = _getChakraBalance();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bubble_chart, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  '차크라 밸런스',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...chakras.asMap().entries.map((entry) => 
              _buildChakraItem(entry.value, index: entry.key)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildChakraItem(Map<String, dynamic> chakra, {int index = 0}) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: chakra['color'] as Color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  chakra['name'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${chakra['balance']}%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: chakra['color'] as Color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: (chakra['balance'] as int) / 100,
            backgroundColor: (chakra['color'] as Color).withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(chakra['color'] as Color),
          ),
        ],
      ),
    ).animate()
        .fadeIn(delay: (index * 100).ms)
        .slideX(begin: -0.1, end: 0);
  }

  Widget _buildAsanaRecommendations() {
    final theme = Theme.of(context);
    final asanas = _getRecommendedAsanas();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.accessibility_new, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  '오늘의 추천 아사나',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...asanas.map((asana) => _buildAsanaItem(
              asana['korean']!,
              asana['sanskrit']!,
              asana['benefit']!,
              Icons.accessibility_new,
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAsanaItem(String korean, String sanskrit, String benefit, IconData icon) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 24, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyLarge,
                    children: [
                      TextSpan(
                        text: korean,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' ($sanskrit)',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  benefit,
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

  Widget _buildBreathingExercises() {
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
                Icon(Icons.air, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  '오늘의 호흡법',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.1),
                    Colors.cyan.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '나디 쇼다나 (교호 호흡법)',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '좌우 콧구멍을 번갈아가며 호흡하여 신경계의 균형을 맞춥니다.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBreathingStep('들숨', '4초', Colors.blue),
                      _buildBreathingStep('멈춤', '4초', Colors.purple),
                      _buildBreathingStep('날숨', '4초', Colors.green),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreathingStep(String label, String duration, Color color) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              duration,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    ).animate()
        .scale(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildMeditationGuidance() {
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
                Icon(Icons.spa, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  '명상 가이드',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.format_quote,
                    color: Colors.green,
                    size: 30,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '오늘의 명상 주제',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getMeditationTheme(),
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

  Widget _buildYogaWisdom() {
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
                Icon(Icons.auto_stories, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(
                  '요가 수트라',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.withOpacity(0.1),
                    Colors.purple.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '"요가는 마음의 움직임을 멈추는 것이다"',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '- 파탄잘리 요가 수트라 1.2',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '오늘은 생각의 흐름을 관찰하고, 내면의 고요함을 찾는 수련에 집중해보세요.',
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

  int _calculateFlowEnergy() {
    // Calculate based on practice level and time
    final baseEnergy = switch (_practiceLevel) {
      'beginner' => 70,
      'intermediate' => 75,
      'advanced' => 80,
      'expert' => 85,
      'instructor' => 90,
      _ => 75,
    };
    
    // Add time-based bonus
    final timeBonus = switch (_practiceTime) {
      'early_morning' => 10,
      'morning' => 5,
      'evening' => 3,
      _ => 0,
    };
    
    // Add randomness for daily variation
    final today = DateTime.now();
    final random = math.Random(today.day + today.month);
    final variation = random.nextInt(10) - 5;
    
    return (baseEnergy + timeBonus + variation).clamp(50, 100);
  }

  List<Map<String, dynamic>> _getChakraBalance() {
    final today = DateTime.now();
    final random = math.Random(today.day + today.month);
    
    return [
      {
        'name': '루트 차크라 (물라다라)',
        'color': Colors.red,
        'balance': 60 + random.nextInt(30),
      },
      {
        'name': '세이크럴 차크라 (스바디스타나)',
        'color': Colors.orange,
        'balance': 60 + random.nextInt(30),
      },
      {
        'name': '솔라 차크라 (마니푸라)',
        'color': Colors.yellow,
        'balance': 60 + random.nextInt(30),
      },
      {
        'name': '하트 차크라 (아나하타)',
        'color': Colors.green,
        'balance': 60 + random.nextInt(30),
      },
      {
        'name': '스로트 차크라 (비슈다)',
        'color': Colors.blue,
        'balance': 60 + random.nextInt(30),
      },
      {
        'name': '써드아이 차크라 (아즈나)',
        'color': Colors.indigo,
        'balance': 60 + random.nextInt(30),
      },
      {
        'name': '크라운 차크라 (사하스라라)',
        'color': Colors.purple,
        'balance': 60 + random.nextInt(30),
      },
    ];
  }

  List<Map<String, String>> _getRecommendedAsanas() {
    final asanas = [
      {
        'korean': '산 자세',
        'sanskrit': 'Tadasana',
        'benefit': '자세 교정과 집중력 향상',
      },
      {
        'korean': '나무 자세',
        'sanskrit': 'Vrikshasana',
        'benefit': '균형감각과 안정감 증진',
      },
      {
        'korean': '전사 자세',
        'sanskrit': 'Virabhadrasana',
        'benefit': '하체 강화와 자신감 향상',
      },
      {
        'korean': '아이 자세',
        'sanskrit': 'Balasana',
        'benefit': '휴식과 이완, 스트레스 해소',
      },
      {
        'korean': '코브라 자세',
        'sanskrit': 'Bhujangasana',
        'benefit': '척추 유연성과 가슴 개방',
      },
    ];
    
    // Return 3 random asanas
    final today = DateTime.now();
    final random = math.Random(today.day + today.month);
    asanas.shuffle(random);
    return asanas.take(3).toList();
  }

  String _getMeditationTheme() {
    final themes = [
      '호흡에 대한 깊은 관찰과 현재 순간에 머물기',
      '몸의 감각을 있는 그대로 받아들이는 연습',
      '자애와 연민의 마음으로 자신과 타인을 바라보기',
      '생각의 흐름을 판단 없이 관찰하기',
      '감사하는 마음으로 하루를 시작하고 마무리하기',
    ];
    
    final today = DateTime.now();
    final index = (today.day + today.month) % themes.length;
    return themes[index];
  }

  Color _getEnergyColor(int energy) {
    if (energy >= 85) return Colors.purple;
    if (energy >= 70) return Colors.blue;
    if (energy >= 55) return Colors.green;
    return Colors.orange;
  }

  String _getEnergyMessage(int energy) {
    if (energy >= 85) return '최상의 흐름';
    if (energy >= 70) return '좋은 에너지';
    if (energy >= 55) return '안정적인 수련';
    return '차분한 수련';
  }

  String _getFlowMessage(int energy) {
    if (energy >= 85) return '몸과 마음이 완벽한 조화를 이루는 날입니다!';
    if (energy >= 70) return '깊은 수련을 통해 내면의 성장을 경험할 수 있습니다.';
    if (energy >= 55) return '기본에 충실한 수련으로 안정감을 찾으세요.';
    return '부드럽고 회복적인 수련을 권합니다.';
  }
}