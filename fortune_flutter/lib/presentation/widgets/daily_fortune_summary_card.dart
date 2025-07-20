import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../domain/entities/fortune.dart';
import '../../core/theme/app_theme_extensions.dart';

class DailyFortuneSummaryCard extends StatelessWidget {
  final DailyFortune? fortune;
  final bool isLoading;
  final VoidCallback onTap;
  final String? userName;

  const DailyFortuneSummaryCard({
    super.key,
    this.fortune,
    required this.isLoading,
    required this.onTap,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeGreeting = _getTimeGreeting(now);

    return InkWell(
      onTap: fortune != null ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.98),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.fortuneTheme.dividerColor.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 - 날짜와 시간
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      timeGreeting['icon'] as IconData,
                      size: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      userName != null && userName!.isNotEmpty 
                          ? '$userName님의 ${timeGreeting['greeting']} 운세'
                          : '${timeGreeting['greeting']} 운세',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${now.month}월 ${now.day}일 ${_getWeekday(now.weekday)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (isLoading)
              _buildLoadingState(context)
            else if (fortune != null)
              _buildFortuneContent(context)
            else
              _buildEmptyState(context),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildLoadingState(BuildContext context) {
    return Column(
      children: [
        // Score and keywords loading
        Row(
          children: [
            Container(
              width: 80,
              height: 32,
              decoration: BoxDecoration(
                color: context.fortuneTheme.dividerColor,
                borderRadius: BorderRadius.circular(16),
              ),
            ).animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 1.5.seconds),
            const SizedBox(width: 10),
            Container(
              width: 60,
              height: 28,
              decoration: BoxDecoration(
                color: context.fortuneTheme.dividerColor,
                borderRadius: BorderRadius.circular(14),
              ),
            ).animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 1.5.seconds, delay: 0.2.seconds),
            const SizedBox(width: 6),
            Container(
              width: 60,
              height: 28,
              decoration: BoxDecoration(
                color: context.fortuneTheme.dividerColor,
                borderRadius: BorderRadius.circular(14),
              ),
            ).animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 1.5.seconds, delay: 0.4.seconds),
          ],
        ),
        const SizedBox(height: 16),
        // Summary loading
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: context.fortuneTheme.dividerColor,
            borderRadius: BorderRadius.circular(12),
          ),
        ).animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 1.5.seconds),
        const SizedBox(height: 16),
        // Elements loading
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: context.fortuneTheme.dividerColor,
            borderRadius: BorderRadius.circular(12),
          ),
        ).animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 1.5.seconds, delay: 0.3.seconds),
        const SizedBox(height: 16),
        // Lucky info loading
        Row(
          children: [
            Expanded(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: context.fortuneTheme.dividerColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 1.5.seconds),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: context.fortuneTheme.dividerColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 1.5.seconds, delay: 0.2.seconds),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: context.fortuneTheme.dividerColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 1.5.seconds, delay: 0.4.seconds),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFortuneContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 점수와 키워드
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 점수 섹션
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getScoreGradient(fortune!.score),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: _getScoreGradient(fortune!.score)[0].withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.stars_rounded, size: 20, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        '오늘의 점수',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${fortune!.score}점',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 키워드 섹션 - Wrap으로 변경
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: fortune!.keywords.map((keyword) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  keyword,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 운세 요약
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fortune!.summary,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  fontSize: 15,
                ),
              ),
              if (fortune!.summary.length > 100) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '더보기',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 운세 요소들 (사랑, 건강, 돈, 일)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.fortuneTheme.dividerColor.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              _buildFortuneElement(context, '사랑', Icons.favorite_rounded, fortune!.elements.love, Color(0xFFE91E63)),
              const SizedBox(height: 12),
              _buildFortuneElement(context, '건강', Icons.spa_rounded, fortune!.elements.health, Color(0xFF4CAF50)),
              const SizedBox(height: 12),
              _buildFortuneElement(context, '재물', Icons.account_balance_wallet_rounded, fortune!.elements.money, Color(0xFFFFC107)),
              const SizedBox(height: 12),
              _buildFortuneElement(context, '직장', Icons.business_center_rounded, fortune!.elements.career, Color(0xFF2196F3)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 행운의 정보들
        Row(
          children: [
            Expanded(
              child: _buildLuckyInfo(
                context,
                '행운의 색',
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Color(int.parse(
                      fortune!.luckyColor.replaceAll('#', '0xFF')
                    )),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.fortuneTheme.dividerColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildLuckyInfo(
                context,
                '행운의 숫자',
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${fortune!.luckyNumber}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildLuckyInfo(
                context,
                '최고의 시간',
                Icon(
                  Icons.access_time,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                fortune!.bestTime,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 조언과 주의사항
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, size: 16, color: Colors.green),
                        const SizedBox(width: 6),
                        Text(
                          '오늘의 조언',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      fortune!.advice,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.4,
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
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_outlined, size: 16, color: Colors.orange),
                        const SizedBox(width: 6),
                        Text(
                          '주의할 점',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      fortune!.caution,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFortuneElement(BuildContext context, String label, IconData icon, int score, Color color) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: score / 100,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.8),
                        color,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$score%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLuckyInfo(BuildContext context, String label, Widget icon, [String? value]) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          icon,
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.fortuneTheme.subtitleText,
            ),
          ),
          if (value != null) ...[
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    // When empty, it means fortune is being loaded, so show loading state
    return _buildLoadingState(context);
  }

  List<Color> _getScoreGradient(int score) {
    if (score >= 80) {
      return [Color(0xFFFF6B6B), Color(0xFFFECA57)];
    } else if (score >= 60) {
      return [Color(0xFF4ECDC4), Color(0xFF44A08D)];
    } else if (score >= 40) {
      return [Color(0xFF667EEA), Color(0xFF764BA2)];
    } else {
      return [Color(0xFF868F96), Color(0xFF596164)];
    }
  }

  Map<String, dynamic> _getTimeGreeting(DateTime time) {
    final hour = time.hour;
    if (hour < 6) {
      return {'greeting': '새벽', 'icon': Icons.nightlight_round};
    } else if (hour < 12) {
      return {'greeting': '오전', 'icon': Icons.wb_sunny_outlined};
    } else if (hour < 18) {
      return {'greeting': '오후', 'icon': Icons.wb_sunny};
    } else {
      return {'greeting': '저녁', 'icon': Icons.nights_stay_outlined};
    }
  }

  String _getWeekday(int weekday) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return '${weekdays[weekday - 1]}요일';
  }
}