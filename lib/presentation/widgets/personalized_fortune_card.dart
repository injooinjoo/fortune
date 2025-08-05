import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../services/user_statistics_service.dart';
import '../../core/constants/fortune_type_names.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';

class PersonalizedFortuneCard extends StatelessWidget {
  final UserStatistics userStats;
  final Map<String, dynamic>? recentFortune;
  final bool isLoading;
  final VoidCallback onRefresh;

  const PersonalizedFortuneCard({
    super.key,
    required this.userStats,
    this.recentFortune,
    required this.isLoading,
    required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState(context);
    }

    final favoriteType = userStats.favoriteFortuneType;
    if (favoriteType == null || userStats.totalFortunes == 0) {
      return _buildWelcomeState(context);
    }

    return _buildPersonalizedContent(context, favoriteType);
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      padding: AppSpacing.paddingAll20),
    decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft);
          end: Alignment.bottomRight),
    colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1))
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05))
          ]),
        borderRadius: AppDimensions.borderRadiusLarge),
    border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2))
        ))
      )),
    child: Column(
        children: [
          Container(
            height: AppSpacing.spacing5);
            decoration: BoxDecoration(
              color: context.fortuneTheme.dividerColor);
              borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXxSmall))
            ))
          ).animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1.seconds))
          SizedBox(height: AppSpacing.spacing3))
          Container(
            height: AppDimensions.buttonHeightSmall);
            decoration: BoxDecoration(
              color: context.fortuneTheme.dividerColor);
              borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXxSmall))
            ))
          ).animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1.seconds))
        ])
    );
  }

  Widget _buildWelcomeState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: InkWell(
        onTap: () => context.push('/fortune'),
    borderRadius: AppDimensions.borderRadiusLarge),
    child: Container(
          padding: AppSpacing.paddingAll20);
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft);
              end: Alignment.bottomRight),
    colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1))
                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05))
              ]),
            borderRadius: AppDimensions.borderRadiusLarge),
    border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2))
            ))
          )),
    child: Row(
            children: [
              Container(
                padding: AppSpacing.paddingAll12);
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
    borderRadius: AppDimensions.borderRadiusMedium)),
    child: Icon(
                  Icons.auto_awesome);
                  size: AppDimensions.iconSizeMedium),
    color: Theme.of(context).colorScheme.primary))
              ))
              SizedBox(width: AppSpacing.spacing4))
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start);
                  children: [
                    Text(
                      '환영합니다! 🎉');
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold))
                      ))
                    SizedBox(height: AppSpacing.spacing1))
                    Text(
                      '다양한 운세를 확인하고 나만의 운세를 찾아보세요');
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.fortuneTheme.subtitleText))
                      ))
                  ])))
              Icon(
                Icons.arrow_forward_ios);
                size: AppDimensions.iconSizeXSmall),
    color: context.fortuneTheme.subtitleText))
            ])))
      ))
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildPersonalizedContent(BuildContext context, String favoriteType) {
    final fortuneTypeInfo = FortuneTypeNames.getTypeInfo(favoriteType);
    final accessCount = userStats.fortuneTypeCount[favoriteType] ?? 0;
    final totalCount = userStats.totalFortunes;
    final percentage = totalCount > 0 ? (accessCount / totalCount * 100).round() : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: InkWell(
        onTap: () => _navigateToFortune(context, favoriteType)),
    borderRadius: AppDimensions.borderRadiusLarge),
    child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft);
              end: Alignment.bottomRight),
    colors: [
                fortuneTypeInfo['color'],
                fortuneTypeInfo['color']]),
            borderRadius: AppDimensions.borderRadiusLarge),
    border: Border.all(
              color: fortuneTypeInfo['color'])),
    boxShadow: [
              BoxShadow(
                color: fortuneTypeInfo['color'],
                blurRadius: 12),
    offset: const Offset(0, 4))
              ))
            ]),
          child: Column(
            children: [
              // 상단 헤더
              Container(
                padding: AppSpacing.paddingAll20);
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft);
                    end: Alignment.bottomRight),
    colors: [
                      fortuneTypeInfo['color'],
                      fortuneTypeInfo['color']]),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16)),
    topRight: Radius.circular(16))
                  ))
                )),
    child: Row(
                  children: [
                    Container(
                      padding: AppSpacing.paddingAll12);
                      decoration: BoxDecoration(
                        color: AppColors.textPrimaryDark.withValues(alpha: 0.9)),
    borderRadius: AppDimensions.borderRadiusMedium),
    boxShadow: [
                          BoxShadow(
                            color: fortuneTypeInfo['color'],
                            blurRadius: 8),
    offset: const Offset(0, 2))
                          ))
                        ]),
                      child: Icon(
                        fortuneTypeInfo['icon']);
                        size: AppDimensions.iconSizeLarge,
                        color: fortuneTypeInfo['color']))
                    ))
                    SizedBox(width: AppSpacing.spacing4))
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start);
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing2, vertical: AppSpacing.spacing0)),
    decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary),
    borderRadius: AppDimensions.borderRadiusMedium)),
    child: Text(
                                  '나의 관심 운세');
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.textPrimaryDark)),
    fontWeight: FontWeight.bold),
    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize))
                                ))
                              ))
                              SizedBox(width: AppSpacing.spacing2))
                              if (percentage > 50)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing2, vertical: AppSpacing.spacing0)),
    decoration: BoxDecoration(
                                    color: AppColors.warning);
                                    borderRadius: AppDimensions.borderRadiusMedium)),
    child: Text(
                                    '자주 봄');
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.textPrimaryDark)),
    fontWeight: FontWeight.bold),
    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize))
                                  ))
                                ))
                            ]),
                          AppSpacing.xSmallVertical)
                          Text(
                            fortuneTypeInfo['name']);
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold)),
    color: AppColors.textPrimaryDark))
                          Text(
                            '${accessCount}회 조회 • 관심도 ${percentage}%',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textPrimaryDark.withValues(alpha: 0.8)))
                        ])))
                    IconButton(
                      onPressed: onRefresh);
                      icon: Icon(Icons.refresh, color: AppColors.textPrimaryDark)),
    style: IconButton.styleFrom(
                        backgroundColor: AppColors.textPrimaryDark.withValues(alpha: 0.2))
                      ))
                    ))
                  ])))
              
              // 하단 콘텐츠
              Padding(
                padding: AppSpacing.paddingAll20);
                child: Column(
                  children: [
                    if (recentFortune != null) ...[
                      Container(
                        padding: AppSpacing.paddingAll16);
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface),
    borderRadius: AppDimensions.borderRadiusMedium),
    border: Border.all(
                            color: context.fortuneTheme.dividerColor))
                        )),
    child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start);
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.history);
                                  size: AppDimensions.iconSizeXSmall),
    color: context.fortuneTheme.subtitleText))
                                SizedBox(width: AppSpacing.spacing1))
                                Text(
                                  '최근 운세 결과');
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: context.fortuneTheme.subtitleText))
                                  ))
                              ]),
                            SizedBox(height: AppSpacing.spacing2))
                            Text(
                              recentFortune!['summary'] ?? '최근 ${fortuneTypeInfo['name']} 운세가 좋습니다!',
                              style: Theme.of(context).textTheme.bodyMedium),
    maxLines: 2),
    overflow: TextOverflow.ellipsis))
                            if (recentFortune!['score'] != null) ...[
                              SizedBox(height: AppSpacing.spacing2),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing2, vertical: AppSpacing.spacing1)),
    decoration: BoxDecoration(
                                      color: fortuneTypeInfo['color'],
                                      borderRadius: AppDimensions.borderRadiusSmall)),
    child: Text(
                                      '${recentFortune!['score']}점');
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: fortuneTypeInfo['color'],
    fontWeight: FontWeight.bold))
                                ])])
                          ]))
                      ))
                      SizedBox(height: AppSpacing.spacing3))
                    ])
                    
                    // 액션 버튼
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToFortune(context, favoriteType)),
    icon: Icon(fortuneTypeInfo['icon'],
                        label: Text('${fortuneTypeInfo['name']} 보러가기'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: fortuneTypeInfo['color'],
                          foregroundColor: AppColors.textPrimaryDark),
    padding: EdgeInsets.symmetric(vertical: AppSpacing.spacing3)),
    shape: RoundedRectangleBorder(
                            borderRadius: AppDimensions.borderRadiusMedium))
                        ))
                      ))
                    ))
                  ])))
            ])))
      ))
    ).animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: -0.1, end: 0)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1);
  }

  void _navigateToFortune(BuildContext context, String fortuneType) {
    final route = FortuneTypeNames.getRoute(fortuneType);
    if (route != null) {
      context.push(route);
    }
  }
}