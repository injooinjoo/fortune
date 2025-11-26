import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
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
        ? (isDark ? TossDesignSystem.tossBlue.withValues(alpha: 0.15) : TossDesignSystem.tossBlue.withValues(alpha: 0.08))
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
                    style: TypographyUnified.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _buildSubtitle(),
                    style: TypographyUnified.labelSmall.copyWith(
                      color: isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray500,
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
                  color: TossDesignSystem.tossBlue,
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
    final bgColor = isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray100;
    final textColor = isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700;

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
          style: TypographyUnified.labelMedium.copyWith(
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
