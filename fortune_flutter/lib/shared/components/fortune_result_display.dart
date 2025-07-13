import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/fortune.dart';
import '../glassmorphism/glass_container.dart';
import '../glassmorphism/glass_effects.dart';
import '../../core/theme/app_theme.dart';

class FortuneResultDisplay extends StatelessWidget {
  final Fortune fortune;
  final Widget? headerWidget;
  final List<Widget>? additionalSections;
  final VoidCallback? onShare;

  const FortuneResultDisplay({
    Key? key,
    required this.fortune,
    this.headerWidget,
    this.additionalSections,
    this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Widget (optional custom header)
          if (headerWidget != null) headerWidget!,

          // Main Fortune Content
          _buildMainContent(context),

          // Score Breakdown (if available)
          if (fortune.scoreBreakdown != null && fortune.scoreBreakdown!.isNotEmpty)
            _buildScoreBreakdown(context),

          // Lucky Items (if available)
          if (fortune.luckyItems != null && fortune.luckyItems!.isNotEmpty)
            _buildLuckyItems(context),

          // Recommendations (if available)
          if (fortune.recommendations != null && fortune.recommendations!.isNotEmpty)
            _buildRecommendations(context),

          // Additional Sections (custom sections from specific fortune pages)
          if (additionalSections != null)
            ...additionalSections!,

          // Share Button
          _buildShareButton(context),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Overall Score (if available)
            if (fortune.overallScore != null)
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: _getScoreGradientColors(fortune.overallScore!),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getScoreGradientColors(fortune.overallScore!).first.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${fortune.overallScore}점',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ).animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .fade(),

            const SizedBox(height: 24),

            // Category Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _getCategoryDisplayName(fortune.category ?? fortune.type),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Main Content
            Text(
              fortune.content,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),

            // Description (if different from content)
            if (fortune.description != null && fortune.description != fortune.content) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  fortune.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Date
            Text(
              '생성일: ${_formatDate(fortune.createdAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    ).animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildScoreBreakdown(BuildContext context) {
    final theme = Theme.of(context);
    final scores = fortune.scoreBreakdown!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassCard(
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
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.analytics_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '상세 점수',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...scores.entries.map((entry) {
              final score = entry.value is int ? entry.value as int : 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        entry.key,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: Row(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                Container(
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 1000),
                                  height: 20,
                                  width: MediaQuery.of(context).size.width * 0.4 * score / 100,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: _getScoreGradientColors(score),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$score점',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getScoreColor(score),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    ).animate()
        .fadeIn(duration: 500.ms, delay: 200.ms)
        .slideX(begin: 0.1, end: 0);
  }

  Widget _buildLuckyItems(BuildContext context) {
    final theme = Theme.of(context);
    final items = fortune.luckyItems!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ShimmerGlass(
        shimmerColor: Colors.amber,
        borderRadius: BorderRadius.circular(24),
        child: GlassCard(
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
                        colors: [Colors.amber.shade400, Colors.amber.shade600],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '행운 아이템',
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: items.entries.map((entry) {
                  final value = entry.value;
                  String displayValue = '';
                  
                  if (value is List) {
                    displayValue = value.join(', ');
                  } else {
                    displayValue = value.toString();
                  }

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                          theme.colorScheme.primary.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getLuckyItemIcon(entry.key),
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                entry.key,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                displayValue,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 500.ms, delay: 400.ms)
        .slideX(begin: -0.1, end: 0);
  }

  Widget _buildRecommendations(BuildContext context) {
    final theme = Theme.of(context);
    final recommendations = fortune.recommendations!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassCard(
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
                      colors: [Colors.green.shade400, Colors.green.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.tips_and_updates_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '추천 사항',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recommendations.asMap().entries.map((entry) {
              final index = entry.key;
              final recommendation = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        recommendation,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ).animate()
                  .fadeIn(delay: Duration(milliseconds: 600 + (index * 100)))
                  .slideX(begin: 0.1, end: 0);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassButton(
        onPressed: onShare ?? () {
          // Default share implementation
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('공유 기능이 곧 추가됩니다!')),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.share_rounded),
              const SizedBox(width: 8),
              Text(
                '운세 공유하기',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 500.ms, delay: 800.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }

  List<Color> _getScoreGradientColors(int score) {
    if (score >= 80) {
      return [Colors.green.shade400, Colors.green.shade600];
    } else if (score >= 60) {
      return [Colors.blue.shade400, Colors.blue.shade600];
    } else if (score >= 40) {
      return [Colors.orange.shade400, Colors.orange.shade600];
    } else {
      return [Colors.red.shade400, Colors.red.shade600];
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green.shade600;
    if (score >= 60) return Colors.blue.shade600;
    if (score >= 40) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  IconData _getLuckyItemIcon(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('숫자')) return Icons.looks_one_rounded;
    if (lowerType.contains('색') || lowerType.contains('컬러')) return Icons.palette_rounded;
    if (lowerType.contains('방향')) return Icons.explore_rounded;
    if (lowerType.contains('시간')) return Icons.access_time_rounded;
    if (lowerType.contains('음식')) return Icons.restaurant_rounded;
    if (lowerType.contains('향') || lowerType.contains('향수')) return Icons.water_drop_rounded;
    if (lowerType.contains('꽃')) return Icons.local_florist_rounded;
    if (lowerType.contains('액세서리')) return Icons.diamond_rounded;
    return Icons.star_rounded;
  }

  String _getCategoryDisplayName(String category) {
    final categoryMap = {
      'daily': '데일리 운세',
      'wealth': '재물운',
      'love': '연애운',
      'career': '직업운',
      'saju': '사주팔자',
      'compatibility': '궁합',
      'mbti': 'MBTI 운세',
      'zodiac': '별자리 운세',
      'tarot': '타로 카드',
    };
    return categoryMap[category] ?? category;
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일 ${date.hour}시 ${date.minute}분';
  }
}

// Glass Button Widget
class GlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry? padding;

  const GlassButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: GlassContainer(
          padding: padding ?? const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(16),
          blur: 10,
          child: child,
        ),
      ),
    );
  }
}