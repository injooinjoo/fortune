import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../../core/theme/toss_design_system.dart';

/// 가족 화합도 측정기 - 토스 디자인 시스템
class FamilyHarmonyMeter extends StatelessWidget {
  final int score;
  final String level;
  final String description;
  final bool showAnimation;
  
  const FamilyHarmonyMeter({
    super.key,
    required this.score,
    required this.level,
    required this.description,
    this.showAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scoreColor = _getScoreColor(score);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scoreColor.withOpacity(0.05),
            scoreColor.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: scoreColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Title
          Text(
            '오늘의 가족 화합도',
            style: TossDesignSystem.heading4.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
            ),
          ),
          const SizedBox(height: 24),
          
          // Circular meter
          CircularPercentIndicator(
            radius: 100.0,
            lineWidth: 12.0,
            animation: showAnimation,
            animationDuration: 1500,
            percent: score / 100,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$score',
                  style: TossDesignSystem.display1.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 48,
                  ),
                ),
                Text(
                  '%',
                  style: TossDesignSystem.body2.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: scoreColor,
            backgroundColor: scoreColor.withOpacity(0.1),
          ),
          
          const SizedBox(height: 20),
          
          // Level badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              level,
              style: TossDesignSystem.heading4.copyWith(
                color: scoreColor,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            description,
            style: TossDesignSystem.body3.copyWith(
              color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Family emojis
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildFamilyEmojis(),
          ),
        ],
      ),
    ).animate()
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }
  
  List<Widget> _buildFamilyEmojis() {
    final emojis = ['👨', '👩', '👦', '👧', '👶'];
    return emojis.map((emoji) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 24),
      ).animate()
          .fadeIn(delay: Duration(milliseconds: emojis.indexOf(emoji) * 100))
          .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
    )).toList();
  }
  
  Color _getScoreColor(int score) {
    if (score >= 80) return TossDesignSystem.successGreen;
    if (score >= 60) return TossDesignSystem.tossBlue;
    if (score >= 40) return TossDesignSystem.warningOrange;
    return TossDesignSystem.errorRed;
  }
}

/// 카테고리별 화합도 차트
class FamilyCategoryChart extends StatelessWidget {
  final Map<String, dynamic> categories;
  
  const FamilyCategoryChart({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '카테고리별 점수',
            style: TossDesignSystem.heading4.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
            ),
          ),
          const SizedBox(height: 20),
          
          ...categories.entries.map((entry) {
            final category = entry.value as Map<String, dynamic>;
            final score = category['score'] ?? 0;
            final advice = category['advice'] ?? '';
            final label = _getCategoryLabel(entry.key);
            final icon = _getCategoryIcon(entry.key);
            final color = _getCategoryColor(entry.key);
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        size: 18,
                        color: color,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: TossDesignSystem.body3.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$score점',
                        style: TossDesignSystem.body3.copyWith(
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearPercentIndicator(
                    lineHeight: 8.0,
                    percent: score / 100,
                    backgroundColor: color.withOpacity(0.1),
                    progressColor: color,
                    barRadius: const Radius.circular(4),
                    padding: EdgeInsets.zero,
                    animation: true,
                    animationDuration: 1000,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    advice,
                    style: TossDesignSystem.caption.copyWith(
                      color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
  
  String _getCategoryLabel(String key) {
    final labels = {
      'communication': '소통',
      'affection': '애정',
      'cooperation': '협력',
      'growth': '성장',
    };
    return labels[key] ?? key;
  }
  
  IconData _getCategoryIcon(String key) {
    final icons = {
      'communication': Icons.chat_bubble_outline,
      'affection': Icons.favorite_outline,
      'cooperation': Icons.group_work_outlined,
      'growth': Icons.trending_up,
    };
    return icons[key] ?? Icons.circle;
  }
  
  Color _getCategoryColor(String key) {
    final colors = {
      'communication': TossDesignSystem.tossBlue,
      'affection': TossDesignSystem.errorRed,
      'cooperation': TossDesignSystem.successGreen,
      'growth': TossDesignSystem.purple,
    };
    return colors[key] ?? TossDesignSystem.gray600;
  }
}

/// 주간 가족 운세 트렌드 차트
class FamilyWeeklyTrendChart extends StatelessWidget {
  final Map<String, dynamic> weeklyTrend;
  
  const FamilyWeeklyTrendChart({
    super.key,
    required this.weeklyTrend,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = DateTime.now().weekday;
    final days = ['월', '화', '수', '목', '금', '토', '일'];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이번 주 가족 운세',
            style: TossDesignSystem.heading4.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
            ),
          ),
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.asMap().entries.map((entry) {
              final index = entry.key;
              final day = entry.value;
              final dayData = weeklyTrend[day] ?? {};
              final score = dayData['score'] ?? 0;
              final keyword = dayData['keyword'] ?? '';
              final isToday = index == (today - 1);
              final color = _getScoreColor(score);
              
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isToday ? color.withOpacity(0.1) : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        day,
                        style: TossDesignSystem.caption.copyWith(
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                          color: isToday 
                              ? color
                              : isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Bar chart
                    Container(
                      width: 30,
                      height: 80,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 500 + (index * 100)),
                          width: 30,
                          height: (score / 100) * 80,
                          decoration: BoxDecoration(
                            color: isToday ? color : color.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    Text(
                      '$score',
                      style: TossDesignSystem.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      keyword,
                      style: TossDesignSystem.overline.copyWith(
                        fontSize: 10,
                        color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }
  
  Color _getScoreColor(int score) {
    if (score >= 80) return TossDesignSystem.successGreen;
    if (score >= 60) return TossDesignSystem.tossBlue;
    if (score >= 40) return TossDesignSystem.warningOrange;
    return TossDesignSystem.errorRed;
  }
}