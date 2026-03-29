import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ondo/core/design_system/design_system.dart';
import 'package:ondo/core/widgets/paper_runtime_chrome.dart';
import 'package:ondo/core/widgets/paper_runtime_surface_kit.dart';

class PrivacyPolicyPage extends ConsumerStatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  ConsumerState<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends ConsumerState<PrivacyPolicyPage> {
  @override
  Widget build(BuildContext context) {
    const primarySections = [
      (
        '1. 개인정보의 수집 및 이용 목적',
        '온도 앱은 수집한 개인정보를 다음의 목적을 위해 이용합니다.\n'
            '• 회원 가입 및 관리\n'
            '• 맞춤형 운세 결과 생성\n'
            '• 대화 분석 및 관계 인사이트 제공\n'
            '• 유료 서비스 결제 확인과 고객 지원',
      ),
      (
        '2. 수집하는 개인정보의 항목',
        '필수 항목\n'
            '• 이메일 주소\n'
            '• 닉네임\n'
            '• 생년월일\n\n'
            '선택 항목\n'
            '• 성별\n'
            '• MBTI\n'
            '• 프로필 사진',
      ),
    ];
    const secondarySections = [
      (
        '3. 서비스 이용 과정에서 생성되는 정보',
        '대화 입력 내용, 선택 설문 응답, 구매 상태, 기본적인 기기·앱 진단 정보가 생성될 수 있습니다.',
      ),
      (
        '4. 제3자 제공 및 처리 위탁',
        'Supabase, Firebase Analytics, Apple App Store / Google Play 등 서비스 운영에 필요한 범위에서만 정보를 처리합니다.',
      ),
      (
        '5. 보관 기간 및 삭제',
        '계정 정보는 회원 탈퇴 시까지 보관하며, 결제 기록은 관련 법령과 스토어 정책에 따라 필요한 기간 동안 보관될 수 있습니다.',
      ),
      (
        '6. 문의처',
        'privacy@zpzg.co.kr\nsupport@zpzg.co.kr',
      ),
    ];

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const PaperRuntimeAppBar(title: '개인정보처리방침'),
      body: PaperRuntimeBackground(
        showRings: false,
        applySafeArea: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            DSSpacing.pageHorizontal,
            DSSpacing.md,
            DSSpacing.pageHorizontal,
            DSSpacing.xxl,
          ),
          children: [
            for (final section in primarySections)
              _buildSection(section.$1, section.$2),
            PaperRuntimeExpandablePanel(
              title: '추가 개인정보 안내',
              subtitle: '보관 기간, 처리 위탁, 문의처',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final section in secondarySections)
                    _buildSection(section.$1, section.$2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.heading4.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            content,
            style: context.bodyMedium.copyWith(
              color: context.colors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
