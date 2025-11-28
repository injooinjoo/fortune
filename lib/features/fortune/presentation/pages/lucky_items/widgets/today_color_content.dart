import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../../../core/theme/typography_unified.dart';
import 'info_item.dart';

/// 오늘의 색상 컨텐츠
class TodayColorContent extends StatelessWidget {
  final DateTime birthDate;

  const TodayColorContent({super.key, required this.birthDate});

  Map<String, dynamic> _generateTodayColor() {
    final now = DateTime.now();

    // 사주 기반 시드
    final seed = birthDate.day + birthDate.month * 10 + now.day + now.month * 100;
    final random = Random(seed);

    // RGB 생성
    final r = random.nextInt(256);
    final g = random.nextInt(256);
    final b = random.nextInt(256);

    final hex = '#${r.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${g.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${b.toRadixString(16).padLeft(2, '0').toUpperCase()}';

    return {
      'hex': hex,
      'color': Color.fromARGB(255, r, g, b),
      'r': r,
      'g': g,
      'b': b,
    };
  }

  String _getColorMeaning(int r, int g, int b) {
    // RGB 값에 따른 색상 의미
    if (r > 200 && g < 100 && b < 100) return '열정과 에너지의 빨간색 계열';
    if (r < 100 && g < 100 && b > 200) return '평온과 안정의 파란색 계열';
    if (r < 100 && g > 200 && b < 100) return '성장과 희망의 녹색 계열';
    if (r > 200 && g > 200 && b < 100) return '활력과 기쁨의 노란색 계열';
    if (r > 200 && g < 100 && b > 200) return '창의성의 보라색 계열';
    if (r > 150 && g > 150 && b > 150) return '순수함과 청명함의 밝은 색';
    if (r < 100 && g < 100 && b < 100) return '세련됨과 우아함의 어두운 색';
    return '균형과 조화의 중간 톤';
  }

  @override
  Widget build(BuildContext context) {
    final colorData = _generateTodayColor();
    final color = colorData['color'] as Color;
    final hex = colorData['hex'] as String;
    final r = colorData['r'] as int;
    final g = colorData['g'] as int;
    final b = colorData['b'] as int;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 큰 색상 프리뷰
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  hex,
                  style: TypographyUnified.heading2.copyWith(
                    color: (r + g + b) > 382 ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 색상 정보
            InfoItem(label: 'HEX 코드', value: hex),
            InfoItem(label: 'RGB', value: 'R:$r, G:$g, B:$b'),
            InfoItem(label: '색상 의미', value: _getColorMeaning(r, g, b)),
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
      ),
    );
  }
}
