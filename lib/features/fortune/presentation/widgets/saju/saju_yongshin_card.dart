import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';

/// 용신(用神) 분석 카드 위젯
///
/// 용신/희신/기신/구신을 분석하여 표시합니다.
/// - 용신(用神): 사주 균형에 가장 필요한 오행 → 초록
/// - 희신(喜神): 용신을 돕는 오행 → 파랑
/// - 기신(忌神): 사주에 해로운 오행 → 주황
/// - 구신(仇神): 기신을 돕는 오행 → 빨강
class SajuYongshinCard extends StatelessWidget {
  final Map<String, dynamic> sajuData;

  const SajuYongshinCard({
    super.key,
    required this.sajuData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final analysis = _extractYongshinData();

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: isDark ? DSColors.border : DSColors.borderDark,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 용신 + 희신 (좋은 것)
          Row(
            children: [
              Expanded(
                child: _buildYongshinChip(
                  context,
                  type: '용신',
                  typeHanja: '用神',
                  element: analysis['yongshin'] ?? '',
                  description: '가장 필요한 오행',
                  color: const Color(0xFF10B981),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: _buildYongshinChip(
                  context,
                  type: '희신',
                  typeHanja: '喜神',
                  element: analysis['heeshin'] ?? '',
                  description: '용신을 돕는 오행',
                  color: const Color(0xFF3B82F6),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),

          // 기신 + 구신 (나쁜 것)
          Row(
            children: [
              Expanded(
                child: _buildYongshinChip(
                  context,
                  type: '기신',
                  typeHanja: '忌神',
                  element: analysis['gishin'] ?? '',
                  description: '해로운 오행',
                  color: const Color(0xFFF59E0B),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: _buildYongshinChip(
                  context,
                  type: '구신',
                  typeHanja: '仇神',
                  element: analysis['gushin'] ?? '',
                  description: '기신을 돕는 오행',
                  color: const Color(0xFFEF4444),
                  isDark: isDark,
                ),
              ),
            ],
          ),

          // 한줄 설명
          if (analysis['summary'] != null &&
              (analysis['summary'] as String).isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: context.colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: context.colors.textSecondary,
                  ),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      analysis['summary'] as String,
                      style: context.bodySmall.copyWith(
                        color: context.colors.textSecondary,
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
  }

  Widget _buildYongshinChip(
    BuildContext context, {
    required String type,
    required String typeHanja,
    required String element,
    required String description,
    required Color color,
    required bool isDark,
  }) {
    final elementHanja = _elementToHanja(element);
    final wuxingColor = element.isNotEmpty
        ? SajuColors.getWuxingColor(element, isDark: isDark)
        : context.colors.textTertiary;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DSRadius.sm),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타입 라벨
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$type($typeHanja)',
                  style: context.labelTiny.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.xs),

          // 오행 표시
          if (element.isNotEmpty)
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: SajuColors.getWuxingBackgroundColor(
                      element,
                      isDark: isDark,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: wuxingColor, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      elementHanja,
                      style: context.labelSmall.copyWith(
                        color: wuxingColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: DSSpacing.xs),
                Expanded(
                  child: Text(
                    element,
                    style: context.bodySmall.copyWith(
                      color: wuxingColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            )
          else
            Text(
              '미정',
              style: context.bodySmall.copyWith(
                color: context.colors.textTertiary,
              ),
            ),

          const SizedBox(height: 2),
          Text(
            description,
            style: context.labelTiny.copyWith(
              color: context.colors.textTertiary,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _extractYongshinData() {
    // sajuData['yongshin_analysis'] 또는 ['yongshin'] 에서 추출
    final yongshinData = sajuData['yongshin_analysis'] as Map<String, dynamic>?;
    if (yongshinData != null) {
      return {
        'yongshin': yongshinData['yongshin'] ?? yongshinData['用神'] ?? '',
        'heeshin': yongshinData['heeshin'] ?? yongshinData['喜神'] ?? '',
        'gishin': yongshinData['gishin'] ?? yongshinData['忌神'] ?? '',
        'gushin': yongshinData['gushin'] ?? yongshinData['仇神'] ?? '',
        'summary': yongshinData['summary'] ?? yongshinData['설명'] ?? '',
      };
    }

    // 신강/신약 기반으로 용신 추론
    return _inferYongshinFromStrength();
  }

  /// 신강/신약 + 오행 분포 기반 용신 추론
  Map<String, dynamic> _inferYongshinFromStrength() {
    // 일간 오행 확인
    final dayElement = _getDayElement();
    if (dayElement.isEmpty) return {};

    // 오행 분포 확인
    final elements = sajuData['elements'] as Map<String, dynamic>?;
    final elementBalance = sajuData['elementBalance'] as Map<String, dynamic>?;
    final dist = elements ?? elementBalance ?? {};

    if (dist.isEmpty) return {};

    // 상생 관계: 목→화→토→금→수→목
    const sheng = {'목': '화', '화': '토', '토': '금', '금': '수', '수': '목'};
    // 나를 생하는 오행 (인성)
    const piSheng = {'목': '수', '화': '목', '토': '화', '금': '토', '수': '금'};
    // 내가 극하는 오행 (재성)
    const ke = {'목': '토', '화': '금', '토': '수', '금': '목', '수': '화'};
    // 나를 극하는 오행 (관성)
    const piKe = {'목': '금', '화': '수', '토': '목', '금': '화', '수': '토'};

    final myCount = ((dist[dayElement] as num?)?.toInt() ?? 0) +
        ((dist[piSheng[dayElement]] as num?)?.toInt() ?? 0);
    final total =
        dist.values.fold<int>(0, (a, b) => a + ((b as num?)?.toInt() ?? 0));

    if (total == 0) return {};

    final ratio = myCount / total;

    if (ratio > 0.5) {
      // 신강 → 일간을 설기(泄氣)하거나 극하는 오행이 용신
      return {
        'yongshin': sheng[dayElement] ?? '', // 식상 (내가 생하는)
        'heeshin': ke[dayElement] ?? '', // 재성 (내가 극하는)
        'gishin': piSheng[dayElement] ?? '', // 인성 (나를 생하는)
        'gushin': dayElement, // 비겁 (같은 오행)
        'summary': '신강하여 ${sheng[dayElement]}(식상)이 용신, 기운을 발산하면 좋습니다.',
      };
    } else {
      // 신약 → 일간을 생(生)하거나 같은 오행이 용신
      return {
        'yongshin': piSheng[dayElement] ?? '', // 인성 (나를 생하는)
        'heeshin': dayElement, // 비겁 (같은 오행)
        'gishin': ke[dayElement] ?? '', // 재성 (내가 극하는)
        'gushin': piKe[dayElement] ?? '', // 관성 (나를 극하는)
        'summary': '신약하여 ${piSheng[dayElement]}(인성)이 용신, 도움을 받으면 좋습니다.',
      };
    }
  }

  String _getDayElement() {
    final myungsik = sajuData['myungsik'] as Map<String, dynamic>?;
    if (myungsik != null) {
      final daySky = myungsik['daySky'] as String? ?? '';
      const stemEl = {
        '갑': '목',
        '을': '목',
        '병': '화',
        '정': '화',
        '무': '토',
        '기': '토',
        '경': '금',
        '신': '금',
        '임': '수',
        '계': '수',
      };
      return stemEl[daySky] ?? '';
    }
    final dayData = sajuData['day'] as Map<String, dynamic>?;
    final cheongan = dayData?['cheongan'] as Map<String, dynamic>?;
    return cheongan?['element'] as String? ?? '';
  }

  String _elementToHanja(String element) {
    const map = {
      '목': '木',
      '화': '火',
      '토': '土',
      '금': '金',
      '수': '水',
    };
    return map[element] ?? element;
  }
}
