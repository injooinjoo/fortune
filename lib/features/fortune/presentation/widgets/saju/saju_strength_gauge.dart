import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../domain/models/saju/strength_calculator.dart';

/// 신강/신약(身强/身弱) 게이지 위젯
///
/// 일간의 강약을 수평 게이지로 시각화합니다.
/// - 0~20: 극약(極弱) - 보라
/// - 21~40: 약(弱) - 파랑
/// - 41~60: 중화(中和) - 초록
/// - 61~80: 강(强) - 주황
/// - 81~100: 극강(極强) - 빨강
class SajuStrengthGauge extends StatelessWidget {
  final Map<String, dynamic> sajuData;

  const SajuStrengthGauge({
    super.key,
    required this.sajuData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final result = StrengthCalculator.calculateFromSajuData(sajuData);

    if (result == null) {
      return _buildEmptyState(context);
    }

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
          // 헤더
          _buildHeader(context, result, isDark),
          const SizedBox(height: DSSpacing.md),

          // 메인 게이지
          _buildGauge(context, result, isDark),
          const SizedBox(height: DSSpacing.md),

          // 3요소 분석
          _buildFactors(context, result, isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    StrengthResult result,
    bool isDark,
  ) {
    return Row(
      children: [
        // 일간 한자 표시
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: result.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(DSRadius.sm),
            border: Border.all(
              color: result.color.withValues(alpha: 0.4),
            ),
          ),
          child: Center(
            child: Text(
              _getDayHanja(),
              style: context.heading3.copyWith(
                color: result.color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: DSSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${result.label} (${result.labelHanja})',
                style: context.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: result.color,
                ),
              ),
              Text(
                '${result.dayElement}(${_getElementHanja(result.dayElement)}) · ${result.dayYinYang}',
                style: context.labelSmall.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // 점수
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.sm,
            vertical: DSSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: result.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(DSRadius.full),
          ),
          child: Text(
            '${result.score}점',
            style: context.labelMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: result.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGauge(
    BuildContext context,
    StrengthResult result,
    bool isDark,
  ) {
    return Column(
      children: [
        // 라벨 행
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '극약',
              style: context.labelTiny.copyWith(
                color: const Color(0xFF7E57C2),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '약',
              style: context.labelTiny.copyWith(
                color: const Color(0xFF42A5F5),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '중화',
              style: context.labelTiny.copyWith(
                color: const Color(0xFF66BB6A),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '강',
              style: context.labelTiny.copyWith(
                color: const Color(0xFFFF7043),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '극강',
              style: context.labelTiny.copyWith(
                color: const Color(0xFFE53935),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // 게이지 바
        SizedBox(
          height: 28,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final position = (result.score / 100) * width;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // 배경 그라디언트 바
                  Container(
                    height: 12,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF7E57C2), // 극약 - 보라
                          Color(0xFF42A5F5), // 약 - 파랑
                          Color(0xFF66BB6A), // 중화 - 초록
                          Color(0xFFFF7043), // 강 - 주황
                          Color(0xFFE53935), // 극강 - 빨강
                        ],
                      ),
                    ),
                  ),

                  // 현재 위치 인디케이터
                  Positioned(
                    left: position.clamp(6, width - 6) - 6,
                    top: 2,
                    child: Container(
                      width: 12,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: result.color,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: result.color.withValues(alpha: 0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 4),

        // 숫자 행
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0',
              style: context.labelTiny.copyWith(
                color: context.colors.textTertiary,
                fontSize: 9,
              ),
            ),
            Text(
              '20',
              style: context.labelTiny.copyWith(
                color: context.colors.textTertiary,
                fontSize: 9,
              ),
            ),
            Text(
              '50',
              style: context.labelTiny.copyWith(
                color: context.colors.textTertiary,
                fontSize: 9,
              ),
            ),
            Text(
              '80',
              style: context.labelTiny.copyWith(
                color: context.colors.textTertiary,
                fontSize: 9,
              ),
            ),
            Text(
              '100',
              style: context.labelTiny.copyWith(
                color: context.colors.textTertiary,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFactors(
    BuildContext context,
    StrengthResult result,
    bool isDark,
  ) {
    return Row(
      children: [
        _buildFactorChip(
          context,
          label: '득령',
          hanja: '得令',
          value: result.deukryeong,
          max: 40,
          isDark: isDark,
        ),
        const SizedBox(width: DSSpacing.xs),
        _buildFactorChip(
          context,
          label: '득지',
          hanja: '得地',
          value: result.deukji,
          max: 30,
          isDark: isDark,
        ),
        const SizedBox(width: DSSpacing.xs),
        _buildFactorChip(
          context,
          label: '득세',
          hanja: '得勢',
          value: result.deukse,
          max: 30,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildFactorChip(
    BuildContext context, {
    required String label,
    required String hanja,
    required int value,
    required int max,
    required bool isDark,
  }) {
    final ratio = value / max;
    final color = ratio >= 0.7
        ? const Color(0xFF66BB6A)
        : ratio >= 0.4
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: DSSpacing.xs,
          horizontal: DSSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DSRadius.sm),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Text(
              '$label($hanja)',
              style: context.labelTiny.copyWith(
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$value/$max',
              style: context.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color:
            context.colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: context.isDark ? DSColors.border : DSColors.borderDark,
        ),
      ),
      child: Center(
        child: Text(
          '신강/신약 분석을 위한 데이터가 부족합니다.',
          style: context.bodySmall.copyWith(
            color: context.colors.textTertiary,
          ),
        ),
      ),
    );
  }

  String _getDayHanja() {
    final myungsik = sajuData['myungsik'] as Map<String, dynamic>?;
    if (myungsik != null) {
      return _stemToHanja(myungsik['daySky'] as String? ?? '');
    }
    final dayData = sajuData['day'] as Map<String, dynamic>?;
    final cheongan = dayData?['cheongan'] as Map<String, dynamic>?;
    return cheongan?['hanja'] as String? ?? '';
  }

  String _stemToHanja(String stem) {
    const map = {
      '갑': '甲',
      '을': '乙',
      '병': '丙',
      '정': '丁',
      '무': '戊',
      '기': '己',
      '경': '庚',
      '신': '辛',
      '임': '壬',
      '계': '癸',
    };
    return map[stem] ?? stem;
  }

  String _getElementHanja(String element) {
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
