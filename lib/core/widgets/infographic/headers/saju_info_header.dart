import 'package:flutter/material.dart';
import '../../../design_system/design_system.dart';
import '../../../theme/typography_unified.dart';

/// 사주 결과 인포그래픽 헤더
///
/// 사주 팔자 표, 오행 밸런스, 보완 조언을 표시
///
/// 사용 예시:
/// ```dart
/// SajuInfoHeader(
///   birthDate: '1990.05.15',
///   birthTime: '10:30',
///   pillars: {'year': {'sky': '庚', 'earth': '午'}, ...},
///   elements: {'목': 28, '화': 35, '토': 22, '금': 10, '수': 5},
/// )
/// ```
class SajuInfoHeader extends StatelessWidget {
  /// 생년월일
  final String? birthDate;

  /// 생시
  final String? birthTime;

  /// 사주 팔자 (4주 8자)
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

          // 사주 팔자 테이블
          if (pillars != null && pillars!.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildPillarsTable(context),
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
            style: context.calligraphyTitle.copyWith(
              color: colors.accent,
              fontSize: 20,
            ),
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

  Widget _buildPillarsTable(BuildContext context) {
    final colors = context.colors;
    final pillarOrder = ['year', 'month', 'day', 'hour'];
    final pillarNames = {'year': '년', 'month': '월', 'day': '일', 'hour': '시'};

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          // 천간 행
          Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  '天干',
                  style: context.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
              ...pillarOrder.map((key) {
                final pillar = pillars![key] as Map<String, dynamic>?;
                final sky = pillar?['sky'] as String? ?? pillar?['천간'] as String? ?? '-';
                return Expanded(
                  child: Center(
                    child: Text(
                      sky,
                      style: context.calligraphySubtitle.copyWith(
                        color: _getElementColor(sky, colors),
                        fontSize: 18,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 8),
          // 지지 행
          Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  '地支',
                  style: context.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
              ...pillarOrder.map((key) {
                final pillar = pillars![key] as Map<String, dynamic>?;
                final earth = pillar?['earth'] as String? ?? pillar?['지지'] as String? ?? '-';
                return Expanded(
                  child: Center(
                    child: Text(
                      earth,
                      style: context.calligraphySubtitle.copyWith(
                        color: _getElementColor(earth, colors),
                        fontSize: 18,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 8),
          // 라벨 행
          Row(
            children: [
              const SizedBox(width: 40),
              ...pillarOrder.map((key) {
                return Expanded(
                  child: Center(
                    child: Text(
                      pillarNames[key] ?? key,
                      style: context.labelSmall.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildElementBalance(BuildContext context) {
    final colors = context.colors;
    final elementColors = {
      '목': const Color(0xFF38A169), // 초록
      '화': const Color(0xFFE53E3E), // 빨강
      '토': const Color(0xFFD69E2E), // 황토
      '금': const Color(0xFFA0AEC0), // 은색
      '수': const Color(0xFF3182CE), // 파랑
    };

    final total = elements!.values.fold<num>(0, (sum, v) => sum + (v as num));

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
        // 수평 스택 바
        Container(
          height: 24,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: elements!.entries.map((e) {
              final ratio = (e.value as num) / total;
              final color = elementColors[e.key] ?? colors.accent;
              return Expanded(
                flex: (ratio * 100).round(),
                child: Container(
                  color: color,
                  child: Center(
                    child: ratio > 0.1
                        ? Text(
                            e.key,
                            style: context.labelSmall.copyWith(
                              color: Colors.white,
                              fontSize: 10,
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
        const SizedBox(height: 8),
        // 강/약 표시
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (strongElement != null) ...[
              Text(
                '↑ 강: $strongElement',
                style: context.labelSmall.copyWith(
                  color: colors.success,
                ),
              ),
              const SizedBox(width: 16),
            ],
            if (weakElement != null)
              Text(
                '↓ 약: $weakElement',
                style: context.labelSmall.copyWith(
                  color: colors.error,
                ),
              ),
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

  Color _getElementColor(String char, DSColorScheme colors) {
    // 천간/지지에서 오행 추출
    const woodChars = ['甲', '乙', '寅', '卯'];
    const fireChars = ['丙', '丁', '巳', '午'];
    const earthChars = ['戊', '己', '辰', '戌', '丑', '未'];
    const metalChars = ['庚', '辛', '申', '酉'];
    const waterChars = ['壬', '癸', '子', '亥'];

    if (woodChars.contains(char)) return const Color(0xFF38A169);
    if (fireChars.contains(char)) return const Color(0xFFE53E3E);
    if (earthChars.contains(char)) return const Color(0xFFD69E2E);
    if (metalChars.contains(char)) return const Color(0xFFA0AEC0);
    if (waterChars.contains(char)) return const Color(0xFF3182CE);

    return colors.textPrimary;
  }
}
