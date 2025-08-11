import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/toast.dart';

class CoupleMatchPage extends BaseFortunePage {
  const CoupleMatchPage({Key? key})
      : super(
          key: key,
          title: '연인 궁합',
          description: '현재 연인과의 깊은 궁합 분석',
          fortuneType: 'couple-match',
          requiresUserInfo: false
        );

  @override
  ConsumerState<CoupleMatchPage> createState() => _CoupleMatchPageState();
}

class _CoupleMatchPageState extends BaseFortunePageState<CoupleMatchPage> {
  // My Info
  String? _myName;
  DateTime? _myBirthDate;
  String? _myGender;
  String? _myPersonality;
  List<String> _myLoveLanguages = [];
  
  // Partner Info
  String? _partnerName;
  DateTime? _partnerBirthDate;
  String? _partnerGender;
  String? _partnerPersonality;
  List<String> _partnerLoveLanguages = [];
  
  // Relationship Info
  String? _relationshipDuration;
  String? _meetingType;
  List<String> _challengeAreas = [];
  String? _futureGoal;
  
  final Map<String, String> _personalities = {
    'introvert': '내향적',
    'extrovert': '외향적',
    'logical': '논리적',
    'emotional': '감성적',
    'planned': '계획적',
    'spontaneous': '즉흥적'
  };
  
  final List<String> _loveLanguageOptions = [
    '말로 하는 애정표현',
    '스킨십과 포옹',
    '선물 주고받기',
    '함께하는 시간',
    '배려와 봉사'
  ];
  
  final Map<String, String> _durations = {
    'new': '1개월 미만',
    'short': '1-6개월',
    'medium': '6개월-1년',
    'long': '1-3년',
    'verylong': '3년 이상'
  };
  
  final Map<String, String> _meetingTypes = {
    'friend': '친구에서 연인으로',
    'blind': '소개팅',
    'app': '데이팅 앱',
    'work': '직장/학교',
    'hobby': '취미/동호회',
    'chance': '우연한 만남'
  };
  
  final List<String> _challengeOptions = [
    '의사소통 부족',
    '시간 부족',
    '가치관 차이',
    '표현 방식 차이',
    '미래 계획 차이',
    '가족 문제',
    '경제적 문제',
    '신뢰 문제'
  ];
  
  final Map<String, String> _futureGoals = {
    'marriage': '결혼을 목표로',
    'growth': '함께 성장하기',
    'enjoy': '현재를 즐기기',
    'uncertain': '아직 불확실'
  };

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final fortuneService = ref.read(fortuneServiceProvider);
    
    return await fortuneService.getFortune(
      fortuneType: widget.fortuneType,
      userId: ref.read(userProvider).value?.id ?? 'anonymous',
      params: params
    );
  }

  @override
  Future<Map<String, dynamic>?> getFortuneParams() async {
    if (_myName == null || _myBirthDate == null || _myGender == null ||
        _myPersonality == null || _myLoveLanguages.isEmpty ||
        _partnerName == null || _partnerBirthDate == null || 
        _partnerGender == null || _partnerPersonality == null ||
        _partnerLoveLanguages.isEmpty || _relationshipDuration == null ||
        _meetingType == null || _futureGoal == null) {
      Toast.warning(context, '모든 필수 정보를 입력해주세요.');
      return null;
    }

    return {
      'me': {
        'name': _myName,
        'birthDate': _myBirthDate!.toIso8601String(),
        'gender': _myGender,
        'personality': _myPersonality,
        'loveLanguages': _myLoveLanguages},
      'partner': {
        'name': _partnerName,
        'birthDate': _partnerBirthDate!.toIso8601String(),
        'gender': _partnerGender,
        'personality': _partnerPersonality,
        'loveLanguages': _partnerLoveLanguages},
      'relationship': {
        'duration': _relationshipDuration,
        'meetingType': _meetingType,
        'challengeAreas': _challengeAreas,
        'futureGoal': _futureGoal}};
  }

  @override
  Widget buildInputForm() {
    final theme = Theme.of(context);

    return Column(
      children: [
        // My Info
        _buildPersonCard(
          title: '나의 정보',
          icon: Icons.person,
          color: theme.colorScheme.primary,
          name: _myName,
          onNameChanged: (value) => setState(() => _myName = value),
          birthDate: _myBirthDate,
          onBirthDateChanged: (date) => setState(() => _myBirthDate = date),
          gender: _myGender,
          onGenderChanged: (value) => setState(() => _myGender = value),
          personality: _myPersonality,
          onPersonalityChanged: (value) => setState(() => _myPersonality = value),
          loveLanguages: _myLoveLanguages,
          onLoveLanguageToggle: (language) {
            setState(() {
              if (_myLoveLanguages.contains(language)) {
                _myLoveLanguages.remove(language);
              } else {
                _myLoveLanguages.add(language);
              }
            });
          }),
        const SizedBox(height: 16),
        
        // Heart Icon
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.pink.withOpacity(0.3),
                  Colors.red.withOpacity(0.3)])),
            child: const Icon(
              Icons.favorite,
              color: Colors.red,
              size: 40),
          ),
        ),
        const SizedBox(height: 16),
        
        // Partner Info
        _buildPersonCard(
          title: '연인의 정보',
          icon: Icons.person,
          color: theme.colorScheme.secondary,
          name: _partnerName,
          onNameChanged: (value) => setState(() => _partnerName = value),
          birthDate: _partnerBirthDate,
          onBirthDateChanged: (date) => setState(() => _partnerBirthDate = date),
          gender: _partnerGender,
          onGenderChanged: (value) => setState(() => _partnerGender = value),
          personality: _partnerPersonality,
          onPersonalityChanged: (value) => setState(() => _partnerPersonality = value),
          loveLanguages: _partnerLoveLanguages,
          onLoveLanguageToggle: (language) {
            setState(() {
              if (_partnerLoveLanguages.contains(language)) {
                _partnerLoveLanguages.remove(language);
              } else {
                _partnerLoveLanguages.add(language);
              }
            });
          }),
        const SizedBox(height: 16),
        
        // Relationship Info
        GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '우리의 관계',
                style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              
              // Duration
              Text(
                '교제 기간',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _relationshipDuration,
                decoration: InputDecoration(
                  hintText: '교제 기간을 선택하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: theme.colorScheme.surface.withOpacity(0.5)),
                items: _durations.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _relationshipDuration = value;
                  });
                }),
              const SizedBox(height: 16),
              
              // Meeting Type
              Text(
                '만남의 계기',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _meetingTypes.entries.map((entry) {
                  final isSelected = _meetingType == entry.key;
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _meetingType = entry.key;
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
                            : theme.colorScheme.onSurface.withOpacity(0.3)),
                    ),
                  );
                }).toList(),
              const SizedBox(height: 16),
              
              // Challenge Areas
              Text(
                '개선하고 싶은 부분 (선택)',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _challengeOptions.map((area) {
                  final isSelected = _challengeAreas.contains(area);
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _challengeAreas.remove(area);
                        } else {
                          _challengeAreas.add(area);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Chip(
                      label: Text(area),
                      backgroundColor: isSelected
                          ? Colors.orange.withOpacity(0.2)
                          : theme.colorScheme.surface.withOpacity(0.5),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.orange
                            : theme.colorScheme.onSurface.withOpacity(0.3)),
                    ),
                  );
                }).toList(),
              const SizedBox(height: 16),
              
              // Future Goal
              Text(
                '관계의 목표',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...(_futureGoals.entries.map((entry) {
                final isSelected = _futureGoal == entry.key;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _futureGoal = entry.key;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
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
                            groupValue: _futureGoal,
                            onChanged: (value) {
                              setState(() {
                                _futureGoal = value;
                              });
                            }),
                          Text(
                            entry.value,
                            style: theme.textTheme.bodyLarge),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPersonCard({
    required String title,
    required IconData icon,
    required Color color,
    required String? name,
    required Function(String) onNameChanged,
    required DateTime? birthDate,
    required Function(DateTime) onBirthDateChanged,
    required String? gender,
    required Function(String?) onGenderChanged,
    required String? personality,
    required Function(String?) onPersonalityChanged,
    required List<String> loveLanguages,
    required Function(String) onLoveLanguageToggle}) {
    final theme = Theme.of(context);
    
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: 16),
          
          // Name
          TextField(
            decoration: InputDecoration(
              labelText: '이름',
              hintText: '이름을 입력하세요',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: theme.colorScheme.surface.withOpacity(0.5)),
            onChanged: onNameChanged),
          const SizedBox(height: 16),
          
          // Gender
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => onGenderChanged('male'),
                  borderRadius: BorderRadius.circular(12),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(12),
                    blur: 10,
                    borderColor: gender == 'male'
                        ? color.withOpacity(0.5)
                        : Colors.transparent,
                    borderWidth: gender == 'male' ? 2 : 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.male,
                          color: gender == 'male' ? color : null),
                        const SizedBox(width: 8),
                        Text('남성'),
                      ],
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => onGenderChanged('female'),
                  borderRadius: BorderRadius.circular(12),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(12),
                    blur: 10,
                    borderColor: gender == 'female'
                        ? color.withOpacity(0.5)
                        : Colors.transparent,
                    borderWidth: gender == 'female' ? 2 : 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.female,
                          color: gender == 'female' ? color : null),
                        const SizedBox(width: 8),
                        Text('여성'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          const SizedBox(height: 16),
          
          // Birth Date
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: birthDate ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now());
              if (date != null) {
                onBirthDateChanged(date);
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: '생년월일',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: theme.colorScheme.surface.withOpacity(0.5),
                suffixIcon: const Icon(Icons.calendar_today)),
              child: Text(
                birthDate != null
                    ? '${birthDate.year}년 ${birthDate.month}월 ${birthDate.day}일'
                    : '생년월일을 선택하세요'),
            ),
          const SizedBox(height: 16),
          
          // Personality
          Text(
            '성격 유형',
            style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: personality,
            decoration: InputDecoration(
              hintText: '성격을 선택하세요',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: theme.colorScheme.surface.withOpacity(0.5)),
            items: _personalities.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value));
            }).toList(),
            onChanged: onPersonalityChanged),
          const SizedBox(height: 16),
          
          // Love Languages
          Text(
            '사랑의 언어 (2개 이상)',
            style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _loveLanguageOptions.map((language) {
              final isSelected = loveLanguages.contains(language);
              
              return InkWell(
                onTap: () => onLoveLanguageToggle(language),
                borderRadius: BorderRadius.circular(20),
                child: Chip(
                  label: Text(language),
                  backgroundColor: isSelected
                      ? color.withOpacity(0.2)
                      : theme.colorScheme.surface.withOpacity(0.5),
                  side: BorderSide(
                    color: isSelected
                        ? color
                        : theme.colorScheme.onSurface.withOpacity(0.3)),
                  deleteIcon: isSelected
                      ? const Icon(Icons.check_circle, size: 18)
                      : null,
                  onDeleted: isSelected ? () {} : null),
                );
            }).toList()),
          ],
        ),
      );
  }

  @override
  Widget buildFortuneResult() {
    return Column(
      children: [
        super.buildFortuneResult(),
        _buildOverallCompatibility(),
        _buildLoveStyleAnalysis(),
        _buildCommunicationGuide(),
        _buildConflictResolution(),
        _buildGrowthRoadmap(),
        _buildDateIdeas()]);
  }

  Widget _buildOverallCompatibility() {
    final theme = Theme.of(context);
    final score = 87;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '전체 궁합도',
              style: theme.textTheme.headlineSmall),
            const SizedBox(height: 24),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CustomPaint(
                    painter: HeartProgressPainter(
                      progress: score / 100,
                      progressColor: Colors.red,
                      backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1)),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '$score%',
                      style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
                        color: Colors.red)),
                    Text(
                      '찰떡궁합',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.red)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.pink.withOpacity(0.1),
                    Colors.red.withOpacity(0.1)]),
                borderRadius: BorderRadius.circular(12),
              child: Text(
                '${_myName ?? "당신"}님과 ${_partnerName ?? "연인"}님은 서로를 깊이 이해하고 보완하는 환상의 커플입니다. 특히 감정적 교감과 가치관의 일치도가 높아 오래도록 행복한 관계를 유지할 수 있습니다.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoveStyleAnalysis() {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.favorite_border,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '사랑 표현 스타일',
                  style: theme.textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 16),
            _buildLoveStyleComparison(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 맞춤 조언',
                    style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    '${_myName ?? "당신"}님은 ${_myLoveLanguages.isNotEmpty ? _myLoveLanguages.first : "말로 하는 애정표현"}을 중요시하고, ${_partnerName ?? "연인"}님은 ${_partnerLoveLanguages.isNotEmpty ? _partnerLoveLanguages.first : "함께하는 시간"}을 가장 중요하게 생각합니다. 서로의 사랑 표현 방식을 이해하고 맞춰가면 더욱 깊은 사랑을 나눌 수 있습니다.',
                    style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoveStyleComparison() {
    final theme = Theme.of(context);
    
    return Column(
      children: _loveLanguageOptions.map((language) {
        final myScore = _myLoveLanguages.contains(language) ? 80 + math.Random().nextInt(20) : 20 + math.Random().nextInt(30);
        final partnerScore = _partnerLoveLanguages.contains(language) ? 80 + math.Random().nextInt(20) : 20 + math.Random().nextInt(30);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                language,
                style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10)),
                          ),
                        FractionallySizedBox(
                          widthFactor: myScore / 100,
                          child: Container(
                            height: 20,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withOpacity(0.7)]),
                              borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text(
                      'vs',
                      style: theme.textTheme.bodySmall)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10)),
                          ),
                        FractionallySizedBox(
                          widthFactor: partnerScore / 100,
                          child: Container(
                            height: 20,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.secondary,
                                  theme.colorScheme.secondary.withOpacity(0.7)]),
                              borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList();
  }

  Widget _buildCommunicationGuide() {
    final theme = Theme.of(context);
    
    final tips = [
      {
        'icon': Icons.chat_bubble_outline as IconData,
        'title': '대화 시작하기',
        'tip': '하루의 끝에 서로의 하루를 공유하는 시간을 가지세요.'},
      {
        'icon': Icons.hearing as IconData,
        'title': '경청하기',
        'tip': '상대방의 말을 끊지 말고 끝까지 들어주세요.'},
      {
        'icon': Icons.emoji_emotions as IconData,
        'title': '감정 표현하기',
        'tip': '"나는 ~할 때 ~한 기분이 들어"라고 표현해보세요.'},
      {
        'icon': Icons.handshake as IconData,
        'title': '타협하기',
        'tip': '서로 양보할 수 있는 지점을 찾아 합의하세요.'}];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.forum,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '소통 가이드',
                  style: theme.textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 16),
            ...tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                    child: Icon(
                      tip['icon'] as IconData,
                      size: 20,
                      color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip['title'] as String,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          tip['tip'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.8))),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildConflictResolution() {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.healing,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '갈등 해결법',
                  style: theme.textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 16),
            if (_challengeAreas.isNotEmpty) ...[
              Text(
                '선택하신 개선 영역별 조언',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ..._challengeAreas.map((area) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            area,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getConflictAdvice(area),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8))),
                    ],
                  ),
                ),
              )).toList(),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '큰 갈등 요소가 없는 건강한 관계입니다!',
                        style: theme.textTheme.bodyLarge)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getConflictAdvice(String area) {
    final advices = {
      '의사소통 부족': '매일 10분씩 서로의 하루를 나누는 시간을 가져보세요.',
      '시간 부족': '바쁜 일상 속에서도 주 1회는 데이트 시간을 확보하세요.',
      '가치관 차이': '서로의 가치관을 존중하면서 공통점을 찾아보세요.',
      '표현 방식 차이': '상대방이 좋아하는 표현 방식을 배우고 실천해보세요.',
      '미래 계획 차이': '단계별로 목표를 설정하고 함께 계획을 세워보세요.',
      '가족 문제': '서로의 가족을 이해하고 경계를 설정하세요.',
      '경제적 문제': '솔직한 재정 상황 공유와 공동의 재정 목표를 세우세요.',
      '신뢰 문제': '작은 약속부터 지키며 신뢰를 쌓아가세요.'
  };
    return advices[area] ?? '서로를 이해하고 소통하는 시간을 가져보세요.';
  }

  Widget _buildGrowthRoadmap() {
    final theme = Theme.of(context);
    
    final stages = [
      {
        'stage': '현재',
        'focus': '서로를 깊이 이해하기',
        'activities': ['깊은 대화 나누기', '취미 공유하기', '추억 만들기']},
      {
        'stage': '3개월 후',
        'focus': '신뢰 관계 강화',
        'activities': ['미래 계획 공유', '갈등 해결 연습', '가족 소개']},
      {
        'stage': '6개월 후',
        'focus': '더 깊은 유대감',
        'activities': ['여행 계획', '공동 목표 설정', '일상 공유']},
      {
        'stage': '1년 후',
        'focus': '장기적 관계 구축',
        'activities': ['결혼 논의', '재정 계획', '삶의 비전 공유']}];
    
    return Padding(
      padding: const EdgeInsets.all(16),
            child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '관계 성장 로드맵',
                  style: theme.textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 16),
            ...stages.map((stage) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.05),
                      theme.colorScheme.secondary.withOpacity(0.05)]),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(11),
                          topRight: Radius.circular(11)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.flag,
                            size: 16,
                            color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            stage['stage'] as String,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              stage['focus'] as String,
                              style: theme.textTheme.bodyMedium)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (stage['activities'] as List).map((activity) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.onSurface.withOpacity(0.1)),
                          child: Text(
                            activity as String,
                            style: theme.textTheme.bodySmall)),
                        )).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateIdeas() {
    final theme = Theme.of(context);
    
    final dateIdeas = [
      {'idea': '별 보기', 'emoji': '🌟', 'type': '로맨틱'},
      {'idea': '요리 클래스', 'emoji': '👨‍🍳', 'type': '체험'},
      {'idea': '피크닉', 'emoji': '🧺', 'type': '야외'},
      {'idea': '영화 마라톤', 'emoji': '🎬', 'type': '실내'},
      {'idea': '스파 데이트', 'emoji': '💆', 'type': '힐링'},
      {'idea': '보드게임 카페', 'emoji': '🎲', 'type': '재미'}];
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '이번 주 데이트 아이디어',
                  style: theme.textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: dateIdeas.map((idea) => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.pink.withOpacity(0.1),
                      Colors.red.withOpacity(0.1)]),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.pink.withOpacity(0.3)),
                child: Row(
                  children: [
                    Text(
                      idea['emoji'] as String,
                      style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            idea['idea'] as String,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold)),
                          Text(
                            idea['type'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6))),
                        ],
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for heart-shaped progress
class HeartProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;

  HeartProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 200;

    // Draw background heart
    paint.color = backgroundColor;
    _drawHeart(canvas, center, scale, paint);

    // Draw progress heart
    canvas.save();
    canvas.clipPath(_getHeartPath(center, scale));
    
    paint.color = progressColor;
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        size.height * (1 - progress),
        size.width,
        size.height * progress),
      paint
    );
    
    canvas.restore();
  }

  Path _getHeartPath(Offset center, double scale) {
    final path = Path();
    final dx = center.dx;
    final dy = center.dy - 30 * scale;

    path.moveTo(dx, dy + 25 * scale);
    
    path.cubicTo(
      dx - 20 * scale, dy - 10 * scale,
      dx - 60 * scale, dy - 10 * scale,
      dx - 60 * scale, dy + 20 * scale
    );
    
    path.cubicTo(
      dx - 60 * scale, dy + 50 * scale,
      dx, dy + 90 * scale,
      dx, dy + 90 * scale
    );
    
    path.cubicTo(
      dx, dy + 90 * scale,
      dx + 60 * scale, dy + 50 * scale,
      dx + 60 * scale, dy + 20 * scale
    );
    
    path.cubicTo(
      dx + 60 * scale, dy - 10 * scale,
      dx + 20 * scale, dy - 10 * scale,
      dx, dy + 25 * scale
    );
    
    path.close();
    return path;
  }

  void _drawHeart(Canvas canvas, Offset center, double scale, Paint paint) {
    canvas.drawPath(_getHeartPath(center, scale), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}