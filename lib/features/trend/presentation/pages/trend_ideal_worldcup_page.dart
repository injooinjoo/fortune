import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/loading_states.dart';
import '../../../../shared/components/toast.dart';
import 'package:fortune/core/design_system/design_system.dart';
import '../../domain/models/models.dart';
import '../providers/trend_providers.dart';

/// 이상형 월드컵 상세 Provider
final trendIdealWorldcupProvider =
    FutureProvider.family<IdealWorldcup?, String>((ref, contentId) async {
  final repository = ref.watch(idealWorldcupRepositoryProvider);
  return repository.getWorldcupByContentId(contentId);
});

class TrendIdealWorldcupPage extends ConsumerStatefulWidget {
  final String contentId;

  const TrendIdealWorldcupPage({
    super.key,
    required this.contentId,
  });

  @override
  ConsumerState<TrendIdealWorldcupPage> createState() =>
      _TrendIdealWorldcupPageState();
}

class _TrendIdealWorldcupPageState
    extends ConsumerState<TrendIdealWorldcupPage> {
  List<WorldcupCandidate> _currentRound = [];
  List<WorldcupCandidate> _nextRound = [];
  List<WorldcupMatchResult> _matchHistory = [];
  int _currentMatchIndex = 0;
  int _currentRoundSize = 16;
  bool _isSubmitting = false;
  WorldcupCandidate? _winner;
  List<WorldcupRanking>? _rankings;

  @override
  Widget build(BuildContext context) {
    final worldcupAsync =
        ref.watch(trendIdealWorldcupProvider(widget.contentId));

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: worldcupAsync.when(
          loading: () => const Center(child: LoadingIndicator()),
          error: (e, _) => _buildErrorView(e.toString()),
          data: (worldcup) {
            if (worldcup == null) {
              return _buildErrorView('월드컵을 찾을 수 없습니다');
            }
            // Initialize candidates on first load
            if (_currentRound.isEmpty && _winner == null) {
              _initializeWorldcup(worldcup);
            }
            return _buildContent(worldcup);
          },
        ),
      ),
    );
  }

  void _initializeWorldcup(IdealWorldcup worldcup) {
    final candidates = List<WorldcupCandidate>.from(worldcup.candidates);
    candidates.shuffle(Random());

    // Determine round size based on candidate count
    final candidateCount = candidates.length;
    if (candidateCount >= 16) {
      _currentRoundSize = 16;
    } else if (candidateCount >= 8) {
      _currentRoundSize = 8;
    } else {
      _currentRoundSize = 4;
    }

    _currentRound = candidates.take(_currentRoundSize).toList();
    _nextRound = [];
    _matchHistory = [];
    _currentMatchIndex = 0;
  }

  Widget _buildContent(IdealWorldcup worldcup) {
    if (_winner != null) {
      return _buildResultView(worldcup, _winner!);
    }
    return Column(
      children: [
        const AppHeader(
          title: '이상형 월드컵',
          showBackButton: true,
          showActions: false,
        ),
        // Round indicator
        _buildRoundIndicator(),
        // Match view
        Expanded(
          child: _buildMatchView(),
        ),
      ],
    );
  }

  Widget _buildRoundIndicator() {
    final roundName = _getRoundName(_currentRound.length);
    final matchProgress =
        '${_currentMatchIndex + 1}/${_currentRound.length ~/ 2}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: DSColors.accentDark.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              roundName,
              style: context.labelMedium.copyWith(
                color: DSColors.accentDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            matchProgress,
            style: context.labelMedium.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _getRoundName(int candidatesLeft) {
    switch (candidatesLeft) {
      case 16:
        return '16강';
      case 8:
        return '8강';
      case 4:
        return '4강';
      case 2:
        return '결승';
      default:
        return '$candidatesLeft강';
    }
  }

  Widget _buildMatchView() {
    if (_currentRound.length < 2) {
      return const Center(child: CircularProgressIndicator());
    }

    final matchIndex = _currentMatchIndex * 2;
    if (matchIndex + 1 >= _currentRound.length) {
      return const Center(child: CircularProgressIndicator());
    }

    final candidate1 = _currentRound[matchIndex];
    final candidate2 = _currentRound[matchIndex + 1];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: _buildCandidateCard(
              candidate1,
              true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    DSColors.accentDark,
                    DSColors.accentTertiary,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: DSColors.accentDark.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'VS',
                  style: context.labelLarge.copyWith(
                    color: context.colors.ctaForeground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildCandidateCard(
              candidate2,
              false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(
    WorldcupCandidate candidate,
    bool isTop,
  ) {
    return GestureDetector(
      onTap: () => _selectCandidate(candidate, isTop),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              Image.network(
                candidate.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: context.colors.surface,
                  child: const Center(
                    child: Text(
                      '🎯',
                      style: TextStyle(fontSize: 64),
                    ),
                  ),
                ),
              ),
              // Gradient overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: isTop ? Alignment.topCenter : Alignment.bottomCenter,
                      end: isTop ? Alignment.bottomCenter : Alignment.topCenter,
                      colors: [
                        Colors.transparent,
                        context.colors.background.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),
              // Name label
              Positioned(
                left: 16,
                right: 16,
                bottom: isTop ? null : 16,
                top: isTop ? 16 : null,
                child: Text(
                  candidate.name,
                  style: context.headingSmall.copyWith(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                        color: context.colors.background.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  textAlign: isTop ? TextAlign.left : TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectCandidate(WorldcupCandidate winner, bool isTop) {
    final matchIndex = _currentMatchIndex * 2;
    final loser = isTop
        ? _currentRound[matchIndex + 1]
        : _currentRound[matchIndex];

    setState(() {
      // Record match result
      _matchHistory.add(WorldcupMatchResult(
        round: _currentRound.length,
        winnerId: winner.id,
        loserId: loser.id,
      ));

      _nextRound.add(winner);
      _currentMatchIndex++;

      // Check if round is complete
      if (_currentMatchIndex >= _currentRound.length ~/ 2) {
        if (_nextRound.length == 1) {
          // We have a winner!
          _winner = _nextRound.first;
          _submitResult();
        } else {
          // Move to next round
          _currentRound = List.from(_nextRound);
          _nextRound = [];
          _currentMatchIndex = 0;
        }
      }
    });
  }

  Future<void> _submitResult() async {
    if (_isSubmitting || _winner == null) return;

    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(idealWorldcupRepositoryProvider);
      final worldcup =
          ref.read(trendIdealWorldcupProvider(widget.contentId)).value;

      if (worldcup == null) return;

      // Submit result
      await repository.submitResult(
        worldcupId: worldcup.id,
        winnerId: _winner!.id,
        matchHistory: _matchHistory,
      );

      // Get rankings
      _rankings = await repository.getRankings(worldcup.id, limit: 10);

      setState(() => _isSubmitting = false);
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        Toast.show(context, message: '결과 저장 중 오류가 발생했습니다', type: ToastType.error);
      }
    }
  }

  Widget _buildResultView(
    IdealWorldcup worldcup,
    WorldcupCandidate winner,
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
                // Trophy icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.shade300,
                        Colors.amber.shade700,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🏆', style: TextStyle(fontSize: 40)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '나의 이상형',
                  style: context.labelLarge.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                // Winner card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            winner.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: context.colors.surface,
                              child: const Center(
                                child: Text(
                                  '🎯',
                                  style: TextStyle(fontSize: 80),
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    context.colors.background.withValues(alpha: 0.7),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 16,
                            child: Text(
                              winner.name,
                              style: context.headingMedium.copyWith(
                                color: context.colors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Rankings section
                if (_rankings != null && _rankings!.isNotEmpty) ...[
                  _buildRankingsSection(),
                  const SizedBox(height: 24),
                ],
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
                            color: context.colors.ctaForeground,
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

  Widget _buildRankingsSection() {
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
            '전체 랭킹',
            style: context.labelLarge.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            _rankings!.length.clamp(0, 5),
            (index) {
              final ranking = _rankings![index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    _buildRankBadge(index + 1),
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        ranking.candidateImage,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: context.colors.border,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              '🎯',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        ranking.candidateName,
                        style: context.bodyMedium.copyWith(
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '${ranking.winRate.toStringAsFixed(1)}%',
                      style: context.labelMedium.copyWith(
                        color: DSColors.accentDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    Color badgeColor;
    switch (rank) {
      case 1:
        badgeColor = Colors.amber;
        break;
      case 2:
        badgeColor = Colors.grey.shade400;
        break;
      case 3:
        badgeColor = Colors.orange.shade700;
        break;
      default:
        badgeColor = DSColors.textDisabledDark;
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: badgeColor,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: context.labelSmall.copyWith(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _reset() {
    final worldcup =
        ref.read(trendIdealWorldcupProvider(widget.contentId)).value;
    if (worldcup != null) {
      setState(() {
        _winner = null;
        _rankings = null;
        _matchHistory = [];
        _initializeWorldcup(worldcup);
      });
    }
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
