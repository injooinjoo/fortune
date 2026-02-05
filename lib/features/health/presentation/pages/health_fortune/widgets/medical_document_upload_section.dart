import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/theme/font_config.dart';


/// 전문 진단 서류 업로드 섹션
/// 건강검진표, 처방전, 진단서 분석 기능으로 연결
class MedicalDocumentUploadSection extends StatelessWidget {
  final int tokenCost;
  final VoidCallback onTap;

  const MedicalDocumentUploadSection({
    super.key,
    this.tokenCost = 3,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DSFortuneColors.categoryHealth.withValues(alpha: 0.08),
              const Color(0xFF3B82F6).withValues(alpha: 0.08), // 고유 색상 - 장식용 그라데이션 블루
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: DSFortuneColors.categoryHealth.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: DSFortuneColors.categoryHealth.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: Color(0xFF10B981),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '전문 진단 서류가 있다면',
                        style: context.heading3.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: DSFortuneColors.categoryHealth,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '신령 분석',
                          style: context.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: FontConfig.badgeText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '건강검진표 · 처방전 · 진단서',
                    style: context.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // 토큰 비용 & 화살표
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.monetization_on_rounded,
                      size: 14,
                      color: DSColors.warning,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '$tokenCost',
                      style: context.heading3.copyWith(
                        fontWeight: FontWeight.w700,
                        color: DSColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: context.colors.textDisabled,
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05, end: 0);
  }
}
