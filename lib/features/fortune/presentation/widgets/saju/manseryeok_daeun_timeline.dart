import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../domain/models/saju/daeun_calculator.dart';

/// 만세력 대운(大運) 타임라인 위젯
///
/// 8-10개 대운 카드를 수직 타임라인으로 배열합니다.
/// 현재 대운은 accent 테두리 + "현재" 배지로 강조됩니다.
class ManseryeokDaeunTimeline extends StatelessWidget {
  final Map<String, dynamic> sajuData;

  const ManseryeokDaeunTimeline({
    super.key,
    required this.sajuData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final daeunList = _extractOrCalculateDaeun();
    final currentIndex = _findCurrentIndex(daeunList);

    if (daeunList.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? context.colors.backgroundSecondary : Colors.white,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: isDark ? DSColors.border : DSColors.borderDark,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타임라인 (수평 스크롤)
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: daeunList.length,
              separatorBuilder: (_, __) => _buildConnector(context),
              itemBuilder: (context, index) {
                return _buildDaeunCard(
                  context: context,
                  daeun: daeunList[index],
                  isCurrent: index == currentIndex,
                  isPast: index < currentIndex,
                  isDark: isDark,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaeunCard({
    required BuildContext context,
    required Map<String, dynamic> daeun,
    required bool isCurrent,
    required bool isPast,
    required bool isDark,
  }) {
    final startAge = daeun['startAge'] as int? ?? 0;
    final endAge = daeun['endAge'] as int? ?? 0;
    final stem = daeun['stem'] as String? ?? '';
    final branch = daeun['branch'] as String? ?? '';
    final stemHanja = daeun['stemHanja'] as String? ?? '';
    final branchHanja = daeun['branchHanja'] as String? ?? '';

    final stemColor = SajuColors.getStemColor(stem, isDark: isDark);
    final branchColor = SajuColors.getBranchColor(branch, isDark: isDark);

    return Container(
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: isCurrent
            ? DSColors.accent.withValues(alpha: 0.12)
            : isPast
                ? (isDark
                    ? context.colors.surface.withValues(alpha: 0.05)
                    : Colors.grey.shade50)
                : (isDark
                    ? context.colors.surface.withValues(alpha: 0.08)
                    : Colors.white),
        borderRadius: BorderRadius.circular(DSRadius.sm),
        border: Border.all(
          color: isCurrent
              ? DSColors.accent
              : (isDark ? DSColors.border : DSColors.borderDark),
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: DSColors.accent.withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 현재 배지
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: DSColors.accent,
                borderRadius: BorderRadius.circular(DSRadius.full),
              ),
              child: Text(
                '현재',
                style: context.labelTiny.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 8,
                ),
              ),
            ),

          // 나이 범위
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isCurrent
                  ? DSColors.accent.withValues(alpha: 0.2)
                  : (isDark
                      ? context.colors.surface.withValues(alpha: 0.15)
                      : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              '$startAge-$endAge세',
              style: context.labelTiny.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isCurrent
                    ? DSColors.accent
                    : (isPast
                        ? context.colors.textTertiary
                        : context.colors.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // 천간
          Text(
            stemHanja.isNotEmpty ? stemHanja : stem,
            style: context.heading3.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: isPast ? stemColor.withValues(alpha: 0.4) : stemColor,
            ),
          ),

          // 지지
          Text(
            branchHanja.isNotEmpty ? branchHanja : branch,
            style: context.heading3.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: isPast ? branchColor.withValues(alpha: 0.4) : branchColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector(BuildContext context) {
    return Center(
      child: Container(
        width: 8,
        height: 2,
        margin: const EdgeInsets.only(top: 20),
        color: context.colors.textTertiary.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color:
            context.isDark ? context.colors.backgroundSecondary : Colors.white,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: context.isDark ? DSColors.border : DSColors.borderDark,
        ),
      ),
      child: Center(
        child: Text(
          '대운 데이터를 계산할 수 없습니다.',
          style: context.bodySmall.copyWith(
            color: context.colors.textTertiary,
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _extractOrCalculateDaeun() {
    // 1) sajuData에서 직접 추출 시도
    final existing = _extractExistingDaeun();
    if (existing.isNotEmpty) return existing;

    // 2) DaeunCalculator로 계산
    return _calculateDaeun();
  }

  List<Map<String, dynamic>> _extractExistingDaeun() {
    final rawDaeun = sajuData['daeun'];
    List<dynamic>? daeunData;

    if (rawDaeun is List) {
      daeunData = rawDaeun;
    } else if (rawDaeun is Map) {
      if (rawDaeun.containsKey('items') && rawDaeun['items'] is List) {
        daeunData = rawDaeun['items'] as List;
      } else if (rawDaeun.containsKey('list') && rawDaeun['list'] is List) {
        daeunData = rawDaeun['list'] as List;
      }
    }

    if (daeunData == null || daeunData.isEmpty) return [];

    final List<Map<String, dynamic>> result = [];
    for (final item in daeunData) {
      if (item is Map<String, dynamic>) {
        result.add({
          'startAge': item['startAge'] ?? item['start_age'] ?? 0,
          'endAge': item['endAge'] ?? item['end_age'] ?? 0,
          'stem': item['stem'] ?? item['cheongan'] ?? '',
          'branch': item['branch'] ?? item['jiji'] ?? '',
          'stemHanja': item['stemHanja'] ?? item['cheongan_hanja'] ?? '',
          'branchHanja': item['branchHanja'] ?? item['jiji_hanja'] ?? '',
        });
      }
    }
    return result;
  }

  List<Map<String, dynamic>> _calculateDaeun() {
    final myungsik = sajuData['myungsik'] as Map<String, dynamic>?;
    if (myungsik == null) return [];

    final monthStem = myungsik['monthSky'] as String?;
    final monthBranch = myungsik['monthEarth'] as String?;
    final yearStem = myungsik['yearSky'] as String?;
    if (monthStem == null || monthBranch == null || yearStem == null) return [];

    final gender = sajuData['gender'] as String? ?? '남';
    final birthYear = sajuData['birthYear'] as int?;
    final birthMonth = sajuData['birthMonth'] as int?;
    final birthDay = sajuData['birthDay'] as int?;

    DateTime? birthDate;
    if (birthYear != null && birthMonth != null && birthDay != null) {
      birthDate = DateTime(birthYear, birthMonth, birthDay);
    }

    if (birthDate == null) return [];

    final isMale = gender == '남';
    final daeunInfoList = DaeunCalculator.calculateDaeun(
      monthStem: monthStem,
      monthBranch: monthBranch,
      yearStem: yearStem,
      isMale: isMale,
      birthDate: birthDate,
    );

    return daeunInfoList.map((d) => d.toMap()).toList();
  }

  int _findCurrentIndex(List<Map<String, dynamic>> daeunList) {
    final birthYear = sajuData['birthYear'] as int?;
    if (birthYear == null) return 0;

    final currentYear = DateTime.now().year;
    final age = currentYear - birthYear + 1;

    for (int i = 0; i < daeunList.length; i++) {
      final startAge = daeunList[i]['startAge'] as int? ?? 0;
      final endAge = daeunList[i]['endAge'] as int? ?? 0;
      if (age >= startAge && age <= endAge) return i;
    }
    return 0;
  }
}
