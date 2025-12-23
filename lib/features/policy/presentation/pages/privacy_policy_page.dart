import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fortune/core/theme/fortune_design_system.dart';

class PrivacyPolicyPage extends ConsumerStatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  ConsumerState<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends ConsumerState<PrivacyPolicyPage> {
  // TOSS Design System Helper Methods
  bool _isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Color _getTextColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark900
        : TossDesignSystem.gray900;
  }

  Color _getSecondaryTextColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark400
        : TossDesignSystem.gray600;
  }

  Color _getBackgroundColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark50
        : TossDesignSystem.gray50;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: _getTextColor(context)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '개인정보처리방침',
          style: TossDesignSystem.heading4.copyWith(
            color: _getTextColor(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: TossDesignSystem.marginHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: TossDesignSystem.spacingM),

            _buildSection(
              '1. 개인정보의 수집 및 이용 목적',
              'Fortune 앱은 수집한 개인정보를 다음의 목적을 위해 이용합니다:\n\n'
              '• 회원 가입 및 관리\n'
              '• 맞춤형 운세 서비스 제공\n'
              '• 서비스 이용 통계 및 분석\n'
              '• 고객 문의 대응 및 공지사항 전달\n'
              '• 유료 서비스 결제 및 정산',
            ),

            _buildSection(
              '2. 수집하는 개인정보의 항목',
              'Fortune 앱은 다음과 같은 개인정보를 수집합니다:\n\n'
              '필수 항목:\n'
              '• 이메일 주소\n'
              '• 닉네임\n'
              '• 생년월일\n'
              '• 결제 정보 (유료 서비스 이용 시)\n\n'
              '선택 항목:\n'
              '• 성별\n'
              '• MBTI\n'
              '• 프로필 사진',
            ),

            _buildSection(
              '3. 개인정보의 보유 및 이용 기간',
              '서비스는 원칙적으로 개인정보 수집 및 이용목적이 달성된 후에는 해당 정보를 지체 없이 파기합니다.\n\n'
              '회원 정보: 회원 탈퇴 시까지\n'
              '결제 정보: 전자상거래법에 따라 5년간 보관\n'
              '서비스 이용 기록: 통신비밀보호법에 따라 3개월간 보관',
            ),

            _buildSection(
              '4. 광고 및 추적',
              'Fortune 앱은 맞춤형 광고 제공을 위해 다음의 서비스를 이용합니다:\n\n'
              '• Google AdMob: 맞춤형 광고 제공\n'
              '• SKAdNetwork: Apple의 개인정보 보호 광고 측정\n'
              '• Firebase Analytics: 앱 사용 분석\n\n'
              '앱 추적 투명성(ATT):\n'
              '앱 최초 실행 시 "앱이 활동을 추적하는 것을 허용할까요?" 팝업이 표시됩니다. '
              '추적을 허용하면 맞춤형 광고가 표시되고, 거부하면 일반 광고가 표시됩니다. '
              '추적 거부 시에도 앱의 모든 기능을 정상적으로 이용할 수 있습니다.\n\n'
              '광고 식별자(IDFA):\n'
              '사용자가 추적을 허용한 경우에만 광고 식별자를 수집하여 광고 성과 측정에 활용합니다.\n\n'
              '프리미엄 구독 시 모든 광고가 제거됩니다.',
            ),

            _buildSection(
              '5. 기기 권한 사용',
              'Fortune 앱은 다음의 기기 권한을 사용합니다:\n\n'
              '• 카메라: 관상 분석 기능에서 얼굴 사진 촬영\n'
              '• 사진 보관함: 관상 분석용 사진 선택 및 운세 이미지 저장\n'
              '• 마이크: 꿈 해몽 기능에서 음성으로 꿈 내용 입력\n'
              '• 음성 인식: 음성을 텍스트로 변환하여 꿈 해몽 제공\n'
              '• 위치: 현재 위치 기반 날씨 정보를 운세에 반영\n'
              '• 캘린더: 중요한 운세 날짜 저장 및 일정 분석 기반 맞춤 운세\n\n'
              '각 권한은 해당 기능 사용 시에만 요청되며, 권한을 거부해도 해당 기능 외의 앱 사용에는 제한이 없습니다.',
            ),

            _buildSection(
              '6. 개인정보의 제3자 제공',
              '서비스는 다음의 제3자에게 개인정보를 제공합니다:\n\n'
              '• Google LLC (AdMob): 광고 ID, 앱 사용 데이터 - 맞춤형 광고 제공\n'
              '• Google LLC (Firebase): 기기 정보, 앱 사용 데이터 - 앱 분석 및 오류 추적\n'
              '• Supabase Inc: 이메일, 생년월일 - 회원 관리 및 운세 서비스 제공\n'
              '• Apple Inc: 구매 정보 - 인앱 결제 처리\n\n'
              '그 외 다음의 경우에 제3자에게 제공될 수 있습니다:\n'
              '• 이용자가 사전에 동의한 경우\n'
              '• 법령의 규정에 의거하거나, 수사 목적으로 법령에 정해진 절차와 방법에 따라 수사기관의 요구가 있는 경우',
            ),

            _buildSection(
              '7. 개인정보의 파기',
              '서비스는 개인정보 보유기간의 경과, 처리목적 달성 등 개인정보가 불필요하게 되었을 때에는 지체없이 해당 개인정보를 파기합니다.\n\n'
              '파기 방법:\n'
              '전자적 파일 형태: 기록을 재생할 수 없는 기술적 방법 사용\n'
              '종이 문서: 분쇄기로 분쇄하거나 소각',
            ),

            _buildSection(
              '8. 이용자의 권리',
              '이용자는 다음과 같은 권리를 행사할 수 있습니다:\n\n'
              '• 개인정보 열람 요구\n'
              '• 오류 등이 있을 경우 정정 요구\n'
              '• 삭제 요구\n'
              '• 처리정지 요구\n'
              '• 광고 추적 설정 변경 (설정 > 개인정보 보호 > 추적)\n\n'
              '권리 행사는 서비스 내 설정 메뉴 또는 고객센터를 통해 가능합니다.',
            ),

            _buildSection(
              '9. 개인정보 보호책임자',
              '개인정보 보호책임자\n'
              '• 성명: 김포춘\n'
              '• 직책: 개인정보보호 책임자\n'
              '• 이메일: privacy@fortune-app.com\n'
              '• 전화: 02-1234-5678',
            ),

            const SizedBox(height: TossDesignSystem.spacingL),

            Container(
              padding: const EdgeInsets.all(TossDesignSystem.spacingM),
              decoration: BoxDecoration(
                color: TossDesignSystem.tossBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: TossDesignSystem.tossBlue,
                  ),
                  const SizedBox(width: TossDesignSystem.spacingS),
                  Text(
                    '시행일: 2025년 1월 1일',
                    style: TossDesignSystem.caption.copyWith(
                      color: _getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: TossDesignSystem.spacingXXL),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TossDesignSystem.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TossDesignSystem.body1.copyWith(
              color: _getTextColor(context),
            ),
          ),
          const SizedBox(height: TossDesignSystem.spacingM),
          Text(
            content,
            style: TossDesignSystem.caption.copyWith(
              color: _getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
