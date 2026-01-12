import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../constants/fortune_card_images.dart';
import '../theme/typography_unified.dart';

/// 프리미엄 운세 결과 히어로 섹션
/// SliverAppBar를 사용하여 스크롤 시 축소되는 효과를 제공하며,
/// 점수, 마스코트, 요약 텍스트를 포함합니다.
class FortuneHeroSection extends StatelessWidget {
  final String fortuneType;
  final int score;
  final String summary;
  final List<String>? hashtags;
  final VoidCallback? onBackPressed;
  final Widget? bottom;

  const FortuneHeroSection({
    super.key,
    required this.fortuneType,
    required this.score,
    required this.summary,
    this.hashtags,
    this.onBackPressed,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final heroImage = FortuneCardImages.getHeroImage(fortuneType, score);
    final mascotImage = FortuneCardImages.getMascotImage(fortuneType, score);
    final scoreColor = _getScoreColor(score);
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      stretch: true,
      backgroundColor:
          isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F0E6),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
        ),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // 히어로 배경 이미지 (AI 생성 이미지)
            Image.asset(
              heroImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // 에셋이 없을 경우 그라데이션으로 대체
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF2C2C2C), const Color(0xFF000000)]
                          : [const Color(0xFFF5F0E6), const Color(0xFFE5DED0)],
                    ),
                  ),
                );
              },
            ),

            // 하단 그라데이션 오버레이 (텍스트 가독성 확보)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // 콘텐츠 레이아웃
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 마스코트 & 점수 행
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // 마스코트 캐릭터
                        if (mascotImage != null)
                          Expanded(
                            flex: 5,
                            child: Hero(
                              tag: 'fortune_mascot_$fortuneType',
                              child: Image.asset(
                                mascotImage,
                                height: 100,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const SizedBox(height: 100),
                              ),
                            ),
                          ),
                        const Spacer(),
                        // 원형 점수 인디케이터
                        Expanded(
                          flex: 4,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularPercentIndicator(
                                radius: 28.0,
                                lineWidth: 5.0,
                                animation: true,
                                percent: score / 100,
                                center: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$score',
                                      style: context.displaySmall.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        height: 1.0,
                                      ),
                                    ),
                                    Text(
                                      '점',
                                      style: context.bodySmall.copyWith(
                                        color:
                                            Colors.white.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                                circularStrokeCap: CircularStrokeCap.round,
                                progressColor: scoreColor,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.2),
                              ),
                              const SizedBox(height: 6),
                              _ScoreBadge(score: score),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 운세 요약 문구
                    Text(
                      summary,
                      textAlign: TextAlign.center,
                      style: context.heading1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 해시태그 목록
                    if (hashtags != null && hashtags!.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: hashtags!
                            .map((tag) => _HashtagChip(label: tag))
                            .toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottom: bottom != null
          ? PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: bottom!,
            )
          : null,
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return const Color(0xFFFFD700); // Gold (최상)
    if (score >= 70) return const Color(0xFF4ADE80); // Green (좋음)
    if (score >= 40) return const Color(0xFFFACC15); // Yellow (보통)
    return const Color(0xFFF87171); // Red (주의)
  }
}

/// 점수 등급 뱃지
class _ScoreBadge extends StatelessWidget {
  final int score;

  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;

    if (score >= 90) {
      label = '운수대통';
      color = const Color(0xFFFFD700);
    } else if (score >= 70) {
      label = '운세좋음';
      color = const Color(0xFF4ADE80);
    } else if (score >= 40) {
      label = '평범한운';
      color = const Color(0xFFFACC15);
    } else {
      label = '신중필요';
      color = const Color(0xFFF87171);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: context.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// 해시태그 칩
class _HashtagChip extends StatelessWidget {
  final String label;

  const _HashtagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(
        '#$label',
        style: context.bodySmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
