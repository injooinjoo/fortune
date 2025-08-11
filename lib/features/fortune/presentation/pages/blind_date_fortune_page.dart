import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/toast.dart';
import '../../../../core/theme/app_colors.dart';

class BlindDateFortunePage extends BaseFortunePage {
  const BlindDateFortunePage({Key? key})
      : super(
          key: key,
          title: '소개팅 운세',
          description: '성공적인 만남을 위한 운세',
          fortuneType: 'blind-date',
          requiresUserInfo: true
        );

  @override
  ConsumerState<BlindDateFortunePage> createState() => _BlindDateFortunePageState();
}

class _BlindDateFortunePageState extends BaseFortunePageState<BlindDateFortunePage> {
  // Meeting Info
  DateTime? _meetingDate;
  String? _meetingTime;
  String? _meetingType;
  String? _introducer;
  
  // Preferences
  List<String> _importantQualities = [];
  String? _agePreference;
  String? _idealFirstDate;
  
  // Self Assessment
  String? _confidence;
  List<String> _concerns = [];
  String? _pastExperience;
  bool _isFirstBlindDate = false;
  
  final Map<String, String> _meetingTimes = {
    'morning': '아침 (7-11시)',
    'lunch': '점심 (11-14시)',
    'afternoon': '오후 (14-18시)',
    'evening': '저녁 (18-22시)',
    'night': '밤 (22시 이후)'
  };
  
  final Map<String, String> _meetingTypes = {
    'coffee': '카페에서 차 한잔',
    'meal': '식사',
    'activity': '액티비티 (볼링, 영화 등)',
    'walk': '산책',
    'online': '온라인 만남'
  };
  
  final Map<String, String> _introducers = {
    'friend': '친구',
    'family': '가족',
    'colleague': '직장 동료',
    'app': '데이팅 앱',
    'matchmaker': '결혼정보회사',
    'other': '기타'
  };
  
  final List<String> _qualities = [
    '외모', '성격',
    '유머감각', '경제력',
    '가치관', '학력',
    '직업', '취미',
    '가족관계', '종교'
  ];
  
  final Map<String, String> _agePreferences = {
    'younger': '연하 선호',
    'same': '동갑 선호',
    'older': '연상 선호',
    'flexible': '나이 상관없음'
  };
  
  final Map<String, String> _idealDates = {
    'casual': '편안한 대화 (카페, 산책)',
    'fun': '재미있는 활동 (놀이공원, 게임)',
    'cultural': '문화생활 (전시회, 공연)',
    'nature': '자연 속 데이트',
    'food': '맛집 탐방'
  };
  
  final Map<String, String> _confidenceLevels = {
    'very_low': '매우 낮음',
    'low': '낮음',
    'medium': '보통',
    'high': '높음',
    'very_high': '매우 높음'
  };
  
  final List<String> _concernOptions = [
    '첫인상', '대화 주제',
    '어색한 침묵', '외모',
    '매너', '상대방의 기대',
    '거절 두려움', '과거 경험'
  ];

  // User info form state
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  String? _gender;
  String? _mbti;
  
  @override
  void initState() {
    super.initState();
    
    // Pre-fill user data with profile if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userProfile != null) {
        setState(() {
          _nameController.text = userProfile!.name ?? '';
          _birthDate = userProfile!.birthDate;
          _gender = userProfile!.gender;
          _mbti = userProfile!.mbtiType;
        });
      }
    });
  }

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
      params: params
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
      'mbti': null};
  }

  Widget buildUserInfoForm() {
    final theme = Theme.of(context);
    
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '기본 정보',
            style: theme.textTheme.headlineSmall
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
                borderRadius: BorderRadius.circular(12)
              )
            )
          ),
          const SizedBox(height: 16),
          // Birth Date Picker
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _birthDate ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now()
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
                  borderRadius: BorderRadius.circular(12))
              ),
              child: Text(
                _birthDate != null
                    ? '${_birthDate!.year}년 ${_birthDate!.month}월 ${_birthDate!.day}일'
                    : '생년월일을 선택하세요',
                style: TextStyle(
                  color: _birthDate != null
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withOpacity(0.6)
                )
              )
            )
          ),
          const SizedBox(height: 16),
          // Gender Selection
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '성별',
                style: theme.textTheme.bodyLarge
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
                      contentPadding: EdgeInsets.zero
                    )
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('여성'),
                      value: 'female',
                      groupValue: _gender,
                      onChanged: (value) => setState(() => _gender = value),
                      contentPadding: EdgeInsets.zero
                    )
                  )
                ]
              )
            ]
          ),
          const SizedBox(height: 16),
          // MBTI Selection (Optional)
          DropdownButtonFormField<String>(
            value: _mbti,
            decoration: InputDecoration(
              labelText: 'MBTI (선택)',
              prefixIcon: const Icon(Icons.psychology),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12))
            ),
            items: [
              'INTJ', 'INTP', 'ENTJ', 'ENTP',
              'INFJ', 'INFP', 'ENFJ', 'ENFP',
              'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
              'ISTP', 'ISFP', 'ESTP', 'ESFP'].map((mbti) => DropdownMenuItem(
              value: mbti,
              child: Text(mbti))).toList(),
            onChanged: (value) => setState(() => _mbti = value)
          )
        ]
      )
    )
  );
  }

  @override
  Future<Map<String, dynamic>?> getFortuneParams() async {
    final userInfo = await getUserInfo();
    if (userInfo == null) return null;

    if (_meetingDate == null || _meetingTime == null || 
        _meetingType == null || _introducer == null ||
        _importantQualities.isEmpty || _agePreference == null ||
        _idealFirstDate == null || _confidence == null) {
      Toast.warning(context, '모든 필수 정보를 입력해주세요.');
      return null;
    }

    return {
      ...userInfo,
      'meetingDate': _meetingDate!.toIso8601String(),
      'meetingTime': _meetingTime,
      'meetingType': _meetingType,
      'introducer': _introducer,
      'importantQualities': _importantQualities,
      'agePreference': _agePreference,
      'idealFirstDate': _idealFirstDate,
      'confidence': _confidence,
      'concerns': _concerns,
      'pastExperience': _pastExperience,
      'isFirstBlindDate': null};
  }

  @override
  Widget buildInputForm() {
    final theme = Theme.of(context);

    return Column(
      children: [
        // User Info Form
        buildUserInfoForm(),
        const SizedBox(height: 16),
        // Meeting Details
        GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '만남 정보',
                    style: theme.textTheme.headlineSmall
                  )
                ]
              ),
              const SizedBox(height: 16),
              // Meeting Date
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _meetingDate ?? DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90))
                  );
                  if (date != null) {
                    setState(() {
                      _meetingDate = date;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: '만남 예정일',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    filled: true,
                    fillColor: theme.colorScheme.surface.withOpacity(0.5),
                    suffixIcon: const Icon(Icons.calendar_today)),
                  child: Text(
                    _meetingDate != null
                        ? '${_meetingDate!.year}년 ${_meetingDate!.month}월 ${_meetingDate!.day}일'
                        : '날짜를 선택하세요'
                  )
                )
              ),
              const SizedBox(height: 16),
              // Meeting Time
              Text(
                '만남 시간대',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold
                )
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _meetingTimes.entries.map((entry) {
                  final isSelected = _meetingTime == entry.key;
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _meetingTime = entry.key;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                  ),
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
                    )
                  );
                }).toList()
              ),
              const SizedBox(height: 16),
              // Meeting Type
              Text(
                '만남 방식',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _meetingType,
                decoration: InputDecoration(
                  hintText: '어떤 방식으로 만날 예정인가요?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface.withOpacity(0.5)),
                items: _meetingTypes.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _meetingType = value;
                  });
                }),
              const SizedBox(height: 16),
              // Introducer
              Text(
                '소개 경로',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold
                )
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _introducers.entries.map((entry) {
                  final isSelected = _introducer == entry.key;
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _introducer = entry.key;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Chip(
                      label: Text(entry.value),
                      backgroundColor: isSelected
                          ? theme.colorScheme.primary.withOpacity(0.2)
                          : theme.colorScheme.surface.withOpacity(0.5),
                      side: BorderSide(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.3)
                      )
                    )
                  );
                }).toList()
              ),
        const SizedBox(height: 16),
        // Preferences
        GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.favorite_outline,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '선호 사항',
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Important Qualities
              Text(
                '중요하게 생각하는 것 (3개 이상)',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _qualities.map((quality) {
                  final isSelected = _importantQualities.contains(quality);
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _importantQualities.remove(quality);
                        } else {
                          _importantQualities.add(quality);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Chip(
                      label: Text(quality),
                      backgroundColor: isSelected
                          ? theme.colorScheme.primary.withOpacity(0.2)
                          : theme.colorScheme.surface.withOpacity(0.5),
                      side: BorderSide(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.3)),
                      deleteIcon: isSelected
                          ? const Icon(Icons.check_circle, size: 18)
                          : null,
                      onDeleted: isSelected ? () {} : null));
                }).toList()
              ),
              const SizedBox(height: 16),
              // Age Preference
              Text(
                '나이 선호도',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._agePreferences.entries.map((entry) {
                final isSelected = _agePreference == entry.key;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _agePreference = entry.key;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: GlassContainer(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16),
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
                            groupValue: _agePreference,
                            onChanged: (value) {
                              setState(() {
                                _agePreference = value;
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
              }).toList(),
          ),
          const SizedBox(height: 16),
              // Ideal First Date
              Text(
                '이상적인 첫 데이트',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _idealFirstDate,
                decoration: InputDecoration(
                  hintText: '선호하는 데이트 스타일',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface.withOpacity(0.5)),
                items: _idealDates.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _idealFirstDate = value;
                  });
                },
              )
            ]
          )
        ),
        const SizedBox(height: 16),
        // Self Assessment
        GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.psychology,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '자기 평가',
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Confidence Level
              Text(
                '소개팅 자신감',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._confidenceLevels.entries.map((entry) {
                final isSelected = _confidence == entry.key;
                final index = _confidenceLevels.keys.toList().indexOf(entry.key);
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _confidence = entry.key;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: GlassContainer(
                      padding: const EdgeInsets.all(16),
                      borderRadius: BorderRadius.circular(12),
                      blur: 10,
                      borderColor: isSelected
                          ? theme.colorScheme.primary.withOpacity(0.5)
                          : Colors.transparent,
                      borderWidth: isSelected ? 2 : 0,
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getConfidenceColor(index).withOpacity(0.2),
                              border: Border.all(
                                color: _getConfidenceColor(index),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${(index + 1) * 20}%',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _getConfidenceColor(index),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            entry.value,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
          ),
          const SizedBox(height: 16),
              // Concerns
              Text(
                '걱정되는 부분 (선택)',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _concernOptions.map((concern) {
                  final isSelected = _concerns.contains(concern);
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _concerns.remove(concern);
                        } else {
                          _concerns.add(concern);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Chip(
                      label: Text(concern),
                      backgroundColor: isSelected
                          ? Colors.orange.withOpacity(0.2)
                          : theme.colorScheme.surface.withOpacity(0.5),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.orange
                            : theme.colorScheme.onSurface.withOpacity(0.3)
                      )
                    )
                  );
                }).toList()
              ),
              const SizedBox(height: 16),
              // First Blind Date
              _buildSwitchTile(
                '첫 소개팅인가요?',
                _isFirstBlindDate,
                (value) => setState(() => _isFirstBlindDate = value),
                Icons.favorite_border
              )
            ]
          )
        )
      ]
    );
  }

  Color _getConfidenceColor(int index) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.lightGreen,
      Colors.green];
    return colors[index];
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
            style: theme.textTheme.bodyLarge)),
        Switch(
          value: value,
          onChanged: onChanged)]);
  }

  @override
  Widget buildFortuneResult() {
    return Column(
      children: [
        super.buildFortuneResult(),
        _buildSuccessPrediction(),
        _buildFirstImpressionGuide(),
        _buildConversationTopics(),
        _buildOutfitRecommendation(),
        _buildDateLocationAdvice(),
        _buildDosDonts()]);
  }

  Widget _buildSuccessPrediction() {
    final theme = Theme.of(context);
    final successRate = _calculateSuccessRate();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(

            children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '소개팅 성공 예측',
                  style: theme.textTheme.headlineSmall
                )
              ]
            ),
            const SizedBox(height: 24),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: successRate / 100,
                    strokeWidth: 20,
                    backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getSuccessColor(successRate)
                    )
                  )
                ),
                Column(
                  children: [
                    Text(
                      '$successRate%',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getSuccessColor(successRate)
                      )
                    ),
                    Text(
                      _getSuccessMessage(successRate),
                      style: theme.textTheme.bodyLarge
                    )
                  ]
                )
              ]
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.secondary.withOpacity(0.1)]),
                borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                _getSuccessAdvice(successRate),
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center
              )
            )
          ]
        )
      )
    );
  }

  int _calculateSuccessRate() {
    int rate = 50;
    
    // Time factor
    if (_meetingTime == 'afternoon' || _meetingTime == 'evening') rate += 10;
    
    // Meeting type factor
    if (_meetingType == 'coffee' || _meetingType == 'meal') rate += 5;
    
    // Confidence factor
    switch (_confidence) {
      case 'very_high': rate += 20;
        break;
      case 'high':
        rate += 15;
        break;
      case 'medium':
        rate += 10;
        break;
      case 'low':
        rate += 5;
        break;
      case 'very_low':
        rate += 0;
        break;
    }
    
    // Concerns factor
    if (_concerns.length <= 2) rate += 10;
    
    // First date factor
    if (!_isFirstBlindDate) rate += 5;
    
    return rate.clamp(0, 100);
  }

  Color _getSuccessColor(int rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getSuccessMessage(int rate) {
    if (rate >= 80) return '대박 예감!';
    if (rate >= 60) return '좋은 만남';
    return '긴장하지 마세요';
  }

  String _getSuccessAdvice(int rate) {
    if (rate >= 80) {
      return '운이 아주 좋습니다! 자신감을 가지고 자연스럽게 대화를 이끌어가세요. 좋은 인연이 될 가능성이 높습니다.';
    } else if (rate >= 60) {
      return '평균 이상의 좋은 운입니다. 너무 긴장하지 말고 편안한 마음으로 상대방을 알아가는 시간을 가지세요.';
    } else {
      return '첫 만남은 누구나 긴장됩니다. 완벽하려 하지 말고 진솔한 모습을 보여주세요. 인연은 자연스럽게 찾아옵니다.';
    }
  }

  Widget _buildFirstImpressionGuide() {
    final theme = Theme.of(context);
    
    final impressionTips = [
      {
        'tip': '미소로 인사하기', 'detail': '밝은 미소는 호감도를 높입니다', 'icon': Icons.sentiment_satisfied},
      {
        'tip': '아이컨택 유지', 'detail': '적당한 눈맿춤으로 진정성 전달', 'icon': Icons.remove_red_eye},
      {
        'tip': '경청하는 자세', 'detail': '상대방 이야기에 집중하세요', 'icon': Icons.hearing},
      {
        'tip': '자연스러운 바디랭귀지', 'detail': '열린 자세로 편안함 표현', 'icon': Icons.accessibility_new}
    ];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star_outline,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '첫인상 가이드',
                  style: theme.textTheme.headlineSmall
                )
              ]
            ),
            const SizedBox(height: 16),
            ...impressionTips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                      tip['icon'] as IconData,
                      size: 20,
                      color: theme.colorScheme.primary)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip['tip'] as String,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold
                )
              ),
                        const SizedBox(height: 4),
                        Text(
                          tip['detail'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7)
                          )
                        )
                      ]
                    )
                  ]
                )
              )
            )).toList()
          ]
        )
      )
    );
  }

  Widget _buildConversationTopics() {
    final theme = Theme.of(context);
    
    final topics = [
      {'category': '가벼운 주제', 'items': ['취미', '여행', '음식', '영화/드라마']},
      {'category': '일상 이야기', 'items': ['주말 보내는 법', '좋아하는 활동', '버킷리스트']},
      {'category': '진지한 대화', 'items': ['일과 삶의 균형', '미래 계획', '관계에서 중요한 것']}
    ];
    
    final avoidTopics = ['전 애인', '정치/종교', '연봉', '결혼 압박', '부정적인 이야기'];
    
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
                  Icons.chat_bubble_outline,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '대화 주제 추천',
                  style: theme.textTheme.headlineSmall
                )
              ]
            ),
            const SizedBox(height: 16),
            ...topics.map((topic) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                      topic['category'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary
                      )
                    )
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (topic['items'] as List).map((item) => Chip(
                      label: Text(
                        item as String,
                        style: theme.textTheme.bodySmall
                      ),
                      backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
                      side: BorderSide(
                        color: theme.colorScheme.onSurface.withOpacity(0.2)
                      )
                    )).toList()
                  )
                ]
              )
            ).toList(),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3)
                )
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        '피해야 할 주제',
                        style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
                          color: Colors.red))]),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: avoidTopics.map((topic) => Text(
                      '• $topic',
                      style: theme.textTheme.bodySmall).toList()])]);)
  }

  Widget _buildOutfitRecommendation() {
    final theme = Theme.of(context);
    
    final outfitStyle = _getOutfitStyle();
    final colors = _getLuckyColors();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.checkroom,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '스타일링 추천',
                  style: theme.textTheme.headlineSmall
                )
              ]
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.05),
                    theme.colorScheme.secondary.withOpacity(0.05)]),
                borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '추천 스타일',
                    style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
                  const SizedBox(height: 8),
                  Text(
                    outfitStyle,
                    style: theme.textTheme.bodyMedium)])),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.palette,
                  size: 20,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '행운의 색상',
                  style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold))]),
            const SizedBox(height: 8),
            Row(
              children: colors.map((color) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color['color'],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.onSurface.withOpacity(0.2)),
                  child: Center(
                    child: Text(
                      color['name'],
                      style: theme.textTheme.bodySmall?.copyWith(
            color: (color['color'] as Color).computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white,
                        fontSize: 10))).toList()]));
  }

  String _getOutfitStyle() {
    switch (_meetingType) {
      case 'coffee': return '캐주얼하면서도 깔끔한 스타일. 편안한 니트나 셔츠에 청바지나 슬랙스를 매치하세요.';
      case 'meal':
        return '세미 포멀한 스타일. 블라우스나 셔츠에 깔끔한 하의를 매치하세요.';
      case 'activity':
        return '활동적이면서도 스타일리시한 룩. 운동화와 함께 편안한 옷차림을 선택하세요.';
      case 'walk': return '편안하고 자연스러운 스타일. 걷기 편한 신발은 필수입니다.';
      default:
        return '깔끔하고 단정한 스타일. 자신감 있게 입을 수 있는 옷을 선택하세요.';
    }
  }

  List<Map<String, dynamic>> _getLuckyColors() {
    return [
      {'name': '블루': 'color': Colors.blue},
      {'name': '화이트': 'color': Colors.white},
      {'name': '핑크': 'color': Colors.pink}];
  }

  Widget _buildDateLocationAdvice() {
    final theme = Theme.of(context);
    
    final locationAdvice = _getLocationAdvice();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '장소 & 분위기',
                  style: theme.textTheme.headlineSmall
                )
              ]
            ),
            const SizedBox(height: 16),
            ...locationAdvice.map((advice) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      advice,
                      style: theme.textTheme.bodyMedium)]).toList(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                children: [
                  Icon(
                    Icons.tips_and_updates,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '조용하고 대화하기 좋은 장소를 선택하세요. 너무 시끄럽거나 붐비는 곳은 피하는 것이 좋습니다.',
                      style: theme.textTheme.bodyMedium)])]));)
  }

  List<String> _getLocationAdvice() {
    switch (_meetingType) {
      case 'coffee':
        return [
          '분위기 좋은 독립 카페 추천': '창가 자리나 조용한 코너 선택',
          '음악이 너무 크지 않은 곳'
  ];
      case 'meal':
        return [
          '예약 가능한 레스토랑 선택': '메뉴가 다양한 곳 추천',
          '개인 공간이 보장되는 자리'
  ];
      case 'activity': return [
          '서로 즐길 수 있는 활동 선택': '대화할 기회가 있는 활동',
          '너무 경쟁적이지 않은 분위기'
  ];
      default:
        return [
          '편안한 분위기의 장소': '대화에 집중할 수 있는 환경',
          '적당한 프라이버시 보장'
  ];
    }
  }

  Widget _buildDosDonts() {
    final theme = Theme.of(context);
    
    final dos = [
      '시간 약속 지키기 (10분 전 도착)': '긍정적인 태도 유지하기',
      '상대방에게 질문하고 관심 보이기': '적당한 유머로 분위기 풀기',
      '감사 인사 전하기'
  ];
    
    final donts = [
      '핸드폰 자주 확인하지 않기': '과도한 자기 자랑 피하기',
      '부정적인 이야기 하지 않기': '너무 개인적인 질문 피하기',
      '결론 급하게 내리지 않기'
  ];
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.rule,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'DO\'s & DON\'Ts',
                  style: theme.textTheme.headlineSmall
                )
              ]
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 20,
                        color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'DO\'s - 꼭 하세요',
                        style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
                          color: Colors.green))]),
                  const SizedBox(height: 8),
                  ...dos.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(
                          child: Text(
                            item,
                            style: theme.textTheme.bodyMedium)]).toList()])),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.cancel,
                        size: 20,
                        color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        'DON\'Ts - 피하세요',
                        style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
                          color: Colors.red))]),
                  const SizedBox(height: 8),
                  ...donts.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(
                          child: Text(
                            item,
                            style: theme.textTheme.bodyMedium)]).toList()])),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.withOpacity(0.1),
                    Colors.orange.withOpacity(0.1)]),
                borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: Colors.amber),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '가장 중요한 것은 진실된 자신의 모습을 보여주는 것입니다. 행운을 빕니다!',
                      style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500)])]));
  }
}