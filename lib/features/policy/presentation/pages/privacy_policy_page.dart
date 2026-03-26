import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:fortune/core/widgets/paper_runtime_surface_kit.dart';

class PrivacyPolicyPage extends ConsumerStatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  ConsumerState<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends ConsumerState<PrivacyPolicyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const PaperRuntimeAppBar(title: '개인정보처리방침'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          DSSpacing.pageHorizontal,
          DSSpacing.lg,
          DSSpacing.pageHorizontal,
          DSSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              '1. 수집하는 정보',
              'ZPZG 앱은 다음 정보를 수집할 수 있습니다:\n\n'
                  '• 계정 정보: 이메일 주소, 닉네임, 사용자 식별자\n'
                  '• 서비스 입력 정보: 생년월일, 출생 시간/지역, 사용자가 직접 입력한 질문\n'
                  '• 선택 정보: 프로필 사진, 얼굴 분석용 사진, 음성 입력 내용, 위치\n'
                  '• 결제 정보: 토큰 구매 및 구독 상태 확인에 필요한 구매 이력\n'
                  '• 서비스 이용 정보: 화면 조회, 기능 사용 기록, 기본적인 기기/앱 진단 정보',
            ),
            _buildSection(
              '2. 이용 목적',
              '수집한 정보는 다음 목적에 사용됩니다:\n\n'
                  '• 회원 가입, 로그인, 계정 보호, 고객 문의 대응\n'
                  '• 대화형 AI 경험과 운세·관계·성향·생활 인사이트 제공\n'
                  '• 토큰/구독 구매 확인 및 결제 처리\n'
                  '• 서비스 품질 분석과 안정성 개선\n'
                  '• 법령 준수와 부정 이용 방지',
            ),
            _buildSection(
              '3. 권한 사용 안내',
              '앱은 사용자가 해당 기능을 직접 실행할 때만 다음 권한을 요청합니다:\n\n'
                  '• 카메라: 사용자가 직접 얼굴 사진을 촬영할 때만 사용\n'
                  '• 사진 보관함: 사용자가 직접 선택한 사진만 업로드\n'
                  '• 마이크/음성 인식: 음성 입력 기능을 사용할 때만 요청\n'
                  '• 위치: 날씨/지역 기반 인사이트를 사용할 때만 사용\n\n'
                  '선택 권한은 거부해도 다른 핵심 기능은 계속 이용할 수 있습니다.',
            ),
            _buildSection(
              '4. 제3자 제공 및 처리 위탁',
              '서비스 운영을 위해 다음 제3자에게 최소한의 정보가 전달될 수 있습니다:\n\n'
                  '• Supabase: 계정 관리, 데이터 저장, 서비스 운영\n'
                  '• Google Firebase Analytics: 비식별 사용 통계 분석\n'
                  '• Apple App Store / Google Play: 인앱 결제 처리 및 구매 확인\n'
                  '• AI 모델 제공자(예: Google Gemini, OpenAI): 사용자가 직접 입력한 질문, 선택적으로 업로드한 사진/음성 입력, 생성 요청에 필요한 최소 정보 처리\n\n'
                  'AI 결과 생성 시에만 필요한 범위에서 외부 AI 모델 제공자에게 데이터를 전달하며, ATT/IDFA 기반 광고 추적은 사용하지 않고 개인정보를 판매하지 않습니다.',
            ),
            _buildSection(
              '5. 보관 기간과 삭제',
              '계정 정보는 회원 탈퇴 시까지 보관합니다. 결제 관련 기록은 관련 법령과 스토어 정책에 따라 필요한 기간 동안 보관할 수 있습니다. 사용자는 앱 내 설정에서 계정 삭제를 요청할 수 있습니다.',
            ),
            _buildSection(
              '6. 문의처',
              '개인정보 관련 문의: privacy@zpzg.co.kr\n'
                  '일반 지원 문의: support@zpzg.co.kr',
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
            style: context.bodyLarge.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w700,
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
