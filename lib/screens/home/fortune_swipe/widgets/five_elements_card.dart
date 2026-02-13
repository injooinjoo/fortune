import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/theme/font_config.dart';

/// 🌊 오행 밸런스 카드
class FiveElementsCard extends StatelessWidget {
  final Map<String, int> elements;
  final Map<String, String?> sajuInfo;
  final String balance;
  final String explanation;

  const FiveElementsCard({
    super.key,
    required this.elements,
    required this.sajuInfo,
    required this.balance,
    required this.explanation,
  });

  /// 오행 색상
  /// 목(木) - 청색 (동쪽, 봄, 성장)
  /// 화(火) - 적색 (남쪽, 여름, 열정)
  /// 토(土) - 황색 (중앙, 환절기, 안정)
  /// 금(金) - 백색/금색 (서쪽, 가을, 결실)
  /// 수(水) - 흑색/남색 (북쪽, 겨울, 지혜)
  Color _getElementColor(String element) {
    switch (element) {
      case '목(木)':
        return DSColors.success; // 청록
      case '화(火)':
        return DSColors.error; // 진홍
      case '토(土)':
        return DSColors.warning; // 금황
      case '금(金)':
        return DSColors.accentSecondary; // 금색
      case '수(水)':
        return DSColors.info; // 남색
      default:
        return DSColors.textSecondary; // 기본 회색
    }
  }

  /// 오행 한자 추출
  String _getHanja(String element) {
    switch (element) {
      case '목(木)':
        return '木';
      case '화(火)':
        return '火';
      case '토(土)':
        return '土';
      case '금(金)':
        return '金';
      case '수(水)':
        return '水';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오행 밸런스',
          style: context.heading3.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '당신의 오행 에너지 분석',
          style: context.labelSmall.copyWith(
            color: context.colors.textTertiary,
          ),
        ),

        const SizedBox(height: 16),

        // 사주 4주 표시
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.colors.border,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _PillarItem(label: '년주', value: sajuInfo['year_pillar'] ?? '○○'),
              _PillarItem(label: '월주', value: sajuInfo['month_pillar'] ?? '○○'),
              _PillarItem(label: '일주', value: sajuInfo['day_pillar'] ?? '○○'),
              _PillarItem(label: '시주', value: sajuInfo['hour_pillar'] ?? '○○'),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 오행 그래프
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.colors.border,
              width: 1,
            ),
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
                                color: context.colors.textPrimary,
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
                            color: context.colors.border,
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
                          ).animate().scaleX(
                              begin: 0,
                              duration: 800.ms,
                              curve: Curves.easeOutCubic,
                              alignment: Alignment.centerLeft),
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
              colors: context.isDark
                  ? [
                      DSColors.success.withValues(alpha: 0.15),
                      DSColors.info.withValues(alpha: 0.15)
                    ]
                  : [
                      DSColors.success.withValues(alpha: 0.08),
                      DSColors.info.withValues(alpha: 0.08)
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.isDark
                  ? DSColors.success.withValues(alpha: 0.3)
                  : DSColors.success.withValues(alpha: 0.2),
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
                      color: context.colors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '오행 분석',
                    style: context.labelSmall.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                balance,
                style: context.bodySmall.copyWith(
                  color: context.colors.textPrimary.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                explanation,
                style: context.labelTiny.copyWith(
                  color: context.colors.textSecondary,
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

  const _PillarItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: context.labelTiny.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: context.bodySmall.copyWith(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
