import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/design_system.dart';

/// 웰니스 메인 페이지
class WellnessPage extends ConsumerWidget {
  const WellnessPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: colors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '웰니스',
          style: context.heading3.copyWith(color: colors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 인사말 섹션
              _buildGreetingSection(context, colors),
              const SizedBox(height: DSSpacing.xl),

              // 오늘의 무드
              _buildSectionTitle(context, colors, '오늘의 기분'),
              const SizedBox(height: 12),
              _buildMoodSelector(context, colors),
              const SizedBox(height: DSSpacing.xl),

              // 웰니스 메뉴
              _buildSectionTitle(context, colors, '마음 챙김'),
              const SizedBox(height: 12),
              _buildWellnessMenu(context, colors),
              const SizedBox(height: DSSpacing.xl),

              // 오늘의 감사
              _buildSectionTitle(context, colors, '오늘 감사한 것'),
              const SizedBox(height: 12),
              _buildGratitudeCard(context, colors),
              const SizedBox(height: DSSpacing.xl),

              // 주간 통계
              _buildSectionTitle(context, colors, '이번 주 기록'),
              const SizedBox(height: 12),
              _buildWeeklyStats(context, colors),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection(BuildContext context, DSColorScheme colors) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = '좋은 아침이에요';
    } else if (hour < 18) {
      greeting = '좋은 오후예요';
    } else {
      greeting = '좋은 저녁이에요';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: context.heading2.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: DSSpacing.sm),
        Text(
          '오늘 하루도 나를 돌보는 시간을 가져보세요',
          style: context.bodyMedium.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    DSColorScheme colors,
    String title,
  ) {
    return Text(
      title,
      style: context.bodyLarge.copyWith(
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
    );
  }

  Widget _buildMoodSelector(BuildContext context, DSColorScheme colors) {
    final moods = [
      ('very_bad', '😢', '매우 나쁨'),
      ('bad', '😕', '나쁨'),
      ('neutral', '😐', '보통'),
      ('good', '🙂', '좋음'),
      ('very_good', '😄', '매우 좋음'),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: moods.map((mood) {
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              // TODO: 무드 저장 기능 구현
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('오늘의 기분: ${mood.$3}'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            child: Column(
              children: [
                Text(
                  mood.$2,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: DSSpacing.xs),
                Text(
                  mood.$3,
                  style: context.labelLarge.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWellnessMenu(BuildContext context, DSColorScheme colors) {
    return Column(
      children: [
        _buildMenuCard(
          context: context,
          colors: colors,
          icon: Icons.self_improvement_rounded,
          iconColor: const Color(0xFF7C3AED),
          title: '호흡 명상',
          subtitle: '4-7-8 호흡법으로 마음을 진정시키세요',
          onTap: () {
            HapticFeedback.lightImpact();
            context.push('/wellness/meditation');
          },
        ),
        const SizedBox(height: 12),
        _buildMenuCard(
          context: context,
          colors: colors,
          icon: Icons.favorite_outline_rounded,
          iconColor: const Color(0xFFEC4899),
          title: '감사 일기',
          subtitle: '오늘 감사한 일 3가지를 기록하세요',
          onTap: () {
            HapticFeedback.lightImpact();
            // TODO: 감사 일기 페이지로 이동
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('감사 일기 기능이 곧 추가됩니다'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildMenuCard(
          context: context,
          colors: colors,
          icon: Icons.insights_rounded,
          iconColor: const Color(0xFF06B6D4),
          title: '무드 트래커',
          subtitle: '감정 패턴을 파악하고 나를 이해하세요',
          onTap: () {
            HapticFeedback.lightImpact();
            // TODO: 무드 트래커 페이지로 이동
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('무드 트래커 기능이 곧 추가됩니다'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required DSColorScheme colors,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: DSSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.xs),
                  Text(
                    subtitle,
                    style: context.labelLarge.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGratitudeCard(BuildContext context, DSColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFBBF24).withValues(alpha: 0.1),
            const Color(0xFFF59E0B).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFBBF24).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 20)),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '오늘의 감사',
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          ...[1, 2, 3].map((index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.textTertiary,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$index',
                        style: context.labelLarge.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.border),
                      ),
                      child: Text(
                        '감사한 일을 입력하세요...',
                        style: context.bodyMedium.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWeeklyStats(BuildContext context, DSColorScheme colors) {
    final days = ['월', '화', '수', '목', '금', '토', '일'];
    final today = DateTime.now().weekday - 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.asMap().entries.map((entry) {
              final isToday = entry.key == today;
              final isPast = entry.key < today;

              return Column(
                children: [
                  Text(
                    entry.value,
                    style: context.labelLarge.copyWith(
                      color: isToday ? colors.accent : colors.textTertiary,
                      fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.sm),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isToday
                          ? colors.accent
                          : isPast
                              ? colors.accent.withValues(alpha: 0.2)
                              : colors.surfaceSecondary,
                      border: isToday ? null : Border.all(color: colors.border),
                    ),
                    child: isPast || isToday
                        ? Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: isToday ? Colors.white : colors.accent,
                          )
                        : null,
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: DSSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xFFF97316),
                size: 20,
              ),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '${today + 1}일 연속 기록 중!',
                style: context.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
