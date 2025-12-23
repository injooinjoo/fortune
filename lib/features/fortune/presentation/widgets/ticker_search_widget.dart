import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/design_system.dart';
import '../../data/models/investment_ticker.dart';
import '../providers/ticker_provider.dart';
import 'ticker_list_item.dart';

/// ChatGPT 스타일의 종목 검색 및 선택 위젯
/// API로 티커 데이터 로드, 실패 시 정적 데이터 fallback
class TickerSearchWidget extends ConsumerStatefulWidget {
  final String category;
  final InvestmentTicker? selectedTicker;
  final ValueChanged<InvestmentTicker> onTickerSelected;

  const TickerSearchWidget({
    super.key,
    required this.category,
    required this.selectedTicker,
    required this.onTickerSelected,
  });

  @override
  ConsumerState<TickerSearchWidget> createState() => _TickerSearchWidgetState();
}

class _TickerSearchWidgetState extends ConsumerState<TickerSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // 카테고리 선택 및 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tickerProvider.notifier).selectCategory(widget.category);
    });
  }

  @override
  void didUpdateWidget(covariant TickerSearchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 카테고리 변경 시 다시 로드
    if (oldWidget.category != widget.category) {
      ref.read(tickerProvider.notifier).selectCategory(widget.category);
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
    } else {
      ref.read(tickerProvider.notifier).selectCategory(widget.category);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final category = InvestmentCategory.fromCode(widget.category);
    final tickerState = ref.watch(tickerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${category.label} 종목 선택',
                style: DSTypography.headingSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? DSColors.textPrimary
                      : DSColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '운세를 확인할 종목을 선택해주세요',
                style: DSTypography.bodySmall.copyWith(
                  color: isDark
                      ? DSColors.textTertiary
                      : DSColors.textTertiary,
                ),
              ),
            ],
          ),
        ),

        // 검색 필드
        _buildSearchField(isDark),

        const SizedBox(height: 24),

        // 로딩 상태
        if (tickerState.isLoading)
          _buildLoadingState(isDark)
        else ...[
          // 인기 종목 또는 검색 결과
          if (_searchQuery.isEmpty && tickerState.popularTickers.isNotEmpty) ...[
            _buildSectionHeader('인기 종목', isDark),
            const SizedBox(height: 12),
            _buildPopularTickers(tickerState.popularTickers),
            const SizedBox(height: 24),
            _buildSectionHeader('전체 종목', isDark),
            const SizedBox(height: 12),
          ],

          // 종목 리스트
          _buildTickerList(tickerState.tickers),
        ],
      ],
    );
  }

  Widget _buildSearchField(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? DSColors.surface : DSColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: DSTypography.bodyMedium.copyWith(
          color: isDark
              ? DSColors.textPrimary
              : DSColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: '종목명 또는 티커 검색',
          hintStyle: DSTypography.bodyMedium.copyWith(
            color: isDark
                ? DSColors.textTertiary
                : DSColors.textTertiary,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark
                ? DSColors.textTertiary
                : DSColors.textTertiary,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark
                        ? DSColors.textTertiary
                        : DSColors.textTertiary,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: DSTypography.labelMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
      ),
    );
  }

  Widget _buildPopularTickers(List<InvestmentTicker> popularTickers) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: popularTickers.map((ticker) {
        final isSelected = widget.selectedTicker?.symbol == ticker.symbol;

        return GestureDetector(
          onTap: () => widget.onTickerSelected(ticker),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? DSColors.accent
                  : (isDark ? DSColors.surface : Colors.white),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? DSColors.accent
                    : (isDark
                        ? DSColors.border
                        : DSColors.border),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ticker.name,
                  style: DSTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? DSColors.textPrimary
                            : DSColors.textPrimary),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  ticker.symbol,
                  style: DSTypography.labelSmall.copyWith(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.8)
                        : (isDark
                            ? DSColors.textTertiary
                            : DSColors.textTertiary),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTickerList(List<InvestmentTicker> tickers) {
    if (tickers.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tickers.length,
      itemBuilder: (context, index) {
        final ticker = tickers[index];
        final isSelected = widget.selectedTicker?.symbol == ticker.symbol;

        return TickerListItem(
          ticker: ticker,
          isSelected: isSelected,
          onTap: () => widget.onTickerSelected(ticker),
        );
      },
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: DSColors.accent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '종목을 불러오는 중...',
              style: DSTypography.bodyMedium.copyWith(
                color: isDark
                    ? DSColors.textTertiary
                    : DSColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: isDark
                  ? DSColors.textTertiary
                  : DSColors.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              '검색 결과가 없습니다',
              style: DSTypography.bodyMedium.copyWith(
                color: isDark
                    ? DSColors.textTertiary
                    : DSColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
