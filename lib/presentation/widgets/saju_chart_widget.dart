import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/core/design_system/design_system.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';
import '../../features/fortune/presentation/providers/saju_provider.dart';
import 'saju_loading_widget.dart';
// import 'saju_element_explanation_bottom_sheet.dart';

class SajuChartWidget extends ConsumerStatefulWidget {
  final Map<String, dynamic>? userProfile;
  
  const SajuChartWidget({
    super.key,
    required this.userProfile});

  @override
  ConsumerState<SajuChartWidget> createState() => _SajuChartWidgetState();
}

class _SajuChartWidgetState extends ConsumerState<SajuChartWidget> {
  @override
  void initState() {
    super.initState();
    // Fetch user's Saju data when widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSaju();
    });
  }

  Future<void> _initializeSaju() async {
    debugPrint('=== SAJU INITIALIZATION START ===');
    debugPrint('Timestamp: ${DateTime.now().toIso8601String()}');
    debugPrint('data: ${widget.userProfile}');
    
    try {
      final sajuNotifier = ref.read(sajuProvider.notifier);
      
      debugPrint('1: Fetching user Saju from database...');
      await sajuNotifier.fetchUserSaju();
      debugPrint('Step 1 completed');
      
      // If no Saju data exists and we have birth info, calculate it
      final sajuState = ref.read(sajuProvider);
      debugPrint('state:');
      debugPrint('- isLoading: ${sajuState.isLoading}');
      debugPrint('exists: ${sajuState.sajuData != null}');
      debugPrint('- error: ${sajuState.error}');
      debugPrint('- isCached: ${sajuState.isCached}');
      
      if (sajuState.sajuData == null && !sajuState.isLoading && widget.userProfile != null) {
        debugPrint('No Saju data found, checking birth info...');
        final birthDate = widget.userProfile!['birth_date'];
        final birthTime = widget.userProfile!['birth_time'];
        
        debugPrint('Fortune cached');
        debugPrint('Fortune cached');
        
        if (birthDate != null) {
          debugPrint('2: Calculating Saju with birth info...');
          debugPrint('with:');
          debugPrint('birthDate: $birthDate');
          debugPrint('birthTime: $birthTime');
          debugPrint('Fortune cached');
          debugPrint('- isLunar: false');
          
          await sajuNotifier.calculateAndSaveSaju(
            birthDate: DateTime.parse(birthDate),
            birthTime: birthTime,
            isLunar: false
          );
          
          debugPrint('Step 2 completed');
          
          // Check final state
          final finalState = ref.read(sajuProvider);
          debugPrint('state:');
          debugPrint('- isLoading: ${finalState.isLoading}');
          debugPrint('exists: ${finalState.sajuData != null}');
          debugPrint('- error: ${finalState.error}');
          debugPrint('- isCached: ${finalState.isCached}');
        } else {
          debugPrint('No birth date available, skipping Saju calculation');
        }
      } else {
        debugPrint('met:');
        debugPrint('exists: ${sajuState.sajuData != null}');
        debugPrint('- isLoading: ${sajuState.isLoading}');
        debugPrint('exists: ${widget.userProfile != null}');
      }
    } catch (e, stackTrace) {
      debugPrint('=== SAJU INITIALIZATION ERROR ===');
      debugPrint('type: ${e.runtimeType}');
      debugPrint('Fortune cached');
      debugPrint('trace:');
      debugPrint(stackTrace.toString());
    }
    
    debugPrint('=== SAJU INITIALIZATION END ===');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sajuState = ref.watch(sajuProvider);
    
    if (sajuState.isLoading) {
      return const SajuLoadingWidget();
    }
    
    if (sajuState.error != null) {
      return Container(
        padding: AppSpacing.paddingAll20,
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: AppDimensions.borderRadiusMedium),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.onErrorContainer,
              size: 48),
            const SizedBox(height: AppSpacing.spacing4),
            Text(
              sajuState.error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer),
              textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.spacing4),
            ElevatedButton(
              onPressed: _initializeSaju,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }
    
    final sajuData = sajuState.sajuData;
    
    if (sajuData == null) {
      return Container(
        padding: AppSpacing.paddingAll20,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: AppDimensions.borderRadiusMedium,
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
            width: 1)),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              color: theme.colorScheme.primary,
              size: 48),
            const SizedBox(height: AppSpacing.spacing4),
            Text(
              '사주 정보가 없습니다',
              style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.spacing2),
            Text(
              '생년월일시를 입력하면 정확한 사주팔자를 계산해드립니다.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: AppSpacing.paddingAll20,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppDimensions.borderRadiusMedium,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '나의 사주팔자',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold)),
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _initializeSaju();
                },
                icon: Icon(
                  Icons.refresh,
                  color: theme.colorScheme.primary))]),
          const SizedBox(height: AppSpacing.spacing6),
          
          // Four Pillars
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPillar(context, '시주\n時柱', sajuData['hour']),
              _buildPillar(context, '일주\n日柱', sajuData['day']),
              _buildPillar(context, '월주\n月柱', sajuData['month']),
              _buildPillar(context, '년주\n年柱', sajuData['year']),
            ],
          ),
          
          const SizedBox(height: AppSpacing.spacing6),
          
          // Summary info
          _buildSummaryInfo(context, sajuData),
        ],
      ),
    );
  }
  
  Widget _buildPillar(BuildContext context, String title, Map<String, dynamic>? pillarData) {
    final theme = Theme.of(context);
    
    if (pillarData == null) {
      return Column(
        children: [
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.spacing2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: AppDimensions.borderRadiusSmall,
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              '?',
              style: theme.textTheme.titleLarge,
            ),
          ),
        ],
      );
    }
    
    final heavenlyStem = pillarData['heavenly_stem'] ?? {};
    final earthlyBranch = pillarData['earthly_branch'] ?? {};
    
    // NOTE: SajuElementExplanationBottomSheet 기능은 향후 구현 예정 (saju_element_explanation_bottom_sheet.dart.skip 참조)
    return Column(
      children: [
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.spacing2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getColorForElement(heavenlyStem['element'] ?? '').withValues(alpha: 0.8),
                  _getColorForElement(earthlyBranch['element'] ?? '').withValues(alpha: 0.6)]),
              borderRadius: AppDimensions.borderRadiusSmall,
              boxShadow: [
                BoxShadow(
                  color: _getColorForElement(heavenlyStem['element'] ?? '').withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4))]),
            child: Column(
              children: [
                Text(
                  heavenlyStem['character'] ?? '',
                  style: AppTypography.headlineMedium.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold)),
                Text(
                  earthlyBranch['character'] ?? '',
                  style: AppTypography.headlineMedium.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryInfo(BuildContext context, Map<String, dynamic> sajuData) {
    final theme = Theme.of(context);
    
    return Container(
      padding: AppSpacing.paddingAll16,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppDimensions.borderRadiusSmall,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오행 구성',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.spacing4),
          _buildElementBalance(sajuData['element_balance'] ?? {}),
          
          const SizedBox(height: AppSpacing.spacing6),
          
          Text(
            '주요 특성',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.spacing4),
          _buildCharacteristics(sajuData['characteristics'] ?? {}),
        ],
      ),
    );
  }
  
  Widget _buildElementBalance(Map<String, dynamic> elementBalance) {
    final elements = ['wood', 'fire', 'earth', 'metal', 'water'];
    final elementNames = {
      'wood': '목(木)',
      'fire': '화(火)', 
      'earth': '토(土)',
      'metal': '금(金)',
      'water': '수(水)'};
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: elements.map((element) {
        final count = elementBalance[element] ?? 0;
        return Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getColorForElement(element),
                shape: BoxShape.circle),
              child: Center(
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.spacing1),
            Text(
              elementNames[element] ?? '',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        );
      }).toList(),
    );
  }
  
  Widget _buildCharacteristics(Map<String, dynamic> characteristics) {
    final theme = Theme.of(context);
    final items = <Widget>[];
    
    characteristics.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.spacing2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: 16),
                const SizedBox(width: AppSpacing.spacing2),
                Expanded(
                  child: Text(
                    value.toString(),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items);
  }
  
  Color _getColorForElement(String? element) {
    switch (element?.toLowerCase()) {
      case 'wood':
      case '목':
        return DSColors.success; // Green for wood
      case 'fire':
      case '화':
        return DSColors.warning; // Red/orange for fire
      case 'earth':
      case '토':
        return DSColors.warning; // Yellow/gold for earth
      case 'metal':
      case '금':
        return DSColors.textSecondaryDark; // Gray/silver for metal
      case 'water':
      case '수':
        return DSColors.accentDark; // Blue for water
      default:
        return DSColors.textSecondaryDark;
    }
  }
}