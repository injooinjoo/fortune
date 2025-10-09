import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/toss_design_system.dart';

class HelpPage extends ConsumerStatefulWidget {
  const HelpPage({super.key});

  @override
  ConsumerState<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends ConsumerState<HelpPage> {
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

  Color _getCardColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark100
        : TossDesignSystem.white;
  }

  Color _getDividerColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark200
        : TossDesignSystem.gray200;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _getTextColor(context)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '도움말',
          style: TossDesignSystem.heading4.copyWith(
            color: _getTextColor(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Links
            Container(
              margin: const EdgeInsets.all(TossDesignSystem.marginHorizontal),
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
                  Icon(
                    Icons.lightbulb_outline,
                    color: TossDesignSystem.tossBlue,
                    size: 22,
                  ),
                  const SizedBox(width: TossDesignSystem.spacingM),
                  Expanded(
                    child: Text(
                      'Fortune 앱을 더 잘 활용하는 방법을 알아보세요!',
                      style: TossDesignSystem.body2.copyWith(
                        color: _getSecondaryTextColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // FAQ Section
            _buildSection(
              context,
              title: '자주 묻는 질문',
              icon: Icons.help_outline,
              children: [
                _buildFAQItem(
                  context,
                  question: '토큰은 어떻게 사용하나요?',
                  answer: '토큰은 운세를 확인할 때 사용됩니다. 일반 운세는 1토큰, 프리미엄 운세는 2-3토큰이 소모됩니다. 매일 무료로 3개의 토큰을 받을 수 있으며, 추가로 필요한 경우 토큰을 구매하실 수 있습니다.'),
                _buildFAQItem(
                  context,
                  question: '운세는 얼마나 자주 업데이트되나요?',
                  answer: '일일 운세는 매일 자정에 업데이트되며, 주간 운세는 매주 월요일, 월간 운세는 매월 1일에 업데이트됩니다. 실시간 운세는 조회할 때마다 새로운 결과를 보여드립니다.'),
                _buildFAQItem(
                  context,
                  question: '프리미엄 구독의 혜택은 무엇인가요?',
                  answer: '프리미엄 구독 시 모든 운세를 무제한으로 확인할 수 있으며, 광고 없이 서비스를 이용할 수 있습니다. 또한 프리미엄 전용 운세와 특별한 기능들을 이용하실 수 있습니다.'),
                _buildFAQItem(
                  context,
                  question: '내 정보는 안전한가요?',
                  answer: '네, 모든 개인정보는 암호화되어 안전하게 보관됩니다. 운세 제공 목적 외에는 사용되지 않으며, 제3자에게 제공되지 않습니다.',
                ),
              ],
            ),
            
            // How to Use Section
            _buildSection(
              context,
              title: '사용 방법',
              icon: Icons.school_outlined,
              children: [
                _buildHowToItem(
                  context,
                  title: '운세 확인하기',
                  steps: [
                    '홈 화면에서 원하는 운세 카테고리를 선택하세요',
                    '세부 운세 종류를 선택하세요',
                    '필요한 정보를 입력하고 "운세 보기"를 누르세요',
                    '결과를 확인하고 공유할 수 있습니다']),
                _buildHowToItem(
                  context,
                  title: '프로필 설정하기',
                  steps: [
                    '하단 메뉴에서 프로필 아이콘을 누르세요',
                    '프로필 편집을 선택하세요',
                    '이름, 생년월일, MBTI 등을 입력하세요',
                    '저장을 눌러 정보를 업데이트하세요']),
                _buildHowToItem(
                  context,
                  title: '소셜 로그인 연동하기',
                  steps: [
                    '설정 > 소셜 계정 연동으로 이동하세요',
                    '연동하고 싶은 소셜 서비스를 선택하세요',
                    '해당 서비스에 로그인하세요',
                    '연동이 완료되면 해당 계정으로도 로그인할 수 있습니다',
                  ],
                ),
              ],
            ),
            
            // Tips Section
            _buildSection(
              context,
              title: '알아두면 좋은 팁',
              icon: Icons.tips_and_updates_outlined,
              children: [
                _buildTipItem(
                  context,
                  '매일 접속하면 무료 토큰을 받을 수 있어요!',
                  Icons.toll),
                _buildTipItem(
                  context,
                  '프로필을 완성하면 더 정확한 운세를 받을 수 있어요',
                  Icons.person),
                _buildTipItem(
                  context,
                  '운세 결과를 친구와 공유해보세요',
                  Icons.share),
                _buildTipItem(
                  context,
                  '알림을 설정하면 매일 운세를 받아볼 수 있어요',
                  Icons.notifications,
                ),
              ],
            ),
            
            // Contact Section
            Container(
              margin: const EdgeInsets.all(TossDesignSystem.marginHorizontal),
              decoration: BoxDecoration(
                color: _getCardColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getDividerColor(context),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: TossDesignSystem.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(TossDesignSystem.spacingM),
                    child: Row(
                      children: [
                        Icon(Icons.headset_mic_outlined,
                            color: TossDesignSystem.tossBlue, size: 22),
                        const SizedBox(width: TossDesignSystem.spacingM),
                        Text(
                          '추가 도움이 필요하신가요?',
                          style: TossDesignSystem.body1.copyWith(
                            color: _getTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: _getDividerColor(context)),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: TossDesignSystem.marginHorizontal,
                      vertical: TossDesignSystem.spacingS,
                    ),
                    leading: Icon(
                      Icons.support_agent,
                      color: _getSecondaryTextColor(context),
                      size: 22,
                    ),
                    title: Text(
                      '고객센터',
                      style: TossDesignSystem.body2.copyWith(
                        color: _getTextColor(context),
                      ),
                    ),
                    subtitle: Text(
                      '1:1 문의하기',
                      style: TossDesignSystem.caption.copyWith(
                        color: _getSecondaryTextColor(context),
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: _getSecondaryTextColor(context),
                    ),
                    onTap: () => context.push('/support'),
                  ),
                  Divider(height: 1, color: _getDividerColor(context)),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: TossDesignSystem.marginHorizontal,
                      vertical: TossDesignSystem.spacingS,
                    ),
                    leading: Icon(
                      Icons.email_outlined,
                      color: _getSecondaryTextColor(context),
                      size: 22,
                    ),
                    title: Text(
                      '이메일 문의',
                      style: TossDesignSystem.body2.copyWith(
                        color: _getTextColor(context),
                      ),
                    ),
                    subtitle: Text(
                      'support@fortune-app.com',
                      style: TossDesignSystem.caption.copyWith(
                        color: _getSecondaryTextColor(context),
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: _getSecondaryTextColor(context),
                    ),
                    onTap: () {
                      // TODO: Open email client
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: TossDesignSystem.marginHorizontal, vertical: 8),
      decoration: BoxDecoration(
        color: _getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getDividerColor(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(TossDesignSystem.spacingM),
            child: Row(
              children: [
                Icon(icon, color: TossDesignSystem.tossBlue, size: 22),
                const SizedBox(width: TossDesignSystem.spacingM),
                Text(
                  title,
                  style: TossDesignSystem.body1.copyWith(
                    color: _getTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: _getDividerColor(context)),
          Padding(
            padding: const EdgeInsets.all(TossDesignSystem.spacingM),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFAQItem(BuildContext context, {
    required String question,
    required String answer,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(
          question,
          style: TossDesignSystem.body2.copyWith(
            color: _getTextColor(context),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: TossDesignSystem.spacingM),
            child: Text(
              answer,
              style: TossDesignSystem.caption.copyWith(
                color: _getSecondaryTextColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHowToItem(BuildContext context, {
    required String title,
    required List<String> steps,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TossDesignSystem.spacingS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TossDesignSystem.body2.copyWith(
              color: _getTextColor(context),
            ),
          ),
          const SizedBox(height: TossDesignSystem.spacingS),
          ...steps.asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.only(
                left: TossDesignSystem.spacingM, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.key + 1}. ',
                  style: TossDesignSystem.caption.copyWith(
                    color: TossDesignSystem.tossBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value,
                    style: TossDesignSystem.caption.copyWith(
                      color: _getSecondaryTextColor(context),
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildTipItem(BuildContext context, String tip, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TossDesignSystem.spacingS),
      child: Row(
        children: [
          Icon(
            icon,
            color: TossDesignSystem.tossBlue,
            size: 22,
          ),
          const SizedBox(width: TossDesignSystem.spacingM),
          Expanded(
            child: Text(
              tip,
              style: TossDesignSystem.caption.copyWith(
                color: _getSecondaryTextColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}