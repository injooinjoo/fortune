import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../shared/glassmorphism/glass_container.dart';

/// 소개팅 성공 예측 위젯
class BlindDateSuccessPrediction extends StatelessWidget {
  final int successRate;

  const BlindDateSuccessPrediction({
    super.key,
    required this.successRate,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GlassCard(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite,
                color: colors.accentSecondary,
                size: 24,
              ),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '소개팅 성공 예측',
                style: DSTypography.headingSmall.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.lg),
          // 원형 프로그레스
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: successRate / 100,
                  strokeWidth: 20,
                  backgroundColor: colors.textPrimary.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getSuccessColor(successRate),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$successRate%',
                    style: DSTypography.displayLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getSuccessColor(successRate),
                    ),
                  ),
                  Text(
                    _getSuccessMessage(successRate),
                    style: DSTypography.bodyLarge.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.lg),
          // 조언 컨테이너
          Container(
            padding: const EdgeInsets.all(DSSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.accent.withValues(alpha: 0.1),
                  colors.accentSecondary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(DSRadius.md),
            ),
            child: Text(
              _getSuccessAdvice(successRate),
              style: DSTypography.bodyLarge.copyWith(
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSuccessColor(int rate) {
    if (rate >= 80) return DSColors.success;
    if (rate >= 60) return DSColors.warning;
    return DSColors.error;
  }

  String _getSuccessMessage(int rate) {
    if (rate >= 80) return '대박 예감!';
    if (rate >= 60) return '좋은 만남';
    return '긴장하지 마세요';
  }

  String _getSuccessAdvice(int rate) {
    if (rate >= 80) {
      return '운이 아주 좋습니다! 자신감을 가지고 자연스럽게 대화를 이끌어가세요. 좋은 인연이 될 가능성이 높습니다.';
    } else if (rate >= 60) {
      return '평균 이상의 좋은 운입니다. 너무 긴장하지 말고 편안한 마음으로 상대방을 알아가는 시간을 가지세요.';
    } else {
      return '첫 만남은 누구나 긴장됩니다. 완벽하려 하지 말고 진솔한 모습을 보여주세요. 인연은 자연스럽게 찾아옵니다.';
    }
  }
}

/// 성공률 계산 유틸리티
int calculateSuccessRate({
  String? meetingTime,
  String? meetingType,
  String? confidence,
  List<String> concerns = const [],
  bool isFirstBlindDate = false,
}) {
  int rate = 50;

  // Time factor
  if (meetingTime == 'afternoon' || meetingTime == 'evening') rate += 10;

  // Meeting type factor
  if (meetingType == 'coffee' || meetingType == 'meal') rate += 5;

  // Confidence factor
  switch (confidence) {
    case 'very_high':
      rate += 20;
      break;
    case 'high':
      rate += 15;
      break;
    case 'medium':
      rate += 10;
      break;
    case 'low':
      rate += 5;
      break;
    case 'very_low':
      rate += 0;
      break;
  }

  // Concerns factor
  if (concerns.length <= 2) rate += 10;

  // First date factor
  if (!isFirstBlindDate) rate += 5;

  return rate.clamp(0, 100);
}
