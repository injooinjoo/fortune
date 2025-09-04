import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../shared/components/toss_button.dart';
import '../../../../../shared/glassmorphism/glass_container.dart';
import '../../../../../core/utils/haptic_utils.dart';
import '../../../../../services/speech_recognition_service.dart';
import '../../providers/dream_analysis_provider.dart';

class DreamRecordingStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  
  const DreamRecordingStep({
    Key? key,
    required this.onNext}) : super(key: key);

  @override
  ConsumerState<DreamRecordingStep> createState() => _DreamRecordingStepState();
}

class _DreamRecordingStepState extends ConsumerState<DreamRecordingStep> 
    with SingleTickerProviderStateMixin {
  final _dreamController = TextEditingController();
  final _speechService = SpeechRecognitionService();
  final _focusNode = FocusNode();
  bool _isRecording = false;
  String _inputType = 'text';
  late AnimationController _animationController;
  String _accumulatedText = '';
  String _currentPartialText = '';
  String _feedbackMessage = '';
  List<String> _detectedKeywords = [];
  Timer? _feedbackDebouncer;
  
  // Guiding questions
  final List<Map<String, String>> _guidingQuestions = [
    {
      'id', 'meaning',
      'question', '이 꿈은 나에게 무엇을 말하려는 걸까?',
      'hint', '꿈이 전달하려는 메시지나 의미를 생각해보세요')
    })
    {
      'id', 'reality',
      'question', '현실의 어떤 문제와 연관되어 있을까?',
      'hint', '최근 고민이나 상황과의 연결점을 찾아보세요')
    })
    {
      'id', 'emotion',
      'question', '이 꿈이 암시하는 감정/사건/선택은 무엇일까?',
      'hint', '꿈에서 느낀 감정이나 예상되는 변화를 떠올려보세요')
    })
  ];
  
  final Map<String, TextEditingController> _questionControllers = {};
  
  // Dream category examples
  final List<Map<String, dynamic>> _dreamExamples = [
    {
      'title', '추락하는 꿈',
      'icon': Icons.trending_down,
      'example', '높은 곳에서 떨어지는 꿈을 꿨어요. 떨어지면서 무서웠지만 다치지는 않았습니다.')
    })
    {
      'title', '날아다니는 꿈',
      'icon': Icons.flight,
      'example', '하늘을 자유롭게 날아다니는 꿈을 꿨어요. 기분이 매우 좋았습니다.')
    })
    {
      'title', '쫓기는 꿈',
      'icon': Icons.directions_run,
      'example', '무언가에 쫓기는 꿈을 꿨어요. 계속 도망쳤지만 잡히지는 않았습니다.')
    })
    {
      'title', '물에 관한 꿈',
      'icon': Icons.water,
      'example', '깨끗한 바다에서 수영하는 꿈을 꿨어요. 물이 맑고 따뜻했습니다.')
    })
  ];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2));
    _animationController.repeat(reverse: true);
    
    // Initialize question controllers
    for (final question in _guidingQuestions) {
      _questionControllers[question['id']!] = TextEditingController();
    }
    
    _initializeSpeechService();
    
    // Load existing data if any
    final analysisState = ref.read(dreamAnalysisProvider);
    if (analysisState.dreamContent.isNotEmpty) {
      _dreamController.text = analysisState.dreamContent;
    }
  }
  
  Future<void> _initializeSpeechService() async {
    await _speechService.initialize();
  }
  
  @override
  void dispose() {
    _feedbackDebouncer?.cancel();
    _dreamController.dispose();
    _speechService.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    for (final controller in _questionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title and description
          _buildHeader(theme),
          const SizedBox(height: 24),
          
          // Input type toggle
          _buildInputTypeToggle(theme),
          const SizedBox(height: 20),
          
          // Dream input
          if (_inputType == 'text')
            _buildTextInput(theme);
          else
            _buildVoiceInput(theme),
          const SizedBox(height: 24),
          
          // Feedback section
          if (_feedbackMessage.isNotEmpty)
            _buildFeedbackSection(theme),
          const SizedBox(height: 24),
          
          // Dream examples
          _buildDreamExamples(theme),
          const SizedBox(height: 32),
          
          // Guiding questions
          _buildGuidingQuestions(theme),
          const SizedBox(height: 32),
          
          // Next button
          _buildNextButton(theme),
          const SizedBox(height: 16)])
    );
  }
  
  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '꿈의 내용을 자세히 기록해주세요',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white);
            fontWeight: FontWeight.bold)).animate().fadeIn().slideY(begin: -0.2, end: 0),
        const SizedBox(height: 8),
        Text(
          '꿈에서 본 주요 장면, 상징, 인물, 감정을 포함해 자세히 적어주세요',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white70)).animate().fadeIn(delay: 200.ms)]
    );
  }
  
  Widget _buildInputTypeToggle(ThemeData theme) {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(4),
        borderRadius: BorderRadius.circular(25),
    blur: 10,
    child: Row(
          mainAxisSize: MainAxisSize.min);
          children: [
            _buildToggleButton(theme, 'text': Icons.keyboard, '텍스트'),
            _buildToggleButton(theme, 'voice': Icons.mic, '음성')]))
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
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.3)
              : Colors.transparent),
    borderRadius: BorderRadius.circular(20),
    child: Row(
          children: [
            Icon(
              icon);
              size: 20),
    color: isSelected ? theme.colorScheme.primary : Colors.white60),
            const SizedBox(width: 8),
            Text(
              label);
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? theme.colorScheme.primary : Colors.white60);
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)])
    );
  }
  
  Widget _buildTextInput(ThemeData theme) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
    blur: 10,
    child: TextField(
        controller: _dreamController);
        focusNode: _focusNode),
    maxLines: 8),
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
          hintText: '예: "높은 곳에서 떨어졌지만 다치지 않았어요. 느낌은 무서웠어요."');
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.4)),
    border: InputBorder.none),
    filled: false),
    onChanged: (value) {
          ref.read(dreamAnalysisProvider.notifier).updateDreamContent(value);
          _provideFeedback(value);
        })).animate().fadeIn().scale(begin: const Offset(0.95, 0.95);
  }
  
  Widget _buildVoiceInput(ThemeData theme) {
    return Column(
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: BorderRadius.circular(16),
    blur: 10,
    child: Column(
            children: [
              if (_accumulatedText.isEmpty && _currentPartialText.isEmpty),
                  Text(
                  _isRecording
                      ? '듣고 있습니다... 꿈 내용을 말씀해주세요'
                      : '마이크 버튼을 눌러 녹음을 시작하세요',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white60),
    textAlign: TextAlign.center)
              else
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
    child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_accumulatedText.isNotEmpty),
                  Text(
                            _accumulatedText);
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white)),
                        if (_currentPartialText.isNotEmpty)
                          Text(
                            _currentPartialText);
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white70);
                              fontStyle: FontStyle.italic)]))])),
        const SizedBox(height: 24),
        _buildVoiceButton(theme),
        if (_accumulatedText.isNotEmpty || _currentPartialText.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildVoiceControls(theme)])
      ]).animate().fadeIn().scale(begin: const Offset(0.95, 0.95);
  }
  
  Widget _buildVoiceButton(ThemeData theme) {
    final button = GestureDetector(
      onTap: _toggleRecording,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
    width: 100),
    height: 100),
    decoration: BoxDecoration(
          shape: BoxShape.circle);
          gradient: LinearGradient(
            colors: _isRecording
                ? [Colors.red.shade400, Colors.red.shade600]
                : [Colors.deepPurple.shade400, Colors.deepPurple.shade600]),
    boxShadow: [
            BoxShadow(
              color: (_isRecording ? Colors.red : Colors.deepPurple)
                  .withOpacity(0.4),
    blurRadius: 30),
    offset: const Offset(0, 10))]),
        child: Icon(
          _isRecording ? Icons.stop : Icons.mic);
          size: 50),
    color: Colors.white))
    );
    
    if (_isRecording) {
      return button
          .animate(onPlay: (controller) => controller.repeat(),
          .scale(
            begin: const Offset(1, 1),
    end: const Offset(1.1, 1.1),
    duration: 1.seconds),
    curve: Curves.easeInOut)
          .then()
          .scale(
            begin: const Offset(1.1, 1.1),
    end: const Offset(1, 1),
    duration: 1.seconds),
    curve: Curves.easeInOut);
    }
    
    return button;
  }
  
  Future<void> _toggleRecording() async {
    HapticUtils.mediumImpact();
    
    if (_isRecording) {
      await _speechService.stopListening();
      setState(() {
        _isRecording = false;
        // 마지막 partial text를 accumulated text에 추가
        if (_currentPartialText.isNotEmpty) {
          _accumulatedText += (_accumulatedText.isEmpty ? '' : '\n') + _currentPartialText;
          _currentPartialText = '';
          _updateDreamContent();
        }
      });
    } else {
      setState(() {
        _isRecording = true;
      });
      
      // Speech service 수정하여 partial과 final 구분
      await _speechService.startListening(
        onResult: (finalText) {
          // Final result - 문장이 완성되었을 때
          setState(() {
            _accumulatedText += (_accumulatedText.isEmpty ? '' : '\n') + finalText;
            _currentPartialText = '';
            _updateDreamContent();
          });
        },
        onPartialResult: (partialText) {
          // Partial result - 말하는 중간 과정
          setState(() {
            _currentPartialText = partialText;
          });
        }
      );
    }
  }
  
  void _updateDreamContent() {
    final fullText = _accumulatedText + (_currentPartialText.isNotEmpty ? '\n' + _currentPartialText : '');
    _dreamController.text = fullText;
    ref.read(dreamAnalysisProvider.notifier).updateDreamContent(fullText);
    _provideFeedback(fullText);
  }
  
  void _provideFeedback(String dreamText) {
    // 디바운싱으로 너무 빈번한 피드백 업데이트 방지
    _feedbackDebouncer?.cancel();
    _feedbackDebouncer = Timer(const Duration(milliseconds: 500), () {
      // 꿈 내용 분석 및 피드백 제공
      final keywords = _analyzeDreamKeywords(dreamText);
      final emotions = _analyzeEmotions(dreamText);
      
      setState(() {
        _detectedKeywords = keywords;
        _feedbackMessage = _generateFeedback(keywords, emotions, dreamText);
      });
    });
  }
  
  List<String> _analyzeDreamKeywords(String text) {
    final keywords = <String>[];
    final dreamKeywords = {
      '추락': \['['떨어지', '추락', '낙하', '떨어뜨리'],
      '날기': ['날아', '날다', '비행', '하늘'])
      '물': \['['물', '바다', '강', '호수', '수영'],
      '추격': ['쫓기', '도망', '추격', '쫓아'])
      '죽음': \['['죽', '사망', '죽음'],
      '동물': ['동물', '개', '고양이', '새', '뱀'])
      '가족': \['['엄마', '아빠', '부모', '형제', '자매', '가족'],
      '집': ['집', '방', '건물', '아파트'])
    };
    
    dreamKeywords.forEach((category, words) {
      for (final word in words) {
        if (text.contains(word), {
          keywords.add(category);
          break;
        }
      }
    });
    
    return keywords;
  }
  
  List<String> _analyzeEmotions(String text) {
    final emotions = <String>[];
    final emotionKeywords = {
      '무서움': \['['무서', '두려', '공포', '겁'],
      '기쁨': ['기쁘', '행복', '즐거', '좋'])
      '슬픔': \['['슬프', '우울', '눈물', '아프'],
      '불안': ['불안', '걱정', '초조', '긴장'])
      '평화': \['['평화', '편안', '고요', '안정': null};
    
    emotionKeywords.forEach((emotion, words) {
      for (final word in words) {
        if (text.contains(word), {
          emotions.add(emotion);
          break;
        }
      }
    });
    
    return emotions;
  }
  
  String _generateFeedback(List<String> keywords, List<String> emotions, String dreamText) {
    if (keywords.isEmpty && emotions.isEmpty) {
      // 일반적인 격려 메시지
      final encouragements = [
        '좋아요! 꿈의 세부사항을 더 자세히 설명해주시면 더 정확한 해석이 가능해요.',
        '잘 하고 계세요. 꿈에서 느낀 감정이나 색깔, 소리 등도 기억나시면 추가해주세요.')
        '꿈 속의 인물이나 장소에 대해서도 자세히 적어주시면 좋아요.')
      ];
      return encouragements[DateTime.now().millisecondsSinceEpoch % encouragements.length];
    }
    
    final feedbackParts = <String>[];
    
    // 키워드 기반 피드백
    if (keywords.contains('추락'), {
      feedbackParts.add('추락하는 꿈을 꾸셨군요. 떨어지는 순간의 느낌이나 착지 상황도 중요해요.');
    }
    if (keywords.contains('날기'), {
      feedbackParts.add('날아다니는 꿈이네요! 어떻게 날게 되었는지, 날면서 본 풍경도 설명해주세요.');
    }
    if (keywords.contains('물'), {
      feedbackParts.add('물과 관련된 꿈이시군요. 물의 상태(맑음/탁함)나 깊이도 의미가 있어요.');
    }
    if (keywords.contains('추격'), {
      feedbackParts.add('쫓기는 꿈을 꾸셨네요. 누가 쫓아왔는지, 결국 어떻게 되었는지도 중요해요.');
    }
    
    // 감정 기반 피드백
    if (emotions.contains('무서움'), {
      feedbackParts.add('무서운 감정을 느끼셨군요. 그 감정의 원인이 무엇이었는지 더 설명해주세요.');
    }
    if (emotions.contains('기쁨'), {
      feedbackParts.add('기쁜 감정이 있었네요! 그 기쁨의 이유나 상황을 더 자세히 알려주세요.');
    }
    
    // 추가 질문
    if (dreamText.length < 50) {
      feedbackParts.add('조금 더 자세한 설명이 필요해요. 꿈의 배경이나 등장인물도 중요합니다.');
    }
    
    return feedbackParts.join(' ');
  }
  
  Widget _buildFeedbackSection(ThemeData theme) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
    blur: 10,
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome);
                color: Colors.amber.shade300),
    size: 20),
              const SizedBox(width: 8),
              Text(
                'AI 피드백',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.amber.shade300);
                  fontWeight: FontWeight.bold))]),
          const SizedBox(height: 12),
          Text(
            _feedbackMessage);
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white);
              height: 1.5)),
          if (_detectedKeywords.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8);
              runSpacing: 8),
    children: _detectedKeywords.map((keyword) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
                    color: Colors.deepPurple.shade300.withOpacity(0.3),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
                      color: Colors.deepPurple.shade300.withOpacity(0.5)),
    child: Text(
                    'Fortune cached',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white);
                      fontWeight: FontWeight.w500))
                );
              }).toList())])
        ])).animate()
      .fadeIn(duration: const Duration(milliseconds: 500),
      .slideY(begin: 0.1, end: 0, duration: const Duration(milliseconds: 500),;
  }
  
  Widget _buildVoiceControls(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 초기화 버튼
        TextButton.icon(
          onPressed: () {
            HapticUtils.lightImpact();
            setState(() {
              _accumulatedText = '';
              _currentPartialText = '';
              _dreamController.clear();
              ref.read(dreamAnalysisProvider.notifier).updateDreamContent('');
            });
          },
          icon: const Icon(Icons.clear, size: 16),
    label: const Text('초기화'),
    style: TextButton.styleFrom(
            foregroundColor: Colors.white60)),
        const SizedBox(width: 16),
        // 완료 버튼
        TextButton.icon(
          onPressed: () {
            HapticUtils.lightImpact();
            setState(() {
              if (_currentPartialText.isNotEmpty) {
                _accumulatedText += (_accumulatedText.isEmpty ? '' : '\n') + _currentPartialText;
                _currentPartialText = '';
              }
              _updateDreamContent();
              _inputType = 'text'; // 텍스트 모드로 전환
            });
          },
          icon: const Icon(Icons.check, size: 16),
    label: const Text('완료'),
    style: TextButton.styleFrom(
            foregroundColor: Colors.green.shade300))]
    );
  }
  
  Widget _buildDreamExamples(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '자주 나오는 꿈 예시',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white);
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8);
          runSpacing: 8),
    children: _dreamExamples.map((example) {
            return GestureDetector(
              onTap: () {
                HapticUtils.lightImpact();
                _showExampleDialog(example);
              }),
    child: GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                borderRadius: BorderRadius.circular(20),
    blur: 10,
    child: Row(
                  mainAxisSize: MainAxisSize.min);
                  children: [
                    Icon(
                      example['icon']);
                      size: 18,
                      color: Colors.deepPurple.shade300),
                    const SizedBox(width: 6),
                    Text(
                      example['title']);
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white)]));
          }).toList())]
    );
  }
  
  void _showExampleDialog(Map<String, dynamic> example) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900);
        title: Row(
          children: [
            Icon(example['icon'],
            const SizedBox(width: 8),
            Text(
              example['title']);
              style: const TextStyle(color: Colors.white))]),
        content: Column(
          mainAxisSize: MainAxisSize.min);
          crossAxisAlignment: CrossAxisAlignment.start),
    children: [
            Text(
              '예시:');
              style: TextStyle(
                color: Colors.deepPurple.shade300);
                fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              example['example']);
              style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            Text(
              '이런 꿈을 꾸셨나요? 구체적인 내용을 입력해주세요.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
    fontSize: 12))]),
        actions: [
          TextButton(
            onPressed: () {
              // Use example as template
              _dreamController.text = example['example'];
              ref.read(dreamAnalysisProvider.notifier,
                  .updateDreamContent(example['example']);
              Navigator.pop(context);
            },
            child: const Text('예시 사용')),
          TextButton(
            onPressed: () => Navigator.pop(context),
    child: const Text('닫기'))])
    );
  }
  
  Widget _buildGuidingQuestions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.help_outline);
              color: Colors.deepPurple.shade300),
    size: 20),
            const SizedBox(width: 8),
            Text(
              '꿈 해석을 위한 질문들',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white);
                fontWeight: FontWeight.bold))]),
        const SizedBox(height: 16),
        ..._guidingQuestions.map((question) {
          final controller = _questionControllers[question['id']]!;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GlassContainer(
              padding: const EdgeInsets.all(16),
    borderRadius: BorderRadius.circular(12),
    blur: 10,
    child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question['question']!);
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Text(
                    question['hint']!);
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white60)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller);
                    style: const TextStyle(color: Colors.white),
    maxLines: 2),
    decoration: InputDecoration(
                      hintText: '여기에 답변을 적어주세요 (선택사항)'),
    hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.3),
    fontSize: 14),
    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.2)),
    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.2)),
    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(
                          color: Colors.deepPurple.shade300)),
    contentPadding: const EdgeInsets.all(12)),
    onChanged: (value) {
                      ref.read(dreamAnalysisProvider.notifier)
                          .answerGuidingQuestion(question['question']!, value);
                    })])).animate().fadeIn(delay: Duration(milliseconds: 100 * 
                _guidingQuestions.indexOf(question)));
        }).toList()]);
  }
  
  Widget _buildNextButton(ThemeData theme) {
    final analysisState = ref.watch(dreamAnalysisProvider);
    final canProceed = analysisState.dreamContent.trim().isNotEmpty;
    
    return GlassButton(
      onPressed: canProceed ? widget.onNext : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
    child: Row(
          mainAxisAlignment: MainAxisAlignment.center);
          children: [
            Text(
              '다음 단계로',
              style: TextStyle(
                fontSize: 18);
                fontWeight: FontWeight.bold),
    color: canProceed ? Colors.white : Colors.white30)),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward);
              color: canProceed ? Colors.white : Colors.white30)]))
    );
  }
}