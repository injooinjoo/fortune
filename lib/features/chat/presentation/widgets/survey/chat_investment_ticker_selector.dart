import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/design_system/design_system.dart';
import 'package:fortune/core/utils/haptic_utils.dart';
import '../../../../fortune/data/models/investment_ticker.dart';
import '../../../../fortune/presentation/providers/ticker_provider.dart';

/// 채팅 설문용 투자 종목(티커) 선택 위젯
class ChatInvestmentTickerSelector extends ConsumerStatefulWidget {
  final String? category;
  final ValueChanged<InvestmentTicker> onTickerSelected;

  const ChatInvestmentTickerSelector({
    super.key,
    this.category,
    required this.onTickerSelected,
  });

  @override
  ConsumerState<ChatInvestmentTickerSelector> createState() =>
      _ChatInvestmentTickerSelectorState();
}

class _ChatInvestmentTickerSelectorState
    extends ConsumerState<ChatInvestmentTickerSelector> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.category != null) {
        ref.read(tickerProvider.notifier).selectCategory(widget.category!);
      }
    });
  }

  @override
  void didUpdateWidget(covariant ChatInvestmentTickerSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category && widget.category != null) {
      ref.read(tickerProvider.notifier).selectCategory(widget.category!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.trim();
    });

    if (_searchQuery.isNotEmpty) {
      ref.read(tickerProvider.notifier).search(_searchQuery);
    } else if (widget.category != null) {
      ref.read(tickerProvider.notifier).selectCategory(widget.category!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final tickerState = ref.watch(tickerProvider);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(DSRadius.md),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 검색 필드
          _buildSearchField(colors, typography),
          const SizedBox(height: DSSpacing.md),

          // 로딩 상태
          if (tickerState.isLoading)
            _buildLoadingState(colors, typography)
          else ...[
            // 인기 종목
            if (_searchQuery.isEmpty &&
                tickerState.popularTickers.isNotEmpty) ...[
              _buildSectionHeader('인기 종목', colors, typography),
              const SizedBox(height: DSSpacing.sm),
              _buildPopularTickers(
                  tickerState.popularTickers, colors, typography),
              const SizedBox(height: DSSpacing.md),
            ],

            // 종목 리스트 (최대 8개)
            if (tickerState.tickers.isNotEmpty) ...[
              _buildSectionHeader(
                _searchQuery.isEmpty ? '전체 종목' : '검색 결과',
                colors,
                typography,
              ),
              const SizedBox(height: DSSpacing.sm),
              _buildTickerList(
                tickerState.tickers.take(8).toList(),
                colors,
                typography,
              ),
            ] else if (_searchQuery.isNotEmpty)
              _buildEmptyState(colors, typography),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchField(
    DSColorScheme colors,
    DSTypographyScheme typography,
  ) {
    final isDark = context.isDark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? colors.backgroundSecondary : colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.1),
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: typography.bodyMedium.copyWith(color: colors.textPrimary),
        decoration: InputDecoration(
          hintText: '종목명 또는 티커 검색',
          hintStyle: typography.bodyMedium.copyWith(color: colors.textTertiary),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colors.textTertiary,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded, color: colors.textTertiary),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.md,
            vertical: DSSpacing.sm,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    DSColorScheme colors,
    DSTypographyScheme typography,
  ) {
    return Text(
      title,
      style: typography.labelSmall.copyWith(
        color: colors.textTertiary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildPopularTickers(
    List<InvestmentTicker> tickers,
    DSColorScheme colors,
    DSTypographyScheme typography,
  ) {
    return Wrap(
      spacing: DSSpacing.xs,
      runSpacing: DSSpacing.xs,
      children: tickers.take(6).map((ticker) {
        return _TickerChip(
          ticker: ticker,
          colors: colors,
          typography: typography,
          onTap: () {
            HapticUtils.lightImpact();
            widget.onTickerSelected(ticker);
          },
        );
      }).toList(),
    );
  }

  Widget _buildTickerList(
    List<InvestmentTicker> tickers,
    DSColorScheme colors,
    DSTypographyScheme typography,
  ) {
    return Column(
      children: tickers.map((ticker) {
        return _TickerListItem(
          ticker: ticker,
          colors: colors,
          typography: typography,
          onTap: () {
            HapticUtils.lightImpact();
            widget.onTickerSelected(ticker);
          },
        );
      }).toList(),
    );
  }

  Widget _buildLoadingState(
    DSColorScheme colors,
    DSTypographyScheme typography,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DSSpacing.xl),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              '종목을 불러오는 중...',
              style: typography.labelMedium.copyWith(
                color: colors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    DSColorScheme colors,
    DSTypographyScheme typography,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DSSpacing.xl),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 40,
              color: colors.textTertiary,
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              '검색 결과가 없습니다',
              style: typography.labelMedium.copyWith(
                color: colors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 인기 종목 칩 위젯
class _TickerChip extends StatelessWidget {
  final InvestmentTicker ticker;
  final DSColorScheme colors;
  final DSTypographyScheme typography;
  final VoidCallback onTap;

  const _TickerChip({
    required this.ticker,
    required this.colors,
    required this.typography,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.sm,
            vertical: DSSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isDark ? colors.backgroundSecondary : colors.surface,
            borderRadius: BorderRadius.circular(DSRadius.lg),
            border: Border.all(
              color: colors.textPrimary.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ticker.name,
                style: typography.labelMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: DSSpacing.xxs),
              Text(
                ticker.symbol,
                style: typography.labelSmall.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 종목 리스트 아이템 위젯
class _TickerListItem extends StatelessWidget {
  final InvestmentTicker ticker;
  final DSColorScheme colors;
  final DSTypographyScheme typography;
  final VoidCallback onTap;

  const _TickerListItem({
    required this.ticker,
    required this.colors,
    required this.typography,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DSRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.xs,
            vertical: DSSpacing.sm,
          ),
          child: Row(
            children: [
              // 티커 심볼 박스
              Container(
                width: 48,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.textPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DSRadius.xs),
                ),
                alignment: Alignment.center,
                child: Text(
                  ticker.symbol.length > 5
                      ? ticker.symbol.substring(0, 5)
                      : ticker.symbol,
                  style: typography.labelSmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              // 종목명
              Expanded(
                child: Text(
                  ticker.name,
                  style: typography.bodyMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // 화살표
              Icon(
                Icons.chevron_right_rounded,
                color: colors.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
