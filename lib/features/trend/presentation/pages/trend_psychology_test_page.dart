import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/loading_states.dart';
import '../../../../shared/components/toast.dart';
import '../../../../core/design_system/design_system.dart';
import '../../domain/models/models.dart';
import '../providers/trend_providers.dart';

/// 심리테스트 상세 Provider
final trendPsychologyTestProvider =
    FutureProvider.family<TrendPsychologyTest?, String>((ref, contentId) async {
  final repository = ref.watch(psychologyTestRepositoryProvider);
  return repository.getTestByContentId(contentId);
});

class TrendPsychologyTestPage extends ConsumerStatefulWidget {
  final String contentId;

  const TrendPsychologyTestPage({
    super.key,
    required this.contentId,
  });

  @override
  ConsumerState<TrendPsychologyTestPage> createState() =>
      _TrendPsychologyTestPageState();
}

class _TrendPsychologyTestPageState
    extends ConsumerState<TrendPsychologyTestPage> {
  int _currentQuestionIndex = 0;
  final Map<String, String> _answers = {}; // questionId -> optionId
  bool _isSubmitting = false;
  TrendPsychologyResult? _result;

  @override
  Widget build(BuildContext context) {
    final testAsync = ref.watch(trendPsychologyTestProvider(widget.contentId));

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: testAsync.when(
          loading: () => const Center(child: LoadingIndicator()),
          error: (e, _) => _buildErrorView(e.toString()),
          data: (test) {
            if (test == null) {
              return _buildErrorView('테스트를 찾을 수 없습니다');
            }
            return _buildContent(test);
          },
        ),
      ),
    );
  }

  Widget _buildContent(TrendPsychologyTest test) {
    if (_result != null) {
      return _buildResultView(test, _result!);
    }
    return Column(
      children: [
        const AppHeader(
          title: '심리테스트',
          showBackButton: true,
          showActions: false,
        ),
        // Progress indicator
        _buildProgressBar(test),
        // Question content
        Expanded(
          child: _buildQuestionView(test),
        ),
      ],
    );
  }

  Widget _buildProgressBar(TrendPsychologyTest test) {
    final progress = (test.questions.isEmpty)
        ? 0.0
        : (_currentQuestionIndex + 1) / test.questions.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '질문 ${_currentQuestionIndex + 1}/${test.questions.length}',
                style: context.labelMedium.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: context.labelMedium.copyWith(
                  color: DSColors.accentDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: context.colors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                DSColors.accentDark,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionView(TrendPsychologyTest test) {
    if (test.questions.isEmpty) {
      return Center(
        child: Text(
          '질문이 없습니다',
          style: context.bodyMedium.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      );
    }

    final question = test.questions[_currentQuestionIndex];
    final selectedOptionId = _answers[question.id];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Question text
          Text(
            question.questionText,
            style: context.heading3.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (question.imageUrl != null) ...[
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                question.imageUrl!,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
          const SizedBox(height: 32),
          // Options
          ...question.options.map((option) {
            final isSelected = selectedOptionId == option.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildOptionButton(option, isSelected, question.id),
            );
          }),
          const SizedBox(height: 24),
          // Navigation buttons
          Row(
            children: [
              if (_currentQuestionIndex > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        setState(() => _currentQuestionIndex--),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: context.colors.textDisabled,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '이전',
                      style: context.bodyMedium.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              if (_currentQuestionIndex > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: selectedOptionId != null
                      ? () => _handleNext(test)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DSColors.accentDark,
                    disabledBackgroundColor: context.colors.border,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _currentQuestionIndex == test.questions.length - 1
                              ? '결과 보기'
                              : '다음',
                          style: context.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(
    TrendPsychologyOption option,
    bool isSelected,
    String questionId,
  ) {
    return GestureDetector(
      onTap: () => _selectAnswer(questionId, option.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? DSColors.accentDark.withValues(alpha: 0.1)
              : context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? DSColors.accentDark
                : context.colors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (option.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  option.imageUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                option.label,
                style: context.bodyMedium.copyWith(
                  color: isSelected
                      ? DSColors.accentDark
                      : context.colors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? DSColors.accentDark
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? DSColors.accentDark
                      : context.colors.textDisabled,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _selectAnswer(String questionId, String optionId) {
    setState(() {
      _answers[questionId] = optionId;
    });
  }

  Future<void> _handleNext(TrendPsychologyTest test) async {
    if (_currentQuestionIndex < test.questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    } else {
      await _submitResult(test);
    }
  }

  Future<void> _submitResult(TrendPsychologyTest test) async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(psychologyTestRepositoryProvider);

      // Calculate result
      final result = repository.calculateResult(test, _answers);

      // Calculate score breakdown
      final scoreBreakdown = <String, int>{};
      for (final question in test.questions) {
        final selectedOptionId = _answers[question.id];
        if (selectedOptionId == null) continue;

        final selectedOption = question.options.firstWhere(
          (o) => o.id == selectedOptionId,
          orElse: () => question.options.first,
        );

        for (final entry in selectedOption.scoreMap.entries) {
          scoreBreakdown[entry.key] = (scoreBreakdown[entry.key] ?? 0) + entry.value;
        }
      }

      // Submit to database
      await repository.submitResult(
        testId: test.id,
        resultId: result.id,
        answers: _answers,
        scoreBreakdown: scoreBreakdown,
      );

      setState(() {
        _result = result;
        _isSubmitting = false;
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        Toast.show(context, message: '결과 저장 중 오류가 발생했습니다', type: ToastType.error);
      }
    }
  }

  Widget _buildResultView(
    TrendPsychologyTest test,
    TrendPsychologyResult result,
  ) {
    return Column(
      children: [
        AppHeader(
          title: '결과',
          showBackButton: true,
          showActions: false,
          onBackPressed: () => context.pop(),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Result image
                if (result.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      result.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              DSColors.accentDark,
                              DSColors.accentTertiary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text('🎉', style: TextStyle(fontSize: 64)),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                // Result title
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: DSColors.accentDark.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${test.resultType.emoji} ${test.resultType.displayName}',
                    style: context.labelMedium.copyWith(
                      color: DSColors.accentDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  result.title,
                  style: context.heading2.copyWith(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  result.description,
                  style: context.bodyMedium.copyWith(
                    color: context.colors.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (result.characteristics.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildCharacteristicsSection(result.characteristics),
                ],
                if (result.compatibleWith != null ||
                    result.incompatibleWith != null) ...[
                  const SizedBox(height: 24),
                  _buildCompatibilitySection(result),
                ],
                const SizedBox(height: 32),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Share functionality
                        },
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('공유하기'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _reset(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DSColors.accentDark,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '다시 하기',
                          style: context.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCharacteristicsSection(List<String> characteristics) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '특징',
            style: context.labelLarge.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...characteristics.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '•',
                      style: TextStyle(
                        color: DSColors.accentDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        c,
                        style: context.bodyMedium.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCompatibilitySection(TrendPsychologyResult result) {
    return Row(
      children: [
        if (result.compatibleWith != null)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DSColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    '💚',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '잘 맞는 유형',
                    style: context.labelSmall.copyWith(
                      color: DSColors.success,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.compatibleWith!,
                    style: context.bodySmall.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        if (result.compatibleWith != null && result.incompatibleWith != null)
          const SizedBox(width: 12),
        if (result.incompatibleWith != null)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DSColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    '💔',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '안 맞는 유형',
                    style: context.labelSmall.copyWith(
                      color: DSColors.error,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.incompatibleWith!,
                    style: context.bodySmall.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _reset() {
    setState(() {
      _currentQuestionIndex = 0;
      _answers.clear();
      _result = null;
    });
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: context.colors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            error,
            style: context.bodyMedium.copyWith(
              color: context.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('돌아가기'),
          ),
        ],
      ),
    );
  }
}
