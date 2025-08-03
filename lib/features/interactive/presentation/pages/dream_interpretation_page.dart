import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/korean_date_picker.dart';
import '../../../../shared/components/loading_states.dart';
import '../../../../shared/components/toast.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../data/services/fortune_api_service.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../presentation/providers/providers.dart';
import '../../../../services/speech_recognition_service.dart';
import '../../../../core/utils/haptic_utils.dart';

final dreamAnalysisProvider = StateNotifierProvider.family<DreamAnalysisNotifier, AsyncValue<DreamAnalysisResult?>, DreamInput>(
  (ref, input) => DreamAnalysisNotifier(ref, input),
);

class DreamInput {
  final String name;
  final DateTime birthDate;
  final String dreamContent;

  DreamInput({
    required this.name,
    required this.birthDate,
    required this.dreamContent,
  });
}

class DreamAnalysisResult {
  final int overallLuck;
  final String dreamSummary;
  final String dreamInterpretation;
  final List<String> luckyElements;
  final String advice;

  DreamAnalysisResult({
    required this.overallLuck,
    required this.dreamSummary,
    required this.dreamInterpretation,
    required this.luckyElements,
    required this.advice,
  });

  factory DreamAnalysisResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return DreamAnalysisResult(
      overallLuck: data['overall_luck'],
      dreamSummary: data['dream_summary'] ?? '',
      dreamInterpretation: data['dream_interpretation'] ?? '',
      luckyElements: List<String>.from(data['lucky_elements'],
      advice: data['advice'] ?? '',
    );
  }
}

class DreamAnalysisNotifier extends StateNotifier<AsyncValue<DreamAnalysisResult?>> {
  final Ref ref;
  final DreamInput input;

  DreamAnalysisNotifier(this.ref, this.input) : super(const AsyncValue.loading()) {
    _analyzeDream();
  }

  Future<void> _analyzeDream() async {
    try {
      final apiService = ref.read(fortuneApiServiceProvider);
      final tokenService = ref.read(tokenProvider.notifier);
      
      // Check token balance
      final hasEnoughTokens = await tokenService.consumeTokens(
        fortuneType: 'dream',
        amount: 2,
      );
      
      if (!hasEnoughTokens) {
        state = AsyncValue.error(
          Exception('토큰이 부족합니다'),
          StackTrace.current,
        );
        return;
      }

      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post(
        ApiEndpoints.generate,
        data: {
          'type': 'dream-interpretation',
          'userInfo': {
            'name': input.name),
            'birth_date': input.birthDate.toIso8601String(),
            'dream_content': null,
          },
        },
      );

      if (response.data['success'] == true) {
        state = AsyncValue.data(DreamAnalysisResult.fromJson(response.data));
      } else {
        throw Exception(response.data['error'] ?? '꿈 해몽 분석에 실패했습니다');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

class DreamInterpretationPage extends ConsumerStatefulWidget {
  const DreamInterpretationPage({super.key});

  @override
  ConsumerState<DreamInterpretationPage> createState() => _DreamInterpretationPageState();
}

class _DreamInterpretationPageState extends ConsumerState<DreamInterpretationPage> {
  final _nameController = TextEditingController();
  final _dreamController = TextEditingController();
  DateTime? _selectedBirthDate;
  bool _showResult = false;
  DreamInput? _currentInput;

  @override
  void dispose() {
    _nameController.dispose();
    _dreamController.dispose();
    super.dispose();
  }

  void _analyzeDream() {
    if (_nameController.text.isEmpty || 
        _selectedBirthDate == null || 
        _dreamController.text.isEmpty) {
      Toast.show(
        context,
        message: '모든 정보를 입력해주세요',
        type: ToastType.warning,
      );
      return;
    }

    setState(() {
      _currentInput = DreamInput(
        name: _nameController.text,
        birthDate: _selectedBirthDate!,
        dreamContent: _dreamController.text,
      );
      _showResult = true;
    });
  }

  void _reset() {
    setState(() {
      _showResult = false;
      _currentInput = null;
      _nameController.clear();
      _dreamController.clear();
      _selectedBirthDate = null;
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
              title: '꿈 해몽',
              showBackButton: true,
              showTokenBalance: !_showResult,
            ),
            Expanded(
              child: _showResult && _currentInput != null
                  ? _DreamResultView(
                      input: _currentInput!,
                      onReset: _reset,
                      fontScale: fontScale,
                    )
                  : _DreamInputForm(
                      nameController: _nameController,
                      dreamController: _dreamController,
                      selectedBirthDate: _selectedBirthDate,
                      onBirthDateChanged: (date) => setState(() => _selectedBirthDate = date),
                      onAnalyze: _analyzeDream,
                      fontScale: fontScale,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DreamInputForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController dreamController;
  final DateTime? selectedBirthDate;
  final ValueChanged<DateTime> onBirthDateChanged;
  final VoidCallback onAnalyze;
  final double fontScale;

  const _DreamInputForm({
    required this.nameController,
    required this.dreamController,
    required this.selectedBirthDate,
    required this.onBirthDateChanged,
    required this.onAnalyze,
    required this.fontScale,
  });

  @override
  State<_DreamInputForm> createState() => _DreamInputFormState();
}

class _DreamInputFormState extends State<_DreamInputForm> {
  final _speechService = SpeechRecognitionService();
  bool _isRecording = false;
  String _inputType = 'text'; // 'text' or 'voice'

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
    _speechService.dispose();
    super.dispose();
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
            widget.dreamController.text = text;
            _isRecording = false;
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Icon
          GlassContainer(
            width: 100,
            height: 100,
            borderRadius: BorderRadius.circular(50),
            child: Center(
              child: Icon(
                Icons.bedtime_outlined,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          Text(
            '꿈의 의미를 해석해드립니다',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24 * widget.fontScale,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '꿈 내용을 자세히 입력해주세요',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 16 * widget.fontScale,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Name Input
          GlassContainer(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '이름',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16 * widget.fontScale,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: widget.nameController,
                  style: TextStyle(fontSize: 16 * widget.fontScale),
                  decoration: InputDecoration(
                    hintText: '이름을 입력하세요',
                    filled: true,
                    fillColor: theme.colorScheme.surface.withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Birth Date
          GlassContainer(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '생년월일',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16 * widget.fontScale,
                  ),
                ),
                const SizedBox(height: 12),
                KoreanDatePicker(
                  initialDate: widget.selectedBirthDate,
                  onDateSelected: widget.onBirthDateChanged,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Dream Content
          GlassContainer(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '꿈 내용',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16 * widget.fontScale,
                      ),
                    ),
                    // Input Type Toggle
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          _buildToggleButton('text': Icons.keyboard, '텍스트': null,
                          _buildToggleButton('voice': Icons.mic, '음성',
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_inputType == 'text')
                  TextField(
                    controller: widget.dreamController,
                    style: TextStyle(fontSize: 16 * widget.fontScale),
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: '예: 넓은 바다에서 헤엄치다가 황금 용을 만나는 꿈을 꾸었습니다.',
                      filled: true,
                      fillColor: theme.colorScheme.surface.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  )
                else
                  _buildVoiceInput(theme),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Analyze Button
          SizedBox(
            width: double.infinity,
            child: GlassButton(
              onPressed: widget.onAnalyze,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, size: 20 * widget.fontScale),
                    const SizedBox(width: 8),
                    Text(
                      '꿈 해몽 분석하기',
                      style: TextStyle(
                        fontSize: 18 * widget.fontScale,
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
    );
  }

  Widget _buildToggleButton(String type, IconData icon, String label) {
    final theme = Theme.of(context);
    final isSelected = _inputType == type;
    
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        setState(() {
          _inputType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceInput(ThemeData theme) {
    return Column(
      children: [
        ValueListenableBuilder<String>(
          valueListenable: _speechService.recognizedTextNotifier,
          builder: (context, recognizedText, _) {
            if (recognizedText.isNotEmpty) {
              widget.dreamController.text = recognizedText;
            }
            return Container(
              height: 120,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isRecording 
                      ? theme.colorScheme.primary 
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  recognizedText.isEmpty
                      ? (_isRecording
                          ? '듣고 있습니다... 꿈 내용을 말씀해주세요'
                          : '마이크 버튼을 눌러 녹음을 시작하세요')
                      : recognizedText,
                  style: TextStyle(
                    fontSize: 16 * widget.fontScale,
                    color: recognizedText.isEmpty
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                        : theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _toggleRecording,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: _isRecording
                    ? [Colors.red.shade400, Colors.red.shade600]
                    : [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: (_isRecording ? Colors.red : theme.colorScheme.primary)
                      .withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              _isRecording ? Icons.stop : Icons.mic,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<String>(
          valueListenable: _speechService.statusNotifier,
          builder: (context, status, _) {
            return Text(
              status,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _DreamResultView extends ConsumerWidget {
  final DreamInput input;
  final VoidCallback onReset;
  final double fontScale;

  const _DreamResultView({
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
    if (score >= 85) return '매우 길몽';
    if (score >= 70) return '길몽';
    if (score >= 55) return '평범한 꿈';
    return '흉몽';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final analysisAsync = ref.watch(dreamAnalysisProvider(input));

    return analysisAsync.when(
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingIndicator(size: 60),
            SizedBox(height: 24),
            Text(
              '꿈을 분석하고 있습니다...',
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
                    : '꿈 분석 중 오류가 발생했습니다',
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
                          '${input.name}님의 꿈 해몽',
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
                  
                  // Dream Summary & Interpretation
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.book_outlined, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              '꿈 요약 및 해석',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18 * fontScale,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Summary
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.summarize_outlined,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '꿈 요약',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                      fontSize: 14 * fontScale,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                result.dreamSummary,
                                style: TextStyle(
                                  fontSize: 16 * fontScale,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Interpretation
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.psychology_outlined,
                                    size: 16,
                                    color: theme.colorScheme.secondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '꿈 해석',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.secondary,
                                      fontSize: 14 * fontScale,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                result.dreamInterpretation,
                                style: TextStyle(
                                  fontSize: 16 * fontScale,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Lucky Elements
                  if (result.luckyElements.isNotEmpty) ...[
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star_outline, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                '행운 요소',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18 * fontScale,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
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
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Advice
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
                              '다른 꿈 분석하기',
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