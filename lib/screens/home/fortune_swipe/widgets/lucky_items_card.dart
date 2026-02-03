import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/design_system.dart';

/// ✨ 행운 아이템 카드 - ChatGPT Pulse 스타일
class LuckyItemsCard extends StatelessWidget {
  final Map<String, String> luckyItems;
  final bool isDark;

  const LuckyItemsCard({
    super.key,
    required this.luckyItems,
    required this.isDark,
  });

  /// U07: 시간 포맷 변경 ("저녁6시에서8시" → "저녁6~8시")
  String _formatTimeRange(String time) {
    // "저녁6시에서8시" 또는 "오전10시에서12시" 패턴을 "저녁6~8시"로 변환
    final regex = RegExp(r'^(.+?)(\d+)시에서(\d+)시$');
    final match = regex.firstMatch(time);
    if (match != null) {
      final prefix = match.group(1) ?? ''; // 저녁, 오전, 오후 등
      final startHour = match.group(2) ?? '';
      final endHour = match.group(3) ?? '';
      return '$prefix$startHour~$endHour시';
    }
    // 매칭되지 않으면 원본 반환
    return time;
  }

  /// 시간 키인지 확인하고 포맷 적용
  String _formatValue(String key, String value) {
    final lowerKey = key.toLowerCase();
    if (lowerKey.contains('시간') || lowerKey == 'time') {
      return _formatTimeRange(value);
    }
    return value;
  }

  /// 값에 맞는 구체적 이모지 반환
  String _getValueEmoji(String key, String value) {
    final lowerKey = key.toLowerCase();
    final lowerValue = value.toLowerCase();

    // 시간대별 이모지
    if (lowerKey.contains('시간') || lowerKey == 'time') {
      if (lowerValue.contains('오전') || lowerValue.contains('아침')) return '🌅';
      if (lowerValue.contains('오후') || lowerValue.contains('낮')) return '☀️';
      if (lowerValue.contains('저녁')) return '🌆';
      if (lowerValue.contains('밤')) return '🌙';
      if (lowerValue.contains('새벽')) return '🌌';
      if (lowerValue.contains('정오')) return '🌞';
      return '🕐';
    }

    // 색상별 이모지
    if (lowerKey.contains('색') || lowerKey == 'color') {
      if (lowerValue.contains('빨강') || lowerValue.contains('레드')) return '🔴';
      if (lowerValue.contains('파랑') || lowerValue.contains('블루')) return '🔵';
      if (lowerValue.contains('초록') || lowerValue.contains('그린')) return '🟢';
      if (lowerValue.contains('노랑') || lowerValue.contains('옐로')) return '🟡';
      if (lowerValue.contains('보라') || lowerValue.contains('퍼플')) return '🟣';
      if (lowerValue.contains('주황') || lowerValue.contains('오렌지')) return '🟠';
      if (lowerValue.contains('분홍') || lowerValue.contains('핑크')) return '🩷';
      if (lowerValue.contains('흰') || lowerValue.contains('화이트')) return '⚪';
      if (lowerValue.contains('검정') || lowerValue.contains('블랙')) return '⚫';
      if (lowerValue.contains('올리브')) return '🫒';
      if (lowerValue.contains('청록') || lowerValue.contains('민트') || lowerValue.contains('터콰이즈')) return '🩵';
      if (lowerValue.contains('금') || lowerValue.contains('골드')) return '🥇';
      if (lowerValue.contains('은') || lowerValue.contains('실버')) return '🥈';
      if (lowerValue.contains('베이지') || lowerValue.contains('아이보리')) return '🤍';
      if (lowerValue.contains('갈색') || lowerValue.contains('브라운')) return '🟤';
      return '🎨';
    }

    // 방향별 이모지
    if (lowerKey.contains('방향') || lowerKey == 'direction') {
      if (lowerValue.contains('동남') || lowerValue.contains('남동')) return '↘️';
      if (lowerValue.contains('동북') || lowerValue.contains('북동')) return '↗️';
      if (lowerValue.contains('서남') || lowerValue.contains('남서')) return '↙️';
      if (lowerValue.contains('서북') || lowerValue.contains('북서')) return '↖️';
      if (lowerValue.contains('동')) return '➡️';
      if (lowerValue.contains('서')) return '⬅️';
      if (lowerValue.contains('남')) return '⬇️';
      if (lowerValue.contains('북')) return '⬆️';
      return '🧭';
    }

    // 음식별 이모지
    if (lowerKey.contains('음식') || lowerKey == 'food') {
      if (lowerValue.contains('과일')) return '🍎';
      if (lowerValue.contains('채소') || lowerValue.contains('야채') || lowerValue.contains('샐러드')) return '🥬';
      if (lowerValue.contains('고기') || lowerValue.contains('육류') || lowerValue.contains('스테이크')) return '🥩';
      if (lowerValue.contains('해산물') || lowerValue.contains('생선') || lowerValue.contains('회')) return '🦐';
      if (lowerValue.contains('면') || lowerValue.contains('국수') || lowerValue.contains('파스타') || lowerValue.contains('라면')) return '🍜';
      if (lowerValue.contains('밥') || lowerValue.contains('쌀')) return '🍚';
      if (lowerValue.contains('빵') || lowerValue.contains('토스트') || lowerValue.contains('베이커리')) return '🍞';
      if (lowerValue.contains('견과') || lowerValue.contains('땅콩') || lowerValue.contains('아몬드') || lowerValue.contains('호두')) return '🥜';
      if (lowerValue.contains('디저트') || lowerValue.contains('케이크') || lowerValue.contains('과자')) return '🍰';
      if (lowerValue.contains('음료') || lowerValue.contains('커피') || lowerValue.contains('차')) return '☕';
      if (lowerValue.contains('국') || lowerValue.contains('찌개') || lowerValue.contains('탕')) return '🍲';
      if (lowerValue.contains('피자')) return '🍕';
      if (lowerValue.contains('버거') || lowerValue.contains('햄버거')) return '🍔';
      if (lowerValue.contains('초밥') || lowerValue.contains('스시')) return '🍣';
      if (lowerValue.contains('치킨') || lowerValue.contains('닭')) return '🍗';
      return '🍽️';
    }

    // 아이템별 이모지
    if (lowerKey.contains('아이템') || lowerKey == 'item') {
      if (lowerValue.contains('시계') || lowerValue.contains('워치')) return '⌚';
      if (lowerValue.contains('가방') || lowerValue.contains('백')) return '👜';
      if (lowerValue.contains('책') || lowerValue.contains('도서')) return '📖';
      if (lowerValue.contains('꽃') || lowerValue.contains('플라워')) return '🌸';
      if (lowerValue.contains('브로치') || lowerValue.contains('보석') || lowerValue.contains('쥬얼리')) return '💎';
      if (lowerValue.contains('반지') || lowerValue.contains('링')) return '💍';
      if (lowerValue.contains('목걸이') || lowerValue.contains('네크리스')) return '📿';
      if (lowerValue.contains('열쇠') || lowerValue.contains('키')) return '🔑';
      if (lowerValue.contains('우산')) return '☂️';
      if (lowerValue.contains('손수건') || lowerValue.contains('스카프')) return '🧣';
      if (lowerValue.contains('노트') || lowerValue.contains('다이어리') || lowerValue.contains('수첩')) return '📓';
      if (lowerValue.contains('펜') || lowerValue.contains('필기')) return '🖊️';
      if (lowerValue.contains('안경')) return '👓';
      if (lowerValue.contains('모자') || lowerValue.contains('캡')) return '🧢';
      if (lowerValue.contains('신발') || lowerValue.contains('구두') || lowerValue.contains('운동화')) return '👟';
      if (lowerValue.contains('지갑')) return '👛';
      if (lowerValue.contains('휴대폰') || lowerValue.contains('스마트폰') || lowerValue.contains('폰')) return '📱';
      if (lowerValue.contains('이어폰') || lowerValue.contains('헤드폰')) return '🎧';
      return '✨';
    }

    // 숫자 이모지
    if (lowerKey.contains('숫자') || lowerKey == 'number') {
      final numEmojis = {
        '0': '0️⃣', '1': '1️⃣', '2': '2️⃣', '3': '3️⃣', '4': '4️⃣',
        '5': '5️⃣', '6': '6️⃣', '7': '7️⃣', '8': '8️⃣', '9': '9️⃣',
      };
      // 첫 번째 숫자만 이모지로
      for (final digit in value.split('')) {
        if (numEmojis.containsKey(digit)) {
          return numEmojis[digit]!;
        }
      }
      return '🔢';
    }

    return '⭐';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Text(
          '오늘의 행운 아이템',
          style: context.heading3.copyWith(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '오늘 행운을 불러올 아이템들',
          style: context.bodySmall.copyWith(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
          ),
        ),

        const SizedBox(height: 16),

        // 행운 아이템 그리드 (Pulse 스타일) - LayoutBuilder로 정확한 너비 계산
        LayoutBuilder(
          builder: (context, constraints) {
            // 사용 가능한 전체 너비
            final availableWidth = constraints.maxWidth;
            // 2열 그리드: (전체 너비 - 중간 간격) / 2
            final itemWidth = (availableWidth - 10) / 2;

            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: luckyItems.entries.map((entry) {
                return Container(
                  width: itemWidth,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? DSColors.surface : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이모지 (크게)
                      Text(
                        _getValueEmoji(entry.key, entry.value),
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 6),
                      // 라벨 (작게)
                      Text(
                        entry.key,
                        style: context.labelTiny.copyWith(
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 2),
                      // 값 (중간) - 시간 포맷 적용
                      Text(
                        _formatValue(entry.key, entry.value),
                        style: context.labelMedium.copyWith(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ).animate()
                  .fadeIn(duration: 400.ms)
                  .scale(begin: const Offset(0.95, 0.95), duration: 400.ms, curve: Curves.easeOut);
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
