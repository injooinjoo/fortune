import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../domain/entities/fortune.dart';
import 'fortune_card.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/unified_button_enums.dart';

/// 반려동물 운세 결과 카드 - 토스 디자인 시스템 적용
class PetFortuneResultCard extends StatelessWidget {
  final Fortune fortune;
  final String petName;
  final String petSpecies;
  final int petAge;
  final VoidCallback? onShare;
  final VoidCallback? onRetry;
  final VoidCallback? onSave;
  
  const PetFortuneResultCard({
    super.key,
    required this.fortune,
    required this.petName,
    required this.petSpecies,
    required this.petAge,
    this.onShare,
    this.onRetry,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Extract pet-specific data from fortune
    final petInfo = fortune.additionalInfo?['pet_info'] ?? {};
    final healthFortune = fortune.additionalInfo?['health_fortune'] ?? {};
    final activityFortune = fortune.additionalInfo?['activity_fortune'] ?? {};
    final emotionalState = fortune.additionalInfo?['emotional_state'] ?? {};
    final specialEvents = fortune.additionalInfo?['special_events'] ?? {};
    final carePoints = fortune.additionalInfo?['care_points'] ?? [];
    final luckyItems = fortune.additionalInfo?['lucky_items'] ?? {};
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // 헤더 - 반려동물 정보
          _buildPetHeader(context, isDark, petInfo),
          
          // 메인 점수 카드
          _buildMainScoreCard(context, isDark)
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
          
          // 건강 운세 카드
          if (healthFortune.isNotEmpty)
            _buildHealthCard(context, isDark, healthFortune)
                .animate()
                .fadeIn(duration: 600.ms, delay: 400.ms)
                .slideY(begin: 0.1, end: 0),
          
          // 활동 운세 카드
          if (activityFortune.isNotEmpty)
            _buildActivityCard(context, isDark, activityFortune)
                .animate()
                .fadeIn(duration: 600.ms, delay: 600.ms)
                .slideY(begin: 0.1, end: 0),
          
          // 감정 상태 카드
          if (emotionalState.isNotEmpty)
            _buildEmotionalCard(context, isDark, emotionalState)
                .animate()
                .fadeIn(duration: 600.ms, delay: 800.ms)
                .slideY(begin: 0.1, end: 0),
          
          // 특별 이벤트 카드
          if (specialEvents.isNotEmpty)
            _buildSpecialEventsCard(context, isDark, specialEvents)
                .animate()
                .fadeIn(duration: 600.ms, delay: 1000.ms)
                .slideY(begin: 0.1, end: 0),
          
          // 케어 포인트 카드
          if (carePoints.isNotEmpty)
            _buildCarePointsCard(context, isDark, carePoints)
                .animate()
                .fadeIn(duration: 600.ms, delay: 1200.ms)
                .slideY(begin: 0.1, end: 0),
          
          // 행운 아이템 카드
          if (luckyItems.isNotEmpty)
            _buildLuckyItemsCard(context, isDark, luckyItems)
                .animate()
                .fadeIn(duration: 600.ms, delay: 1400.ms)
                .slideY(begin: 0.1, end: 0),
          
          // 액션 버튼
          _buildActionButtons(context)
              .animate()
              .fadeIn(duration: 600.ms, delay: 1600.ms)
              .slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
  
  Widget _buildPetHeader(BuildContext context, bool isDark, Map<String, dynamic> petInfo) {
    final emoji = petInfo['emoji'] ?? '🐾';
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            emoji,
            style: context.displayLarge,
          ),
          SizedBox(height: 12),
          Text(
            '$petName의 오늘 운세',
            style: context.heading1.copyWith(
              color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: DSColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$petSpecies • $petAge살',
              style: context.bodySmall.copyWith(
                color: DSColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMainScoreCard(BuildContext context, bool isDark) {
    final score = fortune.overallScore ?? 0;
    final scoreColor = _getScoreColor(score);
    final compatibilityResult = fortune.additionalInfo?['compatibility_result'] ?? {};
    
    return FortuneCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 90.0,
            lineWidth: 10.0,
            animation: true,
            percent: score / 100,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$score',
                  style: context.displayMedium.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '점',
                  style: context.bodyMedium.copyWith(
                    color: isDark ? DSColors.textTertiary : DSColors.textSecondary,
                  ),
                ),
              ],
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: scoreColor,
            backgroundColor: scoreColor.withValues(alpha: 0.1),
          ),
          SizedBox(height: 20),
          Text(
            compatibilityResult['level'] ?? '좋은 궁합',
            style: context.heading2.copyWith(
              color: scoreColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Text(
            compatibilityResult['message'] ?? fortune.content,
            style: context.bodySmall.copyWith(
              color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          if (compatibilityResult['advice'] != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DSColors.accent.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: DSColors.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      compatibilityResult['advice'],
                      style: context.bodySmall.copyWith(
                        color: DSColors.accent,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildHealthCard(BuildContext context, bool isDark, Map<String, dynamic> healthFortune) {
    final scores = healthFortune['scores'] ?? {};
    
    return FortuneCard(
      title: '🏥 건강 운세',
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          // 건강 지표
          _buildHealthIndicator(context, '에너지', scores['energy'] ?? 0, DSColors.success, isDark),
          _buildHealthIndicator(context, '식욕', scores['appetite'] ?? 0, DSColors.warning, isDark),
          _buildHealthIndicator(context, '기분', scores['mood'] ?? 0, DSColors.accent, isDark),
          _buildHealthIndicator(context, '활동성', scores['activity'] ?? 0, DSColors.accentSecondary, isDark),
          
          const SizedBox(height: 16),
          
          // 메인 조언
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DSColors.success.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.health_and_safety,
                  color: DSColors.success,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    healthFortune['mainAdvice'] ?? '',
                    style: context.bodySmall.copyWith(
                      color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 체크 포인트
          if (healthFortune['checkPoints'] != null) ...[
            const SizedBox(height: 12),
            ...((healthFortune['checkPoints'] as List).map((point) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: DSColors.textTertiary,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      point.toString(),
                      style: context.labelSmall.copyWith(
                        color: isDark ? DSColors.textTertiary : DSColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList()),
          ],
        ],
      ),
    );
  }
  
  Widget _buildHealthIndicator(BuildContext context, String label, int score, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: context.labelSmall.copyWith(
                color: isDark ? DSColors.textTertiary : DSColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LinearPercentIndicator(
              lineHeight: 8.0,
              percent: score / 100,
              backgroundColor: color.withValues(alpha: 0.1),
              progressColor: color,
              barRadius: const Radius.circular(4),
              padding: EdgeInsets.zero,
            ),
          ),
          SizedBox(width: 12),
          Text(
            '$score',
            style: context.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityCard(BuildContext context, bool isDark, Map<String, dynamic> activityFortune) {
    return FortuneCard(
      title: '🎾 활동 운세',
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          // 추천 활동
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DSColors.accentSecondary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: DSColors.accentSecondary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${activityFortune['bestTime'] ?? '지금'} 추천',
                      style: context.labelSmall.copyWith(
                        color: DSColors.accentSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  activityFortune['recommended'] ?? '',
                  style: context.bodyMedium.copyWith(
                    color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          
          // 특별 활동
          if (activityFortune['special'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    DSColors.accent.withValues(alpha: 0.05),
                    DSColors.accentSecondary.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    color: DSColors.warning,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      activityFortune['special'],
                      style: context.bodySmall.copyWith(
                        color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildEmotionalCard(BuildContext context, bool isDark, Map<String, dynamic> emotionalState) {
    final moodScore = emotionalState['score'] ?? 0;
    final moodColor = _getScoreColor(moodScore);
    
    return FortuneCard(
      title: '💝 감정 상태',
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: moodColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$moodScore',
                    style: context.heading2.copyWith(
                      color: moodColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '오늘의 감정: ${emotionalState['primary'] ?? '평온한'}',
                      style: context.bodyMedium.copyWith(
                        color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      emotionalState['advice'] ?? '',
                      style: context.labelSmall.copyWith(
                        color: isDark ? DSColors.textTertiary : DSColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSpecialEventsCard(BuildContext context, bool isDark, Map<String, dynamic> specialEvents) {
    return FortuneCard(
      title: '✨ 특별 이벤트 적합도',
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          if (specialEvents['grooming'] != null)
            _buildEventItem(context, '미용/목욕', specialEvents['grooming'], Icons.shower, isDark),
          if (specialEvents['vetVisit'] != null)
            _buildEventItem(context, '병원 방문', specialEvents['vetVisit'], Icons.local_hospital, isDark),
          if (specialEvents['training'] != null)
            _buildEventItem(context, '훈련/교육', specialEvents['training'], Icons.school, isDark),
          if (specialEvents['socializing'] != null)
            _buildEventItem(context, '사회화', specialEvents['socializing'], Icons.people, isDark),
        ],
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, String label, Map<String, dynamic> event, IconData icon, bool isDark) {
    final score = event['score'] ?? 0;
    final color = _getScoreColor(score);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: context.bodySmall.copyWith(
                        color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$score점',
                        style: context.labelSmall.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  event['advice'] ?? '',
                  style: context.labelSmall.copyWith(
                    color: isDark ? DSColors.textTertiary : DSColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCarePointsCard(BuildContext context, bool isDark, List<dynamic> carePoints) {
    return FortuneCard(
      title: '💡 오늘의 케어 포인트',
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      backgroundColor: DSColors.warning.withValues(alpha: 0.03),
      child: Column(
        children: carePoints.map((point) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.pets,
                color: DSColors.warning,
                size: 16,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  point.toString(),
                  style: context.bodySmall.copyWith(
                    color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }
  
  Widget _buildLuckyItemsCard(BuildContext context, bool isDark, Map<String, dynamic> luckyItems) {
    return FortuneCard(
      title: '🍀 오늘의 행운 아이템',
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          _buildLuckyItem(context, '색상', luckyItems['color'], Icons.palette, DSColors.accentSecondary, isDark),
          _buildLuckyItem(context, '아이템', luckyItems['item'], Icons.shopping_bag, DSColors.accent, isDark),
          _buildLuckyItem(context, '활동', luckyItems['activity'], Icons.directions_run, DSColors.success, isDark),
          _buildLuckyItem(context, '간식', luckyItems['food'], Icons.restaurant, DSColors.warning, isDark),
          if (luckyItems['toy'] != null)
            _buildLuckyItem(context, '장난감', luckyItems['toy'], Icons.toys, DSColors.error, isDark),
          if (luckyItems['spot'] != null)
            _buildLuckyItem(context, '장소', luckyItems['spot'], Icons.place, DSColors.accentSecondary, isDark),
          if (luckyItems['time'] != null)
            _buildLuckyItem(context, '시간', luckyItems['time'], Icons.schedule, DSColors.accent, isDark),
        ],
      ),
    );
  }

  Widget _buildLuckyItem(BuildContext context, String label, dynamic value, IconData icon, Color color, bool isDark) {
    if (value == null) return const SizedBox.shrink();
    
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
                  label,
                  style: context.labelSmall.copyWith(
                    color: isDark ? DSColors.textTertiary : DSColors.textSecondary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value.toString(),
                  style: context.bodyMedium.copyWith(
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
  
  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (onShare != null)
            UnifiedButton(
              text: '공유하기',
              onPressed: onShare,
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
}