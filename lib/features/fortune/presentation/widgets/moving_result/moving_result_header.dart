import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/toss_theme.dart';
import '../../../../../core/theme/toss_design_system.dart';

/// 이사운 결과 페이지 헤더
class MovingResultHeader extends StatelessWidget {
  final String name;
  final VoidCallback onBack;

  const MovingResultHeader({
    super.key,
    required this.name,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          // 뒤로가기 버튼
          Positioned(
            left: 0,
            top: 0,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TossDesignSystem.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: TossDesignSystem.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 20,
                  color: TossTheme.textBlack,
                ),
              ),
            ),
          ),
          // 제목
          Column(
            children: [
              Text(
                '$name님의',
                style: TossTheme.heading3.copyWith(
                  color: TossTheme.textGray600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '이사운 분석 완료',
                style: TossTheme.heading1.copyWith(
                  fontWeight: FontWeight.w800,
                  color: TossTheme.textBlack,
                ),
              ).animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.2, end: 0),
            ],
          ),
        ],
      ),
    );
  }
}
