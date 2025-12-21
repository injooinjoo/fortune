import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/fortune_theme.dart';
import '../../../../core/theme/fortune_design_system.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/unified_button_enums.dart';

class TalismanPremiumBottomSheet extends StatelessWidget {
  final VoidCallback? onSubscribe;
  final VoidCallback? onOneTimePurchase;
  final VoidCallback? onWatchAd;
  final VoidCallback? onTokenPaid;
  final int? currentTokens;
  final bool isPremium;

  /// 토큰 비용 (복주머니 1개)
  static const int requiredTokens = 1;

  const TalismanPremiumBottomSheet({
    super.key,
    this.onSubscribe,
    this.onOneTimePurchase,
    this.onWatchAd,
    this.onTokenPaid,
    this.currentTokens,
    this.isPremium = false,
  });

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onSubscribe,
    VoidCallback? onOneTimePurchase,
    VoidCallback? onWatchAd,
    VoidCallback? onTokenPaid,
    int? currentTokens,
    bool isPremium = false,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: TossDesignSystem.white.withValues(alpha: 0.0),
      builder: (context) => TalismanPremiumBottomSheet(
        onSubscribe: onSubscribe,
        onOneTimePurchase: onOneTimePurchase,
        onWatchAd: onWatchAd,
        onTokenPaid: onTokenPaid,
        currentTokens: currentTokens,
        isPremium: isPremium,
      ),
    );
  }

  bool get hasEnoughTokens => (currentTokens ?? 0) >= requiredTokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      TossTheme.primaryBlue,
                      TossTheme.primaryBlue.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: TossDesignSystem.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '프리미엄 부적',
                      style: TossTheme.heading3,
                    ),
                    Text(
                      '더 강력하고 특별한 부적을 만나보세요',
                      style: TossTheme.subtitle2.copyWith(
                        color: TossTheme.textGray600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).animate()
            .fadeIn(duration: 400.ms)
            .slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 32),
          
          // Features
          _buildFeatureList(),
          
          const SizedBox(height: 32),
          
          // Pricing Options
          _buildPricingOptions(),
          
          const SizedBox(height: 24),
          
          // Action Buttons
          Column(
            children: [
              // 광고 시청 옵션 (무료)
              if (onWatchAd != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: UnifiedButton(
                    text: '🎬 광고 보고 무료로 만들기',
                    onPressed: onWatchAd,
                    style: UnifiedButtonStyle.ghost,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ✅ 토큰 결제 옵션
              if (onTokenPaid != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: UnifiedButton(
                    text: hasEnoughTokens
                        ? '🎀 복주머니 $requiredTokens개로 바로 만들기 (보유: ${currentTokens ?? 0}개)'
                        : '🎀 복주머니 부족 (보유: ${currentTokens ?? 0}개 / 필요: $requiredTokens개)',
                    onPressed: hasEnoughTokens ? onTokenPaid : null,
                    style: UnifiedButtonStyle.secondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Divider(color: TossTheme.borderGray200)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '또는',
                        style: TossTheme.caption.copyWith(
                          color: TossTheme.textGray500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: TossTheme.borderGray200)),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              SizedBox(
                width: double.infinity,
                child: UnifiedButton(
                  text: '⭐ 프리미엄 구독하기 (무제한)',
                  onPressed: onSubscribe,
                  style: UnifiedButtonStyle.primary,
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: UnifiedButton(
                  text: '1,900원으로 한 번만 구매',
                  onPressed: onOneTimePurchase,
                  style: UnifiedButtonStyle.secondary,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                '프리미엄 구독 시 모든 부적을 무제한으로 생성할 수 있습니다.',
                style: TossTheme.caption.copyWith(
                  color: TossTheme.textGray500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ).animate(delay: 600.ms)
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildFeatureList() {
    final features = [
      {
        'icon': Icons.all_inclusive,
        'title': '무제한 부적 생성',
        'subtitle': '하루 제한 없이 원하는 만큼',
      },
      {
        'icon': Icons.palette,
        'title': '고급 디자인 선택',
        'subtitle': '20가지 이상의 특별한 템플릿',
      },
      {
        'icon': Icons.storage,
        'title': '영구 보관함',
        'subtitle': '모든 부적을 평생 보관',
      },
      {
        'icon': Icons.insights,
        'title': '부적 효과 분석',
        'subtitle': '상세한 통계와 분석 리포트',
      },
      {
        'icon': Icons.calendar_today,
        'title': '주간 운세 리포트',
        'subtitle': '매주 맞춤형 운세 제공',
      },
    ];

    return Column(
      children: features.map((feature) {
        final index = features.indexOf(feature);
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TossTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color: TossTheme.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature['title'] as String,
                      style: TossTheme.body3.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      feature['subtitle'] as String,
                      style: TossTheme.caption.copyWith(
                        color: TossTheme.textGray600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.check_circle,
                color: TossTheme.success,
                size: 20,
              ),
            ],
          ),
        ).animate(delay: Duration(milliseconds: 200 + (index * 100)))
          .fadeIn(duration: 400.ms)
          .slideX(begin: -0.1, end: 0);
      }).toList(),
    );
  }

  Widget _buildPricingOptions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TossTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TossTheme.primaryBlue.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Monthly Subscription
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TossTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: TossTheme.primaryBlue.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: TossTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '추천',
                    style: TossTheme.caption.copyWith(
                      color: TossDesignSystem.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '월간 구독',
                        style: TossTheme.body2.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '월 4,900원 (첫 7일 무료)',
                        style: TossTheme.caption.copyWith(
                          color: TossTheme.textGray600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '가장 인기',
                  style: TossTheme.caption.copyWith(
                    color: TossTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // One-time Purchase
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: TossTheme.borderGray200,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '일회성 구매',
                        style: TossTheme.body2.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '1,900원 (고품질 다운로드)',
                        style: TossTheme.caption.copyWith(
                          color: TossTheme.textGray600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '특별한 날',
                  style: TossTheme.caption.copyWith(
                    color: TossTheme.textGray500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: 400.ms)
      .fadeIn(duration: 500.ms)
      .slideY(begin: 0.1, end: 0);
  }
}