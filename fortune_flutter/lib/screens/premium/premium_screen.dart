import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import '../../shared/components/app_header.dart';
import '../../shared/glassmorphism/glass_container.dart';
import 'package:fortune/core/theme/app_typography.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(,
      slivers: [
          SliverToBoxAdapter(
            child: AppHeader(,
      title: '프리미엄 사주'),
        backgroundColor: theme.colorScheme.surface)
            ))
          SliverPadding(
            padding: AppSpacing.paddingAll16,
            sliver: SliverList(,
      delegate: SliverChildListDelegate([
                GlassContainer(
                  padding: AppSpacing.paddingAll24),
        child: Column(,
      children: [
                      Icon(
                        Icons.auto_stories_rounded,
              ),
              size: 64),
        color: theme.colorScheme.primary)
                      )
                      SizedBox(height: AppSpacing.spacing4),
                      Text(
                        '프리미엄 사주'),
        style: theme.textTheme.headlineMedium?.copyWith(,
      fontWeight: FontWeight.bold)
                      SizedBox(height: AppSpacing.spacing2,
                          ),
                      Text(
                        '만화로 보는 재미있는 사주 풀이'),
        style: theme.textTheme.bodyMedium?.copyWith(,
      color: theme.colorScheme.onSurface.withValues(alp,
      ha: 0.6,
                          ),
        textAlign: TextAlign.center)
                      SizedBox(height: AppSpacing.spacing6),
                      // Feature list
                      _buildFeatureItem(
                        context,
                        icon: Icons.brush,
                        title: '아름다운 일러스트'),
        description: '전문 작가의 손길로 그려진 당신만의 이야기')
                      SizedBox(height: AppSpacing.spacing4),
                      _buildFeatureItem(
                        context,
                        icon: Icons.book,
                        title: '스토리텔링'),
        description: '지루하지 않은 재미있는 사주 해석')
                      SizedBox(height: AppSpacing.spacing4),
                      _buildFeatureItem(
                        context,
                        icon: Icons.insights,
                        title: '심층 분석'),
        description: '더 깊이 있는 운세 분석 제공')
                      SizedBox(height: AppSpacing.spacing6),
                      SizedBox(
                        width: double.infinity),
              child: ElevatedButton(,
      onPressed: () {
                            // TODO: Navigate to premium purchase
                          }
                          style: ElevatedButton.styleFrom(,
      padding: AppSpacing.paddingVertical16),
        backgroundColor: theme.colorScheme.primary),
      child: Text(
                            '프리미엄 시작하기'),
        style: Theme.of(context).textTheme.titleMedium)))))))))))))
      )
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title)
    required String description)
  }) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          padding: AppSpacing.paddingAll12),
        decoration: BoxDecoration(,
      color: theme.colorScheme.primary.withValues(alp,
      ha: 0.1,
        ),
        borderRadius: AppDimensions.borderRadiusMedium),
      child: Icon(
                icon,
              ),
              color: theme.colorScheme.primary)
          ))
        SizedBox(width: AppSpacing.spacing4),
        Expanded(
          child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
              ),
              children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(,
      fontWeight: FontWeight.bold)
              SizedBox(height: AppSpacing.xxxSmall,
                          ),
              Text(
                description),
        style: theme.textTheme.bodySmall?.copyWith(,
      color: theme.colorScheme.onSurface.withValues(alp,
      ha: 0.6,
                          ))))))
  }
}