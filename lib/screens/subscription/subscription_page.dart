import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/toss_design_system.dart';
import '../../shared/components/floating_bottom_button.dart';
import '../../shared/components/toss_button.dart';
import '../../shared/components/toss_floating_progress_button.dart';
import '../../shared/components/app_header.dart';

class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({super.key});

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  String _selectedPlan = 'free'; // free, monthly, yearly

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
      appBar: AppHeader(
        title: '구독 관리',
        showBackButton: true,
        showTokenBalance: false,
        backgroundColor: Colors.transparent,
        foregroundColor: _getTextColor(context),
        onBackPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: TossDesignSystem.marginHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: TossDesignSystem.spacingM),

            // Premium Benefits
            Container(
              padding: const EdgeInsets.all(TossDesignSystem.spacingL),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    TossDesignSystem.tossBlue,
                    TossDesignSystem.tossBlue.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: TossDesignSystem.white,
                        size: 32,
                      ),
                      const SizedBox(width: TossDesignSystem.spacingM),
                      Text(
                        'Premium',
                        style: TossDesignSystem.heading3.copyWith(
                          color: TossDesignSystem.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TossDesignSystem.spacingM),
                  Text(
                    '무제한 운세와 프리미엄 기능을 경험하세요',
                    style: TossDesignSystem.body2.copyWith(
                      color: TossDesignSystem.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: TossDesignSystem.spacingXL),

            // Plan Selection
            Text(
              '구독 플랜 선택',
              style: TossDesignSystem.caption.copyWith(
                color: _getSecondaryTextColor(context),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: TossDesignSystem.spacingM),

            // Free Plan
            _buildPlanCard(
              id: 'free',
              title: '무료',
              price: '₩0',
              period: '',
              badge: '지금',
            ),

            const SizedBox(height: TossDesignSystem.spacingM),

            // Monthly Plan
            _buildPlanCard(
              id: 'monthly',
              title: '월간 구독',
              price: '₩1,900',
              period: '/ 월',
              badge: null,
            ),

            const SizedBox(height: TossDesignSystem.spacingM),

            // Yearly Plan
            _buildPlanCard(
              id: 'yearly',
              title: '연간 구독',
              price: '₩19,000',
              period: '/ 년',
              badge: '17% 절약',
              originalPrice: '₩22,800',
            ),

            const SizedBox(height: TossDesignSystem.spacingXL),

            // Premium Features
            Text(
              '프리미엄 혜택',
              style: TossDesignSystem.caption.copyWith(
                color: _getSecondaryTextColor(context),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: TossDesignSystem.spacingM),

            Container(
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
                  _buildFeatureItem(
                    icon: Icons.all_inclusive,
                    title: '무제한 운세',
                    subtitle: '모든 운세를 무제한으로 확인',
                  ),
                  _buildFeatureItem(
                    icon: Icons.block,
                    title: '광고 제거',
                    subtitle: '광고 없이 깔끔하게',
                  ),
                  _buildFeatureItem(
                    icon: Icons.star,
                    title: '프리미엄 운세',
                    subtitle: '더 상세한 프리미엄 운세',
                  ),
                  _buildFeatureItem(
                    icon: Icons.priority_high,
                    title: '우선 지원',
                    subtitle: '고객센터 우선 응대',
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: TossDesignSystem.spacingXXL),

            // Terms
            Center(
              child: Text(
                '구독은 언제든 해지 가능합니다\n자동 갱신되며 해지 전까지 요금이 청구됩니다',
                textAlign: TextAlign.center,
                style: TossDesignSystem.caption.copyWith(
                  color: _getSecondaryTextColor(context),
                ),
              ),
            ),

            const SizedBox(height: 100), // FloatingBottomButton 공간 확보
          ],
        ),
          ),

          // Floating Bottom Button
          TossFloatingProgressButtonPositioned(
            text: _selectedPlan == 'free'
                ? '무료 플랜 사용 중'
                : _selectedPlan == 'monthly'
                    ? '월간 구독 시작하기 - ₩1,900/월'
                    : '연간 구독 시작하기 - ₩19,000/년',
            onPressed: _selectedPlan == 'free' ? null : _showSubscribeDialog,
            isEnabled: _selectedPlan != 'free',
            showProgress: false,
            isVisible: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String id,
    required String title,
    required String price,
    required String period,
    String? badge,
    String? originalPrice,
  }) {
    final isSelected = _selectedPlan == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(TossDesignSystem.spacingM),
        decoration: BoxDecoration(
          color: _getCardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? TossDesignSystem.tossBlue
                : _getDividerColor(context),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: TossDesignSystem.tossBlue.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? TossDesignSystem.tossBlue
                      : _getDividerColor(context),
                  width: 2,
                ),
                color: isSelected
                    ? TossDesignSystem.tossBlue
                    : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: TossDesignSystem.white,
                    )
                  : null,
            ),
            const SizedBox(width: TossDesignSystem.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TossDesignSystem.body1.copyWith(
                          color: _getTextColor(context),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: TossDesignSystem.spacingS),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: TossDesignSystem.tossBlue
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            badge,
                            style: TossDesignSystem.caption.copyWith(
                              color: TossDesignSystem.tossBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        price,
                        style: TossDesignSystem.heading4.copyWith(
                          color: _getTextColor(context),
                        ),
                      ),
                      Text(
                        period,
                        style: TossDesignSystem.caption.copyWith(
                          color: _getSecondaryTextColor(context),
                        ),
                      ),
                      if (originalPrice != null) ...[
                        const SizedBox(width: TossDesignSystem.spacingS),
                        Text(
                          originalPrice,
                          style: TossDesignSystem.caption.copyWith(
                            color: _getSecondaryTextColor(context),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
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
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
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

  void _showSubscribeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '구독 준비 중',
          style: TossDesignSystem.heading4.copyWith(
            color: _getTextColor(context),
          ),
        ),
        content: Text(
          '구독 기능은 현재 준비 중입니다.\n곧 서비스 예정입니다.',
          style: TossDesignSystem.body2.copyWith(
            color: _getSecondaryTextColor(context),
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
}
