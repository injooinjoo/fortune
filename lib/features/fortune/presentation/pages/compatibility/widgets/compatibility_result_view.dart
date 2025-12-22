import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/core/design_system/components/traditional/traditional_button.dart';
import 'package:fortune/domain/entities/fortune.dart';
import 'package:fortune/presentation/providers/subscription_provider.dart';
import 'overall_score_card.dart';
import 'detailed_scores_card.dart';
import 'traditional_compatibility_card.dart';
import 'numeric_compatibility_card.dart';
import 'emotional_compatibility_card.dart';
import 'compatibility_analysis_card.dart';
import 'relationship_advice_card.dart';

class CompatibilityResultView extends ConsumerStatefulWidget {
  final Fortune fortune;
  final Map<String, double> scores;
  final String person1Name;
  final String person2Name;
  final bool isBlurred;
  final List<String> blurredSections;
  final VoidCallback onShowAdAndUnblur;

  /// 프로필 추가 버튼 표시 여부 (직접 입력 + 프로필 추가 가능할 때)
  final bool showAddProfileButton;

  /// 프로필 추가 버튼 클릭 시 콜백
  final VoidCallback? onAddProfile;

  const CompatibilityResultView({
    super.key,
    required this.fortune,
    required this.scores,
    required this.person1Name,
    required this.person2Name,
    required this.isBlurred,
    required this.blurredSections,
    required this.onShowAdAndUnblur,
    this.showAddProfileButton = false,
    this.onAddProfile,
  });

  @override
  ConsumerState<CompatibilityResultView> createState() => _CompatibilityResultViewState();
}

class _CompatibilityResultViewState extends ConsumerState<CompatibilityResultView> {
  // GPT 스타일 타이핑 효과 섹션 관리
  int _currentTypingSection = 0;

  @override
  void didUpdateWidget(covariant CompatibilityResultView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // fortune이 변경되면 타이핑 섹션 리셋
    if (widget.fortune != oldWidget.fortune) {
      setState(() => _currentTypingSection = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final overallScore = widget.scores['전체 궁합'] ?? 0.85;

    return Stack(
      fit: StackFit.expand,
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 전체 궁합 점수
              OverallScoreCard(
                person1Name: widget.person1Name,
                person2Name: widget.person2Name,
                overallScore: overallScore,
                fortune: widget.fortune,
              ).animate().fadeIn().slideY(begin: -0.3),

              const SizedBox(height: 24),

              // 세부 궁합 점수 (블러 처리)
              DetailedScoresCard(
                scores: widget.scores,
                isBlurred: widget.isBlurred,
                blurredSections: widget.blurredSections,
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3),

              const SizedBox(height: 16),

              // 전통 궁합 (띠 + 별자리)
              if (widget.fortune.metadata?['zodiac_animal'] != null || widget.fortune.metadata?['star_sign'] != null)
                TraditionalCompatibilityCard(
                  fortune: widget.fortune,
                ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3),

              const SizedBox(height: 16),

              // 숫자 궁합 (이름 + 운명수)
              if (widget.fortune.metadata?['name_compatibility'] != null || widget.fortune.metadata?['destiny_number'] != null)
                NumericCompatibilityCard(
                  fortune: widget.fortune,
                  person1Name: widget.person1Name,
                  person2Name: widget.person2Name,
                ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.3),

              const SizedBox(height: 16),

              // 감성 궁합 (계절 + 나이차)
              if (widget.fortune.metadata?['season'] != null || widget.fortune.metadata?['age_difference'] != null)
                EmotionalCompatibilityCard(
                  fortune: widget.fortune,
                ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.3),

              const SizedBox(height: 16),

              // 궁합 분석 결과 (블러 처리) - 타이핑 섹션 0
              CompatibilityAnalysisCard(
                fortune: widget.fortune,
                isBlurred: widget.isBlurred,
                blurredSections: widget.blurredSections,
                startTyping: _currentTypingSection >= 0,
                onTypingComplete: () {
                  if (mounted) setState(() => _currentTypingSection = 1);
                },
              ).animate(delay: 450.ms).fadeIn().slideY(begin: 0.3),

              if (widget.fortune.advice?.isNotEmpty == true) ...[
                const SizedBox(height: 16),

                // 관계 개선 조언 (블러 처리) - 타이핑 섹션 1
                RelationshipAdviceCard(
                  fortune: widget.fortune,
                  isBlurred: widget.isBlurred,
                  blurredSections: widget.blurredSections,
                  startTyping: _currentTypingSection >= 1,
                  onTypingComplete: () {
                    // 마지막 섹션 완료
                    if (mounted) setState(() => _currentTypingSection = 2);
                  },
                ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.3),
              ],

              const SizedBox(height: 120), // 버튼 공간 확보
            ],
          ),
        ),

        // ✅ 블러 해제 버튼 (블러 상태일 때만, 구독자 제외)
        if (widget.isBlurred && !ref.watch(isPremiumProvider))
          Positioned(
            left: 20,
            right: 20,
            bottom: 32,
            child: TraditionalButton(
              text: '광고 보고 전체 내용 보기',
              hanja: '解禁',
              style: TraditionalButtonStyle.filled,
              colorScheme: TraditionalButtonColorScheme.love,
              isExpanded: true,
              height: 56,
              onPressed: widget.onShowAdAndUnblur,
            ),
          ),

        // ✅ 프로필 추가 프롬프트 (블러 해제 후 + 직접 입력이었을 때)
        if (!widget.isBlurred && widget.showAddProfileButton)
          _buildAddProfilePrompt(context),
      ],
    );
  }

  /// 프로필 추가 프롬프트 위젯
  Widget _buildAddProfilePrompt(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.person2Name}님을 프로필에 저장할까요?',
                    style: TextStyle(
                      fontSize: 15, // 예외: 플로팅 프롬프트 타이틀
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '저장하면 다음에 더 빠르게 궁합을 확인할 수 있어요',
                    style: TextStyle(
                      fontSize: 13, // 예외: 초소형 안내 문구
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: widget.onAddProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '저장',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.3),
    );
  }
}
