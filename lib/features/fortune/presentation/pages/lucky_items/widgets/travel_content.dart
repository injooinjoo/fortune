import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import 'info_item.dart';

/// 여행/장소 컨텐츠 - API 데이터 + 나침반 시각화
class TravelContent extends StatelessWidget {
  final List<dynamic>? placesDetail;
  final Map<String, dynamic>? directionDetail;
  final String? directionCompass;

  const TravelContent({
    super.key,
    this.placesDetail,
    this.directionDetail,
    this.directionCompass,
  });

  /// 방향 → 한자 변환
  String _getDirectionHanja(String direction) {
    const hanja = {
      '동': '東',
      '서': '西',
      '남': '南',
      '북': '北',
      '동남': '東南',
      '동북': '東北',
      '서남': '西南',
      '서북': '西北',
    };
    return hanja[direction] ?? '';
  }

  /// 방향 → 각도 (나침반 회전용)
  double _getDirectionAngle(String direction) {
    const angles = {
      '북': 0.0,
      '동북': 45.0,
      '동': 90.0,
      '동남': 135.0,
      '남': 180.0,
      '서남': 225.0,
      '서': 270.0,
      '서북': 315.0,
    };
    return angles[direction] ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // 방향 데이터
    final direction = directionCompass ?? directionDetail?['direction'] ?? '동남';
    final directionReason =
        directionDetail?['reason'] ?? '木 기운이 강한 방향으로 행운의 기운이 모입니다';
    final hanja = _getDirectionHanja(direction);
    final angle = _getDirectionAngle(direction);

    // 장소 데이터 (API에서 최대 3개)
    final places = (placesDetail ?? []).take(3).toList();

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
          // 나침반 시각화 섹션
          _buildCompassSection(context, direction, hanja, angle, colors),
          const SizedBox(height: 16),

          // 방향 설명
          InfoItem(label: '행운의 방향', value: '$direction ($hanja)'),
          InfoItem(label: '방향 해석', value: directionReason),

          const SizedBox(height: 16),
          Divider(color: colors.border),
          const SizedBox(height: 16),

          // 추천 장소들
          Text(
            '오늘의 추천 장소',
            style: DSTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          if (places.isNotEmpty)
            ...places.map((place) => _buildPlaceItem(context, place, colors))
          else ...[
            const InfoItem(label: '데이트 장소', value: '한강공원 산책로'),
            const InfoItem(label: '드라이브', value: '북한산 둘레길'),
            const InfoItem(label: '산책 장소', value: '남산 타워 주변'),
          ],
        ],
      ),
    );
  }

  /// 나침반 시각화 위젯
  Widget _buildCompassSection(
    BuildContext context,
    String direction,
    String hanja,
    double angle,
    DSColorScheme colors,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 나침반 원형
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colors.accent, width: 3),
              color: colors.surface,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 방위 표시 (고정)
                Positioned(
                    top: 8,
                    child: Text('北',
                        style: DSTypography.bodySmall
                            .copyWith(color: colors.textSecondary))),
                Positioned(
                    bottom: 8,
                    child: Text('南',
                        style: DSTypography.bodySmall
                            .copyWith(color: colors.textSecondary))),
                Positioned(
                    left: 8,
                    child: Text('西',
                        style: DSTypography.bodySmall
                            .copyWith(color: colors.textSecondary))),
                Positioned(
                    right: 8,
                    child: Text('東',
                        style: DSTypography.bodySmall
                            .copyWith(color: colors.textSecondary))),

                // 방향 화살표 (회전)
                Transform.rotate(
                  angle: angle * 3.14159 / 180,
                  child: Icon(
                    Icons.navigation,
                    size: 48,
                    color: colors.accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$direction $hanja',
            style: DSTypography.headingSmall.copyWith(
              color: colors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// 장소 아이템 위젯
  Widget _buildPlaceItem(
    BuildContext context,
    dynamic place,
    DSColorScheme colors,
  ) {
    if (place is Map<String, dynamic>) {
      final placeName = place['place'] ?? '추천 장소';
      final category = place['category'] ?? '';
      final reason = place['reason'] ?? '';
      final timing = place['timing'] ?? '';

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.place, size: 16, color: colors.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    placeName,
                    style: DSTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (category.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      category,
                      style:
                          DSTypography.bodySmall.copyWith(color: colors.accent),
                    ),
                  ),
              ],
            ),
            if (reason.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                reason,
                style:
                    DSTypography.bodySmall.copyWith(color: colors.textSecondary),
              ),
            ],
            if (timing.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 12, color: colors.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    timing,
                    style: DSTypography.bodySmall
                        .copyWith(color: colors.textTertiary),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    }

    // 문자열인 경우 간단히 표시
    return InfoItem(label: '장소', value: place.toString());
  }
}
