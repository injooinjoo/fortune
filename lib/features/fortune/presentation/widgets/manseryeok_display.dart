import 'package:flutter/material.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../core/theme/typography_unified.dart';

/// 토스 스타일의 만세력 사주 표시 위젯
class ManseryeokDisplay extends StatelessWidget {
  final Map<String, dynamic> sajuData;

  const ManseryeokDisplay({
    super.key,
    required this.sajuData,
  });

  @override
  Widget build(BuildContext context) {
    return TossCard(
      padding: const EdgeInsets.all(TossTheme.spacingL),
      child: Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Column(
            children: [
              // 제목
              _buildTitle(isDark),
              const SizedBox(height: TossTheme.spacingL),

              // 만세력 표
              _buildManseryeokTable(isDark),
              const SizedBox(height: TossTheme.spacingM),

              // 하단 설명
              _buildDescription(isDark),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTitle(bool isDark) {
    return Column(
      children: [
        // 한문 제목
        Text(
          '사주 명식',
          style: TossTheme.heading2.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
          ),
        ),
        SizedBox(height: TossTheme.spacingXS),
        // 한글 부제
        Text(
          '당신의 타고난 사주팔자입니다',
          style: TossTheme.caption.copyWith(
            color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildManseryeokTable(bool isDark) {
    final year = sajuData['year'];
    final month = sajuData['month'];
    final day = sajuData['day'];
    final hour = sajuData['hour'];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.surfaceBackgroundDark : TossDesignSystem.surfaceBackgroundLight,
        borderRadius: BorderRadius.circular(TossTheme.radiusM),
        border: Border.all(
          color: isDark ? TossDesignSystem.borderDark : TossDesignSystem.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 상단 라벨
          Container(
            padding: const EdgeInsets.symmetric(vertical: TossTheme.spacingM),
            decoration: BoxDecoration(
              color: isDark
                  ? TossDesignSystem.cardBackgroundDark.withValues(alpha: 0.5)
                  : TossDesignSystem.surfaceBackgroundLight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(TossTheme.radiusM),
                topRight: Radius.circular(TossTheme.radiusM),
              ),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? TossDesignSystem.borderDark : TossDesignSystem.borderLight,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                _buildColumnHeader('時柱', '시주', isDark: isDark),
                _buildVerticalDivider(isDark),
                _buildColumnHeader('日柱', '일주', isHighlight: true, isDark: isDark),
                _buildVerticalDivider(isDark),
                _buildColumnHeader('月柱', '월주', isDark: isDark),
                _buildVerticalDivider(isDark),
                _buildColumnHeader('年柱', '년주', isDark: isDark),
              ],
            ),
          ),

          // 천간 행
          Container(
            padding: const EdgeInsets.symmetric(vertical: TossTheme.spacingL),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: (isDark ? TossDesignSystem.borderDark : TossDesignSystem.borderLight).withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                _buildPillarCell(hour, '천간', isHour: true, isDark: isDark),
                _buildVerticalDivider(isDark),
                _buildPillarCell(day, '천간', isDay: true, isDark: isDark),
                _buildVerticalDivider(isDark),
                _buildPillarCell(month, '천간', isDark: isDark),
                _buildVerticalDivider(isDark),
                _buildPillarCell(year, '천간', isDark: isDark),
              ],
            ),
          ),

          // 지지 행
          Container(
            padding: const EdgeInsets.symmetric(vertical: TossTheme.spacingL),
            child: Row(
              children: [
                _buildPillarCell(hour, '지지', isHour: true, isDark: isDark),
                _buildVerticalDivider(isDark),
                _buildPillarCell(day, '지지', isDay: true, isDark: isDark),
                _buildVerticalDivider(isDark),
                _buildPillarCell(month, '지지', isDark: isDark),
                _buildVerticalDivider(isDark),
                _buildPillarCell(year, '지지', isDark: isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnHeader(String hanja, String korean, {bool isHighlight = false, required bool isDark}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            hanja,
            style: TossTheme.body1.copyWith(
              fontSize: isHighlight ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: isHighlight
                  ? TossTheme.brandBlue
                  : (isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight),
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 4),
          Text(
            korean,
            style: TossTheme.caption.copyWith(
              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillarCell(Map<String, dynamic>? pillar, String type, {bool isDay = false, bool isHour = false, required bool isDark}) {
    if (pillar == null && !isHour) {
      return Expanded(
        child: Center(
          child: Text(
            '-',
            style: TextStyle(
              color: isDark ? TossDesignSystem.textTertiaryDark : TossDesignSystem.textTertiaryLight,
            ),
          ),
        ),
      );
    }

    String hanja = '';
    String korean = '';
    String element = '';

    if (pillar != null) {
      if (type == '천간') {
        hanja = pillar['cheongan']?['hanja'] ?? '';
        korean = pillar['cheongan']?['char'] ?? '';
        element = pillar['cheongan']?['element'] ?? '';
      } else {
        hanja = pillar['jiji']?['hanja'] ?? '';
        korean = pillar['jiji']?['char'] ?? '';
        element = pillar['jiji']?['element'] ?? '';

        // 지지의 경우 띠 동물도 표시
        if (type == '지지') {
          final animal = pillar['jiji']?['animal'] ?? '';
          if (animal.isNotEmpty) {
            korean = '$korean($animal)';
          }
        }
      }
    } else if (isHour) {
      // 시주가 없는 경우
      hanja = '未定';
      korean = '미정';
    }

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 큰 한자
          Text(
            hanja,
            style: TossTheme.heading3.copyWith(
              fontSize: isDay ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: isDay
                  ? TossTheme.brandBlue
                  : (isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight),
              height: 1,
            ),
          ),
          SizedBox(height: 4),
          // 한글
          Text(
            korean,
            style: TossTheme.caption.copyWith(
              fontSize: isDay ? 12 : 11,
              color: isDay
                  ? TossTheme.brandBlue.withValues(alpha: 0.8)
                  : (isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight),
              fontWeight: isDay ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (element.isNotEmpty) ...[
            const SizedBox(height: 4),
            // 오행
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getElementColor(element).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getElementColor(element).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '$element행',
                style: TypographyUnified.labelTiny.copyWith(
                  color: _getElementColor(element),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      width: 1,
      height: 60,
      color: (isDark ? TossDesignSystem.borderDark : TossDesignSystem.borderLight).withValues(alpha: 0.3),
    );
  }

  Widget _buildDescription(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(TossTheme.spacingM),
      decoration: BoxDecoration(
        color: isDark
            ? TossDesignSystem.cardBackgroundDark.withValues(alpha: 0.3)
            : TossDesignSystem.surfaceBackgroundLight,
        borderRadius: BorderRadius.circular(TossTheme.radiusM),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
            size: 16,
          ),
          SizedBox(width: TossTheme.spacingXS),
          Text(
            '위 사주는 만세력 기준으로 계산되었습니다',
            style: TossTheme.caption.copyWith(
              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Color _getElementColor(String element) {
    switch (element) {
      case '목':
        return TossTheme.success;
      case '화':
        return TossTheme.error;
      case '토':
        return TossTheme.warning;
      case '금':
        return TossTheme.textGray600;
      case '수':
        return TossTheme.brandBlue;
      default:
        return TossTheme.textGray500;
    }
  }
}