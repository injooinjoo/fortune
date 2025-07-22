import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/providers.dart';
import '../screens/ad_loading_screen.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/haptic_utils.dart';

enum TimePeriod {
  today('오늘', 'today', '오늘 하루의 시간대별 운세를 확인해보세요', Icons.today),
  tomorrow('내일', 'tomorrow', '내일의 주요 시간대와 운세를 미리 확인해보세요', Icons.upcoming),
  weekly('이번 주', 'weekly', '월요일부터 일요일까지 주간 운세를 확인해보세요', Icons.calendar_view_week),
  monthly('이번 달', 'monthly', '이번 달의 주차별 운세를 확인해보세요', Icons.calendar_month),
  yearly('올해', 'yearly', '올해의 계절별 운세를 확인해보세요', Icons.calendar_today);

  final String label;
  final String value;
  final String description;
  final IconData icon;
  
  const TimePeriod(this.label, this.value, this.description, this.icon);
}

class TimeBasedFortuneBottomSheet extends ConsumerStatefulWidget {
  final VoidCallback? onDismiss;
  
  const TimeBasedFortuneBottomSheet({
    super.key,
    this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onDismiss,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      barrierColor: Colors.transparent, // Remove background dimming
      useRootNavigator: true, // Ensure bottom sheet appears above all widgets
      builder: (context) => TimeBasedFortuneBottomSheet(
        onDismiss: onDismiss,
      ),
    ).then((_) {
      onDismiss?.call();
    });
  }

  @override
  ConsumerState<TimeBasedFortuneBottomSheet> createState() => _TimeBasedFortuneBottomSheetState();
}

class _TimeBasedFortuneBottomSheetState extends ConsumerState<TimeBasedFortuneBottomSheet> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  TimePeriod? _selectedPeriod;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPeriodSelected(TimePeriod period) {
    setState(() {
      _selectedPeriod = period;
    });
    HapticUtils.lightImpact();
  }

  void _onFortuneButtonPressed() {
    if (_selectedPeriod == null) return;
    
    HapticUtils.mediumImpact();
    
    // Navigate to AdLoadingScreen with selected period
    final isPremium = ref.read(hasUnlimitedAccessProvider);
    
    Navigator.of(context).pop(); // Close bottom sheet
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdLoadingScreen(
          fortuneType: 'time',
          fortuneTitle: '시간별 운세',
          fortuneRoute: '/fortune/time?period=${_selectedPeriod!.value}',
          isPremium: isPremium,
          fortuneParams: {
            'period': _selectedPeriod!.value,
          },
          onComplete: () {
            // This won't be called since we're using fortuneRoute
          },
          onSkip: () {
            // Navigate to premium page
            Navigator.of(context).pushNamed('/subscription');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          )),
          child: Container(
            height: screenHeight * 0.7,
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark 
                  ? Colors.grey[900] 
                  : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHandle(),
                _buildHeader(theme),
                Expanded(
                  child: _buildContent(theme),
                ),
                _buildBottomButton(theme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        children: [
          Text(
            '시간별 운세',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 8),
          Text(
            '확인하고 싶은 기간을 선택해주세요',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        children: [
          ...TimePeriod.values.map((period) => _buildPeriodCard(theme, period))
              .toList()
              .animate(interval: 50.ms)
              .fadeIn(duration: 300.ms, delay: 200.ms)
              .slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildPeriodCard(ThemeData theme, TimePeriod period) {
    final isSelected = _selectedPeriod == period;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _onPeriodSelected(period),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                : theme.colorScheme.surface,
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryColor
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withValues(alpha: 0.2)
                      : theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  period.icon,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      period.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppTheme.primaryColor : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      period.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton(ThemeData theme) {
    final isEnabled = _selectedPeriod != null;
    
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).padding.bottom + 24,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: AnimatedOpacity(
        opacity: isEnabled ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton(
          onPressed: isEnabled ? _onFortuneButtonPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: isEnabled ? 4 : 0,
            shadowColor: AppTheme.primaryColor.withValues(alpha: 0.3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, size: 20),
              const SizedBox(width: 8),
              Text(
                isEnabled 
                    ? '${_selectedPeriod!.label} 운세 보기'
                    : '기간을 선택해주세요',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}