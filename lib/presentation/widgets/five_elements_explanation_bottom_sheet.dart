import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/five_elements_explanations.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_animations.dart';
import 'package:fortune/core/theme/fortune_colors.dart';

class FiveElementsExplanationBottomSheet extends StatefulWidget {
  final String element;
  final int elementCount;
  final int totalCount;
  
  const FiveElementsExplanationBottomSheet({
    super.key,
    required this.element,
    required this.elementCount,
    required this.totalCount});

  static Future<void> show(
    BuildContext context, {
    required String element,
    required int elementCount,
    required int totalCount}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => FiveElementsExplanationBottomSheet(
        element: element,
        elementCount: elementCount,
        totalCount: totalCount));
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
              topRight: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -5))]),
          child: Column(
            children: [
              _buildHandle(),
              _buildHeader(theme, elementColor, explanation, percentage),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBasicInfo(theme, elementColor, explanation),
                      SizedBox(height: AppSpacing.spacing6),
                      _buildCharacteristics(theme, elementColor, explanation),
                      SizedBox(height: AppSpacing.spacing6),
                      _buildPersonality(theme, elementColor, explanation),
                      SizedBox(height: AppSpacing.spacing6),
                      _buildBalanceAdvice(theme, elementColor, explanation, percentage),
                      SizedBox(height: AppSpacing.spacing6),
                      _buildCompatibility(theme, elementColor, explanation),
                      SizedBox(height: AppSpacing.spacing6),
                      _buildHealth(theme, elementColor, explanation),
                      SizedBox(height: AppSpacing.spacing6),
                      _buildCareer(theme, elementColor, explanation),
                      SizedBox(height: AppSpacing.spacing6),
                      _buildLuckyItems(theme, elementColor, explanation),
                      SizedBox(height: AppSpacing.spacing10)]).animate().fadeIn(duration: 400.ms, delay: 100.ms)))]));
      });
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(
        top: AppSpacing.small,
        bottom: AppSpacing.xSmall),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.textSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall)));
  }

  Widget _buildHeader(ThemeData theme, Color elementColor, Map<String, dynamic> explanation, int percentage) {
    return Container(
      padding: AppSpacing.paddingAll20,
      decoration: BoxDecoration(
      gradient: LinearGradient(
          colors: [
            elementColor.withValues(alpha: 0.1),
            elementColor.withValues(alpha: 0.05)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter)),
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
                          color: elementColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4))
                      ]),
                    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          explanation['hanja'],
                          style: Theme.of(context).textTheme.displaySmall),
                        Text(
                          explanation['name'],
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimaryDark))])).animate()
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      duration: 300.ms,
                      curve: Curves.elasticOut),
                  SizedBox(width: AppSpacing.spacing4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                        Text(
                          '오행 (五行)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                      SizedBox(height: AppSpacing.spacing1),
                      Text(
                        explanation['basicMeaning'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold)),
                      SizedBox(height: AppSpacing.spacing1),
                      Text(
                        '비율: $percentage%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: elementColor,
                          fontWeight: FontWeight.w600))])]),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  shape: const CircleBorder()))])]));
  }

  Widget _buildBasicInfo(ThemeData theme, Color elementColor, Map<String, dynamic> explanation) {
    return Container(
      padding: AppSpacing.paddingAll16,
        decoration: BoxDecoration(
      color: elementColor.withValues(alpha: 0.05),
        borderRadius: AppDimensions.borderRadiusMedium,
        border: Border.all(
      color: elementColor.withValues(alpha: 0.2))),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _getElementIcon(widget.element),
                color: elementColor,
                size: AppDimensions.iconSizeMedium),
              SizedBox(width: AppSpacing.spacing2),
              Text(
                '기본 정보',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold))]),
          SizedBox(height: AppSpacing.spacing4),
          _buildInfoRow(theme, '색상', explanation['color']),
          _buildInfoRow(theme, '계절', explanation['season']),
          _buildInfoRow(theme, '방향', explanation['direction']),
          _buildInfoRow(theme, '장기', explanation['organ']),
          _buildInfoRow(theme, '감정', explanation['emotion'])]));
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.spacing1),
      child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
                        Text(
                          label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          Text(
            value,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600))]));
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
                color: elementColor.withValues(alpha: 0.1),
                borderRadius: AppDimensions.borderRadiusSmall),
              child: Icon(
                Icons.star,
                color: elementColor,
                size: AppDimensions.iconSizeSmall)),
            SizedBox(width: AppSpacing.spacing3),
            Text(
              '주요 특징',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold))]),
        SizedBox(height: AppSpacing.spacing4),
        ...characteristics.map((characteristic) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xSmall),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle,
                size: AppDimensions.iconSizeSmall,
                color: elementColor),
              SizedBox(width: AppSpacing.spacing2),
              Expanded(
                child: Text(
                  characteristic,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5)))])))]);
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
                color: elementColor.withValues(alpha: 0.1),
                borderRadius: AppDimensions.borderRadiusSmall),
              child: Icon(
                Icons.psychology,
                color: elementColor,
                size: AppDimensions.iconSizeSmall)),
            SizedBox(width: AppSpacing.spacing3),
            Text(
              '성격과 성향',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold))]),
        SizedBox(height: AppSpacing.spacing4),
        Container(
          padding: AppSpacing.paddingAll16,
          decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: AppDimensions.borderRadiusMedium,
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))]),
                    child: Text(
                      explanation['personality'] ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.6)))]);
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
      statusColor = AppColors.warning;
    } else if (isDeficient) {
      advice = balanceAdvice['deficiency'] ?? '';
      status = '부족';
      statusColor = AppColors.error;
    } else {
      advice = '${explanation['name']}(${widget.element})의 기운이 적절한 균형을 이루고 있습니다. 현재의 조화로운 상태를 유지하면서 건강한 생활을 이어가세요.';
      status = '균형';
      statusColor = AppColors.success;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: AppSpacing.paddingAll8,
        decoration: BoxDecoration(
      color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: AppDimensions.borderRadiusSmall),
      child: Icon(
                Icons.balance,
                color: AppColors.warning,
                size: AppDimensions.iconSizeSmall)),
            SizedBox(width: AppSpacing.spacing3),
            Text(
              '오행 균형 조언',
              style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold)),
            SizedBox(width: AppSpacing.spacing2),
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing2, vertical: AppSpacing.spacing1),
              decoration: BoxDecoration(
      color: statusColor.withValues(alpha: 0.2),
                borderRadius: AppDimensions.borderRadiusMedium),
      child: Text(
                status,
        
                        style: Theme.of(context).textTheme.labelSmall))]),
        SizedBox(height: AppSpacing.spacing4),
        Container(
          padding: AppSpacing.paddingAll16,
        decoration: BoxDecoration(
      gradient: LinearGradient(
              colors: [
                statusColor.withValues(alpha: 0.1),
                statusColor.withValues(alpha: 0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
      borderRadius: AppDimensions.borderRadiusMedium,
            border: Border.all(
      color: statusColor.withValues(alpha: 0.3))),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.tips_and_updates,
                    size: AppDimensions.iconSizeXSmall,
                    color: statusColor),
                  SizedBox(width: AppSpacing.spacing2),
                  Text(
                    '상태: $percentage%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold))]),
              SizedBox(height: AppSpacing.spacing2),
              Text(
                advice,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.6))]))]);
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
      color: elementColor.withValues(alpha: 0.1),
                borderRadius: AppDimensions.borderRadiusSmall),
      child: Icon(
                Icons.sync,
                color: elementColor,
                size: AppDimensions.iconSizeSmall)),
            SizedBox(width: AppSpacing.spacing3),
            Text(
              '다른 오행과의 관계',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold))]),
        SizedBox(height: AppSpacing.spacing4),
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
                  otherColor.withValues(alpha: 0.05),
                  otherColor.withValues(alpha: 0.02)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight),
      borderRadius: AppDimensions.borderRadiusSmall,
              border: Border.all(
      color: otherColor.withValues(alpha: 0.2))),
      child: Row(
              children: [
                Container(
                  width: AppDimensions.buttonHeightSmall,
                  height: AppDimensions.buttonHeightSmall,
                  decoration: BoxDecoration(
      color: otherColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle),
      child: Center(
                    child: Icon(
                      _getElementIcon(otherElement),
                      color: otherColor,
                      size: AppDimensions.iconSizeSmall))),
                SizedBox(width: AppSpacing.spacing3),
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
                          SizedBox(width: AppSpacing.spacing2),
                          if (isHarmonious)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing1, vertical: AppSpacing.spacing0),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
                              child: Text(
                                '상생',
                                style: theme.textTheme.bodySmall))
                          else
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing1, vertical: AppSpacing.spacing0),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
                              child: Text(
                                '상극',
                                style: theme.textTheme.bodySmall))]),
                      SizedBox(height: AppSpacing.spacing1),
                      Text(
                        relation,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.8)))]))]));
        })]);
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
      color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: AppDimensions.borderRadiusSmall),
      child: const Icon(
                Icons.favorite,
                color: AppColors.error,
                size: AppDimensions.iconSizeSmall)),
            SizedBox(width: AppSpacing.spacing3),
            Text(
              '건강 조언',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold))]),
        SizedBox(height: AppSpacing.spacing4),
        Container(
          padding: AppSpacing.paddingAll16,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.05),
            borderRadius: AppDimensions.borderRadiusMedium,
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.2))),
          child: Column(
            children: healthTips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xSmall),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.health_and_safety,
                    size: AppDimensions.iconSizeXSmall,
                    color: AppColors.error),
                  SizedBox(width: AppSpacing.spacing2),
                  Expanded(
                    child: Text(
                      tip,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.4)))]))).toList()))]);
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
      color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: AppDimensions.borderRadiusSmall),
              child: const Icon(
                Icons.work,
                color: AppColors.primary,
                size: AppDimensions.iconSizeSmall)),
            SizedBox(width: AppSpacing.spacing3),
            Text(
              '적합한 진로',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold))]),
        SizedBox(height: AppSpacing.spacing4),
        Container(
          padding: AppSpacing.paddingAll16,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: AppDimensions.borderRadiusMedium,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2))),
          child: Column(
            children: careers.map((career) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xSmall),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.arrow_right,
                    size: AppDimensions.iconSizeSmall,
                    color: AppColors.primary),
                  SizedBox(width: AppSpacing.spacing2),
                  Expanded(
                    child: Text(
                      career,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.4)))]))).toList()))]);
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
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: AppDimensions.borderRadiusSmall),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.amber,
                size: AppDimensions.iconSizeSmall)),
            SizedBox(width: AppSpacing.spacing3),
            Text(
              '행운의 아이템',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold))]),
        SizedBox(height: AppSpacing.spacing4),
        Container(
          padding: AppSpacing.paddingAll16,
        decoration: BoxDecoration(
      gradient: LinearGradient(
              colors: [
                Colors.amber.withValues(alpha: 0.1),
                Colors.amber.withValues(alpha: 0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
      borderRadius: AppDimensions.borderRadiusMedium,
            border: Border.all(
              color: Colors.amber.withValues(alpha: 0.3))),
          child: Column(
            children: luckyItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xSmall),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.stars,
                    size: AppDimensions.iconSizeXSmall,
                    color: Colors.amber),
                  SizedBox(width: AppSpacing.spacing2),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.4)))]))).toList()))]);
  }
}