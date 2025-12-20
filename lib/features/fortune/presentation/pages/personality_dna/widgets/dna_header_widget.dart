import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortune/core/models/personality_dna_model.dart';
import 'package:fortune/core/design_system/components/traditional/hanji_card.dart';
import 'package:fortune/core/design_system/tokens/ds_fortune_colors.dart';

/// 성격DNA 헤더 위젯 - 한국 전통 스타일
///
/// HanjiCard scroll 스타일과 민화 배경을 사용합니다.
class DnaHeaderWidget extends StatelessWidget {
  final PersonalityDNA dna;
  final VoidCallback? onPopularityTapped;

  const DnaHeaderWidget({
    super.key,
    required this.dna,
    this.onPopularityTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return HanjiCard(
      style: HanjiCardStyle.scroll,
      colorScheme: HanjiColorScheme.fortune,
      showSealStamp: true,
      sealText: '性',
      sealSize: 36,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          // 민화 배경 (음양 이미지)
          Positioned(
            right: -10,
            bottom: -10,
            child: Opacity(
              opacity: isDark ? 0.06 : 0.10,
              child: Image.asset(
                'assets/images/minhwa/minhwa_saju_yin_yang.png',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // 메인 콘텐츠
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // 인기도 배지
                if (dna.popularityRank != null) ...[
                  _buildPopularityBadge(isDark),
                  const SizedBox(height: 16),
                ],
                // 이모지
                Text(
                  dna.emoji,
                  style: const TextStyle(fontSize: 56),
                ),
                const SizedBox(height: 16),
                // 타이틀 (GowunBatang)
                Text(
                  dna.title,
                  style: TextStyle(
                    fontFamily: 'GowunBatang',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: DSFortuneColors.getInk(isDark),
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // 설명
                if (dna.description.isNotEmpty)
                  Text(
                    dna.description,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: DSFortuneColors.getInk(isDark).withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 20),
                // DNA 코드 (한지 스타일 컨테이너)
                _buildDnaCodeBadge(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 인기도 배지 (전통 스타일) - 탭하면 랭킹 상세 표시
  Widget _buildPopularityBadge(bool isDark) {
    return GestureDetector(
      onTap: onPopularityTapped != null
          ? () {
              HapticFeedback.lightImpact();
              onPopularityTapped!();
            }
          : null,
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            dna.popularityColor,
            dna.popularityColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: DSFortuneColors.getGold(isDark).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: dna.popularityColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.trending_up,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            dna.popularityText,
            style: const TextStyle(
              fontFamily: 'GowunBatang',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
      ),
    );
  }

  /// DNA 코드 배지 (한지 스타일)
  Widget _buildDnaCodeBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? DSFortuneColors.inkLight.withValues(alpha: 0.1)
            : DSFortuneColors.inkBlack.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? DSFortuneColors.inkLight.withValues(alpha: 0.2)
              : DSFortuneColors.inkBlack.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // DNA 아이콘
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: DSFortuneColors.getGold(isDark).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '🧬',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            dna.dnaCode,
            style: TextStyle(
              fontFamily: 'GowunBatang',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: DSFortuneColors.getInk(isDark),
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
