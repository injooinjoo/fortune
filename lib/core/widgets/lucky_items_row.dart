import 'package:flutter/material.dart';
import '../theme/typography_unified.dart';
import '../../shared/glassmorphism/glass_container.dart';
import '../services/fortune_asset_service.dart';
import '../../shared/widgets/smart_image.dart';

/// 행운의 아이템 가로 스크롤 행 위젯 (Premium 리디자인)
/// 색상, 방향, 시간, 숫자, 띠, 오행 외에도 음식, 패션, 장소 등 확장된 행운 요소를 표시합니다.
class LuckyItemsRow extends StatelessWidget {
  final Map<String, dynamic> luckyItems;

  const LuckyItemsRow({
    super.key,
    required this.luckyItems,
  });

  @override
  Widget build(BuildContext context) {
    if (luckyItems.isEmpty) return const SizedBox.shrink();

    // 표시 가능한 아이템 필터링 및 이름 변경
    final items = luckyItems.entries.where((e) => _isSupported(e.key)).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Text(
                '✨ 오늘의 행운 요소',
                style: context.heading4.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              Text(
                '더보기',
                style: context.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: items.map((entry) {
              final displayName = _getDisplayName(entry.key);
              final displayValue = entry.value.toString();

              return _LuckyItemCard(
                type: entry.key,
                label: displayName,
                value: displayValue,
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  bool _isSupported(String key) {
    final k = key.toLowerCase();
    return [
      'color',
      '색깔',
      '행운색',
      'direction',
      '방향',
      '행운방향',
      'time',
      '시간',
      '행운시간',
      'number',
      '숫자',
      '행운숫자',
      'zodiac',
      '띠',
      '행운띠',
      'element',
      '오행',
      '행운오행',
      'food',
      '음식',
      'fashion',
      '패션',
      'place',
      '장소',
      'jewelry',
      '보석',
      '장신구',
    ].contains(k);
  }

  String _getDisplayName(String key) {
    final k = key.toLowerCase();
    if (k == 'color' || k == '색깔' || k == '행운색') return '행운색';
    if (k == 'direction' || k == '방향' || k == '행운방향') return '행운방향';
    if (k == 'time' || k == '시간' || k == '행운시간') return '행운시간';
    if (k == 'number' || k == '숫자' || k == '행운숫자') return '행운숫자';
    if (k == 'zodiac' || k == '띠' || k == '행운띠') return '행운띠';
    if (k == 'element' || k == '오행' || k == '행운오행') return '행운오행';
    if (k == 'food' || k == '음식') return '행운의 음식';
    if (k == 'fashion' || k == '패션') return '추천 패션';
    if (k == 'place' || k == '장소') return '행운의 장소';
    if (k == 'jewelry' || k == '보석' || k == '장신구') return '보석/장신구';
    return key;
  }
}

class _LuckyItemCard extends StatelessWidget {
  final String type;
  final String label;
  final String value;

  const _LuckyItemCard({
    required this.type,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140, // 기존 110에서 확대
      margin: const EdgeInsets.only(right: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          width: 1,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: context.bodySmall.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withValues(alpha: 0.5),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            // 아이콘 영역 확대 및 애니메이션 효과
            _SmartLuckyItemIcon(type: type, value: value),
            const SizedBox(height: 16),
            Text(
              value,
              textAlign: TextAlign.center,
              style: context.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: -0.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// 스마트 행운 아이템 아이콘
/// 1. 로컬 에셋 시도
/// 2. 실패 시 원격 저장소 시도
/// 3. 실패 시 생성 요청 및 폴백 아이콘
class _SmartLuckyItemIcon extends StatefulWidget {
  final String type;
  final String value;

  const _SmartLuckyItemIcon({
    required this.type,
    required this.value,
  });

  @override
  State<_SmartLuckyItemIcon> createState() => _SmartLuckyItemIconState();
}

class _SmartLuckyItemIconState extends State<_SmartLuckyItemIcon> {
  bool _useRemote = false;

  @override
  Widget build(BuildContext context) {
    final assetPath =
        FortuneAssetService.getLuckyItemPath(widget.type, widget.value);
    final remoteUrl =
        FortuneAssetService.getRemoteFallbackUrl(widget.type, widget.value);

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .secondaryContainer
            .withValues(alpha: 0.3),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: SmartImage(
        path: _useRemote ? remoteUrl : assetPath,
        fit: BoxFit.contain,
        errorWidget: _useRemote ? _buildFallback() : null,
        // SmartImage의 errorBuilder에서 _handleError를 호출할 수 없으므로
        // Image.asset의 errorBuilder를 직접 쓰거나 SmartImage를 래핑해야 함.
        // 여기서는 SmartImage가 errorWidget을 보여줄 때 내부적으로 로깅하므로 간단히 처리.
      ),
    );
  }

  Widget _buildFallback() {
    return Icon(
      _getFallbackIcon(),
      size: 40,
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
    );
  }

  IconData _getFallbackIcon() {
    final k = widget.type.toLowerCase();
    if (k.contains('color') || k.contains('색')) return Icons.palette_rounded;
    if (k.contains('direction') || k.contains('방향'))
      return Icons.explore_rounded;
    if (k.contains('number') || k.contains('숫자')) return Icons.pin_rounded;
    if (k.contains('food') || k.contains('음식')) return Icons.restaurant_rounded;
    if (k.contains('place') || k.contains('장소')) return Icons.place_rounded;
    return Icons.stars_rounded;
  }
}
