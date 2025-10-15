import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/toss_design_system.dart';
import '../../shared/components/toss_button.dart';

/// Collection of infographic widgets for fortune completion page
class FortuneInfographicWidgets {

  /// 토스 스타일 메인 점수 표시 (깔끔한 흰 배경)
  static Widget buildTossStyleMainScore({
    required int score,
    required String message,
    String? subtitle,
    double size = 280,
  }) {
    return Builder(
      builder: (context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? TossDesignSystem.grayDark200
              : TossDesignSystem.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? TossDesignSystem.grayDark300
                : const Color(0xFFF2F4F6),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // 토스 스타일 점수 표시 (큰 숫자만)
            Text(
              '$score',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? TossDesignSystem.white
                    : TossDesignSystem.gray900,
                fontSize: size * 0.3,
                fontWeight: FontWeight.w300,
                letterSpacing: -4,
                height: 1.0,
              ),
            ).animate()
              .scale(begin: const Offset(0.8, 0.8), duration: 800.ms, curve: Curves.elasticOut)
              .fadeIn(duration: 600.ms),

            const SizedBox(height: 24),

            // 메시지 (사자성어)
            Text(
              message,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? TossDesignSystem.grayDark100
                    : TossDesignSystem.gray700,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ).animate()
              .fadeIn(duration: 800.ms, delay: 400.ms)
              .slideY(begin: 0.3, curve: Curves.easeOut),

            // 사자성어 설명 (있을 경우)
            if (subtitle != null) ...[
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? TossDesignSystem.grayDark600
                      : TossDesignSystem.gray600,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ).animate()
                .fadeIn(duration: 800.ms, delay: 600.ms)
                .slideY(begin: 0.3, curve: Curves.easeOut),
            ],
          ],
        ),
      ),
    );
  }

  /// Hero-style score chart (원형 점수 차트)
  static Widget buildHeroScoreChart({
    required int score,
    required String title,
    double size = 200,
    Color? color,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final chartColor = color ?? TossDesignSystem.tossBlue;

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: score / 100.0,
                  strokeWidth: 8,
                  backgroundColor: isDark
                      ? TossDesignSystem.grayDark300
                      : TossDesignSystem.gray200,
                  valueColor: AlwaysStoppedAnimation<Color>(chartColor),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$score',
                    style: TextStyle(
                      fontSize: size * 0.2,
                      fontWeight: FontWeight.bold,
                      color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: size * 0.08,
                      color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate()
          .scale(begin: const Offset(0.8, 0.8), duration: 800.ms, curve: Curves.elasticOut)
          .fadeIn(duration: 600.ms);
      },
    );
  }

  /// Helper methods for color scoring
  static Color _getScoreColor(int score) {
    if (score >= 90) return const Color(0xFF00D2FF);
    if (score >= 80) return const Color(0xFF0066FF);
    if (score >= 70) return const Color(0xFF7C4DFF);
    if (score >= 60) return const Color(0xFFFF6B35);
    return const Color(0xFFFF4757);
  }

  static String _getScoreGrade(int score) {
    if (score >= 90) return 'S';
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    return 'D';
  }

  static Color _getScoreGradeColor(int score) {
    if (score >= 90) return const Color(0xFF00D2FF);
    if (score >= 80) return const Color(0xFF0066FF);
    if (score >= 70) return const Color(0xFF7C4DFF);
    if (score >= 60) return const Color(0xFFFF6B35);
    return const Color(0xFFFF4757);
  }

  static Color _getKeywordColor(double weight) {
    if (weight >= 0.8) return const Color(0xFF00D2FF);
    if (weight >= 0.6) return const Color(0xFF0066FF);
    if (weight >= 0.4) return const Color(0xFF7C4DFF);
    if (weight >= 0.2) return const Color(0xFFFF6B35);
    return const Color(0xFFFF4757);
  }

  static Color _getLuckyItemColor(String type) {
    switch (type.toLowerCase()) {
      case 'color':
      case '색상':
        return const Color(0xFFFF6B35);
      case 'food':
      case '음식':
        return const Color(0xFF00D2FF);
      case 'item':
      case '아이템':
        return const Color(0xFF7C4DFF);
      case 'number':
      case '숫자':
        return const Color(0xFF0066FF);
      default:
        return TossDesignSystem.tossBlue;
    }
  }

  static IconData _getLuckyItemIcon(String type) {
    switch (type.toLowerCase()) {
      case 'color':
      case '색상':
        return Icons.palette;
      case 'food':
      case '음식':
        return Icons.restaurant;
      case 'item':
      case '아이템':
        return Icons.stars;
      case 'number':
      case '숫자':
        return Icons.numbers;
      default:
        return Icons.auto_awesome;
    }
  }

  /// Mini statistics dashboard (토스 스타일)
  static Widget buildMiniStatsDashboard({
    required Map<String, dynamic> stats,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? TossDesignSystem.grayDark200
            : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? TossDesignSystem.grayDark300
              : TossDesignSystem.gray200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  title: '총 점수',
                  value: '${stats['totalScore'] ?? 0}',
                  context: context,
                ),
              ),
              Container(width: 1, height: 40, color: TossDesignSystem.gray200),
              Expanded(
                child: _buildStatItem(
                  title: '등급',
                  value: _getScoreGrade(stats['totalScore'] ?? 0),
                  context: context,
                ),
              ),
              Container(width: 1, height: 40, color: TossDesignSystem.gray200),
              Expanded(
                child: _buildStatItem(
                  title: '랭킹',
                  value: '${stats['ranking'] ?? '-'}위',
                  context: context,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 800.ms, delay: 700.ms)
      .slideY(begin: 0.1, curve: Curves.easeOut);
  }

  static Widget _buildStatItem({
    required String title,
    required String value,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
          ),
        ),
      ],
    );
  }

  /// Keyword cloud widget
  static Widget buildKeywordCloud({
    required List<String> keywords,
    double maxFontSize = 32,
    double minFontSize = 14,
    Map<String, double>? importance,
  }) {
    if (keywords.isEmpty) {
      return const Center(
        child: Text(
          '키워드가 없습니다',
          style: TextStyle(color: TossDesignSystem.gray500),
        ),
      );
    }

    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: keywords.map((keyword) {
            final weight = importance?[keyword] ?? 0.5;
            final fontSize = minFontSize + (maxFontSize - minFontSize) * weight;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getKeywordColor(weight).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getKeywordColor(weight).withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                keyword,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: isDark ? TossDesignSystem.white : _getKeywordColor(weight),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  /// 토스 스타일 키워드 섹션 (개선된 디자인)
  static Widget buildTossStyleKeywordSection({
    required List<String> keywords,
    required Map<String, double> importance,
    required BuildContext context,
  }) {
    if (keywords.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
            ? [
                const Color(0xFF1E293B),
                const Color(0xFF0F172A),
              ]
            : [
                TossDesignSystem.white,
                const Color(0xFFF8FAFC),
              ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
            ? TossDesignSystem.purple.withValues(alpha: 0.2)
            : TossDesignSystem.tossBlue.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
              ? TossDesignSystem.purple.withValues(alpha: 0.1)
              : TossDesignSystem.tossBlue.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 섹션
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                      ? [TossDesignSystem.purple, TossDesignSystem.purple.withValues(alpha: 0.8)]
                      : [TossDesignSystem.tossBlue, TossDesignSystem.tossBlue.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? TossDesignSystem.purple : TossDesignSystem.tossBlue).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: TossDesignSystem.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '오늘의 키워드',
                      style: TextStyle(
                        color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '당신을 위한 특별한 메시지',
                      style: TextStyle(
                        color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 키워드 클라우드
          _buildEnhancedKeywordCloud(keywords, importance, isDark),
        ],
      ),
    ).animate()
      .fadeIn(duration: 800.ms, delay: 600.ms)
      .slideY(begin: 0.1, curve: Curves.easeOut);
  }

  /// 향상된 키워드 클라우드
  static Widget _buildEnhancedKeywordCloud(
    List<String> keywords,
    Map<String, double> importance,
    bool isDark
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: keywords.asMap().entries.map((entry) {
        final index = entry.key;
        final keyword = entry.value;
        final weight = importance[keyword] ?? 0.5;
        final isHighPriority = weight > 0.7;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isHighPriority ? 16 : 12,
            vertical: isHighPriority ? 10 : 8,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isHighPriority
                ? isDark
                  ? [
                      TossDesignSystem.purple.withValues(alpha: 0.2),
                      TossDesignSystem.purple.withValues(alpha: 0.1),
                    ]
                  : [
                      TossDesignSystem.tossBlue.withValues(alpha: 0.15),
                      TossDesignSystem.tossBlue.withValues(alpha: 0.05),
                    ]
                : isDark
                  ? [
                      TossDesignSystem.grayDark400.withValues(alpha: 0.3),
                      TossDesignSystem.grayDark400.withValues(alpha: 0.1),
                    ]
                  : [
                      TossDesignSystem.gray100,
                      TossDesignSystem.gray50,
                    ],
            ),
            borderRadius: BorderRadius.circular(isHighPriority ? 16 : 12),
            border: Border.all(
              color: isHighPriority
                ? isDark
                  ? TossDesignSystem.purple.withValues(alpha: 0.4)
                  : TossDesignSystem.tossBlue.withValues(alpha: 0.3)
                : isDark
                  ? TossDesignSystem.grayDark500.withValues(alpha: 0.5)
                  : TossDesignSystem.gray200,
              width: isHighPriority ? 1.5 : 1,
            ),
            boxShadow: isHighPriority ? [
              BoxShadow(
                color: (isDark ? TossDesignSystem.purple : TossDesignSystem.tossBlue).withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isHighPriority) ...[
                Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: isDark ? TossDesignSystem.purple : TossDesignSystem.tossBlue,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                keyword,
                style: TextStyle(
                  fontSize: isHighPriority ? 16 : 14,
                  fontWeight: isHighPriority ? FontWeight.bold : FontWeight.w600,
                  color: isHighPriority
                    ? isDark
                      ? TossDesignSystem.purple
                      : TossDesignSystem.tossBlue
                    : isDark
                      ? TossDesignSystem.white
                      : TossDesignSystem.gray800,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ).animate(delay: Duration(milliseconds: 100 * index))
          .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut)
          .fadeIn();
      }).toList(),
    );
  }

  /// Lucky items grid
  static Widget buildLuckyItemsGrid({
    required List<Map<String, dynamic>> items,
    int crossAxisCount = 2,
    double? itemSize,  // Added for alternate signature
    List<Map<String, dynamic>>? luckyItems,  // Added for alternate signature
  }) {
    // Handle alternate signature
    final actualItems = luckyItems ?? items;

    if (actualItems.isEmpty) {
      return const Center(
        child: Text(
          '행운 아이템이 없습니다',
          style: TextStyle(color: TossDesignSystem.gray500),
        ),
      );
    }

    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: actualItems.length,
          itemBuilder: (context, index) {
            final item = actualItems[index];
            final type = item['type'] ?? '';
            final title = item['title'] ?? '';
            final value = item['value'] ?? '';

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? TossDesignSystem.grayDark200
                    : TossDesignSystem.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getLuckyItemColor(type).withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: TossDesignSystem.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getLuckyItemIcon(type),
                    size: itemSize ?? 32,
                    color: _getLuckyItemColor(type),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate()
              .scale(begin: const Offset(0.8, 0.8), duration: 600.ms)
              .fadeIn(duration: 400.ms, delay: Duration(milliseconds: index * 100));
          },
        );
      },
    );
  }

  /// Category cards implementation
  static Widget buildCategoryCards(
    Map<String, dynamic> categories, {
    required bool isDarkMode,
  }) {
    // total 카테고리 추출
    final totalData = categories['total'] as Map<String, dynamic>?;

    // 나머지 카테고리 데이터 정리 (5개: love, money, work, study, health)
    final categoryEntries = categories.entries.where((entry) =>
      entry.value is Map &&
      entry.value['score'] != null &&
      entry.key != 'total' // total은 별도로 표시
    ).toList();

    if (categoryEntries.isEmpty && totalData == null) {
      return Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? TossDesignSystem.grayDark200 : TossDesignSystem.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
          ),
        ),
        child: Center(
          child: Text(
            '카테고리 데이터를 불러오는 중...',
            style: TextStyle(
              color: isDarkMode ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // 총운 카드 (4자성어 표시)
        if (totalData != null) ...[
          _buildTotalFortuneCard(
            totalData: totalData,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 16),
        ],

        // 나머지 카테고리 세로 나열 (5개) - 각 카드가 전체 너비 사용
        Column(
          children: categoryEntries.map((entry) {
            final categoryKey = entry.key;
            final categoryData = entry.value as Map<String, dynamic>;
            final score = categoryData['score'] as int? ?? 0;
            final title = categoryData['title'] as String? ?? _getDefaultCategoryTitle(categoryKey);

            // advice 필드 사용 (300자 텍스트), 없으면 short 또는 fallback
            String description;
            final advice = categoryData['advice'];
            if (advice is String && advice.isNotEmpty) {
              description = advice;  // 300자 조언
            } else {
              description = categoryData['short'] as String? ?? _getDefaultCategoryShort(categoryKey, score);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCategoryCard(
                title: title,
                score: score,
                description: description,
                isDarkMode: isDarkMode,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 총운 카드 (4자성어 표시)
  static Widget _buildTotalFortuneCard({
    required Map<String, dynamic> totalData,
    required bool isDarkMode,
  }) {
    final score = totalData['score'] as int? ?? 0;
    final scoreColor = _getCategoryScoreColor(score, isDarkMode);

    // advice가 객체인 경우와 문자열인 경우 모두 처리
    String idiom = '만사형통';
    String description = '균형잡힌 하루를 보내세요';

    final advice = totalData['advice'];
    if (advice is Map<String, dynamic>) {
      idiom = advice['idiom'] as String? ?? '만사형통';
      description = advice['description'] as String? ?? '균형잡힌 하루를 보내세요';
    } else if (advice is String) {
      description = advice;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
            ? [
                TossDesignSystem.grayDark200,
                TossDesignSystem.grayDark300.withValues(alpha: 0.5),
              ]
            : [
                TossDesignSystem.white,
                scoreColor.withValues(alpha: 0.05),
              ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scoreColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더: 제목과 점수
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '오늘의 총운',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? TossDesignSystem.white : TossDesignSystem.gray900,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$score점',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: scoreColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 4자성어 (가장 눈에 띄게)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: scoreColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: scoreColor.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                idiom,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: scoreColor,
                  letterSpacing: 2,
                  height: 1.2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 설명 텍스트
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? TossDesignSystem.grayDark400 : TossDesignSystem.gray700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildCategoryCard({
    required String title,
    required int score,
    required String description,
    required bool isDarkMode,
  }) {
    final scoreColor = _getCategoryScoreColor(score, isDarkMode);

    return Container(
      width: double.infinity,  // 전체 너비 사용
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? TossDesignSystem.grayDark200 : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? TossDesignSystem.white : TossDesignSystem.gray900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$score점',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: scoreColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 높이 제한 없이 자연스럽게 표시 (300자 설명 모두 보임)
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: isDarkMode ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  static Color _getCategoryScoreColor(int score, bool isDarkMode) {
    if (score >= 80) {
      return isDarkMode ? TossDesignSystem.primaryGreen : TossDesignSystem.successGreen;
    } else if (score >= 60) {
      return isDarkMode ? TossDesignSystem.primaryBlue : TossDesignSystem.tossBlue;
    } else if (score >= 40) {
      return isDarkMode ? TossDesignSystem.primaryYellow : TossDesignSystem.warningOrange;
    } else {
      return isDarkMode ? TossDesignSystem.primaryRed : TossDesignSystem.errorRed;
    }
  }

  static String _getDefaultCategoryTitle(String key) {
    switch (key) {
      case 'love':
        return '연애운';
      case 'money':
        return '금전운';
      case 'work':
      case 'career':
        return '직장운';
      case 'study':
        return '학업운';
      case 'health':
        return '건강운';
      default:
        return key.toUpperCase();
    }
  }

  static String _getDefaultCategoryShort(String key, int score) {
    switch (key) {
      case 'love':
        return score >= 70 ? '순조로운 연애운' : score >= 50 ? '평범한 연애운' : '조심스러운 연애운';
      case 'money':
        return score >= 70 ? '안정적인 금전운' : score >= 50 ? '보통의 금전운' : '신중한 소비 필요';
      case 'work':
      case 'career':
        return score >= 70 ? '발전하는 직장운' : score >= 50 ? '평범한 직장운' : '주의가 필요한 시기';
      case 'study':
        return score >= 70 ? '향상되는 학업운' : score >= 50 ? '평범한 학업운' : '집중력 관리 필요';
      case 'health':
        return score >= 70 ? '건강한 컨디션' : score >= 50 ? '보통의 건강상태' : '건강 관리 필요';
      default:
        return score >= 70 ? '좋은 운세' : score >= 50 ? '보통 운세' : '주의 필요';
    }
  }

  static String _getDefaultFortuneSummary(String? zodiacAnimal, String? zodiacSign, String? mbti) {
    final elements = <String>[];

    if (zodiacAnimal != null) {
      elements.add('${zodiacAnimal}띠');
    }
    if (zodiacSign != null) {
      elements.add(zodiacSign);
    }
    if (mbti != null) {
      elements.add(mbti);
    }

    final profile = elements.isNotEmpty ? elements.join(', ') + '의 ' : '';

    return '${profile}오늘의 운세를 종합적으로 분석한 결과, 전반적으로 균형 잡힌 하루가 될 것으로 예상됩니다. 새로운 기회와 도전이 함께 찾아올 수 있으니 긍정적인 마음가짐을 유지하세요.';
  }

  static Widget _buildProfileTag(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
          ? TossDesignSystem.primaryBlue.withValues(alpha: 0.2)
          : TossDesignSystem.tossBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark ? TossDesignSystem.primaryBlue : TossDesignSystem.tossBlue,
        ),
      ),
    );
  }

  /// Fortune summary with user profile information
  static Widget buildTossStyleFortuneSummary({
    Map<String, dynamic>? fortuneSummary,
    String? userZodiacAnimal,
    String? userZodiacSign,
    String? userMBTI,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        // Extract summary from fortuneSummary data
        final summary = fortuneSummary?['summary'] as String? ??
                       fortuneSummary?['description'] as String? ??
                       _getDefaultFortuneSummary(userZodiacAnimal, userZodiacSign, userMBTI);

        final title = fortuneSummary?['title'] as String? ?? '오늘의 운세 요약';
        final score = fortuneSummary?['score'] as int? ?? 75;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 20,
                    color: isDark ? TossDesignSystem.primaryBlue : TossDesignSystem.tossBlue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryScoreColor(score, isDark).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$score점',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getCategoryScoreColor(score, isDark),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                summary,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray700,
                ),
              ),
              if (userZodiacAnimal != null || userZodiacSign != null || userMBTI != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (userZodiacAnimal != null) ...[
                      _buildProfileTag(userZodiacAnimal!, isDark),
                      const SizedBox(width: 8),
                    ],
                    if (userZodiacSign != null) ...[
                      _buildProfileTag(userZodiacSign!, isDark),
                      const SizedBox(width: 8),
                    ],
                    if (userMBTI != null) ...[
                      _buildProfileTag(userMBTI!, isDark),
                    ],
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Lucky tags with color, food, numbers, and direction
  static Widget buildTossStyleLuckyTags({
    String? luckyColor,
    String? luckyFood,
    List<String>? luckyNumbers,
    String? luckyDirection,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        // Collect all lucky items
        final luckyItems = <Widget>[];

        if (luckyColor != null && luckyColor.isNotEmpty) {
          luckyItems.add(_buildLuckyTag(
            icon: Icons.palette,
            label: '행운의 색상',
            value: luckyColor,
            isDark: isDark,
          ));
        }

        if (luckyFood != null && luckyFood.isNotEmpty) {
          luckyItems.add(_buildLuckyTag(
            icon: Icons.restaurant,
            label: '행운의 음식',
            value: luckyFood,
            isDark: isDark,
          ));
        }

        if (luckyNumbers != null && luckyNumbers.isNotEmpty) {
          luckyItems.add(_buildLuckyTag(
            icon: Icons.looks_one,
            label: '행운의 숫자',
            value: luckyNumbers.join(', '),
            isDark: isDark,
          ));
        }

        if (luckyDirection != null && luckyDirection.isNotEmpty) {
          luckyItems.add(_buildLuckyTag(
            icon: Icons.explore,
            label: '행운의 방향',
            value: luckyDirection,
            isDark: isDark,
          ));
        }

        // If no items, show default message
        if (luckyItems.isEmpty) {
          luckyItems.add(_buildLuckyTag(
            icon: Icons.star,
            label: '행운의 아이템',
            value: '오늘의 행운이 함께합니다',
            isDark: isDark,
          ));
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 20,
                    color: isDark ? TossDesignSystem.primaryYellow : TossDesignSystem.warningOrange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '행운의 요소들',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: luckyItems,
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildLuckyTag({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
          ? TossDesignSystem.primaryYellow.withValues(alpha: 0.2)
          : TossDesignSystem.warningOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
            ? TossDesignSystem.primaryYellow.withValues(alpha: 0.3)
            : TossDesignSystem.warningOrange.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? TossDesignSystem.primaryYellow : TossDesignSystem.warningOrange,
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Lucky outfit (placeholder implementation)
  static Widget buildTossStyleLuckyOutfit({
    required String title,
    required String description,
    required List<String> items,
    String? imagePath,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          height: 160,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (items.isNotEmpty) ...[
                  for (String item in items.take(2)) // Show max 2 items
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        item,
                        style: TextStyle(
                          color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ] else
                  Text(
                    '행운의 코디 준비 중...',
                    style: TextStyle(
                      color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Saju lucky items (placeholder implementation)
  static Widget buildSajuLuckyItems(
    Map<String, dynamic>? sajuInsight, {
    required bool isDarkMode,
  }) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? TossDesignSystem.grayDark200 : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
        ),
      ),
      child: Center(
        child: Text(
          '사주 행운 아이템 준비 중...',
          style: TextStyle(
            color: isDarkMode ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  /// Radar chart with real score data
  static Widget buildRadarChart({
    required Map<String, int> scores,
    double? size,
    Color? primaryColor,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          height: size ?? 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
            ),
          ),
          child: scores.isNotEmpty ?
            CustomPaint(
              size: Size((size ?? 200) - 32, (size ?? 200) - 32),
              painter: RadarChartPainter(
                scores: scores,
                isDark: isDark,
                primaryColor: primaryColor ?? (isDark ? TossDesignSystem.tossBlueDark : TossDesignSystem.tossBlue),
              ),
            ) :
            Center(
              child: Text(
                '레이더 차트 준비 중...',
                style: TextStyle(
                  color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                  fontSize: 16,
                ),
              ),
            ),
        );
      },
    );
  }

  /// Action checklist (placeholder implementation)
  static Widget buildActionChecklist(
    List<Map<String, dynamic>>? actions, {
    required bool isDarkMode,
  }) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? TossDesignSystem.grayDark200 : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
        ),
      ),
      child: Center(
        child: Text(
          '액션 체크리스트 준비 중...',
          style: TextStyle(
            color: isDarkMode ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  /// Weather fortune widget
  static Widget buildWeatherFortune(
    Map<String, dynamic>? weatherSummary,
    int score,
  ) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
            ),
            boxShadow: [
              BoxShadow(
                color: TossDesignSystem.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.wb_sunny,
                    color: TossDesignSystem.warningOrange,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '날씨 운세',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                weatherSummary?['description'] ?? '오늘의 날씨와 함께하는 운세를 확인해보세요.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray700,
                  height: 1.5,
                ),
              ),
              if (weatherSummary?['temperature'] != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '온도: ${weatherSummary!['temperature']}°C',
                    style: TextStyle(
                      fontSize: 12,
                      color: TossDesignSystem.tossBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ).animate()
          .fadeIn(duration: 600.ms)
          .slideY(begin: 0.1, curve: Curves.easeOut);
      },
    );
  }

  /// Shareable card (placeholder implementation)
  static Widget buildShareableCard(Map<String, dynamic>? shareCard) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          height: 180,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
            ),
          ),
          child: Center(
            child: Text(
              '공유 카드 준비 중...',
              style: TextStyle(
                color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Timeline chart with real hourly data
  static Widget buildTimelineChart({
    required List<int> hourlyScores,
    required int currentHour,
    required double height,
  }) {
    return _InteractiveTimelineChart(
      hourlyScores: hourlyScores,
      currentHour: currentHour,
      height: height,
    );
  }

  /// AI insights card with real data display
  static Widget buildAIInsightsCard({
    String? insight,
    List<String>? tips,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with AI icon
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI 인사이트',
                    style: TextStyle(
                      color: isDark ? TossDesignSystem.white : TossDesignSystem.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Main insight text
              if (insight != null && insight.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? TossDesignSystem.grayDark300.withValues(alpha: 0.5)
                        : TossDesignSystem.gray50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    insight,
                    style: TextStyle(
                      color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray700,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Tips section
              if (tips != null && tips.isNotEmpty) ...[
                Text(
                  '✨ 추천 팁',
                  style: TextStyle(
                    color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ...tips.take(3).map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(top: 6, right: 8),
                        decoration: BoxDecoration(
                          color: Color(0xFF6366f1),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          tip,
                          style: TextStyle(
                            color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],

              // Fallback when no data
              if ((insight == null || insight.isEmpty) && (tips == null || tips.isEmpty))
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'AI 인사이트 준비 중...',
                      style: TextStyle(
                        color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Celebrity list (placeholder implementation)
  static Widget buildTossStyleCelebrityList({
    required String title,
    required String subtitle,
    required List<Map<String, dynamic>> celebrities,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          height: 140,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFf59e0b), Color(0xFFef4444)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Celebrity list
              if (celebrities.isNotEmpty) ...[
                Expanded(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: celebrities.take(3).length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final celebrity = celebrities[index];
                      return Container(
                        width: 80,
                        child: Column(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? TossDesignSystem.grayDark300
                                    : TossDesignSystem.gray100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person,
                                color: isDark
                                    ? TossDesignSystem.grayDark600
                                    : TossDesignSystem.gray400,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              celebrity['name'] ?? '연예인',
                              style: TextStyle(
                                color: isDark
                                    ? TossDesignSystem.grayDark700
                                    : TossDesignSystem.gray700,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (celebrity['similarity'] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                '${celebrity['similarity']}%',
                                style: TextStyle(
                                  color: Color(0xFFf59e0b),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ] else
                Expanded(
                  child: Center(
                    child: Text(
                      '연예인 목록 준비 중...',
                      style: TextStyle(
                        color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Age fortune card (placeholder implementation)
  static Widget buildTossStyleAgeFortuneCard({
    required String ageGroup,
    required String title,
    required String description,
    String? zodiacAnimal,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          height: 140,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with zodiac icon
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF10b981), Color(0xFF059669)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.cake,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$ageGroup 운세',
                          style: TextStyle(
                            color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (zodiacAnimal != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            '$zodiacAnimal띠',
                            style: TextStyle(
                              color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Fortune content
              if (title.isNotEmpty && description.isNotEmpty) ...[
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    description,
                    style: TextStyle(
                      color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                      fontSize: 12,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ] else
                Expanded(
                  child: Center(
                    child: Text(
                      '연령별 운세 준비 중...',
                      style: TextStyle(
                        color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Share section (placeholder implementation)
  static Widget buildTossStyleShareSection({
    required String shareCount,
    required VoidCallback onShare,
    VoidCallback? onSave,
    VoidCallback? onReview,
    VoidCallback? onOtherFortune,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
            ),
          ),
          child: Column(
            children: [
              // 공유 카운트 텍스트
              Text(
                '$shareCount명이 공유했어요',
                style: TextStyle(
                  color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 16),

              // 3개 버튼
              Row(
                children: [
                  // 다시 뽑기
                  Expanded(
                    child: TossButton.secondary(
                      text: '다시 뽑기',
                      onPressed: onOtherFortune ?? () {},
                      size: TossButtonSize.medium,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // 스토리 다시 보기
                  Expanded(
                    child: TossButton.secondary(
                      text: '스토리 다시 보기',
                      onPressed: onReview ?? () {},
                      size: TossButtonSize.medium,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // 공유하기
                  Expanded(
                    child: TossButton.primary(
                      text: '공유하기',
                      onPressed: onShare,
                      size: TossButtonSize.medium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Custom painter for drawing timeline chart with real hourly scores
class TimelineChartPainter extends CustomPainter {
  final List<int> hourlyScores;
  final int currentHour;
  final bool isDark;

  TimelineChartPainter({
    required this.hourlyScores,
    required this.currentHour,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 8.0;
    final chartWidth = size.width - (padding * 2);
    final chartHeight = size.height - (padding * 2);

    if (hourlyScores.isEmpty) return;

    // Calculate data points for the line chart
    final points = <Offset>[];
    final maxScore = 100;
    final minScore = 20;

    for (int i = 0; i < hourlyScores.length; i++) {
      final x = padding + (i / (hourlyScores.length - 1)) * chartWidth;
      final normalizedScore = (hourlyScores[i] - minScore) / (maxScore - minScore);
      final y = padding + chartHeight - (normalizedScore * chartHeight);
      points.add(Offset(x, y));
    }

    // Draw gradient background
    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          (isDark ? TossDesignSystem.tossBlueDark : TossDesignSystem.tossBlue).withValues(alpha: 0.1),
          (isDark ? TossDesignSystem.tossBlueDark : TossDesignSystem.tossBlue).withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create path for the area under the curve
    final areaPath = Path();
    if (points.isNotEmpty) {
      areaPath.moveTo(points.first.dx, size.height - padding);
      for (final point in points) {
        areaPath.lineTo(point.dx, point.dy);
      }
      areaPath.lineTo(points.last.dx, size.height - padding);
      areaPath.close();
    }

    // Draw the area under the curve
    canvas.drawPath(areaPath, backgroundPaint);

    // Draw the main line
    final linePaint = Paint()
      ..color = isDark ? TossDesignSystem.tossBlueDark : TossDesignSystem.tossBlue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (points.length > 1) {
      final linePath = Path();
      linePath.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        // Create smooth curves between points
        if (i < points.length - 1) {
          final cp1 = Offset(
            points[i - 1].dx + (points[i].dx - points[i - 1].dx) * 0.5,
            points[i - 1].dy,
          );
          final cp2 = Offset(
            points[i - 1].dx + (points[i].dx - points[i - 1].dx) * 0.5,
            points[i].dy,
          );
          linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
        } else {
          linePath.lineTo(points[i].dx, points[i].dy);
        }
      }
      canvas.drawPath(linePath, linePaint);
    }

    // Draw points on the line
    final pointPaint = Paint()
      ..color = isDark ? TossDesignSystem.tossBlueDark : TossDesignSystem.tossBlue
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final point = points[i];

      // Draw larger point for current hour
      if (i == currentHour) {
        // Draw border
        canvas.drawCircle(point, 5, pointBorderPaint);
        // Draw center
        canvas.drawCircle(point, 3, pointPaint);

        // Draw current hour indicator line
        final indicatorPaint = Paint()
          ..color = (isDark ? TossDesignSystem.tossBlueDark : TossDesignSystem.tossBlue).withValues(alpha: 0.3)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;

        canvas.drawLine(
          Offset(point.dx, padding),
          Offset(point.dx, size.height - padding),
          indicatorPaint,
        );
      } else {
        // Draw smaller points for other hours
        canvas.drawCircle(point, 2, pointPaint);
      }
    }

    // Draw horizontal reference lines
    final gridPaint = Paint()
      ..color = (isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray300).withValues(alpha: 0.3)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw reference lines at 25%, 50%, 75% heights
    for (double ratio in [0.25, 0.5, 0.75]) {
      final y = padding + chartHeight * (1 - ratio);
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(TimelineChartPainter oldDelegate) {
    return oldDelegate.hourlyScores != hourlyScores ||
           oldDelegate.currentHour != currentHour ||
           oldDelegate.isDark != isDark;
  }
}

/// Custom painter for drawing radar chart with multiple score categories
class RadarChartPainter extends CustomPainter {
  final Map<String, int> scores;
  final bool isDark;
  final Color primaryColor;

  RadarChartPainter({
    required this.scores,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;
    final categories = scores.keys.toList();
    final values = scores.values.toList();
    final categoryCount = categories.length;

    if (categoryCount == 0) return;

    // Draw background grid
    final gridPaint = Paint()
      ..color = (isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray300).withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw concentric circles (grid lines)
    for (int i = 1; i <= 5; i++) {
      final gridRadius = radius * (i / 5.0);
      canvas.drawCircle(center, gridRadius, gridPaint);
    }

    // Draw category axes
    for (int i = 0; i < categoryCount; i++) {
      final angle = (i * 2 * math.pi / categoryCount) - (math.pi / 2);
      final end = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, end, gridPaint);

      // Draw category labels
      final textPainter = TextPainter(
        text: TextSpan(
          text: _getCategoryLabel(categories[i]),
          style: TextStyle(
            color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final labelOffset = Offset(
        center.dx + (radius + 15) * math.cos(angle) - textPainter.width / 2,
        center.dy + (radius + 15) * math.sin(angle) - textPainter.height / 2,
      );
      textPainter.paint(canvas, labelOffset);
    }

    // Draw data area
    final dataPath = Path();
    final dataPoints = <Offset>[];

    for (int i = 0; i < categoryCount; i++) {
      final score = values[i].clamp(0, 100);
      final angle = (i * 2 * math.pi / categoryCount) - (math.pi / 2);
      final distance = radius * (score / 100.0);
      final point = Offset(
        center.dx + distance * math.cos(angle),
        center.dy + distance * math.sin(angle),
      );
      dataPoints.add(point);

      if (i == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
    }
    dataPath.close();

    // Fill the data area
    final fillPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawPath(dataPath, fillPaint);

    // Draw the data outline
    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(dataPath, linePaint);

    // Draw data points
    final pointPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.white
      ..style = PaintingStyle.fill;

    for (final point in dataPoints) {
      canvas.drawCircle(point, 4, pointBorderPaint);
      canvas.drawCircle(point, 3, pointPaint);
    }
  }

  String _getCategoryLabel(String key) {
    switch (key.toLowerCase()) {
      case 'love':
      case '연애':
        return '연애';
      case 'money':
      case '금전':
        return '금전';
      case 'work':
      case 'career':
      case '직장':
        return '직장';
      case 'health':
      case '건강':
        return '건강';
      case 'study':
      case '학업':
        return '학업';
      default:
        return key.length > 2 ? key.substring(0, 2) : key;
    }
  }

  @override
  bool shouldRepaint(RadarChartPainter oldDelegate) {
    return oldDelegate.scores != scores ||
           oldDelegate.isDark != isDark ||
           oldDelegate.primaryColor != primaryColor;
  }
}

/// Interactive Timeline Chart with touch support
class _InteractiveTimelineChart extends StatefulWidget {
  final List<int> hourlyScores;
  final int currentHour;
  final double height;

  const _InteractiveTimelineChart({
    required this.hourlyScores,
    required this.currentHour,
    required this.height,
  });

  @override
  State<_InteractiveTimelineChart> createState() => _InteractiveTimelineChartState();
}

class _InteractiveTimelineChartState extends State<_InteractiveTimelineChart> {
  int? _touchedHour;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayHour = _touchedHour ?? widget.currentHour;
    final displayScore = widget.hourlyScores[displayHour];

    return Container(
      height: widget.height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
        ),
      ),
      child: Column(
        children: [
          // Chart header with current/touched hour indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _touchedHour != null ? '${displayHour}시' : '현재 ${displayHour}시',
                style: TextStyle(
                  color: isDark ? TossDesignSystem.white : TossDesignSystem.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${displayScore}점',
                style: TextStyle(
                  color: isDark ? TossDesignSystem.tossBlueDark : TossDesignSystem.tossBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Timeline chart with touch detection
          Expanded(
            child: GestureDetector(
              onTapDown: (details) {
                _handleTouch(details.localPosition);
              },
              onPanUpdate: (details) {
                _handleTouch(details.localPosition);
              },
              onPanEnd: (_) {
                setState(() {
                  _touchedHour = null;
                });
              },
              child: CustomPaint(
                size: Size.infinite,
                painter: TimelineChartPainter(
                  hourlyScores: widget.hourlyScores,
                  currentHour: _touchedHour ?? widget.currentHour,
                  isDark: isDark,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Time labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int i = 0; i < 24; i += 6)
                Text(
                  '${i.toString().padLeft(2, '0')}:00',
                  style: TextStyle(
                    color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleTouch(Offset position) {
    // Get the chart area dimensions (excluding padding)
    const padding = 16.0 + 8.0; // Container padding + chart internal padding
    final chartWidth = MediaQuery.of(context).size.width - (padding * 2);

    // Calculate which hour was touched
    final relativeX = position.dx - 8.0; // Internal chart padding
    final hourIndex = ((relativeX / chartWidth) * widget.hourlyScores.length).round();

    if (hourIndex >= 0 && hourIndex < widget.hourlyScores.length) {
      setState(() {
        _touchedHour = hourIndex;
      });
    }
  }
}