import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/models/fortune_result.dart';
import '../../../../../../core/utils/fortune_text_cleaner.dart';

/// 주의해야 할 함정 섹션
///
/// API 응답의 warnings 필드를 표시합니다.
/// 각 항목은 "함정: XX → 해결: XX" 형태입니다.
class WarningsSection extends StatelessWidget {
  final FortuneResult? fortuneResult;
  final DSColorScheme colors;

  const WarningsSection({
    super.key,
    required this.fortuneResult,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final warningsRaw = fortuneResult?.data['warnings'];
    final List<String> warnings;

    if (warningsRaw is List) {
      warnings = warningsRaw
          .map((e) => FortuneTextCleaner.clean(e.toString()))
          .where((e) => e.isNotEmpty)
          .toList();
    } else {
      warnings = [];
    }

    if (warnings.isEmpty) {
      return Center(
        child: Text(
          '주의 함정 데이터가 없습니다',
          style: DSTypography.bodySmall.copyWith(
            color: colors.textSecondary,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...warnings.asMap().entries.map((entry) {
          final index = entry.key;
          final warning = entry.value;

          // "함정: XX → 해결: XX" 형태 파싱
          String problem = warning;
          String? solution;

          if (warning.contains('→')) {
            final parts = warning.split('→');
            problem = parts[0].trim();
            solution = parts.length > 1 ? parts[1].trim() : null;
          }

          return Container(
            margin: EdgeInsets.only(bottom: index < warnings.length - 1 ? 12 : 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DSColors.error.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: DSColors.error.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: DSColors.error.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: DSColors.error,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        problem,
                        style: DSTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                if (solution != null && solution.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: DSColors.success.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          size: 16,
                          color: DSColors.success,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            solution,
                            style: DSTypography.bodySmall.copyWith(
                              color: DSColors.success,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}
