import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/theme/font_config.dart';

/// 🌊 오행 밸런스 카드
class FiveElementsCard extends StatelessWidget {
  final Map<String, int> elements;
  final Map<String, String?> sajuInfo;
  final String balance;
  final String explanation;
  final bool isDark;

  const FiveElementsCard({
    super.key,
    required this.elements,
    required this.sajuInfo,
    required this.balance,
    required this.explanation,
    required this.isDark,
  });

  /// 오행 전통색 (오방색 기반)
  /// 목(木) - 청색 (동쪽, 봄, 성장)
  /// 화(火) - 적색 (남쪽, 여름, 열정)
  /// 토(土) - 황색 (중앙, 환절기, 안정)
  /// 금(金) - 백색/금색 (서쪽, 가을, 결실)
  /// 수(水) - 흑색/남색 (북쪽, 겨울, 지혜)
  Color _getElementColor(String element) {
    switch (element) {
      case '목(木)':
        return const Color(0xFF2E8B57); // 청록색 (전통 청)
      case '화(火)':
        return const Color(0xFFDC143C); // 진홍색 (전통 적)
      case '토(土)':
        return const Color(0xFFDAA520); // 금황색 (전통 황)
      case '금(金)':
        return const Color(0xFFC0A062); // 금색 (전통 백/금)
      case '수(水)':
        return const Color(0xFF1E3A5F); // 남색 (전통 흑/수)
      default:
        return const Color(0xFF6B7280);
    }
  }

  /// 오행 한자 추출
  String _getHanja(String element) {
    switch (element) {
      case '목(木)': return '木';
      case '화(火)': return '火';
      case '토(土)': return '土';
      case '금(金)': return '金';
      case '수(水)': return '水';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오행 밸런스',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '당신의 오행 에너지 분석',
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black54,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 16),

        // 사주 4주 표시
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _PillarItem(label: '년주', value: sajuInfo['year_pillar'] ?? '○○', isDark: isDark),
              _PillarItem(label: '월주', value: sajuInfo['month_pillar'] ?? '○○', isDark: isDark),
              _PillarItem(label: '일주', value: sajuInfo['day_pillar'] ?? '○○', isDark: isDark),
              _PillarItem(label: '시주', value: sajuInfo['hour_pillar'] ?? '○○', isDark: isDark),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 오행 그래프
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: elements.entries.map((entry) {
              final color = _getElementColor(entry.key);
              final hanja = _getHanja(entry.key);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // 한자 아이콘
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  hanja,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: FontConfig.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              entry.key,
                              style: context.bodySmall.copyWith(
                                color: isDark ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${entry.value}%',
                          style: context.labelSmall.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      children: [
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: entry.value / 100,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ).animate()
                            .scaleX(begin: 0, duration: 800.ms, curve: Curves.easeOutCubic, alignment: Alignment.centerLeft),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 12),

        // 균형 설명
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF2E8B57).withValues(alpha: 0.15), const Color(0xFF1E3A5F).withValues(alpha: 0.15)]
                  : [const Color(0xFF2E8B57).withValues(alpha: 0.08), const Color(0xFF1E3A5F).withValues(alpha: 0.08)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF2E8B57).withValues(alpha: 0.3)
                  : const Color(0xFF2E8B57).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '☯',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '오행 분석',
                    style: context.labelSmall.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                balance,
                style: context.bodySmall.copyWith(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                explanation,
                style: context.bodySmall.copyWith(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PillarItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _PillarItem({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
