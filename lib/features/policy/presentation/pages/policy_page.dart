import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/design_system.dart';
import 'package:fortune/shared/glassmorphism/glass_container.dart';
import 'package:fortune/shared/components/app_header.dart';
import 'package:fortune/core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fortune/core/theme/fortune_design_system.dart';

class PolicyPage extends ConsumerWidget {
  const PolicyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: const BoxDecoration(color: AppTheme.backgroundColor),
        child: SafeArea(
          child: Column(
            children: [
              const AppHeader(title: '약관 및 정책'),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildPolicyCard(
                        context: context,
                        icon: Icons.privacy_tip_rounded,
                        title: '개인정보처리방침',
                        subtitle: '개인정보 수집 및 이용에 관한 안내',
                        color: TossDesignSystem.tossBlue,
                        onTap: () => context.push('/privacy-policy')).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 16),
                      _buildPolicyCard(
                        context: context,
                        icon: Icons.description_rounded,
                        title: '이용약관',
                        subtitle: '서비스 이용에 관한 약관',
                        color: TossDesignSystem.purple,
                        onTap: () => context.push('/terms-of-service')).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 32),
                      _buildInfoSection(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: GlassContainer(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.3),
            color.withValues(alpha: 0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.headingSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: TossDesignSystem.white)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: context.bodySmall.copyWith(
                      color: TossDesignSystem.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: TossDesignSystem.white.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return GlassContainer(
      gradient: LinearGradient(
        colors: [
          TossDesignSystem.white.withValues(alpha: 0.1),
          TossDesignSystem.white.withValues(alpha: 0.05)]),
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: TossDesignSystem.white.withValues(alpha: 0.6),
            size: 32),
          const SizedBox(height: 12),
          Text(
            'Fortune은 이용자의 개인정보를 소중히 여기며,\n'
            '관련 법령에 따라 안전하게 관리하고 있습니다.',
            style: context.bodySmall.copyWith(
              color: TossDesignSystem.white.withValues(alpha: 0.8),
              height: 1.5),
            textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(
            '문의사항이 있으시면 고객지원 페이지를 이용해주세요.',
            style: context.labelMedium.copyWith(
              color: TossDesignSystem.white.withValues(alpha: 0.6)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 500.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }
}