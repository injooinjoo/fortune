import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';

/// 압축된 신살 요약
///
/// 길신과 흉신을 분류하여 배지 형태로 표시합니다.
class CompactSinsalSummary extends StatelessWidget {
  final Map<String, dynamic> sajuData;

  const CompactSinsalSummary({
    super.key,
    required this.sajuData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final sinsalData = _extractSinsal();

    if (sinsalData['gilsin']!.isEmpty && sinsalData['hyungsin']!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color:
            isDark ? context.colors.backgroundSecondary : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(DSRadius.sm),
        border: Border.all(
          color: isDark ? DSColors.border : DSColors.borderDark,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Icon(
                Icons.stars_rounded,
                size: 14,
                color: context.colors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '신살',
                style: context.labelTiny.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '神煞 · 길흉성',
                style: context.labelTiny.copyWith(
                  fontSize: 9,
                  color: context.colors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.xs),

          // 길신 섹션
          if (sinsalData['gilsin']!.isNotEmpty) ...[
            _buildSinsalSection(
              context: context,
              title: '길신',
              hanja: '吉神',
              sinsals: sinsalData['gilsin']!,
              color: DSColors.success,
              isDark: isDark,
            ),
            const SizedBox(height: 6),
          ],

          // 흉신 섹션
          if (sinsalData['hyungsin']!.isNotEmpty)
            _buildSinsalSection(
              context: context,
              title: '흉신',
              hanja: '凶神',
              sinsals: sinsalData['hyungsin']!,
              color: DSColors.error,
              isDark: isDark,
            ),
        ],
      ),
    );
  }

  Map<String, List<Map<String, String>>> _extractSinsal() {
    final gilsinList = <Map<String, String>>[];
    final hyungsinList = <Map<String, String>>[];

    final sinsalData = sajuData['sinsal'] as Map<String, dynamic>?;
    if (sinsalData == null) {
      return {'gilsin': gilsinList, 'hyungsin': hyungsinList};
    }

    // 길신 데이터 추출
    final gilsin = sinsalData['gilsin'] as List<dynamic>?;
    if (gilsin != null) {
      for (final item in gilsin) {
        if (item is Map<String, dynamic>) {
          gilsinList.add({
            'name': item['name']?.toString() ?? '',
            'hanja': item['hanja']?.toString() ?? '',
            'description': item['description']?.toString() ?? '',
          });
        } else if (item is String) {
          final info = _getSinsalInfo(item);
          gilsinList.add(info);
        }
      }
    }

    // 흉신 데이터 추출
    final hyungsin = sinsalData['hyungsin'] as List<dynamic>?;
    if (hyungsin != null) {
      for (final item in hyungsin) {
        if (item is Map<String, dynamic>) {
          hyungsinList.add({
            'name': item['name']?.toString() ?? '',
            'hanja': item['hanja']?.toString() ?? '',
            'description': item['description']?.toString() ?? '',
          });
        } else if (item is String) {
          final info = _getSinsalInfo(item);
          hyungsinList.add(info);
        }
      }
    }

    return {'gilsin': gilsinList, 'hyungsin': hyungsinList};
  }

  Map<String, String> _getSinsalInfo(String name) {
    // 주요 신살 한자 및 설명
    const sinsalMap = {
      '천을귀인': {'hanja': '天乙貴人', 'description': '귀인의 도움'},
      '문창귀인': {'hanja': '文昌貴人', 'description': '학업/문서운'},
      '천덕귀인': {'hanja': '天德貴人', 'description': '하늘의 덕'},
      '월덕귀인': {'hanja': '月德貴人', 'description': '달의 덕'},
      '금여록': {'hanja': '金輿祿', 'description': '물질적 풍요'},
      '역마': {'hanja': '驛馬', 'description': '이동/변화'},
      '화개': {'hanja': '華蓋', 'description': '예술/종교'},
      '도화': {'hanja': '桃花', 'description': '인기/매력'},
      '장성': {'hanja': '將星', 'description': '리더십'},
      '학당': {'hanja': '學堂', 'description': '학문'},
      '양인': {'hanja': '羊刃', 'description': '날카로움/결단'},
      '겁살': {'hanja': '劫煞', 'description': '손재수'},
      '재살': {'hanja': '災煞', 'description': '재난/사고'},
      '천살': {'hanja': '天煞', 'description': '천재지변'},
      '망신': {'hanja': '亡神', 'description': '명예손상'},
      '백호': {'hanja': '白虎', 'description': '피해/상해'},
      '공망': {'hanja': '空亡', 'description': '허무/공허'},
      '원진': {'hanja': '怨嗔', 'description': '원한/미움'},
      '귀문관': {'hanja': '鬼門關', 'description': '귀신/초자연'},
    };

    final info = sinsalMap[name];
    if (info != null) {
      return {
        'name': name,
        'hanja': info['hanja']!,
        'description': info['description']!,
      };
    }

    return {
      'name': name,
      'hanja': '',
      'description': '',
    };
  }

  Widget _buildSinsalSection({
    required BuildContext context,
    required String title,
    required String hanja,
    required List<Map<String, String>> sinsals,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 라벨
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hanja,
                    style: context.labelTiny.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    title,
                    style: context.labelTiny.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${sinsals.length}개',
              style: context.labelTiny.copyWith(
                fontSize: 9,
                color: context.colors.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // 신살 배지들
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: sinsals.map((sinsal) {
            return _buildSinsalBadge(context, sinsal, color, isDark);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSinsalBadge(
    BuildContext context,
    Map<String, String> sinsal,
    Color color,
    bool isDark,
  ) {
    final name = sinsal['name'] ?? '';
    final hanja = sinsal['hanja'] ?? '';
    final description = sinsal['description'] ?? '';

    return Tooltip(
      message: description.isNotEmpty ? description : name,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: isDark
              ? context.colors.surface.withValues(alpha: 0.08)
              : context.colors.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hanja.isNotEmpty) ...[
              Text(
                hanja.length > 2 ? hanja.substring(0, 2) : hanja,
                style: context.labelTiny.copyWith(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: color.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: 3),
            ],
            Text(
              name,
              style: context.labelTiny.copyWith(
                fontWeight: FontWeight.w500,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
