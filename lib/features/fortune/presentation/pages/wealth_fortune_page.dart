import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../shared/components/loading_states.dart';
import '../../../../shared/components/toast.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/glassmorphism/glass_effects.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/providers/fortune_provider.dart';

class WealthFortunePage extends BaseFortunePage {
  const WealthFortunePage({
    Key? key,
    Map<String, dynamic>? initialParams}) : super(
          key: key,
          title: '재물운',
          description: '당신의 재물운을 확인해보세요',
          fortuneType: 'wealth',
          requiresUserInfo: false,
          initialParams: initialParams);

  @override
  ConsumerState<WealthFortunePage> createState() => _WealthFortunePageState();
}

class _WealthFortunePageState extends BaseFortunePageState<WealthFortunePage> {
  Map<String, dynamic>? _wealthData;
  late AnimationController _coinController;
  late Animation<double> _coinAnimation;

  @override
  void initState() {
    super.initState();
    _coinController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this)..repeat();
    _coinAnimation = CurvedAnimation(
      parent: _coinController,
      curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _coinController.dispose();
    super.dispose();
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    final wealthNotifier = ref.read(wealthFortuneProvider.notifier);

    if (params.isNotEmpty) {
      wealthNotifier.setFinancialData(params);
    } else {
      wealthNotifier.setFinancialData({
        'monthlyIncome': 0,
        'monthlySavings': 0,
        'investmentGoals': 0});
    }

    await wealthNotifier.loadFortune();

    final state = ref.read(wealthFortuneProvider);
    if (state.error != null) {
      throw Exception(state.error);
    }
    if (state.fortune == null) {
      throw Exception('운세를 불러올 수 없습니다');
    }

    _wealthData = {
      'wealthIndex': 85,
      'monthlyTrend': [
        {'month': '1월', 'value': 65},
        {'month': '2월', 'value': 70},
        {'month': '3월', 'value': 75},
        {'month': '4월', 'value': 80},
        {'month': '5월', 'value': 85},
        {'month': '6월', 'value': 90}],
      'incomeBreakdown': {
        '주 수입': 75,
        '부 수입': 85,
        '투자 수익': 70,
        '예상외 수입': 60},
      'financialAdvice': {
        'summary': '재물운이 상승하는 시기입니다',
        'details': '이번 달은 예상치 못한 수입이 들어올 가능성이 높습니다. 투자보다는 저축에 집중하며 미래를 준비하는 것이 좋겠습니다.',
        'warnings': [
          '충동구매를 주의하세요',
          '과도한 투자는 피하세요',
          '계획적인 소비를 하세요']},
      'luckyInvestments': [
        {'type': '부동산', 'score': 88, 'description': '안정적인 수익 예상'},
        {'type': '주식', 'score': 72, 'description': '변동성 주의 필요'},
        {'type': '예적금', 'score': 95, 'description': '가장 안전한 선택'},
        {'type': '암호화폐', 'score': 45, 'description': '높은 위험도'}],
      'spendingCategories': {
        '생활비': {'percentage': 35, 'status': '적정'},
        '여가/취미': {'percentage': 20, 'status': '양호'},
        '저축': {'percentage': 30, 'status': '우수'},
        '투자': {'percentage': 15, 'status': '적정'}},
      'wealthBoosters': {
        '행운의 숫자': ['7', '23', '45'],
        '행운의 방향': '동쪽',
        '행운의 색상': '금색, 노란색',
        '행운의 시간': '오전 9시~11시'},
      'actionItems': [
        '매일 가계부 작성하기',
        '월 저축 목표 설정하기',
        '불필요한 구독 서비스 정리하기',
        '투자 포트폴리오 점검하기',
        '비상금 준비하기']};

    final fortune = state.fortune!;
    return Fortune(
      id: fortune.id,
      userId: fortune.userId,
      type: fortune.type,
      content: fortune.content,
      createdAt: fortune.createdAt,
      category: 'wealth',
      overallScore: fortune.overallScore ?? 85,
      description: fortune.description ??
          '전반적으로 좋은 재물운이 예상됩니다. 예상치 못한 수입과 함께 저축의 기회가 찾아올 것입니다.',
      scoreBreakdown:
          fortune.scoreBreakdown ?? _wealthData!['incomeBreakdown'],
      luckyItems:
          fortune.luckyItems ?? _wealthData!['wealthBoosters'],
      recommendations: fortune.recommendations ?? [
        '계획적인 소비 습관을 유지하세요',
        '투자는 신중하게 접근하세요',
        '비상금을 준비하는 것이 좋습니다']);
  }

  @override
  Widget buildFortuneResult() {
    return Column(
      children: [
        _buildWealthIndexCard(),
        const SizedBox(height: 24),
        _buildMonthlyTrendChart(),
        const SizedBox(height: 24),
        _buildIncomeBreakdown(),
        const SizedBox(height: 24),
        _buildFinancialAdvice(),
        const SizedBox(height: 24),
        _buildLuckyInvestments(),
        const SizedBox(height: 24),
        _buildSpendingAnalysis(),
        const SizedBox(height: 24),
        _buildWealthBoosters(),
        const SizedBox(height: 24),
        _buildActionItems(),
        const SizedBox(height: 32)]);
  }

  Widget _buildWealthIndexCard() {
    final wealthIndex = _wealthData!['wealthIndex'] as int;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LiquidGlassContainer(
        padding: const EdgeInsets.all(32),
        borderRadius: BorderRadius.circular(32),
        liquidColors: [
          Colors.amber.shade200,
          Colors.yellow.shade300,
          Colors.orange.shade200],
        child: Column(
          children: [
            RotationTransition(
              turns: _coinAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.amber.shade300,
                      Colors.amber.shade600]),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 10)]),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '₩',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                      Text(
                        '$wealthIndex점',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold))])))),
            const SizedBox(height: 24),
            Text(
              '재물 지수',
              style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              _getWealthIndexMessage(wealthIndex),
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center)])));
  }

  Widget _buildMonthlyTrendChart() {
    final trendData = _wealthData!['monthlyTrend'] as List<dynamic>;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600]),
                    borderRadius: BorderRadius.circular(12)),
                  child: const Icon(
                    Icons.show_chart_rounded,
                    color: Colors.white,
                    size: 24)),
                const SizedBox(width: 12),
                Text(
                  '월별 재물운 추이',
                  style: Theme.of(context).textTheme.headlineSmall)]),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1);
                    }),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < trendData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                trendData[value.toInt()]['month'],
                                style: const TextStyle(fontSize: 12)));
                          }
                          return const Text('');
                        })),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: const TextStyle(fontSize: 10));
                        }))),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: trendData.length - 1.0,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: trendData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value['value'].toDouble());
                      }).toList(),
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.shade400,
                          Colors.orange.shade400]),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: Colors.amber.shade600);
                        }),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade200.withOpacity(0.3),
                            Colors.amber.shade100.withOpacity(0.1)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter)))])))])));
  }

  Widget _buildIncomeBreakdown() {
    final breakdown = _wealthData!['incomeBreakdown'] as Map<String, dynamic>;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600]),
                    borderRadius: BorderRadius.circular(12)),
                  child: const Icon(
                    Icons.pie_chart_rounded,
                    color: Colors.white,
                    size: 24)),
                const SizedBox(width: 12),
                Text(
                  '수입원별 운세',
                  style: Theme.of(context).textTheme.headlineSmall)]),
            const SizedBox(height: 20),
            ...breakdown.entries.map((entry) {
              final score = entry.value as int;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodyMedium)),
                    Expanded(
                      flex: 7,
                      child: Row(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                Container(
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12))),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 1000),
                                  height: 24,
                                  width: MediaQuery.of(context).size.width * 0.4 * score / 100,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        _getIncomeColor(score),
                                        _getIncomeColor(score).withOpacity(0.7)]),
                                    borderRadius: BorderRadius.circular(12)))])),
                          const SizedBox(width: 12),
                          Text(
                            '$score점',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _getIncomeColor(score)))]))]));
            }).toList()])));
  }

  Widget _buildFinancialAdvice() {
    final advice = _wealthData!['financialAdvice'] as Map<String, dynamic>;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.indigo.shade400, Colors.indigo.shade600]),
                    borderRadius: BorderRadius.circular(12)),
                  child: const Icon(
                    Icons.lightbulb_rounded,
                    color: Colors.white,
                    size: 24)),
                const SizedBox(width: 12),
                Text(
                  '재테크 조언',
                  style: Theme.of(context).textTheme.headlineSmall)]),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    advice['summary'],
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700)),
                  const SizedBox(height: 8),
                  Text(
                    advice['details'],
                    style: Theme.of(context).textTheme.bodyMedium)])),
            const SizedBox(height: 16),
            Text(
              '주의사항',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...(advice['warnings'] as List<dynamic>).map((warning) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange.shade600,
                      size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        warning.toString(),
                        style: Theme.of(context).textTheme.bodyMedium))]));
            }).toList()])));
  }

  Widget _buildLuckyInvestments() {
    final investments = _wealthData!['luckyInvestments'] as List<dynamic>;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade400, Colors.purple.shade600]),
                    borderRadius: BorderRadius.circular(12)),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: Colors.white,
                    size: 24)),
                const SizedBox(width: 12),
                Text(
                  '투자 운세',
                  style: Theme.of(context).textTheme.headlineSmall)])),
          const SizedBox(height: 16),
          ...investments.map((investment) {
            final type = investment['type'] as String;
            final score = investment['score'] as int;
            final description = investment['description'] as String;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircularPercentIndicator(
                      radius: 30,
                      lineWidth: 6,
                      percent: score / 100,
                      center: Text(
                        '$score',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold)),
                      progressColor: _getInvestmentColor(score),
                      backgroundColor: Colors.grey.shade200,
                      animation: true,
                      animationDuration: 1000),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))])])))));
          }).toList()]));
  }

  Widget _buildSpendingAnalysis() {
    final categories = _wealthData!['spendingCategories'] as Map<String, dynamic>;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade400, Colors.orange.shade600]),
                    borderRadius: BorderRadius.circular(12)),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 24)),
                const SizedBox(width: 12),
                Text(
                  '지출 분석',
                  style: Theme.of(context).textTheme.headlineSmall)]),
            const SizedBox(height: 20),
            ...categories.entries.map((entry) {
              final category = entry.key;
              final data = entry.value as Map<String, dynamic>;
              final percentage = data['percentage'] as int;
              final status = data['status'] as String;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        category,
                        style: Theme.of(context).textTheme.bodyMedium)),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(15))),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 1000),
                            height: 30,
                            width: MediaQuery.of(context).size.width * 0.5 * percentage / 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _getSpendingColors(status)),
                              borderRadius: BorderRadius.circular(15)),
                            child: Center(
                              child: Text(
                                '$percentage%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12))))])),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontSize: 12,
                          fontWeight: FontWeight.bold)))]));
            }).toList()])));
  }

  Widget _buildWealthBoosters() {
    final boosters = _wealthData!['wealthBoosters'] as Map<String, dynamic>;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ShimmerGlass(
        shimmerColor: Colors.amber,
        borderRadius: BorderRadius.circular(24),
        child: GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade400, Colors.amber.shade600]),
                      borderRadius: BorderRadius.circular(12)),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 24)),
                  const SizedBox(width: 12),
                  Text(
                    '재물 부스터',
                    style: Theme.of(context).textTheme.headlineSmall)]),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: boosters.entries.map((entry) {
                  final value = entry.value;
                  String displayValue = '';
                  if (value is List) {
                    displayValue = value.join(', ');
                  } else {
                    displayValue = value.toString();
                  }
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.shade50,
                          Colors.amber.shade100]),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.shade300)),
                    child: Row(
                      children: [
                        Icon(
                          _getBoosterIcon(entry.key),
                          color: Colors.amber.shade700,
                          size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                entry.key,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.amber.shade800,
                                      fontSize: 10)),
                              Text(
                                displayValue,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber.shade900,
                                      fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis)]))]));
                }).toList())]))));
  }

  Widget _buildActionItems() {
    final items = _wealthData!['actionItems'] as List<dynamic>;
    final List<bool> itemChecks = List.filled(items.length, false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade400, Colors.teal.shade600]),
                    borderRadius: BorderRadius.circular(12)),
                  child: const Icon(
                    Icons.checklist_rounded,
                    color: Colors.white,
                    size: 24)),
                const SizedBox(width: 12),
                Text(
                  '재물운 향상 액션 플랜',
                  style: Theme.of(context).textTheme.headlineSmall)]),
            const SizedBox(height: 20),
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value as String;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2))),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.teal.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: Theme.of(context).textTheme.bodyMedium))])));
            }).toList()])));
  }

  String _getWealthIndexMessage(int score) {
    if (score >= 90) return '최고의 재물운! 큰 수익이 예상됩니다 💰';
    if (score >= 80) return '좋은 재물운! 적극적인 재테크를 시작하세요 💵';
    if (score >= 70) return '평균적인 재물운. 꾸준한 저축이 중요합니다';
    if (score >= 60) return '조금 부족한 재물운. 지출을 줄이고 절약하세요';
    return '재물운이 좋지 않습니다. 신중한 소비가 필요해요';
  }

  Color _getIncomeColor(int score) {
    if (score >= 80) return Colors.green.shade500;
    if (score >= 60) return Colors.blue.shade500;
    return Colors.orange.shade500;
  }

  Color _getInvestmentColor(int score) {
    if (score >= 80) return Colors.green.shade600;
    if (score >= 60) return Colors.amber.shade600;
    if (score >= 40) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  List<Color> _getSpendingColors(String status) {
    switch (status) {
      case '우수':
        return [Colors.green.shade400, Colors.green.shade600];
      case '양호':
        return [Colors.blue.shade400, Colors.blue.shade600];
      case '적정':
        return [Colors.amber.shade400, Colors.amber.shade600];
      default:
        return [Colors.red.shade400, Colors.red.shade600];
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '우수': 
        return Colors.green.shade600;
      case '양호':
        return Colors.blue.shade600;
      case '적정':
        return Colors.amber.shade600;
      default:
        return Colors.red.shade600;
    }
  }

  IconData _getBoosterIcon(String type) {
    switch (type) {
      case '행운의 숫자': 
        return Icons.looks_one_rounded;
      case '행운의 방향':
        return Icons.explore_rounded;
      case '행운의 색상':
        return Icons.palette_rounded;
      case '행운의 시간':
        return Icons.access_time_rounded;
      default:
        return Icons.star_rounded;
    }
  }
}
