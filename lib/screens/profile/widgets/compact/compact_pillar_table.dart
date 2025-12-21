import 'package:flutter/material.dart';
import '../../../../core/theme/fortune_theme.dart';
import '../../../../core/theme/fortune_design_system.dart';
import '../../../../core/theme/saju_colors.dart';
import '../../../../core/theme/typography_unified.dart';

/// 압축된 사주 4주 테이블
///
/// 시주/일주/월주/년주를 한눈에 보여주는 압축 테이블입니다.
/// - 천간/지지 한자
/// - 십성 표시
class CompactPillarTable extends StatelessWidget {
  final Map<String, dynamic> sajuData;

  const CompactPillarTable({
    super.key,
    required this.sajuData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pillars = [
      {'title': '시주', 'hanja': '時柱', 'key': 'hour'},
      {'title': '일주', 'hanja': '日柱', 'key': 'day'},
      {'title': '월주', 'hanja': '月柱', 'key': 'month'},
      {'title': '년주', 'hanja': '年柱', 'key': 'year'},
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TossTheme.radiusM),
        border: Border.all(
          color: isDark ? TossDesignSystem.borderDark : TossTheme.borderPrimary,
        ),
      ),
      child: Column(
        children: [
          // 헤더 행
          _buildHeaderRow(context, pillars, isDark),
          // 천간 행
          _buildStemRow(context, pillars, isDark),
          // 지지 행
          _buildBranchRow(context, pillars, isDark),
          // 십성 행
          _buildTenshinRow(context, pillars, isDark),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, List<Map<String, String>> pillars, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? TossDesignSystem.cardBackgroundDark
            : TossTheme.backgroundSecondary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(TossTheme.radiusM),
          topRight: Radius.circular(TossTheme.radiusM),
        ),
      ),
      child: Row(
        children: pillars.asMap().entries.map((entry) {
          final index = entry.key;
          final pillar = entry.value;
          final isDay = pillar['key'] == 'day';

          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                border: Border(
                  right: index < pillars.length - 1
                      ? BorderSide(
                          color: isDark
                              ? TossDesignSystem.borderDark
                              : TossTheme.borderPrimary,
                        )
                      : BorderSide.none,
                ),
                color: isDay
                    ? TossTheme.brandBlue.withValues(alpha: 0.15)
                    : null,
              ),
              child: Column(
                children: [
                  Text(
                    pillar['hanja']!,
                    style: context.labelTiny.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDay
                          ? TossTheme.brandBlue
                          : (isDark
                              ? TossDesignSystem.grayDark600
                              : TossDesignSystem.gray700),
                    ),
                  ),
                  Text(
                    pillar['title']!,
                    style: context.labelTiny.copyWith(
                      fontSize: 9,
                      color: isDay
                          ? TossTheme.brandBlue
                          : (isDark
                              ? TossTheme.textGray400
                              : TossTheme.textGray600),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStemRow(BuildContext context, List<Map<String, String>> pillars, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? TossDesignSystem.borderDark : TossTheme.borderPrimary,
          ),
        ),
      ),
      child: Row(
        children: pillars.asMap().entries.map((entry) {
          final index = entry.key;
          final pillar = entry.value;
          final pillarData = sajuData[pillar['key']];
          final stemData = pillarData?['cheongan'] as Map<String, dynamic>?;
          final isDay = pillar['key'] == 'day';

          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  right: index < pillars.length - 1
                      ? BorderSide(
                          color: isDark
                              ? TossDesignSystem.borderDark
                              : TossTheme.borderPrimary,
                        )
                      : BorderSide.none,
                ),
                color: isDay
                    ? TossTheme.brandBlue.withValues(alpha: 0.08)
                    : null,
              ),
              child: _buildStemCell(context, stemData, isDay, isDark),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBranchRow(BuildContext context, List<Map<String, String>> pillars, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? TossDesignSystem.borderDark : TossTheme.borderPrimary,
          ),
        ),
      ),
      child: Row(
        children: pillars.asMap().entries.map((entry) {
          final index = entry.key;
          final pillar = entry.value;
          final pillarData = sajuData[pillar['key']];
          final branchData = pillarData?['jiji'] as Map<String, dynamic>?;
          final isDay = pillar['key'] == 'day';

          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  right: index < pillars.length - 1
                      ? BorderSide(
                          color: isDark
                              ? TossDesignSystem.borderDark
                              : TossTheme.borderPrimary,
                        )
                      : BorderSide.none,
                ),
                color: isDay
                    ? TossTheme.brandBlue.withValues(alpha: 0.08)
                    : null,
              ),
              child: _buildBranchCell(context, branchData, isDay, isDark),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTenshinRow(BuildContext context, List<Map<String, String>> pillars, bool isDark) {
    // 십성 데이터 (임시 - 실제로는 sajuData에서 가져와야 함)
    final tenshinMap = _calculateTenshin();

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.2)
            : Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(TossTheme.radiusM),
          bottomRight: Radius.circular(TossTheme.radiusM),
        ),
      ),
      child: Row(
        children: pillars.asMap().entries.map((entry) {
          final index = entry.key;
          final pillar = entry.value;
          final isDay = pillar['key'] == 'day';
          final tenshin = isDay ? '일간(나)' : (tenshinMap[pillar['key']] ?? '-');

          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                border: Border(
                  right: index < pillars.length - 1
                      ? BorderSide(
                          color: isDark
                              ? TossDesignSystem.borderDark
                              : TossTheme.borderPrimary,
                        )
                      : BorderSide.none,
                ),
              ),
              child: Text(
                tenshin,
                style: context.labelTiny.copyWith(
                  fontWeight: isDay ? FontWeight.bold : FontWeight.w500,
                  color: isDay
                      ? TossTheme.brandBlue
                      : (isDark ? Colors.white70 : Colors.black54),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStemCell(
    BuildContext context,
    Map<String, dynamic>? stemData,
    bool isDay,
    bool isDark,
  ) {
    if (stemData == null) {
      return Center(
        child: Text('-', style: context.bodyMedium.copyWith(color: Colors.grey)),
      );
    }

    final hanja = stemData['hanja'] as String? ?? '';
    final element = stemData['element'] as String? ?? '';
    final name = stemData['char'] as String? ?? '';
    final color = SajuColors.getStemColor(name, isDark: isDark);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          hanja,
          style: context.heading3.copyWith(
            fontSize: isDay ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: isDay ? TossTheme.brandBlue : color,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            element,
            style: context.labelTiny.copyWith(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBranchCell(
    BuildContext context,
    Map<String, dynamic>? branchData,
    bool isDay,
    bool isDark,
  ) {
    if (branchData == null) {
      return Center(
        child: Text('-', style: context.bodyMedium.copyWith(color: Colors.grey)),
      );
    }

    final hanja = branchData['hanja'] as String? ?? '';
    final element = branchData['element'] as String? ?? '';
    final name = branchData['char'] as String? ?? '';
    final animal = branchData['animal'] as String? ?? '';
    final color = SajuColors.getBranchColor(name, isDark: isDark);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          hanja,
          style: context.heading3.copyWith(
            fontSize: isDay ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: isDay ? TossTheme.brandBlue : color,
          ),
        ),
        Text(
          animal,
          style: context.labelTiny.copyWith(
            fontSize: 8,
            color: isDark ? Colors.white60 : Colors.black45,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            element,
            style: context.labelTiny.copyWith(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  /// 십성 계산 (일간 기준)
  Map<String, String> _calculateTenshin() {
    final dayData = sajuData['day'];
    if (dayData == null) return {};

    final dayStem = (dayData['cheongan'] as Map<String, dynamic>?)?['char'] as String? ?? '';
    if (dayStem.isEmpty) return {};

    // 십성 계산 로직 (간략화)
    final Map<String, String> result = {};

    // 년주 천간의 십성
    final yearStem = (sajuData['year']?['cheongan'] as Map<String, dynamic>?)?['char'] as String? ?? '';
    if (yearStem.isNotEmpty) {
      result['year'] = _getTenshin(dayStem, yearStem);
    }

    // 월주 천간의 십성
    final monthStem = (sajuData['month']?['cheongan'] as Map<String, dynamic>?)?['char'] as String? ?? '';
    if (monthStem.isNotEmpty) {
      result['month'] = _getTenshin(dayStem, monthStem);
    }

    // 시주 천간의 십성
    final hourStem = (sajuData['hour']?['cheongan'] as Map<String, dynamic>?)?['char'] as String? ?? '';
    if (hourStem.isNotEmpty) {
      result['hour'] = _getTenshin(dayStem, hourStem);
    }

    return result;
  }

  /// 십성 판단
  String _getTenshin(String dayStem, String targetStem) {
    // 천간 오행
    const stemElements = {
      '갑': '목', '을': '목',
      '병': '화', '정': '화',
      '무': '토', '기': '토',
      '경': '금', '신': '금',
      '임': '수', '계': '수',
    };

    // 음양
    const stemYinYang = {
      '갑': '양', '을': '음',
      '병': '양', '정': '음',
      '무': '양', '기': '음',
      '경': '양', '신': '음',
      '임': '양', '계': '음',
    };

    final dayElement = stemElements[dayStem] ?? '';
    final targetElement = stemElements[targetStem] ?? '';
    final dayYinYang = stemYinYang[dayStem] ?? '';
    final targetYinYang = stemYinYang[targetStem] ?? '';

    if (dayElement.isEmpty || targetElement.isEmpty) return '-';

    final isSameYinYang = dayYinYang == targetYinYang;

    // 오행 상생상극 관계로 십성 판단
    if (dayElement == targetElement) {
      return isSameYinYang ? '비견' : '겁재';
    }

    // 상생 관계 (나를 생하는 것 = 인성)
    final generatingMap = {'목': '수', '화': '목', '토': '화', '금': '토', '수': '금'};
    if (generatingMap[dayElement] == targetElement) {
      return isSameYinYang ? '편인' : '정인';
    }

    // 내가 생하는 것 = 식상
    if (generatingMap[targetElement] == dayElement) {
      return isSameYinYang ? '식신' : '상관';
    }

    // 상극 관계 (나를 극하는 것 = 관성)
    final controllingMap = {'목': '금', '화': '수', '토': '목', '금': '화', '수': '토'};
    if (controllingMap[dayElement] == targetElement) {
      return isSameYinYang ? '편관' : '정관';
    }

    // 내가 극하는 것 = 재성
    if (controllingMap[targetElement] == dayElement) {
      return isSameYinYang ? '편재' : '정재';
    }

    return '-';
  }
}
