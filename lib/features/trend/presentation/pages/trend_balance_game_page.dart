import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/loading_states.dart';
import '../../../../shared/components/toast.dart';
import 'package:fortune/core/design_system/design_system.dart';
import '../../domain/models/models.dart';
import '../providers/trend_providers.dart';

/// 밸런스 게임 상세 Provider
final trendBalanceGameProvider =
    FutureProvider.family<BalanceGameSet?, String>((ref, contentId) async {
  final repository = ref.watch(balanceGameRepositoryProvider);
  return repository.getGameSetByContentId(contentId);
});

class TrendBalanceGamePage extends ConsumerStatefulWidget {
  final String contentId;

  const TrendBalanceGamePage({
    super.key,
    required this.contentId,
  });

  @override
  ConsumerState<TrendBalanceGamePage> createState() =>
      _TrendBalanceGamePageState();
}

class _TrendBalanceGamePageState extends ConsumerState<TrendBalanceGamePage> {
  int _currentQuestionIndex = 0;
  final Map<String, String> _answers = {}; // questionId -> 'A' or 'B'
  bool _showResult = false;
  bool _isSubmitting = false;
  BalanceGameSummary? _summary;

  @override
  Widget build(BuildContext context) {
    final gameAsync = ref.watch(trendBalanceGameProvider(widget.contentId));

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: gameAsync.when(
          loading: () => const Center(child: LoadingIndicator()),
          error: (e, _) => _buildErrorView(e.toString()),
          data: (game) {
            if (game == null) {
              return _buildErrorView('게임을 찾을 수 없습니다');
            }
            return _buildContent(game);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BalanceGameSet game) {
    if (_showResult && _summary != null) {
      return _buildResultView(game, _summary!);
    }
    return Column(
      children: [
        const AppHeader(
          title: '밸런스 게임',
          showBackButton: true,
          showActions: false,
        ),
        // Progress indicator
        _buildProgressBar(game),
        // Question content
        Expanded(
          child: _buildQuestionView(game),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BalanceGameSet game) {
    final progress = (game.questions.isEmpty)
        ? 0.0
        : (_currentQuestionIndex + 1) / game.questions.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '질문 ${_currentQuestionIndex + 1}/${game.questions.length}',
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

  Widget _buildQuestionView(BalanceGameSet game) {
    if (game.questions.isEmpty) {
      return Center(
        child: Text(
          '질문이 없습니다',
          style: context.bodyMedium.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      );
    }

    final question = game.questions[_currentQuestionIndex];
    final selectedChoice = _answers[question.id];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Spacer(),
          // Choice A
          Expanded(
            flex: 4,
            child: _buildChoiceButton(
              question.choiceA,
              'A',
              selectedChoice == 'A',
              Colors.blue,
              () => _selectChoice(question.id, 'A', game),
            ),
          ),
          // VS divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    color: context.colors.border,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'VS',
                    style: context.labelLarge.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: context.colors.border,
                  ),
                ),
              ],
            ),
          ),
          // Choice B
          Expanded(
            flex: 4,
            child: _buildChoiceButton(
              question.choiceB,
              'B',
              selectedChoice == 'B',
              Colors.pink,
              () => _selectChoice(question.id, 'B', game),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildChoiceButton(
    BalanceGameChoice choice,
    String choiceKey,
    bool isSelected,
    Color accentColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.8),
                    accentColor.withValues(alpha: 0.6),
                  ],
                )
              : null,
          color: isSelected
              ? null
              : context.colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? accentColor
                : context.colors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Background image if available
            if (choice.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Opacity(
                  opacity: isSelected ? 0.3 : 0.2,
                  child: Image.network(
                    choice.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            // Content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (choice.emoji != null)
                      Text(
                        choice.emoji!,
                        style: const TextStyle(fontSize: 48),
                      ),
                    if (choice.emoji != null) const SizedBox(height: 12),
                    Text(
                      choice.text,
                      style: context.headingSmall.copyWith(
                        color: isSelected
                            ? Colors.white
                            : context.colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectChoice(String questionId, String choice, BalanceGameSet game) {
    setState(() {
      _answers[questionId] = choice;
    });

    // Auto-advance after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      if (_currentQuestionIndex < game.questions.length - 1) {
        setState(() => _currentQuestionIndex++);
      } else {
        _submitResult(game);
      }
    });
  }

  Future<void> _submitResult(BalanceGameSet game) async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(balanceGameRepositoryProvider);

      // Get summary with statistics
      _summary = await repository.getGameSummary(
        gameSetId: game.id,
        answers: _answers,
      );

      // Submit result to database
      await repository.submitResult(
        gameSetId: game.id,
        answers: _answers,
      );

      setState(() {
        _showResult = true;
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
    BalanceGameSet game,
    BalanceGameSummary summary,
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
                // Result summary
                _buildResultSummaryCard(summary),
                const SizedBox(height: 24),
                // Question breakdown
                ...List.generate(
                  summary.questionSummaries.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildQuestionSummaryCard(
                      index + 1,
                      summary.questionSummaries[index],
                      game.questions[index],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          try {
                            await Share.share(
                              '🎮 밸런스 게임 결과\n\n앱에서 더 다양한 밸런스 게임을 즐겨보세요!',
                              subject: '밸런스 게임 결과 공유',
                            );
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar( // ignore: use_build_context_synchronously
                                const SnackBar(content: Text('공유에 실패했습니다')),
                              );
                            }
                          }
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
                        onPressed: _reset,
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

  Widget _buildResultSummaryCard(BalanceGameSummary summary) {
    final majorityPercentage =
        (summary.majorityMatchCount / summary.totalQuestions * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            DSColors.accentDark,
            DSColors.accentTertiary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: DSColors.accentDark.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            majorityPercentage >= 70
                ? '🎉'
                : majorityPercentage >= 50
                    ? '😊'
                    : '😎',
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          Text(
            majorityPercentage >= 70
                ? '다수파!'
                : majorityPercentage >= 50
                    ? '평범한 취향'
                    : '소수파!',
            style: context.headingMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${summary.totalQuestions}개 중 ${summary.majorityMatchCount}개가 다수파와 일치',
            style: context.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatBadge('다수파', summary.majorityMatchCount, Colors.green),
              const SizedBox(width: 16),
              _buildStatBadge('소수파', summary.minorityCount, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$label $count개',
            style: context.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSummaryCard(
    int questionNumber,
    BalanceQuestionSummary summary,
    BalanceGameQuestion question,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Q$questionNumber',
                  style: context.labelSmall.copyWith(
                    color: context.colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: summary.isMajority
                      ? DSColors.success.withValues(alpha: 0.1)
                      : DSColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  summary.isMajority ? '다수파' : '소수파',
                  style: context.labelSmall.copyWith(
                    color: summary.isMajority
                        ? DSColors.success
                        : DSColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Choice A bar
          _buildChoiceBar(
            summary.choiceAText,
            summary.percentageA,
            summary.userChoice == 'A',
            Colors.blue,
            question.choiceA.emoji,
          ),
          const SizedBox(height: 8),
          // Choice B bar
          _buildChoiceBar(
            summary.choiceBText,
            summary.percentageB,
            summary.userChoice == 'B',
            Colors.pink,
            question.choiceB.emoji,
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceBar(
    String text,
    double percentage,
    bool isSelected,
    Color color,
    String? emoji,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (emoji != null) ...[
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                text,
                style: context.bodySmall.copyWith(
                  color: isSelected
                      ? color
                      : context.colors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: context.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percentage / 100,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: isSelected ? color : color.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _reset() {
    setState(() {
      _currentQuestionIndex = 0;
      _answers.clear();
      _showResult = false;
      _summary = null;
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
