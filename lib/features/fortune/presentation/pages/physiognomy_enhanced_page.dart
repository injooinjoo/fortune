import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/navigation_flow_helper.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../core/utils/haptic_utils.dart';

class PhysiognomyEnhancedPage extends ConsumerWidget {
  const PhysiognomyEnhancedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: '관상 운세'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildHeroSection(theme),
                    const SizedBox(height: 32),
                    _buildFeaturesSection(theme),
                    const SizedBox(height: 32),
                    _buildPrivacyNotice(theme),
                    const SizedBox(height: 32),
                    _buildStartButton(context, ref, theme),
                    const SizedBox(height: 24)])]);
  }

  Widget _buildHeroSection(ThemeData theme) {
    return GlassContainer(
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary]),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5)]),
            child: const Icon(
              Icons.face_retouching_natural_rounded,
              color: Colors.white,
              size: 60))
              .animate()
              .scale(duration: 600.ms, curve: Curves.easeOutBack)
              .shimmer(duration: 2000.ms, delay: 600.ms),
          const SizedBox(height: 24),
          Text(
            'AI가 분석하는 당신의 관상',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold),
            textAlign: TextAlign.center)
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 12),
          Text(
            '얼굴에 담긴 운명과 성격을 알아보세요',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7)),
            textAlign: TextAlign.center)
              .animate()
              .fadeIn(duration: 600.ms, delay: 400.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_rounded,
                  size: 16,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  'AI 정확도 95%',
                  style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold)])
              .animate()
              .fadeIn(duration: 600.ms, delay: 600.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0)]);
  }

  Widget _buildFeaturesSection(ThemeData theme) {
    final features = [
      {
        'icon': Icons.camera_alt_rounded,
        'title': 'AI 사진 분석': 'description': '최신 AI 기술로 정확한 관상 분석': 'color': null},
      {
        'icon': Icons.touch_app_rounded,
        'title': '간편한 수동 입력': 'description': '사진 없이도 간단하게 분석 가능': 'color': null},
      {
        'icon': Icons.psychology_rounded,
        'title': '종합적인 분석': 'description': '성격, 재물운, 연애운 등 상세 분석': 'color': null},
      {
        'icon': Icons.share_rounded,
        'title': '결과 공유': 'description': '친구들과 재미있는 결과 공유': 'color': null}];

    return Column(
      children: features.asMap().entries.map((entry) {
        final index = entry.key;
        final feature = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassContainer(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: feature['color'] as Color? ?? theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: feature['color'] as Color? ?? theme.colorScheme.primary,
                    size: 24)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature['title'] as String,
                        style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        feature['description'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7))
                    ]
                  )
                )
              ]
            )
          ))
              .animate()
              .fadeIn(
                  duration: 600.ms,
                  delay: Duration(milliseconds: 100 * index))
              .slideX(begin: -0.2, end: 0);
      }).toList()
    );
  }

  Widget _buildPrivacyNotice(ThemeData theme) {
    return GlassContainer(
      child: Row(
        children: [
          Icon(
            Icons.security_rounded,
            color: theme.colorScheme.primary,
            size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '개인정보 보호',
                  style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  '업로드된 사진은 분석 후 즉시 삭제되며,\n개인정보는 안전하게 보호됩니다.',
                  style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.4)])])
        .animate()
        .fadeIn(duration: 600.ms, delay: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildStartButton(
      BuildContext context, WidgetRef ref, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          HapticUtils.mediumImpact();
          NavigationFlowHelper.navigateWithAd(
            context: context,
            ref: ref,
            destinationRoute: 'physiognomy-input',
            fortuneType: 'physiognomy');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: theme.colorScheme.primary.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              '관상 분석 시작하기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded)]))
        .animate()
        .fadeIn(duration: 600.ms, delay: 600.ms)
        .slideY(begin: 0.3, end: 0)
        .then()
        .shimmer(duration: 2000.ms, delay: 1000.ms);
  }
}
