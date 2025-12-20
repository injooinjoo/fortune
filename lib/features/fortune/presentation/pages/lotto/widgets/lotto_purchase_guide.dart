import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';

/// 로또 구매 가이드 카드
class LottoPurchaseGuide extends StatelessWidget {
  final DateTime birthDate;

  const LottoPurchaseGuide({
    super.key,
    required this.birthDate,
  });

  String _getBestPurchaseTime() {
    final dayOfWeek = DateTime.now().weekday;
    // 요일별 최적 시간
    switch (dayOfWeek) {
      case 1: // 월
        return '오후 2시~4시';
      case 2: // 화
        return '오전 10시~12시';
      case 3: // 수
        return '오후 3시~5시';
      case 4: // 목
        return '저녁 6시~8시';
      case 5: // 금
        return '오후 1시~3시';
      case 6: // 토
        return '오전 9시~11시';
      default: // 일
        return '오후 4시~6시';
    }
  }

  String _getBestDirection() {
    final month = birthDate.month;
    // 출생월 기반 방향
    if (month >= 2 && month <= 4) return '동쪽';
    if (month >= 5 && month <= 7) return '남쪽';
    if (month >= 8 && month <= 10) return '서쪽';
    return '북쪽';
  }

  String _getLuckyDay() {
    final day = birthDate.day % 7;
    const days = ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일'];
    return days[day];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates,
                color: colors.accent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '구매 가이드',
                style: DSTypography.headingSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildGuideItem(
            icon: Icons.access_time,
            label: '최적 구매 시간',
            value: _getBestPurchaseTime(),
            colors: colors,
          ),
          const SizedBox(height: 12),

          _buildGuideItem(
            icon: Icons.explore,
            label: '행운의 방향',
            value: '집에서 ${_getBestDirection()} 방향',
            colors: colors,
          ),
          const SizedBox(height: 12),

          _buildGuideItem(
            icon: Icons.calendar_today,
            label: '행운의 요일',
            value: _getLuckyDay(),
            colors: colors,
          ),
          const SizedBox(height: 12),

          _buildGuideItem(
            icon: Icons.store,
            label: '구매 장소',
            value: '집 근처 편의점',
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem({
    required IconData icon,
    required String label,
    required String value,
    required DSColorScheme colors,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colors.backgroundSecondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: DSTypography.labelSmall.copyWith(
                  color: colors.textTertiary,
                ),
              ),
              Text(
                value,
                style: DSTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
