import 'package:flutter/material.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../shared/components/floating_bottom_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../widgets/dream_elements_chart.dart';
import '../widgets/dream_psychology_chart.dart';
import '../widgets/dream_timeline_widget.dart';
import '../widgets/fortune_display.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../services/dream_elements_analysis_service.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/toast.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../services/speech_recognition_service.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../shared/glassmorphism/glass_effects.dart';
import '../../../../core/theme/toss_design_system.dart';

class DreamFortunePage extends BaseFortunePage {
  const DreamFortunePage({Key? key})
      : super(
          key: key,
          title: '꿈 해몽',
          description: '어젯밤 꿈은 어떤 의미일까요? AI가 해석해드립니다',
          fortuneType: 'dream',
          requiresUserInfo: false);

  @override
  ConsumerState<DreamFortunePage> createState() => _DreamFortunePageState();
}

class _DreamFortunePageState extends BaseFortunePageState<DreamFortunePage> {
  final _dreamController = TextEditingController();
  final _speechService = SpeechRecognitionService();
  bool _isRecording = false;
  String _inputType = 'text'; // 'text' or 'voice'
  final _focusNode = FocusNode();
  
  // Dream analysis data
  Map<String, List<String>>? _dreamElements;
  Map<String, double>? _elementWeights;
  Map<String, double>? _psychologicalState;
  List<double>? _emotionalFlow;
  List<String>? _dreamScenes;
  Fortune? _fortune;

  // 자주 나오는 꿈 카테고리
  final List<Map<String, dynamic>> _dreamCategories = [
    {'title': '동물', 'icon': Icons.pets, 'keywords': '개, 고양이, 뱀, 새'},
    {'title': '사람', 'icon': Icons.people, 'keywords': '가족, 친구, 연인, 유명인'},
    {'title': '장소', 'icon': Icons.location_on, 'keywords': '집, 학교, 직장, 여행지'},
    {'title': '행동', 'icon': Icons.directions_run, 'keywords': '날다, 떨어지다, 쫓기다'},
    {'title': '사물', 'icon': Icons.category, 'keywords': '돈, 차, 음식, 선물'},
    {'title': '자연', 'icon': Icons.nature, 'keywords': '물, 불, 비, 산'}
  ];

  @override
  void initState() {
    super.initState();
    _initializeSpeechService();
  }

  Future<void> _initializeSpeechService() async {
    await _speechService.initialize();
  }

  @override
  void dispose() {
    _dreamController.dispose();
    _speechService.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    final dreamContent = params['dream'] ?? '';
    if (dreamContent.isEmpty) {
      throw Exception('꿈 내용을 입력해주세요');
    }

    // 꿈 요소 분석
    _dreamElements = DreamElementsAnalysisService.extractDreamElements(dreamContent);
    _elementWeights = DreamElementsAnalysisService.calculateElementWeights(_dreamElements!);
    _psychologicalState = DreamElementsAnalysisService.analyzePsychologicalState(_dreamElements!);
    _emotionalFlow = DreamElementsAnalysisService.analyzeEmotionalFlow(dreamContent);
    
    // 꿈 장면 추출 (간단한 문장 분리)
    _dreamScenes = dreamContent.split('.').where((s) => s.trim().isNotEmpty).toList();
    if (_dreamScenes!.isEmpty) {
      _dreamScenes = [dreamContent];
    }

    // Use the fortune provider to generate dream interpretation
    final fortune = await ref.read(fortuneServiceProvider).getFortune(
      userId: user.id,
      fortuneType: 'dream',
      params: params
    );

    _fortune = fortune;
    
    return fortune;
  }

  @override
  Future<Map<String, dynamic>?> getFortuneParams() async {
    if (_dreamController.text.trim().isEmpty) {
      Toast.show(context, message: '꿈 내용을 입력해주세요', type: ToastType.warning);
      return null;
    }

    return {
      'dream': _dreamController.text.trim(),
      'inputType': _inputType,
      'date': DateTime.now().toIso8601String()
    };
  }

  @override
  Widget buildInputForm() {
    final theme = Theme.of(context);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '꿈 내용 입력',
                style: theme.textTheme.headlineSmall),
              _buildInputTypeToggle(theme)
            ]
          ),
          const SizedBox(height: 16),
          if (_inputType == 'text')
            _buildTextInput(theme)
          else
            _buildVoiceInput(theme),
          const SizedBox(height: 16),
          _buildDreamCategories(theme),
          const SizedBox(height: 8),
          Text(
            '꿈의 세부 내용을 자세히 입력할수록 정확한 해몽이 가능합니다',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6)
            )
          )
        ]
      )
    );
  }

  Widget _buildInputTypeToggle(ThemeData theme) {
    return GlassContainer(
      padding: const EdgeInsets.all(4),
      borderRadius: BorderRadius.circular(25),
      blur: 10,
      child: Row(
        children: [
          _buildToggleButton(
            theme,
            'text',
            Icons.keyboard,
            '텍스트'),
          _buildToggleButton(
            theme,
            'voice',
            Icons.mic,
            '음성')
        ]
      )
    );
  }

  Widget _buildToggleButton(
    ThemeData theme,
    String type,
    IconData icon,
    String label) {
    final isSelected = _inputType == type;
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        setState(() {
          _inputType = type;
          if (type == 'text') {
            _focusNode.requestFocus();
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : TossDesignSystem.white.withValues(alpha: 0.0),
          borderRadius: BorderRadius.circular(20)
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6)
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
              )
            )
          ]
        )
      )
    );
  }

  Widget _buildTextInput(ThemeData theme) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      blur: 10,
      child: TextField(
        controller: _dreamController,
        focusNode: _focusNode,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: '어젯밤 꿈의 내용을 자세히 적어주세요...',
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5)
          ),
          border: InputBorder.none,
          filled: false
        ),
        style: theme.textTheme.bodyMedium
      )
    );
  }

  Widget _buildVoiceInput(ThemeData theme) {
    return Column(
      children: [
        ValueListenableBuilder<String>(
          valueListenable: _speechService.recognizedTextNotifier,
          builder: (context, recognizedText, _) {
            if (recognizedText.isNotEmpty) {
              _dreamController.text = recognizedText;
            }
            return GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(12),
              blur: 10,
              child: Column(
                children: [
                  if (recognizedText.isEmpty)
                    Text(
                      _isRecording
                          ? '듣고 있습니다... 꿈 내용을 말씀해주세요'
                          : '마이크 버튼을 눌러 녹음을 시작하세요',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    )
                  else
                    Text(
                      recognizedText,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            );
          }
        ),
        const SizedBox(height: 20),
        _buildVoiceButton(theme),
        const SizedBox(height: 8),
        ValueListenableBuilder<String>(
          valueListenable: _speechService.statusNotifier,
          builder: (context, status, _) {
            return Text(
              status,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6)
              )
            );
          }
        )
      ]
    );
  }

  Widget _buildVoiceButton(ThemeData theme) {
    return GestureDetector(
      onTap: _toggleRecording,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: _isRecording
                ? [TossDesignSystem.error, TossDesignSystem.error]
                : [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)]
          ),
          boxShadow: [
            BoxShadow(
              color: (_isRecording ? TossDesignSystem.error : theme.colorScheme.primary)
                  .withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10)
            )
          ]
        ),
        child: Icon(
          _isRecording ? Icons.stop : Icons.mic,
          size: 40,
          color: TossDesignSystem.white
        )
      )
    );
  }

  Future<void> _toggleRecording() async {
    HapticUtils.mediumImpact();
    
    if (_isRecording) {
      await _speechService.stopListening();
      setState(() {
        _isRecording = false;
      });
    } else {
      setState(() {
        _isRecording = true;
      });
      await _speechService.startListening(
        onResult: (text) {
          setState(() {
            _dreamController.text = text;
            _isRecording = false;
          });
        }
      );
    }
  }

  Widget _buildDreamCategories(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '자주 나오는 꿈 테마',
          style: theme.textTheme.titleMedium
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _dreamCategories.map((category) {
            return GestureDetector(
              onTap: () {
                HapticUtils.lightImpact();
                showDialog(
                  context: context,
                  builder: (context) => _buildCategoryDialog(category, theme)
                );
              },
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                borderRadius: BorderRadius.circular(20),
                blur: 10,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category['icon'],
                      size: 16,
                      color: theme.colorScheme.primary
                    ),
                    const SizedBox(width: 4),
                    Text(
                      category['title'],
                      style: theme.textTheme.bodySmall
                    )
                  ]
                )
              )
            );
          }).toList()
        )
      ]
    );
  }

  Widget _buildCategoryDialog(Map<String, dynamic> category, ThemeData theme) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(category['icon']),
          const SizedBox(width: 8),
          Text('${category['title']} 관련 꿈')
        ]
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '예시: ${category['keywords']}',
            style: theme.textTheme.bodyMedium
          ),
          const SizedBox(height: 16),
          Text(
            '이 카테고리의 꿈을 꾸셨나요?\n구체적인 내용을 입력해주세요.',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center
          )
        ]
      ),
      actions: [
        TossButton(
          text: '닫기',
          onPressed: () => Navigator.pop(context),
          style: TossButtonStyle.text,
          size: TossButtonSize.medium
        )
      ]
    );
  }

  @override
  Widget buildFortuneResult() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(

        children: [
          // Show the base fortune result
          FortuneDisplay(
            title: _fortune!.summary ?? '꿈 해몽',
            description: _fortune!.description ?? _fortune!.content,
            overallScore: _fortune!.score,
            luckyItems: _fortune!.luckyItems,
            advice: _fortune!.recommendations?.join('\n') ?? '',
            detailedFortune: {'content': _fortune!.content},
            warningMessage: _fortune!.warnings?.join('\n')
          ),
          const SizedBox(height: 24),
          // Dream specific analysis
          if (_dreamElements != null && _elementWeights != null) ...[
            _buildDreamAnalysisSection()
          ]
        ]
      )
    );
  }

  Widget _buildDreamAnalysisSection() {
    return Column(
      children: [
        // 꿈 요소 분석 차트
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: DreamElementsChart(
            elementWeights: _elementWeights!,
            elements: _dreamElements!,
            showAnimation: true
          )
        ),
        const SizedBox(height: 16),
        // 심리 상태 분석
        if (_psychologicalState != null) ...[
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: DreamPsychologyChart(
              psychologicalState: _psychologicalState!,
              showAnimation: true
            )
          ),
          const SizedBox(height: 16)
        ],
        
        // 감정 타임라인
        if (_emotionalFlow != null && _dreamScenes != null) ...[
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: DreamTimelineWidget(
              emotionalFlow: _emotionalFlow!,
              scenes: _dreamScenes!,
              showAnimation: true
            )
          ),
          const SizedBox(height: 16)
        ],
        
        // 종합 해석
        _buildComprehensiveInterpretation()
      ]
    );
  }

  Widget _buildComprehensiveInterpretation() {
    final theme = Theme.of(context);
    final interpretation = DreamElementsAnalysisService.generateDreamInterpretation(
      _dreamController.text,
      _dreamElements!
    );
    
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [TossDesignSystem.purple, TossDesignSystem.purple]
                  ),
                  borderRadius: BorderRadius.circular(12)
                ),
                child: const Icon(
                  Icons.auto_stories,
                  color: TossDesignSystem.white,
                  size: 24
                )
              ),
              const SizedBox(width: 12),
              Text(
                '종합 해석',
                style: theme.textTheme.headlineSmall
              )
            ]
          ),
          const SizedBox(height: 20),
          // 주요 테마
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TossDesignSystem.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: TossDesignSystem.purple.withValues(alpha: 0.3),
                width: 1
              )
            ),
            child: Row(
              children: [
                Icon(
                  Icons.category,
                  color: TossDesignSystem.purple,
                  size: 20
                ),
                const SizedBox(width: 8),
                Text(
                  interpretation['mainTheme'],
                  style: TextStyle(
                    color: TossDesignSystem.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  )
                )
              ]
            )
          ),
          const SizedBox(height: 16),
          // 심리학적 통찰
          Text(
            '심리학적 통찰',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: TossDesignSystem.white
            )
          ),
          const SizedBox(height: 8),
          Text(
            interpretation['psychologicalInsight'],
            style: TextStyle(
              fontSize: 14,
              color: TossDesignSystem.white.withValues(alpha: 0.9),
              height: 1.5
            )
          ),
          const SizedBox(height: 16),
          // 행운 요소
          if ((interpretation['luckyElements'] as List).isNotEmpty) ...[
            Text(
              '긍정적 상징',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: TossDesignSystem.white
              )
            ),
            const SizedBox(height: 8),
            ...(interpretation['luckyElements'] as List<String>).map((element) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(color: TossDesignSystem.success)
                    ),
                    Expanded(
                      child: Text(
                        element,
                        style: TextStyle(
                          fontSize: 14,
                          color: TossDesignSystem.white.withValues(alpha: 0.8)
                        )
                      )
                    )
                  ]
                )
              );
            }).toList()
          ]
        ]
      )
    );
  }
}