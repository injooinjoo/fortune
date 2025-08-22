import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../widgets/talent_dna_chart.dart';
import '../widgets/talent_share_card.dart';
import '../../../../presentation/widgets/fortune_explanation_bottom_sheet.dart';

class TalentFortunePage extends BaseFortunePage {
  const TalentFortunePage({super.key})
      : super(
          title: '재능 발견',
          description: '매일 새롭게 발견하는 나의 재능!\n당신의 숨은 재능과 잠재력을 분석해드립니다.',
          fortuneType: 'talent',
          requiresUserInfo: true,
        );

  @override
  ConsumerState<TalentFortunePage> createState() => _TalentFortunePageState();
}

class _TalentFortunePageState extends BaseFortunePageState<TalentFortunePage> {
  Map<String, dynamic>? _talentQuestions;

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    // 재능 분석 API 호출을 시뮬레이션
    await Future.delayed(const Duration(seconds: 2));
    
    // 사용자 답변을 바탕으로 재능 분석 결과 생성
    final talents = _analyzeTalents(params);
    
    return Fortune(
      id: 'talent_${DateTime.now().millisecondsSinceEpoch}',
      userId: userProfile?.id ?? 'anonymous',
      type: 'talent',
      content: _generateTalentDescription(talents),
      createdAt: DateTime.now(),
      category: 'talent-discovery',
      overallScore: talents['overall'] as int,
      scoreBreakdown: Map<String, int>.from(talents)..remove('overall'),
      description: '당신의 재능 DNA 분석 결과입니다.',
      luckyItems: {
        'talent_dna': talents,
        'top_careers': ['UX 디자이너', '마케팅 전략가', '프로덕트 매니저'],
        'hobbies': ['창작 글쓰기', '팟캐스트 제작', '디자인 스터디'],
      },
      recommendations: [
        '소통 스킬을 더욱 발전시켜보세요',
        '창의적인 프로젝트에 참여해보세요',
        '리더십 역량 개발에 집중하세요',
        '새로운 분야에 도전해보세요',
      ],
    );
  }

  Map<String, int> _analyzeTalents(Map<String, dynamic> params) {
    // 간단한 재능 분석 로직
    final interests = params['interests'] as List<String>? ?? [];
    final confidence = params['confidence_situation'] as String? ?? '';
    final strengths = params['recognized_strengths'] as List<String>? ?? [];
    
    var creativity = 70;
    var communication = 75;
    var analysis = 65;
    var leadership = 60;
    var focus = 70;
    var intuition = 75;
    
    // 관심 분야에 따른 점수 조정
    if (interests.contains('창작/예술')) creativity += 15;
    if (interests.contains('분석/연구')) analysis += 15;
    if (interests.contains('소통/리더십')) {
      communication += 15;
      leadership += 10;
    }
    
    // 자신감 상황에 따른 조정
    switch (confidence) {
      case '사람들 앞에서 발표할 때':
        communication += 10;
        leadership += 10;
        break;
      case '혼자 깊이 생각할 때':
        analysis += 10;
        focus += 10;
        break;
      case '문제를 해결할 때':
        analysis += 15;
        break;
    }
    
    // 인정받는 강점에 따른 조정
    if (strengths.contains('아이디어가 독특해')) creativity += 10;
    if (strengths.contains('사람들과 잘 어울려')) communication += 10;
    if (strengths.contains('꼼꼼하고 정확해')) analysis += 10;
    
    return {
      '창의력': creativity.clamp(0, 100),
      '소통력': communication.clamp(0, 100),
      '분석력': analysis.clamp(0, 100),
      '리더십': leadership.clamp(0, 100),
      '집중력': focus.clamp(0, 100),
      '직감력': intuition.clamp(0, 100),
      'overall': ((creativity + communication + analysis + leadership + focus + intuition) / 6).round(),
    };
  }

  String _generateTalentDescription(Map<String, int> talents) {
    final topTalent = talents.entries
        .where((e) => e.key != 'overall')
        .reduce((a, b) => a.value > b.value ? a : b);
    
    return '''당신의 가장 강한 재능은 "${topTalent.key}"입니다. 
    
${topTalent.key}이 ${topTalent.value}점으로 특히 뛰어나며, 이를 활용한 다양한 분야에서 성공할 가능성이 높습니다.

균형 잡힌 재능 분포를 보이고 있어 다재다능한 성향을 가지고 있습니다. 특히 창의적 사고와 소통 능력이 조화를 이루어 리더십 발휘에 유리한 조건을 갖추고 있습니다.''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? _buildErrorState()
                : fortune != null
                    ? _TalentFortuneResult(
                        fortune: fortune!,
                        onShare: () => _showTalentShareDialog(context, fortune!),
                      )
                    : _TalentIntroScreen(
                        onStartFortune: _showTalentBottomSheet,
                      ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            '오류가 발생했습니다',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error ?? '알 수 없는 오류',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _talentQuestions = null;
              });
              _showTalentBottomSheet();
            },
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  void _showTalentBottomSheet() {
    FortuneExplanationBottomSheet.show(
      context,
      fortuneType: widget.fortuneType,
      onFortuneButtonPressed: () {
        Navigator.of(context).pop();
        _startTalentAnalysis();
      },
    );
  }

  void _startTalentAnalysis() {
    _showTalentQuestionBottomSheet();
  }

  void _showTalentQuestionBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => _TalentQuestionBottomSheet(
        onComplete: (answers) {
          Navigator.of(context).pop();
          _talentQuestions = answers;
          generateFortuneAction(params: answers);
        },
      ),
    );
  }

  void _showTalentShareDialog(BuildContext context, Fortune fortune) {
    final talentData = fortune.luckyItems?['talent_dna'] as Map<String, int>? ?? {};
    
    showDialog(
      context: context,
      builder: (context) => TalentSharePreview(
        userName: userProfile?.name ?? '',
        talentData: talentData,
        onShare: () {
          Navigator.of(context).pop();
          // 실제 공유 로직 구현
        },
      ),
    );
  }
}

class _TalentIntroScreen extends StatelessWidget {
  final VoidCallback onStartFortune;

  const _TalentIntroScreen({
    required this.onStartFortune,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    
    // Get today's focus
    final Map<int, Map<String, dynamic>> dailyFocus = {
      1: {'name': '창의력', 'icon': Icons.palette, 'color': Colors.purple},
      2: {'name': '분석력', 'icon': Icons.analytics, 'color': Colors.blue},
      3: {'name': '소통능력', 'icon': Icons.chat, 'color': Colors.green},
      4: {'name': '리더십', 'icon': Icons.groups, 'color': Colors.orange},
      5: {'name': '집중력', 'icon': Icons.center_focus_strong, 'color': Colors.red},
      6: {'name': '직감력', 'icon': Icons.psychology, 'color': Colors.indigo},
      7: {'name': '회복력', 'icon': Icons.self_improvement, 'color': Colors.teal},
    };
    
    final focus = dailyFocus[today.weekday]!;
    final activationLevel = 75 + (today.day % 25);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                // 메인 아이콘
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFB300).withOpacity(0.2),
                        Color(0xFFFF8F00).withOpacity(0.2),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.psychology,
                    size: 60,
                    color: Color(0xFFFFB300),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 제목
                Text(
                  '재능 발견',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 설명
                Text(
                  '매일 새롭게 발견하는 나의 재능!\n3가지 질문으로 당신의 숨은 재능을 찾아보세요.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // 오늘의 재능 포커스 카드
                GlassContainer(
                  padding: const EdgeInsets.all(24),
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.wb_sunny,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '오늘의 재능 포커스',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: focus['color'].withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              focus['icon'],
                              color: focus['color'],
                              size: 36,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  focus['name'],
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: focus['color'],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '오늘 활성화 지수: $activationLevel%',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 특징 리스트
                _buildFeatureList(theme),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        
        // 하단 버튼
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: onStartFortune,
              icon: const Icon(Icons.stars),
              label: const Text(
                '운세 보기',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFB300),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureList(ThemeData theme) {
    final features = [
      {
        'icon': Icons.psychology,
        'title': '재능 DNA 분석',
        'description': '6가지 핵심 재능 영역을 시각적으로 분석',
      },
      {
        'icon': Icons.work,
        'title': '맞춤 직업 추천',
        'description': '당신의 재능에 어울리는 직업과 취미 제안',
      },
      {
        'icon': Icons.timeline,
        'title': '성장 로드맵',
        'description': '단계별 재능 개발 가이드와 실행 방안',
      },
      {
        'icon': Icons.share,
        'title': '결과 공유',
        'description': '개인화된 재능 카드로 SNS 공유 가능',
      },
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature['title'] as String,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      feature['description'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _TalentQuestionBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;

  const _TalentQuestionBottomSheet({
    required this.onComplete,
  });

  @override
  State<_TalentQuestionBottomSheet> createState() => _TalentQuestionBottomSheetState();
}

class _TalentQuestionBottomSheetState extends State<_TalentQuestionBottomSheet> {
  int _currentStep = 0;
  final Map<String, dynamic> _answers = {};
  
  final List<Map<String, dynamic>> _questions = [
    {
      'title': '현재 어떤 분야에 관심이 많으신가요?',
      'key': 'interests',
      'type': 'multiple_choice',
      'options': ['창작/예술', '분석/연구', '소통/리더십', '기술/엔지니어링', '돌봄/서비스', '운동/신체활동']
    },
    {
      'title': '어떤 상황에서 가장 자신감을 느끼시나요?',
      'key': 'confidence_situation',
      'type': 'single_choice',
      'options': ['혼자 깊이 생각할 때', '사람들 앞에서 발표할 때', '새로운 것을 배울 때', '문제를 해결할 때', '팀과 협업할 때']
    },
    {
      'title': '평소 주변에서 어떤 부분을 인정받나요?',
      'key': 'recognized_strengths',
      'type': 'multiple_choice',
      'options': ['아이디어가 독특해', '꼼꼼하고 정확해', '사람들과 잘 어울려', '새로운 기술을 빨리 익혀', '끈기가 있어', '센스가 좋아']
    }
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Progress bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'STEP ${_currentStep + 1}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_currentStep + 1}/${_questions.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          
          LinearProgressIndicator(
            value: (_currentStep + 1) / _questions.length,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
          
          Expanded(
            child: _currentStep < _questions.length
                ? _buildQuestionView(theme)
                : _buildCompleteView(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionView(ThemeData theme) {
    final question = _questions[_currentStep];
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question['title'],
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: ListView(
              children: question['options'].map<Widget>((option) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildOptionTile(option, question['key'], question['type'] == 'multiple_choice', theme),
              )).toList(),
            ),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep > 0)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentStep--;
                    });
                  },
                  child: const Text('이전'),
                ),
              const Spacer(),
              ElevatedButton(
                onPressed: _canProceed() ? _nextStep : null,
                child: Text(_currentStep == _questions.length - 1 ? '완료' : '다음'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteView(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Spacer(),
          Icon(
            Icons.stars,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            '분석 준비 완료!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '당신만의 재능 DNA를 분석해드릴게요',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => widget.onComplete(_answers),
              icon: const Icon(Icons.psychology),
              label: const Text(
                '재능 분석 시작',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFB300),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(String option, String key, bool isMultiple, ThemeData theme) {
    final isSelected = isMultiple
        ? (_answers[key] as List<String>?)?.contains(option) ?? false
        : _answers[key] == option;
    
    return InkWell(
      onTap: () {
        setState(() {
          if (isMultiple) {
            _answers[key] = (_answers[key] as List<String>?) ?? <String>[];
            if (isSelected) {
              (_answers[key] as List<String>).remove(option);
            } else {
              (_answers[key] as List<String>).add(option);
            }
          } else {
            _answers[key] = option;
          }
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected 
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              isMultiple 
                  ? (isSelected ? Icons.check_box : Icons.check_box_outline_blank)
                  : (isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked),
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected ? theme.colorScheme.primary : null,
                  fontWeight: isSelected ? FontWeight.w500 : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  bool _canProceed() {
    if (_currentStep >= _questions.length) return false;
    
    final question = _questions[_currentStep];
    final answer = _answers[question['key']];
    
    if (question['type'] == 'multiple_choice') {
      return answer != null && (answer as List).isNotEmpty;
    } else {
      return answer != null;
    }
  }
  
  void _nextStep() {
    if (_currentStep < _questions.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      setState(() {
        _currentStep++;
      });
    }
  }
}

class _TalentFortuneResult extends StatelessWidget {
  final Fortune fortune;
  final VoidCallback onShare;

  const _TalentFortuneResult({
    required this.fortune,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final talentData = fortune.luckyItems?['talent_dna'] as Map<String, int>? ?? {};
    final careers = fortune.luckyItems?['top_careers'] as List<String>? ?? [];
    final hobbies = fortune.luckyItems?['hobbies'] as List<String>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Today's Talent Focus
          _buildTodaysTalentFocus(theme),
          const SizedBox(height: 16),

          // Talent DNA Chart
          _buildTalentDnaSection(theme, talentData),
          const SizedBox(height: 16),

          // Main Fortune Content
          GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(16),
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
                      '재능 DNA 분석',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  fortune.content,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Career & Hobby Matching
          if (careers.isNotEmpty || hobbies.isNotEmpty)
            _buildCareerHobbyMatching(theme, careers, hobbies),
          const SizedBox(height: 16),

          // Score Breakdown
          if (fortune.scoreBreakdown != null && fortune.scoreBreakdown!.isNotEmpty) ...[
            GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '재능 지수 상세',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...fortune.scoreBreakdown!.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TalentProgressBar(
                      label: entry.key,
                      value: entry.value,
                      color: _getScoreColor(entry.value),
                    ),
                  )).toList(),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Recommendations
          if (fortune.recommendations != null && fortune.recommendations!.isNotEmpty) ...[
            GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '재능 개발 가이드',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...fortune.recommendations!.map((rec) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            rec,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTodaysTalentFocus(ThemeData theme) {
    final today = DateTime.now();
    final dayOfWeek = today.weekday;
    
    final Map<int, Map<String, dynamic>> dailyFocus = {
      1: {'name': '창의력', 'icon': Icons.palette, 'color': Colors.purple},
      2: {'name': '분석력', 'icon': Icons.analytics, 'color': Colors.blue},
      3: {'name': '소통능력', 'icon': Icons.chat, 'color': Colors.green},
      4: {'name': '리더십', 'icon': Icons.groups, 'color': Colors.orange},
      5: {'name': '집중력', 'icon': Icons.center_focus_strong, 'color': Colors.red},
      6: {'name': '직감력', 'icon': Icons.psychology, 'color': Colors.indigo},
      7: {'name': '회복력', 'icon': Icons.self_improvement, 'color': Colors.teal},
    };
    
    final focus = dailyFocus[dayOfWeek]!;
    final activationLevel = 75 + (today.day % 25);

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.wb_sunny,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '오늘의 재능 포커스',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: focus['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  focus['icon'],
                  color: focus['color'],
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      focus['name'],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: focus['color'],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '오늘 활성화 지수: $activationLevel%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
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
  }

  Widget _buildTalentDnaSection(ThemeData theme, Map<String, int> talentData) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.scatter_plot,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '재능 DNA 맵',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (talentData.isNotEmpty) ...[
            Center(
              child: TalentDnaChart(
                talents: talentData,
                size: 220,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '당신의 재능 DNA는 균형 잡힌 분포를 보이며, 다재다능한 성향을 가지고 있습니다.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCareerHobbyMatching(ThemeData theme, List<String> careers, List<String> hobbies) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.work,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '재능 매칭 분야',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (careers.isNotEmpty) ...[
            Text(
              '추천 직업군',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: careers.map((career) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  career,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
          ],
          
          if (hobbies.isNotEmpty) ...[
            Text(
              '추천 취미 활동',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: hobbies.map((hobby) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  hobby,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}