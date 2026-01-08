import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/constants/fortune_card_images.dart';
import '../../../../core/utils/fortune_text_cleaner.dart';
import '../../../../core/services/fortune_haptic_service.dart';
import '../../../../core/widgets/fortune_action_buttons.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/widgets/fortune_infographic/fortune_infographic_facade.dart';
import '../../../../shared/widgets/smart_image.dart';
import 'fortune_card.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/unified_button_enums.dart';

/// 인사이트 결과 카드 - 토스 디자인 시스템 적용
class FortuneResultCard extends ConsumerWidget {
  final Fortune fortune;
  final String fortuneTitle;
  final VoidCallback? onShare;
  final VoidCallback? onRetry;
  final VoidCallback? onSave;
  final bool showScore;
  final bool showLuckyItems;
  final bool showRecommendations;
  final bool showWarnings;
  final Widget? customContent;
  
  const FortuneResultCard({
    super.key,
    required this.fortune,
    required this.fortuneTitle,
    this.onShare,
    this.onRetry,
    this.onSave,
    this.showScore = true,
    this.showLuckyItems = true,
    this.showRecommendations = true,
    this.showWarnings = true,
    this.customContent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // 헤더 - 인사이트 제목과 날짜
          _buildHeader(context, isDark),
          
          // 점수 표시 (옵션)
          if (showScore && fortune.overallScore != null)
            _buildScoreSection(context, isDark)
                .animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

          if (fortune.hexagonScores != null &&
              fortune.hexagonScores!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.lg,
                vertical: DSSpacing.sm + 4,
              ),
              child: FortuneInfographicWidgets.buildRadarChart(
                scores: fortune.hexagonScores!,
                size: 220,
                primaryColor: DSColors.accent,
              ),
            ),

          if (fortune.categories != null && fortune.categories!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.lg,
                vertical: DSSpacing.sm + 4,
              ),
              child: FortuneInfographicWidgets.buildCategoryCards(
                fortune.categories!,
                isDarkMode: isDark,
              ),
            ),
          
          // 메인 운세 내용
          _buildMainContent(context, isDark)
              .animate()
              .fadeIn(duration: 600.ms, delay: 400.ms)
              .slideY(begin: 0.1, end: 0),
          
          // 커스텀 컨텐츠 (옵션)
          if (customContent != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm + 4),
              child: customContent!,
            ),
          
          // 행운 아이템 (옵션)
          if (showLuckyItems && fortune.luckyItems != null && fortune.luckyItems!.isNotEmpty)
            _buildLuckyItemsSection(context, isDark)
                .animate()
                .fadeIn(duration: 600.ms, delay: 600.ms)
                .slideY(begin: 0.1, end: 0),
          
          // 추천 사항 (옵션)
          if (showRecommendations && fortune.recommendations != null && fortune.recommendations!.isNotEmpty)
            _buildRecommendationsSection(context, isDark)
                .animate()
                .fadeIn(duration: 600.ms, delay: 800.ms)
                .slideY(begin: 0.1, end: 0),
          
          // 주의 사항 (옵션)
          if (showWarnings && fortune.warnings != null && fortune.warnings!.isNotEmpty)
            _buildWarningsSection(context, isDark)
                .animate()
                .fadeIn(duration: 600.ms, delay: 1000.ms)
                .slideY(begin: 0.1, end: 0),
          
          // 액션 버튼
          _buildActionButtons(context, ref)
              .animate()
              .fadeIn(duration: 600.ms, delay: 1200.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: DSSpacing.xl + 8),
        ],
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context, bool isDark) {
    final score = fortune.overallScore ?? 70;
    final heroImage = FortuneCardImages.getHeroImage(fortune.type, score);
    final mascotImage = FortuneCardImages.getMascotImage(fortune.type, score);
    final caption = FortuneCardImages.instagramCaptions[fortune.type] ??
        FortuneCardImages.instagramCaptions[fortune.type.replaceAll('_', '-')] ??
        FortuneCardImages.instagramCaptions['default'];
    final summary = fortune.summary ?? fortune.greeting;
    final dateLabel = DateTime.now().toString().split(' ')[0];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DSSpacing.lg,
        DSSpacing.lg,
        DSSpacing.lg,
        DSSpacing.sm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DSRadius.lg),
        child: SizedBox(
          height: 220,
          child: Stack(
            fit: StackFit.expand,
            children: [
              SmartImage(
                path: heroImage,
                fit: BoxFit.cover,
                errorWidget: Container(
                  color: isDark ? DSColors.surfaceDark : DSColors.surface,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: DSSpacing.sm,
                right: DSSpacing.sm,
                child: FortuneActionButtons(
                  contentId: fortune.id,
                  contentType: fortune.type,
                  shareTitle: fortuneTitle,
                  shareContent: fortune.content,
                  iconColor: Colors.white,
                  iconSize: 20,
                ),
              ),
              Positioned(
                left: DSSpacing.md,
                right: DSSpacing.md,
                bottom: DSSpacing.md,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fortuneTitle,
                      style: DSTypography.headingMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.45),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    if (caption != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        caption,
                        style: DSTypography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                    const SizedBox(height: DSSpacing.xs),
                    Row(
                      children: [
                        _buildHeroPill(dateLabel),
                        if (summary != null && summary.isNotEmpty) ...[
                          const SizedBox(width: DSSpacing.xs),
                          Expanded(
                            child: _buildHeroSummary(summary),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (mascotImage != null)
                Positioned(
                  right: DSSpacing.sm,
                  bottom: DSSpacing.sm,
                  child: SmartImage(
                    path: mascotImage,
                    width: 72,
                    height: 72,
                    fit: BoxFit.contain,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(DSRadius.full),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        text,
        style: DSTypography.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildHeroSummary(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(DSRadius.full),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: DSTypography.labelSmall.copyWith(
          color: Colors.white.withValues(alpha: 0.95),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Widget _buildScoreSection(BuildContext context, bool isDark) {
    final score = fortune.overallScore ?? 0;
    final scoreColor = _getScoreColor(score);

    return FortuneCard(
      margin: const EdgeInsets.symmetric(horizontal: DSSpacing.lg, vertical: DSSpacing.sm + 4),
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 80.0,
            lineWidth: 8.0,
            animation: true,
            percent: score / 100,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$score',
                  style: DSTypography.displayMedium.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '점',
                  style: DSTypography.bodyMedium.copyWith(
                    color: isDark ? DSColors.textSecondaryDark : DSColors.textSecondary,
                  ),
                ),
              ],
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: scoreColor,
            backgroundColor: scoreColor.withValues(alpha: isDark ? 0.15 : 0.1),
          ),
          const SizedBox(height: DSSpacing.lg),
          Text(
            _getScoreMessage(score),
            style: DSTypography.headingSmall.copyWith(
              color: scoreColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          // ✅ 퍼센타일 뱃지 표시 (유효한 경우에만)
          if (fortune.isPercentileValid && fortune.percentile != null) ...[
            const SizedBox(height: DSSpacing.sm + 4),
            _buildPercentileBadge(fortune.percentile!, isDark),
          ],
          const SizedBox(height: DSSpacing.sm),
          Text(
            _getScoreDescription(score),
            style: DSTypography.bodySmall.copyWith(
              color: isDark ? DSColors.textSecondaryDark : DSColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 퍼센타일 뱃지 위젯
  Widget _buildPercentileBadge(int percentile, bool isDark) {
    // 상위 %에 따른 색상 및 메시지 설정
    final Color badgeColor;
    final String emoji;

    if (percentile <= 10) {
      badgeColor = DSColors.warning;  // 골드 대신 오렌지 사용
      emoji = '🏆';
    } else if (percentile <= 25) {
      badgeColor = DSColors.success;
      emoji = '⭐';
    } else if (percentile <= 50) {
      badgeColor = DSColors.accent;
      emoji = '✨';
    } else {
      badgeColor = DSColors.warning;
      emoji = '🍀';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: badgeColor.withValues(alpha: isDark ? 0.4 : 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 16), // 예외: 이모지
          ),
          const SizedBox(width: 6),
          Text(
            '오늘 분석 본 사람 중 상위 $percentile%',
            style: DSTypography.labelSmall.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, bool isDark) {
    return FortuneCard(
      title: '오늘의 인사이트',
      margin: const EdgeInsets.symmetric(horizontal: DSSpacing.lg, vertical: DSSpacing.sm + 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            FortuneTextCleaner.clean(fortune.content),
            style: DSTypography.bodyMedium.copyWith(
              color: isDark ? DSColors.textPrimaryDark : DSColors.textPrimary,
              height: 1.8,
            ),
          ),
          if (fortune.description != null) ...[
            const SizedBox(height: DSSpacing.md),
            Container(
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: DSColors.accent.withValues(alpha: isDark ? 0.08 : 0.05),
                borderRadius: BorderRadius.circular(DSRadius.md),
              ),
              child: Text(
                FortuneTextCleaner.clean(fortune.description!),
                style: DSTypography.bodySmall.copyWith(
                  color: DSColors.accent,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildLuckyItemsSection(BuildContext context, bool isDark) {
    final luckyItems = fortune.luckyItems!;
    final visualItems = <Map<String, String>>[];

    final colorValue = luckyItems['color']?.toString();
    if (colorValue != null && colorValue.isNotEmpty) {
      visualItems.add({
        'label': '색상',
        'value': colorValue,
        'icon': FortuneCardImages.getLuckyColorIcon(
          _normalizeLuckyColor(colorValue),
        ),
      });
    }

    final numberValue = luckyItems['number'];
    final number = numberValue is int
        ? numberValue
        : int.tryParse(numberValue?.toString() ?? '');
    if (number != null) {
      visualItems.add({
        'label': '숫자',
        'value': number.toString(),
        'icon': FortuneCardImages.getLuckyNumberIcon(number),
      });
    }

    final directionValue = luckyItems['direction']?.toString();
    if (directionValue != null && directionValue.isNotEmpty) {
      visualItems.add({
        'label': '방향',
        'value': directionValue,
        'icon': FortuneCardImages.getLuckyDirectionIcon(
          _normalizeLuckyDirection(directionValue),
        ),
      });
    }

    final timeValue = luckyItems['time']?.toString();
    if (timeValue != null && timeValue.isNotEmpty) {
      visualItems.add({
        'label': '시간',
        'value': timeValue,
        'icon': FortuneCardImages.getLuckyTimeIcon(
          _normalizeLuckyTime(timeValue),
        ),
      });
    }

    return FortuneCard(
      title: '오늘의 행운 아이템',
      margin: const EdgeInsets.symmetric(horizontal: DSSpacing.lg, vertical: DSSpacing.sm + 4),
      child: Column(
        children: [
          if (visualItems.isNotEmpty) ...[
            Wrap(
              spacing: DSSpacing.sm,
              runSpacing: DSSpacing.sm,
              children: visualItems
                  .map((item) => _buildLuckyVisualItem(
                        label: item['label']!,
                        value: item['value']!,
                        iconPath: item['icon']!,
                        isDark: isDark,
                      ))
                  .toList(),
            ),
            const SizedBox(height: DSSpacing.md),
          ],
          if (luckyItems['color'] != null)
            _buildLuckyItem(
              icon: Icons.palette,
              title: '행운의 색상',
              value: luckyItems['color'],
              color: DSColors.accentSecondary,
              isDark: isDark,
            ),
          if (luckyItems['number'] != null)
            _buildLuckyItem(
              icon: Icons.looks_one,
              title: '행운의 숫자',
              value: luckyItems['number'].toString(),
              color: DSColors.success,
              isDark: isDark,
            ),
          if (luckyItems['direction'] != null)
            _buildLuckyItem(
              icon: Icons.explore,
              title: '행운의 방향',
              value: luckyItems['direction'],
              color: DSColors.accent,
              isDark: isDark,
            ),
          if (luckyItems['time'] != null)
            _buildLuckyItem(
              icon: Icons.schedule,
              title: '행운의 시간',
              value: luckyItems['time'],
              color: DSColors.warning,
              isDark: isDark,
            ),
        ],
      ),
    );
  }
  
  Widget _buildLuckyItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(DSRadius.sm + 2),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: DSSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DSTypography.labelSmall.copyWith(
                    color: isDark ? DSColors.textSecondaryDark : DSColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: DSTypography.bodyMedium.copyWith(
                    color: isDark ? DSColors.textPrimaryDark : DSColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyVisualItem({
    required String label,
    required String value,
    required String iconPath,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark ? DSColors.surfaceDark : DSColors.surface,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: (isDark ? DSColors.borderDark : DSColors.border)
              .withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SmartImage(
            path: iconPath,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: DSSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: DSTypography.labelSmall.copyWith(
                  color: isDark
                      ? DSColors.textSecondaryDark
                      : DSColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: DSTypography.bodySmall.copyWith(
                  color:
                      isDark ? DSColors.textPrimaryDark : DSColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _normalizeLuckyColor(String value) {
    final lower = value.toLowerCase();
    if (lower.contains('red') || lower.contains('빨') || lower.contains('홍')) {
      return 'red';
    }
    if (lower.contains('orange') || lower.contains('주황')) {
      return 'orange';
    }
    if (lower.contains('yellow') || lower.contains('노랑')) {
      return 'yellow';
    }
    if (lower.contains('green') || lower.contains('초록')) {
      return 'green';
    }
    if (lower.contains('blue') || lower.contains('파랑') || lower.contains('청')) {
      return 'blue';
    }
    if (lower.contains('purple') || lower.contains('보라')) {
      return 'purple';
    }
    if (lower.contains('pink') || lower.contains('분홍')) {
      return 'pink';
    }
    if (lower.contains('white') || lower.contains('흰')) {
      return 'white';
    }
    if (lower.contains('black') || lower.contains('검')) {
      return 'black';
    }
    if (lower.contains('gold') || lower.contains('금')) {
      return 'gold';
    }
    if (lower.contains('silver') || lower.contains('은')) {
      return 'silver';
    }
    if (lower.contains('coral') || lower.contains('코랄')) {
      return 'coral';
    }
    return lower;
  }

  String _normalizeLuckyDirection(String value) {
    final lower = value.toLowerCase();
    if ((lower.contains('북') || lower.contains('north')) &&
        (lower.contains('동') || lower.contains('east'))) {
      return 'northeast';
    }
    if ((lower.contains('북') || lower.contains('north')) &&
        (lower.contains('서') || lower.contains('west'))) {
      return 'northwest';
    }
    if ((lower.contains('남') || lower.contains('south')) &&
        (lower.contains('동') || lower.contains('east'))) {
      return 'southeast';
    }
    if ((lower.contains('남') || lower.contains('south')) &&
        (lower.contains('서') || lower.contains('west'))) {
      return 'southwest';
    }
    if (lower.contains('동') || lower.contains('east')) {
      return 'east';
    }
    if (lower.contains('서') || lower.contains('west')) {
      return 'west';
    }
    if (lower.contains('남') || lower.contains('south')) {
      return 'south';
    }
    if (lower.contains('북') || lower.contains('north')) {
      return 'north';
    }
    return lower;
  }

  String _normalizeLuckyTime(String value) {
    final lower = value.toLowerCase();
    if (lower.contains('오전') || lower.contains('아침') || lower.contains('morning')) {
      return 'morning';
    }
    if (lower.contains('오후') || lower.contains('점심') || lower.contains('afternoon')) {
      return 'afternoon';
    }
    if (lower.contains('저녁') || lower.contains('evening')) {
      return 'evening';
    }
    if (lower.contains('밤') || lower.contains('night')) {
      return 'night';
    }
    if (lower.contains('새벽') || lower.contains('dawn')) {
      return 'dawn';
    }
    return lower;
  }
  
  Widget _buildRecommendationsSection(BuildContext context, bool isDark) {
    return FortuneCard(
      title: '추천 사항',
      margin: const EdgeInsets.symmetric(horizontal: DSSpacing.lg, vertical: DSSpacing.sm + 4),
      child: Column(
        children: fortune.recommendations!.map((recommendation) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: DSColors.success,
                  size: 20,
                ),
                const SizedBox(width: DSSpacing.sm + 4),
                Expanded(
                  child: Text(
                    FortuneTextCleaner.clean(recommendation),
                    style: DSTypography.bodySmall.copyWith(
                      color: isDark ? DSColors.textPrimaryDark : DSColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildWarningsSection(BuildContext context, bool isDark) {
    return FortuneCard(
      title: '주의 사항',
      margin: const EdgeInsets.symmetric(horizontal: DSSpacing.lg, vertical: DSSpacing.sm + 4),
      backgroundColor: DSColors.warning.withValues(alpha: isDark ? 0.08 : 0.05),
      child: Column(
        children: fortune.warnings!.map((warning) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber,
                  color: DSColors.warning,
                  size: 20,
                ),
                const SizedBox(width: DSSpacing.sm + 4),
                Expanded(
                  child: Text(
                    FortuneTextCleaner.clean(warning),
                    style: DSTypography.bodySmall.copyWith(
                      color: isDark ? DSColors.textPrimaryDark : DSColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        children: [
          if (onShare != null)
            UnifiedButton(
              text: '공유하기',
              onPressed: () {
                // 공유 액션 햅틱 피드백
                ref.read(fortuneHapticServiceProvider).shareAction();

                if (onShare != null) {
                  onShare!();
                } else {
                  Share.share(
                    '$fortuneTitle\n\n${fortune.content}\n\n인사이트 점수: ${fortune.overallScore}점',
                  );
                }
              },
              style: UnifiedButtonStyle.primary,
              icon: const Icon(Icons.share, size: 20),
              width: double.infinity,
            ),
          if (onRetry != null) ...[
            const SizedBox(height: DSSpacing.sm + 4),
            UnifiedButton.retry(
              onPressed: onRetry,
            ),
          ],
          if (onSave != null) ...[
            const SizedBox(height: DSSpacing.sm + 4),
            UnifiedButton(
              text: '저장하기',
              onPressed: onSave,
              style: UnifiedButtonStyle.secondary,
              icon: const Icon(Icons.bookmark_border, size: 20),
              width: double.infinity,
            ),
          ],
        ],
      ),
    );
  }
  
  Color _getScoreColor(int score) {
    if (score >= 80) return DSColors.success;
    if (score >= 60) return DSColors.accent;
    if (score >= 40) return DSColors.warning;
    return DSColors.error;
  }
  
  String _getScoreMessage(int score) {
    if (score >= 90) return '최상의 하루!';
    if (score >= 80) return '아주 좋은 하루';
    if (score >= 70) return '좋은 하루';
    if (score >= 60) return '무난한 하루';
    if (score >= 50) return '평범한 하루';
    if (score >= 40) return '조심이 필요한 날';
    return '신중한 하루를 보내세요';
  }
  
  String _getScoreDescription(int score) {
    if (score >= 90) return '오늘은 모든 일이 술술 풀리는 최고의 날입니다!';
    if (score >= 80) return '좋은 기운이 가득한 날, 적극적으로 행동해보세요.';
    if (score >= 70) return '전반적으로 순조로운 하루가 될 것입니다.';
    if (score >= 60) return '평온한 하루, 차분하게 일을 진행하세요.';
    if (score >= 50) return '특별할 것 없는 평범한 하루입니다.';
    if (score >= 40) return '조심스럽게 행동하면 무난한 하루가 될 것입니다.';
    return '오늘은 중요한 결정을 미루는 것이 좋겠습니다.';
  }
}
