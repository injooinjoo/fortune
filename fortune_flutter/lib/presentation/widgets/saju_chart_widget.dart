import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/fortune/presentation/providers/saju_provider.dart';
import 'saju_loading_widget.dart';
import 'saju_element_explanation_bottom_sheet.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/fortune_colors.dart';

class SajuChartWidget extends ConsumerStatefulWidget {
  final Map<String, dynamic>? userProfile;
  
  const SajuChartWidget(
    {
    super.key,
    required this.userProfile,
  )});

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
    print('User profile data: ${widget.userProfile}');
    
    try {
      final sajuNotifier = ref.read(sajuProvider.notifier);
      
      print('Step 1: Fetching user Saju from database...');
      await sajuNotifier.fetchUserSaju();
      print('Step 1 completed');
      
      // If no Saju data exists and we have birth info, calculate it
      final sajuState = ref.read(sajuProvider);
      print('Current Saju state:');
      print('- isLoading: ${sajuState.isLoading}');
      print('- sajuData exists: ${sajuState.sajuData != null}');
      print('- error: ${sajuState.error}');
      print('- isCached: ${sajuState.isCached}');
      
      if (sajuState.sajuData == null && !sajuState.isLoading && widget.userProfile != null) {
        print('No Saju data found, checking birth info...');
        final birthDate = widget.userProfile!['birth_date'];
        final birthTime = widget.userProfile!['birth_time'];
        
        print('Birth date: $birthDate');
        print('Birth time: $birthTime');
        
        if (birthDate != null) {
          print('Step 2: Calculating Saju with birth info...');
          print('Calling calculateAndSaveSaju with:');
          print(
    '- birthDate: ${DateTime.parse(birthDate,
  )}');
          print('- birthTime: $birthTime');
          print('- isLunar: false');
          
          await sajuNotifier.calculateAndSaveSaju(
            birthDate: DateTime.parse(birthDate),
            birthTime: birthTime,
            isLunar: false
          );
          
          print('Step 2 completed');
          
          // Check final state
          final finalState = ref.read(sajuProvider);
          print('Final Saju state:');
          print('- isLoading: ${finalState.isLoading}');
          print('- sajuData exists: ${finalState.sajuData != null}');
          print('- error: ${finalState.error}');
          print('- isCached: ${finalState.isCached}');
        } else {
          print('No birth date available, skipping Saju calculation');
        }
      } else {
        print('Saju data already exists or conditions not met:');
        print('- sajuData exists: ${sajuState.sajuData != null}');
        print('- isLoading: ${sajuState.isLoading}');
        print('- userProfile exists: ${widget.userProfile != null}');
      }
    } catch (e, stackTrace) {
      print('=== SAJU INITIALIZATION ERROR ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('Stack trace:');
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
        decoration: BoxDecoration(,
      color: theme.colorScheme.errorContainer,
          borderRadius: AppDimensions.borderRadiusMedium),
      child: Column(
                children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.onErrorContainer,
              size: 48)
            SizedBox(height: AppSpacing.spacing4),
            Text(
              sajuState.error!,
        ),
        style: theme.textTheme.bodyMedium?.copyWith(,
      color: theme.colorScheme.onErrorContainer,
                          ))
              textAlign: TextAlign.center)
            SizedBox(height: AppSpacing.spacing4),
            ElevatedButton(
              onPressed: _initializeSaju,
              ),
              child: const Text('다시 시도'))
          ])))
    }
    
    final sajuData = sajuState.sajuData;
    
    if (sajuData == null) {
      return Container(
        padding: AppSpacing.paddingAll20,
        decoration: BoxDecoration(,
      color: AppColors.textPrimaryDark,
          borderRadius: AppDimensions.borderRadiusMedium,
        ),
        border: Border.all(,
      color: theme.colorScheme.outline.withValues(alp,
      ha: 0.1),
            width: 1)),
      child: Column(
                children: [
            Icon(
              Icons.info_outline,
              color: theme.colorScheme.primary,
              size: 48)
            SizedBox(height: AppSpacing.spacing4),
            Text(
              '사주 정보가 없습니다',
              style: theme.textTheme.titleMedium)
            SizedBox(height: AppSpacing.spacing2),
            Text(
              '생년월일시를 입력하면 정확한 사주팔자를 계산해드립니다.',
              ),
              style: theme.textTheme.bodyMedium?.copyWith(,
      color: theme.colorScheme.onSurface.withValues(alp,
      ha: 0.7),
      textAlign: TextAlign.center)
          ]
        )
    }
    
    return Container(
      padding: AppSpacing.paddingAll20,
      decoration: BoxDecoration(,
      color: AppColors.textPrimaryDark,
        borderRadius: AppDimensions.borderRadiusMedium,
        ),
        border: Border.all(,
      color: theme.colorScheme.outline.withValues(alp,
      ha: 0.1),
          width: 1)),
      child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                        Text(
                          '나의 사주팔자',
              ),
              style: theme.textTheme.titleLarge?.copyWith(,
      fontWeight: FontWeight.bold,
                          ))))
              Text(
                '四柱八字',
                          style: theme.textTheme.bodyMedium?.copyWith(,
      color: theme.colorScheme.onSurface.withValues(alp,
      ha: 0.6,
                          )))
            ])
          SizedBox(height: AppSpacing.spacing2),
          Text(
            '타고난 운명의 네 기둥'),
        style: theme.textTheme.bodyMedium?.copyWith(,
      color: theme.colorScheme.onSurface.withValues(alp,
      ha: 0.7,
                          )))
          SizedBox(height: AppSpacing.spacing5),
          
          // 사주 차트
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly),
        children: [
              _buildPillar(context, '시주\n時柱', sajuData['hour']),
              _buildPillar(context, '일주\n日柱', sajuData['day']),
              _buildPillar(context, '월주\n月柱', sajuData['month']),
              _buildPillar(context, '년주\n年柱', sajuData['year']),
            ])
          
          SizedBox(height: AppSpacing.spacing6),
          
          // 사주 해석
          _buildInterpretation(context, sajuData),
          
          SizedBox(height: AppSpacing.spacing6),
          
          
          // 대운 정보
          _buildDaeunInfo(context, sajuData['daeun']),
        ]
      )
  }
  
  Widget _buildPillar(BuildContext context, String title, Map<String, dynamic> pillar) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
                        Text(
                          title,
                          style: theme.textTheme.bodySmall?.copyWith(,
      color: theme.colorScheme.onSurface.withValues(alp,
      ha: 0.6, height: 1.2),
      textAlign: TextAlign.center)
        SizedBox(height: AppSpacing.spacing2,
                          ),
        
        // 천간
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            SajuElementExplanationBottomSheet.show(
              context,
              element: pillar['cheongan']['char']),
        elementHanja: pillar['cheongan']['hanja']),
        isCheongan: true),
        elementType: pillar['cheongan']['element']
            );
          }
          child: Container(,
      width: 70,
            height: 70),
              decoration: BoxDecoration(,
      color: _getElementColor(pillar['cheongan']['element']),
              borderRadius: AppDimensions.borderRadiusSmall,
              boxShadow: [
                BoxShadow(
                  color: _getElementColor(pillar['cheongan']['element']).withValues(alph,
      a: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2))
              ])
            child: Column(,
      mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  pillar['cheongan']['hanja'],
        ),
        style: theme.textTheme.headlineMedium?.copyWith(,
      color: AppColors.textPrimaryDark,
                          ),
        fontWeight: FontWeight.bold)
                  ))
                Text(
                  pillar['cheongan']['char'],
              ),
              style: theme.textTheme.bodySmall?.copyWith(,
      color: AppColors.textPrimaryDark.withValues(alp,
      ha: 0.9,
                          )))
              ])))))
        SizedBox(height: AppSpacing.spacing1),
        
        // 지지
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            SajuElementExplanationBottomSheet.show(
              context,
              element: pillar['jiji']['char']),
        elementHanja: pillar['jiji']['hanja']),
        isCheongan: false),
        elementType: pillar['jiji']['element']
            );
          }
          child: Container(,
      width: 70,
            height: 70),
              decoration: BoxDecoration(,
      color: _getElementColor(pillar['jiji']['element']),
              borderRadius: AppDimensions.borderRadiusSmall,
              boxShadow: [
                BoxShadow(
                  color: _getElementColor(pillar['jiji']['element']).withValues(alph,
      a: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2))
              ])
            child: Column(,
      mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  pillar['jiji']['hanja'],
        ),
        style: theme.textTheme.headlineMedium?.copyWith(,
      color: AppColors.textPrimaryDark,
                          ),
        fontWeight: FontWeight.bold)
                  ))
                Text(
                  pillar['jiji']['char'],
              ),
              style: theme.textTheme.bodySmall?.copyWith(,
      color: AppColors.textPrimaryDark.withValues(alp,
      ha: 0.9,
                          )))
              ])))))
      ]
    );
  }
  
  Widget _buildInterpretation(BuildContext context, Map<String, dynamic> sajuData) {
    final theme = Theme.of(context);
    
    return Container(
      padding: AppSpacing.paddingAll16),
        decoration: BoxDecoration(,
      color: theme.colorScheme.primary.withValues(alp,
      ha: 0.05),
        borderRadius: AppDimensions.borderRadiusSmall),
      child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: AppDimensions.iconSizeSmall,
                color: theme.colorScheme.primary)
              SizedBox(width: AppSpacing.spacing2),
              Text(
                '사주 해석',
        ),
        style: theme.textTheme.titleSmall?.copyWith(,
      fontWeight: FontWeight.bold,
                          ))))
              const Spacer(),
              if (sajuData['calculatedAt'] != null,
                Text(
                  '${DateTime.parse(sajuData['calculatedAt']).toLocal().toString().split(' ')[0]} 계산됨',
                  style: theme.textTheme.bodySmall?.copyWith(,
      color: theme.colorScheme.onSurface.withValues(alp,
      ha: 0.5,
                          )))
            ])
          SizedBox(height: AppSpacing.spacing3),
          
          // 일주 정보
          RichText(
            text: TextSpan(),
              style: theme.textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: '${sajuData['day']['cheongan']['hanja']}${sajuData['day']['jiji']['hanja']} '),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(,
      color: theme.colorScheme.primary,
                          ),
                TextSpan(
                  text: '(${sajuData['day']['cheongan']['char']}${sajuData['day']['jiji']['char']}) ')
                const TextSpan(text: '일주를 가진 당신은\n\n'),
              ])))
          
          // 전체 해석
          if (sajuData['interpretation'] != null && sajuData['interpretation'].isNotEmpty,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                        Text(
                          sajuData['interpretation']
                  style: theme.textTheme.bodyMedium)
                SizedBox(height: AppSpacing.spacing4),
              ])
          
          // 성격 분석
          if (sajuData['personalityAnalysis'] != null && sajuData['personalityAnalysis'].isNotEmpty,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.psychology,
                      size: 18,
                      color: theme.colorScheme.secondary)
                    SizedBox(width: AppSpacing.xSmall),
                    Text(
                      '성격 분석',
                          style: theme.textTheme.titleSmall?.copyWith(,
      fontWeight: FontWeight.w600),
        color: theme.colorScheme.secondary,
                          )))
                  ])
                SizedBox(height: AppSpacing.spacing2),
                Text(
                  sajuData['personalityAnalysis']
                  style: theme.textTheme.bodySmall)
                SizedBox(height: AppSpacing.spacing4),
              ])
          
          // 진로 조언
          if (sajuData['careerGuidance'] != null && sajuData['careerGuidance'].isNotEmpty,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.work_outline,
                      size: 18,
                      color: theme.colorScheme.tertiary)
                    SizedBox(width: AppSpacing.xSmall),
                    Text(
                      '진로 조언'),
        style: theme.textTheme.titleSmall?.copyWith(,
      fontWeight: FontWeight.w600),
        color: theme.colorScheme.tertiary,
                          )))
                  ])
                SizedBox(height: AppSpacing.spacing2),
                Text(
                  sajuData['careerGuidance']
                  style: theme.textTheme.bodySmall)
                SizedBox(height: AppSpacing.spacing4),
              ])
          
          // 인간관계 조언
          if (sajuData['relationshipAdvice'] != null && sajuData['relationshipAdvice'].isNotEmpty,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.favorite_outline,
                      size: 18,
                      color: theme.colorScheme.error)
                    SizedBox(width: AppSpacing.xSmall),
                    Text(
                      '인간관계 조언'),
        style: theme.textTheme.titleSmall?.copyWith(,
      fontWeight: FontWeight.w600),
        color: theme.colorScheme.error,
                          )))
                  ])
                SizedBox(height: AppSpacing.spacing2),
                Text(
                  sajuData['relationshipAdvice']
                  style: theme.textTheme.bodySmall)
              ])
        ]
      )
  }
  
  
  Widget _buildDaeunInfo(BuildContext context, Map<String, dynamic> daeun) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
                        Text(
                          '대운 흐름',
                          style: theme.textTheme.titleMedium?.copyWith(,
      fontWeight: FontWeight.bold,
                          ))))
            Text(
              '大運'),
        style: theme.textTheme.bodySmall?.copyWith(,
      color: theme.colorScheme.onSurface.withValues(alp,
      ha: 0.6,
                          )))
          ])
        SizedBox(height: AppSpacing.spacing3),
        Container(
          padding: AppSpacing.paddingAll16),
        decoration: BoxDecoration(,
      color: theme.colorScheme.outline.withValues(alp,
      ha: 0.05),
            borderRadius: AppDimensions.borderRadiusSmall),
      child: Row(
            children: [
              Icon(
                Icons.timeline,
                color: theme.colorScheme.primary)
              SizedBox(width: AppSpacing.spacing3),
              Expanded(
                child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '현재 대운',
        ),
        style: theme.textTheme.bodySmall?.copyWith(,
      color: theme.colorScheme.onSurface.withValues(alp,
      ha: 0.6,
                          )))
                    SizedBox(height: AppSpacing.spacing1),
                    Row(
                      children: [
                        Text(
                          '${daeun['currentHanja']} (${daeun['current']})',
                          style: theme.textTheme.bodyLarge?.copyWith(,
      fontWeight: FontWeight.bold,
                          ))))
                        SizedBox(width: AppSpacing.spacing2),
                        Text(
                          '${daeun['age']}세~${daeun['endAge']}세',
                          style: theme.textTheme.bodyMedium)
                      ])
                  ])))
            ])))
      ]
    );
  }
  
  Color _getElementColor(String element) {
    switch (element) {
      case '목':
        return AppColors.success; // Green
      case '화':
        return AppColors.warning; // Red
      case '토':
        return FortuneColors.goldLight; // Yellow
      case '금':
        return AppColors.textTertiary; // Gray
      case '수':
        return AppColors.primary; // Blue
      default:
        return AppColors.textSecondary;
    }
  }
  
  Map<String, dynamic> _getElementInfo(String element) {
    switch (element) {
      case '목':
        return {'hanja': '木', 'name': '나무'};
      case '화':
        return {'hanja': '火', 'name': '불'};
      case '토':
        return {'hanja': '土', 'name': '흙'};
      case '금':
        return {'hanja': '金', 'name': '쇠'};
      case '수':
        return {'hanja': '水', 'name': '물'};
      default:
        return {'hanja': element, 'name': element};
    }
  }
  
}