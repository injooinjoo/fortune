import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/tokens/ds_spacing.dart';
import 'package:fortune/core/design_system/tokens/ds_radius.dart';
import 'package:fortune/core/design_system/theme/ds_extensions.dart';
import 'package:fortune/core/theme/obangseok_colors.dart';

/// 행운 아이템 행 위젯
///
/// 색상, 숫자, 시간, 음식, 아이템, 방향 등의 행운 요소를
/// 아이콘과 함께 수평으로 표시합니다.
class LuckyItemRow extends StatelessWidget {
  const LuckyItemRow({
    super.key,
    required this.items,
    this.spacing = DSSpacing.sm,
    this.wrap = true,
    this.alignment = WrapAlignment.center,
  });

  /// 행운 아이템 목록
  final List<LuckyItem> items;

  /// 아이템 간 간격
  final double spacing;

  /// 줄바꿈 여부
  final bool wrap;

  /// 정렬 방식
  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) {
    if (wrap) {
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        alignment: alignment,
        children: items.map((item) => _LuckyItemChip(item: item)).toList(),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              right: index < items.length - 1 ? spacing : 0,
            ),
            child: _LuckyItemChip(item: item),
          );
        }).toList(),
      ),
    );
  }
}

/// 개별 행운 아이템 칩
/// 동양화 스타일: 투명 배경 + 먹색 테두리 + 먹색 텍스트
class _LuckyItemChip extends StatelessWidget {
  const _LuckyItemChip({
    required this.item,
  });

  final LuckyItem item;

  @override
  Widget build(BuildContext context) {
    final meokColor = ObangseokColors.getMeok(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: DSRadius.smBorder,
        border: Border.all(
          color: meokColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 색상 타입: 작은 원형 컬러칩만
          if (item.type == LuckyItemType.color && item.colorValue != null)
            _ColorChip(color: item.colorValue!)
          else
            Icon(
              item.icon ?? _getDefaultIcon(item.type),
              size: 14,
              color: meokColor.withValues(alpha: 0.5),
            ),
          const SizedBox(width: DSSpacing.xs),
          // 라벨과 값 - 모두 먹색
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.label != null)
                Text(
                  item.label!,
                  style: context.typography.labelSmall.copyWith(
                    fontSize: 10,
                    color: meokColor.withValues(alpha: 0.5),
                  ),
                ),
              Text(
                item.value,
                style: context.typography.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                  color: meokColor.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getDefaultIcon(LuckyItemType type) {
    switch (type) {
      case LuckyItemType.color:
        return Icons.palette_rounded;
      case LuckyItemType.number:
        return Icons.tag_rounded;
      case LuckyItemType.time:
        return Icons.access_time_rounded;
      case LuckyItemType.food:
        return Icons.restaurant_rounded;
      case LuckyItemType.item:
        return Icons.star_rounded;
      case LuckyItemType.direction:
        return Icons.explore_rounded;
      case LuckyItemType.place:
        return Icons.place_rounded;
      case LuckyItemType.animal:
        return Icons.pets_rounded;
      case LuckyItemType.custom:
        return Icons.auto_awesome_rounded;
    }
  }
}

/// 색상 칩 위젯 (원형, 작은 크기)
/// 동양화 스타일: 그림자 없이 단순한 원형
class _ColorChip extends StatelessWidget {
  const _ColorChip({
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    final meokColor = ObangseokColors.getMeok(context);

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: meokColor.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
    );
  }
}

/// 행운 아이템 타입
enum LuckyItemType {
  /// 행운 색상
  color,

  /// 행운 숫자
  number,

  /// 행운 시간
  time,

  /// 행운 음식
  food,

  /// 행운 아이템
  item,

  /// 행운 방향
  direction,

  /// 행운 장소
  place,

  /// 행운 동물
  animal,

  /// 커스텀
  custom,
}

/// 행운 아이템 데이터
class LuckyItem {
  const LuckyItem({
    required this.type,
    required this.value,
    this.label,
    this.icon,
    this.iconColor,
    this.colorValue,
    this.backgroundColor,
  });

  /// 아이템 타입
  final LuckyItemType type;

  /// 값 (표시될 텍스트)
  final String value;

  /// 라벨 (선택)
  final String? label;

  /// 커스텀 아이콘 (선택)
  final IconData? icon;

  /// 아이콘 색상 (선택)
  final Color? iconColor;

  /// 색상 값 (color 타입일 때)
  final Color? colorValue;

  /// 배경색 (선택)
  final Color? backgroundColor;

  /// 색상 타입 아이템 생성
  factory LuckyItem.color({
    required String name,
    required Color color,
    String? label,
  }) {
    return LuckyItem(
      type: LuckyItemType.color,
      value: name,
      label: label ?? '행운 색상',
      colorValue: color,
    );
  }

  /// 숫자 타입 아이템 생성
  factory LuckyItem.number({
    required int number,
    String? label,
  }) {
    return LuckyItem(
      type: LuckyItemType.number,
      value: '$number',
      label: label ?? '행운 숫자',
    );
  }

  /// 시간 타입 아이템 생성
  factory LuckyItem.time({
    required String time,
    String? label,
  }) {
    return LuckyItem(
      type: LuckyItemType.time,
      value: time,
      label: label ?? '행운 시간',
    );
  }

  /// 음식 타입 아이템 생성
  factory LuckyItem.food({
    required String food,
    String? label,
  }) {
    return LuckyItem(
      type: LuckyItemType.food,
      value: food,
      label: label ?? '행운 음식',
    );
  }

  /// 아이템 타입 생성
  factory LuckyItem.item({
    required String item,
    String? label,
    IconData? icon,
  }) {
    return LuckyItem(
      type: LuckyItemType.item,
      value: item,
      label: label ?? '행운 아이템',
      icon: icon,
    );
  }

  /// 방향 타입 아이템 생성
  factory LuckyItem.direction({
    required String direction,
    String? label,
  }) {
    return LuckyItem(
      type: LuckyItemType.direction,
      value: direction,
      label: label ?? '행운 방향',
    );
  }

  /// 장소 타입 아이템 생성
  factory LuckyItem.place({
    required String place,
    String? label,
  }) {
    return LuckyItem(
      type: LuckyItemType.place,
      value: place,
      label: label ?? '행운 장소',
    );
  }
}

/// 일일 운세용 행운 아이템 프리셋
class DailyLuckyItems {
  DailyLuckyItems._();

  static List<LuckyItem> fromData({
    String? colorName,
    Color? colorValue,
    int? luckyNumber,
    String? luckyTime,
    String? luckyFood,
    String? luckyItem,
    String? luckyDirection,
  }) {
    final items = <LuckyItem>[];

    if (colorName != null && colorValue != null) {
      items.add(LuckyItem.color(name: colorName, color: colorValue));
    }

    if (luckyNumber != null) {
      items.add(LuckyItem.number(number: luckyNumber));
    }

    if (luckyTime != null) {
      items.add(LuckyItem.time(time: luckyTime));
    }

    if (luckyFood != null) {
      items.add(LuckyItem.food(food: luckyFood));
    }

    if (luckyItem != null) {
      items.add(LuckyItem.item(item: luckyItem));
    }

    if (luckyDirection != null) {
      items.add(LuckyItem.direction(direction: luckyDirection));
    }

    return items;
  }
}

/// 컴팩트 행운 아이템 그리드
class LuckyItemGrid extends StatelessWidget {
  const LuckyItemGrid({
    super.key,
    required this.items,
    this.columns = 2,
    this.spacing = DSSpacing.sm,
  });

  final List<LuckyItem> items;
  final int columns;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += columns) {
      final rowItems = items.skip(i).take(columns).toList();
      rows.add(
        Row(
          children: rowItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < rowItems.length - 1 ? spacing : 0,
                ),
                child: _LuckyItemCard(item: item),
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

/// 행운 아이템 카드 (그리드용)
/// 동양화 스타일: 투명 배경 + 먹색 테두리 + 먹색 텍스트
class _LuckyItemCard extends StatelessWidget {
  const _LuckyItemCard({
    required this.item,
  });

  final LuckyItem item;

  @override
  Widget build(BuildContext context) {
    final meokColor = ObangseokColors.getMeok(context);

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: DSRadius.smBorder,
        border: Border.all(
          color: meokColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 색상 타입: 원형 컬러칩
          if (item.type == LuckyItemType.color && item.colorValue != null)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: item.colorValue,
                shape: BoxShape.circle,
                border: Border.all(
                  color: meokColor.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
            )
          else
            Icon(
              item.icon ?? _getDefaultIcon(item.type),
              size: 22,
              color: meokColor.withValues(alpha: 0.5),
            ),
          const SizedBox(height: DSSpacing.xs),
          // 값 - 먹색
          Text(
            item.value,
            style: context.typography.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              color: meokColor.withValues(alpha: 0.85),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // 라벨 - 옅은 먹색
          if (item.label != null)
            Text(
              item.label!,
              style: context.typography.labelSmall.copyWith(
                fontSize: 10,
                color: meokColor.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  IconData _getDefaultIcon(LuckyItemType type) {
    switch (type) {
      case LuckyItemType.color:
        return Icons.palette_rounded;
      case LuckyItemType.number:
        return Icons.tag_rounded;
      case LuckyItemType.time:
        return Icons.access_time_rounded;
      case LuckyItemType.food:
        return Icons.restaurant_rounded;
      case LuckyItemType.item:
        return Icons.star_rounded;
      case LuckyItemType.direction:
        return Icons.explore_rounded;
      case LuckyItemType.place:
        return Icons.place_rounded;
      case LuckyItemType.animal:
        return Icons.pets_rounded;
      case LuckyItemType.custom:
        return Icons.auto_awesome_rounded;
    }
  }
}
