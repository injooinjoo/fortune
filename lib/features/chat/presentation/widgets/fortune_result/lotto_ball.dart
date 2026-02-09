import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';

/// 로또 번호 공 위젯
/// 번호 범위에 따른 색상:
/// 1-10: 노랑, 11-20: 파랑, 21-30: 빨강, 31-40: 회색, 41-45: 초록
class LottoBall extends StatelessWidget {
  final int number;

  const LottoBall({super.key, required this.number});

  Color get _ballColor {
    if (number <= 10) return DSColors.warning; // 노랑
    if (number <= 20) return DSColors.info; // 파랑
    if (number <= 30) return DSColors.error; // 빨강
    if (number <= 40) return DSColors.textTertiary; // 회색
    return DSColors.success; // 초록
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            _ballColor.withValues(alpha: 0.9),
            _ballColor,
            _ballColor.withValues(alpha: 0.7),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: _ballColor.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$number',
          style: context.typography.bodyLarge.copyWith(
            color: context.colors.surface,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: context.colors.textPrimary.withValues(alpha: 0.26),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
