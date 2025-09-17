import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/toss_design_system.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/fortune_colors.dart';
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
    print('=== SAJU INITIALIZATION START ===');
    print('Timestamp: ${DateTime.now().toIso8601String()}');
    print('data: ${widget.userProfile}');
    
    try {
      final sajuNotifier = ref.read(sajuProvider.notifier);
      
      print('1: Fetching user Saju from database...');
      await sajuNotifier.fetchUserSaju();
      print('Step 1 completed');
      
      // If no Saju data exists and we have birth info, calculate it
      final sajuState = ref.read(sajuProvider);
      print('state:');
      print('- isLoading: ${sajuState.isLoading}');
      print('exists: ${sajuState.sajuData != null}');
      print('- error: ${sajuState.error}');
      print('- isCached: ${sajuState.isCached}');
      
      if (sajuState.sajuData == null && !sajuState.isLoading && widget.userProfile != null) {
        print('No Saju data found, checking birth info...');
        final birthDate = widget.userProfile!['birth_date'];
        final birthTime = widget.userProfile!['birth_time'];
        
        print('Fortune cached');
        print('Fortune cached');
        
        if (birthDate != null) {
          print('2: Calculating Saju with birth info...');
          print('with:');
          print('birthDate: $birthDate');
          print('birthTime: $birthTime');
          print('Fortune cached');
          print('- isLunar: false');
          
          await sajuNotifier.calculateAndSaveSaju(
            birthDate: DateTime.parse(birthDate),
            birthTime: birthTime,
            isLunar: false
          );
          
          print('Step 2 completed');
          
          // Check final state
          final finalState = ref.read(sajuProvider);
          print('state:');
          print('- isLoading: ${finalState.isLoading}');
          print('exists: ${finalState.sajuData != null}');
          print('- error: ${finalState.error}');
          print('- isCached: ${finalState.isCached}');
        } else {
          print('No birth date available, skipping Saju calculation');
        }
      } else {
        print('met:');
        print('exists: ${sajuState.sajuData != null}');
        print('- isLoading: ${sajuState.isLoading}');
        print('exists: ${widget.userProfile != null}');
      }
    } catch (e, stackTrace) {
      print('=== SAJU INITIALIZATION ERROR ===');
      print('type: ${e.runtimeType}');
      print('Fortune cached');
      print('trace:');
      print(stackTrace);
    }
    
    print('=== SAJU INITIALIZATION END ===');
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
            SizedBox(height: AppSpacing.spacing4),
            Text(
              sajuState.error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer),
              textAlign: TextAlign.center),
            SizedBox(height: AppSpacing.spacing4),
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
          color: Theme.of(context).brightness == Brightness.dark
              ? TossDesignSystem.grayDark600
              : TossDesignSystem.white,
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
            SizedBox(height: AppSpacing.spacing4),
            Text(
              '사주 정보가 없습니다',
              style: theme.textTheme.titleMedium),
            SizedBox(height: AppSpacing.spacing2),
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
        color: Theme.of(context).brightness == Brightness.dark
            ? TossDesignSystem.grayDark600
            : TossDesignSystem.white,
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
          SizedBox(height: AppSpacing.spacing6),
          
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
          
          SizedBox(height: AppSpacing.spacing6),
          
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
          SizedBox(height: AppSpacing.spacing2),
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
    
    return GestureDetector(
      onTap: () {
        // TODO: Fix SajuElementExplanationBottomSheet syntax errors
        // HapticFeedback.lightImpact();
        // showModalBottomSheet(
        //   context: context,
        //   isScrollControlled: true,
        //   backgroundColor: TossDesignSystem.white.withValues(alpha: 0.0),
        //   builder: (context) => SajuElementExplanationBottomSheet(
        //     element: heavenlyStem['name'] ?? '',
        //     elementHanja: heavenlyStem['hanja'] ?? '',
        //     isCheongan: true,
        //     elementType: heavenlyStem['element'] ?? '',
        //   ),
        // );
      },
      child: Column(
        children: [
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: AppSpacing.spacing2),
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
      ),
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
          SizedBox(height: AppSpacing.spacing4),
          _buildElementBalance(sajuData['element_balance'] ?? {}),
          
          SizedBox(height: AppSpacing.spacing6),
          
          Text(
            '주요 특성',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold)),
          SizedBox(height: AppSpacing.spacing4),
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
            SizedBox(height: AppSpacing.spacing1),
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
            padding: EdgeInsets.only(bottom: AppSpacing.spacing2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: 16),
                SizedBox(width: AppSpacing.spacing2),
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
        return TossDesignSystem.successGreen; // Green for wood
      case 'fire':
      case '화':
        return TossDesignSystem.warningOrange; // Red/orange for fire
      case 'earth':
      case '토':
        return FortuneColors.goldLight; // Yellow/gold for earth
      case 'metal':
      case '금':
        return TossDesignSystem.gray600; // Gray/silver for metal
      case 'water':
      case '수':
        return TossDesignSystem.tossBlue; // Blue for water
      default:
        return TossDesignSystem.gray600;
    }
  }
}