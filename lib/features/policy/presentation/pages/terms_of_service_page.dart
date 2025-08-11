import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/shared/glassmorphism/glass_container.dart';
import 'package:fortune/shared/components/app_header.dart';
import 'package:fortune/core/theme/app_theme.dart';

class TermsOfServicePage extends ConsumerWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(color: AppTheme.backgroundColor),
        child: SafeArea(
          child: Column(
            children: [
              const AppHeader(title: '이용약관'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: GlassContainer(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05)]),
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection(
                          '제1조 (목적)',
                          '이 약관은 Fortune(이하 "회사")이 제공하는 운세 서비스(이하 "서비스")의 이용과 관련하여 회사와 이용자 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.'),
                        _buildSection(
                          '제2조 (용어의 정의)',
                          '1. "서비스"란 회사가 제공하는 AI 기반 운세 예측 및 관련 콘텐츠를 의미합니다.\n'
                          '2. "이용자"란 이 약관에 따라 회사가 제공하는 서비스를 받는 회원 및 비회원을 말합니다.\n'
                          '3. "회원"이란 회사에 개인정보를 제공하여 회원등록을 한 자로서, 서비스를 이용하는 자를 말합니다.\n'
                          '4. "토큰"이란 서비스 내에서 운세 조회 등에 사용되는 가상의 이용권을 말합니다.'),
                        _buildSection(
                          '제3조 (약관의 효력 및 변경)',
                          '1. 이 약관은 서비스를 이용하고자 하는 모든 이용자에게 그 효력이 발생합니다.\n'
                          '2. 회사는 필요한 경우 관련 법령을 위배하지 않는 범위에서 이 약관을 변경할 수 있습니다.\n'
                          '3. 약관이 변경되는 경우 회사는 변경사항을 시행일자 7일 전부터 서비스 내 공지사항을 통해 공지합니다.'),
                        _buildSection(
                          '제4조 (서비스의 제공)',
                          '제공합니다:\n'
                          '   • 일일, 주간, 월간 등 다양한 형태의 운세 정보\n'
                          '   • 사주, 타로, 별자리 등 전통 및 현대적 운세\n'
                          '   • 궁합, 연애운 등 관계 관련 운세\n'
                          '   • 재물운, 직업운 등 생활 밀착형 운세\n\n'
                          '2. 서비스는 연중무휴, 1일 24시간 제공함을 원칙으로 합니다.\n'
                          '3. 회사는 서비스 제공을 위해 정기적인 시스템 점검 시간을 가질 수 있습니다.'),
                        _buildSection(
                          '제5조 (이용자의 의무)',
                          '됩니다:\n\n'
                          '1. 타인의 정보 도용\n'
                          '2. 회사가 게시한 정보의 무단 변경\n'
                          '3. 회사의 저작권 등 지적재산권에 대한 침해\n'
                          '4. 회사나 제3자의 명예를 손상시키거나 업무를 방해하는 행위\n'
                          '5. 외설 또는 폭력적인 메시지, 기타 공서양속에 반하는 정보를 공개하는 행위'),
                        _buildSection(
                          '제6조 (유료 서비스)',
                          '1. 회사는 토큰 구매, 구독 서비스 등 유료 서비스를 제공할 수 있습니다.\n'
                          '2. 유료 서비스의 이용요금은 서비스 내에 명시된 요금정책에 따릅니다.\n'
                          '3. 결제는 앱스토어(App Store, Google Play) 정책에 따라 처리됩니다.\n'
                          '4. 구매한 토큰의 유효기간은 구매일로부터 1년입니다.'),
                        _buildSection(
                          '제7조 (환불 정책)',
                          '1. 토큰 구매 후 7일 이내, 사용하지 않은 경우에 한해 환불이 가능합니다.\n'
                          '2. 구독 서비스는 각 앱스토어의 환불 정책을 따릅니다.\n'
                          '3. 이용자의 귀책사유로 인한 서비스 이용 제한의 경우 환불이 불가능합니다.'),
                        _buildSection(
                          '제8조 (면책조항)',
                          '1. 회사가 제공하는 운세 정보는 오락 및 참고 목적으로만 제공되며, 실제 미래를 예측하거나 보장하지 않습니다.\n'
                          '2. 이용자가 서비스를 통해 얻은 정보를 바탕으로 한 의사결정에 대한 책임은 전적으로 이용자에게 있습니다.\n'
                          '3. 회사는 천재지변, 시스템 장애 등 불가항력적인 사유로 인한 서비스 중단에 대해 책임을 지지 않습니다.'),
                        _buildSection(
                          '제9조 (분쟁해결)',
                          '1. 회사와 이용자 간에 발생한 분쟁은 상호 협의하여 해결하는 것을 원칙으로 합니다.\n'
                          '2. 협의가 이루어지지 않을 경우, 대한민국 법령에 따라 관할 법원에서 해결합니다.'),
                        const SizedBox(height: 24),
                        Text(
                          '시행일: 2025년 1월 1일',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14)]))])));
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white)),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
              height: 1.6)]);
  }
}