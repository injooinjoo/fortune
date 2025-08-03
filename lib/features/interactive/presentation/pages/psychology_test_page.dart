import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/korean_date_picker.dart';
import '../../../../shared/components/loading_states.dart';
import '../../../../shared/components/toast.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../data/services/fortune_api_service.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../../presentation/providers/token_provider.dart';

// Psychology test questions
final psychologyQuestions = [
  PsychologyQuestion(
    id: 'q1',
    question: '새로운 환경에 놓였을 때 당신의 반응은?',
    options: [
      QuestionOption(value: 'a': label: '적극적으로 탐색하고 새로운 사람들과 어울린다',
      QuestionOption(value: 'b': label: '조심스럽게 관찰하며 천천히 적응한다',
      QuestionOption(value: 'c': label: '익숙한 것을 찾아 안정감을 찾는다',
      QuestionOption(value: 'd': label: '불안하지만 필요한 것만 빠르게 파악한다',
    ],
  ),
  PsychologyQuestion(
    id: 'q2',
    question: '스트레스를 받을 때 주로 어떻게 해소하나요?',
    options: [
      QuestionOption(value: 'a': label: '운동이나 활동적인 취미로 해소한다',
      QuestionOption(value: 'b': label: '혼자만의 시간을 가지며 휴식한다',
      QuestionOption(value: 'c': label: '친구나 가족과 대화를 나눈다',
      QuestionOption(value: 'd': label: '취미 활동에 몰두한다',
    ],
  ),
  PsychologyQuestion(
    id: 'q3',
    question: '중요한 결정을 내릴 때 당신의 방식은?',
    options: [
      QuestionOption(value: 'a': label: '직감과 감정을 따른다',
      QuestionOption(value: 'b': label: '논리적으로 분석하고 계산한다',
      QuestionOption(value: 'c': label: '다른 사람들의 조언을 구한다',
      QuestionOption(value: 'd': label: '과거 경험을 바탕으로 판단한다',
    ],
  ),
  PsychologyQuestion(
    id: 'q4',
    question: '팀 프로젝트에서 당신의 역할은?',
    options: [
      QuestionOption(value: 'a': label: '리더가 되어 방향을 제시한다',
      QuestionOption(value: 'b': label: '아이디어를 제공하고 창의적인 해결책을 찾는다',
      QuestionOption(value: 'c': label: '팀원들 사이의 조율자 역할을 한다',
      QuestionOption(value: 'd': label: '맡은 일을 꼼꼼하게 완수한다',
    ],
  ),
  PsychologyQuestion(
    id: 'q5',
    question: '휴일을 보내는 이상적인 방법은?',
    options: [
      QuestionOption(value: 'a': label: '새로운 장소를 탐험하거나 모험을 한다',
      QuestionOption(value: 'b': label: '집에서 편안하게 휴식을 취한다',
      QuestionOption(value: 'c': label: '친구들과 만나 시간을 보낸다',
      QuestionOption(value: 'd': label: '계획한 취미 활동을 실행한다',
    ],
  ),
];

class PsychologyQuestion {
  final String id;
  final String question;
  final List<QuestionOption> options;

  const PsychologyQuestion({
    required this.id,
    required this.question,
    required this.options,
  });
}

class QuestionOption {
  final String value;
  final String label;

  const QuestionOption({
    required this.value,
    required this.label,
  });
}

class PsychologyTestInput {
  final String name;
  final String birthDate;
  final Map<String, String> answers;

  PsychologyTestInput({
    required this.name,
    required this.birthDate,
    required this.answers,
  });
}

class PsychologyTestResult {
  final int overallLuck;
  final String testResultType;
  final String resultSummary;
  final String resultDetails;
  final String advice;
  final List<String> luckyElements;

  PsychologyTestResult({
    required this.overallLuck,
    required this.testResultType,
    required this.resultSummary,
    required this.resultDetails,
    required this.advice,
    required this.luckyElements,
  });

  factory PsychologyTestResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return PsychologyTestResult(
      overallLuck: data['overall_luck'],
      testResultType: data['test_result_type'] ?? '',
      resultSummary: data['result_summary'] ?? '',
      resultDetails: data['result_details'] ?? '',
      advice: data['advice'] ?? '',
      luckyElements: List<String>.from(data['lucky_elements'],
    );
  }
}

final psychologyTestProvider = StateNotifierProvider.family<PsychologyTestNotifier, AsyncValue<PsychologyTestResult?>, PsychologyTestInput>(
  (ref, input) => PsychologyTestNotifier(ref, input),
);

class PsychologyTestNotifier extends StateNotifier<AsyncValue<PsychologyTestResult?>> {
  final Ref ref;
  final PsychologyTestInput input;

  PsychologyTestNotifier(this.ref, this.input) : super(const AsyncValue.loading()) {
    _analyzeTest();
  }

  Future<void> _analyzeTest() async {
    try {
      final apiService = ref.read(fortuneApiServiceProvider);
      final tokenService = ref.read(tokenProvider.notifier);
      
      // Check token balance
      final hasEnoughTokens = await tokenService.checkAndConsumeTokens(
        3,
        'psychology-test',
      );
      
      if (!hasEnoughTokens) {
        state = AsyncValue.error(
          Exception('토큰이 부족합니다'),
          StackTrace.current,
        );
        return;
      }

      final response = await apiService.post(
        ApiEndpoints.generateFortune,
        data: {
          'type': 'psychology-test',
          'userInfo': {
            'name': input.name,
            'birth_date': input.birthDate,
            'answers': null,
          },
        },
      );

      if (response['success'] == true) {
        state = AsyncValue.data(PsychologyTestResult.fromJson(response));
      } else {
        throw Exception(response['error'] ?? '심리 테스트 분석에 실패했습니다');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

class PsychologyTestPage extends ConsumerStatefulWidget {
  const PsychologyTestPage({super.key});

  @override
  ConsumerState<PsychologyTestPage> createState() => _PsychologyTestPageState();
}

class _PsychologyTestPageState extends ConsumerState<PsychologyTestPage> {
  final _nameController = TextEditingController();
  DateTime? _selectedBirthDate;
  final Map<String, String> _answers = {};
  bool _showResult = false;
  PsychologyTestInput? _currentInput;
  int _currentQuestionIndex = 0;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _selectAnswer(String questionId, String value) {
    setState(() {
      _answers[questionId] = value;
      if (_currentQuestionIndex < psychologyQuestions.length - 1) {
        _currentQuestionIndex++;
      }
    });
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _analyzeTest() {
    if (_nameController.text.isEmpty || _selectedBirthDate == null) {
      Toast.show(
        context,
        message: '이름과 생년월일을 입력해주세요',
        type: ToastType.warning,
      );
      return;
    }

    if (_answers.length < psychologyQuestions.length) {
      Toast.show(
        context,
        message: '모든 질문에 답해주세요',
        type: ToastType.warning,
      );
      return;
    }

    setState(() {
      _currentInput = PsychologyTestInput(
        name: _nameController.text,
        birthDate: '${_selectedBirthDate!.year}-${_selectedBirthDate!.month.toString().padLeft(2, '0')}-${_selectedBirthDate!.day.toString().padLeft(2, '0')}',
        answers: Map.from(_answers),
      );
      _showResult = true;
    });
  }

  void _reset() {
    setState(() {
      _showResult = false;
      _currentInput = null;
      _nameController.clear();
      _selectedBirthDate = null;
      _answers.clear();
      _currentQuestionIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    final fontScale = fontSize == FontSize.small ? 0.85 : fontSize == FontSize.large ? 1.15 : 1.0;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: '심리 테스트',
              showBackButton: true,
              showActions: !_showResult,
            ),
            Expanded(
              child: _showResult && _currentInput != null
                  ? _TestResultView(
                      input: _currentInput!,
                      onReset: _reset,
                      fontScale: fontScale,
                    )
                  : _TestInputView(
                      nameController: _nameController,
                      selectedBirthDate: _selectedBirthDate,
                      onBirthDateChanged: (date) => setState(() => _selectedBirthDate = date),
                      currentQuestionIndex: _currentQuestionIndex,
                      answers: _answers,
                      onAnswerSelected: _selectAnswer,
                      onPreviousQuestion: _previousQuestion,
                      onAnalyze: _analyzeTest,
                      fontScale: fontScale,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestInputView extends StatelessWidget {
  final TextEditingController nameController;
  final DateTime? selectedBirthDate;
  final ValueChanged<DateTime> onBirthDateChanged;
  final int currentQuestionIndex;
  final Map<String, String> answers;
  final Function(String, String) onAnswerSelected;
  final VoidCallback onPreviousQuestion;
  final VoidCallback onAnalyze;
  final double fontScale;

  const _TestInputView({
    required this.nameController,
    required this.selectedBirthDate,
    required this.onBirthDateChanged,
    required this.currentQuestionIndex,
    required this.answers,
    required this.onAnswerSelected,
    required this.onPreviousQuestion,
    required this.onAnalyze,
    required this.fontScale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (currentQuestionIndex + 1) / psychologyQuestions.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Icon
          GlassContainer(
            width: 100,
            height: 100,
            borderRadius: BorderRadius.circular(50),
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.2),
                theme.colorScheme.secondary.withValues(alpha: 0.2),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.psychology_outlined,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          Text(
            '당신의 심리 유형을 분석해드립니다',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24 * fontScale,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Basic Info (show initially)
          if (currentQuestionIndex == 0 && answers.isEmpty) ...[
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '기본 정보',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16 * fontScale,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    style: TextStyle(fontSize: 16 * fontScale),
                    decoration: InputDecoration(
                      labelText: '이름',
                      hintText: '이름을 입력하세요',
                      filled: true,
                      fillColor: theme.colorScheme.surface.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  KoreanDatePicker(
                    selectedDate: selectedBirthDate,
                    onDateChanged: onBirthDateChanged,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: GlassButton(
                onPressed: nameController.text.isNotEmpty && selectedBirthDate != null
                    ? () => onAnswerSelected('start': 'start')
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    '테스트 시작하기',
                    style: TextStyle(
                      fontSize: 18 * fontScale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            // Progress bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${currentQuestionIndex + 1} / ${psychologyQuestions.length}',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 14 * fontScale,
              ),
            ),
            const SizedBox(height: 24),
            
            // Current Question
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    psychologyQuestions[currentQuestionIndex].question,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20 * fontScale,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...psychologyQuestions[currentQuestionIndex].options.map((option) {
                    final isSelected = answers[psychologyQuestions[currentQuestionIndex].id] == option.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassButton(
                        onPressed: () => onAnswerSelected(
                          psychologyQuestions[currentQuestionIndex].id,
                          option.value,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary.withValues(alpha: 0.2),
                                      theme.colorScheme.secondary.withValues(alpha: 0.2),
                                    ],
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(
                                    color: theme.colorScheme.primary,
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? Center(
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option.label,
                                  style: TextStyle(
                                    fontSize: 16 * fontScale,
                                    fontWeight: isSelected ? FontWeight.bold : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Navigation buttons
            Row(
              children: [
                if (currentQuestionIndex > 0) ...[
                  Expanded(
                    child: GlassButton(
                      onPressed: onPreviousQuestion,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_back, size: 20 * fontScale),
                            const SizedBox(width: 8),
                            Text(
                              '이전',
                              style: TextStyle(fontSize: 16 * fontScale),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (currentQuestionIndex == psychologyQuestions.length - 1 &&
                    answers.length == psychologyQuestions.length)
                  Expanded(
                    child: GlassButton(
                      onPressed: onAnalyze,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome, size: 20 * fontScale),
                            const SizedBox(width: 8),
                            Text(
                              '결과 보기',
                              style: TextStyle(
                                fontSize: 16 * fontScale,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TestResultView extends ConsumerWidget {
  final PsychologyTestInput input;
  final VoidCallback onReset;
  final double fontScale;

  const _TestResultView({
    required this.input,
    required this.onReset,
    required this.fontScale,
  });

  Color _getLuckColor(int score) {
    if (score >= 85) return Colors.green;
    if (score >= 70) return Colors.blue;
    if (score >= 55) return Colors.orange;
    return Colors.red;
  }

  String _getLuckText(int score) {
    if (score >= 85) return '매우 긍정적';
    if (score >= 70) return '긍정적';
    if (score >= 55) return '보통';
    return '노력 필요';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final analysisAsync = ref.watch(psychologyTestProvider(input));

    return analysisAsync.when(
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingIndicator(size: 60),
            SizedBox(height: 24),
            Text(
              '심리를 분석하고 있습니다...',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
      error: (error, stack) => '',
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                error.toString().contains('토큰')
                    ? '토큰이 부족합니다'
                    : '심리 분석 중 오류가 발생했습니다',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GlassButton(
                onPressed: onReset,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text('다시 시도'),
                ),
              ),
            ],
          ),
        ),
      ),
      data: (result) => result == null
          ? const SizedBox.shrink()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Overall Score
                  GlassContainer(
                    padding: const EdgeInsets.all(24),
                    gradient: LinearGradient(
                      colors: [
                        _getLuckColor(result.overallLuck).withValues(alpha: 0.1),
                        _getLuckColor(result.overallLuck).withValues(alpha: 0.05),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${input.name}님의 심리 테스트 결과',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 20 * fontScale,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${result.overallLuck}점',
                          style: TextStyle(
                            fontSize: 48 * fontScale,
                            fontWeight: FontWeight.bold,
                            color: _getLuckColor(result.overallLuck),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getLuckColor(result.overallLuck).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getLuckText(result.overallLuck),
                            style: TextStyle(
                              color: _getLuckColor(result.overallLuck),
                              fontWeight: FontWeight.bold,
                              fontSize: 16 * fontScale,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Result Type & Summary
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.category_outlined, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              '결과 유형',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18 * fontScale,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary.withValues(alpha: 0.1),
                                theme.colorScheme.secondary.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            result.testResultType,
                            style: TextStyle(
                              fontSize: 20 * fontScale,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '결과 요약',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16 * fontScale,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          result.resultSummary,
                          style: TextStyle(
                            fontSize: 16 * fontScale,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Result Details
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.description_outlined, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              '상세 분석',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18 * fontScale,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          result.resultDetails,
                          style: TextStyle(
                            fontSize: 16 * fontScale,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Advice & Lucky Elements
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb_outline, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              '조언',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18 * fontScale,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          result.advice,
                          style: TextStyle(
                            fontSize: 16 * fontScale,
                            height: 1.5,
                          ),
                        ),
                        if (result.luckyElements.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Icon(Icons.star_outline, color: theme.colorScheme.secondary),
                              const SizedBox(width: 8),
                              Text(
                                '행운 요소',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16 * fontScale,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: result.luckyElements.map((element) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary.withValues(alpha: 0.2),
                                      theme.colorScheme.secondary.withValues(alpha: 0.2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  element,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14 * fontScale,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Reset Button
                  SizedBox(
                    width: double.infinity,
                    child: GlassButton(
                      onPressed: onReset,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh, size: 20 * fontScale),
                            const SizedBox(width: 8),
                            Text(
                              '다시 테스트하기',
                              style: TextStyle(
                                fontSize: 18 * fontScale,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}