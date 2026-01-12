import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/tokens/ds_spacing.dart';
import 'package:fortune/core/design_system/tokens/ds_radius.dart';
import 'package:fortune/core/design_system/theme/ds_extensions.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/infographic_container.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/lucky_item_row.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/privacy_shield.dart';

/// 그리드/리스트 중심 인포그래픽 템플릿 (템플릿 D)
///
/// 3개 운세 타입에 사용:
/// - lucky_items (행운 아이템)
/// - lucky-lottery (로또 번호)
/// - naming (AI 작명)
///
/// 레이아웃:
/// - 상단: 제목
/// - 중간: 그리드/리스트 아이템
/// - 하단: 부가 정보 (선택)
class GridTemplate extends StatelessWidget {
  const GridTemplate({
    super.key,
    required this.title,
    required this.gridWidget,
    this.subtitle,
    this.headerWidget,
    this.footerWidget,
    this.showWatermark = true,
    this.isShareMode = false,
    this.backgroundColor,
  });

  /// 제목
  final String title;

  /// 부제목 (선택)
  final String? subtitle;

  /// 헤더 위젯 (선택)
  final Widget? headerWidget;

  /// 그리드 위젯 (필수)
  final Widget gridWidget;

  /// 푸터 위젯 (선택)
  final Widget? footerWidget;

  /// 워터마크 표시 여부
  final bool showWatermark;

  /// 공유 모드
  final bool isShareMode;

  /// 배경색 (선택)
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return PrivacyModeProvider(
      isShareMode: isShareMode,
      child: InfographicContainer(
        title: title,
        subtitle: subtitle,
        showWatermark: showWatermark,
        isShareMode: isShareMode,
        backgroundColor: backgroundColor,
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 헤더 위젯
        if (headerWidget != null) ...[
          headerWidget!,
          const SizedBox(height: DSSpacing.md),
        ],

        // 메인 그리드
        gridWidget,

        // 푸터 위젯
        if (footerWidget != null) ...[
          const SizedBox(height: DSSpacing.md),
          footerWidget!,
        ],
      ],
    );
  }
}

/// 행운 아이템 그리드 템플릿
class LuckyItemsGridTemplate extends StatelessWidget {
  const LuckyItemsGridTemplate({
    super.key,
    required this.items,
    this.luckyTime,
    this.luckyDirection,
    this.date,
    this.isShareMode = false,
  });

  /// 행운 아이템 목록
  final List<LuckyItem> items;

  /// 행운 시간 (선택)
  final String? luckyTime;

  /// 행운 방향 (선택)
  final String? luckyDirection;

  /// 날짜
  final DateTime? date;

  /// 공유 모드
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return GridTemplate(
      title: '오늘의 행운 아이템',
      isShareMode: isShareMode,
      gridWidget: LuckyItemGrid(
        items: items,
        columns: 2,
        spacing: DSSpacing.sm,
      ),
      footerWidget: _buildFooter(context),
    );
  }

  Widget _buildFooter(BuildContext context) {
    if (luckyTime == null && luckyDirection == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withOpacity(0.5),
        borderRadius: DSRadius.mdBorder,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (luckyTime != null) ...[
            Icon(
              Icons.access_time_rounded,
              size: 16,
              color: context.colors.accent,
            ),
            const SizedBox(width: DSSpacing.xs),
            Text(
              '행운 시간: $luckyTime',
              style: context.typography.labelMedium.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
          if (luckyTime != null && luckyDirection != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
              child: Text(
                '·',
                style: TextStyle(color: context.colors.textTertiary),
              ),
            ),
          if (luckyDirection != null) ...[
            Icon(
              Icons.explore_rounded,
              size: 16,
              color: context.colors.accent,
            ),
            const SizedBox(width: DSSpacing.xs),
            Text(
              '행운 방향: $luckyDirection',
              style: context.typography.labelMedium.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 로또 번호 템플릿
class LotteryGridTemplate extends StatelessWidget {
  const LotteryGridTemplate({
    super.key,
    required this.numbers,
    this.bonusNumber,
    this.message,
    this.date,
    this.isShareMode = false,
  });

  /// 6개 번호
  final List<int> numbers;

  /// 보너스 번호 (선택)
  final int? bonusNumber;

  /// 메시지 (선택)
  final String? message;

  /// 날짜
  final DateTime? date;

  /// 공유 모드
  final bool isShareMode;

  Color _getBallColor(int number) {
    if (number <= 10) return const Color(0xFFFFB300); // 노랑
    if (number <= 20) return const Color(0xFF2196F3); // 파랑
    if (number <= 30) return const Color(0xFFE53935); // 빨강
    if (number <= 40) return const Color(0xFF9E9E9E); // 회색
    return const Color(0xFF4CAF50); // 초록
  }

  @override
  Widget build(BuildContext context) {
    return GridTemplate(
      title: '행운의 로또 번호',
      isShareMode: isShareMode,
      gridWidget: _buildNumberBalls(context),
      footerWidget: message != null ? _buildMessage(context) : null,
    );
  }

  Widget _buildNumberBalls(BuildContext context) {
    final sortedNumbers = List<int>.from(numbers)..sort();

    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withOpacity(0.5),
        borderRadius: DSRadius.lgBorder,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 메인 6개 번호
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: sortedNumbers.map((number) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xs),
                child: _LottoBall(
                  number: number,
                  color: _getBallColor(number),
                ),
              );
            }).toList(),
          ),

          // 보너스 번호
          if (bonusNumber != null) ...[
            const SizedBox(height: DSSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '+',
                  style: context.typography.headingMedium.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
                const SizedBox(width: DSSpacing.sm),
                _LottoBall(
                  number: bonusNumber!,
                  color: _getBallColor(bonusNumber!),
                  isBonus: true,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.accent.withOpacity(0.1),
        borderRadius: DSRadius.mdBorder,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 16,
            color: context.colors.accent,
          ),
          const SizedBox(width: DSSpacing.xs),
          Text(
            message!,
            style: context.typography.bodySmall.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LottoBall extends StatelessWidget {
  const _LottoBall({
    required this.number,
    required this.color,
    this.isBonus = false,
  });

  final int number;
  final Color color;
  final bool isBonus;

  @override
  Widget build(BuildContext context) {
    final size = isBonus ? 40.0 : 44.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.8),
            color,
          ],
          center: const Alignment(-0.3, -0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: isBonus
            ? Border.all(
                color: context.colors.accent,
                width: 2,
              )
            : null,
      ),
      child: Center(
        child: Text(
          '$number',
          style: context.typography.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: isBonus ? 14 : 16,
          ),
        ),
      ),
    );
  }
}

/// AI 작명 템플릿
class NamingGridTemplate extends StatelessWidget {
  const NamingGridTemplate({
    super.key,
    required this.names,
    this.criteria,
    this.date,
    this.isShareMode = false,
  });

  /// 이름 목록
  final List<NameSuggestion> names;

  /// 작명 기준 (선택)
  final String? criteria;

  /// 날짜
  final DateTime? date;

  /// 공유 모드
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return GridTemplate(
      title: 'AI 추천 이름',
      isShareMode: isShareMode,
      headerWidget: criteria != null ? _buildCriteria(context) : null,
      gridWidget: _buildNameCards(context),
    );
  }

  Widget _buildCriteria(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withOpacity(0.5),
        borderRadius: DSRadius.smBorder,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_fix_high_rounded,
            size: 16,
            color: context.colors.accent,
          ),
          const SizedBox(width: DSSpacing.xs),
          Text(
            criteria!,
            style: context.typography.labelSmall.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameCards(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: names.asMap().entries.map((entry) {
        final index = entry.key;
        final name = entry.value;
        final isFirst = index == 0;

        return Padding(
          padding: EdgeInsets.only(
            bottom: index < names.length - 1 ? DSSpacing.sm : 0,
          ),
          child: _NameCard(
            name: name,
            rank: index + 1,
            isHighlighted: isFirst,
          ),
        );
      }).toList(),
    );
  }
}

class NameSuggestion {
  const NameSuggestion({
    required this.name,
    required this.meaning,
    this.hanja,
    this.score,
  });

  /// 이름
  final String name;

  /// 의미
  final String meaning;

  /// 한자 (선택)
  final String? hanja;

  /// 점수 (선택)
  final int? score;
}

class _NameCard extends StatelessWidget {
  const _NameCard({
    required this.name,
    required this.rank,
    this.isHighlighted = false,
  });

  final NameSuggestion name;
  final int rank;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: isHighlighted
            ? context.colors.accent.withOpacity(0.1)
            : context.colors.surfaceSecondary.withOpacity(0.5),
        borderRadius: DSRadius.mdBorder,
        border: isHighlighted
            ? Border.all(
                color: context.colors.accent.withOpacity(0.3),
                width: 2,
              )
            : null,
      ),
      child: Row(
        children: [
          // 순위
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isHighlighted
                  ? context.colors.accent
                  : context.colors.textTertiary.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: context.typography.labelMedium.copyWith(
                  color: isHighlighted
                      ? Colors.white
                      : context.colors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: DSSpacing.md),

          // 이름 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      name.name,
                      style: context.typography.headingSmall.copyWith(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (name.hanja != null) ...[
                      const SizedBox(width: DSSpacing.xs),
                      Text(
                        '(${name.hanja})',
                        style: context.typography.bodySmall.copyWith(
                          color: context.colors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: DSSpacing.xxs),
                Text(
                  name.meaning,
                  style: context.typography.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 점수
          if (name.score != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.sm,
                vertical: DSSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? context.colors.accent
                    : context.colors.surfaceSecondary,
                borderRadius: DSRadius.smBorder,
              ),
              child: Text(
                '${name.score}',
                style: context.typography.labelSmall.copyWith(
                  color: isHighlighted
                      ? Colors.white
                      : context.colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 커스텀 그리드 아이템 위젯
class GridItem extends StatelessWidget {
  const GridItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: backgroundColor ?? context.colors.surface,
          borderRadius: DSRadius.mdBorder,
          border: Border.all(
            color: context.colors.border.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: iconColor ?? context.colors.accent,
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              value,
              style: context.typography.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DSSpacing.xxs),
            Text(
              label,
              style: context.typography.labelSmall.copyWith(
                color: context.colors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 2열 그리드 빌더
class TwoColumnGrid extends StatelessWidget {
  const TwoColumnGrid({
    super.key,
    required this.items,
    this.spacing = DSSpacing.sm,
  });

  final List<Widget> items;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    for (var i = 0; i < items.length; i += 2) {
      final rowItems = items.skip(i).take(2).toList();
      rows.add(
        Row(
          children: rowItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == 0 && rowItems.length > 1 ? spacing : 0,
                ),
                child: item,
              ),
            );
          }).toList(),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows.asMap().entries.map((entry) {
        final index = entry.key;
        final row = entry.value;
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < rows.length - 1 ? spacing : 0,
          ),
          child: row,
        );
      }).toList(),
    );
  }
}
