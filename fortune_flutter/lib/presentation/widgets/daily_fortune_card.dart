import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../domain/entities/fortune.dart';
import '../../core/theme/app_theme_extensions.dart';

class DailyFortuneCard extends StatelessWidget {
  final DailyFortune? fortune;
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback onRefresh;

  const DailyFortuneCard({
    super.key,
    this.fortune,
    required this.isLoading,
    required this.onTap,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeGreeting = _getTimeGreeting(now);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.fortuneTheme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        timeGreeting['icon'] as IconData,
                        size: 24,
                        color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${timeGreeting['greeting']} 운세',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${now.month}월 ${now.day}일 ${_getWeekday(now.weekday)} • ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.fortuneTheme.subtitleText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: onRefresh,
                  icon: Icon(
                    Icons.refresh,
                    color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
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
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildLoadingState(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 20,
          decoration: BoxDecoration(
            color: context.fortuneTheme.dividerColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ).animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 1.seconds),
        const SizedBox(height: 12),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: context.fortuneTheme.dividerColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ).animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 1.seconds),
      ],
    );
  }

  Widget _buildFortuneContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 점수와 기분
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${fortune!.score}점',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.headlineSmall?.color,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                fortune!.mood,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.bolt, size: 16, color: context.fortuneTheme.subtitleText),
                const SizedBox(width: 4),
                Text(
                  '에너지 ${fortune!.energy}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.fortuneTheme.subtitleText,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 운세 요약
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fortune!.summary,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              
              // 키워드
              Wrap(
                spacing: 8,
                children: fortune!.keywords.map((keyword) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.fortuneTheme.dividerColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '#$keyword',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 12),

              // 조언
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, 
                    size: 16, 
                    color: context.fortuneTheme.subtitleText,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      fortune!.advice,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.visibility_outlined, 
                    size: 16, 
                    color: context.fortuneTheme.subtitleText,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      fortune!.caution,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 운세 요소들
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: [
            _buildElementCard(
              context,
              icon: Icons.favorite_outline,
              label: '연애',
              value: fortune!.elements.love,
              onTap: () {},
            ),
            _buildElementCard(
              context,
              icon: Icons.work_outline,
              label: '직업',
              value: fortune!.elements.career,
              onTap: () {},
            ),
            _buildElementCard(
              context,
              icon: Icons.attach_money,
              label: '금전',
              value: fortune!.elements.money,
              onTap: () {},
            ),
            _buildElementCard(
              context,
              icon: Icons.favorite_border,
              label: '건강',
              value: fortune!.elements.health,
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 하단 정보
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: context.fortuneTheme.dividerColor),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Color(int.parse(
                                  fortune!.luckyColor.replaceAll('#', '0xFF')
                                )),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: context.fortuneTheme.dividerColor,
                                  width: 2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '행운의 색',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: context.fortuneTheme.subtitleText,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star_outline,
                              size: 20,
                              color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '행운의 숫자: ${fortune!.luckyNumber}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: context.fortuneTheme.subtitleText,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.access_time, size: 14, color: context.fortuneTheme.subtitleText),
            const SizedBox(width: 4),
            Text(
              fortune!.bestTime,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.fortuneTheme.subtitleText,
              ),
            ),
            const SizedBox(width: 16),
            Icon(Icons.people_outline, size: 14, color: context.fortuneTheme.subtitleText),
            const SizedBox(width: 4),
            Text(
              fortune!.compatibility,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.fortuneTheme.subtitleText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildElementCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  '$value%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.headlineSmall?.color,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 12,
                  color: context.fortuneTheme.subtitleText,
                ),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: value / 100,
              backgroundColor: context.fortuneTheme.dividerColor,
              valueColor: AlwaysStoppedAnimation(context.fortuneTheme.subtitleText),
              minHeight: 6,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome,
            size: 48,
            color: context.fortuneTheme.subtitleText,
          ),
          const SizedBox(height: 16),
          Text(
            '오늘의 운세를 확인해보세요',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: context.fortuneTheme.subtitleText,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getTimeGreeting(DateTime time) {
    final hour = time.hour;
    if (hour < 6) {
      return {'greeting': '새벽', 'icon': Icons.nightlight_round};
    } else if (hour < 12) {
      return {'greeting': '아침', 'icon': Icons.wb_sunny_outlined};
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