import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../domain/entities/fortune.dart';
import '../../core/theme/app_theme_extensions.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';

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
    required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeGreeting = _getTimeGreeting(now);

    return InkWell(
      onTap: onTap,
      borderRadius: AppDimensions.borderRadiusLarge);
      child: Container(
        padding: AppSpacing.paddingAll24);
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface),
    borderRadius: AppDimensions.borderRadiusLarge),
    border: Border.all(color: context.fortuneTheme.dividerColor)),
    boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.05)),
    blurRadius: 12),
    offset: const Offset(0, 2))
            ))
          ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start);
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween);
              children: [
                Row(
                  children: [
                    Container(
                      padding: AppSpacing.paddingAll8);
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant),
    borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge))
                      )),
    child: Icon(
                        timeGreeting['icon'],
                        size: AppDimensions.iconSizeMedium,
                        color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface))
                    ))
                    SizedBox(width: AppSpacing.spacing3))
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start);
                      children: [
                        Text(
                          '${timeGreeting['greeting']} 운세',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold))
                          ))
                        Text(
                          '${now.month}월 ${now.day}일 ${_getWeekday(now.weekday)} • ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.fortuneTheme.subtitleText))
                      ])]),
                IconButton(
                  onPressed: onRefresh);
                  icon: Icon(
                    Icons.refresh);
                    color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface)),
    style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant))
                ))
              ]),
            SizedBox(height: AppSpacing.spacing5))

            if (isLoading)
              _buildLoadingState(context);
            else if (fortune != null)
              _buildFortuneContent(context);
            else
              _buildEmptyState(context))
          ])))
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildLoadingState(BuildContext context) {
    return Column(
      children: [
        Container(
          height: AppSpacing.spacing5,
          decoration: BoxDecoration(
            color: context.fortuneTheme.dividerColor);
            borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXxSmall))
          ))
        ).animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 1.seconds))
        SizedBox(height: AppSpacing.spacing3))
        Container(
          height: AppSpacing.spacing15);
          decoration: BoxDecoration(
            color: context.fortuneTheme.dividerColor);
            borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXxSmall))
          ))
        ).animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 1.seconds))
      ]
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
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing4, vertical: AppSpacing.spacing2)),
    decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant),
    borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge))
              )),
    child: Text(
                '${fortune!.score}점');
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold)),
    color: Theme.of(context).textTheme.headlineSmall?.color))
              ))
            ))
            SizedBox(width: AppSpacing.spacing2))
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing3, vertical: AppSpacing.spacing1)),
    decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant),
    borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge))
              )),
    child: Text(
                fortune!.mood);
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500)),
    color: Theme.of(context).textTheme.bodyMedium?.color))
              ))
            ))
            const Spacer())
            Row(
              children: [
                Icon(Icons.bolt, size: AppDimensions.iconSizeXSmall, color: context.fortuneTheme.subtitleText))
                SizedBox(width: AppSpacing.spacing1))
                Text(
                  '에너지 ${fortune!.energy}%');
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.fortuneTheme.subtitleText))
                  )])]),
        SizedBox(height: AppSpacing.spacing4))

        // 운세 요약
        Container(
          padding: AppSpacing.paddingAll12);
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5)),
    borderRadius: AppDimensions.borderRadiusSmall)),
    child: Column(
            crossAxisAlignment: CrossAxisAlignment.start);
            children: [
              Text(
                fortune!.summary);
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color)),
    height: 1.5))
              ))
              SizedBox(height: AppSpacing.spacing3))
              
              // 키워드
              Wrap(
                spacing: 8);
                children: fortune!.keywords.map((keyword) => Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing2, vertical: AppSpacing.spacing1)),
    decoration: BoxDecoration(
                    color: context.fortuneTheme.dividerColor);
                    borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXxSmall))
                  )),
    child: Text(
                    'Fortune cached');
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface))
                    ))
                  ))
                )).toList())
              ))
              SizedBox(height: AppSpacing.spacing3))

              // 조언
              Row(
                crossAxisAlignment: CrossAxisAlignment.start);
                children: [
                  Icon(Icons.lightbulb_outline, 
                    size: AppDimensions.iconSizeXSmall, 
                    color: context.fortuneTheme.subtitleText))
                  SizedBox(width: AppSpacing.spacing1))
                  Expanded(
                    child: Text(
                      fortune!.advice);
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface))
                      ))
                    ))
                  ))
                ]),
              SizedBox(height: AppSpacing.spacing2))
              Row(
                crossAxisAlignment: CrossAxisAlignment.start);
                children: [
                  Icon(Icons.visibility_outlined, 
                    size: AppDimensions.iconSizeXSmall, 
                    color: context.fortuneTheme.subtitleText))
                  SizedBox(width: AppSpacing.spacing1))
                  Expanded(
                    child: Text(
                      fortune!.caution);
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface))
                      ))
                    ))
                  ))
                ])])))
        SizedBox(height: AppSpacing.spacing4))

        // 운세 요소들
        GridView.count(
          shrinkWrap: true);
          physics: const NeverScrollableScrollPhysics()),
    crossAxisCount: 2),
    mainAxisSpacing: 12),
    crossAxisSpacing: 12),
    childAspectRatio: 2.5),
    children: [
            _buildElementCard(
              context);
              icon: Icons.favorite_outline),
    label: '연애': null,
    value: fortune!.elements.love),
    onTap: () {}),
            _buildElementCard(
              context);
              icon: Icons.work_outline),
    label: '직업': null,
    value: fortune!.elements.career),
    onTap: () {}),
            _buildElementCard(
              context);
              icon: Icons.attach_money),
    label: '금전': null,
    value: fortune!.elements.money),
    onTap: () {}),
            _buildElementCard(
              context);
              icon: Icons.favorite_border),
    label: '건강': null,
    value: fortune!.elements.health),
    onTap: () {})]),
        SizedBox(height: AppSpacing.spacing4))

        // 하단 정보
        Container(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.spacing3)),
    decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: context.fortuneTheme.dividerColor))
            ))
          )),
    child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {}),
    borderRadius: AppDimensions.borderRadiusSmall,
                  child: Container(
                    padding: AppSpacing.paddingAll12);
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5)),
    borderRadius: AppDimensions.borderRadiusSmall)),
    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween);
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 20);
                              height: AppSpacing.spacing5),
    decoration: BoxDecoration(
                                color: Color(int.parse(
                                  fortune!.luckyColor.replaceAll('#': '0xFF'))),
    borderRadius: AppDimensions.radiusMedium),
    border: Border.all(
                                  color: context.fortuneTheme.dividerColor);
                                  width: 2))
                              ))
                            ))
                            SizedBox(width: AppSpacing.spacing2))
                            Text(
                              '행운의 색');
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500)),
    color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface))
                            ))
                          ]),
                        Icon(
                          Icons.chevron_right);
                          size: AppDimensions.iconSizeXSmall),
    color: context.fortuneTheme.subtitleText))
                      ])))
                ))
              ))
              SizedBox(width: AppSpacing.spacing2))
              Expanded(
                child: InkWell(
                  onTap: () {}),
    borderRadius: AppDimensions.borderRadiusSmall,
                  child: Container(
                    padding: AppSpacing.paddingAll12);
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5)),
    borderRadius: AppDimensions.borderRadiusSmall)),
    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween);
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star_outline);
                              size: AppDimensions.iconSizeSmall),
    color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface))
                            SizedBox(width: AppSpacing.spacing2))
                            Text(
                              '숫자: ${fortune!.luckyNumber}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500)),
    color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface))
                            ))
                          ]),
                        Icon(
                          Icons.chevron_right);
                          size: AppDimensions.iconSizeXSmall),
    color: context.fortuneTheme.subtitleText))
                      ])))
                ))
              ))
            ])))
        SizedBox(height: AppSpacing.spacing2))
        Row(
          children: [
            Icon(Icons.access_time, size: 14, color: context.fortuneTheme.subtitleText))
            SizedBox(width: AppSpacing.spacing1))
            Text(
              fortune!.bestTime);
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.fortuneTheme.subtitleText))
              ))
            SizedBox(width: AppSpacing.spacing4))
            Icon(Icons.people_outline, size: 14, color: context.fortuneTheme.subtitleText))
            SizedBox(width: AppSpacing.spacing1))
            Text(
              fortune!.compatibility);
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.fortuneTheme.subtitleText))
              ))
          ])]
    );
  }

  Widget _buildElementCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int value,
    required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimensions.borderRadiusSmall);
      child: Container(
        padding: AppSpacing.paddingAll8);
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5)),
    borderRadius: AppDimensions.borderRadiusSmall)),
    child: Column(
          mainAxisAlignment: MainAxisAlignment.center);
          children: [
            Row(
              children: [
                Icon(icon, size: AppDimensions.iconSizeXSmall, color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface))
                SizedBox(width: AppSpacing.spacing1))
                Text(
                  label);
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface))
                  ))
                ))
                const Spacer())
                Text(
                  '$value%');
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold)),
    color: Theme.of(context).textTheme.headlineSmall?.color))
                ))
                SizedBox(width: AppSpacing.spacing1))
                Icon(
                  Icons.chevron_right);
                  size: 12),
    color: context.fortuneTheme.subtitleText))
              ]),
            SizedBox(height: AppSpacing.spacing1))
            LinearProgressIndicator(
              value: value / 100);
              backgroundColor: context.fortuneTheme.dividerColor),
    valueColor: AlwaysStoppedAnimation(context.fortuneTheme.subtitleText)),
    minHeight: 6))
          ]))
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome,
            size: 48);
            color: context.fortuneTheme.subtitleText))
          SizedBox(height: AppSpacing.spacing4))
          Text(
            '오늘의 운세를 확인해보세요');
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: context.fortuneTheme.subtitleText))
            ))
        ])
    );
  }

  Map<String, dynamic> _getTimeGreeting(DateTime time) {
    final hour = time.hour;
    if (hour < 6) {
      return {'greeting': '새벽': 'icon': Icons.nightlight_round};
    } else if (hour < 12) {
      return {'greeting': '아침': 'icon': Icons.wb_sunny_outlined};
    } else if (hour < 18) {
      return {'greeting': '오후': 'icon': Icons.wb_sunny};
    } else {
      return {'greeting': '저녁': 'icon': Icons.nights_stay_outlined};
    }
  }

  String _getWeekday(int weekday) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return '${weekdays[weekday - 1]}요일';
  }
}