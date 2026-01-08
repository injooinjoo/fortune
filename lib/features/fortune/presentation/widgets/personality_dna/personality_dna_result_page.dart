import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/models/personality_dna_model.dart';
import '../../../../../core/theme/typography_unified.dart';
import '../../../../../core/widgets/unified_blur_wrapper.dart';
import 'widgets/basic_info_card.dart';
import 'widgets/stats_radar_chart.dart';
import 'widgets/love_style_card.dart';
import 'widgets/work_style_card.dart';
import 'widgets/compatibility_card.dart';
import 'widgets/daily_matching_card.dart';
import 'widgets/celebrity_card.dart';
import 'widgets/rarity_card.dart';
import 'widgets/daily_fortune_card.dart';
import 'widgets/power_color_card.dart';
import '../../../../../core/widgets/fortune_hero_section.dart';
import '../../../../../core/widgets/section_card.dart';

/// 성격 DNA 결과 페이지
class PersonalityDnaResultPage extends ConsumerWidget {
  final PersonalityDNA dna;
  final bool isPremium;

  /// 블러 처리할 섹션 목록
  static const List<String> _blurredSections = [
    'love_style',
    'work_style',
    'compatibility',
    'daily_matching',
  ];

  const PersonalityDnaResultPage({
    super.key,
    required this.dna,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // 1. 프리미엄 히어로 섹션 (AI 배경 + 마스코트 + 점수)
          FortuneHeroSection(
            fortuneType: 'mbti',
            score: dna.scores['overall'] ?? 85,
            summary: dna.title,
            hashtags: dna.traits,
            onBackPressed: () => Navigator.of(context).pop(),
          ),

          // 콘텐츠
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1. 기본 조건 카드
                BasicInfoCard(dna: dna),
                const SizedBox(height: 16),

                // 2. 능력치 레이더 차트
                if (dna.stats != null) ...[
                  StatsRadarChart(stats: dna.stats!),
                  const SizedBox(height: 16),
                ],

                // 3. 연애 스타일 카드 (블러)
                if (dna.loveStyle != null) ...[
                  UnifiedBlurWrapper(
                    isBlurred: !isPremium,
                    blurredSections: _blurredSections,
                    sectionKey: 'love_style',
                    fortuneType: 'personality_dna',
                    child: SectionCard(
                      title: '연애 스타일',
                      sectionKey: 'relationship',
                      child: LoveStyleCard(loveStyle: dna.loveStyle!),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 4. 직장 스타일 카드 (블러)
                if (dna.workStyle != null) ...[
                  UnifiedBlurWrapper(
                    isBlurred: !isPremium,
                    blurredSections: _blurredSections,
                    sectionKey: 'work_style',
                    fortuneType: 'personality_dna',
                    child: SectionCard(
                      title: '업무 스타일',
                      sectionKey: 'work',
                      child: WorkStyleCard(workStyle: dna.workStyle!),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 5. 궁합 카드 (블러)
                if (dna.compatibility != null) ...[
                  UnifiedBlurWrapper(
                    isBlurred: !isPremium,
                    blurredSections: _blurredSections,
                    sectionKey: 'compatibility',
                    fortuneType: 'personality_dna',
                    child: CompatibilityCard(compatibility: dna.compatibility!),
                  ),
                  const SizedBox(height: 16),
                ],

                // 6. 일상 매칭 카드 (블러)
                if (dna.dailyMatching != null) ...[
                  UnifiedBlurWrapper(
                    isBlurred: !isPremium,
                    blurredSections: _blurredSections,
                    sectionKey: 'daily_matching',
                    fortuneType: 'personality_dna',
                    child: DailyMatchingCard(dailyMatching: dna.dailyMatching!),
                  ),
                  const SizedBox(height: 16),
                ],

                // 7. 유명인 닮은꼴 카드
                if (dna.celebrity != null) ...[
                  CelebrityCard(celebrity: dna.celebrity!),
                  const SizedBox(height: 16),
                ],

                // 8. 희귀도 카드
                RarityCard(
                  popularityRank: dna.popularityRank,
                  mbti: dna.mbti,
                ),
                const SizedBox(height: 16),

                // 9. 데일리 운세 카드
                if (dna.dailyFortune != null) ...[
                  DailyFortuneCard(dailyFortune: dna.dailyFortune!),
                  const SizedBox(height: 16),
                ],

                // 10. 파워 컬러 카드
                if (dna.powerColor != null) ...[
                  PowerColorCard(powerColor: dna.powerColor!),
                  const SizedBox(height: 16),
                ],

                // 재미있는 사실
                if (dna.funnyFact != null && dna.funnyFact!.isNotEmpty) ...[
                  _buildFunnyFactCard(context),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFunnyFactCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                '재미있는 사실',
                style: context.heading4.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            dna.funnyFact!,
            style: context.bodyLarge,
          ),
        ],
      ),
    );
  }
}
