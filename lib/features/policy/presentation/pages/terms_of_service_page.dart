import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/paper_runtime_chrome.dart';
import '../../../../core/widgets/paper_runtime_surface_kit.dart';

class TermsOfServicePage extends ConsumerStatefulWidget {
  const TermsOfServicePage({super.key});

  @override
  ConsumerState<TermsOfServicePage> createState() => _TermsOfServicePageState();
}

class _TermsOfServicePageState extends ConsumerState<TermsOfServicePage> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const PaperRuntimeAppBar(title: '이용약관'),
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
            _buildSection(
              context,
              '제1조 (목적)',
              '이 약관은 Fortune(이하 "회사")이 제공하는 운세 서비스(이하 "서비스")의 이용과 관련하여 회사와 이용자 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.',
            ),
            _buildSection(
              context,
              '제2조 (용어의 정의)',
              '1. "서비스"란 회사가 제공하는 신점 기반 운세 예측 및 관련 콘텐츠를 의미합니다.\n'
                  '2. "이용자"란 이 약관에 따라 회사가 제공하는 서비스를 받는 회원 및 비회원을 말합니다.\n'
                  '3. "토큰"이란 서비스 내에서 운세 조회 등에 사용되는 가상의 이용 권리를 말합니다.',
            ),
            _buildSection(
              context,
              '제3조 (약관의 효력 및 변경)',
              '1. 이 약관은 서비스를 이용하고자 하는 모든 이용자에게 효력이 발생합니다.\n'
                  '2. 회사는 필요한 경우 관련 법령을 위배하지 않는 범위에서 이 약관을 변경할 수 있습니다.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: typography.bodyLarge.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            content,
            style: typography.bodyMedium.copyWith(
              color: colors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
