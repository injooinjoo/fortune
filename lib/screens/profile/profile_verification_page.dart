import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/toss_design_system.dart';

class ProfileVerificationPage extends ConsumerStatefulWidget {
  const ProfileVerificationPage({super.key});

  @override
  ConsumerState<ProfileVerificationPage> createState() =>
      _ProfileVerificationPageState();
}

class _ProfileVerificationPageState
    extends ConsumerState<ProfileVerificationPage> {
  String _selectedMethod = 'phone'; // 'phone' or 'identity'

  // TOSS Design System Helper Methods (프로필 페이지와 동일)
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TossDesignSystem.marginHorizontal,
        TossDesignSystem.spacingL,
        TossDesignSystem.marginHorizontal,
        TossDesignSystem.spacingS,
      ),
      child: Text(
        title,
        style: TossDesignSystem.caption.copyWith(
          color: _getSecondaryTextColor(context),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMethodCard({
    required String method,
    required IconData icon,
    required String title,
    required String description,
    bool isLast = false,
  }) {
    final isSelected = _selectedMethod == method;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMethod = method;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: TossDesignSystem.marginHorizontal,
            vertical: TossDesignSystem.spacingM,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isLast ? Colors.transparent : _getDividerColor(context),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // 아이콘
              Icon(
                icon,
                size: 22,
                color: isSelected
                    ? TossDesignSystem.tossBlue
                    : _getSecondaryTextColor(context),
              ),
              const SizedBox(width: TossDesignSystem.spacingM),

              // 제목 & 설명
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TossDesignSystem.body2.copyWith(
                        color: _getTextColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TossDesignSystem.caption.copyWith(
                        color: _getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),

              // 선택 라디오
              Radio<String>(
                value: method,
                groupValue: _selectedMethod,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedMethod = value;
                    });
                  }
                },
                activeColor: TossDesignSystem.tossBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TossDesignSystem.marginHorizontal,
        vertical: TossDesignSystem.spacingM,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : _getDividerColor(context),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 22,
            color: TossDesignSystem.tossBlue,
          ),
          const SizedBox(width: TossDesignSystem.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TossDesignSystem.body2.copyWith(
                    color: _getTextColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TossDesignSystem.caption.copyWith(
                    color: _getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleVerification() {
    // TODO: 실제 인증 로직 구현
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '준비 중',
          style: TossDesignSystem.heading4.copyWith(
            color: _getTextColor(context),
          ),
        ),
        content: Text(
          '본인 인증 기능은 곧 추가될 예정입니다.',
          style: TossDesignSystem.body2.copyWith(
            color: _getTextColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '확인',
              style: TossDesignSystem.button.copyWith(
                color: TossDesignSystem.tossBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _getTextColor(context)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '프로필 인증',
          style: TossDesignSystem.heading4.copyWith(
            color: _getTextColor(context),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: TossDesignSystem.spacingM),

                    // 안내 메시지
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: TossDesignSystem.marginHorizontal),
                      child: Container(
                        padding: const EdgeInsets.all(TossDesignSystem.spacingM),
                        decoration: BoxDecoration(
                          color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.verified_user,
                              color: TossDesignSystem.tossBlue,
                              size: 20,
                            ),
                            const SizedBox(width: TossDesignSystem.spacingS),
                            Expanded(
                              child: Text(
                                '본인 인증을 완료하면 더 많은 프리미엄 기능을 이용할 수 있습니다.',
                                style: TossDesignSystem.caption.copyWith(
                                  color: TossDesignSystem.tossBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 인증 방법 선택
                    _buildSectionHeader('인증 방법 선택'),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: TossDesignSystem.marginHorizontal),
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
                          _buildMethodCard(
                            method: 'phone',
                            icon: Icons.phone_android,
                            title: '휴대폰 인증',
                            description: '간편하고 빠른 휴대폰 본인 인증',
                          ),
                          _buildMethodCard(
                            method: 'identity',
                            icon: Icons.credit_card,
                            title: '신분증 인증',
                            description: '신분증 촬영을 통한 본인 인증',
                            isLast: true,
                          ),
                        ],
                      ),
                    ),

                    // 인증 혜택
                    _buildSectionHeader('인증 혜택'),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: TossDesignSystem.marginHorizontal),
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
                          _buildBenefitItem(
                            icon: Icons.verified,
                            title: '인증 배지',
                            description: '프로필에 인증 배지가 표시됩니다',
                          ),
                          _buildBenefitItem(
                            icon: Icons.security,
                            title: '보안 강화',
                            description: '계정 보안이 강화되고 안전하게 보호됩니다',
                          ),
                          _buildBenefitItem(
                            icon: Icons.star,
                            title: '프리미엄 기능',
                            description: '프리미엄 운세 기능에 접근할 수 있습니다',
                          ),
                          _buildBenefitItem(
                            icon: Icons.card_giftcard,
                            title: '보너스 토큰',
                            description: '인증 완료 시 1000 토큰을 지급합니다',
                            isLast: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: TossDesignSystem.spacingXXL),
                  ],
                ),
              ),
            ),

            // 하단 인증 시작 버튼
            Container(
              padding: const EdgeInsets.all(TossDesignSystem.marginHorizontal),
              decoration: BoxDecoration(
                color: _getCardColor(context),
                border: Border(
                  top: BorderSide(
                    color: _getDividerColor(context),
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _handleVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TossDesignSystem.tossBlue,
                      foregroundColor: TossDesignSystem.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _selectedMethod == 'phone' ? '휴대폰 인증 시작' : '신분증 인증 시작',
                      style: TossDesignSystem.button.copyWith(
                        color: TossDesignSystem.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
