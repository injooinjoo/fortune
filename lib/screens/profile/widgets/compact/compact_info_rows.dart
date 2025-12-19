import 'package:flutter/material.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../features/fortune/domain/models/saju/ji_jang_gan_data.dart';
import '../../../../features/fortune/domain/models/saju/twelve_stage_calculator.dart';

/// 압축된 지장간 행
class CompactJijangganRow extends StatelessWidget {
  final Map<String, dynamic> sajuData;

  const CompactJijangganRow({
    super.key,
    required this.sajuData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final jijangganData = _getJijangganData();

    return _buildInfoRow(
      context: context,
      label: '지장간',
      hanja: '支藏干',
      values: jijangganData,
      isDark: isDark,
    );
  }

  List<String> _getJijangganData() {
    final result = <String>[];

    for (final key in ['hour', 'day', 'month', 'year']) {
      final pillarData = sajuData[key];
      final branchData = pillarData?['jiji'] as Map<String, dynamic>?;
      final branch = branchData?['char'] as String? ?? '';

      if (branch.isEmpty) {
        result.add('-');
        continue;
      }

      final hiddenStems = JiJangGanData.getHiddenStems(branch);
      if (hiddenStems.isEmpty) {
        result.add('-');
      } else {
        // 한자로 표시
        final hanjaList = hiddenStems.map((s) => s.stemHanja).join();
        result.add(hanjaList);
      }
    }

    return result;
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required String label,
    required String hanja,
    required List<String> values,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TossTheme.spacingS,
        vertical: TossTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.15)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(TossTheme.radiusS),
      ),
      child: Row(
        children: [
          // 라벨
          SizedBox(
            width: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.labelTiny.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                Text(
                  hanja,
                  style: context.labelTiny.copyWith(
                    fontSize: 8,
                    color: isDark ? Colors.white38 : Colors.black26,
                  ),
                ),
              ],
            ),
          ),
          // 값들
          Expanded(
            child: Row(
              children: values.asMap().entries.map((entry) {
                final index = entry.key;
                final value = entry.value;
                return Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      border: index < values.length - 1
                          ? Border(
                              right: BorderSide(
                                color: isDark
                                    ? Colors.white12
                                    : Colors.black12,
                              ),
                            )
                          : null,
                    ),
                    child: Text(
                      value,
                      style: context.labelTiny.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// 압축된 12운성 행
class CompactTwelveStagesRow extends StatelessWidget {
  final Map<String, dynamic> sajuData;

  const CompactTwelveStagesRow({
    super.key,
    required this.sajuData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stagesData = _calculateTwelveStages();

    return _buildInfoRow(
      context: context,
      label: '12운성',
      hanja: '十二運星',
      values: stagesData,
      isDark: isDark,
    );
  }

  List<String> _calculateTwelveStages() {
    final dayData = sajuData['day'] as Map<String, dynamic>?;
    final dayStem = (dayData?['cheongan'] as Map<String, dynamic>?)?['char'] as String? ?? '';

    if (dayStem.isEmpty) {
      return ['-', '-', '-', '-'];
    }

    final result = <String>[];

    for (final key in ['hour', 'day', 'month', 'year']) {
      final pillarData = sajuData[key];
      final branchData = pillarData?['jiji'] as Map<String, dynamic>?;
      final branch = branchData?['char'] as String? ?? '';

      if (branch.isEmpty) {
        result.add('-');
        continue;
      }

      final stage = TwelveStageCalculator.calculate(dayStem, branch);
      result.add(stage.korean);
    }

    return result;
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required String label,
    required String hanja,
    required List<String> values,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TossTheme.spacingS,
        vertical: TossTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.15)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(TossTheme.radiusS),
      ),
      child: Row(
        children: [
          // 라벨
          SizedBox(
            width: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.labelTiny.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                Text(
                  hanja,
                  style: context.labelTiny.copyWith(
                    fontSize: 8,
                    color: isDark ? Colors.white38 : Colors.black26,
                  ),
                ),
              ],
            ),
          ),
          // 값들
          Expanded(
            child: Row(
              children: values.asMap().entries.map((entry) {
                final index = entry.key;
                final value = entry.value;
                return Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      border: index < values.length - 1
                          ? Border(
                              right: BorderSide(
                                color: isDark
                                    ? Colors.white12
                                    : Colors.black12,
                              ),
                            )
                          : null,
                    ),
                    child: Text(
                      value,
                      style: context.labelTiny.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// 압축된 납음오행 행
class CompactNapeumRow extends StatelessWidget {
  final Map<String, dynamic> sajuData;

  const CompactNapeumRow({
    super.key,
    required this.sajuData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final napeumData = _getNapeumData();

    return _buildInfoRow(
      context: context,
      label: '납음',
      hanja: '納音五行',
      values: napeumData,
      isDark: isDark,
    );
  }

  List<String> _getNapeumData() {
    // 납음오행 계산 (60갑자 배당 오행)
    final result = <String>[];

    for (final key in ['hour', 'day', 'month', 'year']) {
      final pillarData = sajuData[key];
      if (pillarData == null) {
        result.add('-');
        continue;
      }

      final stemData = pillarData['cheongan'] as Map<String, dynamic>?;
      final branchData = pillarData['jiji'] as Map<String, dynamic>?;
      final stem = stemData?['char'] as String? ?? '';
      final branch = branchData?['char'] as String? ?? '';

      if (stem.isEmpty || branch.isEmpty) {
        result.add('-');
        continue;
      }

      result.add(_getNapeum(stem, branch));
    }

    return result;
  }

  String _getNapeum(String stem, String branch) {
    // 60갑자 납음오행 테이블
    const napeumTable = {
      '갑자': '해중금', '을축': '해중금',
      '병인': '노중화', '정묘': '노중화',
      '무진': '대림목', '기사': '대림목',
      '경오': '노방토', '신미': '노방토',
      '임신': '검봉금', '계유': '검봉금',
      '갑술': '산두화', '을해': '산두화',
      '병자': '간하수', '정축': '간하수',
      '무인': '성두토', '기묘': '성두토',
      '경진': '백납금', '신사': '백납금',
      '임오': '양류목', '계미': '양류목',
      '갑신': '천중수', '을유': '천중수',
      '병술': '옥상토', '정해': '옥상토',
      '무자': '벽력화', '기축': '벽력화',
      '경인': '송백목', '신묘': '송백목',
      '임진': '장류수', '계사': '장류수',
      '갑오': '사중금', '을미': '사중금',
      '병신': '산하화', '정유': '산하화',
      '무술': '평지목', '기해': '평지목',
      '경자': '벽상토', '신축': '벽상토',
      '임인': '금박금', '계묘': '금박금',
      '갑진': '복등화', '을사': '복등화',
      '병오': '천하수', '정미': '천하수',
      '무신': '대역토', '기유': '대역토',
      '경술': '차천금', '신해': '차천금',
      '임자': '상자목', '계축': '상자목',
      '갑인': '대계수', '을묘': '대계수',
      '병진': '사중토', '정사': '사중토',
      '무오': '천상화', '기미': '천상화',
      '경신': '석류목', '신유': '석류목',
      '임술': '대해수', '계해': '대해수',
    };

    final key = '$stem$branch';
    return napeumTable[key] ?? '-';
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required String label,
    required String hanja,
    required List<String> values,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TossTheme.spacingS,
        vertical: TossTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.15)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(TossTheme.radiusS),
      ),
      child: Row(
        children: [
          // 라벨
          SizedBox(
            width: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.labelTiny.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                Text(
                  hanja,
                  style: context.labelTiny.copyWith(
                    fontSize: 8,
                    color: isDark ? Colors.white38 : Colors.black26,
                  ),
                ),
              ],
            ),
          ),
          // 값들
          Expanded(
            child: Row(
              children: values.asMap().entries.map((entry) {
                final index = entry.key;
                final value = entry.value;
                return Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      border: index < values.length - 1
                          ? Border(
                              right: BorderSide(
                                color: isDark
                                    ? Colors.white12
                                    : Colors.black12,
                              ),
                            )
                          : null,
                    ),
                    child: Text(
                      value,
                      style: context.labelTiny.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// 압축된 공망/천을귀인 행
class CompactSpecialInfoRow extends StatelessWidget {
  final Map<String, dynamic> sajuData;

  const CompactSpecialInfoRow({
    super.key,
    required this.sajuData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TossTheme.spacingS,
        vertical: TossTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.15)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(TossTheme.radiusS),
      ),
      child: Row(
        children: [
          // 공망
          Expanded(
            child: _buildInfoItem(
              context: context,
              label: '공망',
              value: _getGongmangText(),
              isDark: isDark,
            ),
          ),
          Container(
            width: 1,
            height: 20,
            color: isDark ? Colors.white12 : Colors.black12,
          ),
          // 천을귀인
          Expanded(
            child: _buildInfoItem(
              context: context,
              label: '천을귀인',
              value: _getCheonEulGuiinText(),
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  String _getGongmangText() {
    // 공망 계산 (일주 기준)
    final dayData = sajuData['day'];
    if (dayData == null) return '-';

    final stemData = dayData['cheongan'] as Map<String, dynamic>?;
    final branchData = dayData['jiji'] as Map<String, dynamic>?;
    final stem = stemData?['char'] as String? ?? '';
    final branch = branchData?['char'] as String? ?? '';

    if (stem.isEmpty || branch.isEmpty) return '-';

    // 공망 테이블 (일주별)
    const gongmangTable = {
      '갑자': '술해', '을축': '술해', '병인': '술해', '정묘': '술해', '무진': '술해', '기사': '술해',
      '갑오': '진사', '을미': '진사', '병신': '진사', '정유': '진사', '무술': '진사', '기해': '진사',
      '갑인': '자축', '을묘': '자축', '병진': '자축', '정사': '자축', '무오': '자축', '기미': '자축',
      '갑신': '오미', '을유': '오미', '병술': '오미', '정해': '오미', '무자': '오미', '기축': '오미',
      '갑진': '인묘', '을사': '인묘', '병오': '인묘', '정미': '인묘', '무신': '인묘', '기유': '인묘',
      '갑술': '신유', '을해': '신유', '병자': '신유', '정축': '신유', '무인': '신유', '기묘': '신유',
      '경자': '신유', '신축': '신유', '임인': '신유', '계묘': '신유', '경오': '진사', '신미': '진사',
      '임신': '진사', '계유': '진사', '경인': '자축', '신묘': '자축', '임진': '자축', '계사': '자축',
      '경신': '오미', '신유': '오미', '임술': '오미', '계해': '오미', '경진': '인묘', '신사': '인묘',
      '임오': '인묘', '계미': '인묘', '경술': '술해', '신해': '술해', '임자': '술해', '계축': '술해',
    };

    final key = '$stem$branch';
    return gongmangTable[key] ?? '-';
  }

  String _getCheonEulGuiinText() {
    // 천을귀인 계산 (일간 기준)
    final dayData = sajuData['day'];
    if (dayData == null) return '-';

    final stemData = dayData['cheongan'] as Map<String, dynamic>?;
    final stem = stemData?['char'] as String? ?? '';

    if (stem.isEmpty) return '-';

    // 천을귀인 테이블 (일간별)
    const guiinTable = {
      '갑': '축미', '을': '자신',
      '병': '해유', '정': '해유',
      '무': '축미', '기': '자신',
      '경': '축미', '신': '인오',
      '임': '묘사', '계': '묘사',
    };

    return guiinTable[stem] ?? '-';
  }

  Widget _buildInfoItem({
    required BuildContext context,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TossTheme.spacingXS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: context.labelTiny.copyWith(
              color: isDark ? Colors.white60 : Colors.black45,
            ),
          ),
          Text(
            value,
            style: context.labelTiny.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
