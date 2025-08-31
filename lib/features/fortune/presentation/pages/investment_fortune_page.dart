import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/toss_theme.dart';
import 'investment_fortune_input_page.dart';

class InvestmentFortunePage extends ConsumerStatefulWidget {
  const InvestmentFortunePage({super.key});

  @override
  ConsumerState<InvestmentFortunePage> createState() => _InvestmentFortunePageState();
}

class _InvestmentFortunePageState extends ConsumerState<InvestmentFortunePage> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: TossTheme.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: TossTheme.textBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '투자 운세',
          style: TossTheme.heading4,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildIllustrationSection(),
              _buildContentSection(),
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustrationSection() {
    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            TossTheme.primaryBlue.withOpacity(0.05),
            TossTheme.backgroundWhite,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    TossTheme.primaryBlue.withOpacity(0.2),
                    TossTheme.primaryBlue.withOpacity(0.1),
                  ],
                ),
              ),
              child: Icon(
                Icons.trending_up,
                size: 60,
                color: TossTheme.primaryBlue,
              ),
            ),
          ).animate()
            .fadeIn(duration: 800.ms)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
          const SizedBox(height: 24),
          Text(
            '투자 운세',
            style: TossTheme.heading2.copyWith(
              fontSize: 32,
            ),
          ).animate()
            .fadeIn(duration: 600.ms, delay: 200.ms)
            .slideY(begin: 0.1, end: 0),
          const SizedBox(height: 8),
          Text(
            '오늘의 투자 운을 확인해보세요',
            style: TossTheme.body3.copyWith(
              color: TossTheme.textGray600,
            ),
          ).animate()
            .fadeIn(duration: 600.ms, delay: 400.ms)
            .slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildFeatureCard(
            icon: Icons.analytics_outlined,
            title: 'AI 투자 분석',
            description: '당신의 투자 성향을 분석하고\n최적의 투자 전략을 제안합니다',
            color: TossTheme.primaryBlue,
            delay: 600,
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.pie_chart_outline,
            title: '포트폴리오 추천',
            description: '리스크 성향에 맞는\n포트폴리오를 구성해드립니다',
            color: TossTheme.success,
            delay: 700,
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.schedule,
            title: '최적 타이밍',
            description: '오늘의 투자 타이밍을\n운세로 알려드립니다',
            color: TossTheme.warning,
            delay: 800,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TossTheme.borderGray200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TossTheme.body2.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TossTheme.caption.copyWith(
                    color: TossTheme.textGray600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: TossTheme.textGray400,
            size: 24,
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 400.ms, delay: delay.ms)
      .slideX(begin: 0.05, end: 0);
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TossTheme.backgroundWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TossTheme.primaryBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: TossTheme.primaryBlue.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: TossTheme.primaryBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '투자 운세는 재미로 보는 것이며,\n실제 투자는 신중하게 결정하세요',
                      style: TossTheme.caption.copyWith(
                        color: TossTheme.primaryBlue,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate()
              .fadeIn(duration: 600.ms, delay: 900.ms)
              .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _startFortuneTelling,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TossTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  textStyle: TossTheme.button,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '투자 운세 보기',
                      style: TossTheme.button.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ).animate()
              .fadeIn(duration: 600.ms, delay: 1000.ms)
              .slideY(begin: 0.2, end: 0)
              .then()
              .shimmer(duration: 2000.ms, delay: 1000.ms),
          ],
        ),
      ),
    );
  }

  void _startFortuneTelling() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const InvestmentFortuneInputPage(),
      ),
    );
  }
}