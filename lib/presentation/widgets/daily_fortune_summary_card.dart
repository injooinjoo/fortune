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

  const DailyFortuneSummaryCard({
    super.key,
    this.fortune,
    required this.isLoading,
    required this.onTap,
    this.userName,
    this.onRefresh,
    this.isRefreshing = false,
    this.refreshCount = 0,
    this.maxRefreshCount = 3});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeGreeting = _getTimeGreeting(now);

    return InkWell(
      onTap: fortune != null ? onTap : null,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
      child: Container(
        width: double.infinity,
        padding: AppSpacing.paddingAll24,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.textPrimaryDark,
              AppColors.textPrimaryDark.withOpacity(0.98)]),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
          border: Border.all(color: context.fortuneTheme.dividerColor.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 4))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 - 날짜와 시간
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        timeGreeting['icon'],
                        size: AppDimensions.iconSizeMedium,
                        color: Theme.of(context).colorScheme.primary),
                      SizedBox(width: AppSpacing.spacing2),
                      Flexible(
                        child: Text(
                          userName != null && userName!.isNotEmpty 
                              ? '$userName님의 ${timeGreeting['greeting']} 운세'
                              : '${timeGreeting['greeting']} 운세',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize),
                          overflow: TextOverflow.ellipsis)]),
                SizedBox(width: AppSpacing.spacing2),
                Row(
                  children: [
                    if (fortune != null && onRefresh != null && refreshCount < maxRefreshCount) ...[
                      Container(
                        height: AppSpacing.spacing9,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge)),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: isRefreshing ? null : onRefresh,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing3),
                              child: Row(
                                children: [
                                  isRefreshing
                                      ? SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Theme.of(context).colorScheme.primary)))
                                      : Icon(
                                          Icons.refresh,
                                          size: 18,
                                          color: Theme.of(context).colorScheme.primary),
                                  SizedBox(width: AppSpacing.xSmall),
                                  Text(
                                    '$refreshCount/$maxRefreshCount',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600)])),
                      SizedBox(width: AppSpacing.spacing2)],
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.spacing3, 
                        vertical: AppSpacing.spacing1),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: AppDimensions.borderRadiusMedium),
                      child: Text(
                        '${now.day}일 (${_getWeekdayKorean(now.weekday)})',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600)))])]),
            SizedBox(height: AppSpacing.spacing5),

            if (isLoading)
              _buildLoadingState(context)
            else if (fortune != null)
              _buildFortuneContent(context)
            else
              _buildEmptyState(context)])));
  }

  Widget _buildLoadingState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 200,
          height: 20,
          decoration: BoxDecoration(
            color: context.fortuneTheme.dividerColor,
            borderRadius: BorderRadius.circular(10))).animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 1.5.seconds),
        SizedBox(height: AppSpacing.spacing3),
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: context.fortuneTheme.dividerColor,
            borderRadius: BorderRadius.circular(8))).animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 1.5.seconds, delay: 0.2.seconds)]);
  }

  Widget _buildFortuneContent(BuildContext context) {
    final score = fortune!.score;
    final scoreColor = _getScoreColor(context, score);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 운세 점수와 기분
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.spacing3,
                vertical: AppSpacing.spacing1),
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.1),
                borderRadius: AppDimensions.borderRadiusLarge,
                border: Border.all(color: scoreColor.withOpacity(0.3)),
              child: Row(
                children: [
                  Icon(
                    _getScoreIcon(score),
                    size: 16,
                    color: scoreColor),
                  SizedBox(width: AppSpacing.xSmall),
                  Text(
                    '$score점',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scoreColor,
                      fontWeight: FontWeight.bold)]),
            SizedBox(width: AppSpacing.spacing2),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.spacing3,
                vertical: AppSpacing.spacing1),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                borderRadius: AppDimensions.borderRadiusLarge),
              child: Text(
                fortune!.mood ?? '평온함',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary)))]),
        SizedBox(height: AppSpacing.spacing3),
        
        // 운세 요약
        Text(
          fortune!.summary ?? '',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: context.fortuneTheme.primaryText,
            height: 1.5),
          maxLines: 3,
          overflow: TextOverflow.ellipsis),
        
        SizedBox(height: AppSpacing.spacing4),
        
        // 키워드 태그들
        Wrap(
          spacing: AppSpacing.spacing2,
          runSpacing: AppSpacing.spacing1,
          children: (fortune!.keywords ?? []).map((keyword) => Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing2,
              vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: AppDimensions.borderRadiusMedium),
            child: Text(
              '#$keyword',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500))).toList())]);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingAll16,
      decoration: BoxDecoration(
        color: context.fortuneTheme.dividerColor.withOpacity(0.3),
        borderRadius: AppDimensions.borderRadiusMedium),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome,
            color: context.fortuneTheme.subtitleText,
            size: 24),
          SizedBox(width: AppSpacing.spacing3),
          Expanded(
            child: Text(
              '오늘의 운세를 확인해보세요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.fortuneTheme.subtitleText)),
          Icon(
            Icons.arrow_forward_ios,
            color: context.fortuneTheme.subtitleText,
            size: 16)]));
  }

  Map<String, dynamic> _getTimeGreeting(DateTime now) {
    final hour = now.hour;
    
    if (hour >= 5 && hour < 10) {
      return {'greeting': '아침', 'icon': Icons.wb_sunny};
    } else if (hour >= 10 && hour < 12) {
      return {'greeting': '오전', 'icon': Icons.wb_sunny};
    } else if (hour >= 12 && hour < 14) {
      return {'greeting': '점심', 'icon': Icons.wb_cloudy};
    } else if (hour >= 14 && hour < 18) {
      return {'greeting': '오후', 'icon': Icons.wb_cloudy};
    } else if (hour >= 18 && hour < 22) {
      return {'greeting': '저녁', 'icon': Icons.nights_stay};
    } else {
      return {'greeting': '밤', 'icon': Icons.bedtime};
    }
  }

  String _getWeekdayKorean(int weekday) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[weekday - 1];
  }

  Color _getScoreColor(BuildContext context, int score) {
    final fortuneTheme = Theme.of(context).extension<FortuneThemeExtension>()!;
    if (score >= 90) return fortuneTheme.scoreExcellent;
    if (score >= 80) return fortuneTheme.scoreGood;
    if (score >= 70) return fortuneTheme.scoreFair;
    if (score >= 60) return fortuneTheme.scorePoor;
    return fortuneTheme.errorColor;
  }

  IconData _getScoreIcon(int score) {
    if (score >= 90) return Icons.sentiment_very_satisfied;
    if (score >= 80) return Icons.sentiment_satisfied;
    if (score >= 70) return Icons.sentiment_neutral;
    if (score >= 60) return Icons.sentiment_dissatisfied;
    return Icons.sentiment_very_dissatisfied;
  }
}

class DailyFortune {
  final int score;
  final List<String> keywords;
  final String? summary;
  final String? luckyColor;
  final int? luckyNumber;
  final int? energy;
  final String? mood;
  final String? advice;
  final String? caution;
  final String? bestTime;
  final String? compatibility;
  final FortuneElements? elements;

  DailyFortune({
    required this.score,
    required this.keywords,
    this.summary,
    this.luckyColor,
    this.luckyNumber,
    this.energy,
    this.mood,
    this.advice,
    this.caution,
    this.bestTime,
    this.compatibility,
    this.elements});
}

class FortuneElements {
  final int? love;
  final int? career;
  final int? money;
  final int? health;

  FortuneElements({
    this.love,
    this.career,
    this.money,
    this.health});
}