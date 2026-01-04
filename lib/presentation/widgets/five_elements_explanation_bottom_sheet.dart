import 'package:fortune/core/theme/fortune_design_system.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/tokens/ds_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/five_elements_explanations.dart';
import 'package:fortune/core/theme/app_animations.dart';

class FiveElementsExplanationBottomSheet extends StatefulWidget {
  final String element;
  final int elementCount;
  final int totalCount;
  
  const FiveElementsExplanationBottomSheet({
    super.key,
    required this.element,
    required this.elementCount,
    required this.totalCount,
  });

  static Future<void> show(
    BuildContext context, {
    required String element,
    required int elementCount,
    required int totalCount,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: TossDesignSystem.white.withValues(alpha: 0.0),
      barrierColor: DSColors.overlay,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => FiveElementsExplanationBottomSheet(
        element: element,
        elementCount: elementCount,
        totalCount: totalCount,
      ),
    );
  }

  @override
  State<FiveElementsExplanationBottomSheet> createState() => _FiveElementsExplanationBottomSheetState();
}

class _FiveElementsExplanationBottomSheetState extends State<FiveElementsExplanationBottomSheet> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppAnimations.durationMedium);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Color _getElementColor(String element) {
    switch (element) {
      case '목':
        return TossDesignSystem.successGreen;
      case '화':
        return TossDesignSystem.warningOrange;
      case '토':
        return TossDesignSystem.warningOrange;
      case '금':
        return TossDesignSystem.gray600;
      case '수':
        return TossDesignSystem.tossBlue;
      default:
        return TossDesignSystem.gray600;
    }
  }

  IconData _getElementIcon(String element) {
    switch (element) {
      case '목':
        return Icons.park;
      case '화':
        return Icons.local_fire_department;
      case '토':
        return Icons.landscape;
      case '금':
        return Icons.diamond;
      case '수':
        return Icons.water_drop;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final explanation = FiveElementsExplanations.getExplanation(widget.element);
    
    if (explanation == null) {
      return Container();
    }
    
    final elementColor = _getElementColor(widget.element);
    final percentage = widget.totalCount > 0 ? (widget.elementCount / widget.totalCount * 100).round() : 0;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          height: screenHeight * 0.85,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.brightness == Brightness.dark
                    ? TossDesignSystem.grayDark900.withValues(alpha: 0.3)
                    : TossDesignSystem.gray900.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHandle(context),
              _buildHeader(theme, elementColor, explanation, percentage),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBasicInfo(theme, elementColor, explanation),
                      const SizedBox(height: AppSpacing.spacing6),
                      _buildCharacteristics(theme, elementColor, explanation),
                      const SizedBox(height: AppSpacing.spacing6),
                      _buildPersonality(theme, elementColor, explanation),
                      const SizedBox(height: AppSpacing.spacing6),
                      _buildBalanceAdvice(theme, elementColor, explanation, percentage),
                      const SizedBox(height: AppSpacing.spacing6),
                      _buildCompatibility(theme, elementColor, explanation),
                      const SizedBox(height: AppSpacing.spacing6),
                      _buildHealth(theme, elementColor, explanation),
                      const SizedBox(height: AppSpacing.spacing6),
                      _buildCareer(theme, elementColor, explanation),
                      const SizedBox(height: AppSpacing.spacing6),
                      _buildLuckyItems(theme, elementColor, explanation),
                      const SizedBox(height: AppSpacing.spacing10),
                    ],
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                ),
              ),
            ],
          ),
        );
      });
  }

  Widget _buildHandle(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: AppSpacing.small,
        bottom: TossDesignSystem.spacingXS),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? TossDesignSystem.gray400
            : TossDesignSystem.gray600,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, Color elementColor, Map<String, dynamic> explanation, int percentage) {
    return Container(
      padding: AppSpacing.paddingAll20,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            elementColor.withValues(alpha:0.1),
            elementColor.withValues(alpha:0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 80,
                    height: AppSpacing.spacing20,
                    decoration: BoxDecoration(
                      color: elementColor,
                      borderRadius: AppDimensions.borderRadiusLarge,
                      boxShadow: [
                        BoxShadow(
                          color: elementColor.withValues(alpha:0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          explanation['hanja'],
                          style: Theme.of(context).textTheme.displaySmall),
                        Text(
                          explanation['name'],
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: theme.brightness == Brightness.dark
                                ? TossDesignSystem.gray100
                                : TossDesignSystem.grayDark900)),
                      ],
                    ),
                  ).animate()
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      duration: 300.ms,
                      curve: Curves.elasticOut,
                    ),
                  const SizedBox(width: AppSpacing.spacing4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(
                          '오행 (五行)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.spacing1),
                      Text(
                        explanation['basicMeaning'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spacing1),
                      Text(
                        '비율: $percentage%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: elementColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  shape: const CircleBorder()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo(ThemeData theme, Color elementColor, Map<String, dynamic> explanation) {
    return Container(
      padding: AppSpacing.paddingAll16,
      decoration: BoxDecoration(
        color: elementColor.withValues(alpha:0.05),
        borderRadius: AppDimensions.borderRadiusMedium,
        border: Border.all(
          color: elementColor.withValues(alpha:0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _getElementIcon(widget.element),
                color: elementColor,
                size: AppDimensions.iconSizeMedium),
              const SizedBox(width: AppSpacing.spacing2),
              Text(
                '기본 정보',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: AppSpacing.spacing4),
          _buildInfoRow(theme, '색상', explanation['color']),
          _buildInfoRow(theme, '계절', explanation['season']),
          _buildInfoRow(theme, '방향', explanation['direction']),
          _buildInfoRow(theme, '장기', explanation['organ']),
          _buildInfoRow(theme, '감정', explanation['emotion']),
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacing1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha:0.6)),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacteristics(ThemeData theme, Color elementColor, Map<String, dynamic> explanation) {
    final characteristics = List<String>.from(explanation['characteristics'] ?? []);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: AppSpacing.paddingAll8,
              decoration: BoxDecoration(
                color: elementColor.withValues(alpha:0.1),
                borderRadius: AppDimensions.borderRadiusSmall),
              child: Icon(
                Icons.star,
                color: elementColor,
                size: AppDimensions.iconSizeSmall),
            ),
            const SizedBox(width: AppSpacing.spacing3),
            Text(
              '주요 특징',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: AppSpacing.spacing4),
        ...characteristics.map((characteristic) => Padding(
          padding: const EdgeInsets.only(bottom: TossDesignSystem.spacingXS),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle,
                size: AppDimensions.iconSizeSmall,
                color: elementColor),
              const SizedBox(width: AppSpacing.spacing2),
              Expanded(
                child: Text(
                  characteristic,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5)),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildPersonality(ThemeData theme, Color elementColor, Map<String, dynamic> explanation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: AppSpacing.paddingAll8,
              decoration: BoxDecoration(
                color: elementColor.withValues(alpha:0.1),
                borderRadius: AppDimensions.borderRadiusSmall),
              child: Icon(
                Icons.psychology,
                color: elementColor,
                size: AppDimensions.iconSizeSmall),
            ),
            const SizedBox(width: AppSpacing.spacing3),
            Text(
              '성격과 성향',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: AppSpacing.spacing4),
        Container(
          padding: AppSpacing.paddingAll16,
          decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: AppDimensions.borderRadiusMedium,
          boxShadow: [
            BoxShadow(
              color: TossDesignSystem.gray900.withValues(alpha:0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
                    child: Text(
                      explanation['personality'] ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildBalanceAdvice(ThemeData theme, Color elementColor, Map<String, dynamic> explanation, int percentage) {
    final balanceAdvice = explanation['balanceAdvice'] as Map<String, dynamic>;
    final isExcess = percentage > 25;
    final isDeficient = percentage < 15;
    
    String advice = '';
    String status = '';
    Color statusColor = elementColor;
    
    if (isExcess) {
      advice = balanceAdvice['excess'] ?? '';
      status = '과다';
      statusColor = TossDesignSystem.warningOrange;
    } else if (isDeficient) {
      advice = balanceAdvice['deficiency'] ?? '';
      status = '부족';
      statusColor = TossDesignSystem.errorRed;
    } else {
      advice = '${explanation['name']}(${widget.element})의 기운이 적절한 균형을 이루고 있습니다. 현재의 조화로운 상태를 유지하면서 건강한 생활을 이어가세요.';
      status = '균형';
      statusColor = TossDesignSystem.successGreen;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: AppSpacing.paddingAll8,
        decoration: BoxDecoration(
          color: TossDesignSystem.warningOrange.withValues(alpha:0.1),
          borderRadius: AppDimensions.borderRadiusSmall,
        ),
        child: const Icon(
                Icons.balance,
                color: TossDesignSystem.warningOrange,
                size: AppDimensions.iconSizeSmall,
              ),
            ),
            const SizedBox(width: AppSpacing.spacing3),
            Text(
              '오행 균형 조언',
              style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
            ),
            const SizedBox(width: AppSpacing.spacing2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing2, vertical: AppSpacing.spacing1),
              decoration: BoxDecoration(
        color: statusColor.withValues(alpha:0.2),
                borderRadius: AppDimensions.borderRadiusMedium,
              ),
              child: Text(
                status,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spacing4),
        Container(
          padding: AppSpacing.paddingAll16,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                statusColor.withValues(alpha:0.1),
                statusColor.withValues(alpha:0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppDimensions.borderRadiusMedium,
            border: Border.all(
              color: statusColor.withValues(alpha:0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.tips_and_updates,
                    size: AppDimensions.iconSizeXSmall,
                    color: statusColor),
                  const SizedBox(width: AppSpacing.spacing2),
                  Text(
                    '상태: $percentage%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold)),
              ],
            ),
              const SizedBox(height: AppSpacing.spacing2),
              Text(
                advice,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.6)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompatibility(ThemeData theme, Color elementColor, Map<String, dynamic> explanation) {
    final compatibility = explanation['compatibility'] as Map<String, dynamic>;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: AppSpacing.paddingAll8,
        decoration: BoxDecoration(
      color: elementColor.withValues(alpha:0.1),
                borderRadius: AppDimensions.borderRadiusSmall),
      child: Icon(
                Icons.sync,
                color: elementColor,
                size: AppDimensions.iconSizeSmall),
            ),
            const SizedBox(width: AppSpacing.spacing3),
            Text(
              '다른 오행과의 관계',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: AppSpacing.spacing4),
        ...compatibility.entries.map((entry) {
          final otherElement = entry.key;
          final relation = entry.value;
          final otherColor = _getElementColor(otherElement);
          final isHarmonious = relation.contains('에너지를 받는') || relation.contains('에너지를 주는');
          
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.small),
            padding: AppSpacing.paddingAll12,
            decoration: BoxDecoration(
      gradient: LinearGradient(
                colors: [
                  otherColor.withValues(alpha:0.05),
                  otherColor.withValues(alpha:0.02)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight),
      borderRadius: AppDimensions.borderRadiusSmall,
              border: Border.all(
      color: otherColor.withValues(alpha:0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: AppDimensions.buttonHeightSmall,
                  height: AppDimensions.buttonHeightSmall,
                  decoration: BoxDecoration(
      color: otherColor.withValues(alpha:0.2),
                    shape: BoxShape.circle,
                ),
      child: Center(
                    child: Icon(
                      _getElementIcon(otherElement),
                      color: otherColor,
                      size: AppDimensions.iconSizeSmall,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.spacing3),
                Expanded(
                  child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            otherElement,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: otherColor)),
                          const SizedBox(width: AppSpacing.spacing2),
                          if (isHarmonious)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing1, vertical: AppSpacing.spacing0),
                              decoration: BoxDecoration(
                                color: TossDesignSystem.successGreen.withValues(alpha:0.2),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
                              child: Text(
                                '상생',
                                style: theme.textTheme.bodySmall,
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing1, vertical: AppSpacing.spacing0),
                              decoration: BoxDecoration(
                                color: TossDesignSystem.warningOrange.withValues(alpha:0.2),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
                              child: Text(
                                '상극',
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.spacing1),
                      Text(
                        relation,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha:0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHealth(ThemeData theme, Color elementColor, Map<String, dynamic> explanation) {
    final healthTips = List<String>.from(explanation['health'] ?? []);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: AppSpacing.paddingAll8,
        decoration: BoxDecoration(
      color: TossDesignSystem.errorRed.withValues(alpha:0.1),
                borderRadius: AppDimensions.borderRadiusSmall),
      child: const Icon(
                Icons.favorite,
                color: TossDesignSystem.errorRed,
                size: AppDimensions.iconSizeSmall),
            ),
            const SizedBox(width: AppSpacing.spacing3),
            Text(
              '건강 조언',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: AppSpacing.spacing4),
        Container(
          padding: AppSpacing.paddingAll16,
          decoration: BoxDecoration(
            color: TossDesignSystem.errorRed.withValues(alpha:0.05),
            borderRadius: AppDimensions.borderRadiusMedium,
            border: Border.all(
              color: TossDesignSystem.errorRed.withValues(alpha:0.2),
            ),
          ),
          child: Column(
            children: healthTips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: TossDesignSystem.spacingXS),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.health_and_safety,
                    size: AppDimensions.iconSizeXSmall,
                    color: TossDesignSystem.errorRed,
                  ),
                  const SizedBox(width: AppSpacing.spacing2),
                  Expanded(
                    child: Text(
                      tip,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCareer(ThemeData theme, Color elementColor, Map<String, dynamic> explanation) {
    final careers = List<String>.from(explanation['career'] ?? []);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: AppSpacing.paddingAll8,
        decoration: BoxDecoration(
      color: TossDesignSystem.tossBlue.withValues(alpha:0.1),
                borderRadius: AppDimensions.borderRadiusSmall),
              child: const Icon(
                Icons.work,
                color: TossDesignSystem.tossBlue,
                size: AppDimensions.iconSizeSmall),
            ),
            const SizedBox(width: AppSpacing.spacing3),
            Text(
              '적합한 진로',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spacing4),
        Container(
          padding: AppSpacing.paddingAll16,
          decoration: BoxDecoration(
            color: TossDesignSystem.tossBlue.withValues(alpha:0.05),
            borderRadius: AppDimensions.borderRadiusMedium,
            border: Border.all(
              color: TossDesignSystem.tossBlue.withValues(alpha:0.2)),
          ),
          child: Column(
            children: careers.map((career) => Padding(
              padding: const EdgeInsets.only(bottom: TossDesignSystem.spacingXS),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.arrow_right,
                    size: AppDimensions.iconSizeSmall,
                    color: TossDesignSystem.tossBlue,
                  ),
                  const SizedBox(width: AppSpacing.spacing2),
                  Expanded(
                    child: Text(
                      career,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.4),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLuckyItems(ThemeData theme, Color elementColor, Map<String, dynamic> explanation) {
    final luckyItems = List<String>.from(explanation['luckyItems'] ?? []);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: AppSpacing.paddingAll8,
              decoration: BoxDecoration(
                color: TossDesignSystem.warningOrange.withValues(alpha:0.2),
                borderRadius: AppDimensions.borderRadiusSmall,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: TossDesignSystem.warningOrange,
                size: AppDimensions.iconSizeSmall,
              ),
            ),
            const SizedBox(width: AppSpacing.spacing3),
            Text(
              '행운의 아이템',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spacing4),
        Container(
          padding: AppSpacing.paddingAll16,
        decoration: BoxDecoration(
      gradient: LinearGradient(
              colors: [
                TossDesignSystem.warningOrange.withValues(alpha:0.1),
                TossDesignSystem.warningOrange.withValues(alpha:0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
          ),
      borderRadius: AppDimensions.borderRadiusMedium,
            border: Border.all(
              color: TossDesignSystem.warningOrange.withValues(alpha:0.3)),
        ),
          child: Column(
            children: luckyItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: TossDesignSystem.spacingXS),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.stars,
                    size: AppDimensions.iconSizeXSmall,
                    color: TossDesignSystem.warningOrange,
                  ),
                  const SizedBox(width: AppSpacing.spacing2),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }
}