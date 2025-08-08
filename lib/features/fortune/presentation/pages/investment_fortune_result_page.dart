import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

import '../../../../domain/entities/fortune.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import 'investment_fortune_enhanced_page.dart';

class InvestmentFortuneResultPage extends ConsumerStatefulWidget {
  final Fortune fortune;
  final InvestmentFortuneData investmentData;

  const InvestmentFortuneResultPage({
    Key? key,
    required this.fortune,
    required this.investmentData}) : super(key: key);

  @override
  ConsumerState<InvestmentFortuneResultPage> createState() => _InvestmentFortuneResultPageState();
}

class _InvestmentFortuneResultPageState extends ConsumerState<InvestmentFortuneResultPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut);
    
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic);
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fortuneData = widget.fortune.additionalInfo ?? {};
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '투자 운세 결과',),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.8)])),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: CustomPaint(
                        painter: InvestmentPatternPainter())),
                    // Center icon
                    Center(
                      child: Icon(
                        Icons.auto_graph_rounded,
                        size: 80,
                        color: Colors.white.withOpacity(0.3)))]))),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => context.pop()),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                onPressed: _shareFortune)]),
          
          // Overall Score
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: _buildOverallScore(fortuneData)));
              })),
          
          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: theme.colorScheme.primary,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                tabs: const [
                  Tab(text: '종합 분석'),
                  Tab(text: '섹터별 운세'),
                  Tab(text: '투자 타이밍'),
                  Tab(text: '행운 정보')]))),
          
          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverallAnalysis(fortuneData),
                _buildSectorAnalysis(fortuneData),
                _buildTimingAnalysis(fortuneData),
                _buildLuckyInfo(fortuneData)]))]));
  }

  Widget _buildOverallScore(Map<String, dynamic> fortuneData) {
    final score = fortuneData['overallScore'] ?? 75;
    final scoreLabel = _getScoreLabel(score);
    final scoreColor = _getScoreColor(score);
    
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scoreColor.withOpacity(0.2),
            scoreColor.withOpacity(0.1)]),
        borderRadius: BorderRadius.circular(20))),
        border: Border.all(
          color: scoreColor.withOpacity(0.5),
          width: 2)),
      child: Column(
        children: [
          Text(
            '오늘의 투자 운세 점수',),
            style: Theme.of(context).textTheme.titleMedium)),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor))),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: scoreColor)),
                  Text(
                    scoreLabel,
                    style: TextStyle(
                      fontSize: 16,
                      color: scoreColor,
                      fontWeight: FontWeight.w600))])]),
          const SizedBox(height: 24),
          Text(
            fortuneData['summary'] ?? '오늘은 투자에 좋은 날입니다.',
            style: Theme.of(context).textTheme.bodyLarge),
            textAlign: TextAlign.center)])).animate(,
      .fadeIn(duration: 600.ms, delay: 200.ms,
      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0);
  }

  Widget _buildOverallAnalysis(Map<String, dynamic> fortuneData) {
    final analysis = fortuneData['overallAnalysis'] as Map<String, dynamic>?;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalysisSection(
            '투자 성향 분석',
            analysis?['personality'] ?? '당신은 균형잡힌 투자자입니다.',
            Icons.psychology_rounded,
            const Color(0xFF2563EB)),
          const SizedBox(height: 24),
          
          _buildAnalysisSection(
            '오늘의 투자 운세',
            analysis?['todaysFortune'] ?? '금전운이 상승하고 있습니다.',
            Icons.trending_up_rounded,
            const Color(0xFF16A34A)),
          const SizedBox(height: 24),
          
          _buildAnalysisSection(
            '주의사항',
            analysis?['warnings'] ?? '과도한 레버리지는 피하세요.',
            Icons.warning_rounded,
            const Color(0xFFDC2626)),
          const SizedBox(height: 24),
          
          if (widget.investmentData.wantPortfolioReview)
            _buildPortfolioChart(analysis?['portfolio']),
          
          if (widget.investmentData.wantRiskAnalysis)
            _buildRiskAnalysis(analysis?['riskAnalysis']]));
  }

  Widget _buildAnalysisSection(String title, String content, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16))),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith()
                  fontWeight: FontWeight.bold,
                  color: color))]),
          const SizedBox(height: 12),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium)])).animate(),
      .fadeIn(duration: 500.ms,
      .slideX(begin: 0.1, end: 0);
  }

  Widget _buildPortfolioChart(Map<String, dynamic>? portfolioData) {
    final sectors = widget.investmentData.selectedSectors;
    final sectorData = sectors.map((sector) {
      final priority = widget.investmentData.sectorPriorities[sector] ?? 0.0;
      return PieChartSectionData(
        value: priority,
        title: '${sector.label}\n${priority.round()}%',
        color: sector.gradientColors[0],
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white));
    }).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '추천 포트폴리오',),
          style: Theme.of(context).textTheme.titleMedium?.copyWith()
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16)),
          child: PieChart(
            PieChartData(
              sections: sectorData,
              centerSpaceRadius: 60,
              sectionsSpace: 2,
              startDegreeOffset: -90)))]
    );
  }

  Widget _buildRiskAnalysis(Map<String, dynamic>? riskData) {
    final risks = riskData?['risks'] as List<dynamic>? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          '위험 관리 분석',),
          style: Theme.of(context).textTheme.titleMedium?.copyWith()
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...risks.map((risk) => _buildRiskItem(risk).toList()]);
  }

  Widget _buildRiskItem(dynamic risk) {
    final level = risk['level'] ?? 'medium';
    final color = level == 'high' ? Colors.red
                : level == 'medium' ? Colors.orange
                : Colors.green;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12))),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1)),
      child: Row(
        children: [
          Icon(
            level == 'high' ? Icons.error_rounded
          : level == 'medium' ? Icons.warning_rounded
          : Icons.check_circle_rounded,
            color: color,
            size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  risk['title'] ?? '',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith()
                    fontWeight: FontWeight.bold)),
                Text(
                  risk['description'] ?? '',
                  style: Theme.of(context).textTheme.bodySmall)]))]));)
  }

  Widget _buildSectorAnalysis(Map<String, dynamic> fortuneData) {
    final sectorFortuneData = fortuneData['sectorFortune'] as Map<String, dynamic>? ?? {};
    
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: widget.investmentData.selectedSectors.length,
      itemBuilder: (context, index) {
        final sector = widget.investmentData.selectedSectors[index];
        final sectorFortune = sectorFortuneData[sector.name] as Map<String, dynamic>? ?? {};
        
        return _buildSectorCard(sector, sectorFortune, index);
      }
    );
  }

  Widget _buildSectorCard(InvestmentSector sector, Map<String, dynamic> sectorFortune, int index) {
    final score = sectorFortune['score'] ?? 70;
    final recommendation = sectorFortune['recommendation'] ?? '보통';
    final analysis = sectorFortune['analysis'] ?? '안정적인 투자를 권합니다.';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            sector.gradientColors[0].withOpacity(0.2),
            sector.gradientColors[1].withOpacity(0.1)]),
        borderRadius: BorderRadius.circular(16))),
        border: Border.all(
          color: sector.gradientColors[0].withOpacity(0.5),
          width: 1)),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(sector.icon, color: sector.gradientColors[0], size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sector.label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith()
                      fontWeight: FontWeight.bold)),
                  Text(
                    '점수: $score점',),
                    style: Theme.of(context).textTheme.bodySmall)]))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getRecommendationColor(recommendation),
                borderRadius: BorderRadius.circular(12)),
              child: Text(
                recommendation,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)))]),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Score bar
                LinearProgressIndicator(
                  value: score / 100,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(sector.gradientColors[0]),
                  minHeight: 8),
                const SizedBox(height: 16),
                Text(
                  analysis,
                  style: Theme.of(context).textTheme.bodyMedium)),
                if (sectorFortune['tips'] != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    '💡 팁',),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith()
                      fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    sectorFortune['tips'],
                    style: Theme.of(context).textTheme.bodySmall)]]))])).animate(),
      .fadeIn(duration: 500.ms, delay: (100 * index).ms,
      .slideY(begin: 0.1, end: 0);
  }

  Widget _buildTimingAnalysis(Map<String, dynamic> fortuneData) {
    final timing = fortuneData['marketTiming'] as Map<String, dynamic>? ?? {};
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.investmentData.wantMarketTiming) ...[
            _buildTimingSection('오늘의 타이밍': timing['today'],
            const SizedBox(height: 24,
            _buildTimingSection('이번 주 타이밍': timing['week'],
            const SizedBox(height: 24,
            _buildTimingSection('이번 달 타이밍': timing['month'],
            const SizedBox(height: 24],
          
          _buildLuckyDaysCalendar(timing['luckyDays']]));
  }

  Widget _buildTimingSection(String title, dynamic timingData, IconData icon) {
    final isBuy = timingData?['action'] == 'buy';
    final strength = timingData?['strength'] ?? 'medium';
    final description = timingData?['description'] ?? '';
    
    final color = isBuy ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1)]),
        borderRadius: BorderRadius.circular(16))),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith()
                  fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12)),
                child: Text(
                  isBuy ? '매수' : '매도',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold)))]),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '강도: ',),
                style: Theme.of(context).textTheme.bodySmall)),
              ...List.generate(5, (index) {
                final filled = strength == 'strong' ? index < 5
                              : strength == 'medium' ? index < 3
                              : index < 1;
                return Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 16,
                  color: color);
              })]),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium)]));)
  }

  Widget _buildLuckyDaysCalendar(List<dynamic>? luckyDays) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '투자 길일',),
          style: Theme.of(context).textTheme.titleMedium?.copyWith()
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              // Calendar grid here
              Text(
                '길일: ${luckyDays?.join(', ') ?? '15일, 23일, 28일'}',
                style: Theme.of(context).textTheme.bodyMedium)]))])
    );
  }

  Widget _buildLuckyInfo(Map<String, dynamic> fortuneData) {
    final luckyInfo = fortuneData['luckyInfo'] as Map<String, dynamic>? ?? {};
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.investmentData.wantLuckyNumbers)
            _buildLuckyNumbers(luckyInfo['numbers']),
          
          const SizedBox(height: 24),
          _buildLuckyColors(luckyInfo['colors']),
          
          const SizedBox(height: 24),
          _buildLuckyDirections(luckyInfo['directions']),
          
          if (widget.investmentData.specificQuestion?.isNotEmpty ?? false) ...[
            const SizedBox(height: 24),
            _buildSpecificAnswer(fortuneData['specificAnswer']]]));
  }

  Widget _buildLuckyNumbers(dynamic numbersData) {
    final lottoNumbers = numbersData?['lotto'] as List<dynamic>? ?? [7, 14, 21, 28, 35, 42];
    final luckyNumbers = numbersData?['general'] as List<dynamic>? ?? [3, 7, 9];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '행운의 숫자',),
          style: Theme.of(context).textTheme.titleMedium?.copyWith()
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        
        // Lotto numbers
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.withOpacity(0.2),
                Colors.orange.withOpacity(0.1)]),
            borderRadius: BorderRadius.circular(16))),
            border: Border.all(
              color: Colors.amber.withOpacity(0.5),
              width: 1)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.casino_rounded, color: Colors.amber, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    '로또 추천 번호',),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith()
                      fontWeight: FontWeight.bold))]),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                children: lottoNumbers.map((number) {
                  return Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.amber, Colors.orange])),
                    child: Center(
                      child: Text(
                        '$number',),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18))));
                }).toList())])),
        
        const SizedBox(height: 16),
        
        // General lucky numbers
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '오늘의 행운 숫자',),
                style: Theme.of(context).textTheme.titleSmall?.copyWith()
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                luckyNumbers.join(', ',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith()
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold))]))]
    );
  }

  Widget _buildLuckyColors(dynamic colorsData) {
    final colors = colorsData as List<dynamic>? ?? \['['red', 'gold', 'green'];
    final colorMap = {
      'red': const Color(0xFFDC2626,
      'gold': const Color(0xFFFACC15),
      'green': const Color(0xFF16A34A),
      'blue': const Color(0xFF2563EB),
      'purple': null};
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '행운의 색상',),
          style: Theme.of(context).textTheme.titleMedium?.copyWith()
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: colors.map((colorName) {
            final color = colorMap[colorName] ?? Colors.grey;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 80,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: Text(
                    _getColorLabel(colorName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold)))));
          }).toList())]
    );
  }

  Widget _buildLuckyDirections(dynamic directionsData) {
    final directions = directionsData as List<dynamic>? ?? ['동쪽', '남동쪽'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '행운의 방향',),
          style: Theme.of(context).textTheme.titleMedium?.copyWith()
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              const Icon(Icons.explore_rounded, size: 48, color: Color(0xFF2563EB),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      directions.join(', ',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith()
                        fontWeight: FontWeight.bold)),
                    Text(
                      '이 방향으로 투자 기회를 찾아보세요',),
                      style: Theme.of(context).textTheme.bodySmall)]))]))]);)
  }

  Widget _buildSpecificAnswer(dynamic answer) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1)]),
        borderRadius: BorderRadius.circular(16))),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.investmentData.specificQuestion!,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith()
                    fontWeight: FontWeight.bold)))]),
          const SizedBox(height: 12),
          Text(
            answer ?? '당신의 직감을 믿고 신중하게 결정하세요.',
            style: Theme.of(context).textTheme.bodyMedium)]));)
  }

  // Helper methods
  String _getScoreLabel(int score) {
    if (score >= 90) return '최고의 날';
    if (score >= 80) return '매우 좋음';
    if (score >= 70) return '좋음';
    if (score >= 60) return '보통';
    if (score >= 50) return '주의';
    return '위험';
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF16A34A)
    if (score >= 60) return const Color(0xFFFACC15)
    if (score >= 40) return const Color(0xFFFF8F00)
    return const Color(0xFFDC2626);
  }

  Color _getRecommendationColor(String recommendation) {
    switch (recommendation) {
      case '매수': return const Color(0xFF16A34A);
      case '매도':
        return const Color(0xFFDC2626);
      case , '관망': return const Color(0xFF6B7280);
      default:
        return const Color(0xFF3B82F6);}
    }
  }

  String _getColorLabel(String colorName) {
    final labels = {
      'red', '빨강',
      'gold', '금색',
      'green', '초록',
      'blue', '파랑',
      'purple', '보라'};
    return labels[colorName] ?? colorName;
  }

  void _shareFortune() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('공유 기능은 준비 중입니다.'));
  }
}

// Custom painter for background pattern
class InvestmentPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
     
   
    ..color = Colors.white.withOpacity(0.1);

    // Draw grid pattern
    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw trend lines
    paint.strokeWidth = 2.0;
    paint.color = Colors.white.withOpacity(0.2);
    
    final path = Path();
    path.moveTo(0, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.3, size.height * 0.4,
      size.width * 0.6, size.height * 0.5
    );
    path.quadraticBezierTo(
      size.width * 0.8, size.height * 0.6,
      size.width, size.height * 0.3
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom sliver delegate for tab bar
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: tabBar
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}