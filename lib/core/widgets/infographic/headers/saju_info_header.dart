import 'package:flutter/material.dart';
import '../../../design_system/design_system.dart';

/// 사주 결과 인포그래픽 헤더 (프리미엄 비주얼)
///
/// 사주 팔자를 개별 컬러 카드로 표시, 오행 밸런스, 보완 조언을 표시
///
/// pillars 데이터 형식:
/// ```dart
/// {
///   'year': { 'sky': '甲', 'skyElement': '목', 'earth': '子', 'earthElement': '수', 'animal': '쥐' },
///   'month': { ... },
///   'day': { ... },
///   'hour': { ... },
/// }
/// ```
class SajuInfoHeader extends StatelessWidget {
  /// 생년월일
  final String? birthDate;

  /// 생시
  final String? birthTime;

  /// 사주 팔자 (4주 8자) - sky/earth + element info
  final Map<String, dynamic>? pillars;

  /// 오행 분포
  final Map<String, dynamic>? elements;

  /// 강한 오행
  final String? strongElement;

  /// 약한 오행
  final String? weakElement;

  /// 보완 조언
  final String? advice;

  const SajuInfoHeader({
    super.key,
    this.birthDate,
    this.birthTime,
    this.pillars,
    this.elements,
    this.strongElement,
    this.weakElement,
    this.advice,
  });

  /// API 응답 데이터에서 생성
  factory SajuInfoHeader.fromData(Map<String, dynamic> data) {
    return SajuInfoHeader(
      birthDate: data['birthDate'] as String?,
      birthTime: data['birthTime'] as String?,
      pillars: data['pillars'] as Map<String, dynamic>? ??
          data['sajuPillars'] as Map<String, dynamic>?,
      elements: data['elements'] as Map<String, dynamic>? ??
          data['fiveElements'] as Map<String, dynamic>?,
      strongElement: data['strongElement'] as String?,
      weakElement: data['weakElement'] as String?,
      advice: data['balanceAdvice'] as String? ?? data['advice'] as String?,
    );
  }

  // 오행 → 한자 매핑
  static const _wuxingKanji = {
    '목': '木',
    '화': '火',
    '토': '土',
    '금': '金',
    '수': '水',
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(DSRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 + 생년월일
          _buildTitle(context),

          // 사주 팔자 개별 카드
          if (pillars != null && pillars!.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildPillarCards(context),
          ],

          // 오행 밸런스 바
          if (elements != null && elements!.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildElementBalance(context),
          ],

          // 보완 조언
          if (advice != null && advice!.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildAdvice(context),
          ],
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final colors = context.colors;
    final dateTimeStr = [
      if (birthDate != null) birthDate,
      if (birthTime != null) birthTime,
    ].join(' ');

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '四柱',
            style: context.heading3.copyWith(color: colors.accent),
          ),
        ),
        const SizedBox(width: DSSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '사주 분석',
              style: context.heading4.copyWith(
                color: colors.textPrimary,
              ),
            ),
            if (dateTimeStr.isNotEmpty)
              Text(
                dateTimeStr,
                style: context.labelMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// 4개 필러를 개별 컬러 카드로 표시
  Widget _buildPillarCards(BuildContext context) {
    final isDark = context.isDark;
    final pillarOrder = ['hour', 'day', 'month', 'year'];
    final pillarLabels = {
      'year': '년주',
      'month': '월주',
      'day': '일주',
      'hour': '시주'
    };

    return Row(
      children: pillarOrder.asMap().entries.map((entry) {
        final index = entry.key;
        final key = entry.value;
        final pillar = pillars![key] as Map<String, dynamic>?;
        final isDay = key == 'day';

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 3,
              right: index == 3 ? 0 : 3,
            ),
            child: pillar != null
                ? _buildPillarCard(
                    context,
                    sky: pillar['sky'] as String? ?? '-',
                    earth: pillar['earth'] as String? ?? '-',
                    skyElement: pillar['skyElement'] as String? ?? '',
                    earthElement: pillar['earthElement'] as String? ?? '',
                    animal: pillar['animal'] as String?,
                    label: pillarLabels[key] ?? key,
                    isDay: isDay,
                    isDark: isDark,
                  )
                : _buildEmptyPillarCard(
                    context,
                    label: pillarLabels[key] ?? key,
                    isDark: isDark,
                  ),
          ),
        );
      }).toList(),
    );
  }

  /// 개별 필러 카드 위젯
  Widget _buildPillarCard(
    BuildContext context, {
    required String sky,
    required String earth,
    required String skyElement,
    required String earthElement,
    String? animal,
    required String label,
    required bool isDay,
    required bool isDark,
  }) {
    final colors = context.colors;
    final skyColor = SajuColors.getWuxingColor(skyElement, isDark: isDark);
    final earthColor = SajuColors.getWuxingColor(earthElement, isDark: isDark);
    final skyBg =
        SajuColors.getWuxingBackgroundColor(skyElement, isDark: isDark);
    final earthBg =
        SajuColors.getWuxingBackgroundColor(earthElement, isDark: isDark);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: isDay
            ? Border.all(color: colors.accent, width: 2)
            : Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06)),
        boxShadow: isDay
            ? [
                BoxShadow(
                  color: colors.accent.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // 천간 영역
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: skyBg,
            ),
            child: Column(
              children: [
                Text(
                  sky,
                  style: context.heading2.copyWith(
                    color: skyColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: skyColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    skyElement.isNotEmpty
                        ? '${_wuxingKanji[skyElement] ?? skyElement} $skyElement'
                        : '',
                    style: context.labelTiny.copyWith(
                      color: skyColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 미세한 구분선
          Container(
            height: 0.5,
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
          ),
          // 지지 영역
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: earthBg,
            ),
            child: Column(
              children: [
                Text(
                  earth,
                  style: context.heading2.copyWith(
                    color: earthColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (animal != null && animal.isNotEmpty)
                  Text(
                    animal,
                    style: context.labelTiny.copyWith(
                      color: earthColor.withValues(alpha: 0.7),
                    ),
                  ),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: earthColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    earthElement.isNotEmpty
                        ? '${_wuxingKanji[earthElement] ?? earthElement} $earthElement'
                        : '',
                    style: context.labelTiny.copyWith(
                      color: earthColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 라벨
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 5),
            color: isDay
                ? colors.accent.withValues(alpha: 0.08)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.black.withValues(alpha: 0.02)),
            child: Center(
              child: Text(
                label,
                style: context.labelSmall.copyWith(
                  color: isDay ? colors.accent : colors.textTertiary,
                  fontWeight: isDay ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 시주 데이터 없을 때 placeholder
  Widget _buildEmptyPillarCard(
    BuildContext context, {
    required String label,
    required bool isDark,
  }) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
          style: BorderStyle.solid,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // 천간 placeholder
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: isDark
                ? Colors.white.withValues(alpha: 0.02)
                : Colors.black.withValues(alpha: 0.02),
            child: Center(
              child: Text(
                '?',
                style: context.heading2.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ),
          ),
          Container(
            height: 0.5,
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
          ),
          // 지지 placeholder
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: isDark
                ? Colors.white.withValues(alpha: 0.02)
                : Colors.black.withValues(alpha: 0.02),
            child: Center(
              child: Text(
                '?',
                style: context.heading2.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ),
          ),
          // 라벨
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 5),
            color: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.black.withValues(alpha: 0.02),
            child: Center(
              child: Text(
                label,
                style: context.labelSmall.copyWith(
                  color: colors.textTertiary,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElementBalance(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;
    final total = elements!.values.fold<num>(0, (sum, v) => sum + (v as num));
    if (total <= 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('☯️', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              '오행 밸런스',
              style: context.labelMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.sm),
        // 수평 스택 바 (높이 증가 + 한자 표시)
        Container(
          height: 32,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: elements!.entries.map((e) {
              final ratio = (e.value as num) / total;
              final color = SajuColors.getWuxingColor(e.key, isDark: isDark);
              final kanji = _wuxingKanji[e.key] ?? e.key;
              return Expanded(
                flex: (ratio * 100).round().clamp(1, 100),
                child: Container(
                  color: color,
                  child: Center(
                    child: ratio > 0.08
                        ? Text(
                            kanji,
                            style: context.labelSmall.copyWith(
                              color: Colors.white,
                              fontSize: ratio > 0.15 ? 13 : 10,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),
        // 강/약 표시 (오행 색 도트 추가)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (strongElement != null) ...[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color:
                      SajuColors.getWuxingColor(strongElement!, isDark: isDark),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '강: $strongElement',
                style: context.labelSmall.copyWith(
                  color:
                      SajuColors.getWuxingColor(strongElement!, isDark: isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
            ],
            if (weakElement != null) ...[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color:
                      SajuColors.getWuxingColor(weakElement!, isDark: isDark),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '약: $weakElement',
                style: context.labelSmall.copyWith(
                  color:
                      SajuColors.getWuxingColor(weakElement!, isDark: isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildAdvice(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: colors.infoBackground,
        borderRadius: BorderRadius.circular(DSRadius.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              advice!,
              style: context.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
