import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../../../core/theme/toss_design_system.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../core/components/toss_card.dart';
import '../../domain/models/blind_date_instagram_model.dart';

class BlindDateCoachingPage extends ConsumerWidget {
  final BlindDateInstagramInput input;
  
  const BlindDateCoachingPage({
    super.key,
    required this.input,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = _generateMockResult(input);
    
    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.grayDark50 : TossDesignSystem.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'AI 코칭 결과',
          style: TossDesignSystem.heading4.copyWith(
            color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Main Score Section
            _buildMainScore(result, isDark),
            
            // Profile Analysis
            _buildProfileAnalysis(result, isDark),
            
            // Common Interests
            _buildCommonInterests(result, isDark),
            
            // First Impression Strategy
            _buildFirstImpressionStrategy(result, isDark),
            
            // Conversation Guide
            _buildConversationGuide(result, isDark),
            
            // Styling Recommendation
            _buildStylingRecommendation(result, isDark),
            
            // Date Plan
            _buildDatePlan(result, isDark),
            
            // Do's and Don'ts
            _buildDosDonts(result, isDark),
            
            // Motivational Message
            _buildMotivationalMessage(result, isDark),
            
            // Action Button
            _buildActionButton(context, isDark),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMainScore(BlindDateCoachingResult result, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Animated Score Circle
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: CircularProgressPainter(
                    progress: result.compatibilityScore / 100,
                    gradientColors: [
                      TossDesignSystem.purple,
                      TossDesignSystem.tossBlue,
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${result.compatibilityScore}%',
                    style: TossDesignSystem.heading1.copyWith(
                      color: TossDesignSystem.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
                  Text(
                    _getCompatibilityText(result.compatibilityLevel),
                    style: TossDesignSystem.body1.copyWith(
                      color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
          
          const SizedBox(height: 24),
          
          // Lucky Charm
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TossDesignSystem.purple.withOpacity(0.1),
                  Colors.purple.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: TossDesignSystem.purple.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🍀',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  result.luckyCharm,
                  style: TossDesignSystem.body2.copyWith(
                    color: TossDesignSystem.purple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildProfileAnalysis(BlindDateCoachingResult result, bool isDark) {
    // Mock profile data
    final profile = InstagramProfileAnalysis(
      profileImageUrl: '',
      username: '@username',
      followerCount: 1234,
      followingCount: 567,
      postCount: 89,
      fashionStyle: 'Casual & Trendy',
      estimatedPersonality: 'Extrovert',
      detectedInterests: ['여행', '맛집', '운동', '음악'],
      lifestyle: 'Work-Life Balance',
      ageRange: '25-30',
      frequentLocations: ['카페', '레스토랑', '공원'],
      hashtagTrends: ['#일상', '#맛스타그램', '#여행스타그램'],
      postingFrequency: 'Weekly',
      contentType: 'Lifestyle Mix',
    );
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TossCard(
        style: TossCardStyle.filled,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple, Colors.pink, Colors.orange],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.insights,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '프로필 분석',
                  style: TossDesignSystem.heading4.copyWith(
                    color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Style & Personality
            Row(
              children: [
                Expanded(
                  child: _buildInfoBox(
                    '스타일',
                    profile.fashionStyle,
                    Icons.checkroom,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoBox(
                    '성격',
                    profile.estimatedPersonality,
                    Icons.psychology,
                    isDark,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Lifestyle & Age
            Row(
              children: [
                Expanded(
                  child: _buildInfoBox(
                    '라이프스타일',
                    profile.lifestyle,
                    Icons.favorite,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoBox(
                    '연령대',
                    profile.ageRange,
                    Icons.cake,
                    isDark,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Detected Interests
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '관심사',
                  style: TossDesignSystem.body2.copyWith(
                    color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile.detectedInterests.map((interest) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: TossDesignSystem.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: TossDesignSystem.purple.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        interest,
                        style: TossDesignSystem.body3.copyWith(
                          color: TossDesignSystem.purple,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildCommonInterests(BlindDateCoachingResult result, bool isDark) {
    if (result.commonInterests.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: TossCard(
        style: TossCardStyle.filled,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '공통 관심사',
                  style: TossDesignSystem.heading4.copyWith(
                    color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...result.commonInterests.map((interest) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: TossDesignSystem.purple,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      interest,
                      style: TossDesignSystem.body2.copyWith(
                        color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildFirstImpressionStrategy(BlindDateCoachingResult result, bool isDark) {
    final strategy = result.firstImpression;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TossCard(
        style: TossCardStyle.filled,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '첫인상 전략',
                  style: TossDesignSystem.heading4.copyWith(
                    color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Opening Line
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.withOpacity(0.1),
                    Colors.orange.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.format_quote,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '추천 오프닝',
                        style: TossDesignSystem.body3.copyWith(
                          color: Colors.amber[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strategy.openingLine,
                    style: TossDesignSystem.body2.copyWith(
                      color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Approach Style
            Row(
              children: [
                Expanded(
                  child: _buildStrategyBox(
                    '접근 스타일',
                    _getApproachStyleText(strategy.approachStyle),
                    Icons.sentiment_satisfied,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStrategyBox(
                    '에너지 레벨',
                    _getEnergyLevelText(strategy.energyLevel),
                    Icons.battery_charging_full,
                    isDark,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Body Language Tips
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '바디랭귀지 팁',
                  style: TossDesignSystem.body2.copyWith(
                    color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...strategy.bodyLanguageTips.map((tip) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '•',
                          style: TossDesignSystem.body3.copyWith(
                            color: TossDesignSystem.purple,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tip,
                            style: TossDesignSystem.body3.copyWith(
                              color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildConversationGuide(BlindDateCoachingResult result, bool isDark) {
    final guide = result.conversationGuide;
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: TossCard(
        style: TossCardStyle.filled,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: TossDesignSystem.tossBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '대화 가이드',
                  style: TossDesignSystem.heading4.copyWith(
                    color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Ice Breakers
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TossDesignSystem.tossBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: TossDesignSystem.tossBlue.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.ac_unit,
                        color: TossDesignSystem.tossBlue,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '아이스브레이킹 질문',
                        style: TossDesignSystem.body2.copyWith(
                          color: TossDesignSystem.tossBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...guide.iceBreakers.take(3).map((question) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💬',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              question,
                              style: TossDesignSystem.body3.copyWith(
                                color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Recommended Topics
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '추천 대화 주제',
                  style: TossDesignSystem.body2.copyWith(
                    color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: guide.recommendedTopics.map((topic) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            topic,
                            style: TossDesignSystem.body3.copyWith(
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Avoid Topics
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '피해야 할 주제',
                  style: TossDesignSystem.body2.copyWith(
                    color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: guide.avoidTopics.map((topic) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cancel,
                            color: Colors.red,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            topic,
                            style: TossDesignSystem.body3.copyWith(
                              color: Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms, delay: 400.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildStylingRecommendation(BlindDateCoachingResult result, bool isDark) {
    final styling = result.styling;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TossCard(
        style: TossCardStyle.filled,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.checkroom,
                  color: Colors.purple,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '스타일링 추천',
                  style: TossDesignSystem.heading4.copyWith(
                    color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Recommended Style
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.withOpacity(0.05),
                    Colors.pink.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '추천 스타일',
                    style: TossDesignSystem.body3.copyWith(
                      color: Colors.purple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    styling.recommendedStyle,
                    style: TossDesignSystem.body2.copyWith(
                      color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Color Suggestions
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '추천 색상',
                  style: TossDesignSystem.body2.copyWith(
                    color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: styling.colorSuggestions.map((color) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getColorFromString(color),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Grooming Advice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.tips_and_updates,
                    color: Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      styling.groomingAdvice,
                      style: TossDesignSystem.body3.copyWith(
                        color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms, delay: 500.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildDatePlan(BlindDateCoachingResult result, bool isDark) {
    final plan = result.datePlan;
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: TossCard(
        style: TossCardStyle.filled,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.place,
                  color: Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '데이트 플랜',
                  style: TossDesignSystem.heading4.copyWith(
                    color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Location Suggestions
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '추천 장소',
                  style: TossDesignSystem.body2.copyWith(
                    color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...plan.locationSuggestions.map((location) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          location,
                          style: TossDesignSystem.body3.copyWith(
                            color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Timing & Duration
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: TossDesignSystem.purple,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '권장 시간',
                              style: TossDesignSystem.body3.copyWith(
                                color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${plan.suggestedDuration}분',
                          style: TossDesignSystem.body2.copyWith(
                            color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.restaurant,
                              color: TossDesignSystem.purple,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '분위기',
                              style: TossDesignSystem.body3.copyWith(
                                color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getAtmosphereText(plan.atmosphereType),
                          style: TossDesignSystem.body2.copyWith(
                            color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms, delay: 600.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildDosDonts(BlindDateCoachingResult result, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Do's
          Expanded(
            child: TossCard(
              style: TossCardStyle.filled,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'DO',
                        style: TossDesignSystem.body1.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...result.doList.take(3).map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✓',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 6),
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
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Don'ts
          Expanded(
            child: TossCard(
              style: TossCardStyle.filled,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.cancel,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'DON\'T',
                        style: TossDesignSystem.body1.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...result.dontList.take(3).map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✗',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 6),
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
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 500.ms, delay: 700.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildMotivationalMessage(BlindDateCoachingResult result, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              TossDesignSystem.purple.withOpacity(0.1),
              Colors.purple.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: TossDesignSystem.purple.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.auto_awesome,
              color: TossDesignSystem.purple,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              result.motivationalMessage,
              style: TossDesignSystem.body1.copyWith(
                color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms, delay: 800.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
    );
  }

  Widget _buildActionButton(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: TossButton.primary(
          text: '다시 분석하기',
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildInfoBox(String label, String value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray500,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TossDesignSystem.body3.copyWith(
                  color: isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TossDesignSystem.body2.copyWith(
              color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategyBox(String label, String value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: TossDesignSystem.purple,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TossDesignSystem.body3.copyWith(
                  color: isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TossDesignSystem.body2.copyWith(
              color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getCompatibilityText(String level) {
    switch (level) {
      case 'excellent':
        return '환상의 궁합';
      case 'good':
        return '좋은 궁합';
      case 'moderate':
        return '무난한 궁합';
      case 'challenging':
        return '노력이 필요한 궁합';
      default:
        return '분석 중';
    }
  }

  String _getApproachStyleText(String style) {
    switch (style) {
      case 'warm':
        return '따뜻하고 친근하게';
      case 'professional':
        return '차분하고 진중하게';
      case 'playful':
        return '유쾌하고 재미있게';
      case 'mysterious':
        return '신비롭고 매력적으로';
      default:
        return '자연스럽게';
    }
  }

  String _getEnergyLevelText(String level) {
    switch (level) {
      case 'calm':
        return '차분하게';
      case 'moderate':
        return '적당히';
      case 'energetic':
        return '활기차게';
      default:
        return '편안하게';
    }
  }

  String _getAtmosphereText(String type) {
    switch (type) {
      case 'quiet':
        return '조용한';
      case 'lively':
        return '활기찬';
      case 'romantic':
        return '로맨틱';
      case 'casual':
        return '캐주얼';
      default:
        return '편안한';
    }
  }

  Color _getColorFromString(String color) {
    switch (color) {
      case '네이비':
        return Colors.indigo;
      case '화이트':
        return Colors.white;
      case '베이지':
        return Color(0xFFF5E6D3);
      case '블랙':
        return Colors.black;
      case '파스텔':
        return Colors.pink[100]!;
      default:
        return Colors.grey;
    }
  }

  // Mock result generator
  BlindDateCoachingResult _generateMockResult(BlindDateInstagramInput input) {
    return BlindDateCoachingResult(
      compatibilityScore: 85,
      compatibilityLevel: 'good',
      commonInterests: ['여행', '맛집 탐방', '음악 감상'],
      complementaryTraits: ['외향적-내향적 균형', '계획적-즉흥적 조화'],
      firstImpression: FirstImpressionStrategy(
        approachStyle: 'warm',
        openingLine: '안녕하세요! 사진으로 봤을 때 여행 좋아하시는 것 같던데, 최근에 가장 기억에 남는 여행지가 어디였어요?',
        bodyLanguageTips: [
          '자연스러운 미소 유지하기',
          '적당한 아이컨택 (3-5초)',
          '열린 자세로 앉기',
        ],
        energyLevel: 'moderate',
        smileIntensity: 'natural',
      ),
      conversationGuide: ConversationGuide(
        iceBreakers: [
          '요즘 가장 빠져있는 취미가 뭐예요?',
          '주말에 보통 어떻게 보내세요?',
          '최근에 본 영화나 드라마 중에 추천할 만한 거 있어요?',
        ],
        recommendedTopics: ['여행', '음식', '취미', '주말 활동'],
        avoidTopics: ['전 애인', '정치', '종교', '연봉'],
        conversationStyle: 'balanced',
        interestingQuestions: [
          '만약 한 달 동안 어디든 갈 수 있다면 어디로 가고 싶어요?',
          '인생에서 가장 도전해보고 싶은 것은?',
        ],
        humorLevel: 'moderate',
      ),
      styling: StylingRecommendation(
        recommendedStyle: '캐주얼하면서도 깔끔한 스타일. 편안한 셔츠나 니트에 청바지나 슬랙스를 매치하세요.',
        colorSuggestions: ['네이비', '화이트', '베이지'],
        dressCode: 'smart casual',
        avoidItems: ['너무 화려한 액세서리', '강한 향수'],
        accessoryTips: '심플한 시계나 팔찌 정도가 적당해요',
        groomingAdvice: '자연스러운 헤어스타일과 깔끔한 손톱 관리를 추천드려요',
      ),
      datePlan: DatePlanSuggestion(
        idealTiming: input.meetingTime,
        locationSuggestions: [
          '분위기 좋은 독립 카페',
          '조용한 브런치 레스토랑',
          '산책하기 좋은 공원 근처',
        ],
        atmosphereType: 'casual',
        activityIdeas: ['카페에서 대화', '가벼운 산책', '디저트 카페 방문'],
        mealRecommendation: '부담스럽지 않은 브런치나 디저트',
        suggestedDuration: 90,
      ),
      doList: [
        '시간 약속 지키기',
        '경청하는 자세',
        '긍정적인 태도',
      ],
      dontList: [
        '핸드폰 자주 보기',
        '과도한 자기 자랑',
        '부정적인 이야기',
      ],
      motivationalMessage: '당신의 진정성 있는 모습이 가장 큰 매력입니다. 자신감을 가지고 즐거운 시간 보내세요!',
      luckyCharm: '오늘의 행운 아이템: 향긋한 커피 한 잔',
    );
  }
}

// Custom painter for circular progress
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final List<Color> gradientColors;

  CircularProgressPainter({
    required this.progress,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawCircle(center, radius - 6, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: gradientColors,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}