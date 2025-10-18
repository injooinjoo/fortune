import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../domain/entities/fortune.dart';
import 'fortune_card.dart';
import 'fortune_button.dart';
import '../../../../core/theme/typography_unified.dart';

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
            style: TypographyUnified.displayLarge,
          ),
          SizedBox(height: 12),
          Text(
            '$petName의 오늘 운세',
            style: TossDesignSystem.heading2.copyWith(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$petSpecies • $petAge살',
              style: TossDesignSystem.body3.copyWith(
                color: TossDesignSystem.tossBlue,
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
                  style: TossDesignSystem.display2.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '점',
                  style: TossDesignSystem.body2.copyWith(
                    color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
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
            style: TossDesignSystem.heading3.copyWith(
              color: scoreColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Text(
            compatibilityResult['message'] ?? fortune.content,
            style: TossDesignSystem.body3.copyWith(
              color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          if (compatibilityResult['advice'] != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TossDesignSystem.tossBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: TossDesignSystem.tossBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      compatibilityResult['advice'],
                      style: TossDesignSystem.body3.copyWith(
                        color: TossDesignSystem.tossBlue,
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
          _buildHealthIndicator('에너지', scores['energy'] ?? 0, TossDesignSystem.successGreen, isDark),
          _buildHealthIndicator('식욕', scores['appetite'] ?? 0, TossDesignSystem.warningOrange, isDark),
          _buildHealthIndicator('기분', scores['mood'] ?? 0, TossDesignSystem.tossBlue, isDark),
          _buildHealthIndicator('활동성', scores['activity'] ?? 0, TossDesignSystem.purple, isDark),
          
          const SizedBox(height: 16),
          
          // 메인 조언
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TossDesignSystem.successGreen.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.health_and_safety,
                  color: TossDesignSystem.successGreen,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    healthFortune['mainAdvice'] ?? '',
                    style: TossDesignSystem.body3.copyWith(
                      color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
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
                    color: TossDesignSystem.gray500,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      point.toString(),
                      style: TossDesignSystem.caption.copyWith(
                        color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
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
  
  Widget _buildHealthIndicator(String label, int score, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TossDesignSystem.caption.copyWith(
                color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
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
            style: TossDesignSystem.body3.copyWith(
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
              color: TossDesignSystem.purple.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: TossDesignSystem.purple,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${activityFortune['bestTime'] ?? '지금'} 추천',
                      style: TossDesignSystem.caption.copyWith(
                        color: TossDesignSystem.purple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  activityFortune['recommended'] ?? '',
                  style: TossDesignSystem.body2.copyWith(
                    color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
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
                    TossDesignSystem.tossBlue.withValues(alpha: 0.05),
                    TossDesignSystem.purple.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    color: TossDesignSystem.warningOrange,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      activityFortune['special'],
                      style: TossDesignSystem.body3.copyWith(
                        color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
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
                    style: TossDesignSystem.heading3.copyWith(
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
                      style: TossDesignSystem.body2.copyWith(
                        color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      emotionalState['advice'] ?? '',
                      style: TossDesignSystem.caption.copyWith(
                        color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
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
            _buildEventItem('미용/목욕', specialEvents['grooming'], Icons.shower, isDark),
          if (specialEvents['vetVisit'] != null)
            _buildEventItem('병원 방문', specialEvents['vetVisit'], Icons.local_hospital, isDark),
          if (specialEvents['training'] != null)
            _buildEventItem('훈련/교육', specialEvents['training'], Icons.school, isDark),
          if (specialEvents['socializing'] != null)
            _buildEventItem('사회화', specialEvents['socializing'], Icons.people, isDark),
        ],
      ),
    );
  }
  
  Widget _buildEventItem(String label, Map<String, dynamic> event, IconData icon, bool isDark) {
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
                      style: TossDesignSystem.body3.copyWith(
                        color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
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
                        style: TossDesignSystem.caption.copyWith(
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
                  style: TossDesignSystem.caption.copyWith(
                    color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
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
      backgroundColor: TossDesignSystem.warningOrange.withValues(alpha: 0.03),
      child: Column(
        children: carePoints.map((point) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.pets,
                color: TossDesignSystem.warningOrange,
                size: 16,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  point.toString(),
                  style: TossDesignSystem.body3.copyWith(
                    color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
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
          _buildLuckyItem('색상', luckyItems['color'], Icons.palette, TossDesignSystem.purple, isDark),
          _buildLuckyItem('아이템', luckyItems['item'], Icons.shopping_bag, TossDesignSystem.tossBlue, isDark),
          _buildLuckyItem('활동', luckyItems['activity'], Icons.directions_run, TossDesignSystem.successGreen, isDark),
          _buildLuckyItem('간식', luckyItems['food'], Icons.restaurant, TossDesignSystem.warningOrange, isDark),
          if (luckyItems['toy'] != null)
            _buildLuckyItem('장난감', luckyItems['toy'], Icons.toys, TossDesignSystem.errorRed, isDark),
          if (luckyItems['spot'] != null)
            _buildLuckyItem('장소', luckyItems['spot'], Icons.place, TossDesignSystem.purple, isDark),
          if (luckyItems['time'] != null)
            _buildLuckyItem('시간', luckyItems['time'], Icons.schedule, TossDesignSystem.tossBlue, isDark),
        ],
      ),
    );
  }
  
  Widget _buildLuckyItem(String label, dynamic value, IconData icon, Color color, bool isDark) {
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
                  style: TossDesignSystem.caption.copyWith(
                    color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value.toString(),
                  style: TossDesignSystem.body2.copyWith(
                    color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
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
            FortuneButton(
              text: '공유하기',
              onPressed: onShare,
              type: FortuneButtonType.primary,
              icon: const Icon(Icons.share, size: 20),
              width: double.infinity,
            ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            FortuneButton.retry(
              onPressed: onRetry,
            ),
          ],
          if (onSave != null) ...[
            const SizedBox(height: 12),
            FortuneButton(
              text: '저장하기',
              onPressed: onSave,
              type: FortuneButtonType.secondary,
              icon: const Icon(Icons.bookmark_border, size: 20),
              width: double.infinity,
            ),
          ],
        ],
      ),
    );
  }
  
  Color _getScoreColor(int score) {
    if (score >= 80) return TossDesignSystem.successGreen;
    if (score >= 60) return TossDesignSystem.tossBlue;
    if (score >= 40) return TossDesignSystem.warningOrange;
    return TossDesignSystem.errorRed;
  }
}