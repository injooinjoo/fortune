import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/utils/fortune_text_cleaner.dart';
import '../../../../domain/entities/fortune.dart';
import 'fortune_card.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/unified_button_enums.dart';

/// 운세 결과 카드 - 토스 디자인 시스템 적용
class FortuneResultCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // 헤더 - 운세 제목과 날짜
          _buildHeader(context, isDark),
          
          // 점수 표시 (옵션)
          if (showScore && fortune.overallScore != null)
            _buildScoreSection(context, isDark)
                .animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
          
          // 메인 운세 내용
          _buildMainContent(context, isDark)
              .animate()
              .fadeIn(duration: 600.ms, delay: 400.ms)
              .slideY(begin: 0.1, end: 0),
          
          // 커스텀 컨텐츠 (옵션)
          if (customContent != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
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
          _buildActionButtons(context)
              .animate()
              .fadeIn(duration: 600.ms, delay: 1200.ms)
              .slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            fortuneTitle,
            style: DSTypography.headingMedium.copyWith(
              color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            DateTime.now().toString().split(' ')[0],
            style: DSTypography.bodySmall.copyWith(
              color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildScoreSection(BuildContext context, bool isDark) {
    final score = fortune.overallScore ?? 0;
    final scoreColor = _getScoreColor(score);
    
    return FortuneCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(24),
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
                    color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
                  ),
                ),
              ],
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: scoreColor,
            backgroundColor: scoreColor.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 20),
          Text(
            _getScoreMessage(score),
            style: DSTypography.headingSmall.copyWith(
              color: scoreColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          // ✅ 퍼센타일 뱃지 표시 (유효한 경우에만)
          if (fortune.isPercentileValid && fortune.percentile != null) ...[
            const SizedBox(height: 12),
            _buildPercentileBadge(fortune.percentile!, isDark),
          ],
          const SizedBox(height: 8),
          Text(
            _getScoreDescription(score),
            style: DSTypography.bodySmall.copyWith(
              color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 6),
          Text(
            '오늘 운세 본 사람 중 상위 $percentile%',
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
      title: '오늘의 운세',
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            FortuneTextCleaner.clean(fortune.content),
            style: DSTypography.bodyMedium.copyWith(
              color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
              height: 1.8,
            ),
          ),
          if (fortune.description != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DSColors.accent.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
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
    
    return FortuneCard(
      title: '오늘의 행운 아이템',
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DSTypography.labelSmall.copyWith(
                    color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: DSTypography.bodyMedium.copyWith(
                    color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
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
  
  Widget _buildRecommendationsSection(BuildContext context, bool isDark) {
    return FortuneCard(
      title: '추천 사항',
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: fortune.recommendations!.map((recommendation) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  color: DSColors.success,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    FortuneTextCleaner.clean(recommendation),
                    style: DSTypography.bodySmall.copyWith(
                      color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      backgroundColor: DSColors.warning.withValues(alpha: 0.05),
      child: Column(
        children: fortune.warnings!.map((warning) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber,
                  color: DSColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    FortuneTextCleaner.clean(warning),
                    style: DSTypography.bodySmall.copyWith(
                      color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
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
  
  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (onShare != null)
            UnifiedButton(
              text: '공유하기',
              onPressed: () {
                if (onShare != null) {
                  onShare!();
                } else {
                  Share.share(
                    '$fortuneTitle\n\n${fortune.content}\n\n운세 점수: ${fortune.overallScore}점',
                  );
                }
              },
              style: UnifiedButtonStyle.primary,
              icon: const Icon(Icons.share, size: 20),
              width: double.infinity,
            ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            UnifiedButton.retry(
              onPressed: onRetry,
            ),
          ],
          if (onSave != null) ...[
            const SizedBox(height: 12),
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
    if (score >= 90) return '최상의 운세!';
    if (score >= 80) return '아주 좋은 운세';
    if (score >= 70) return '좋은 운세';
    if (score >= 60) return '무난한 운세';
    if (score >= 50) return '평범한 운세';
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