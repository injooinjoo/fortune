import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fortune/core/theme/toss_theme.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/components/app_card.dart';
import 'package:fortune/core/widgets/unified_blur_wrapper.dart';
import 'package:fortune/core/widgets/unified_button.dart';
import 'package:fortune/domain/entities/fortune.dart';
import 'overall_score_card.dart';
import 'detailed_scores_card.dart';
import 'traditional_compatibility_card.dart';
import 'numeric_compatibility_card.dart';
import 'emotional_compatibility_card.dart';
import 'compatibility_analysis_card.dart';
import 'relationship_advice_card.dart';

class CompatibilityResultView extends StatelessWidget {
  final Fortune fortune;
  final Map<String, double> scores;
  final String person1Name;
  final String person2Name;
  final bool isBlurred;
  final List<String> blurredSections;
  final VoidCallback onShowAdAndUnblur;

  const CompatibilityResultView({
    super.key,
    required this.fortune,
    required this.scores,
    required this.person1Name,
    required this.person2Name,
    required this.isBlurred,
    required this.blurredSections,
    required this.onShowAdAndUnblur,
  });

  @override
  Widget build(BuildContext context) {
    final overallScore = scores['전체 궁합'] ?? 0.85;

    return Stack(
      fit: StackFit.expand,
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 전체 궁합 점수
              OverallScoreCard(
                person1Name: person1Name,
                person2Name: person2Name,
                overallScore: overallScore,
                fortune: fortune,
              ).animate().fadeIn().slideY(begin: -0.3),

              const SizedBox(height: 24),

              // 세부 궁합 점수 (블러 처리)
              DetailedScoresCard(
                scores: scores,
                isBlurred: isBlurred,
                blurredSections: blurredSections,
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3),

              const SizedBox(height: 16),

              // 전통 궁합 (띠 + 별자리)
              if (fortune.metadata?['zodiac_animal'] != null || fortune.metadata?['star_sign'] != null)
                TraditionalCompatibilityCard(
                  fortune: fortune,
                ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3),

              const SizedBox(height: 16),

              // 숫자 궁합 (이름 + 운명수)
              if (fortune.metadata?['name_compatibility'] != null || fortune.metadata?['destiny_number'] != null)
                NumericCompatibilityCard(
                  fortune: fortune,
                  person1Name: person1Name,
                  person2Name: person2Name,
                ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.3),

              const SizedBox(height: 16),

              // 감성 궁합 (계절 + 나이차)
              if (fortune.metadata?['season'] != null || fortune.metadata?['age_difference'] != null)
                EmotionalCompatibilityCard(
                  fortune: fortune,
                ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.3),

              const SizedBox(height: 16),

              // 궁합 분석 결과 (블러 처리)
              CompatibilityAnalysisCard(
                fortune: fortune,
                isBlurred: isBlurred,
                blurredSections: blurredSections,
              ).animate(delay: 450.ms).fadeIn().slideY(begin: 0.3),

              if (fortune.advice?.isNotEmpty == true) ...[
                const SizedBox(height: 16),

                // 관계 개선 조언 (블러 처리)
                RelationshipAdviceCard(
                  fortune: fortune,
                  isBlurred: isBlurred,
                  blurredSections: blurredSections,
                ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.3),
              ],

              const SizedBox(height: 120), // 버튼 공간 확보
            ],
          ),
        ),

        // 블러 해제 버튼 (블러 상태일 때만 표시)
        if (isBlurred)
          UnifiedButton.floating(
            text: '🎁 광고 보고 전체 내용 보기',
            onPressed: onShowAdAndUnblur,
            isEnabled: true,
          ),
      ],
    );
  }
}
