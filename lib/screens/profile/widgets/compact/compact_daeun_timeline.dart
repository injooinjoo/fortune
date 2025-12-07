import 'package:flutter/material.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/saju_colors.dart';

/// 압축된 대운 타임라인
///
/// 10년 단위 대운 흐름을 수평 타임라인으로 표시합니다.
class CompactDaeunTimeline extends StatelessWidget {
  final Map<String, dynamic> sajuData;

  const CompactDaeunTimeline({
    super.key,
    required this.sajuData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daeunList = _extractDaeun();
    final currentIndex = _findCurrentDaeunIndex(daeunList);

    if (daeunList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(TossTheme.spacingS),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.2)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(TossTheme.radiusS),
        border: Border.all(
          color: isDark ? TossDesignSystem.borderDark : TossTheme.borderPrimary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Icon(
                Icons.timeline_rounded,
                size: 14,
                color: isDark ? Colors.white60 : Colors.black45,
              ),
              const SizedBox(width: 4),
              Text(
                '대운 흐름',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const Spacer(),
              Text(
                '大運 · 10년 주기',
                style: TextStyle(
                  fontSize: 9,
                  color: isDark ? Colors.white38 : Colors.black26,
                ),
              ),
            ],
          ),
          const SizedBox(height: TossTheme.spacingS),

          // 타임라인
          SizedBox(
            height: 80,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: daeunList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final daeun = entry.value;
                  final isCurrent = index == currentIndex;
                  final isPast = index < currentIndex;

                  return _buildDaeunItem(
                    daeun: daeun,
                    isCurrent: isCurrent,
                    isPast: isPast,
                    isLast: index == daeunList.length - 1,
                    isDark: isDark,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _extractDaeun() {
    final List<Map<String, dynamic>> daeunList = [];

    // sajuData['daeun']이 List 또는 Map일 수 있으므로 방어적으로 처리
    final rawDaeun = sajuData['daeun'];
    List<dynamic>? daeunData;

    if (rawDaeun is List) {
      daeunData = rawDaeun;
    } else if (rawDaeun is Map) {
      // Map인 경우 values나 특정 키에서 리스트 추출 시도
      if (rawDaeun.containsKey('items') && rawDaeun['items'] is List) {
        daeunData = rawDaeun['items'] as List;
      } else if (rawDaeun.containsKey('list') && rawDaeun['list'] is List) {
        daeunData = rawDaeun['list'] as List;
      } else {
        // Map의 values를 리스트로 변환 (fallback)
        daeunData = rawDaeun.values.toList();
      }
    }

    if (daeunData == null) return daeunList;

    for (final item in daeunData) {
      if (item is Map<String, dynamic>) {
        daeunList.add({
          'startAge': item['startAge'] ?? item['start_age'] ?? 0,
          'endAge': item['endAge'] ?? item['end_age'] ?? 0,
          'stem': item['stem'] ?? item['cheongan'] ?? '',
          'branch': item['branch'] ?? item['jiji'] ?? '',
          'stemHanja': item['stemHanja'] ?? item['cheongan_hanja'] ?? '',
          'branchHanja': item['branchHanja'] ?? item['jiji_hanja'] ?? '',
          'element': item['element'] ?? '',
          'description': item['description'] ?? '',
        });
      }
    }

    return daeunList;
  }

  int _findCurrentDaeunIndex(List<Map<String, dynamic>> daeunList) {
    // sajuData에서 현재 나이 추출
    final birthYear = sajuData['birthYear'] as int?;
    if (birthYear == null) return 0;

    final currentYear = DateTime.now().year;
    final age = currentYear - birthYear + 1; // 한국 나이

    for (int i = 0; i < daeunList.length; i++) {
      final startAge = daeunList[i]['startAge'] as int? ?? 0;
      final endAge = daeunList[i]['endAge'] as int? ?? 0;

      if (age >= startAge && age <= endAge) {
        return i;
      }
    }

    return 0;
  }

  Widget _buildDaeunItem({
    required Map<String, dynamic> daeun,
    required bool isCurrent,
    required bool isPast,
    required bool isLast,
    required bool isDark,
  }) {
    final startAge = daeun['startAge'] as int? ?? 0;
    final endAge = daeun['endAge'] as int? ?? 0;
    final stem = daeun['stem'] as String? ?? '';
    final branch = daeun['branch'] as String? ?? '';
    final stemHanja = daeun['stemHanja'] as String? ?? '';
    final branchHanja = daeun['branchHanja'] as String? ?? '';

    // 색상 결정
    final stemColor = SajuColors.getStemColor(stem, isDark: isDark);
    final branchColor = SajuColors.getBranchColor(branch, isDark: isDark);

    return Row(
      children: [
        // 대운 카드
        Container(
          width: 52,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            color: isCurrent
                ? TossTheme.brandBlue.withValues(alpha: 0.15)
                : isPast
                    ? (isDark
                        ? Colors.white.withValues(alpha: 0.03)
                        : Colors.black.withValues(alpha: 0.03))
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.white),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isCurrent
                  ? TossTheme.brandBlue
                  : (isDark
                      ? TossDesignSystem.borderDark
                      : TossTheme.borderPrimary),
              width: isCurrent ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 나이 범위
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? TossTheme.brandBlue.withValues(alpha: 0.2)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  '$startAge-$endAge세',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: isCurrent
                        ? TossTheme.brandBlue
                        : (isPast
                            ? (isDark ? Colors.white30 : Colors.black26)
                            : (isDark ? Colors.white54 : Colors.black45)),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // 천간
              Text(
                stemHanja.isNotEmpty ? stemHanja : stem,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isPast
                      ? stemColor.withValues(alpha: 0.4)
                      : stemColor,
                ),
              ),
              // 지지
              Text(
                branchHanja.isNotEmpty ? branchHanja : branch,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isPast
                      ? branchColor.withValues(alpha: 0.4)
                      : branchColor,
                ),
              ),
            ],
          ),
        ),
        // 연결선 (마지막 아이템 제외)
        if (!isLast)
          Container(
            width: 12,
            height: 2,
            color: isDark
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.1),
          ),
      ],
    );
  }
}
