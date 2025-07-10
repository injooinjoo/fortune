import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/toast.dart';

class ExLoverFortunePage extends BaseFortunePage {
  const ExLoverFortunePage({Key? key})
      : super(
          key: key,
          title: '전 애인 운세',
          description: '과거 관계의 의미와 새로운 시작',
          fortuneType: 'ex-lover',
          requiresUserInfo: true,
        );

  @override
  ConsumerState<ExLoverFortunePage> createState() => _ExLoverFortunePageState();
}

class _ExLoverFortunePageState extends BaseFortunePageState<ExLoverFortunePage> {
  // Ex-relationship info
  String? _relationshipDuration;
  String? _breakupReason;
  String? _timeSinceBreakup;
  String? _currentFeeling;
  bool _stillInContact = false;
  bool _hasUnresolvedFeelings = false;
  List<String> _lessonLearned = [];
  
  // Current situation
  String? _currentStatus;
  bool _readyForNewRelationship = false;
  
  final Map<String, String> _durations = {
    'short': '6개월 미만',
    'medium': '6개월-1년',
    'long': '1-3년',
    'verylong': '3년 이상',
  };
  
  final Map<String, String> _breakupReasons = {
    'distance': '물리적/정서적 거리',
    'values': '가치관 차이',
    'timing': '시기가 맞지 않음',
    'cheating': '신뢰 문제',
    'family': '가족 반대',
    'growth': '서로 다른 성장',
    'communication': '소통 부재',
    'other': '기타',
  };
  
  final Map<String, String> _timePeriods = {
    'recent': '1개월 미만',
    'short': '1-3개월',
    'medium': '3-6개월',
    'long': '6개월-1년',
    'verylong': '1년 이상',
  };
  
  final Map<String, String> _feelings = {
    'miss': '그리움',
    'anger': '분노/원망',
    'sadness': '슬픔',
    'relief': '안도감',
    'indifferent': '무덤덤',
    'grateful': '감사함',
    'confused': '혼란스러움',
  };
  
  final List<String> _lessons = [
    '소통의 중요성',
    '자기 자신을 사랑하기',
    '경계 설정하기',
    '신뢰의 가치',
    '타이밍의 중요성',
    '양보와 이해',
    '독립성 유지',
    '감정 표현',
    '성장의 필요성',
  ];
  
  final Map<String, String> _currentStatuses = {
    'single': '싱글',
    'dating': '새로운 사람과 연애 중',
    'healing': '치유 중',
    'confused': '혼란스러운 상태',
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
          const SizedBox(height: 16),
          
          // MBTI Selection (Optional)
          DropdownButtonFormField<String>(
            value: _mbti,
            decoration: InputDecoration(
              labelText: 'MBTI (선택)',
              prefixIcon: const Icon(Icons.psychology),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: [
              'INTJ', 'INTP', 'ENTJ', 'ENTP',
              'INFJ', 'INFP', 'ENFJ', 'ENFP',
              'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
              'ISTP', 'ISFP', 'ESTP', 'ESFP',
            ].map((mbti) => DropdownMenuItem(
              value: mbti,
              child: Text(mbti),
            )).toList(),
            onChanged: (value) => setState(() => _mbti = value),
          ),
        ],
      ),
    );
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

  @override
  Future<Map<String, dynamic>?> getFortuneParams() async {
    final userInfo = await getUserInfo();
    if (userInfo == null) return null;

    if (_relationshipDuration == null || _breakupReason == null || 
        _timeSinceBreakup == null || _currentFeeling == null ||
        _currentStatus == null) {
      Toast.warning(context, '모든 필수 정보를 입력해주세요.');
      return null;
    }

    return {
      ...userInfo,
      'relationshipDuration': _relationshipDuration,
      'breakupReason': _breakupReason,
      'timeSinceBreakup': _timeSinceBreakup,
      'currentFeeling': _currentFeeling,
      'stillInContact': _stillInContact,
      'hasUnresolvedFeelings': _hasUnresolvedFeelings,
      'lessonLearned': _lessonLearned,
      'currentStatus': _currentStatus,
      'readyForNewRelationship': _readyForNewRelationship,
    };
  }

  @override
  Widget buildInputForm() {
    final theme = Theme.of(context);

    return Column(
      children: [
        // User Info Form
        buildUserInfoForm(),
        const SizedBox(height: 16),
        
        // Past Relationship Info
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '과거 관계 정보',
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Relationship Duration
              Text(
                '교제 기간',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _relationshipDuration,
                decoration: InputDecoration(
                  hintText: '교제 기간을 선택하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface.withOpacity(0.5),
                ),
                items: _durations.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _relationshipDuration = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Breakup Reason
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
                children: _breakupReasons.entries.map((entry) {
                  final isSelected = _breakupReason == entry.key;
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _breakupReason = entry.key;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Chip(
                      label: Text(entry.value),
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
              const SizedBox(height: 16),
              
              // Time Since Breakup
              Text(
                '이별 후 시간',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _timeSinceBreakup,
                decoration: InputDecoration(
                  hintText: '이별 후 얼마나 지났나요?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface.withOpacity(0.5),
                ),
                items: _timePeriods.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _timeSinceBreakup = value;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Current Feelings
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.favorite_border,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '현재 감정',
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Current Feeling
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
                children: _feelings.entries.map((entry) {
                  final isSelected = _currentFeeling == entry.key;
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _currentFeeling = entry.key;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Chip(
                      label: Text(entry.value),
                      backgroundColor: isSelected
                          ? _getFeelingColor(entry.key).withOpacity(0.2)
                          : theme.colorScheme.surface.withOpacity(0.5),
                      side: BorderSide(
                        color: isSelected
                            ? _getFeelingColor(entry.key)
                            : theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              
              // Contact Status
              _buildSwitchTile(
                '아직 연락하고 있나요?',
                _stillInContact,
                (value) => setState(() => _stillInContact = value),
                Icons.chat_bubble_outline,
              ),
              const SizedBox(height: 8),
              _buildSwitchTile(
                '아직 미련이 남아있나요?',
                _hasUnresolvedFeelings,
                (value) => setState(() => _hasUnresolvedFeelings = value),
                Icons.favorite_outline,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Lessons Learned
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '배운 점',
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '이 관계에서 배운 점을 선택하세요 (복수 선택)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _lessons.map((lesson) {
                  final isSelected = _lessonLearned.contains(lesson);
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _lessonLearned.remove(lesson);
                        } else {
                          _lessonLearned.add(lesson);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Chip(
                      label: Text(lesson),
                      backgroundColor: isSelected
                          ? Colors.green.withOpacity(0.2)
                          : theme.colorScheme.surface.withOpacity(0.5),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.green
                            : theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      deleteIcon: isSelected
                          ? const Icon(Icons.check_circle, size: 18)
                          : null,
                      onDeleted: isSelected ? () {} : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Current Status
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '현재 상태',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              ...(_currentStatuses.entries.map((entry) {
                final isSelected = _currentStatus == entry.key;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _currentStatus = entry.key;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      blur: 10,
                      borderColor: isSelected
                          ? theme.colorScheme.primary.withOpacity(0.5)
                          : Colors.transparent,
                      borderWidth: isSelected ? 2 : 0,
                      child: Row(
                        children: [
                          Radio<String>(
                            value: entry.key,
                            groupValue: _currentStatus,
                            onChanged: (value) {
                              setState(() {
                                _currentStatus = value;
                              });
                            },
                          ),
                          Text(
                            entry.value,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList()),
              const SizedBox(height: 16),
              _buildSwitchTile(
                '새로운 연애를 시작할 준비가 되었나요?',
                _readyForNewRelationship,
                (value) => setState(() => _readyForNewRelationship = value),
                Icons.favorite,
              ),
            ],
          ),
        ),
      ],
    );
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
        _buildClosureAnalysis(),
        _buildReunionPossibility(),
        _buildHealingProgress(),
        _buildGrowthInsights(),
        _buildNewBeginningGuidance(),
      ],
    );
  }

  Widget _buildClosureAnalysis() {
    final theme = Theme.of(context);
    final closureLevel = _calculateClosureLevel();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lock_open_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '정리 상태 분석',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: closureLevel / 100,
                    strokeWidth: 20,
                    backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getClosureColor(closureLevel),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '$closureLevel%',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getClosureColor(closureLevel),
                      ),
                    ),
                    Text(
                      _getClosureStatus(closureLevel),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getClosureAdvice(closureLevel),
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateClosureLevel() {
    int level = 40;
    
    if (_currentFeeling == 'indifferent' || _currentFeeling == 'grateful') {
      level += 20;
    }
    if (!_stillInContact) {
      level += 15;
    }
    if (!_hasUnresolvedFeelings) {
      level += 25;
    }
    if (_timeSinceBreakup == 'long' || _timeSinceBreakup == 'verylong') {
      level += 10;
    }
    if (_lessonLearned.length >= 3) {
      level += 10;
    }
    
    return level.clamp(0, 100);
  }

  Color _getClosureColor(int level) {
    if (level >= 80) return Colors.green;
    if (level >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getClosureStatus(int level) {
    if (level >= 80) return '완전히 정리됨';
    if (level >= 60) return '대부분 정리됨';
    if (level >= 40) return '정리 중';
    return '아직 정리 필요';
  }

  String _getClosureAdvice(int level) {
    if (level >= 80) {
      return '과거를 완전히 정리하고 새로운 시작을 할 준비가 되었습니다. 자신감을 가지고 앞으로 나아가세요.';
    } else if (level >= 60) {
      return '많은 부분이 정리되었지만, 아직 작은 미련이 남아있을 수 있습니다. 시간이 해결해 줄 것입니다.';
    } else if (level >= 40) {
      return '아직 정리 과정 중입니다. 자신에게 충분한 시간을 주고, 감정을 인정하며 천천히 나아가세요.';
    } else {
      return '아직 많은 감정이 남아있습니다. 서두르지 말고 자신의 감정을 충분히 느끼고 표현하는 것이 중요합니다.';
    }
  }

  Widget _buildReunionPossibility() {
    final theme = Theme.of(context);
    final reunionChance = _calculateReunionChance();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.loop_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '재회 가능성',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: reunionChance / 100,
              minHeight: 20,
              backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProbabilityColor(reunionChance),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '재회 가능성',
                  style: theme.textTheme.bodyLarge,
                ),
                Text(
                  '$reunionChance%',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getProbabilityColor(reunionChance),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 조언',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getReunionAdvice(reunionChance),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateReunionChance() {
    int chance = 20;
    
    if (_stillInContact) chance += 15;
    if (_hasUnresolvedFeelings) chance += 20;
    if (_currentFeeling == 'miss') chance += 15;
    if (_breakupReason == 'timing' || _breakupReason == 'distance') chance += 10;
    if (_timeSinceBreakup == 'recent' || _timeSinceBreakup == 'short') chance += 10;
    
    return chance.clamp(0, 100);
  }

  Color _getProbabilityColor(int probability) {
    if (probability >= 70) return Colors.green;
    if (probability >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getReunionAdvice(int chance) {
    if (chance >= 70) {
      return '재회 가능성이 높지만, 과거의 문제를 해결하지 않으면 같은 문제가 반복될 수 있습니다. 신중하게 접근하세요.';
    } else if (chance >= 40) {
      return '재회보다는 새로운 시작에 집중하는 것이 좋습니다. 과거는 좋은 추억으로 남기고 앞으로 나아가세요.';
    } else {
      return '이 관계는 끝났다고 봐야 합니다. 새로운 사랑을 위해 마음의 공간을 비워두세요.';
    }
  }

  Widget _buildHealingProgress() {
    final theme = Theme.of(context);
    
    final healingStages = [
      {'stage': '부정', 'completed': true},
      {'stage': '분노', 'completed': true},
      {'stage': '타협', 'completed': _timeSinceBreakup != 'recent'},
      {'stage': '우울', 'completed': _currentFeeling != 'sadness'},
      {'stage': '수용', 'completed': _currentFeeling == 'grateful' || _currentFeeling == 'indifferent'},
    ];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.healing_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '치유 과정',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...healingStages.asMap().entries.map((entry) {
              final index = entry.key;
              final stage = entry.value;
              final isCompleted = stage['completed'] as bool;
              final isLast = index == healingStages.length - 1;
              
              return Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.2),
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stage['stage'] as String,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isCompleted
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                            Text(
                              _getStageDescription(stage['stage'] as String),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!isLast)
                    Container(
                      margin: const EdgeInsets.only(left: 20),
                      height: 30,
                      width: 2,
                      color: isCompleted
                          ? theme.colorScheme.primary.withOpacity(0.3)
                          : theme.colorScheme.onSurface.withOpacity(0.1),
                    ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  String _getStageDescription(String stage) {
    switch (stage) {
      case '부정':
        return '이별을 받아들이지 못하는 단계';
      case '분노':
        return '상대방이나 상황에 대한 분노';
      case '타협':
        return '다시 돌아갈 수 있을까 하는 희망';
      case '우울':
        return '상실감과 슬픔을 느끼는 시기';
      case '수용':
        return '이별을 받아들이고 앞으로 나아감';
      default:
        return '';
    }
  }

  Widget _buildGrowthInsights() {
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
                Icon(
                  Icons.trending_up_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '성장 포인트',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_lessonLearned.isNotEmpty) ...[
              Text(
                '당신이 배운 교훈들',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ..._lessonLearned.map((lesson) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 20,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _getLessonApplication(lesson),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '모든 관계는 우리에게 무언가를 가르쳐줍니다. 이 경험에서 배운 점을 찾아보세요.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.secondary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '다음 관계를 위한 준비',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getNextRelationshipAdvice(),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLessonApplication(String lesson) {
    final applications = {
      '소통의 중요성': '다음 관계에서는 더 열린 마음으로 대화하세요',
      '자기 자신을 사랑하기': '자존감을 높이고 자신의 가치를 인정하세요',
      '경계 설정하기': '건강한 관계를 위한 적절한 경계를 만드세요',
      '신뢰의 가치': '신뢰는 서서히 쌓아가는 것임을 기억하세요',
      '타이밍의 중요성': '서두르지 말고 적절한 시기를 기다리세요',
      '양보와 이해': '상대방의 입장에서 생각하는 연습을 하세요',
      '독립성 유지': '관계 속에서도 자신만의 공간을 지키세요',
      '감정 표현': '솔직한 감정 표현이 건강한 관계를 만듭니다',
      '성장의 필요성': '함께 성장할 수 있는 관계를 추구하세요',
    };
    return applications[lesson] ?? '이 경험을 통해 더 나은 사람이 되세요';
  }

  String _getNextRelationshipAdvice() {
    if (_readyForNewRelationship) {
      return '새로운 사랑을 받아들일 준비가 되었습니다. 과거의 경험을 바탕으로 더 성숙하고 건강한 관계를 만들어가세요.';
    } else {
      return '아직 조금 더 시간이 필요합니다. 자신을 돌보고 치유하는 시간을 가지세요. 준비가 되면 자연스럽게 새로운 사랑이 찾아올 것입니다.';
    }
  }

  Widget _buildNewBeginningGuidance() {
    final theme = Theme.of(context);
    
    final steps = [
      {
        'title': '자기 돌봄',
        'actions': [
          '규칙적인 운동으로 건강 관리',
          '취미 활동으로 자신만의 시간 갖기',
          '친구들과의 관계 강화',
        ],
        'icon': Icons.self_improvement,
      },
      {
        'title': '감정 정리',
        'actions': [
          '일기 쓰기로 감정 표현',
          '필요하다면 전문가 상담',
          '명상이나 요가로 마음 안정',
        ],
        'icon': Icons.psychology,
      },
      {
        'title': '새로운 시작',
        'actions': [
          '새로운 사람들과의 만남',
          '관심사 확장하기',
          '긍정적인 미래 계획 세우기',
        ],
        'icon': Icons.rocket_launch,
      },
    ];
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.wb_sunny_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '새로운 시작을 위한 가이드',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...steps.map((step) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(11),
                          topRight: Radius.circular(11),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            step['icon'] as IconData,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            step['title'] as String,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: (step['actions'] as List).map((action) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  action as String,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            )).toList(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.withOpacity(0.1),
                    Colors.orange.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '모든 끝은 새로운 시작입니다. 과거에 감사하고 미래를 향해 나아가세요.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}