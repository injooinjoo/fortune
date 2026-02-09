import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/models/personality_dna_model.dart';
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
                const SizedBox(height: DSSpacing.md),

                // 2. 능력치 레이더 차트
                if (dna.stats != null) ...[
                  StatsRadarChart(stats: dna.stats!),
                  const SizedBox(height: DSSpacing.md),
                ],

                // 3. 연애 스타일 카드
                if (dna.loveStyle != null) ...[
                  SectionCard(
                    title: '연애 스타일',
                    sectionKey: 'relationship',
                    child: LoveStyleCard(loveStyle: dna.loveStyle!),
                  ),
                  const SizedBox(height: DSSpacing.md),
                ],

                // 4. 직장 스타일 카드
                if (dna.workStyle != null) ...[
                  SectionCard(
                    title: '업무 스타일',
                    sectionKey: 'work',
                    child: WorkStyleCard(workStyle: dna.workStyle!),
                  ),
                  const SizedBox(height: DSSpacing.md),
                ],

                // 5. 궁합 카드
                if (dna.compatibility != null) ...[
                  CompatibilityCard(compatibility: dna.compatibility!),
                  const SizedBox(height: DSSpacing.md),
                ],

                // 6. 일상 매칭 카드
                if (dna.dailyMatching != null) ...[
                  DailyMatchingCard(dailyMatching: dna.dailyMatching!),
                  const SizedBox(height: DSSpacing.md),
                ],

                // 7. 유명인 닮은꼴 카드
                if (dna.celebrity != null) ...[
                  CelebrityCard(celebrity: dna.celebrity!),
                  const SizedBox(height: DSSpacing.md),
                ],

                // 8. 희귀도 카드
                RarityCard(
                  popularityRank: dna.popularityRank,
                  mbti: dna.mbti,
                ),
                const SizedBox(height: DSSpacing.md),

                // 9. 데일리 운세 카드
                if (dna.dailyFortune != null) ...[
                  DailyFortuneCard(dailyFortune: dna.dailyFortune!),
                  const SizedBox(height: DSSpacing.md),
                ],

                // 10. 파워 컬러 카드
                if (dna.powerColor != null) ...[
                  PowerColorCard(powerColor: dna.powerColor!),
                  const SizedBox(height: DSSpacing.md),
                ],

                // 재미있는 사실
                if (dna.funnyFact != null && dna.funnyFact!.isNotEmpty) ...[
                  _buildFunnyFactCard(context),
                  const SizedBox(height: DSSpacing.md),
                ],

                const SizedBox(height: DSSpacing.xl),
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
              const SizedBox(width: DSSpacing.sm),
              Text(
                '재미있는 사실',
                style: context.heading4.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm + 4),
          Text(
            dna.funnyFact!,
            style: context.bodyLarge,
          ),
        ],
      ),
    );
  }
}
