import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/design_system.dart';

class TermsOfServicePage extends ConsumerStatefulWidget {
  const TermsOfServicePage({super.key});

  @override
  ConsumerState<TermsOfServicePage> createState() => _TermsOfServicePageState();
}

class _TermsOfServicePageState extends ConsumerState<TermsOfServicePage> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: colors.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '이용약관',
          style: typography.headingMedium.copyWith(
            color: colors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.symmetric(horizontal: DSSpacing.pageHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: DSSpacing.md),
            _buildSection(
              context,
              '1. 서비스 성격',
              'ZPZG에서 제공하는 결과와 콘텐츠는 오락 및 웰빙 참고 목적입니다. 의료, 법률, 재무, 심리 치료를 대체하지 않으며, 중요한 판단은 전문 자문과 함께 진행해야 합니다.',
            ),
            _buildSection(
              context,
              '2. 계정과 이용자 책임',
              '• 정확한 계정 정보를 제공하고 본인 계정을 안전하게 관리해야 합니다.\n'
                  '• 타인의 정보를 도용하거나 서비스 운영을 방해하는 행위는 금지됩니다.\n'
                  '• 법령 위반, 악성 자동화, 부정 결제 시 이용이 제한될 수 있습니다.',
            ),
            _buildSection(
              context,
              '3. 토큰과 구독',
              '• 대화형 AI 기능과 인사이트 기능 일부는 토큰을 사용해 이용할 수 있습니다.\n'
                  '• 구독 상품은 정기적으로 토큰을 제공할 수 있으며, 실제 지급 조건은 앱 내 상품 화면 기준입니다.\n'
                  '• 결제와 환불은 Apple App Store 또는 Google Play 정책을 우선 적용합니다.',
            ),
            _buildSection(
              context,
              '4. 콘텐츠와 면책',
              '• 서비스 결과는 참고 자료이며 특정 결과를 보장하지 않습니다.\n'
                  '• 서비스를 통해 얻은 정보로 인한 의사결정 책임은 이용자 본인에게 있습니다.\n'
                  '• 시스템 점검, 스토어 정책 변경, 외부 서비스 장애로 일부 기능이 제한될 수 있습니다.',
            ),
            _buildSection(
              context,
              '5. 지원 및 계정 삭제',
              '일반 문의는 support@zpzg.co.kr, 개인정보 문의는 privacy@zpzg.co.kr로 접수할 수 있습니다. 계정 삭제는 앱 내 설정 화면에서 직접 요청할 수 있습니다.',
            ),
            const SizedBox(height: DSSpacing.lg),
            Container(
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(
                  color: colors.accent.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: colors.accent,
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Text(
                    '시행일: 2026년 3월 22일',
                    style: typography.labelSmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DSSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: typography.bodyMedium.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: DSSpacing.md),
          Text(
            content,
            style: typography.labelSmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
