import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../glassmorphism/glass_container.dart';
// import 'daily_token_claim_widget.dart';
import '../../core/theme/typography_unified.dart'; // defined in same file

class DailyTokenBanner extends ConsumerWidget {
  const DailyTokenBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: AppSpacing.paddingAll16,
      child: GlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        blur: 20,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
            gradient: LinearGradient(
              colors: [
                TossDesignSystem.gray600.withValues(alpha: 0.3),
                TossDesignSystem.gray600.withValues(alpha: 0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Background Pattern
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: TossDesignSystem.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: -20,
                bottom: -20,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: TossDesignSystem.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: AppSpacing.paddingAll20,
                child: Row(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: TossDesignSystem.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.stars,
                        color: TossDesignSystem.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Text Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '매일 무료 토큰 받기',
                            style: TypographyUnified.buttonMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: TossDesignSystem.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '매일 접속하여 토큰을 받아보세요!',
                            style: TypographyUnified.labelMedium.copyWith(
                              color: TossDesignSystem.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Claim Button
                    const DailyTokenClaimWidget(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DailyTokenClaimWidget extends ConsumerStatefulWidget {
  const DailyTokenClaimWidget({super.key});
  
  @override
  ConsumerState<DailyTokenClaimWidget> createState() => _DailyTokenClaimWidgetState();
}

class _DailyTokenClaimWidgetState extends ConsumerState<DailyTokenClaimWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
        onPressed: () {
          // Handle claim logic
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: TossDesignSystem.white,
          foregroundColor: TossDesignSystem.gray600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          '받기',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}