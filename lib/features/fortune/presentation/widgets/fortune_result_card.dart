import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/design_system/components/traditional/seal_stamp_widget.dart';
import '../../../../core/constants/fortune_card_images.dart';
import '../../../../core/utils/fortune_text_cleaner.dart';
import '../../../../core/services/fortune_haptic_service.dart';
import '../../../../core/widgets/fortune_action_buttons.dart';
import '../../../../domain/entities/fortune.dart';
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
    final isDark = context.isDark;

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

          // 헥사곤 차트 및 카테고리 카드 제거 - 동양화 스타일 단순화

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
          if (showLuckyItems &&
              fortune.luckyItems != null &&
              fortune.luckyItems!.isNotEmpty)
            _buildLuckyItemsSection(context, isDark)
                .animate()
                .fadeIn(duration: 600.ms, delay: 600.ms)
                .slideY(begin: 0.1, end: 0),

          // 추천 사항 (옵션)
          if (showRecommendations &&
              fortune.recommendations != null &&
              fortune.recommendations!.isNotEmpty)
            _buildRecommendationsSection(context, isDark)
                .animate()
                .fadeIn(duration: 600.ms, delay: 800.ms)
                .slideY(begin: 0.1, end: 0),

          // 주의 사항 (옵션)
          if (showWarnings &&
              fortune.warnings != null &&
              fortune.warnings!.isNotEmpty)
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
    final colors = context.colors;
    final score = fortune.overallScore ?? 70;
    final heroImage = FortuneCardImages.getHeroImage(fortune.type, score);
    final mascotImage = FortuneCardImages.getMascotImage(fortune.type, score);
    final caption = FortuneCardImages.instagramCaptions[fortune.type] ??
        FortuneCardImages
            .instagramCaptions[fortune.type.replaceAll('_', '-')] ??
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
                  color: colors.surface,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors.background.withValues(alpha: 0.15),
                      colors.background.withValues(alpha: 0.65),
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
                  iconColor: colors.textPrimary,
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
                      style: context.headingMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          Shadow(
                            color: colors.background.withValues(alpha: 0.45),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    if (caption != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        caption,
                        style: context.bodySmall.copyWith(
                          color: colors.textPrimary.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                    const SizedBox(height: DSSpacing.xs),
                    Row(
                      children: [
                        _buildHeroPill(context, dateLabel),
                        if (summary != null && summary.isNotEmpty) ...[
                          const SizedBox(width: DSSpacing.xs),
                          Expanded(
                            child: _buildHeroSummary(context, summary),
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

  Widget _buildHeroPill(BuildContext context, String text) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(DSRadius.full),
        border: Border.all(
          color: colors.surface.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        text,
        style: context.labelSmall.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildHeroSummary(BuildContext context, String text) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(DSRadius.full),
        border: Border.all(
          color: colors.surface.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.labelSmall.copyWith(
          color: colors.textPrimary.withValues(alpha: 0.95),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 점수 섹션 - 낙관(도장) 스타일
  /// 동양화 디자인: 붉은 인장 안에 점수 표시
  Widget _buildScoreSection(BuildContext context, bool isDark) {
    final score = fortune.overallScore ?? 0;
    final meokColor = context.colors.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.lg,
        vertical: DSSpacing.md,
      ),
      child: Column(
        children: [
          // 낙관 도장 스타일 점수
          SealStampWidget(
            text: '$score',
            shape: SealStampShape.circle,
            colorScheme: SealStampColorScheme.vermilion,
            size: SealStampSize.xlarge,
            animated: true,
            showInkBleed: true,
            filled: false,
            borderWidth: 2.5,
          ),
          const SizedBox(height: DSSpacing.md),
          // 점수 메시지 - 먹색 서예체
          Text(
            _getScoreMessage(score),
            style: context.headingSmall.copyWith(
              color: meokColor.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          // 점수 설명 - 옅은 먹색
          Text(
            _getScoreDescription(score),
            style: context.bodySmall.copyWith(
              color: meokColor.withValues(alpha: 0.6),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 메인 본문 섹션 - 동양화 스타일
  /// 배경 박스 제거, 먹색 텍스트로 통일
  Widget _buildMainContent(BuildContext context, bool isDark) {
    final meokColor = context.colors.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.lg,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더 - 먹 세로선 스타일
          _buildSectionHeader(context, '오늘의 인사이트', meokColor),
          const SizedBox(height: DSSpacing.md),
          // 본문 - 먹색, 여유로운 줄간격
          Text(
            FortuneTextCleaner.clean(fortune.content),
            style: context.bodyMedium.copyWith(
              color: meokColor.withValues(alpha: 0.85),
              height: 1.9,
            ),
          ),
          if (fortune.description != null) ...[
            const SizedBox(height: DSSpacing.lg),
            // 먹선 구분자
            Container(
              height: 1,
              color: meokColor.withValues(alpha: 0.1),
            ),
            const SizedBox(height: DSSpacing.lg),
            // description - 배경 없이 옅은 먹색 텍스트만
            Text(
              FortuneTextCleaner.clean(fortune.description!),
              style: context.bodySmall.copyWith(
                color: meokColor.withValues(alpha: 0.65),
                height: 1.7,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 섹션 헤더 - 먹 세로선 스타일
  Widget _buildSectionHeader(
      BuildContext context, String title, Color meokColor) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: meokColor.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        const SizedBox(width: DSSpacing.sm),
        Text(
          title,
          style: context.headingSmall.copyWith(
            color: meokColor.withValues(alpha: 0.85),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 행운 아이템 섹션 - 동양화 스타일
  /// 개별 색상 제거, 먹색으로 통일
  Widget _buildLuckyItemsSection(BuildContext context, bool isDark) {
    final luckyItems = fortune.luckyItems!;
    final meokColor = context.colors.textPrimary;
    final items = <_LuckyItemData>[];

    // 색상
    final colorValue = luckyItems['color']?.toString();
    if (colorValue != null && colorValue.isNotEmpty) {
      items.add(_LuckyItemData(
        label: '색상',
        value: colorValue,
        icon: Icons.circle,
        isColor: true,
        colorHex: _getColorFromName(colorValue),
      ));
    }

    // 숫자
    final numberValue = luckyItems['number'];
    final number = numberValue is int
        ? numberValue
        : int.tryParse(numberValue?.toString() ?? '');
    if (number != null) {
      items.add(_LuckyItemData(
        label: '숫자',
        value: number.toString(),
        icon: Icons.tag,
      ));
    }

    // 방향
    final directionValue = luckyItems['direction']?.toString();
    if (directionValue != null && directionValue.isNotEmpty) {
      items.add(_LuckyItemData(
        label: '방향',
        value: directionValue,
        icon: Icons.explore_outlined,
      ));
    }

    // 시간
    final timeValue = luckyItems['time']?.toString();
    if (timeValue != null && timeValue.isNotEmpty) {
      items.add(_LuckyItemData(
        label: '시간',
        value: timeValue,
        icon: Icons.schedule_outlined,
      ));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.lg,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          _buildSectionHeader(context, '행운 아이템', meokColor),
          const SizedBox(height: DSSpacing.md),
          // 행운 아이템 - 가로 Wrap
          Wrap(
            spacing: DSSpacing.sm,
            runSpacing: DSSpacing.sm,
            children: items
                .map((item) => _buildSimpleLuckyItem(
                      context: context,
                      item: item,
                      meokColor: meokColor,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  /// 단순화된 행운 아이템 칩
  Widget _buildSimpleLuckyItem({
    required BuildContext context,
    required _LuckyItemData item,
    required Color meokColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(DSRadius.sm),
        border: Border.all(
          color: meokColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 색상 타입: 원형 컬러칩
          if (item.isColor && item.colorHex != null)
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: item.colorHex,
                shape: BoxShape.circle,
                border: Border.all(
                  color: meokColor.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
            )
          else
            Icon(
              item.icon,
              size: 14,
              color: meokColor.withValues(alpha: 0.5),
            ),
          const SizedBox(width: DSSpacing.xs),
          // 라벨과 값 - 먹색
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.label,
                style: context.labelSmall.copyWith(
                  fontSize: 10,
                  color: meokColor.withValues(alpha: 0.5),
                ),
              ),
              Text(
                item.value,
                style: context.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                  color: meokColor.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 색상 이름에서 Color 추출
  Color? _getColorFromName(String colorName) {
    final normalized = colorName.toLowerCase().trim();
    const colorMap = {
      '파란색': DSColors.info,
      '파랑': DSColors.info,
      '빨간색': DSColors.error,
      '빨강': DSColors.error,
      '노란색': DSColors.warning,
      '노랑': DSColors.warning,
      '초록색': DSColors.success,
      '초록': DSColors.success,
      '보라색': DSColors.accentSecondary,
      '보라': DSColors.accentSecondary,
      '분홍색': DSColors.accentSecondary,
      '분홍': DSColors.accentSecondary,
      '주황색': Color(0xFFF97316),
      '주황': Color(0xFFF97316),
      '흰색': Color(0xFFF5F5F5),
      '흰': Color(0xFFF5F5F5),
      '검정색': Color(0xFF1F2937),
      '검정': Color(0xFF1F2937),
      '회색': DSColors.textSecondary,
      '갈색': Color(0xFF92400E),
    };
    return colorMap[normalized];
  }

  Widget _buildRecommendationsSection(BuildContext context, bool isDark) {
    return FortuneCard(
      title: '추천 사항',
      margin: const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg, vertical: DSSpacing.sm + 4),
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
                    style: context.bodySmall.copyWith(
                      color: isDark
                          ? DSColors.textPrimaryDark
                          : DSColors.textPrimary,
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
      margin: const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg, vertical: DSSpacing.sm + 4),
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
                    style: context.bodySmall.copyWith(
                      color: isDark
                          ? DSColors.textPrimaryDark
                          : DSColors.textPrimary,
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

/// 행운 아이템 데이터 클래스 (동양화 스타일용)
class _LuckyItemData {
  final String label;
  final String value;
  final IconData icon;
  final bool isColor;
  final Color? colorHex;

  const _LuckyItemData({
    required this.label,
    required this.value,
    required this.icon,
    this.isColor = false,
    this.colorHex,
  });
}
