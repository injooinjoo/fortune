import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Adjusted const usage for elements layout
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/fortune/presentation/providers/saju_provider.dart';
import 'five_elements_explanation_bottom_sheet.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/fortune_colors.dart';

class FiveElementsWidget extends ConsumerWidget {
  final Map<String, dynamic>? userProfile;
  
  const FiveElementsWidget({
    super.key,
    required this.userProfile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sajuState = ref.watch(sajuProvider);
    
    // Get elements data from saju state
    final sajuData = sajuState.sajuData;
    if (sajuData == null || sajuData['elements'] == null) {
      return _buildEmptyState(context, theme);
    }
    
    final elements = sajuData['elements'] as Map<String, dynamic>;
    
    // Convert dynamic map to int map
    final elementMap = <String, int>{};
    elements.forEach((key, value) {
      elementMap[key] = value is int ? value : (value as num).toInt();
    });
    
    final total = elementMap.values.isEmpty ? 1 : elementMap.values.reduce((a, b) => a + b);
    
    // Get dominant and lacking elements
    final sajuDisplayData = ref.watch(sajuDisplayDataProvider);
    final dominantElement = sajuDisplayData?['dominantElement'] as String?;
    final lackingElement = sajuDisplayData?['lackingElement'] as String?;
    
    return Container(
      padding: AppSpacing.paddingAll20,
      decoration: BoxDecoration(
        color: AppColors.textPrimaryDark,
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
              Row(
                children: [
                  Text(
                    '나의 오행 분석',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold)),
                  SizedBox(width: AppSpacing.spacing2),
                  Text(
                    '五行分析',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6)))]),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.spacing2,
                  vertical: AppSpacing.spacing1),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: AppDimensions.borderRadiusMedium),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app,
                      size: 14,
                      color: theme.colorScheme.primary),
                    SizedBox(width: AppSpacing.spacing1),
                    Text(
                      '탭하여 상세보기',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary))]))]),
          SizedBox(height: AppSpacing.spacing2),
          Text(
            '오행의 균형으로 보는 나의 기운',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
          SizedBox(height: AppSpacing.spacing5),
          
          // Five Elements Grid
          _buildFiveElementsGrid(context, theme, elementMap, total, dominantElement, lackingElement),
          
          SizedBox(height: AppSpacing.spacing6),
          
          // Element balance bars
          _buildElementBars(context, theme, elementMap, total, dominantElement, lackingElement),
          
          // Balance advice
          if (dominantElement != null || lackingElement != null)
            _buildBalanceAdvice(theme, dominantElement, lackingElement)]));
  }
  
  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Container(
      padding: AppSpacing.paddingAll20,
      decoration: BoxDecoration(
        color: AppColors.textPrimaryDark,
        borderRadius: AppDimensions.borderRadiusMedium,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1)),
      child: Column(
        children: [
          Icon(
            Icons.bubble_chart,
            color: theme.colorScheme.primary,
            size: 48),
          SizedBox(height: AppSpacing.spacing4),
          Text(
            '오행 정보가 없습니다',
            style: theme.textTheme.titleMedium),
          SizedBox(height: AppSpacing.spacing2),
          Text(
            '사주 정보를 입력하면 오행 분석을 확인할 수 있습니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            textAlign: TextAlign.center)]));
  }
  
  Widget _buildFiveElementsGrid(
    BuildContext context,
    ThemeData theme,
    Map<String, int> elementMap,
    int total,
    String? dominantElement,
    String? lackingElement) {
    final elements = ['목', '화', '토', '금', '수'];
    
    return Container(
      padding: AppSpacing.paddingAll16,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: AppDimensions.borderRadiusMedium),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: elements.take(3).map((element) {
                final count = elementMap[element] ?? 0;
                final percentage = total > 0 ? (count / total * 100).round() : 0;
                return Flexible(
                  child: Center(
                    child: _buildElementCircle(
                      context,
                      theme,
                      element,
                      count,
                      percentage,
                      total,
                      dominantElement == element,
                      lackingElement == element)));
              }).toList())),
          SizedBox(height: AppSpacing.spacing3),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: AppSpacing.spacing5),
                ...elements.skip(3).map((element) {
                  final count = elementMap[element] ?? 0;
                  final percentage = total > 0 ? (count / total * 100).round() : 0;
                  return Row(
                    children: [
                      _buildElementCircle(
                        context,
                        theme,
                        element,
                        count,
                        percentage,
                        total,
                        dominantElement == element,
                        lackingElement == element),
                      SizedBox(width: AppSpacing.spacing5)]);
                }).toList()]))]));
  }
  
  Widget _buildElementCircle(
    BuildContext context,
    ThemeData theme,
    String element,
    int count,
    int percentage,
    int total,
    bool isDominant,
    bool isLacking) {
    final color = _getElementColor(element);
    // Constrain size to prevent overflow
    final size = min(75.0, 60.0 + (percentage / 10));
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        FiveElementsExplanationBottomSheet.show(
          context,
          element: element,
          elementCount: count,
          totalCount: total);
      },
      child: SizedBox(
        width: 85,
        height: 95, // Fixed height for all elements,
    child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Circle positioned at top
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDominant ? theme.colorScheme.primary : 
                         isLacking ? theme.colorScheme.error : 
                         color,
                  width: isDominant || isLacking ? 3 : 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2))]),
              child: Center(
                child: Padding(
                  padding: AppSpacing.xSmall.all,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getElementHanja(element),
                          style: Theme.of(context).textTheme.headlineMedium),
                        Text(
                          element,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: color)),
                        Text(
                          '$percentage%',
                          style: context.captionMedium)]))))),
            // Label positioned at bottom (outside circle alignment)
            if (isDominant || isLacking)
              Positioned(
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.spacing1,
                    vertical: AppSpacing.spacing0),
                  decoration: BoxDecoration(
                    color: isDominant ? 
                           theme.colorScheme.primary.withValues(alpha: 0.2) :
                           theme.colorScheme.error.withValues(alpha: 0.2),
                    borderRadius: AppDimensions.borderRadiusSmall),
                  child: Text(
                    isDominant ? '강함' : '부족',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDominant ? 
                             theme.colorScheme.primary :
                             theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                      fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize))))])));
  }
  
  Widget _buildElementBars(
    BuildContext context,
    ThemeData theme,
    Map<String, int> elementMap,
    int total,
    String? dominantElement,
    String? lackingElement) {
    return Column(
      children: elementMap.entries.map((entry) {
        final percentage = total > 0 ? (entry.value / total * 100).round() : 0;
        final isDominant = entry.key == dominantElement;
        final isLacking = entry.key == lackingElement;
        final color = _getElementColor(entry.key);
        
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            FiveElementsExplanationBottomSheet.show(
              context,
              element: entry.key,
              elementCount: entry.value,
              totalCount: total);
          },
          child: Container(
            margin: const EdgeInsets.only(
              bottom: AppSpacing.small),
            padding: AppSpacing.paddingAll12,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: AppDimensions.borderRadiusSmall,
              border: Border.all(
                color: isDominant ? theme.colorScheme.primary.withValues(alpha: 0.3) :
                       isLacking ? theme.colorScheme.error.withValues(alpha: 0.3) :
                       color.withValues(alpha: 0.2))),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: AppDimensions.buttonHeightSmall,
                      height: AppDimensions.buttonHeightSmall,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          _getElementHanja(entry.key),
                          style: Theme.of(context).textTheme.titleLarge))),
                    SizedBox(width: AppSpacing.spacing3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
    children: [
                              Text(
                                '${_getElementName(entry.key)} (${entry.key})',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600)),
                              if (isDominant) ...[
                                SizedBox(width: AppSpacing.spacing2),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.spacing1,
                                    vertical: AppSpacing.spacing0),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                    borderRadius: AppDimensions.borderRadiusMedium),
                                  child: Text(
                                    '강함',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold)))],
                              if (isLacking) ...[
                                SizedBox(width: AppSpacing.spacing2),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.spacing1,
                                    vertical: AppSpacing.spacing0),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.error.withValues(alpha: 0.2),
                                    borderRadius: AppDimensions.borderRadiusMedium),
                                  child: Text(
                                    '부족',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.error,
                                      fontWeight: FontWeight.bold)))]]),
                          SizedBox(height: AppSpacing.spacing2),
                          Row(
                            children: [
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: percentage / 100,
                                  backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.1),
                                  valueColor: AlwaysStoppedAnimation(color),
                                  minHeight: 8)),
                              SizedBox(width: AppSpacing.spacing3),
                              Text(
                                '$percentage%',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: color))])])),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: AppDimensions.iconSizeXSmall,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3))])])));
      }).toList());
  }
  
  Widget _buildBalanceAdvice(ThemeData theme, String? dominantElement, String? lackingElement) {
    return Container(
      margin: const EdgeInsets.only(
        top: AppSpacing.medium),
      padding: AppSpacing.paddingAll16,
      decoration: BoxDecoration(
        color: theme.colorScheme.outline.withValues(alpha: 0.05),
        borderRadius: AppDimensions.borderRadiusMedium,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates,
                size: AppDimensions.iconSizeSmall,
                color: theme.colorScheme.primary),
              SizedBox(width: AppSpacing.spacing2),
              Text(
                '오행 균형 조언',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold))]),
          SizedBox(height: AppSpacing.spacing3),
          if (dominantElement != null)
            Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.xSmall),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: AppSpacing.spacing1 * 1.5,
                    margin: const EdgeInsets.only(
                      top: AppSpacing.xSmall),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle)),
                  SizedBox(width: AppSpacing.spacing2),
                  Expanded(
    child: Text(
                      '${_getElementName(dominantElement)}($dominantElement)의 기운이 강합니다. 과도한 기운을 조절하여 균형을 맞추세요.',
                      style: theme.textTheme.bodySmall))])),
          if (lackingElement != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: AppSpacing.spacing1 * 1.5,
                  margin: const EdgeInsets.only(
                    top: AppSpacing.xSmall),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    shape: BoxShape.circle)),
                SizedBox(width: AppSpacing.spacing2),
                Expanded(
                  child: Text(
                    '${_getElementName(lackingElement)}($lackingElement)의 기운이 부족합니다. 부족한 기운을 보충하여 조화를 이루세요.',
                    style: theme.textTheme.bodySmall))]),
          SizedBox(height: AppSpacing.spacing2),
          Text(
            '자세한 조언을 보려면 각 오행을 탭하세요.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic))]));
  }
  
  Color _getElementColor(String element) {
    switch (element) {
      case '목':
        return AppColors.success;
      case '화':
        return AppColors.warning;
      case '토':
        return FortuneColors.goldLight;
      case '금':
        return AppColors.textSecondary;
      case '수':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }
  
  String _getElementHanja(String element) {
    switch (element) {
      case '목':
        return '木';
      case '화':
        return '火';
      case '토':
        return '土';
      case '금':
        return '金';
      case '수':
        return '水';
      default:
        return element;
    }
  }
  
  String _getElementName(String element) {
    switch (element) {
      case '목':
        return '나무';
      case '화':
        return '불';
      case '토':
        return '흙';
      case '금':
        return '쇠';
      case '수':
        return '물';
      default:
        return element;
    }
  }
}