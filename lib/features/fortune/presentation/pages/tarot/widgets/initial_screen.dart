import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../presentation/providers/auth_provider.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/widgets/unified_button.dart';
import '../../../../../../core/widgets/unified_button_enums.dart';
import 'tarot_card_back_painter.dart';

class InitialScreen extends ConsumerWidget {
  final VoidCallback onStart;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const InitialScreen({
    super.key,
    required this.onStart,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider).value;
    final colors = context.colors;

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // 사용자 인사말 (토스 스타일)
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF7C3AED),
                          Color(0xFF3B82F6),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${userProfile?.name ?? '익명'}님의',
                          style: DSTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w400,
                            color: colors.textSecondary,
                          ),
                        ),
                        Text(
                          'Insight Cards',
                          style: DSTypography.displaySmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 타로 카드 이미지 (큰 카드)
              Center(
                child: Container(
                  width: 200,
                  height: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1E3A5F),
                            Color(0xFF0D1B2A),
                          ],
                        ),
                      ),
                      child: CustomPaint(
                        painter: TarotCardBackPainter(),
                        child: Container(),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 설명 텍스트
              Center(
                child: Text(
                  '카드가 전하는 신비로운 메시지를\n받아보세요',
                  textAlign: TextAlign.center,
                  style: DSTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w400,
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // 시작하기 버튼
              UnifiedButton(
                text: '🔮 카드가 전하는 메시지',
                onPressed: onStart,
                style: UnifiedButtonStyle.primary,
                size: UnifiedButtonSize.large,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
