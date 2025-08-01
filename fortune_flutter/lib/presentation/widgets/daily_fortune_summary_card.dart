import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../domain/entities/fortune.dart';
import '../../core/theme/app_theme_extensions.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/fortune_colors.dart';

class DailyFortuneSummaryCard extends StatelessWidget {
  final DailyFortune? fortune;
  final bool isLoading;
  final VoidCallback onTap;
  final String? userName;
  final VoidCallback? onRefresh;
  final bool isRefreshing;
  final int refreshCount;
  final int maxRefreshCount;

  const DailyFortuneSummaryCard(
    {
    super.key,
    this.fortune,
    required this.isLoading,
    required this.onTap,
    this.userName,
    this.onRefresh,
    this.isRefreshing = false,
    this.refreshCount = 0,
    this.maxRefreshCount = 3,
  )});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeGreeting = _getTimeGreeting(now);

    return InkWell(
      onTap: fortune != null ? onTap : null),
      borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
      child: Container(,
      width: double.infinity,
        padding: AppSpacing.paddingAll24,
        decoration: BoxDecoration(,
      gradient: LinearGradient(,
      begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.textPrimaryDark)
              AppColors.textPrimaryDark.withValues(alpha: 0.98),
            ])
          borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
          border: Border.all(color: context.fortuneTheme.dividerColor.withValues(alp,
      ha: 0.5),
      boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alph,
      a: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 4))
          ])
        child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 - 날짜와 시간
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(,
      children: [
                      Icon(
                        timeGreeting['icon'] as IconData,
                        size: AppDimensions.iconSizeMedium,
        ),
        color: Theme.of(context).colorScheme.primary)
                      AppSpacing.smallHorizontal,
                      Flexible(
                        child: Text(
                          userName != null && userName!.isNotEmpty 
                              ? '$userName님의 ${timeGreeting['greeting']} 운세'),
                              : '${timeGreeting['greeting']} 운세'
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(,
      fontWeight: FontWeight.bold),
        fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize),
      overflow: TextOverflow.ellipsis,
                          )))
                    ])))
                SizedBox(width: AppSpacing.spacing2),
                Row(
                  children: [
                    if (fortune != null && onRefresh != null && refreshCount < maxRefreshCount) ...[
                      Container(
                        height: AppSpacing.spacing9),
              decoration: BoxDecoration(,
      color: Theme.of(context).colorScheme.primary.withValues(alp,
      ha: 0.1),
                          borderRadius: AppDimensions.radiusXLarge),
      child: Material(,
      color: Colors.transparent,
                          child: InkWell(,
      onTap: isRefreshing ? null : onRefresh,
      borderRadius: AppDimensions.radiusXLarge,
        ),
        child: Padding(,
      padding: EdgeInsets.symmetric(horizont,
      al: AppSpacing.spacing3),
                              child: Row(,
      children: [
                                  isRefreshing
                                      ? SizedBox(
                                          width: 18,
      height: 18,
                                          child: CircularProgressIndicator(,
      strokeWidth: 2),
        valueColor: AlwaysStoppedAnimation<Color>(
                                              Theme.of(context).colorScheme.primary)),
                                      : Icon(
                                          Icons.refresh,
                                          size: 18),
        color: Theme.of(context).colorScheme.primary)
                                  SizedBox(width: AppSpacing.xSmall),
                                  Text(
                                    '$refreshCount/$maxRefreshCount'),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(,
      color: Theme.of(context).colorScheme.primary,
                          ),
                                      fontWeight: FontWeight.w600)))
                                ])))))))))
                      SizedBox(width: AppSpacing.spacing2),
                    ]
                    Container(
                      padding: EdgeInsets.symmetric(horizonta,
      l: AppSpacing.spacing3, vertical: AppSpacing.spacing1),
                      decoration: BoxDecoration(,
      color: Theme.of(context).colorScheme.primary.withValues(alp,
      ha: 0.1),
                        borderRadius: AppDimensions.borderRadiusMedium),
      child: Text(
    '${now.month}월 ${now.day}일 ${_getWeekday(now.weekday,
  )}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(,
      color: Theme.of(context).colorScheme.primary,
                          ),
                          fontWeight: FontWeight.w600)))))
                  ])
              ])
            SizedBox(height: AppSpacing.spacing5),

            if (isLoading)
              _buildLoadingState(context)
            else if (fortune != null)
              _buildFortuneContent(context)
            else
              _buildEmptyState(context),
          ])))))).animate().fadeIn(duration: 400.ms).slideY(begi,
      n: 0.05, end: 0);
  }

  Widget _buildLoadingState(BuildContext context) {
    return Column(
      children: [
        // Score and keywords loading
        Row(
          children: [
            Container(
              width: AppSpacing.spacing20,
              height: AppDimensions.buttonHeightXSmall,
              decoration: BoxDecoration(,
      color: context.fortuneTheme.dividerColor,
                borderRadius: AppDimensions.borderRadiusLarge)
              ))).animate(onPlay: (controller) => controller.repeat(),
                .shimmer(duration: 1.5.seconds),
            AppSpacing.smallHorizontal,
            Container(
              width: 60,
              height: AppSpacing.spacing7,
              decoration: BoxDecoration(,
      color: context.fortuneTheme.dividerColor,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge))))).animate(onPla,
      y: (controller) => controller.repeat(),
                .shimmer(duration: 1.5.seconds, delay: 0.2.seconds),
            SizedBox(width: AppSpacing.xSmall),
            Container(
              width: 60,
              height: AppSpacing.spacing7,
              decoration: BoxDecoration(,
      color: context.fortuneTheme.dividerColor,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge))))).animate(onPla,
      y: (controller) => controller.repeat(),
                .shimmer(duration: 1.5.seconds, delay: 0.4.seconds),
          ])
        SizedBox(height: AppSpacing.spacing4),
        // Summary loading
        Container(
          height: AppSpacing.spacing20,
          decoration: BoxDecoration(,
      color: context.fortuneTheme.dividerColor,
            borderRadius: AppDimensions.borderRadiusMedium)
          ))).animate(onPlay: (controller) => controller.repeat(),
            .shimmer(duration: 1.5.seconds),
        SizedBox(height: AppSpacing.spacing4),
        // Elements loading
        Container(
          height: AppSpacing.spacing24 * 1.25,
          decoration: BoxDecoration(,
      color: context.fortuneTheme.dividerColor,
            borderRadius: AppDimensions.borderRadiusMedium)
          ))).animate(onPlay: (controller) => controller.repeat(),
            .shimmer(duration: 1.5.seconds, delay: 0.3.seconds),
        SizedBox(height: AppSpacing.spacing4),
        // Lucky info loading
        Row(
          children: [
            Expanded(
              child: Container(,
      height: AppSpacing.spacing20,
                decoration: BoxDecoration(,
      color: context.fortuneTheme.dividerColor,
                  borderRadius: AppDimensions.borderRadiusMedium)
                ))).animate(onPlay: (controller) => controller.repeat(),
                  .shimmer(duration: 1.5.seconds))
            SizedBox(width: AppSpacing.spacing3),
            Expanded(
              child: Container(,
      height: AppSpacing.spacing20,
                decoration: BoxDecoration(,
      color: context.fortuneTheme.dividerColor,
                  borderRadius: AppDimensions.borderRadiusMedium)
                ))).animate(onPlay: (controller) => controller.repeat(),
                  .shimmer(duration: 1.5.seconds, delay: 0.2.seconds))
            SizedBox(width: AppSpacing.spacing3),
            Expanded(
              child: Container(,
      height: AppSpacing.spacing20,
                decoration: BoxDecoration(,
      color: context.fortuneTheme.dividerColor,
                  borderRadius: AppDimensions.borderRadiusMedium)
                ))).animate(onPlay: (controller) => controller.repeat(),
                  .shimmer(duration: 1.5.seconds, delay: 0.4.seconds))
          ])
      ]
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
                  padding: EdgeInsets.symmetric(horizonta,
      l: AppSpacing.spacing4, vertical: AppSpacing.spacing2),
                  decoration: BoxDecoration(,
      gradient: LinearGradient(,
      colors: _getScoreGradient(fortune!.score),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(AppDimensions.radiusXxLarge),
                    boxShadow: [
                      BoxShadow(
                        color: _getScoreGradient(fortune!.score)[0].withValues(alph,
      a: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                    ])
                  child: Row(,
      children: [
                      Icon(Icons.stars_rounded, size: AppDimensions.iconSizeSmall, color: AppColors.textPrimaryDark),
                      SizedBox(width: AppSpacing.xSmall),
                      Text(
                        '오늘의 점수',
        ),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(,
      color: AppColors.textPrimaryDark.withValues(alp,
      ha: 0.9, fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                          )))
                      SizedBox(width: AppSpacing.spacing2),
                      Text(
                        '${fortune!.score}점'),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(,
      fontWeight: FontWeight.bold,
                          ),),
                          color: AppColors.textPrimaryDark,
                          fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize)))
                    ])))
              ])
            SizedBox(height: AppSpacing.spacing3),
            // 키워드 섹션 - Wrap으로 변경
            Wrap(
              spacing: 8,
              runSpacing: 8),
        children: fortune!.keywords.map((keyword) => Container(,
      padding: EdgeInsets.symmetric(horizont,
      al: AppSpacing.spacing3, vertical: AppSpacing.spacing1),
                decoration: BoxDecoration(,
      color: Theme.of(context).colorScheme.primary.withValues(alp,
      ha: 0.1),
                  borderRadius: AppDimensions.radiusLarge),
      child: Text(
                  keyword,
        ),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(,
      fontWeight: FontWeight.w600,
                          ),),
                    color: Theme.of(context).colorScheme.primary))))))).toList())
          ])
        SizedBox(height: AppSpacing.spacing4),

        // 운세 요약
        Container(
          padding: AppSpacing.paddingAll16),
        decoration: BoxDecoration(,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alp,
      ha: 0.5),
            borderRadius: AppDimensions.borderRadiusMedium),
      child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                        Text(
                          fortune!.summary,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
        ),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(,
      height: 1.6,
                          ),
              fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize)))
              if (fortune!.summary.length > 100) ...[
                SizedBox(height: AppSpacing.spacing2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '더보기',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(,
      color: Theme.of(context).colorScheme.primary,
                          ),
                        fontWeight: FontWeight.w600)))
                    SizedBox(width: AppSpacing.spacing1),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12),
        color: Theme.of(context).colorScheme.primary)
                  ])
              ]
            ])))
        SizedBox(height: AppSpacing.spacing4),

        // 운세 요소들 (사랑, 건강, 돈, 일,
        Container(
          padding: AppSpacing.paddingAll16,
          decoration: BoxDecoration(,
      gradient: LinearGradient(,
      begin: Alignment.topLeft,
              end: Alignment.bottomRight,
        ),
        colors: [
                Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
              ])
            borderRadius: AppDimensions.borderRadiusLarge,
            border: Border.all(,
      color: context.fortuneTheme.dividerColor.withValues(alp,
      ha: 0.3))),
      child: Column(
                children: [
              _buildFortuneElement(context, '사랑', Icons.favorite_rounded, fortune!.elements.love, FortuneColors.love),
              SizedBox(height: AppSpacing.spacing3),
              _buildFortuneElement(context, '건강', Icons.spa_rounded, fortune!.elements.health, AppColors.success),
              SizedBox(height: AppSpacing.spacing3),
              _buildFortuneElement(context, '재물', Icons.account_balance_wallet_rounded, fortune!.elements.money, Color(0xFFFFC107)
              SizedBox(height: AppSpacing.spacing3),
              _buildFortuneElement(context, '직장', Icons.business_center_rounded, fortune!.elements.career, AppColors.primary),
            ])))
        SizedBox(height: AppSpacing.spacing4),

        // 행운의 정보들
        Row(
          children: [
            Expanded(
              child: _buildLuckyInfo(
                context,
                '행운의 색',
                Container(
                  width: 24,
                  height: AppSpacing.spacing6,
              ),
              decoration: BoxDecoration(,
      color: _getColorFromName(context, fortune!.luckyColor),
                    borderRadius: AppDimensions.borderRadiusMedium,
                    border: Border.all(,
      color: context.fortuneTheme.dividerColor,
        ),
        width: 2)
                    ))))))))
            SizedBox(width: AppSpacing.spacing3),
            Expanded(
              child: _buildLuckyInfo(
                context,
                '행운의 숫자',
                Container(
                  width: 24,
                  height: AppSpacing.spacing6),
              decoration: BoxDecoration(,
      color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle),
      child: Center(
                    child: Text(
                      '${fortune!.luckyNumber}'),
        style: Theme.of(context).textTheme.labelSmall)))))
            SizedBox(width: AppSpacing.spacing3),
            Expanded(
              child: _buildLuckyInfo(
                context,
                '최고의 시간',
                Icon(
                  Icons.access_time,
                  size: AppDimensions.iconSizeMedium),
        color: Theme.of(context).colorScheme.primary)
                fortune!.bestTime)))
          ])
        SizedBox(height: AppSpacing.spacing4),

        // 조언과 주의사항
        Row(
          children: [
            Expanded(
              child: Container(,
      padding: AppSpacing.paddingAll12),
        decoration: BoxDecoration(,
      color: AppColors.success.withValues(alp,
      ha: 0.1),
                  borderRadius: AppDimensions.borderRadiusMedium),
      child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
        ),
        children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, size: AppDimensions.iconSizeXSmall, color: AppColors.success),
                        SizedBox(width: AppSpacing.xSmall),
                        Text(
                          '오늘의 조언',
              ),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(,
      fontWeight: FontWeight.bold,
                          ),),
                            color: AppColors.success)
                      ])
                    AppSpacing.xSmallVertical,
                    Text(
                      fortune!.advice,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(,
      height: 1.4)
                  ],
                          )))))
            SizedBox(width: AppSpacing.spacing3),
            Expanded(
              child: Container(,
      padding: AppSpacing.paddingAll12),
        decoration: BoxDecoration(,
      color: AppColors.warning.withValues(alp,
      ha: 0.1),
                  borderRadius: AppDimensions.borderRadiusMedium),
      child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
        ),
        children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_outlined, size: AppDimensions.iconSizeXSmall, color: AppColors.warning),
                        SizedBox(width: AppSpacing.xSmall),
                        Text(
                          '주의할 점',
              ),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(,
      fontWeight: FontWeight.bold,
                          ),),
                            color: AppColors.warning)
                      ])
                    AppSpacing.xSmallVertical,
                    Text(
                      fortune!.caution,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(,
      height: 1.4)
                  ],
                          )))))
          ])
      ]
    );
  }

  Widget _buildFortuneElement(BuildContext context, String label, IconData icon, int score, Color color) {
    return Row(
      children: [
        Container(
          width: AppSpacing.spacing8,
          height: AppDimensions.buttonHeightXSmall),
              decoration: BoxDecoration(,
      color: color.withValues(alp,
      ha: 0.15),
            borderRadius: AppDimensions.borderRadiusSmall),
      child: Icon(icon, size: 18, color: color))
        AppSpacing.smallHorizontal,
        Text(
          label,
        ),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(,
      fontWeight: FontWeight.w600,
                          ),),
            fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize)))
        SizedBox(width: AppSpacing.spacing3),
        Expanded(
          child: Stack(,
      children: [
              Container(
                height: AppSpacing.spacing2 * 1.25),
              decoration: BoxDecoration(,
      color: color.withValues(alp,
      ha: 0.1),
                  borderRadius: AppDimensions.radiusSmall)))
              FractionallySizedBox(
                widthFactor: score / 100,
                child: Container(,
      height: AppSpacing.spacing2 * 1.25,
        ),
        decoration: BoxDecoration(,
      gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.8),
                        color,
                      ])
                    borderRadius: AppDimensions.radiusSmall,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alph,
      a: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                    ])))))
            ])))
        AppSpacing.smallHorizontal,
        Container(
          padding: EdgeInsets.symmetric(horizonta,
      l: AppSpacing.spacing2, vertical: AppSpacing.spacing1),
          decoration: BoxDecoration(,
      color: color.withValues(alp,
      ha: 0.1),
            borderRadius: AppDimensions.borderRadiusMedium),
      child: Text(
            '$score%',
        ),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(,
      fontWeight: FontWeight.bold,
                          ),),
              color: color,
              fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize)))))
      ]
    );
  }

  Widget _buildLuckyInfo(BuildContext context, String label, Widget icon, [String? value]) {
    return Container(
      padding: AppSpacing.paddingAll12),
        decoration: BoxDecoration(,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alp,
      ha: 0.5),
        borderRadius: AppDimensions.borderRadiusMedium),
      child: Column(
                children: [
          icon,
          AppSpacing.xSmallVertical,
          Text(
            label,
        ),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(,
      color: context.fortuneTheme.subtitleText,
                          ))
          if (value != null) ...[
            SizedBox(height: AppSpacing.xxxSmall),
            Text(
              value,
              ),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(,
      fontWeight: FontWeight.bold,
                          ))
          ]
        ]
      )
  }

  Widget _buildEmptyState(BuildContext context) {
    // When empty, it means fortune is being loaded, so show loading state
    return _buildLoadingState(context);
  }

  List<Color> _getScoreGradient(int score) {
    if (score >= 80) {
      return [FortuneColors.love, Color(0xFFFECA57)];
    } else if (score >= 60) {
      return [AppColors.info, Color(0xFF44A08D)];
    } else if (score >= 40) {
      return [FortuneColors.spiritualPrimary, FortuneColors.spiritualDark];
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

  Color _getColorFromName(BuildContext context, String colorName) {
    // First, check if it's a hex color
    if (colorName.startsWith('#')) {
      try {
        return Color(int.parse(colorName.replaceAll('#', '0xFF'))
      } catch (e) {
        // If hex parsing fails, continue to color name mapping
      }
    }

    // Korean color name to Flutter color mapping
    final colorMap = {
      '빨간색': AppColors.error,
      '파란색': AppColors.primary,
      '노란색': Colors.yellow,
      '초록색': AppColors.success,
      '보라색': Colors.purple,
      '주황색': AppColors.warning,
      '분홍색': Colors.pink,
      '하얀색': AppColors.textPrimaryDark,
      '검은색': AppColors.textPrimary,
      '회색': AppColors.textSecondary,
      '갈색': Colors.brown,
      '금색': Colors.amber,
      '은색': AppColors.textSecondary!,
      '하늘색': Colors.lightBlue,
      '남색': Colors.indigo,
      '청록색': Colors.teal,
    };
    
    // Return mapped color or default to primary color
    return colorMap[colorName] ?? Theme.of(context).colorScheme.primary;
  }
}