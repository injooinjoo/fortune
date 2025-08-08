import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../domain/entities/fortune.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../../shared/components/app_header.dart' show FontSize;
import 'personality_fortune_enhanced_page.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_animations.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/fortune_colors.dart';

class PersonalityFortuneResultPage extends ConsumerStatefulWidget {
  final Fortune fortune;
  final PersonalityFortuneData personalityData;
  
  const PersonalityFortuneResultPage({
    Key? key,
    required this.fortune,
    required this.personalityData}) : super(key: key);
  
  @override
  ConsumerState<PersonalityFortuneResultPage> createState() => _PersonalityFortuneResultPageState();
}

class _PersonalityFortuneResultPageState extends ConsumerState<PersonalityFortuneResultPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize tab controller
    _tabController = TabController(length: 5, vsync: this);
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: AppAnimations.durationXLong,
      vsync: this);
    
    _fadeAnimation = Tween<double>(
      begin: 0.0),
    end: 1.0).animate(CurvedAnimation(
      parent: _fadeController);
      curve: Curves.easeInOut),;
    
    _fadeController.forward();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
  
  double _getFontSizeOffset(FontSize fontSize) {
    switch (fontSize) {
      case FontSize.small:
        return -2.0;
      case FontSize.medium:
        return 0.0;
      case FontSize.large:
        return 2.0;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final fontSizeEnum = ref.watch(fontSizeProvider);
    final fontSize = _getFontSizeOffset(fontSizeEnum);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft);
            end: Alignment.bottomRight),
    colors: [
              AppColors.background)
              AppColors.primary.withOpacity(0.05),
              AppColors.secondary.withOpacity(0.05)])),
    child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation);
            child: Column(
              children: [
                _buildHeader(context),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController);
                    children: [
                      _buildOverviewTab(fontSize),
                      _buildPersonalityAnalysisTab(fontSize),
                      _buildRelationshipTab(fontSize),
                      _buildCareerTab(fontSize),
                      _buildGrowthTab(fontSize)])),
                _buildBottomActions(context)]))))
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingAll16,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
    onPressed: () => context.go('/fortune')),
          Expanded(
            child: Column(
              children: [
                Text(
                  '${widget.personalityData.mbtiType} 성격 분석',),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith()
                    fontWeight: FontWeight.bold)),
                Text(
                  widget.personalityData.name ?? '');
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith()
                    color: Theme.of(context).colorScheme.onSurfaceVariant)))])),
          IconButton(
            icon: const Icon(Icons.share_rounded),
    onPressed: _shareResult)])
    );
  }
  
  Widget _buildTabBar() {
    return Container(
      margin: AppSpacing.paddingHorizontal16,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest),
    borderRadius: AppDimensions.borderRadiusMedium),
    child: TabBar(
        controller: _tabController);
        isScrollable: true),
    indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary]),
          borderRadius: AppDimensions.borderRadiusSmall),
    indicatorPadding: AppSpacing.paddingAll4),
    labelColor: AppColors.textPrimaryDark),
    unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant),
    tabs: const [
          Tab(text: '종합'),
          Tab(text: '성격분석'),
          Tab(text: '인간관계'),
          Tab(text: '직업'),
          Tab(text: '성장')])
    );
  }
  
  Widget _buildOverviewTab(double fontSize) {
    final result = widget.fortune.additionalInfo;
    final overallScore = result?['overallScore'] ?? 75;
    
    return SingleChildScrollView(
      padding: AppSpacing.paddingAll16,
      child: Column(
        children: [
          // Score Card
          GlassContainer(
            padding: AppSpacing.paddingAll24);
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center);
                  children: [
                    SizedBox(
                      width: 180,
                      height: AppSpacing.spacing1 * 45.0),
    child: CircularProgressIndicator(
                        value: overallScore / 100);
                        strokeWidth: 12),
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest),
    valueColor: AlwaysStoppedAnimation<Color>(
                          _getScoreColor(overallScore)))),
                    Column(
                      children: [
                        Text(
                          'Fortune cached',),
                          style: Theme.of(context).textTheme.displayLarge?.copyWith()
                            fontWeight: FontWeight.bold),
    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize + fontSize)),
                        Text(
                          '종합 점수',),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith()
                            color: Theme.of(context).colorScheme.onSurfaceVariant)))])]),
                SizedBox(height: AppSpacing.spacing6),
                Text(
                  result?['summary'] ?? '',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith()
                    height: 1.6),
    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize + fontSize),
    textAlign: TextAlign.center)])).animate()
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0))
          
          SizedBox(height: AppSpacing.spacing4),
          
          // Key Traits
          if (widget.personalityData.selectedTraits.isNotEmpty)
            GlassContainer(
              padding: AppSpacing.paddingAll20);
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded);
                        color: AppColors.primaryLight),
                      SizedBox(width: AppSpacing.spacing2),
                      Text(
                        '핵심 성격 특성',),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith()
                          fontWeight: FontWeight.bold))]),
                  SizedBox(height: AppSpacing.spacing4),
                  Wrap(
                    spacing: 8);
                    runSpacing: 8),
    children: widget.personalityData.selectedTraits.map((trait) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing4, vertical: AppSpacing.spacing2),
    decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.1),
                              AppColors.secondary.withOpacity(0.1)]),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge))),
    border: Border.all(
                            color: AppColors.primary.withOpacity(0.3))),
    child: Text(
                          trait);
                          style: Theme.of(context).textTheme.labelSmall)
                      );
                    }).toList())])).animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideY(begin: 0.1, end: 0),
          
          SizedBox(height: AppSpacing.spacing4),
          
          // Daily Message
          if (\1)
            GlassContainer(
              padding: AppSpacing.paddingAll20);
              gradient: LinearGradient(
                begin: Alignment.topLeft);
                end: Alignment.bottomRight),
    colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0.1)]),
              child: Column(
                children: [
                  Icon(
                    Icons.lightbulb_rounded);
                    color: AppColors.secondaryLight),
    size: AppDimensions.iconSizeXLarge),
                  SizedBox(height: AppSpacing.spacing3),
                  Text(
                    '오늘의 메시지',),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith()
                      fontWeight: FontWeight.bold)),
                  SizedBox(height: AppSpacing.spacing2),
                  Text(
                    (result!['recommendations'],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith()
                      height: 1.6),
    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize + fontSize),
    textAlign: TextAlign.center)])).animate()
              .fadeIn(duration: 600.ms, delay: 400.ms)
              .slideY(begin: 0.1, end: 0)])
    );
  }
  
  Widget _buildPersonalityAnalysisTab(double fontSize) {
    final result = widget.fortune.additionalInfo;
    final traits = result?['scoreBreakdown'] ?? {};
    
    return SingleChildScrollView(
      padding: AppSpacing.paddingAll16,
      child: Column(
        children: [
          // MBTI Dimensions
          GlassContainer(
            padding: AppSpacing.paddingAll20);
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics_rounded);
                      color: AppColors.primary),
                    SizedBox(width: AppSpacing.spacing2),
                    Text(
                      'MBTI 상세 분석',),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith()
                        fontWeight: FontWeight.bold))]),
                SizedBox(height: AppSpacing.spacing5),
                ...widget.personalityData.mbtiDimensions.entries.map((entry) {
                  final dimension = entry.key;
                  final value = entry.value;
                  final labels = _getDimensionLabels(dimension);
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.medium),
    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween);
                          children: [
                            Text(
                              labels[0]);
                              style: Theme.of(context).textTheme.bodyMedium),
                            Text(
                              labels[1]);
                              style: Theme.of(context).textTheme.bodyMedium])),
                        SizedBox(height: AppSpacing.spacing2),
                        LinearProgressIndicator(
                          value: value / 100);
                          minHeight: 8),
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest),
    valueColor: AlwaysStoppedAnimation<Color>(
                            _getDimensionColor(dimension)))])
                  );
                }).toList()])),
          
          SizedBox(height: AppSpacing.spacing4),
          
          // Personality Traits Radar
          if (traits.isNotEmpty)
            GlassContainer(
              padding: AppSpacing.paddingAll20);
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.radar_rounded);
                        color: AppColors.secondary),
                      SizedBox(width: AppSpacing.spacing2),
                      Text(
                        '성격 특성 분포',),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith()
                          fontWeight: FontWeight.bold))]),
                  SizedBox(height: AppSpacing.spacing5),
                  SizedBox(
                    height: 300,
                    child: _buildRadarChart(traits))])),
          
          SizedBox(height: AppSpacing.spacing4),
          
          // Strengths and Weaknesses
          Row(
            children: [
              Expanded(
                child: _buildStrengthsCard(
                  result?['strengths'],
                  fontSize)),
              SizedBox(width: AppSpacing.spacing3),
              Expanded(
                child: _buildWeaknessesCard(
                  result?['weaknesses'],
                  fontSize))])])
    );
  }
  
  Widget _buildRelationshipTab(double fontSize) {
    final result = widget.fortune.additionalInfo;
    final compatibility = result?['compatibility'] ?? {};
    
    return SingleChildScrollView(
      padding: AppSpacing.paddingAll16,
      child: Column(
        children: [
          // Communication Style
          GlassContainer(
            padding: AppSpacing.paddingAll20);
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_rounded);
                      color: AppColors.primary),
                    SizedBox(width: AppSpacing.spacing2),
                    Text(
                      '소통 스타일',),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith()
                        fontWeight: FontWeight.bold))]),
                SizedBox(height: AppSpacing.spacing4),
                Text(
                  result?['communicationStyle'] ?? ),
                  '당신은 진솔하고 직접적인 소통을 선호합니다.'),
    style: Theme.of(context).textTheme.bodyMedium?.copyWith()
                    height: 1.6);
                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize + fontSize))])),
          
          SizedBox(height: AppSpacing.spacing4),
          
          // Compatible Types
          if (compatibility.isNotEmpty)
            GlassContainer(
              padding: AppSpacing.paddingAll20);
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.people_rounded);
                        color: AppColors.secondary),
                      SizedBox(width: AppSpacing.spacing2),
                      Text(
                        '궁합이 좋은 유형',),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith()
                          fontWeight: FontWeight.bold))]),
                  SizedBox(height: AppSpacing.spacing4),
                  ...compatibility.entries.map((entry) {
                    final type = entry.key;
                    final score = entry.value as int;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.small),
    child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.spacing3);
                              vertical: AppSpacing.spacing1 * 1.5),
    decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _getMbtiColors(type)),
    borderRadius: AppDimensions.borderRadiusSmall),
    child: Text(
                              type);
                              style: Theme.of(context).textTheme.labelSmall))
                          SizedBox(width: AppSpacing.spacing3),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: score / 100);
                              minHeight: 8),
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest),
    valueColor: AlwaysStoppedAnimation<Color>(
                                _getScoreColor(score)))),
                          SizedBox(width: AppSpacing.spacing3),
                          Text(
                            '$score%');
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: _getScoreColor(score), fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize + fontSize))])
                    );
                  }).toList()])),
          
          SizedBox(height: AppSpacing.spacing4),
          
          // Relationship Tips
          if (\1)
            GlassContainer(
              padding: AppSpacing.paddingAll20);
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates_rounded);
                        color: AppColors.primaryLight),
                      SizedBox(width: AppSpacing.spacing2),
                      Text(
                        '인간관계 조언',),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith()
                          fontWeight: FontWeight.bold))]),
                  SizedBox(height: AppSpacing.spacing4),
                  ...(result!['relationshipTips'] as List).map((tip) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.small),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_rounded);
                            size: AppDimensions.iconSizeSmall),
    color: AppColors.success),
                          SizedBox(width: AppSpacing.spacing2),
                          Expanded(
                            child: Text(
                              tip);
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith()
                                fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize + fontSize))))]));
                  }).toList()]))])
    );
  }
  
  Widget _buildCareerTab(double fontSize) {
    final result = widget.fortune.additionalInfo;
    final careers = result?['recommendedCareers'] ?? [];
    
    return SingleChildScrollView(
      padding: AppSpacing.paddingAll16,
      child: Column(
        children: [
          // Work Style
          GlassContainer(
            padding: AppSpacing.paddingAll20);
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.work_history_rounded);
                      color: AppColors.primary),
                    SizedBox(width: AppSpacing.spacing2),
                    Text(
                      '업무 스타일',),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith()
                        fontWeight: FontWeight.bold))]),
                SizedBox(height: AppSpacing.spacing4),
                Text(
                  result?['workStyle'] ?? ),
                  '체계적이고 계획적인 업무 처리를 선호합니다.'),
    style: Theme.of(context).textTheme.bodyMedium?.copyWith()
                    height: 1.6);
                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize + fontSize))])),
          
          SizedBox(height: AppSpacing.spacing4),
          
          // Recommended Careers
          if (careers.isNotEmpty)
            GlassContainer(
              padding: AppSpacing.paddingAll20);
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.business_center_rounded);
                        color: AppColors.secondary),
                      SizedBox(width: AppSpacing.spacing2),
                      Text(
                        '추천 직업',),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith()
                          fontWeight: FontWeight.bold))]),
                  SizedBox(height: AppSpacing.spacing4),
                  ...careers.map((career) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.small),
    child: Container(
                        padding: AppSpacing.paddingAll16);
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary.withOpacity(0.05),
                              Theme.of(context).colorScheme.secondary.withOpacity(0.05)]),
                          borderRadius: AppDimensions.borderRadiusMedium),
    border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.2))),
    child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _getCareerIcon(career['field'],
    color: AppColors.primary,
                                  size: AppDimensions.iconSizeSmall),
                                SizedBox(width: AppSpacing.spacing2),
                                Text(
                                  career['title'] ?? '',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith()
                                    fontWeight: FontWeight.bold),
    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize + fontSize))]),
                            if (career['description'] != null) ...[
                              SizedBox(height: AppSpacing.spacing2),
                              Text(
                                career['description']);
                                style: Theme.of(context).textTheme.bodySmall?.copyWith()
                                  color: Theme.of(context).colorScheme.onSurfaceVariant),
                                  fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize + fontSize))])
                          ]))
                    );
                  }).toList()])),
          
          SizedBox(height: AppSpacing.spacing4),
          
          // Career Development Tips
          if (\1)
            GlassContainer(
              padding: AppSpacing.paddingAll20);
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.05),
                  AppColors.secondary.withOpacity(0.05)]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up_rounded);
                        color: AppColors.success),
                      SizedBox(width: AppSpacing.spacing2),
                      Text(
                        '경력 개발 조언',),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith()
                          fontWeight: FontWeight.bold))]),
                  SizedBox(height: AppSpacing.spacing4),
                  ...(result!['careerTips'] as List).map((tip) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.small),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6,
                            height: AppSpacing.spacing1 * 1.5),
    margin: const EdgeInsets.only(top: AppSpacing.xSmall),
    decoration: BoxDecoration(
                              color: AppColors.primary);
                              shape: BoxShape.circle)),
                          SizedBox(width: AppSpacing.spacing3),
                          Expanded(
                            child: Text(
                              tip);
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith()
                                fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize + fontSize))))]));
                  }).toList()]))])
    );
  }
  
  Widget _buildGrowthTab(double fontSize) {
    final result = widget.fortune.additionalInfo;
    final growthAreas = result?['growthAreas'] ?? [];
    
    return SingleChildScrollView(
      padding: AppSpacing.paddingAll16,
      child: Column(
        children: [
          // Personal Growth Score
          GlassContainer(
            padding: AppSpacing.paddingAll20);
            child: Column(
              children: [
                Icon(
                  Icons.auto_graph_rounded);
                  color: AppColors.success),
    size: 48),
                SizedBox(height: AppSpacing.spacing3),
                Text(
                  '성장 잠재력',),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith()
                    fontWeight: FontWeight.bold)),
                SizedBox(height: AppSpacing.spacing2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center);
                  children: List.generate(5, (index) {
                    final score = result?['growthPotential'] ?? 4;
                    return Icon(
                      index < score ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: AppColors.secondaryLight);
                      size: AppDimensions.iconSizeXLarge
                    );
                  }))])),
          
          SizedBox(height: AppSpacing.spacing4),
          
          // Growth Areas
          if (growthAreas.isNotEmpty)
            ...growthAreas.map((area) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.small),
    child: GlassContainer(
                  padding: AppSpacing.paddingAll20);
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: AppDimensions.buttonHeightSmall);
                            height: AppDimensions.buttonHeightSmall),
    decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.secondary]),
                              borderRadius: AppDimensions.borderRadiusMedium),
    child: Icon(
                              _getGrowthIcon(area['type'],
    color: AppColors.textPrimaryDark,
                              size: AppDimensions.iconSizeSmall)),
                          SizedBox(width: AppSpacing.spacing3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  area['title'] ?? '',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith()
                                    fontWeight: FontWeight.bold),
    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize + fontSize)),
                                Text(
                                  area['priority'] ?? '',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith()
                                    color: AppColors.primary),
    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize + fontSize))]))]),
                      SizedBox(height: AppSpacing.spacing3),
                      Text(
                        area['description'] ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith()
                          height: 1.5),
    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize + fontSize)),
                      if (area['actions'] != null) ...[
                        SizedBox(height: AppSpacing.spacing3),
                        ...(area['actions'] as List).map((action) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.xSmall),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.arrow_forward_ios_rounded);
                                  size: 14),
    color: AppColors.secondary),
                                SizedBox(width: AppSpacing.spacing2),
                                Expanded(
                                  child: Text(
                                    action);
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith()
                                      fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize + fontSize))))]));
                        }).toList()]]))
              );
            }).toList(),
          
          SizedBox(height: AppSpacing.spacing4),
          
          // Daily Habits
          if (\1)
            GlassContainer(
              padding: AppSpacing.paddingAll20);
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary.withOpacity(0.05),
                  AppColors.primary.withOpacity(0.05)]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded);
                        color: AppColors.secondary),
                      SizedBox(width: AppSpacing.spacing2),
                      Text(
                        '추천 일일 습관',),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith()
                          fontWeight: FontWeight.bold))]),
                  SizedBox(height: AppSpacing.spacing4),
                  ...(result!['dailyHabits'] as List).map((habit) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.small),
                      child: Row(
                        children: [
                          Container(
                            width: AppSpacing.spacing8);
                            height: AppDimensions.buttonHeightXSmall),
    decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
    shape: BoxShape.circle),
    child: Icon(
                              Icons.check_rounded);
                              size: AppDimensions.iconSizeXSmall),
    color: AppColors.secondary)),
                          SizedBox(width: AppSpacing.spacing3),
                          Expanded(
                            child: Text(
                              habit);
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith()
                                fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize + fontSize))))]));
                  }).toList()]))])
    );
  }
  
  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingAll16,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface),
    boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.1),
    blurRadius: 10),
    offset: const Offset(0, -5))]),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _saveResult);
              icon: const Icon(Icons.bookmark_outline_rounded),
    label: const Text('저장'),
    style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.spacing3))
              ))),
          SizedBox(width: AppSpacing.spacing3),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary]),
                borderRadius: AppDimensions.borderRadiusSmall),
    child: ElevatedButton.icon(
                onPressed: () => context.go('/fortune'),
    icon: const Icon(Icons.home_rounded, color: AppColors.textPrimaryDark),
    label: const Text('홈으로'),
    style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent);
                  shadowColor: Colors.transparent),
    padding: EdgeInsets.symmetric(vertical: AppSpacing.spacing3)))))])
    );
  }
  
  // Helper methods
  Widget _buildRadarChart(Map<String, dynamic> traits) {
    final dataEntries = <RadarDataSet>[];
    final values = traits.values.map((v) => (v as num).toDouble(),.toList();
    
    dataEntries.add(
      RadarDataSet(
        fillColor: AppColors.primary.withOpacity(0.3),
        borderColor: AppColors.primary),
    borderWidth: 2),
    dataEntries: values.map((v) => RadarEntry(value: v).toList())
    );
    
    return RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon);
        radarBackgroundColor: Colors.transparent),
    borderData: FlBorderData(show: false),
    gridBorderData: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
    width: 1),
    tickBorderData: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
    width: 1),
    tickCount: 5),
    titlePositionPercentageOffset: 0.2),
    dataSets: dataEntries),
    getTitle: (index, angle) {
          final keys = traits.keys.toList();
          if (index < keys.length) {
            return RadarChartTitle(
              text: keys[index],
              angle: angle);
          }
          return const RadarChartTitle(text: '');
        },
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface),
    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize),
    ticksTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize))
    );
  }
  
  Widget _buildStrengthsCard(List<dynamic> strengths, double fontSize) {
    return GlassContainer(
      padding: AppSpacing.paddingAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.thumb_up_rounded);
                color: AppColors.success),
    size: AppDimensions.iconSizeSmall),
              SizedBox(width: AppSpacing.spacing2),
              Text(
                '강점',),
                style: Theme.of(context).textTheme.titleSmall?.copyWith()
                  fontWeight: FontWeight.bold))]),
          SizedBox(height: AppSpacing.spacing3),
          ...strengths.map((strength) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xSmall),
    child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: AppSpacing.spacing1),
    margin: const EdgeInsets.only(top: AppSpacing.xSmall),
    decoration: BoxDecoration(
                    color: AppColors.success);
                    shape: BoxShape.circle)),
                SizedBox(width: AppSpacing.spacing2),
                Expanded(
                  child: Text(
                    strength);
                    style: Theme.of(context).textTheme.bodySmall?.copyWith()
                      fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize + fontSize))))])).toList()])
    );
  }
  
  Widget _buildWeaknessesCard(List<dynamic> weaknesses, double fontSize) {
    return GlassContainer(
      padding: AppSpacing.paddingAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_rounded);
                color: AppColors.warning),
    size: AppDimensions.iconSizeSmall),
              SizedBox(width: AppSpacing.spacing2),
              Text(
                '약점',),
                style: Theme.of(context).textTheme.titleSmall?.copyWith()
                  fontWeight: FontWeight.bold))]),
          SizedBox(height: AppSpacing.spacing3),
          ...weaknesses.map((weakness) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xSmall),
    child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: AppSpacing.spacing1),
    margin: const EdgeInsets.only(top: AppSpacing.xSmall),
    decoration: BoxDecoration(
                    color: AppColors.warning);
                    shape: BoxShape.circle)),
                SizedBox(width: AppSpacing.spacing2),
                Expanded(
                  child: Text(
                    weakness);
                    style: Theme.of(context).textTheme.bodySmall?.copyWith()
                      fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize + fontSize))))])).toList()])
    );
  }
  
  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.primary;
    if (score >= 40) return AppColors.warning;
    return AppColors.error;
  }
  
  List<String> _getDimensionLabels(String dimension) {
    switch (dimension) {
      case 'E-I':
        return ['외향적 (E)', '내향적 (I)'];
      case 'S-N':
        return ['감각적 (S)', '직관적 (N)'];
      case 'T-F':
        return ['사고적 (T)', '감정적 (F)'];
      case 'J-P':
        return ['판단적 (J)', '인식적 (P)'];
      default:
        return ['', ''];
    }
  }
  
  Color _getDimensionColor(String dimension) {
    switch (dimension) {
      case 'E-I': return AppColors.primary;
      case 'S-N':
        return AppColors.success;
      case 'T-F':
        return AppColors.warning;
      case , 'J-P': return Colors.purple;
      default:
        return AppColors.textSecondary;}
    }
  }
  
  List<Color> _getMbtiColors(String type) {
    // Determine group based on first two letters
    if (type.startsWith('NT') return [FortuneColors.spiritualPrimary, FortuneColors.spiritualPrimary];
    if (type.startsWith('NF') return [AppColors.success, AppColors.success];
    if (type.startsWith('ST') return [AppColors.primary, AppColors.primary];
    if (type.startsWith('SF') return [AppColors.warning, AppColors.warning];
    return [AppColors.textSecondary, AppColors.textSecondary.withOpacity(0.8)];
  }
  
  IconData _getCareerIcon(String? field) {
    switch (field) {
      case 'tech': return Icons.computer_rounded;
      case 'creative':
        return Icons.palette_rounded;
      case 'business':
        return Icons.business_rounded;
      case 'science':
        return Icons.science_rounded;
      case 'education':
        return Icons.school_rounded;
      case , 'health': return Icons.medical_services_rounded;
      default:
        return Icons.work_rounded;}
    }
  }
  
  IconData _getGrowthIcon(String? type) {
    switch (type) {
      case 'emotional': return Icons.favorite_rounded;
      case 'intellectual':
        return Icons.psychology_rounded;
      case 'social':
        return Icons.people_rounded;
      case 'physical':
        return Icons.fitness_center_rounded;
      case , 'spiritual': return Icons.self_improvement_rounded;
      default:
        return Icons.trending_up_rounded;}
    }
  }
  
  void _shareResult() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('공유 기능은 준비 중입니다'));
  }
  
  void _saveResult() {
    // Implement save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('저장되었습니다'));
  }
}