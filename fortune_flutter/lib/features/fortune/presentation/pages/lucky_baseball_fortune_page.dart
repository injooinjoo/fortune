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

class LuckyBaseballFortunePage extends BaseFortunePage {
  const LuckyBaseballFortunePage({Key? key})
      : super(
          key: key,
          title: '야구 운세',
          description: '오늘의 경기를 위한 행운의 가이드',
          fortuneType: 'lucky-baseball',
          requiresUserInfo: true,
        );

  @override
  ConsumerState<LuckyBaseballFortunePage> createState() => _LuckyBaseballFortunePageState();
}

class _LuckyBaseballFortunePageState extends BaseFortunePageState<LuckyBaseballFortunePage> {
  // User baseball info
  String? _position;
  String? _playLevel;
  String? _battingStyle;
  String? _pitchingStyle;
  List<String> _strengths = [];
  List<String> _needsImprovement = [];
  String? _favoriteTeam;
  bool _isGameToday = false;
  String? _gameType;
  
  final Map<String, String> _positions = {
    'pitcher': '투수',
    'catcher': '포수',
    'first': '1루수',
    'second': '2루수',
    'third': '3루수',
    'shortstop': '유격수',
    'left': '좌익수',
    'center': '중견수',
    'right': '우익수',
    'dh': '지명타자',
    'utility': '유틸리티',
  };
  
  final Map<String, String> _playLevels = {
    'beginner': '초급 (야구 입문)',
    'amateur': '아마추어 (동호회)',
    'experienced': '경험자 (학교/클럽)',
    'semipro': '준프로급',
    'pro': '프로/전문선수',
  };
  
  final Map<String, String> _battingStyles = {
    'power': '파워 히터',
    'contact': '컨택 히터',
    'balanced': '균형형',
    'speed': '스피드형',
    'clutch': '클러치 히터',
  };
  
  final Map<String, String> _pitchingStyles = {
    'power': '파워 피처',
    'finesse': '기교파',
    'groundball': '그라운드볼 유도형',
    'strikeout': '삼진 중심',
    'control': '제구력 중심',
    'notpitcher': '투수 아님',
  };
  
  final List<String> _skillOptions = [
    '타격',
    '번트',
    '주루',
    '수비',
    '송구',
    '투구',
    '제구',
    '구속',
    '변화구',
    '체력',
    '집중력',
    '팀워크',
  ];
  
  final Map<String, String> _gameTypes = {
    'practice': '연습 경기',
    'league': '리그전',
    'tournament': '토너먼트',
    'friendly': '친선 경기',
    'championship': '챔피언십',
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

    if (_position == null || _playLevel == null || 
        _battingStyle == null || _pitchingStyle == null) {
      Toast.warning(context, '모든 필수 정보를 입력해주세요.');
      return null;
    }

    return {
      ...userInfo,
      'position': _position,
      'playLevel': _playLevel,
      'battingStyle': _battingStyle,
      'pitchingStyle': _pitchingStyle,
      'strengths': _strengths,
      'needsImprovement': _needsImprovement,
      'favoriteTeam': _favoriteTeam,
      'isGameToday': _isGameToday,
      'gameType': _gameType,
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
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
        
        // Baseball Position Info
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.sports_baseball, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '야구 정보',
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Position
              DropdownButtonFormField<String>(
                value: _position,
                decoration: InputDecoration(
                  labelText: '주 포지션',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _positions.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _position = value),
              ),
              const SizedBox(height: 16),
              
              // Play Level
              DropdownButtonFormField<String>(
                value: _playLevel,
                decoration: InputDecoration(
                  labelText: '실력 수준',
                  prefixIcon: const Icon(Icons.star),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _playLevels.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _playLevel = value),
              ),
              const SizedBox(height: 16),
              
              // Favorite Team
              TextFormField(
                onChanged: (value) => _favoriteTeam = value,
                decoration: InputDecoration(
                  labelText: '좋아하는 팀 (선택)',
                  hintText: '예: 두산 베어스',
                  prefixIcon: const Icon(Icons.favorite),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Play Style
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.sports, color: theme.colorScheme.secondary),
                  const SizedBox(width: 8),
                  Text(
                    '플레이 스타일',
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Batting Style
              DropdownButtonFormField<String>(
                value: _battingStyle,
                decoration: InputDecoration(
                  labelText: '타격 스타일',
                  prefixIcon: const Icon(Icons.sports_baseball),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _battingStyles.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _battingStyle = value),
              ),
              const SizedBox(height: 16),
              
              // Pitching Style
              DropdownButtonFormField<String>(
                value: _pitchingStyle,
                decoration: InputDecoration(
                  labelText: '투구 스타일',
                  prefixIcon: const Icon(Icons.sports_handball),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _pitchingStyles.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _pitchingStyle = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Skills Assessment
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.assessment, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    '기술 평가',
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Strengths
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '강점 (복수 선택 가능)',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _skillOptions.map((skill) {
                      final isSelected = _strengths.contains(skill);
                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _strengths.remove(skill);
                            } else {
                              _strengths.add(skill);
                            }
                          });
                        },
                        child: Chip(
                          label: Text(skill),
                          backgroundColor: isSelected
                              ? Colors.green.withValues(alpha: 0.2)
                              : theme.colorScheme.surface.withValues(alpha: 0.5),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.green
                                : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Needs Improvement
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
                    children: _skillOptions.map((skill) {
                      final isSelected = _needsImprovement.contains(skill);
                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _needsImprovement.remove(skill);
                            } else {
                              _needsImprovement.add(skill);
                            }
                          });
                        },
                        child: Chip(
                          label: Text(skill),
                          backgroundColor: isSelected
                              ? Colors.orange.withValues(alpha: 0.2)
                              : theme.colorScheme.surface.withValues(alpha: 0.5),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.orange
                                : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Today's Game
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSwitchTile(
                '오늘 경기가 있나요?',
                _isGameToday,
                (value) => setState(() => _isGameToday = value),
                Icons.event,
              ),
              
              if (_isGameToday) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _gameType,
                  decoration: InputDecoration(
                    labelText: '경기 유형',
                    prefixIcon: const Icon(Icons.emoji_events),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _gameTypes.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _gameType = value),
                ),
              ],
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
        _buildBattingPrediction(),
        _buildLuckyInnings(),
        _buildFieldPosition(),
        _buildPitchingGuide(),
        _buildTeamChemistry(),
        _buildGameMVPPrediction(),
      ],
    );
  }

  Widget _buildBattingPrediction() {
    final theme = Theme.of(context);
    final battingAverage = _calculateBattingAverage();
    
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
                  Icons.sports_baseball,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '오늘의 타율 예측',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getBattingColor(battingAverage),
                      width: 8,
                    ),
                  ),
                  child: CircularProgressIndicator(
                    value: battingAverage / 1000,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getBattingColor(battingAverage),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '.${battingAverage.toString().padLeft(3, '0')}',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getBattingColor(battingAverage),
                      ),
                    ),
                    Text(
                      _getBattingMessage(battingAverage),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ).animate()
                .scale(duration: 600.ms)
                .then()
                .shimmer(duration: 1000.ms),
            
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('안타', '${(battingAverage / 250).round()}개', Icons.trending_up),
                _buildStatItem('홈런', _getHomeRunPrediction(), Icons.flag),
                _buildStatItem('타점', '${(battingAverage / 200).round()}점', Icons.star),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildLuckyInnings() {
    final theme = Theme.of(context);
    final luckyInnings = _getLuckyInnings();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  '행운의 이닝',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: luckyInnings.map((inning) {
                return Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '$inning회',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ).animate()
                    .fadeIn(delay: (luckyInnings.indexOf(inning) * 100).ms)
                    .scale();
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              '이 이닝에서 특히 좋은 활약이 예상됩니다!',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldPosition() {
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
                Icon(Icons.stadium, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  '수비 포지션 운세',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Stack(
                children: [
                  // Baseball diamond
                  Center(
                    child: Transform.rotate(
                      angle: math.pi / 4,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          color: Colors.brown.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                  // Position indicator
                  Positioned(
                    top: 80,
                    left: 0,
                    right: 0,
                    child: Text(
                      _getPositionAdvice(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                      textAlign: TextAlign.center,
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

  Widget _buildPitchingGuide() {
    final theme = Theme.of(context);
    
    if (_pitchingStyle == 'notpitcher') {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sports_handball, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  '투구 가이드',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPitchItem('직구', '오늘은 특히 위력적입니다!', Colors.red),
            _buildPitchItem('변화구', '체인지업이 효과적일 예정', Colors.blue),
            _buildPitchItem('제구', '스트라이크 존 코너를 노리세요', Colors.green),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.tips_and_updates, 
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '첫 타자는 신중하게 상대하세요',
                      style: theme.textTheme.bodyMedium,
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

  Widget _buildPitchItem(String pitch, String description, Color color) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: '$pitch: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamChemistry() {
    final theme = Theme.of(context);
    final chemistryScore = _calculateTeamChemistry();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.groups, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  '팀 케미스트리',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: chemistryScore / 100,
              minHeight: 12,
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getChemistryColor(chemistryScore),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '팀워크 지수',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  '$chemistryScore%',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getChemistryColor(chemistryScore),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _getChemistryMessage(chemistryScore),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameMVPPrediction() {
    final theme = Theme.of(context);
    final mvpChance = _calculateMVPChance();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'MVP 가능성',
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
                    Colors.amber.withValues(alpha: 0.2),
                    Colors.orange.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '$mvpChance%',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getMVPMessage(mvpChance),
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate()
                .fadeIn()
                .shimmer(delay: 500.ms, duration: 1500.ms),
          ],
        ),
      ),
    );
  }

  int _calculateBattingAverage() {
    final random = math.Random(DateTime.now().day);
    int base = 250;
    
    switch (_battingStyle) {
      case 'contact':
        base = 280 + random.nextInt(40);
        break;
      case 'power':
        base = 220 + random.nextInt(60);
        break;
      case 'balanced':
        base = 250 + random.nextInt(50);
        break;
      case 'speed':
        base = 260 + random.nextInt(40);
        break;
      case 'clutch':
        base = 270 + random.nextInt(50);
        break;
    }
    
    if (_strengths.contains('타격')) base += 20;
    if (_needsImprovement.contains('타격')) base -= 15;
    
    return base.clamp(150, 400);
  }

  String _getHomeRunPrediction() {
    if (_battingStyle == 'power' && _strengths.contains('타격')) {
      return '1-2개';
    } else if (_battingStyle == 'power') {
      return '1개 가능';
    }
    return '어려움';
  }

  List<int> _getLuckyInnings() {
    final today = DateTime.now();
    final random = math.Random(today.day + today.month);
    final innings = <int>[];
    
    while (innings.length < 2) {
      final inning = random.nextInt(9) + 1;
      if (!innings.contains(inning)) {
        innings.add(inning);
      }
    }
    
    innings.sort();
    return innings;
  }

  String _getPositionAdvice() {
    switch (_position) {
      case 'pitcher':
        return '마운드가 편안하게 느껴질 날';
      case 'catcher':
        return '투수 리드가 완벽할 예정';
      case 'shortstop':
        return '화려한 수비가 기대됩니다';
      case 'center':
        return '공이 잘 보이는 날';
      default:
        return '수비 집중도가 높은 날';
    }
  }

  int _calculateTeamChemistry() {
    int chemistry = 70;
    
    if (_strengths.contains('팀워크')) chemistry += 15;
    if (_gameType == 'championship') chemistry += 10;
    if (_playLevel == 'experienced' || _playLevel == 'semipro') chemistry += 5;
    
    return chemistry.clamp(0, 100);
  }

  int _calculateMVPChance() {
    int chance = 20;
    
    if (_strengths.length >= 3) chance += 20;
    if (_battingStyle == 'clutch') chance += 15;
    if (_gameType == 'championship' || _gameType == 'tournament') chance += 10;
    
    final battingAvg = _calculateBattingAverage();
    if (battingAvg >= 300) chance += 20;
    
    return chance.clamp(0, 90);
  }

  Color _getBattingColor(int average) {
    if (average >= 300) return Colors.red;
    if (average >= 270) return Colors.orange;
    if (average >= 250) return Colors.blue;
    return Colors.grey;
  }

  String _getBattingMessage(int average) {
    if (average >= 300) return '최고의 타격감!';
    if (average >= 270) return '좋은 컨디션';
    if (average >= 250) return '평균적인 날';
    return '집중이 필요해요';
  }

  Color _getChemistryColor(int score) {
    if (score >= 80) return Colors.purple;
    if (score >= 60) return Colors.blue;
    return Colors.grey;
  }

  String _getChemistryMessage(int score) {
    if (score >= 80) return '팀원들과 완벽한 호흡을 보일 예정!';
    if (score >= 60) return '팀워크가 좋은 편입니다';
    return '개인 플레이에 집중하세요';
  }

  String _getMVPMessage(int chance) {
    if (chance >= 70) return '오늘의 주인공이 될 가능성이 높습니다!';
    if (chance >= 50) return '좋은 활약이 기대됩니다';
    if (chance >= 30) return '꾸준히 플레이하세요';
    return '팀 승리에 집중하세요';
  }
}