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

class LuckyGolfFortunePage extends BaseFortunePage {
  const LuckyGolfFortunePage({Key? key})
      : super(
          key: key,
          title: '골프 운세',
          description: '오늘의 라운딩을 위한 행운의 가이드',
          fortuneType: 'lucky-golf',
          requiresUserInfo: true,
        );

  @override
  ConsumerState<LuckyGolfFortunePage> createState() => _LuckyGolfFortunePageState();
}

class _LuckyGolfFortunePageState extends BaseFortunePageState<LuckyGolfFortunePage> {
  // User golf info
  String? _skillLevel;
  String? _playFrequency;
  String? _preferredTime;
  String? _goalType;
  List<String> _weakPoints = [];
  bool _hasUpcomingTournament = false;
  String? _preferredCourse;
  
  final Map<String, String> _skillLevels = {
    'beginner': '초급 (100타 이상)',
    'intermediate': '중급 (90-100타)',
    'advanced': '상급 (80-90타)',
    'expert': '고급 (80타 미만)',
    'pro': '프로/준프로',
  };
  
  final Map<String, String> _frequencies = {
    'rarely': '월 1회 미만',
    'monthly': '월 1-2회',
    'biweekly': '월 3-4회',
    'weekly': '주 1-2회',
    'often': '주 3회 이상',
  };
  
  final Map<String, String> _timePreferences = {
    'earlymorning': '새벽 (5-7시)',
    'morning': '오전 (7-11시)',
    'afternoon': '오후 (11-15시)',
    'lateafternoon': '늦은 오후 (15-18시)',
    'flexible': '시간 무관',
  };
  
  final Map<String, String> _goals = {
    'score': '스코어 개선',
    'fun': '즐거운 라운딩',
    'social': '친목 도모',
    'exercise': '운동과 건강',
    'competition': '대회 준비',
  };
  
  final List<String> _weaknessOptions = [
    '드라이버 정확도',
    '아이언 샷',
    '어프로치',
    '퍼팅',
    '벙커샷',
    '러프 탈출',
    '멘탈 관리',
    '코스 매니지먼트',
    '거리 측정',
    '바람 읽기',
  ];
  
  final Map<String, String> _courseTypes = {
    'mountain': '산악 코스',
    'seaside': '해안 코스',
    'lakeside': '호수 코스',
    'parkland': '파크랜드',
    'links': '링크스',
    'any': '상관없음',
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

    if (_skillLevel == null || _playFrequency == null || 
        _preferredTime == null || _goalType == null ||
        _preferredCourse == null) {
      Toast.warning(context, '모든 필수 정보를 입력해주세요.');
      return null;
    }

    return {
      ...userInfo,
      'skillLevel': _skillLevel,
      'playFrequency': _playFrequency,
      'preferredTime': _preferredTime,
      'goalType': _goalType,
      'weakPoints': _weakPoints,
      'hasUpcomingTournament': _hasUpcomingTournament,
      'preferredCourse': _preferredCourse,
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
        
        // Golf Skill Info
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.golf_course, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '골프 정보',
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Skill Level
              DropdownButtonFormField<String>(
                value: _skillLevel,
                decoration: InputDecoration(
                  labelText: '실력 수준',
                  prefixIcon: const Icon(Icons.trending_up),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _skillLevels.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _skillLevel = value),
              ),
              const SizedBox(height: 16),
              
              // Play Frequency
              DropdownButtonFormField<String>(
                value: _playFrequency,
                decoration: InputDecoration(
                  labelText: '라운딩 빈도',
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
                onChanged: (value) => setState(() => _playFrequency = value),
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
                items: _timePreferences.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _preferredTime = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Goals and Weaknesses
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
                    '목표 및 개선점',
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Goal Type
              DropdownButtonFormField<String>(
                value: _goalType,
                decoration: InputDecoration(
                  labelText: '라운딩 목표',
                  prefixIcon: const Icon(Icons.sports_score),
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
                onChanged: (value) => setState(() => _goalType = value),
              ),
              const SizedBox(height: 16),
              
              // Weak Points
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '개선이 필요한 부분 (복수 선택 가능)',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _weaknessOptions.map((weakness) {
                      final isSelected = _weakPoints.contains(weakness);
                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _weakPoints.remove(weakness);
                            } else {
                              _weakPoints.add(weakness);
                            }
                          });
                        },
                        child: Chip(
                          label: Text(weakness),
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
              
              // Tournament
              _buildSwitchTile(
                '대회 참가 예정',
                _hasUpcomingTournament,
                (value) => setState(() => _hasUpcomingTournament = value),
                Icons.emoji_events,
              ),
              const SizedBox(height: 16),
              
              // Preferred Course
              DropdownButtonFormField<String>(
                value: _preferredCourse,
                decoration: InputDecoration(
                  labelText: '선호 코스 유형',
                  prefixIcon: const Icon(Icons.landscape),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _courseTypes.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _preferredCourse = value),
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
        _buildGolfScorePrediction(),
        _buildLuckyHoles(),
        _buildClubRecommendations(),
        _buildCourseStrategy(),
        _buildWeatherConditions(),
        _buildMentalTips(),
      ],
    );
  }

  Widget _buildGolfScorePrediction() {
    final theme = Theme.of(context);
    final scorePrediction = _calculateScorePrediction();
    
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
                  Icons.sports_golf,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '오늘의 예상 스코어',
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
                    _getScoreColor(scorePrediction).withOpacity(0.3),
                    _getScoreColor(scorePrediction).withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: _getScoreColor(scorePrediction),
                  width: 3,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      scorePrediction.toString(),
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(scorePrediction),
                      ),
                    ),
                    Text(
                      _getScoreMessage(scorePrediction),
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
              '오늘은 평소보다 ${_getScoreDifference(scorePrediction)} 예상됩니다!',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLuckyHoles() {
    final theme = Theme.of(context);
    final luckyHoles = _getLuckyHoles();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  '행운의 홀',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: luckyHoles.map((hole) {
                return Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(0.2),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '${hole}H',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ).animate()
                    .fadeIn(delay: (luckyHoles.indexOf(hole) * 100).ms)
                    .scale();
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              '이 홀에서 특히 좋은 성과가 예상됩니다!',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClubRecommendations() {
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
                Icon(Icons.sports_golf, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  '오늘의 행운 클럽',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildClubItem('드라이버', '평소보다 10야드 더 나갑니다!', Icons.sports_golf),
            _buildClubItem('7번 아이언', '정확도가 크게 향상됩니다', Icons.flag),
            _buildClubItem('퍼터', '오늘은 퍼팅 감각이 최고조!', Icons.radio_button_checked),
          ],
        ),
      ),
    );
  }

  Widget _buildClubItem(String club, String description, IconData icon) {
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
                Text(
                  club,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
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

  Widget _buildCourseStrategy() {
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
                Icon(Icons.map, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  '코스 공략법',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStrategyItem('전반 9홀', '공격적으로 플레이하세요'),
            _buildStrategyItem('후반 9홀', '안정적인 플레이 권장'),
            _buildStrategyItem('파3 홀', '핀 왼쪽이 유리합니다'),
            _buildStrategyItem('파5 홀', '투온 도전 추천!'),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategyItem(String title, String strategy) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.chevron_right,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: strategy),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherConditions() {
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
                Icon(Icons.wb_sunny, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  '날씨 운세',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherItem('바람', '순풍 예상', Icons.air, Colors.blue),
                _buildWeatherItem('기온', '쾌적함', Icons.thermostat, Colors.green),
                _buildWeatherItem('습도', '적당함', Icons.water_drop, Colors.cyan),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherItem(String label, String value, IconData icon, Color color) {
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
    );
  }

  Widget _buildMentalTips() {
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
                Icon(Icons.psychology, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  '멘탈 관리 팁',
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
                    Colors.purple.withOpacity(0.1),
                    Colors.blue.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '"오늘은 실수해도 괜찮다"',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '편안한 마음으로 플레이하면 오히려 좋은 결과가 나옵니다.',
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

  int _calculateScorePrediction() {
    // Simple score prediction based on skill level
    switch (_skillLevel) {
      case 'beginner':
        return 100 + (math.Random().nextInt(10) - 5);
      case 'intermediate':
        return 90 + (math.Random().nextInt(10) - 5);
      case 'advanced':
        return 85 + (math.Random().nextInt(8) - 4);
      case 'expert':
        return 75 + (math.Random().nextInt(6) - 3);
      case 'pro':
        return 70 + (math.Random().nextInt(4) - 2);
      default:
        return 95;
    }
  }

  List<int> _getLuckyHoles() {
    final today = DateTime.now();
    final random = math.Random(today.day + today.month);
    final holes = <int>[];
    
    while (holes.length < 3) {
      final hole = random.nextInt(18) + 1;
      if (!holes.contains(hole)) {
        holes.add(hole);
      }
    }
    
    holes.sort();
    return holes;
  }

  Color _getScoreColor(int score) {
    if (score <= 75) return Colors.green;
    if (score <= 85) return Colors.blue;
    if (score <= 95) return Colors.orange;
    return Colors.red;
  }

  String _getScoreMessage(int score) {
    if (score <= 75) return '최고의 라운딩!';
    if (score <= 85) return '좋은 스코어!';
    if (score <= 95) return '평균적인 날';
    return '연습이 필요해요';
  }

  String _getScoreDifference(int score) {
    final baseScore = _getBaseScore();
    final diff = score - baseScore;
    
    if (diff < 0) return '${-diff}타 좋은 스코어가';
    if (diff > 0) return '${diff}타 높은 스코어가';
    return '평소와 비슷한 스코어가';
  }

  int _getBaseScore() {
    switch (_skillLevel) {
      case 'beginner': return 105;
      case 'intermediate': return 95;
      case 'advanced': return 85;
      case 'expert': return 78;
      case 'pro': return 72;
      default: return 95;
    }
  }
}