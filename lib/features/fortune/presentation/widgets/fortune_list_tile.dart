import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../core/constants/fortune_card_images.dart';
import '../pages/fortune_list_page.dart';
import '../providers/fortune_order_provider.dart';
import '../../../../core/design_system/design_system.dart';

class FortuneListTile extends ConsumerWidget {
  final FortuneCategory category;
  final VoidCallback onTap;

  const FortuneListTile({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final orderState = ref.watch(fortuneOrderProvider);
    final isFavorite = orderState.favorites.contains(category.type);

    return Slidable(
      key: ValueKey(category.type),
      // 왼쪽에서 오른쪽으로 스와이프 (startActionPane)
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25, // 스와이프 영역 비율
        children: [
          // 즐겨찾기 버튼 (아이콘만)
          SlidableAction(
            onPressed: (_) {
              ref.read(fortuneOrderProvider.notifier).toggleFavorite(category.type);
            },
            backgroundColor: isFavorite
                ? DSColors.warning
                : DSColors.accent,
            foregroundColor: Colors.white,
            icon: isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
            borderRadius: BorderRadius.zero,
          ),
        ],
      ),
      child: Container(
        color: colors.surface,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  // ❌ 즐겨찾기 별 아이콘 제거 (요청사항: 구분선만 있으면 됨)
                  // if (isFavorite) ...[
                  //   Icon(
                  //     Icons.star,
                  //     size: 20,
                  //     color: Colors.amber,
                  //   ),
                  //   const SizedBox(width: 8),
                  // ],

                  // 좌측 아이콘 (토스 스타일 원형 배경) + 빨간 dot 배지
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: FortuneCardImages.getGradientColors(category.type),
                          ),
                        ),
                        child: Icon(
                          category.icon,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      // 빨간 dot 배지 (새 운세 OR 오늘 안 본 운세)
                      if (category.shouldShowRedDot)
                        Positioned(
                          top: -3,
                          right: -3,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.surface,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(width: 16),

                  // 중앙 텍스트 영역
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 제목 (NEW 배지 제거 - 아이콘 dot으로 대체)
                        Text(
                          category.title,
                          style: DSTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                            color: colors.textPrimary,
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 2),

                        // 부제목 (설명)
                        Text(
                          category.description,
                          style: DSTypography.bodySmall.copyWith(
                            color: colors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 우측 액션 텍스트 (토스 스타일)
                  Text(
                    category.isFreeFortune
                        ? '포인트 받기'
                        : '${category.soulCost}원 받기',
                    style: DSTypography.bodySmall.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
