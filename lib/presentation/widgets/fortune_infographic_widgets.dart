import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/toss_design_system.dart';

/// Collection of infographic widgets for fortune completion page
class FortuneInfographicWidgets {

  /// 토스 스타일 메인 점수 표시 (깔끔한 흰 배경)
  static Widget buildTossStyleMainScore({
    required int score,
    required String message,
    double size = 280,
  }) {
    return Builder(
      builder: (context) => Container(
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
                color: TossDesignSystem.gray900,
                fontSize: size * 0.3,
                fontWeight: FontWeight.w300,
                letterSpacing: -4,
                height: 1.0,
              ),
            ).animate()
              .scale(begin: const Offset(0.8, 0.8), duration: 800.ms, curve: Curves.elasticOut)
              .fadeIn(duration: 600.ms),

            const SizedBox(height: 24),

            // 메시지
            Text(
              message,
              style: const TextStyle(
                color: TossDesignSystem.gray700,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ).animate()
              .fadeIn(duration: 800.ms, delay: 400.ms)
              .slideY(begin: 0.3, curve: Curves.easeOut),
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
    // 카테고리 데이터 정리
    final categoryEntries = categories.entries.where((entry) =>
      entry.value is Map &&
      entry.value['score'] != null &&
      entry.key != 'total' // total은 전체 점수로 제외
    ).toList();

    if (categoryEntries.isEmpty) {
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
        // 카테고리 그리드
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: categoryEntries.length,
          itemBuilder: (context, index) {
            final entry = categoryEntries[index];
            final categoryKey = entry.key;
            final categoryData = entry.value as Map<String, dynamic>;
            final score = categoryData['score'] as int? ?? 0;
            final title = categoryData['title'] as String? ?? _getDefaultCategoryTitle(categoryKey);
            final short = categoryData['short'] as String? ?? _getDefaultCategoryShort(categoryKey, score);

            return _buildCategoryCard(
              title: title,
              score: score,
              description: short,
              isDarkMode: isDarkMode,
            );
          },
        ),
      ],
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
      padding: const EdgeInsets.all(16),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? TossDesignSystem.white : TossDesignSystem.gray900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$score점',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: scoreColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
          ? TossDesignSystem.primaryBlue.withOpacity(0.2)
          : TossDesignSystem.tossBlue.withOpacity(0.1),
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
                      color: _getCategoryScoreColor(score, isDark).withOpacity(0.1),
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
                  color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray700,
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
          ? TossDesignSystem.primaryYellow.withOpacity(0.2)
          : TossDesignSystem.warningOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
            ? TossDesignSystem.primaryYellow.withOpacity(0.3)
            : TossDesignSystem.warningOrange.withOpacity(0.2),
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
                  color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray600,
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

  /// Radar chart (placeholder implementation)
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
          child: Center(
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

  /// Timeline chart (placeholder implementation)
  static Widget buildTimelineChart({
    required List<int> hourlyScores,
    required int currentHour,
    required double height,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          height: height,
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
              '타임라인 차트 준비 중...',
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

  /// AI insights card (placeholder implementation)
  static Widget buildAIInsightsCard({
    String? insight,
    List<String>? tips,
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
            child: Text(
              'AI 인사이트 카드 준비 중...',
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
                Text(
                  '연예인 목록 준비 중...',
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$ageGroup 운세',
                  style: TextStyle(
                    color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '연령별 운세 준비 중...',
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
          height: 100,
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
                  '공유하기',
                  style: TextStyle(
                    color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$shareCount명이 공유했어요',
                  style: TextStyle(
                    color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}