import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../../../core/theme/toss_design_system.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../core/components/toss_card.dart';
import '../../domain/models/ex_lover_simple_model.dart';

class ExLoverEmotionalResultPage extends ConsumerWidget {
  final ExLoverSimpleInput input;
  
  const ExLoverEmotionalResultPage({
    super.key,
    required this.input,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = _generateResult(input);
    
    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.grayDark50 : TossDesignSystem.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.close_rounded,
            color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
            size: 24,
          ),
        ),
        title: Text(
          '운세 결과',
          style: TossDesignSystem.heading3.copyWith(
            color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _shareResult(context, result),
            icon: Icon(
              Icons.share_rounded,
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              size: 20,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 메인 메시지
            _buildMainMessage(result, isDark).animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 24),
            
            // 오늘의 감정 처방
            _buildEmotionalPrescription(result.emotionalPrescription, isDark)
              .animate(delay: 100.ms)
              .fadeIn(duration: 400.ms)
              .slideX(begin: -0.05, end: 0),
            
            const SizedBox(height: 20),
            
            // 그 사람과의 인연
            _buildRelationshipInsight(result.relationshipInsight, input, isDark)
              .animate(delay: 200.ms)
              .fadeIn(duration: 400.ms)
              .slideX(begin: 0.05, end: 0),
            
            const SizedBox(height: 20),
            
            // 새로운 시작
            _buildNewBeginning(result.newBeginning, isDark)
              .animate(delay: 300.ms)
              .fadeIn(duration: 400.ms)
              .slideX(begin: -0.05, end: 0),
            
            const SizedBox(height: 32),
            
            // 다시 보기 버튼
            SizedBox(
              width: double.infinity,
              child: TossButton(
                text: '다시 보기',
                onPressed: () => Navigator.pop(context),
                style: TossButtonStyle.primary,
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMainMessage(ExLoverEmotionalResult result, bool isDark) {
    return TossCard(
      style: TossCardStyle.elevated,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TossDesignSystem.purple.withOpacity(0.8),
                  const Color(0xFFEC4899).withOpacity(0.8),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${result.overallScore}',
                style: TossDesignSystem.heading2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          
          const SizedBox(height: 20),
          
          Text(
            '오늘의 운세 점수',
            style: TossDesignSystem.body2.copyWith(
              color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TossDesignSystem.purple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: TossDesignSystem.purple.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              result.specialMessage,
              style: TossDesignSystem.body2.copyWith(
                color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionalPrescription(EmotionalPrescription prescription, bool isDark) {
    return TossCard(
      style: TossCardStyle.filled,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TossDesignSystem.tossBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: TossDesignSystem.tossBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '오늘의 감정 처방',
                style: TossDesignSystem.body1.copyWith(
                  color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 치유 진행도
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '치유 진행도',
                    style: TossDesignSystem.caption.copyWith(
                      color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                    ),
                  ),
                  Text(
                    '${prescription.healingProgress}%',
                    style: TossDesignSystem.caption.copyWith(
                      color: TossDesignSystem.successGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: prescription.healingProgress / 100,
                  backgroundColor: TossDesignSystem.successGreen.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(TossDesignSystem.successGreen),
                  minHeight: 8,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 현재 상태
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.psychology_rounded,
                      size: 16,
                      color: TossDesignSystem.tossBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '현재 상태',
                      style: TossDesignSystem.caption.copyWith(
                        color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  prescription.currentState,
                  style: TossDesignSystem.body3.copyWith(
                    color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 추천 활동
          _buildListSection(
            '오늘 하면 좋은 활동',
            prescription.recommendedActivities,
            Icons.check_circle_rounded,
            TossDesignSystem.successGreen,
            isDark,
          ),
          
          const SizedBox(height: 16),
          
          // 피해야 할 것
          _buildListSection(
            '피하면 좋은 것',
            prescription.thingsToAvoid,
            Icons.cancel_rounded,
            TossDesignSystem.warningOrange,
            isDark,
          ),
          
          const SizedBox(height: 16),
          
          // 치유 조언
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TossDesignSystem.tossBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: TossDesignSystem.tossBlue.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: TossDesignSystem.tossBlue,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    prescription.healingAdvice,
                    style: TossDesignSystem.caption.copyWith(
                      color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelationshipInsight(RelationshipInsight insight, ExLoverSimpleInput input, bool isDark) {
    // 사용자가 선택한 궁금증에 따라 강조할 내용 결정
    final showReunion = input.mainCuriosity == 'reunionChance';
    final showFeelings = input.mainCuriosity == 'theirFeelings';
    
    return TossCard(
      style: TossCardStyle.filled,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.people_rounded,
                  color: const Color(0xFFEC4899),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '그 사람과의 인연',
                style: TossDesignSystem.body1.copyWith(
                  color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 재회 가능성 (궁금증에 따라 표시)
          if (showReunion) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFEC4899).withOpacity(0.1),
                    TossDesignSystem.purple.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '재회 가능성',
                    style: TossDesignSystem.body2.copyWith(
                      color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${insight.reunionPossibility}%',
                    style: TossDesignSystem.heading2.copyWith(
                      color: const Color(0xFFEC4899),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    insight.contactTiming,
                    style: TossDesignSystem.caption.copyWith(
                      color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // 상대방 마음 (궁금증에 따라 표시)
          if (showFeelings) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.favorite_border_rounded,
                        size: 16,
                        color: const Color(0xFFEC4899),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        insight.isThinkingOfYou ? '그 사람도 당신을 생각해요' : '그 사람은 새로운 길을 가고 있어요',
                        style: TossDesignSystem.caption.copyWith(
                          color: const Color(0xFFEC4899),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    insight.theirCurrentFeelings,
                    style: TossDesignSystem.body3.copyWith(
                      color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // 배울 점
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TossDesignSystem.purple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: TossDesignSystem.purple.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: TossDesignSystem.purple,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '이 관계에서 배울 점',
                        style: TossDesignSystem.caption.copyWith(
                          color: TossDesignSystem.purple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        insight.karmicLesson,
                        style: TossDesignSystem.caption.copyWith(
                          color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewBeginning(NewBeginning newBeginning, bool isDark) {
    return TossCard(
      style: TossCardStyle.filled,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TossDesignSystem.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.local_florist_rounded,
                  color: TossDesignSystem.successGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '새로운 시작',
                style: TossDesignSystem.body1.copyWith(
                  color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 준비도
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '새로운 사랑 준비도',
                      style: TossDesignSystem.caption.copyWith(
                        color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${newBeginning.readinessScore}%',
                          style: TossDesignSystem.heading4.copyWith(
                            color: TossDesignSystem.successGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getReadinessText(newBeginning.readinessLevel),
                          style: TossDesignSystem.caption.copyWith(
                            color: TossDesignSystem.successGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: newBeginning.readinessScore / 100,
                        strokeWidth: 4,
                        backgroundColor: TossDesignSystem.successGreen.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(TossDesignSystem.successGreen),
                      ),
                    ),
                    Icon(
                      _getReadinessIcon(newBeginning.readinessLevel),
                      color: TossDesignSystem.successGreen,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 새로운 인연 시기
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: TossDesignSystem.successGreen,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '새로운 인연 시기',
                        style: TossDesignSystem.caption.copyWith(
                          color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        newBeginning.expectedTiming,
                        style: TossDesignSystem.body3.copyWith(
                          color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 성장 포인트
          _buildListSection(
            '성장 포인트',
            newBeginning.growthPoints,
            Icons.trending_up_rounded,
            TossDesignSystem.successGreen,
            isDark,
          ),
          
          const SizedBox(height: 16),
          
          // 새로운 사랑 조언
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TossDesignSystem.successGreen.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: TossDesignSystem.successGreen.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.favorite_rounded,
                  color: TossDesignSystem.successGreen,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    newBeginning.newLoveAdvice,
                    style: TossDesignSystem.caption.copyWith(
                      color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(
    String title,
    List<String> items,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TossDesignSystem.caption.copyWith(
                color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: TossDesignSystem.body3.copyWith(
                  color: color,
                ),
              ),
              Expanded(
                child: Text(
                  item,
                  style: TossDesignSystem.body3.copyWith(
                    color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  String _getReadinessText(String level) {
    switch (level) {
      case 'not_ready':
        return '아직 준비 중';
      case 'preparing':
        return '천천히 준비 중';
      case 'almost_ready':
        return '거의 준비됨';
      case 'ready':
        return '준비 완료!';
      default:
        return '';
    }
  }

  IconData _getReadinessIcon(String level) {
    switch (level) {
      case 'not_ready':
        return Icons.hourglass_empty_rounded;
      case 'preparing':
        return Icons.hourglass_bottom_rounded;
      case 'almost_ready':
        return Icons.hourglass_top_rounded;
      case 'ready':
        return Icons.check_circle_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  ExLoverEmotionalResult _generateResult(ExLoverSimpleInput input) {
    final random = math.Random();
    
    // 감정과 시간에 따른 치유 진행도 계산
    int healingProgress = 30;
    if (input.timeSinceBreakup == 'verylong') healingProgress += 40;
    else if (input.timeSinceBreakup == 'long') healingProgress += 30;
    else if (input.timeSinceBreakup == 'medium') healingProgress += 20;
    else if (input.timeSinceBreakup == 'short') healingProgress += 10;
    
    if (input.currentEmotion == 'acceptance') healingProgress += 20;
    else if (input.currentEmotion == 'relief') healingProgress += 15;
    else if (input.currentEmotion == 'sadness') healingProgress += 5;
    
    healingProgress = healingProgress.clamp(0, 100);
    
    // 재회 가능성 계산
    int reunionPossibility = 25;
    if (input.currentEmotion == 'miss') reunionPossibility += 20;
    if (input.timeSinceBreakup == 'recent') reunionPossibility += 15;
    if (input.breakupReason == 'timing') reunionPossibility += 20;
    else if (input.breakupReason == 'trust') reunionPossibility -= 20;
    
    reunionPossibility = reunionPossibility.clamp(5, 85);
    
    // 새로운 사랑 준비도 계산
    int readinessScore = healingProgress + random.nextInt(20);
    readinessScore = readinessScore.clamp(0, 100);
    
    String readinessLevel;
    if (readinessScore >= 80) readinessLevel = 'ready';
    else if (readinessScore >= 60) readinessLevel = 'almost_ready';
    else if (readinessScore >= 40) readinessLevel = 'preparing';
    else readinessLevel = 'not_ready';
    
    // 전체 운세 점수
    int overallScore = 50 + random.nextInt(30) + (healingProgress ~/ 2);
    overallScore = overallScore.clamp(0, 100);
    
    // 감정 처방 생성
    final emotionalPrescription = EmotionalPrescription(
      currentState: _getCurrentStateMessage(input.currentEmotion, input.timeSinceBreakup),
      recommendedActivities: _getRecommendedActivities(input.currentEmotion),
      thingsToAvoid: _getThingsToAvoid(input.currentEmotion),
      healingAdvice: _getHealingAdvice(input.currentEmotion, healingProgress),
      healingProgress: healingProgress,
    );
    
    // 관계 인사이트 생성
    final relationshipInsight = RelationshipInsight(
      reunionPossibility: reunionPossibility,
      theirCurrentFeelings: _getTheirFeelings(input.currentEmotion, input.timeSinceBreakup),
      contactTiming: _getContactTiming(reunionPossibility, input.timeSinceBreakup),
      karmicLesson: _getKarmicLesson(input.breakupReason),
      isThinkingOfYou: reunionPossibility > 50 && input.timeSinceBreakup != 'verylong',
    );
    
    // 새로운 시작 생성
    final newBeginning = NewBeginning(
      readinessLevel: readinessLevel,
      expectedTiming: _getExpectedTiming(readinessScore),
      growthPoints: _getGrowthPoints(input.currentEmotion, input.breakupReason),
      newLoveAdvice: _getNewLoveAdvice(readinessLevel),
      readinessScore: readinessScore,
    );
    
    return ExLoverEmotionalResult(
      emotionalPrescription: emotionalPrescription,
      relationshipInsight: relationshipInsight,
      newBeginning: newBeginning,
      overallScore: overallScore,
      specialMessage: _getSpecialMessage(input.mainCuriosity, overallScore),
    );
  }

  String _getCurrentStateMessage(String emotion, String time) {
    if (emotion == 'miss') {
      return '아직 그 사람에 대한 그리움이 남아있네요. 이건 자연스러운 감정이에요. 시간이 지나면서 점점 나아질 거예요.';
    } else if (emotion == 'anger') {
      return '분노는 치유 과정의 일부예요. 이 감정을 인정하고 건강하게 표현하는 것이 중요해요.';
    } else if (emotion == 'sadness') {
      return '슬픔을 느끼는 것은 당연해요. 충분히 슬퍼할 시간을 가지세요. 이것도 지나갈 거예요.';
    } else if (emotion == 'relief') {
      return '안도감을 느끼는 것은 좋은 신호예요. 이제 새로운 시작을 준비할 때가 되었어요.';
    } else {
      return '받아들임의 단계에 도달했네요. 이제 과거를 놓아주고 앞으로 나아갈 준비가 되었어요.';
    }
  }

  List<String> _getRecommendedActivities(String emotion) {
    switch (emotion) {
      case 'miss':
        return ['새로운 취미 시작하기', '친구들과 시간 보내기', '일기 쓰기'];
      case 'anger':
        return ['운동으로 에너지 발산하기', '명상이나 요가', '창작 활동하기'];
      case 'sadness':
        return ['좋아하는 영화 보기', '자연 속 산책', '따뜻한 차 마시기'];
      case 'relief':
        return ['새로운 목표 세우기', '자기계발 시작하기', '여행 계획 세우기'];
      default:
        return ['새로운 사람들 만나기', '봉사활동 참여', '자신을 위한 선물하기'];
    }
  }

  List<String> _getThingsToAvoid(String emotion) {
    switch (emotion) {
      case 'miss':
        return ['상대방 SNS 확인', '과거 사진 보기', '혼자 있는 시간 늘리기'];
      case 'anger':
        return ['충동적인 연락', '복수심 품기', '분노를 억누르기'];
      case 'sadness':
        return ['자책하기', '고립되기', '슬픔에 빠져있기'];
      case 'relief':
        return ['급한 새로운 관계', '과거 미화하기', '경계심 놓기'];
      default:
        return ['서두르기', '비교하기', '과거에 집착하기'];
    }
  }

  String _getHealingAdvice(String emotion, int progress) {
    if (progress >= 80) {
      return '거의 다 치유되었어요! 이제 새로운 사랑을 맞이할 준비가 되었네요.';
    } else if (progress >= 60) {
      return '많이 나아졌어요. 조금만 더 시간을 가지면 완전히 회복될 거예요.';
    } else if (progress >= 40) {
      return '천천히 나아지고 있어요. 자신에게 친절하게 대해주세요.';
    } else {
      return '시간이 필요해요. 서두르지 말고 자신의 속도대로 치유하세요.';
    }
  }

  String _getTheirFeelings(String yourEmotion, String time) {
    if (time == 'recent') {
      return '상대방도 아직 혼란스러워하고 있을 가능성이 높아요. 당신처럼 여러 감정을 겪고 있을 거예요.';
    } else if (time == 'verylong') {
      return '상대방은 이미 새로운 삶을 살고 있을 가능성이 높아요. 하지만 가끔은 당신을 떠올릴 수도 있어요.';
    } else {
      return '상대방도 이별 후 성장하고 있을 거예요. 각자의 길을 가는 것이 서로에게 최선일 수 있어요.';
    }
  }

  String _getContactTiming(int reunionPossibility, String time) {
    if (reunionPossibility > 60) {
      return '조금 더 시간을 가진 후, 마음이 정리되면 가벼운 안부를 전해보세요.';
    } else if (reunionPossibility > 30) {
      return '지금은 연락하지 않는 것이 좋아요. 더 시간이 필요해요.';
    } else {
      return '연락보다는 각자의 길을 가는 것이 서로에게 좋을 것 같아요.';
    }
  }

  String _getKarmicLesson(String? breakupReason) {
    switch (breakupReason) {
      case 'differentValues':
        return '서로 다른 가치관을 인정하는 법을 배웠어요. 다음 사랑에서는 더 잘 소통할 수 있을 거예요.';
      case 'timing':
        return '때로는 타이밍이 맞지 않을 수 있다는 것을 배웠어요. 인연이라면 다시 만날 수도 있어요.';
      case 'communication':
        return '소통의 중요성을 깨달았어요. 다음에는 더 솔직하게 표현할 수 있을 거예요.';
      case 'trust':
        return '신뢰의 소중함을 배웠어요. 다음에는 더 건강한 관계를 만들 수 있을 거예요.';
      default:
        return '모든 관계는 성장의 기회예요. 이 경험으로 더 성숙해졌어요.';
    }
  }

  String _getExpectedTiming(int readiness) {
    if (readiness >= 80) {
      return '지금도 충분해요! 마음이 열려있다면 언제든 새로운 인연을 만날 수 있어요.';
    } else if (readiness >= 60) {
      return '1-2개월 내에 좋은 인연을 만날 가능성이 높아요.';
    } else if (readiness >= 40) {
      return '3-6개월 후면 새로운 사랑을 시작할 준비가 될 거예요.';
    } else {
      return '아직은 자신에게 집중할 시기예요. 6개월 이상 시간을 가져보세요.';
    }
  }

  List<String> _getGrowthPoints(String emotion, String? breakupReason) {
    final points = <String>[];
    
    if (emotion == 'acceptance') {
      points.add('감정을 건강하게 처리하는 능력');
    }
    if (breakupReason == 'communication') {
      points.add('더 나은 소통 방법');
    }
    points.add('자기 자신을 더 사랑하는 법');
    points.add('건강한 관계의 기준 세우기');
    
    return points;
  }

  String _getNewLoveAdvice(String readinessLevel) {
    switch (readinessLevel) {
      case 'ready':
        return '새로운 사랑을 맞이할 준비가 되었어요! 열린 마음으로 기회를 맞이하세요.';
      case 'almost_ready':
        return '조금만 더 자신에게 집중하면 곧 준비가 될 거예요.';
      case 'preparing':
        return '천천히 준비하고 있어요. 서두르지 마세요.';
      default:
        return '지금은 자신을 돌보는 시간이 필요해요. 때가 되면 자연스럽게 알게 될 거예요.';
    }
  }

  String _getSpecialMessage(String curiosity, int score) {
    String base = '';
    
    switch (curiosity) {
      case 'theirFeelings':
        base = '상대방의 마음이 궁금하신가요? ';
        break;
      case 'reunionChance':
        base = '재회를 바라고 계신가요? ';
        break;
      case 'newLove':
        base = '새로운 사랑을 기다리고 계신가요? ';
        break;
      case 'healing':
        base = '마음의 치유를 원하시는군요. ';
        break;
    }
    
    if (score >= 80) {
      return base + '오늘은 정말 좋은 날이에요. 긍정적인 에너지가 당신을 감싸고 있어요.';
    } else if (score >= 60) {
      return base + '괜찮아요, 모든 것이 잘 될 거예요. 시간이 해결해줄 거예요.';
    } else {
      return base + '힘든 시기지만, 이것도 지나갈 거예요. 조금만 더 힘내세요.';
    }
  }

  void _shareResult(BuildContext context, ExLoverEmotionalResult result) {
    HapticFeedback.lightImpact();
    
    final text = StringBuffer();
    text.writeln('💜 헤어진 애인 운세 결과\n');
    text.writeln('오늘의 운세: ${result.overallScore}점');
    text.writeln('치유 진행도: ${result.emotionalPrescription.healingProgress}%');
    text.writeln('재회 가능성: ${result.relationshipInsight.reunionPossibility}%');
    text.writeln('새로운 사랑 준비도: ${result.newBeginning.readinessScore}%');
    text.writeln('\n${result.specialMessage}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('운세 결과가 복사되었습니다'),
        backgroundColor: TossDesignSystem.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}