import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/design_system.dart';

class HelpPage extends ConsumerStatefulWidget {
  const HelpPage({super.key});

  @override
  ConsumerState<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends ConsumerState<HelpPage> {
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
          '도움말',
          style: typography.headingMedium.copyWith(
            color: colors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Links
            Container(
              margin: const EdgeInsets.all(DSSpacing.pageHorizontal),
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
                    Icons.lightbulb_outline,
                    color: colors.accent,
                    size: 22,
                  ),
                  const SizedBox(width: DSSpacing.md),
                  Expanded(
                    child: Text(
                      'Fortune 앱을 더 잘 활용하는 방법을 알아보세요!',
                      style: typography.bodySmall.copyWith(
                        color: colors.textSecondary,
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
                  question: '복주머니는 어떻게 사용하나요?',
                  answer:
                      '복주머니는 인사이트를 확인할 때 사용됩니다. 일반 인사이트는 1개, 프리미엄 인사이트는 2-3개가 소모됩니다. 매일 무료로 3개의 복주머니를 받을 수 있으며, 추가로 필요한 경우 복주머니를 구매하실 수 있습니다.',
                ),
                _buildFAQItem(
                  context,
                  question: '인사이트는 얼마나 자주 업데이트되나요?',
                  answer:
                      '일일 인사이트는 매일 자정에 업데이트되며, 주간 인사이트는 매주 월요일, 월간 인사이트는 매월 1일에 업데이트됩니다. 실시간 인사이트는 조회할 때마다 새로운 결과를 보여드립니다.',
                ),
                _buildFAQItem(
                  context,
                  question: '프리미엄 구독의 혜택은 무엇인가요?',
                  answer:
                      '프리미엄 구독 시 모든 인사이트를 무제한으로 확인할 수 있으며, 광고 없이 서비스를 이용할 수 있습니다. 또한 프리미엄 전용 콘텐츠와 특별한 기능들을 이용하실 수 있습니다.',
                ),
                _buildFAQItem(
                  context,
                  question: '내 정보는 안전한가요?',
                  answer:
                      '네, 모든 개인정보는 암호화되어 안전하게 보관됩니다. 인사이트 제공 목적 외에는 사용되지 않으며, 제3자에게 제공되지 않습니다.',
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
                  title: '인사이트 확인하기',
                  steps: [
                    '홈 화면에서 원하는 카테고리를 선택하세요',
                    '세부 인사이트 종류를 선택하세요',
                    '필요한 정보를 입력하고 "인사이트 보기"를 누르세요',
                    '결과를 확인하고 공유할 수 있습니다'
                  ],
                ),
                _buildHowToItem(
                  context,
                  title: '프로필 설정하기',
                  steps: [
                    '하단 메뉴에서 프로필 아이콘을 누르세요',
                    '프로필 편집을 선택하세요',
                    '이름, 생년월일, MBTI 등을 입력하세요',
                    '저장을 눌러 정보를 업데이트하세요'
                  ],
                ),
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
                  '매일 접속하면 무료 복주머니를 받을 수 있어요!',
                  Icons.toll,
                ),
                _buildTipItem(
                  context,
                  '프로필을 완성하면 더 정확한 운세를 받을 수 있어요',
                  Icons.person,
                ),
                _buildTipItem(
                  context,
                  '운세 결과를 친구와 공유해보세요',
                  Icons.share,
                ),
                _buildTipItem(
                  context,
                  '알림을 설정하면 매일 운세를 받아볼 수 있어요',
                  Icons.notifications,
                ),
              ],
            ),

            // Contact Section
            Container(
              margin: const EdgeInsets.all(DSSpacing.pageHorizontal),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(
                  color: colors.divider,
                  width: 1,
                ),
                boxShadow: context.shadows.sm,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(DSSpacing.md),
                    child: Row(
                      children: [
                        Icon(Icons.headset_mic_outlined,
                            color: colors.accent, size: 22),
                        const SizedBox(width: DSSpacing.md),
                        Text(
                          '추가 도움이 필요하신가요?',
                          style: typography.bodyMedium.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: colors.divider),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: DSSpacing.pageHorizontal,
                      vertical: DSSpacing.sm,
                    ),
                    leading: Icon(
                      Icons.support_agent,
                      color: colors.textSecondary,
                      size: 22,
                    ),
                    title: Text(
                      '고객센터',
                      style: typography.bodySmall.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '1:1 문의하기',
                      style: typography.labelSmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: colors.textSecondary,
                    ),
                    onTap: () {
                      // TODO: 1:1 문의 페이지가 없으므로 이메일 문의로 대체
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('이메일로 문의해주세요: support@fortune-app.com'),
                        ),
                      );
                    },
                  ),
                  Divider(height: 1, color: colors.divider),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: DSSpacing.pageHorizontal,
                      vertical: DSSpacing.sm,
                    ),
                    leading: Icon(
                      Icons.email_outlined,
                      color: colors.textSecondary,
                      size: 22,
                    ),
                    title: Text(
                      '이메일 문의',
                      style: typography.bodySmall.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'support@fortune-app.com',
                      style: typography.labelSmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: colors.textSecondary,
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

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: DSSpacing.pageHorizontal, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.divider,
          width: 1,
        ),
        boxShadow: context.shadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(DSSpacing.md),
            child: Row(
              children: [
                Icon(icon, color: colors.accent, size: 22),
                const SizedBox(width: DSSpacing.md),
                Text(
                  title,
                  style: typography.bodyMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.divider),
          Padding(
            padding: const EdgeInsets.all(DSSpacing.md),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(
          question,
          style: typography.bodySmall.copyWith(
            color: colors.textPrimary,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: DSSpacing.md),
            child: Text(
              answer,
              style: typography.labelSmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToItem(
    BuildContext context, {
    required String title,
    required List<String> steps,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: typography.bodySmall.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          ...steps.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(left: DSSpacing.md, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.key + 1}. ',
                      style: typography.labelSmall.copyWith(
                        color: colors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: typography.labelSmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTipItem(BuildContext context, String tip, IconData icon) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
      child: Row(
        children: [
          Icon(
            icon,
            color: colors.accent,
            size: 22,
          ),
          const SizedBox(width: DSSpacing.md),
          Expanded(
            child: Text(
              tip,
              style: typography.labelSmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
