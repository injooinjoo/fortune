import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../shared/components/app_header.dart';
import '../../shared/components/bottom_navigation_bar.dart';
import '../../shared/glassmorphism/glass_container.dart';
import '../../shared/glassmorphism/glass_effects.dart';
import '../../presentation/providers/token_provider.dart';
import '../../domain/entities/token.dart';
import '../../shared/components/loading_states.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_animations.dart';

class TokenHistoryPage extends ConsumerStatefulWidget {
  const TokenHistoryPage({Key? key}) : super(key: key);

  @override
  ConsumerState<TokenHistoryPage> createState() => _TokenHistoryPageState();
}

class _TokenHistoryPageState extends ConsumerState<TokenHistoryPage> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  String _selectedFilter = 'all'; // all, purchase, usage, bonus, refund
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppAnimations.durationXLong);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn)));
    _animationController.forward();
    
    // Load token history
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tokenProvider.notifier).loadTokenHistory();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokenState = ref.watch(tokenProvider);
    final history = _filterTransactions(tokenState.history);

    return Scaffold(
      appBar: const AppHeader(
        title: '영혼 사용 내역',
        showShareButton: false,
        showFontSizeSelector: false,
        showTokenBalance: true),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: isDark
                ? [
                    const Color(0xFF1E293B),
                    const Color(0xFF0F172A)]
                : [
                    Colors.amber.withOpacity(0.08),
                    AppColors.textPrimaryDark])),
        child: SafeArea(
          child: Column(
            children: [
              // Filter Chips
              _buildFilterChips(theme),
              
              // Transaction List
              Expanded(
                child: tokenState.isLoading && tokenState.history.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : history.isEmpty
                        ? _buildEmptyState(theme)
                        : RefreshIndicator(
                            onRefresh: () async {
                              await ref.read(tokenProvider.notifier).loadTokenHistory();
                            },
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: _buildTransactionList(history, theme, isDark))]),
      bottomNavigationBar: const FortuneBottomNavigationBar(
        currentIndex: -1));
  }

  Widget _buildFilterChips(ThemeData theme) {
    final filters = {
      'all': '전체',
      'purchase': '구매',
      'usage': '사용',
      'bonus': '보너스',
      'refund': '환불'};

    return Container(
      height: AppSpacing.spacing15,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing4, 
        vertical: AppSpacing.spacing3),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: filters.entries.map((entry) {
          final isSelected = _selectedFilter == entry.key;
          
          return Padding(
            padding: const EdgeInsets.only(
              right: AppSpacing.xSmall),
            child: FilterChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = entry.key;
                });
              },
              backgroundColor: Colors.transparent,
              selectedColor: theme.colorScheme.primary.withOpacity(0.2),
              checkmarkColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
              side: BorderSide(
                color: isSelected 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.onSurface.withOpacity(0.3)));
        }).toList()));
  }

  Widget _buildTransactionList(List<TokenTransaction> transactions, ThemeData theme, bool isDark) {
    // Group transactions by date
    final groupedTransactions = _groupTransactionsByDate(transactions);
    
    return ListView.builder(
      padding: AppSpacing.paddingHorizontal16,
      itemCount: groupedTransactions.length,
        itemBuilder: (context, index) {
        final group = groupedTransactions[index];
        final dateLabel = group['label'] as String;
        final dateTransactions = group['transactions'] as List<TokenTransaction>;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            // Date Header
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: AppSpacing.spacing3),
              child: Text(
                dateLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.bold)),
            
            // Transactions for this date
            ...dateTransactions.map((transaction) => _buildTransactionItem(
              transaction,
              theme,
              isDark)).toList()]);
      });
  }

  Widget _buildTransactionItem(TokenTransaction transaction, ThemeData theme, bool isDark) {
    final isAddition = transaction.amount > 0;
    final icon = _getTransactionIcon(transaction.type);
    final color = _getTransactionColor(transaction.type, isAddition);
    
    return Container(
      margin: const EdgeInsets.only(
        bottom: AppSpacing.xSmall),
      child: GlassContainer(
        padding: AppSpacing.paddingAll16,
        borderRadius: AppDimensions.borderRadiusLarge,
        blur: 20,
        child: Row(
          children: [
            // Icon
            Container(
              width: AppDimensions.buttonHeightMedium,
              height: AppDimensions.buttonHeightMedium,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle),
              child: Icon(
                icon,
                color: color,
                size: AppDimensions.iconSizeMedium)),
            SizedBox(width: AppSpacing.spacing4),
            
            // Transaction Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTransactionTitle(transaction),
                    style: theme.textTheme.titleMedium),
                  SizedBox(height: AppSpacing.spacing1),
                  Text(
                    DateFormat('HH:mm').format(transaction.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6))]),
            
            // Amount and Balance
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isAddition ? '+' : ''}${transaction.amount}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold)),
                if (transaction.balanceAfter != null) ...[
                  SizedBox(height: AppSpacing.spacing1),
                  Text(
                    '잔액: ${transaction.balanceAfter}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6)))]])])));
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.3)),
            SizedBox(height: AppSpacing.spacing4),
            Text(
              _selectedFilter == 'all' 
                  ? '아직 토큰 사용 내역이 없습니다'
                  : '해당하는 내역이 없습니다',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6)),
            SizedBox(height: AppSpacing.spacing2),
            Text(
              '운세를 보거나 토큰을 구매하면\n여기에 내역이 표시됩니다',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5)),
              textAlign: TextAlign.center)])));
  }

  List<TokenTransaction> _filterTransactions(List<TokenTransaction> transactions) {
    if (_selectedFilter == 'all') return transactions;
    
    return transactions.where((t) => t.type == _selectedFilter).toList();
  }

  List<Map<String, dynamic>> _groupTransactionsByDate(List<TokenTransaction> transactions) {
    final groups = <String, List<TokenTransaction>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    for (final transaction in transactions) {
      final transactionDate = DateTime(
        transaction.createdAt.year,
        transaction.createdAt.month,
        transaction.createdAt.day);
      
      String label;
      if (transactionDate == today) {
        label = '오늘';
      } else if (transactionDate == yesterday) {
        label = '어제';
      } else if (transactionDate.isAfter(today.subtract(const Duration(days: 7))) {
        label = '이번 주';
      } else if (transactionDate.month == now.month && transactionDate.year == now.year) {
        label = '이번 달';
      } else {
        label = DateFormat('yyyy년 MM월').format(transaction.createdAt);
      }
      
      groups[label] ??= [];
      groups[label]!.add(transaction);
    }
    
    // Convert to list and sort
    final sortedGroups = groups.entries.map((entry) => {
      'label': entry.key,
      'transactions': entry.value}).toList();
    
    // Custom sort order
    final orderMap = {
      '오늘': 0,
      '어제': 1,
      '이번 주': 2,
      '이번 달': 3};
    
    sortedGroups.sort((a, b) {
      final aOrder = orderMap[a['label']] ?? 4;
      final bOrder = orderMap[b['label']] ?? 4;
      
      if (aOrder != bOrder) return aOrder.compareTo(bOrder)
      
      // For custom date labels, sort by date
      return (b['label'] as String).compareTo(a['label'] as String);
    });
    
    return sortedGroups;
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'purchase':
        return Icons.shopping_cart_rounded;
      case 'usage':
      case 'consumption':
        return Icons.auto_awesome_rounded;
      case 'bonus':
        return Icons.card_giftcard_rounded;
      case 'refund':
        return Icons.replay_rounded;
      default:
        return Icons.token_rounded;
    }
  }

  Color _getTransactionColor(String type, bool isAddition) {
    switch (type) {
      case 'purchase':
        return AppColors.primary;
      case 'usage':
      case 'consumption':
        return AppColors.warning;
      case 'bonus':
        return AppColors.success;
      case 'refund':
        return Colors.purple;
      default:
        return isAddition ? AppColors.success : AppColors.error;
    }
  }

  String _getTransactionTitle(TokenTransaction transaction) {
    if (transaction.description != null && transaction.description!.isNotEmpty) {
      return transaction.description!;
    }
    
    switch (transaction.type) {
      case 'purchase':
        return '토큰 구매';
      case 'usage':
      case 'consumption':
        return '운세 조회';
      case 'bonus':
        return '보너스 토큰';
      case 'refund':
        return '환불';
      default:
        return '토큰 ${transaction.amount > 0 ? '획득' : '사용'}';
    }
  }
}