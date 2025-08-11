import 'package:flutter/material.dart';
import '../../shared/components/app_header.dart';
import '../../shared/glassmorphism/glass_container.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: AppHeader(
              title: '프리미엄 사주',
              backgroundColor: theme.colorScheme.surface)),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                GlassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.auto_stories_rounded,
                        size: 64,
                        color: theme.colorScheme.primary),
                      const SizedBox(height: 16),
                      Text(
                        '프리미엄 사주',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        '만화로 보는 재미있는 사주 풀이',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6)),
                        textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      // Feature list
                      _buildFeatureItem(
                        context,
                        icon: Icons.brush,
                        title: '아름다운 일러스트',
                        description: '전문 작가의 손길로 그려진 당신만의 이야기'),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        context,
                        icon: Icons.book,
                        title: '스토리텔링',
                        description: '지루하지 않은 재미있는 사주 해석'),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        context,
                        icon: Icons.insights,
                        title: '심층 분석',
                        description: '더 깊이 있는 운세 분석 제공'),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Navigate to premium purchase
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: theme.colorScheme.primary),
                          child: const Text(
                            '프리미엄 시작하기',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))])]))]);
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description}) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          child: Icon(
            icon,
            color: theme.colorScheme.primary)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6))])]);
  }
}