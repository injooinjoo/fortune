import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import '../constants/fortune_card_images.dart';

/// 표준화된 운세 상세 섹션 카드
/// 아이콘, 제목, 내용을 포함하는 프리미엄 카드 레이아웃입니다.
class SectionCard extends StatelessWidget {
  final String title;
  final String? sectionKey;
  final Widget child;
  final String? iconPath;
  final VoidCallback? onMorePressed;
  final bool showDivider;

  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.sectionKey,
    this.iconPath,
    this.onMorePressed,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconPath = iconPath ??
        (sectionKey != null
            ? FortuneCardImages.getSectionIcon(sectionKey!)
            : null);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          DSCard.flat(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                Row(
                  children: [
                    if (effectiveIconPath != null) ...[
                      Image.asset(
                        effectiveIconPath,
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.auto_awesome, size: 24),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        style: context.typography.headingSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    if (onMorePressed != null)
                      IconButton(
                        icon: const Icon(Icons.chevron_right, size: 24),
                        onPressed: onMorePressed,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // 내용
                child,
              ],
            ),
          ),
          if (showDivider)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Divider(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
                height: 1,
              ),
            ),
        ],
      ),
    );
  }
}
