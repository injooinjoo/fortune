import 'package:flutter/material.dart';
import '../../design_system/design_system.dart';

/// 행운 요소를 컴팩트하게 가로 배열하는 인포그래픽 위젯
///
/// 기존 LuckyItemsRow와 달리 이미지 없이 아이콘+텍스트로만 표시
///
/// 사용 예시:
/// ```dart
/// LuckyItemsCompact(
///   items: [
///     LuckyItem(type: 'color', value: '빨강', icon: '🔴'),
///     LuckyItem(type: 'number', value: '7', icon: '7️⃣'),
///     LuckyItem(type: 'direction', value: '동쪽', icon: '➡️'),
///     LuckyItem(type: 'time', value: '오전', icon: '🌅'),
///   ],
/// )
/// ```
class LuckyItemsCompact extends StatelessWidget {
  /// 행운 아이템 목록
  final List<LuckyItem> items;

  /// 아이템 간 간격 (기본값: 16)
  final double spacing;

  /// 스크롤 가능 여부 (기본값: true)
  final bool scrollable;

  /// 배경 표시 여부 (기본값: true)
  final bool showBackground;

  /// 라벨 표시 여부 (기본값: true)
  final bool showLabel;

  const LuckyItemsCompact({
    super.key,
    required this.items,
    this.spacing = 16,
    this.scrollable = true,
    this.showBackground = true,
    this.showLabel = true,
  });

  /// Map에서 LuckyItemsCompact 생성
  factory LuckyItemsCompact.fromMap(Map<String, dynamic> luckyItems) {
    final items = <LuckyItem>[];

    luckyItems.forEach((key, value) {
      final item = LuckyItem.fromKeyValue(key, value.toString());
      if (item != null) {
        items.add(item);
      }
    });

    return LuckyItemsCompact(items: items);
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final isDark = context.isDark;
    final bgColor = showBackground
        ? (isDark ? DSColors.surfaceDark : DSColors.surface)
        : Colors.transparent;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return Padding(
          padding:
              EdgeInsets.only(right: index < items.length - 1 ? spacing : 0),
          child: _LuckyItemChip(
            item: item,
            showLabel: showLabel,
            showBackground: showBackground,
          ),
        );
      }).toList(),
    );

    if (scrollable) {
      content = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: content,
      );
    }

    if (showBackground) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? DSColors.borderDark : DSColors.border,
            width: 1,
          ),
        ),
        child: content,
      );
    }

    return content;
  }
}

/// 개별 행운 아이템 칩
class _LuckyItemChip extends StatelessWidget {
  final LuckyItem item;
  final bool showLabel;
  final bool showBackground;

  const _LuckyItemChip({
    required this.item,
    required this.showLabel,
    required this.showBackground,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 아이콘
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isDark
                ? DSColors.backgroundSecondaryDark
                : DSColors.backgroundSecondary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            item.icon,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 6),
          // 값
          Text(
            item.value,
            style: context.labelMedium.copyWith(
              color: isDark ? DSColors.textPrimaryDark : DSColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // 라벨
          Text(
            item.label,
            style: context.labelSmall.copyWith(
              color:
                  isDark ? DSColors.textSecondaryDark : DSColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }
}

/// 행운 아이템 데이터 모델
class LuckyItem {
  /// 아이템 타입 (color, number, direction, time 등)
  final String type;

  /// 표시 값 (빨강, 7, 동쪽 등)
  final String value;

  /// 아이콘 (이모지)
  final String icon;

  /// 라벨 (행운색, 행운숫자 등)
  final String label;

  const LuckyItem({
    required this.type,
    required this.value,
    required this.icon,
    required this.label,
  });

  /// 키-값 쌍에서 LuckyItem 생성
  static LuckyItem? fromKeyValue(String key, String value) {
    final k = key.toLowerCase();

    // 지원되는 타입 확인
    if (_isColorType(k)) {
      return LuckyItem(
        type: 'color',
        value: value,
        icon: _getColorIcon(value),
        label: '행운색',
      );
    }
    if (_isNumberType(k)) {
      return LuckyItem(
        type: 'number',
        value: value,
        icon: _getNumberIcon(value),
        label: '행운숫자',
      );
    }
    if (_isDirectionType(k)) {
      return LuckyItem(
        type: 'direction',
        value: value,
        icon: _getDirectionIcon(value),
        label: '행운방향',
      );
    }
    if (_isTimeType(k)) {
      return LuckyItem(
        type: 'time',
        value: value,
        icon: _getTimeIcon(value),
        label: '행운시간',
      );
    }
    if (_isZodiacType(k)) {
      return LuckyItem(
        type: 'zodiac',
        value: value,
        icon: _getZodiacIcon(value),
        label: '행운띠',
      );
    }
    if (_isElementType(k)) {
      return LuckyItem(
        type: 'element',
        value: value,
        icon: _getElementIcon(value),
        label: '행운오행',
      );
    }

    return null;
  }

  // 타입 체크 헬퍼
  static bool _isColorType(String k) =>
      k == 'color' || k == '색깔' || k == '행운색' || k == 'lucky_color';
  static bool _isNumberType(String k) =>
      k == 'number' || k == '숫자' || k == '행운숫자' || k == 'lucky_number';
  static bool _isDirectionType(String k) =>
      k == 'direction' || k == '방향' || k == '행운방향' || k == 'lucky_direction';
  static bool _isTimeType(String k) =>
      k == 'time' || k == '시간' || k == '행운시간' || k == 'lucky_time';
  static bool _isZodiacType(String k) =>
      k == 'zodiac' || k == '띠' || k == '행운띠' || k == 'lucky_zodiac';
  static bool _isElementType(String k) =>
      k == 'element' || k == '오행' || k == '행운오행' || k == 'lucky_element';

  // 아이콘 생성 헬퍼
  static String _getColorIcon(String value) {
    final v = value.toLowerCase();
    if (v.contains('빨') || v.contains('red')) return '🔴';
    if (v.contains('파') || v.contains('blue')) return '🔵';
    if (v.contains('노') || v.contains('yellow')) return '🟡';
    if (v.contains('초') || v.contains('green')) return '🟢';
    if (v.contains('주') || v.contains('orange')) return '🟠';
    if (v.contains('보') || v.contains('purple')) return '🟣';
    if (v.contains('검') || v.contains('black')) return '⚫';
    if (v.contains('흰') || v.contains('white')) return '⚪';
    if (v.contains('분') || v.contains('pink')) return '🩷';
    if (v.contains('갈') || v.contains('brown')) return '🟤';
    return '🎨';
  }

  static String _getNumberIcon(String value) {
    final num = int.tryParse(value);
    if (num != null && num >= 0 && num <= 10) {
      const numbers = [
        '0️⃣',
        '1️⃣',
        '2️⃣',
        '3️⃣',
        '4️⃣',
        '5️⃣',
        '6️⃣',
        '7️⃣',
        '8️⃣',
        '9️⃣',
        '🔟'
      ];
      return numbers[num];
    }
    return '🔢';
  }

  static String _getDirectionIcon(String value) {
    final v = value.toLowerCase();
    if (v.contains('동') || v.contains('east')) return '➡️';
    if (v.contains('서') || v.contains('west')) return '⬅️';
    if (v.contains('남') || v.contains('south')) return '⬇️';
    if (v.contains('북') || v.contains('north')) return '⬆️';
    if (v.contains('북동') || v.contains('northeast')) return '↗️';
    if (v.contains('북서') || v.contains('northwest')) return '↖️';
    if (v.contains('남동') || v.contains('southeast')) return '↘️';
    if (v.contains('남서') || v.contains('southwest')) return '↙️';
    return '🧭';
  }

  static String _getTimeIcon(String value) {
    final v = value.toLowerCase();
    if (v.contains('새벽') || v.contains('dawn')) return '🌃';
    if (v.contains('아침') || v.contains('오전') || v.contains('morning')) {
      return '🌅';
    }
    if (v.contains('정오') || v.contains('낮') || v.contains('noon')) return '☀️';
    if (v.contains('오후') || v.contains('afternoon')) return '🌤️';
    if (v.contains('저녁') || v.contains('evening')) return '🌆';
    if (v.contains('밤') || v.contains('night')) return '🌙';
    return '⏰';
  }

  static String _getZodiacIcon(String value) {
    final v = value.toLowerCase();
    if (v.contains('쥐') || v.contains('자')) return '🐀';
    if (v.contains('소') || v.contains('축')) return '🐂';
    if (v.contains('호랑이') || v.contains('범') || v.contains('인')) return '🐅';
    if (v.contains('토끼') || v.contains('묘')) return '🐇';
    if (v.contains('용') || v.contains('진')) return '🐉';
    if (v.contains('뱀') || v.contains('사')) return '🐍';
    if (v.contains('말') || v.contains('오')) return '🐎';
    if (v.contains('양') || v.contains('미')) return '🐑';
    if (v.contains('원숭이') || v.contains('신')) return '🐒';
    if (v.contains('닭') || v.contains('유')) return '🐓';
    if (v.contains('개') || v.contains('술')) return '🐕';
    if (v.contains('돼지') || v.contains('해')) return '🐖';
    return '🐾';
  }

  static String _getElementIcon(String value) {
    final v = value.toLowerCase();
    if (v.contains('목') || v.contains('wood')) return '🌳';
    if (v.contains('화') || v.contains('fire')) return '🔥';
    if (v.contains('토') || v.contains('earth')) return '⛰️';
    if (v.contains('금') || v.contains('metal')) return '⚙️';
    if (v.contains('수') || v.contains('water')) return '💧';
    return '✨';
  }
}
