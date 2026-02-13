import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';

/// 압축된 오행 바 차트
///
/// 목/화/토/금/수 오행의 개수를 수평 바로 표시합니다.
class CompactElementBars extends StatelessWidget {
  final Map<String, dynamic> sajuData;

  const CompactElementBars({
    super.key,
    required this.sajuData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final elements = _getElementCounts();
    final maxCount =
        elements.values.fold<int>(0, (max, v) => v > max ? v : max);

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color:
            isDark ? context.colors.backgroundSecondary : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(DSRadius.sm),
        border: Border.all(
          color: isDark ? DSColors.border : DSColors.borderDark,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Icon(
                Icons.pie_chart_rounded,
                size: 14,
                color: context.colors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '오행 균형',
                style: context.labelTiny.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          // 바 차트
          ...['목', '화', '토', '금', '수'].map((element) {
            final count = elements[element] ?? 0;
            return _buildElementBar(
              context: context,
              element: element,
              count: count,
              maxCount: maxCount > 0 ? maxCount : 1,
              isDark: isDark,
            );
          }),
        ],
      ),
    );
  }

  Map<String, int> _getElementCounts() {
    final elementsData = sajuData['elements'];
    if (elementsData == null) return {'목': 0, '화': 0, '토': 0, '금': 0, '수': 0};

    return {
      '목': (elementsData['목'] ?? elementsData['wood'] ?? 0) as int,
      '화': (elementsData['화'] ?? elementsData['fire'] ?? 0) as int,
      '토': (elementsData['토'] ?? elementsData['earth'] ?? 0) as int,
      '금': (elementsData['금'] ?? elementsData['metal'] ?? 0) as int,
      '수': (elementsData['수'] ?? elementsData['water'] ?? 0) as int,
    };
  }

  Widget _buildElementBar({
    required BuildContext context,
    required String element,
    required int count,
    required int maxCount,
    required bool isDark,
  }) {
    final color = SajuColors.getWuxingColor(element, isDark: isDark);
    final bgColor =
        SajuColors.getWuxingBackgroundColor(element, isDark: isDark);
    final ratio = count / maxCount;

    // 한자 매핑
    const hanjaMap = {'목': '木', '화': '火', '토': '土', '금': '金', '수': '水'};

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          // 오행 라벨
          SizedBox(
            width: 32,
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Center(
                    child: Text(
                      hanjaMap[element] ?? element,
                      style: context.labelTiny.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 프로그레스 바
          Expanded(
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: context.colors.textPrimary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Stack(
                children: [
                  // 채워진 부분
                  FractionallySizedBox(
                    widthFactor: ratio,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 개수
          SizedBox(
            width: 24,
            child: Text(
              '$count',
              style: context.labelTiny.copyWith(
                fontWeight: FontWeight.bold,
                color: count == 0 ? context.colors.textTertiary : color,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
