import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:fortune/core/theme/fortune_design_system.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:fortune/shared/glassmorphism/glass_container.dart';
import 'package:fortune/shared/components/app_header.dart';

class AboutPage extends ConsumerStatefulWidget {
  const AboutPage({super.key});

  @override
  ConsumerState<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends ConsumerState<AboutPage> {
  String _version = '';
  
  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossDesignSystem.gray50,
      body: Container(
        decoration: const BoxDecoration(color: TossDesignSystem.gray50),
        child: SafeArea(
          child: Column(
            children: [
              const AppHeader(title: 'Fortune 소개'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildHeroSection(),
                      const SizedBox(height: 32),
                      _buildFeatureSection(),
                      const SizedBox(height: 32),
                      _buildTeamSection(),
                      const SizedBox(height: 32),
                      _buildVersionInfo(),
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

  Widget _buildHeroSection() {
    return GlassContainer(
      gradient: LinearGradient(
        colors: [
          TossDesignSystem.purple.withValues(alpha: 0.3),
          TossDesignSystem.primaryBlue.withValues(alpha: 0.1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [TossDesignSystem.purple, TossDesignSystem.primaryBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: TossDesignSystem.purple.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10))]),
            child: const Icon(
              Icons.auto_awesome,
              size: 50,
              color: TossDesignSystem.white)).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text(
            'ZPZG',
            style: DSTypography.displayLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: TossDesignSystem.white)).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            '신이 전하는 나만의 운세',
            style: DSTypography.headingSmall.copyWith(
              color: TossDesignSystem.white.withValues(alpha: 0.9))).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 16),
          Text(
            '매일 새로운 인사이트와 함께\n더 나은 하루를 시작하세요',
            style: DSTypography.bodySmall.copyWith(
              color: TossDesignSystem.white.withValues(alpha: 0.7),
              height: 1.5),
            textAlign: TextAlign.center).animate().fadeIn(delay: 600.ms)]));
  }

  Widget _buildFeatureSection() {
    final features = [
      {
        'icon': Icons.psychology_rounded,
        'title': '영험한 신점',
        'description': '신비로운 기운으로 점지되는\n개인 맞춤형 운세',
        'color': TossDesignSystem.purple},
      {
        'icon': Icons.calendar_today_rounded,
        'title': '다양한 운세',
        'description': '일일, 주간, 월간부터\n사주, 타로까지',
        'color': TossDesignSystem.tossBlue},
      {
        'icon': Icons.favorite_rounded,
        'title': '궁합 & 연애운',
        'description': '상대방과의 궁합부터\n연애 조언까지',
        'color': TossDesignSystem.errorRed},
      {
        'icon': Icons.trending_up_rounded,
        'title': '재테크 운세',
        'description': '투자, 부동산, 사업\n재물운 상세 분석',
        'color': TossDesignSystem.successGreen},
      {
        'icon': Icons.sports_soccer_rounded,
        'title': '스포츠 운세',
        'description': '골프, 테니스, 운동\n오늘의 컨디션 체크',
        'color': TossDesignSystem.warningOrange},
      {
        'icon': Icons.offline_bolt_rounded,
        'title': '오프라인 지원',
        'description': '인터넷 없이도\n저장된 운세 확인',
        'color': TossDesignSystem.successGreen}];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '주요 기능',
          style: DSTypography.displaySmall.copyWith(
            fontWeight: FontWeight.bold,
            color: TossDesignSystem.white)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return _buildFeatureCard(
              icon: feature['icon'] as IconData,
              title: feature['title'] as String,
              description: feature['description'] as String,
              color: feature['color'] as Color).animate().scale(
              delay: Duration(milliseconds: 100 * index),
              duration: 500.ms,
              curve: Curves.easeOutBack);
          })]);
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color}) {
    return GlassContainer(
      gradient: LinearGradient(
        colors: [
          color.withValues(alpha: 0.2),
          color.withValues(alpha: 0.05)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: DSTypography.bodySmall.copyWith(
              color: TossDesignSystem.white,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            description,
            style: DSTypography.labelSmall.copyWith(
              color: TossDesignSystem.white.withValues(alpha: 0.7),
              height: 1.3),
            textAlign: TextAlign.center)]));
  }

  Widget _buildTeamSection() {
    return GlassContainer(
      gradient: LinearGradient(
        colors: [
          TossDesignSystem.tossBlue.withValues(alpha: 0.2),
          TossDesignSystem.tossBlue.withValues(alpha: 0.05)]),
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            '우리의 미션',
            style: DSTypography.headingSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: TossDesignSystem.white)),
          const SizedBox(height: 16),
          Text(
            'Fortune은 신비로운 기운과 전통적인 운세를 결합하여\n'
            '사용자들에게 긍정적인 에너지와 희망을 전달합니다.\n\n'
            '매일 아침 운세를 확인하며 하루를 시작하는 것이\n'
            '일상의 작은 행복이 되기를 바랍니다.',
            style: TextStyle(
              color: TossDesignSystem.white.withValues(alpha: 0.8),
              height: 1.6),
            textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem('83+', '운세 종류'),
              const SizedBox(width: 40),
              _buildStatItem('10만+', '활성 사용자'),
              const SizedBox(width: 40),
              _buildStatItem('4.8', '평점')])]));
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: DSTypography.displaySmall.copyWith(
            fontWeight: FontWeight.bold,
            color: TossDesignSystem.white)),
        Text(
          label,
          style: DSTypography.labelMedium.copyWith(
            color: TossDesignSystem.white.withValues(alpha: 0.7)))]);
  }

  Widget _buildVersionInfo() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          '버전 $_version',
          style: DSTypography.labelMedium.copyWith(
            color: TossDesignSystem.white.withValues(alpha: 0.5))),
        const SizedBox(height: 8),
        Text(
          '© 2025 Fortune. All rights reserved.',
          style: DSTypography.labelMedium.copyWith(
            color: TossDesignSystem.white.withValues(alpha: 0.5))),
        const SizedBox(height: 32)]);
  }
}