import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../glassmorphism/glass_container.dart';
import '../../core/design_system/design_system.dart';

class DailyTokenBanner extends ConsumerWidget {
  const DailyTokenBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      margin: const EdgeInsets.all(DSSpacing.md),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(DSRadius.xl),
        blur: 20,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DSRadius.xl),
            gradient: LinearGradient(
              colors: [
                colors.accentTertiary.withValues(alpha: 0.3),
                colors.accentTertiary.withValues(alpha: 0.2),
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
                    color: colors.surface.withValues(alpha: 0.1),
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
                    color: colors.surface.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(DSSpacing.lg),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(DSSpacing.sm),
                      decoration: BoxDecoration(
                        color: colors.surface.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(DSRadius.sm),
                      ),
                      child: Icon(
                        Icons.stars,
                        color: colors.textPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: DSSpacing.md),

                    // Text Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '매일 무료 복주머니 받기',
                            style: typography.labelLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: DSSpacing.xs),
                          Text(
                            '매일 접속하여 복주머니를 받아보세요!',
                            style: typography.labelMedium.copyWith(
                              color: colors.textPrimary.withValues(alpha: 0.8),
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
    final colors = context.colors;
    final typography = context.typography;

    return ElevatedButton(
      onPressed: () {
        DSHaptics.light();
        // Handle claim logic
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.surface,
        foregroundColor: colors.accentTertiary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadius.sm),
        ),
      ),
      child: Text(
        '받기',
        style: typography.labelMedium.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
