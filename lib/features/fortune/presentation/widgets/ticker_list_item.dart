import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/design_system/design_system.dart';
import '../../data/models/investment_ticker.dart';

/// ChatGPT 스타일의 종목 리스트 아이템
class TickerListItem extends StatelessWidget {
  final InvestmentTicker ticker;
  final bool isSelected;
  final VoidCallback onTap;

  const TickerListItem({
    super.key,
    required this.ticker,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isSelected
        ? (isDark ? DSColors.accent.withValues(alpha: 0.15) : DSColors.accent.withValues(alpha: 0.08))
        : Colors.transparent;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // 종목 아이콘
            _buildTickerIcon(isDark),
            const SizedBox(width: 14),

            // 종목 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticker.name,
                    style: DSTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _buildSubtitle(),
                    style: DSTypography.labelSmall.copyWith(
                      color: isDark ? DSColors.textTertiary : DSColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // 선택 체크마크
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: DSColors.accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTickerIcon(bool isDark) {
    final bgColor = isDark ? DSColors.border : DSColors.backgroundSecondary;
    final textColor = isDark ? DSColors.textSecondary : DSColors.textSecondary;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          ticker.symbol.length > 3 ? ticker.symbol.substring(0, 2) : ticker.symbol,
          style: DSTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }

  String _buildSubtitle() {
    final parts = <String>[];
    parts.add(ticker.symbol);
    if (ticker.exchange != null) {
      parts.add(ticker.exchange!);
    }
    return parts.join(' · ');
  }
}
