import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fortune/shared/glassmorphism/glass_container.dart';
import 'package:fortune/shared/components/app_header.dart';
import 'package:fortune/core/theme/app_theme.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CustomerSupportPage extends ConsumerWidget {
  const CustomerSupportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Container(
        decoration: BoxDecoration(color: AppColors.surface),
        child: SafeArea(
          child: Column(
            children: [
              const AppHeader(title: '고객 지원'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildContactCard(context),
                      const SizedBox(height: 16),
                      _buildFAQSection(context),
                      const SizedBox(height: 16),
                      _buildQuickActions(context),
                    ],
                  ),
              ),
            ],
          ),
      
    );
}

  Widget _buildContactCard(BuildContext context) {
    return GlassContainer(
      gradient: LinearGradient(
        colors: [
          Colors.purple.withValues(alpha: 0.3),
          Colors.purple.withValues(alpha: 0.1),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.support_agent_rounded,
            size: 60,
            color: Colors.purple.withValues(alpha: 0.5)).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          const Text(
            '도움이 필요하신가요?',
            style: TextStyle(
              fontSize: 22),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          const SizedBox(height: 8),
          Text(
            '평일 09:00 - 18:00 운영',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildContactButton(
                icon: Icons.email_rounded,
                label: '이메일',
                onTap: () => _launchEmail(),
                color: Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildContactButton(
                icon: Icons.chat_bubble_rounded,
                label: '카카오톡',
                onTap: () => _launchKakaoTalk(),
                color: Colors.yellow,
              ),
            ],
          ),
        ],
      )).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
}

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color),
                fontWeight: FontWeight.w600,
              ),
          ],
        ));
}

  Widget _buildFAQSection(BuildContext context) {
    final faqs = [
      {
        'question': '토큰은 어떻게 구매하나요?',
        'answer': '프로필 > 토큰 구매 메뉴에서 원하는 토큰 패키지를 선택하여 구매할 수 있습니다. 구독 회원은 무제한으로 운세를 볼 수 있습니다.',
      },
      {
        'question': '운세 결과가 맞지 않아요',
        'answer': '운세는 재미로 보는 것이며, 실제 미래를 예측하는 것은 아닙니다. 긍정적인 마음으로 참고만 해주세요.',
      },
      {
        'question': '구독을 취소하고 싶어요',
        'answer': 'iOS: 설정 > Apple ID > 구독에서 취소\nAndroid: Play 스토어 > 결제 및 구독에서 취소',
      },
      {
        'question': '개인정보는 안전한가요?',
        'answer': '모든 개인정보는 암호화되어 안전하게 보호됩니다. 자세한 내용은 개인정보처리방침을 확인해주세요.',
      },
      {
        'question': '오프라인에서도 사용 가능한가요?',
        'answer': '한 번 조회한 운세는 24시간 동안 오프라인에서도 확인 가능합니다.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '자주 묻는 질문',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold),
            color: Colors.white,
          ),
        const SizedBox(height: 16),
        ...faqs.asMap().entries.map((entry) {
          final index = entry.key;
          final faq = entry.value;
          return _buildFAQItem(
            question: faq['question']!,
            answer: faq['answer']!,
          ).animate().fadeIn(
            delay: Duration(milliseconds: 100 * index),
            duration: 500.ms,
          ).slideX(begin: 0.1, end: 0);
}),
      ]
    );
}

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 16),
        title: GlassContainer(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.1),
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.help_outline_rounded,
                color: Colors.blue.withValues(alpha: 0.5),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    color: Colors.white),
                    fontWeight: FontWeight.w500,
                  ),
              ),
            ],
          ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              answer,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.5,
              ),
          ),
        ],
      
    );
}

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 도움말',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold),
            color: Colors.white,
          ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildActionCard(
              icon: Icons.book_rounded,
              title: '사용 가이드',
              subtitle: '앱 사용법 알아보기',
              color: Colors.green,
              onTap: () => _showGuide(context),
            _buildActionCard(
              icon: Icons.bug_report_rounded,
              title: '버그 신고',
              subtitle: '문제 발견 시 알려주세요',
              color: Colors.red,
              onTap: () => _reportBug(context),
            _buildActionCard(
              icon: Icons.star_rounded,
              title: '평가하기',
              subtitle: '앱스토어 리뷰 남기기',
              color: Colors.orange,
              onTap: () => _rateApp(),
            _buildActionCard(
              icon: Icons.share_rounded,
              title: '앱 공유',
              subtitle: '친구에게 추천하기',
              color: Colors.purple,
              onTap: () => _shareApp(context),
          ],
        ),
      ]
    );
}

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: GlassContainer(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white),
                fontWeight: FontWeight.bold,
              ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.captionMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              textAlign: TextAlign.center,
            ),
          ],
        ),
    );
}

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@fortune-app.com',
      queryParameters: {
        'subject': '[Fortune 앱 문의]',
      }
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
}
  }

  Future<void> _launchKakaoTalk() async {
    // 카카오톡 채널 URL
    final Uri kakaoUri = Uri.parse('https://pf.kakao.com/_fortuneapp');
    
    if (await canLaunchUrl(kakaoUri)) {
      await launchUrl(kakaoUri, mode: LaunchMode.externalApplication);
}
  }

  void _showGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          '사용 가이드',
          style: TextStyle(color: Colors.white)),
        content: const Text(
          '1. 회원가입 후 프로필을 완성하세요\n'
          '2. 원하는 운세를 선택하여 조회하세요\n'
          '3. 토큰이 부족하면 구매하거나 구독하세요\n'),
          '4. 매일 무료 토큰을 받을 수 있습니다',
          style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
        ],
      
    );
}

  void _reportBug(BuildContext context) {
    // 버그 신고 페이지로 이동 또는 이메일 발송
    _launchEmail();
}

  Future<void> _rateApp() async {
    // TODO: 실제 앱스토어 URL로 변경
    final Uri appStoreUri = Uri.parse('https://apps.apple.com/app/id123456789');
    final Uri playStoreUri = Uri.parse('https://play.google.com/store/apps/details?id=com.beyond.fortune_flutter');
    
    // Platform check and launch appropriate store,
}

  void _shareApp(BuildContext context) {
    // Share 기능 구현
    // share_plus 패키지 사용,
}
}