import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import 'info_item.dart';

/// 오늘의 색상 컨텐츠 - API 데이터 우선, 없으면 기존 로직 사용
class TodayColorContent extends StatelessWidget {
  final DateTime birthDate;
  final Map<String, dynamic>? colorDetail;

  const TodayColorContent({
    super.key,
    required this.birthDate,
    this.colorDetail,
  });

  /// 사주 기반 행운 색상 생성 (API 데이터 없을 때 폴백)
  Map<String, dynamic> _generateTodayColor() {
    final now = DateTime.now();

    // 사주 기반 시드
    final seed =
        birthDate.day + birthDate.month * 10 + now.day + now.month * 100;
    final random = Random(seed);

    // 미리 정의된 행운 색상 팔레트 (한글명, Color)
    final luckyColors = [
      {'name': '진홍색', 'color': const Color(0xFFDC143C), 'meaning': '열정과 활력'},
      {'name': '산호색', 'color': const Color(0xFFFF7F50), 'meaning': '따뜻한 에너지'},
      {'name': '주황색', 'color': const Color(0xFFFF8C00), 'meaning': '창의력과 자신감'},
      {'name': '황금색', 'color': const Color(0xFFFFD700), 'meaning': '풍요와 번영'},
      {'name': '레몬색', 'color': const Color(0xFFFFF44F), 'meaning': '밝은 희망'},
      {'name': '연두색', 'color': const Color(0xFF90EE90), 'meaning': '새로운 시작'},
      {'name': '초록색', 'color': const Color(0xFF228B22), 'meaning': '성장과 건강'},
      {'name': '청록색', 'color': const Color(0xFF20B2AA), 'meaning': '균형과 조화'},
      {'name': '하늘색', 'color': const Color(0xFF87CEEB), 'meaning': '평화와 안정'},
      {'name': '파란색', 'color': const Color(0xFF4169E1), 'meaning': '신뢰와 지혜'},
      {'name': '남색', 'color': const Color(0xFF191970), 'meaning': '깊은 통찰'},
      {'name': '보라색', 'color': const Color(0xFF9370DB), 'meaning': '영감과 창조'},
      {'name': '자주색', 'color': const Color(0xFF8B008B), 'meaning': '고귀함과 품위'},
      {'name': '분홍색', 'color': const Color(0xFFFFB6C1), 'meaning': '사랑과 행복'},
      {'name': '복숭아색', 'color': const Color(0xFFFFDAB9), 'meaning': '부드러운 행운'},
      {'name': '베이지색', 'color': const Color(0xFFF5DEB3), 'meaning': '안정과 편안함'},
      {'name': '갈색', 'color': const Color(0xFF8B4513), 'meaning': '신뢰와 안정'},
      {'name': '은색', 'color': const Color(0xFFC0C0C0), 'meaning': '직관과 통찰'},
      {'name': '회색', 'color': const Color(0xFF808080), 'meaning': '중립과 균형'},
      {'name': '검정색', 'color': const Color(0xFF2F2F2F), 'meaning': '세련됨과 권위'},
    ];

    final selected = luckyColors[random.nextInt(luckyColors.length)];

    return {
      'name': selected['name'] as String,
      'color': selected['color'] as Color,
      'meaning': selected['meaning'] as String,
    };
  }

  /// 색상 코드 파싱
  Color _parseColorCode(String? colorCode, Color fallback) {
    if (colorCode == null || colorCode.isEmpty) return fallback;
    try {
      if (colorCode.startsWith('#')) {
        return Color(int.parse(colorCode.substring(1), radix: 16) + 0xFF000000);
      }
    } catch (_) {}
    return fallback;
  }

  /// 색상에 따른 상세 설명
  String _getColorDescription(String colorName) {
    final descriptions = {
      '진홍색': '오늘은 당신의 열정이 빛나는 날입니다. 적극적으로 행동하면 좋은 결과가 있을 거예요.',
      '산호색': '따뜻한 기운이 당신을 감싸고 있어요. 주변 사람들과 좋은 관계를 맺기 좋은 날입니다.',
      '주황색': '창의적인 아이디어가 떠오르는 날이에요. 새로운 시도를 해보세요.',
      '황금색': '재물운이 좋은 날입니다. 금전적인 결정을 내리기 좋아요.',
      '레몬색': '밝고 긍정적인 에너지가 가득한 날이에요. 웃음이 행운을 가져다 줍니다.',
      '연두색': '새로운 시작에 적합한 날입니다. 무언가 새롭게 시작해보세요.',
      '초록색': '건강과 성장의 기운이 함께해요. 운동이나 자기계발에 좋은 날입니다.',
      '청록색': '마음의 평화를 찾기 좋은 날이에요. 명상이나 휴식을 취해보세요.',
      '하늘색': '커뮤니케이션 운이 좋아요. 중요한 대화나 발표가 있다면 잘 될 거예요.',
      '파란색': '집중력이 높아지는 날입니다. 중요한 업무나 공부에 집중해보세요.',
      '남색': '깊은 생각이 필요한 날이에요. 중요한 결정을 내리기 좋습니다.',
      '보라색': '영감이 넘치는 날입니다. 예술적인 활동이나 창작에 좋아요.',
      '자주색': '품위 있는 행동이 행운을 가져옵니다. 격식 있는 자리에 좋은 날이에요.',
      '분홍색': '연애운이 좋은 날이에요. 사랑하는 사람과의 시간이 특별해질 거예요.',
      '복숭아색': '부드러운 행운이 찾아오는 날입니다. 편안한 마음으로 지내세요.',
      '베이지색': '안정적인 하루가 될 거예요. 차분하게 일상을 보내면 좋습니다.',
      '갈색': '실용적인 결정이 좋은 결과를 가져옵니다. 현실적으로 생각하세요.',
      '은색': '직관을 믿어보세요. 느낌대로 행동하면 좋은 일이 생길 거예요.',
      '회색': '균형 잡힌 하루가 될 거예요. 무리하지 말고 중용을 지키세요.',
      '검정색': '세련되고 프로페셔널한 모습이 빛나는 날입니다. 중요한 미팅에 좋아요.',
    };
    return descriptions[colorName] ?? '오늘 이 색상이 행운을 가져다 줄 거예요.';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // API 데이터 우선, 없으면 기존 로직 사용
    final String colorName;
    final Color color;
    final String meaning;
    final String description;

    if (colorDetail != null && colorDetail!['mainColor'] != null) {
      colorName = colorDetail!['mainColor'] as String;
      color = _parseColorCode(
          colorDetail!['mainColorCode'] as String?, Colors.grey);
      meaning = colorDetail!['colorMeaning'] as String? ?? '행운의 기운';
      description = colorDetail!['colorDescription'] as String? ??
          _getColorDescription(colorName);
    } else {
      final colorData = _generateTodayColor();
      colorName = colorData['name'] as String;
      color = colorData['color'] as Color;
      meaning = colorData['meaning'] as String;
      description = _getColorDescription(colorName);
    }

    // 텍스트 색상 계산 (명도 기반)
    final luminance = color.computeLuminance();
    final textColor = luminance > 0.5 ? Colors.black : Colors.white;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.border,
        ),
      ),
      child: Column(
        children: [
          // 큰 색상 프리뷰 - 미니멀 스타일
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                colorName,
                style: DSTypography.headingMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 색상 정보 (한글로만 표시)
          InfoItem(label: '오늘의 행운색', value: colorName),
          InfoItem(label: '색상 의미', value: meaning),
          InfoItem(label: '오늘의 조언', value: description),
          const InfoItem(
            label: '활용 팁',
            value: '오늘 이 색상의 옷이나 소품을 착용하면 행운이 따릅니다',
          ),
          const InfoItem(
            label: '추천 아이템',
            value: '액세서리, 가방, 양말, 스마트폰 케이스',
          ),
        ],
      ),
    );
  }
}
