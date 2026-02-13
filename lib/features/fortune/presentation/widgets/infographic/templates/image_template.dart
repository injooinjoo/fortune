import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/tokens/ds_spacing.dart';
import 'package:fortune/core/design_system/tokens/ds_radius.dart';
import 'package:fortune/core/design_system/theme/ds_extensions.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/infographic_container.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/keyword_tags.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/privacy_shield.dart';

/// 이미지 중심 인포그래픽 템플릿 (템플릿 C)
///
/// 6개 운세 타입에 사용:
/// - tarot (Insight Cards)
/// - talisman (행운 카드)
/// - past-life (전생 분석)
/// - face-reading (Face AI)
/// - dream (꿈 분석)
/// - wish (소원 빌기)
///
/// 레이아웃:
/// - 상단: 메인 이미지/카드
/// - 중간: 키워드/태그
/// - 하단: 해석/메시지
class ImageTemplate extends StatelessWidget {
  const ImageTemplate({
    super.key,
    required this.title,
    required this.imageWidget,
    this.subtitle,
    this.keywords,
    this.message,
    this.footerWidget,
    this.showWatermark = true,
    this.isShareMode = false,
    this.backgroundColor,
  });

  /// 제목
  final String title;

  /// 부제목 (선택)
  final String? subtitle;

  /// 메인 이미지 위젯 (필수)
  final Widget imageWidget;

  /// 키워드 목록 (선택)
  final List<KeywordData>? keywords;

  /// 메시지 (선택)
  final String? message;

  /// 푸터 위젯 (선택)
  final Widget? footerWidget;

  /// 워터마크 표시 여부
  final bool showWatermark;

  /// 공유 모드
  final bool isShareMode;

  /// 배경색 (선택)
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return PrivacyModeProvider(
      isShareMode: isShareMode,
      child: InfographicContainer(
        title: title,
        subtitle: subtitle,
        showWatermark: showWatermark,
        isShareMode: isShareMode,
        backgroundColor: backgroundColor,
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 메인 이미지
          imageWidget,

          // 키워드
          if (keywords != null && keywords!.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            KeywordTags(
              keywords: keywords!,
              style: KeywordTagStyle.hashtag,
              alignment: WrapAlignment.center,
            ),
          ],

          // 메시지
          if (message != null) ...[
            const SizedBox(height: DSSpacing.sm),
            _buildMessage(context),
          ],

          // 푸터
          if (footerWidget != null) ...[
            const SizedBox(height: DSSpacing.sm),
            footerWidget!,
          ],
        ],
      ),
    );
  }

  Widget _buildMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withValues(alpha:0.5),
        borderRadius: DSRadius.mdBorder,
      ),
      child: Text(
        '"$message"',
        style: context.typography.bodyMedium.copyWith(
          color: context.colors.textPrimary,
          fontStyle: FontStyle.italic,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// 타로 카드 템플릿
class TarotImageTemplate extends StatelessWidget {
  const TarotImageTemplate({
    super.key,
    required this.cards,
    this.keywords,
    this.message,
    this.date,
    this.isShareMode = false,
  });

  /// 타로 카드 목록 (1~3장)
  final List<TarotCardData> cards;

  /// 키워드
  final List<KeywordData>? keywords;

  /// 메시지
  final String? message;

  /// 날짜
  final DateTime? date;

  /// 공유 모드
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ImageTemplate(
      title: '오늘의 Insight Cards',
      isShareMode: isShareMode,
      imageWidget: _buildCards(context),
      keywords: keywords,
      message: message,
    );
  }

  Widget _buildCards(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: cards.asMap().entries.map((entry) {
        final index = entry.key;
        final card = entry.value;
        return Padding(
          padding: EdgeInsets.only(
            right: index < cards.length - 1 ? DSSpacing.sm : 0,
          ),
          child: _TarotCard(
            card: card,
            size: cards.length == 1
                ? TarotCardSize.large
                : cards.length == 2
                    ? TarotCardSize.medium
                    : TarotCardSize.small,
          ),
        );
      }).toList(),
    );
  }
}

/// 타로 카드 데이터
class TarotCardData {
  const TarotCardData({
    required this.name,
    required this.image,
    this.position,
    this.isReversed = false,
  });

  /// 카드 이름
  final String name;

  /// 카드 이미지
  final ImageProvider image;

  /// 위치 (과거/현재/미래)
  final String? position;

  /// 역방향 여부
  final bool isReversed;
}

enum TarotCardSize { small, medium, large }

class _TarotCard extends StatelessWidget {
  const _TarotCard({
    required this.card,
    this.size = TarotCardSize.medium,
  });

  final TarotCardData card;
  final TarotCardSize size;

  (double width, double height) _getSize() {
    switch (size) {
      case TarotCardSize.small:
        return (70, 100);
      case TarotCardSize.medium:
        return (90, 130);
      case TarotCardSize.large:
        return (120, 170);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (width, height) = _getSize();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 위치 라벨
        if (card.position != null) ...[
          Text(
            card.position!,
            style: context.typography.labelSmall.copyWith(
              color: context.colors.textTertiary,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: DSSpacing.xxs),
        ],

        // 카드 이미지
        Transform.rotate(
          angle: card.isReversed ? 3.14159 : 0,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image(
                image: card.image,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        const SizedBox(height: DSSpacing.xs),

        // 카드 이름
        Text(
          card.name,
          style: context.typography.labelSmall.copyWith(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),

        // 역방향 표시
        if (card.isReversed)
          Container(
            margin: const EdgeInsets.only(top: DSSpacing.xxs),
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.xs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: context.colors.textTertiary.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '역방향',
              style: context.typography.labelSmall.copyWith(
                color: context.colors.textTertiary,
                fontSize: 9,
              ),
            ),
          ),
      ],
    );
  }
}

/// 꿈 해석 템플릿
class DreamImageTemplate extends StatelessWidget {
  const DreamImageTemplate({
    super.key,
    required this.isGoodDream,
    required this.score,
    required this.keywords,
    this.interpretation,
    this.luckyElements,
    this.date,
    this.isShareMode = false,
  });

  /// 길몽 여부
  final bool isGoodDream;

  /// 점수 (0-100)
  final int score;

  /// 키워드
  final List<String> keywords;

  /// 해석
  final String? interpretation;

  /// 행운 요소
  final List<String>? luckyElements;

  /// 날짜
  final DateTime? date;

  /// 공유 모드
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ImageTemplate(
      title: '꿈 분석 결과',
      isShareMode: isShareMode,
      imageWidget: _buildBadge(context),
      keywords: DreamKeywords.fromSymbols(keywords),
      message: interpretation,
      footerWidget: luckyElements != null ? _buildLuckyElements(context) : null,
    );
  }

  Widget _buildBadge(BuildContext context) {
    final color = isGoodDream ? context.colors.success : context.colors.error;
    final icon = isGoodDream
        ? Icons.wb_sunny_rounded
        : Icons.nights_stay_rounded;
    final label = isGoodDream ? '길몽' : '흉몽';

    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha:0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 48,
            color: color,
          ),
          const SizedBox(height: DSSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.sm,
              vertical: DSSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: DSRadius.smBorder,
            ),
            child: Text(
              label,
              style: context.typography.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            '$score',
            style: context.typography.headingMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyElements(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.accent.withValues(alpha:0.1),
        borderRadius: DSRadius.mdBorder,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 16,
            color: context.colors.accent,
          ),
          const SizedBox(width: DSSpacing.xs),
          Text(
            '오늘의 행운: ',
            style: context.typography.labelMedium.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          Text(
            luckyElements!.join(', '),
            style: context.typography.labelMedium.copyWith(
              color: context.colors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 전생 분석 템플릿
class PastLifeImageTemplate extends StatelessWidget {
  const PastLifeImageTemplate({
    super.key,
    required this.portrait,
    required this.era,
    required this.occupation,
    this.nickname,
    this.story,
    this.presentAdvice,
    this.date,
    this.isShareMode = false,
  });

  /// AI 생성 초상화
  final ImageProvider portrait;

  /// 시대
  final String era;

  /// 신분/직업
  final String occupation;

  /// 별명
  final String? nickname;

  /// 스토리
  final String? story;

  /// 현생 조언
  final String? presentAdvice;

  /// 날짜
  final DateTime? date;

  /// 공유 모드
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ImageTemplate(
      title: '당신의 전생',
      isShareMode: isShareMode,
      imageWidget: _buildPortrait(context),
      message: story,
      footerWidget: presentAdvice != null ? _buildAdvice(context) : null,
    );
  }

  Widget _buildPortrait(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 초상화
        Container(
          width: 140,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: DSRadius.lgBorder,
          ),
          child: ClipRRect(
            borderRadius: DSRadius.lgBorder,
            child: Image(
              image: portrait,
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(height: DSSpacing.md),

        // 시대 + 신분
        Text(
          '$era · $occupation',
          style: context.typography.labelMedium.copyWith(
            color: context.colors.textSecondary,
          ),
        ),

        // 별명
        if (nickname != null) ...[
          const SizedBox(height: DSSpacing.xs),
          Text(
            '"$nickname"',
            style: context.typography.headingSmall.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAdvice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.accent.withValues(alpha:0.1),
        borderRadius: DSRadius.mdBorder,
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 20,
            color: context.colors.accent,
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Text(
              '현생 조언: $presentAdvice',
              style: context.typography.bodySmall.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 소원 빌기 템플릿
class WishImageTemplate extends StatelessWidget {
  const WishImageTemplate({
    super.key,
    required this.achievementLevel,
    required this.message,
    this.missions,
    this.date,
    this.isShareMode = false,
  });

  /// 성취 가능성 (높음/보통/낮음)
  final WishAchievementLevel achievementLevel;

  /// 용의 메시지
  final String message;

  /// 행운 미션 목록
  final List<WishMission>? missions;

  /// 날짜
  final DateTime? date;

  /// 공유 모드
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ImageTemplate(
      title: '🐉 용의 응답',
      isShareMode: isShareMode,
      imageWidget: _buildAchievementBadge(context),
      message: message,
      footerWidget: missions != null ? _buildMissions(context) : null,
    );
  }

  Widget _buildAchievementBadge(BuildContext context) {
    final (label, stars, color) = switch (achievementLevel) {
      WishAchievementLevel.high => ('높음', 4, context.colors.success),
      WishAchievementLevel.medium => ('보통', 3, context.colors.warning),
      WishAchievementLevel.low => ('낮음', 2, context.colors.error),
    };

    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: DSRadius.lgBorder,
        border: Border.all(
          color: color.withValues(alpha:0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '성취 가능성',
            style: context.typography.labelMedium.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            '"$label"',
            style: context.typography.headingMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              return Icon(
                index < stars
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                size: 24,
                color: index < stars ? color : context.colors.textTertiary,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMissions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withValues(alpha:0.5),
        borderRadius: DSRadius.mdBorder,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: context.colors.accent,
              ),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '행운 미션',
                style: context.typography.labelMedium.copyWith(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          ...missions!.map((mission) {
            return Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.xs),
              child: Row(
                children: [
                  Icon(
                    mission.icon ?? Icons.check_circle_outline_rounded,
                    size: 16,
                    color: context.colors.accent,
                  ),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      mission.description,
                      style: context.typography.bodySmall.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

enum WishAchievementLevel { high, medium, low }

class WishMission {
  const WishMission({
    required this.description,
    this.icon,
  });

  final String description;
  final IconData? icon;
}

/// Face AI 템플릿
class FaceReadingImageTemplate extends StatelessWidget {
  const FaceReadingImageTemplate({
    super.key,
    required this.faceImage,
    required this.score,
    this.percentile,
    this.insights,
    this.emotionAnalysis,
    this.celebrityMatch,
    this.celebrityMatchPercent,
    this.date,
    this.isShareMode = false,
  });

  /// 얼굴 이미지 (선택, 공유 모드에서 숨김)
  final ImageProvider? faceImage;

  /// 종합 점수
  final int score;

  /// 상위 퍼센타일
  final int? percentile;

  /// Top 인사이트
  final List<FaceInsight>? insights;

  /// 감정 분석
  final Map<String, int>? emotionAnalysis;

  /// 닮은꼴 연예인
  final String? celebrityMatch;

  /// 닮은꼴 일치율
  final int? celebrityMatchPercent;

  /// 날짜
  final DateTime? date;

  /// 공유 모드
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ImageTemplate(
      title: 'Face AI 분석 결과',
      isShareMode: isShareMode,
      imageWidget: _buildFaceAnalysis(context),
      footerWidget: _buildFooter(context),
    );
  }

  Widget _buildFaceAnalysis(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 얼굴 이미지
        Expanded(
          child: PrivacyShield(
            isShielded: isShareMode,
            style: PrivacyStyle.replace,
            placeholder: Container(
              height: 120,
              decoration: BoxDecoration(
                color: context.colors.surfaceSecondary,
                borderRadius: DSRadius.mdBorder,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_rounded,
                      size: 48,
                      color: context.colors.textTertiary,
                    ),
                    const SizedBox(height: DSSpacing.xs),
                    Text(
                      '사진 비공개',
                      style: context.typography.labelSmall.copyWith(
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            child: faceImage != null
                ? Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: DSRadius.mdBorder,
                    ),
                    child: ClipRRect(
                      borderRadius: DSRadius.mdBorder,
                      child: Image(
                        image: faceImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),

        const SizedBox(width: DSSpacing.md),

        // 점수 - 컴팩트 레이아웃
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.sm,
            vertical: DSSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: context.colors.surfaceSecondary.withValues(alpha:0.5),
            borderRadius: DSRadius.mdBorder,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '종합',
                style: context.typography.labelSmall.copyWith(
                  color: context.colors.textTertiary,
                  fontSize: 10,
                ),
              ),
              Text(
                '$score',
                style: context.typography.headingMedium.copyWith(
                  color: context.colors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (percentile != null)
                Text(
                  '상위 $percentile%',
                  style: context.typography.labelSmall.copyWith(
                    color: context.colors.success,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 인사이트
        if (insights != null && insights!.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(DSSpacing.md),
            decoration: BoxDecoration(
              color: context.colors.surfaceSecondary.withValues(alpha:0.5),
              borderRadius: DSRadius.mdBorder,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: insights!.map((insight) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        insight.icon,
                        size: 16,
                        color: insight.color ?? context.colors.accent,
                      ),
                      const SizedBox(width: DSSpacing.xs),
                      Text(
                        insight.label,
                        style: context.typography.labelSmall.copyWith(
                          color: context.colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: DSSpacing.xs),
                      Expanded(
                        child: Text(
                          '${insight.part} · ${insight.description}',
                          style: context.typography.labelSmall.copyWith(
                            color: context.colors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

        // 감정 분석
        if (emotionAnalysis != null && emotionAnalysis!.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          Container(
            padding: const EdgeInsets.all(DSSpacing.md),
            decoration: BoxDecoration(
              color: context.colors.surfaceSecondary.withValues(alpha:0.5),
              borderRadius: DSRadius.mdBorder,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: emotionAnalysis!.entries.map((e) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      e.key,
                      style: context.typography.labelSmall.copyWith(
                        color: context.colors.textTertiary,
                      ),
                    ),
                    Text(
                      '${e.value}%',
                      style: context.typography.labelMedium.copyWith(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],

        // 닮은꼴
        if (celebrityMatch != null) ...[
          const SizedBox(height: DSSpacing.sm),
          Container(
            padding: const EdgeInsets.all(DSSpacing.sm),
            decoration: BoxDecoration(
              color: context.colors.accent.withValues(alpha:0.1),
              borderRadius: DSRadius.smBorder,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: context.colors.accent,
                ),
                const SizedBox(width: DSSpacing.xs),
                Flexible(
                  child: Text(
                    '닮은꼴: $celebrityMatch',
                    style: context.typography.labelMedium.copyWith(
                      color: context.colors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (celebrityMatchPercent != null) ...[
                  Text(
                    ' ($celebrityMatchPercent% 일치)',
                    style: context.typography.labelSmall.copyWith(
                      color: context.colors.accent,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class FaceInsight {
  const FaceInsight({
    required this.label,
    required this.part,
    required this.description,
    required this.icon,
    this.color,
  });

  /// 라벨 (최고, 강점, 주의)
  final String label;

  /// 부위 (눈, 코, 입)
  final String part;

  /// 설명
  final String description;

  /// 아이콘
  final IconData icon;

  /// 색상
  final Color? color;
}

/// 부적/행운 카드 템플릿
class TalismanImageTemplate extends StatelessWidget {
  const TalismanImageTemplate({
    super.key,
    required this.cardImage,
    this.cardName,
    this.blessing,
    this.date,
    this.isShareMode = false,
  });

  /// 카드 이미지
  final ImageProvider cardImage;

  /// 카드 이름
  final String? cardName;

  /// 축복 메시지
  final String? blessing;

  /// 날짜
  final DateTime? date;

  /// 공유 모드
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ImageTemplate(
      title: '오늘의 행운 카드',
      isShareMode: isShareMode,
      imageWidget: _buildCard(context),
      message: blessing,
    );
  }

  Widget _buildCard(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 카드 이미지
        Container(
          width: 160,
          height: 220,
          decoration: BoxDecoration(
            borderRadius: DSRadius.lgBorder,
            boxShadow: [
              BoxShadow(
                color: context.colors.accent.withValues(alpha:0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: DSRadius.lgBorder,
            child: Image(
              image: cardImage,
              fit: BoxFit.cover,
            ),
          ),
        ),

        // 카드 이름
        if (cardName != null) ...[
          const SizedBox(height: DSSpacing.md),
          Text(
            cardName!,
            style: context.typography.headingSmall.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
