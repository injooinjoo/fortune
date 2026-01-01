import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import 'info_item.dart';

/// 패션/뷰티 컨텐츠 - API 데이터 사용 (오행 기반)
class FashionContent extends StatelessWidget {
  final Map<String, dynamic>? fashionDetail;
  final Map<String, dynamic>? colorDetail;
  final Map<String, dynamic>? jewelryDetail;

  const FashionContent({
    super.key,
    this.fashionDetail,
    this.colorDetail,
    this.jewelryDetail,
  });

  /// 색상 코드 파싱
  Color _parseColor(String? colorCode) {
    if (colorCode == null || colorCode.isEmpty) return Colors.grey;
    try {
      if (colorCode.startsWith('#')) {
        return Color(int.parse(colorCode.substring(1), radix: 16) + 0xFF000000);
      }
    } catch (_) {}
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // 패션 데이터
    final style = fashionDetail?['style'] ?? '캐주얼 시크';
    final styleDescription = fashionDetail?['styleDescription'] ?? '';
    final top = fashionDetail?['top'] ?? '흰색 셔츠';
    final bottom = fashionDetail?['bottom'] ?? '네이비 슬랙스';
    final outer = fashionDetail?['outer'];
    final shoes = fashionDetail?['shoes'] ?? '깔끔한 로퍼';

    // 색상 데이터
    final mainColorName = colorDetail?['mainColor'] ?? '네이비';
    final mainColorCode = colorDetail?['mainColorCode'];
    final subColorName = colorDetail?['subColor'] ?? '화이트';
    final subColorCode = colorDetail?['subColorCode'];
    final pointColorName = colorDetail?['pointColor'];
    final colorTone = colorDetail?['colorTone'] ?? '쿨톤';
    final colorReason = colorDetail?['colorReason'] ?? '';

    // 액세서리 데이터
    final metalTone = jewelryDetail?['metalTone'] ?? '실버';
    final earrings = jewelryDetail?['earrings'] ?? '미니멀 귀걸이';
    final necklace = jewelryDetail?['necklace'];
    final bracelet = jewelryDetail?['bracelet'];
    final ring = jewelryDetail?['ring'];

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 스타일 추천 섹션
          _buildSectionTitle(context, '오늘의 스타일', colors),
          const SizedBox(height: 12),
          InfoItem(label: '추천 스타일', value: style),
          if (styleDescription.isNotEmpty)
            InfoItem(label: '스타일 해석', value: styleDescription),

          const SizedBox(height: 16),

          // 아이템 추천
          _buildSectionTitle(context, '추천 아이템', colors),
          const SizedBox(height: 12),
          InfoItem(label: '상의', value: top),
          InfoItem(label: '하의', value: bottom),
          if (outer != null) InfoItem(label: '아우터', value: outer),
          InfoItem(label: '신발', value: shoes),

          const SizedBox(height: 16),
          Divider(color: colors.border),
          const SizedBox(height: 16),

          // 색상 분석 섹션
          _buildSectionTitle(context, '오늘의 컬러', colors),
          const SizedBox(height: 12),
          _buildColorChips(
            context,
            mainColorName,
            mainColorCode,
            subColorName,
            subColorCode,
            pointColorName,
            colors,
          ),
          const SizedBox(height: 12),
          InfoItem(label: '컬러톤', value: colorTone),
          if (colorReason.isNotEmpty)
            InfoItem(label: '컬러 해석', value: colorReason),

          const SizedBox(height: 16),
          Divider(color: colors.border),
          const SizedBox(height: 16),

          // 액세서리 추천 섹션
          _buildSectionTitle(context, '액세서리', colors),
          const SizedBox(height: 12),
          InfoItem(label: '메탈 톤', value: '$metalTone 톤'),
          InfoItem(label: '귀걸이', value: earrings),
          if (necklace != null) InfoItem(label: '목걸이', value: necklace),
          if (bracelet != null) InfoItem(label: '팔찌', value: bracelet),
          if (ring != null) InfoItem(label: '반지', value: ring),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      BuildContext context, String title, DSColorScheme colors) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: colors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: DSTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildColorChips(
    BuildContext context,
    String mainColorName,
    String? mainColorCode,
    String subColorName,
    String? subColorCode,
    String? pointColorName,
    DSColorScheme dsColors,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildColorChip(
            context, '메인', mainColorName, _parseColor(mainColorCode)),
        _buildColorChip(
            context, '서브', subColorName, _parseColor(subColorCode)),
        if (pointColorName != null)
          _buildColorChip(context, '포인트', pointColorName, dsColors.accent),
      ],
    );
  }

  Widget _buildColorChip(
    BuildContext context,
    String label,
    String colorName,
    Color color,
  ) {
    final textColor =
        color.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: $colorName',
            style: DSTypography.bodySmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
