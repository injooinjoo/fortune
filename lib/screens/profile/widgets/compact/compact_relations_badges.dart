import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';

/// 압축된 합충형해 배지
///
/// 사주 내 합충형해 관계를 색상 구분 배지로 표시합니다.
class CompactRelationsBadges extends StatelessWidget {
  final Map<String, dynamic> sajuData;

  const CompactRelationsBadges({
    super.key,
    required this.sajuData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final relations = _extractRelations();

    if (relations.isEmpty) {
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
                Icons.link_rounded,
                size: 14,
                color: context.colors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '합충형해',
                style: context.labelTiny.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '合沖刑破害',
                style: context.labelTiny.copyWith(
                  fontSize: 9,
                  color: context.colors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.xs),
          // 배지들
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: relations.map((relation) {
              return _buildRelationBadge(context, relation, isDark);
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _extractRelations() {
    final List<Map<String, dynamic>> relations = [];

    // sajuData에서 relations 정보 추출
    final relationsData = sajuData['relations'] as Map<String, dynamic>?;
    if (relationsData == null) return relations;

    // 합(合) 관계
    final haps = relationsData['합'] as List<dynamic>?;
    if (haps != null) {
      for (final hap in haps) {
        relations.add({
          'type': '합',
          'hanja': '合',
          'description': hap.toString(),
          'color': DSColors.success, // 초록 - 조화
        });
      }
    }

    // 충(沖) 관계
    final chungs = relationsData['충'] as List<dynamic>?;
    if (chungs != null) {
      for (final chung in chungs) {
        relations.add({
          'type': '충',
          'hanja': '沖',
          'description': chung.toString(),
          'color': DSColors.error, // 빨강 - 충돌
        });
      }
    }

    // 형(刑) 관계
    final hyungs = relationsData['형'] as List<dynamic>?;
    if (hyungs != null) {
      for (final hyung in hyungs) {
        relations.add({
          'type': '형',
          'hanja': '刑',
          'description': hyung.toString(),
          'color': DSColors.warning, // 주황 - 형벌
        });
      }
    }

    // 파(破) 관계
    final pas = relationsData['파'] as List<dynamic>?;
    if (pas != null) {
      for (final pa in pas) {
        relations.add({
          'type': '파',
          'hanja': '破',
          'description': pa.toString(),
          'color': DSColors.accentSecondary, // 보라 - 파괴
        });
      }
    }

    // 해(害) 관계
    final haes = relationsData['해'] as List<dynamic>?;
    if (haes != null) {
      for (final hae in haes) {
        relations.add({
          'type': '해',
          'hanja': '害',
          'description': hae.toString(),
          'color': DSColors.info, // 인디고 - 해침
        });
      }
    }

    return relations;
  }

  Widget _buildRelationBadge(
      BuildContext context, Map<String, dynamic> relation, bool isDark) {
    final color = relation['color'] as Color;
    final type = relation['type'] as String;
    final hanja = relation['hanja'] as String;
    final description = relation['description'] as String;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 한자 표시
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                hanja,
                style: context.labelTiny.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // 설명
          Text(
            '$type: $description',
            style: context.labelTiny.copyWith(
              fontWeight: FontWeight.w500,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
