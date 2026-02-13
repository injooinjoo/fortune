import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/models/personality_dna_model.dart';
import '../../../../core/services/fortune_haptic_service.dart';
import '../../../../core/constants/fortune_card_images.dart';

/// 채팅용 성격 DNA 결과 카드
///
/// - DNA 코드 + 제목 헤더
/// - 기본 정보 그리드 (MBTI, 혈액형, 별자리, 띠)
/// - 능력치 바 차트
/// - 연애 스타일
/// - 업무 스타일
/// - 궁합 정보
/// - 일상 매칭
/// - 유명인 닮은꼴
/// - 파워 컬러
/// - 재미있는 사실
/// - 인기 순위
class PersonalityDnaChatCard extends ConsumerStatefulWidget {
  final PersonalityDNA dna;

  const PersonalityDnaChatCard({
    super.key,
    required this.dna,
  });

  @override
  ConsumerState<PersonalityDnaChatCard> createState() =>
      _PersonalityDnaChatCardState();
}

class _PersonalityDnaChatCardState
    extends ConsumerState<PersonalityDnaChatCard> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(fortuneHapticServiceProvider).mysticalReveal();
      }
    });
  }

  PersonalityDNA get dna => widget.dna;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        vertical: DSSpacing.sm,
        horizontal: DSSpacing.md,
      ),
      child: DSCard.flat(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더: 프리미엄 AI 배경 + 마스코트
            _buildHeader(context).animate().fadeIn(duration: 500.ms),

            // 기본 정보 그리드 (AI 아이콘 적용)
            _buildBasicInfoGrid(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 100.ms),

            // 특징 및 설명
            _buildDescriptionAndTraits(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 150.ms),

            // 블러 가능 영역
            _buildBlurrableContent(context, isDark)
                .animate()
                .fadeIn(duration: 500.ms, delay: 200.ms),

            const SizedBox(height: DSSpacing.md),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms);
  }

  Widget _buildBlurrableContent(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 능력치 바 차트
        if (dna.stats != null) _buildStatsSection(context),

        // 연애 스타일
        if (dna.loveStyle != null) _buildLoveStyleSection(context),

        // 업무 스타일
        if (dna.workStyle != null) _buildWorkStyleSection(context),

        // 궁합 정보
        if (dna.compatibility != null) _buildCompatibilitySection(context),

        // 일상 매칭
        if (dna.dailyMatching != null) _buildDailyMatchingSection(context),

        // 유명인 닮은꼴
        if (dna.celebrity != null) _buildCelebritySection(context),

        // 파워 컬러
        if (dna.powerColor != null) _buildPowerColorSection(context),

        // 재미있는 사실
        if (dna.funnyFact != null && dna.funnyFact!.isNotEmpty)
          _buildFunFactSection(context),

        // 인기 순위
        if (dna.popularityRank != null) _buildPopularitySection(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final score = dna.scores['overall'] ?? 85;

    final heroImage = FortuneCardImages.getHeroImage('mbti', score);
    final mascotImage = FortuneCardImages.getMascotImage('mbti', score);

    return Container(
      height: 220,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. 프리미엄 배경 (AI 생성)
          Image.asset(
            heroImage,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: dna.gradientColors.isNotEmpty
                      ? dna.gradientColors
                      : [colors.accent, colors.accentSecondary],
                ),
              ),
            ),
          ),

          // 2. 어두운 오버레이 (텍스트 가독성)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  DSColors.background.withValues(alpha: 0.1),
                  DSColors.background.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),

          // 3. 내용
          Padding(
            padding: const EdgeInsets.all(DSSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 마스코트
                if (mascotImage != null)
                  Image.asset(
                    mascotImage,
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        Text(dna.emoji, style: const TextStyle(fontSize: 48)),
                  )
                else
                  Text(dna.emoji, style: const TextStyle(fontSize: 48)),
                const SizedBox(height: DSSpacing.md),

                // DNA 코드 뱃지
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    dna.dnaCode,
                    style: typography.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // 제목
                Text(
                  dna.title,
                  style: typography.headingSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionAndTraits(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 설명
          Text(
            dna.description,
            style: typography.bodyMedium.copyWith(
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
          if (dna.traits.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            // 해시태그
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: dna.traits.map((trait) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.backgroundSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(DSRadius.sm),
                    border: Border.all(
                      color: colors.textPrimary.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Text(
                    '#$trait',
                    style: typography.labelSmall.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBasicInfoGrid(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Row(
        children: [
          _buildInfoChip(context, colors, typography, 'MBTI', dna.mbti,
              iconPath:
                  'assets/images/fortune/mbti/characters/mbti_${dna.mbti.toLowerCase()}.webp'),
          _buildInfoChip(
              context, colors, typography, '혈액형', '${dna.bloodType}형',
              iconPath: 'assets/images/fortune/items/lucky/lucky_heart.webp'),
          _buildInfoChip(context, colors, typography, '별자리', dna.zodiac,
              iconPath: 'assets/images/fortune/items/lucky/lucky_star.webp'),
          _buildInfoChip(context, colors, typography, '띠', dna.zodiacAnimal,
              iconPath:
                  'assets/images/fortune/zodiac/zodiac_${_getZodiacKey(dna.zodiacAnimal)}.webp'),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, DSColorScheme colors,
      DSTypographyScheme typography, String label, String value,
      {IconData? icon, String? iconPath}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(
          vertical: DSSpacing.sm,
          horizontal: DSSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colors.backgroundSecondary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(color: colors.textPrimary.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            if (iconPath != null)
              Image.asset(
                iconPath,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(icon ?? Icons.auto_awesome,
                    size: 16, color: colors.textSecondary),
              )
            else
              Icon(icon ?? Icons.auto_awesome,
                  size: 16, color: colors.textSecondary),
            const SizedBox(height: 6),
            Text(
              value,
              style: typography.labelMedium.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: typography.labelSmall.copyWith(
                color: colors.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final colors = context.colors;
    final stats = dna.stats!;
    return _buildSection(
      context,
      colors,
      title: '능력치',
      icon: Icons.bar_chart,
      child: Column(
        children: [
          _buildStatBar(context, colors, '카리스마', stats.charisma, Colors.red),
          _buildStatBar(context, colors, '지능', stats.intelligence, Colors.blue),
          _buildStatBar(
              context, colors, '창의력', stats.creativity, Colors.purple),
          _buildStatBar(
              context, colors, '리더십', stats.leadership, Colors.orange),
          _buildStatBar(context, colors, '공감력', stats.empathy, Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatBar(BuildContext context, DSColorScheme colors, String label,
      int value, Color color) {
    final typography = context.typography;
    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style:
                  typography.labelSmall.copyWith(color: colors.textSecondary),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: colors.textPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: value / 100,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: DSSpacing.sm),
          SizedBox(
            width: 30,
            child: Text(
              '$value',
              style: typography.labelSmall.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoveStyleSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final love = dna.loveStyle!;
    return _buildSection(
      context,
      colors,
      title: '연애 스타일',
      icon: Icons.favorite,
      iconColor: Colors.pink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            love.title,
            style: typography.bodyMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            love.description,
            style: typography.bodySmall.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: DSSpacing.sm),
          _buildLoveItem(context, colors, typography, '연애할 때', love.whenDating),
          _buildLoveItem(
              context, colors, typography, '이별 후', love.afterBreakup),
        ],
      ),
    );
  }

  Widget _buildLoveItem(BuildContext context, DSColorScheme colors,
      DSTypographyScheme typography, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.xs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.pink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DSRadius.xs),
            ),
            child: Text(
              label,
              style: typography.labelSmall.copyWith(
                color: Colors.pink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Text(
              value,
              style: typography.bodySmall.copyWith(color: colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkStyleSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final work = dna.workStyle!;
    return _buildSection(
      context,
      colors,
      title: '업무 스타일',
      icon: Icons.work,
      iconColor: Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            work.title,
            style: typography.bodyMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          _buildWorkItem(context, colors, typography, '상사일 때', work.asBoss),
          _buildWorkItem(
              context, colors, typography, '회식에서', work.atCompanyDinner),
          _buildWorkItem(context, colors, typography, '업무 습관', work.workHabit),
        ],
      ),
    );
  }

  Widget _buildWorkItem(BuildContext context, DSColorScheme colors,
      DSTypographyScheme typography, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.xs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DSRadius.xs),
            ),
            child: Text(
              label,
              style: typography.labelSmall.copyWith(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Text(
              value,
              style: typography.bodySmall.copyWith(color: colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilitySection(BuildContext context) {
    final colors = context.colors;
    final compat = dna.compatibility!;
    return _buildSection(
      context,
      colors,
      title: '나와 맞는 유형',
      icon: Icons.people,
      iconColor: Colors.purple,
      child: Column(
        children: [
          _buildCompatItem(context, colors, '친구', compat.friend.mbti,
              compat.friend.description, Icons.person),
          _buildCompatItem(context, colors, '연인', compat.lover.mbti,
              compat.lover.description, Icons.favorite),
          _buildCompatItem(context, colors, '동료', compat.colleague.mbti,
              compat.colleague.description, Icons.business_center),
        ],
      ),
    );
  }

  Widget _buildCompatItem(BuildContext context, DSColorScheme colors,
      String type, String mbti, String description, IconData icon) {
    final typography = context.typography;
    return Container(
      margin: const EdgeInsets.only(bottom: DSSpacing.sm),
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(DSRadius.md),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(DSSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DSRadius.sm),
            ),
            child: Icon(icon, size: 20, color: Colors.purple),
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      type,
                      style: typography.labelSmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: DSSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DSSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(DSRadius.xs),
                      ),
                      child: Text(
                        mbti,
                        style: typography.labelSmall.copyWith(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: typography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyMatchingSection(BuildContext context) {
    final colors = context.colors;
    final matching = dna.dailyMatching!;
    return _buildSection(
      context,
      colors,
      title: '일상 매칭',
      icon: Icons.coffee,
      iconColor: Colors.brown,
      child: Column(
        children: [
          _buildMatchingItem(context, colors, '추천 카페 메뉴', matching.cafeMenu),
          _buildMatchingItem(context, colors, '추천 넷플릭스', matching.netflixGenre),
          _buildMatchingItem(
              context, colors, '주말 활동', matching.weekendActivity),
        ],
      ),
    );
  }

  Widget _buildMatchingItem(
      BuildContext context, DSColorScheme colors, String label, String value) {
    final typography = context.typography;
    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: typography.labelSmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: typography.bodySmall.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCelebritySection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final celeb = dna.celebrity!;
    return _buildSection(
      context,
      colors,
      title: '닮은 유명인',
      icon: Icons.stars,
      iconColor: Colors.amber,
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.amber.withValues(alpha: 0.1),
              Colors.orange.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: Colors.amber.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 32, color: Colors.amber),
            ),
            const SizedBox(width: DSSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    celeb.name,
                    style: typography.bodyLarge.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    celeb.reason,
                    style: typography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerColorSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final power = dna.powerColor!;
    return _buildSection(
      context,
      colors,
      title: '파워 컬러',
      icon: Icons.palette,
      iconColor: power.color,
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              power.color.withValues(alpha: 0.2),
              power.color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: power.color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: power.color,
                borderRadius: BorderRadius.circular(DSRadius.md),
                boxShadow: [
                  BoxShadow(
                    color: power.color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: DSSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    power.name,
                    style: typography.bodyLarge.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '이 색을 활용하면 에너지가 높아져요',
                    style: typography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunFactSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return _buildSection(
      context,
      colors,
      title: '재미있는 사실',
      icon: Icons.lightbulb,
      iconColor: Colors.yellow.shade700,
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: Colors.yellow.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DSRadius.md),
        ),
        child: Row(
          children: [
            const Text('💡', style: TextStyle(fontSize: 24)),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              child: Text(
                dna.funnyFact!,
                style: typography.bodySmall.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularitySection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return _buildSection(
      context,
      colors,
      title: '희귀도',
      icon: Icons.trending_up,
      iconColor: dna.popularityColor,
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              dna.popularityColor.withValues(alpha: 0.15),
              dna.popularityColor.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: dna.popularityColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getPopularityIcon(),
              size: 32,
              color: dna.popularityColor,
            ),
            const SizedBox(width: DSSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dna.popularityText,
                  style: typography.headingSmall.copyWith(
                    color: dna.popularityColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getPopularityDescription(),
                  style: typography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPopularityIcon() {
    if (dna.popularityRank == null) return Icons.help_outline;
    if (dna.popularityRank! <= 10) return Icons.diamond;
    if (dna.popularityRank! <= 50) return Icons.star;
    return Icons.circle;
  }

  String _getPopularityDescription() {
    if (dna.popularityRank == null) return '순위 분석 중';
    if (dna.popularityRank! <= 10) return '매우 희귀한 조합이에요!';
    if (dna.popularityRank! <= 50) return '꽤 특별한 조합이에요';
    return '흔한 조합이에요';
  }

  Widget _buildSection(
    BuildContext context,
    DSColorScheme colors, {
    required String title,
    required IconData icon,
    Color? iconColor,
    required Widget child,
  }) {
    final typography = context.typography;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        DSSpacing.md,
        DSSpacing.md,
        DSSpacing.md,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: iconColor ?? colors.textSecondary,
              ),
              const SizedBox(width: DSSpacing.xs),
              Text(
                title,
                style: typography.labelLarge.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          child,
        ],
      ),
    );
  }

  String _getZodiacKey(String animal) {
    const Map<String, String> keys = {
      '쥐': 'rat',
      '소': 'ox',
      '호랑이': 'tiger',
      '토끼': 'rabbit',
      '용': 'dragon',
      '뱀': 'snake',
      '말': 'horse',
      '양': 'sheep',
      '원숭이': 'monkey',
      '닭': 'rooster',
      '개': 'dog',
      '돼지': 'pig',
    };
    return keys[animal] ?? 'dog';
  }
}
