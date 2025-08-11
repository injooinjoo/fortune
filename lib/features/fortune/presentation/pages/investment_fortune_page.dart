import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum InvestmentType {
  stock('주식', 'stock', Icons.trending_up),
  crypto('암호화폐', 'crypto', Icons.currency_bitcoin),
  realEstate('부동산', 'real_estate', Icons.home),
  lottery('복권', 'lottery', Icons.casino),
  general('종합', 'general', Icons.analytics),
  sidejob('부업', 'sidejob', Icons.work);
  
  final String label;
  final String value;
  final IconData icon;
  const InvestmentType(this.label, this.value, this.icon);
  
  
}

class InvestmentFortunePage extends BaseFortunePage {
  final InvestmentType initialType;
  
  const InvestmentFortunePage({
    Key? key,
    this.initialType = InvestmentType.general}) : super(
          key: key,
          title: '투자/재테크 운세',
          description: '오늘의 투자 운세를 확인하고 현명한 결정을 내리세요',
          fortuneType: 'investment',
          requiresUserInfo: false
        );

  @override
  ConsumerState<InvestmentFortunePage> createState() => _InvestmentFortunePageState();
}

class _InvestmentFortunePageState extends BaseFortunePageState<InvestmentFortunePage> {
  late InvestmentType _selectedType;
  Map<String, dynamic>? _investmentData;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final fortuneService = ref.read(fortuneServiceProvider);
    
    params['investmentType'] = _selectedType.value;
    
    final fortune = await fortuneService.getInvestmentFortune(
      userId: params['userId'],
      fortuneType: _selectedType.value,
      params: {
        'investmentType': _selectedType.value}
    );

    // Extract investment-specific data
    _investmentData = _extractInvestmentData(fortune);
    
    return fortune;
  }

  void _onGenerateFortune() {
    // Get user profile and generate fortune
    final profile = userProfile;
    if (profile != null) {
      final params = {
        'userId': profile.id,
        'name': profile.name,
        'birthDate': profile.birthDate?.toIso8601String(),
        'gender': null
      }
      generateFortune(params);
    }
  }

  Map<String, dynamic> _extractInvestmentData(Fortune fortune) {
    // Extract type-specific data
    switch (_selectedType) {
      case InvestmentType.stock:
        return {
          'sectors': ['IT', '바이오', '제조업', '금융', '소비재'],
          'scores': [85, 70, 60, 75, 80],
          'recommendations': ['성장주 주목', '단기 매매 자제', '분산 투자 필수']
        }
      case InvestmentType.crypto:
        return {
          'coins': ['BTC', 'ETH', 'SOL', 'BNB', 'XRP'],
          'scores': [75, 80, 65, 70, 60],
          'volatility': 'high',
          'recommendations': ['변동성 주의', '소액 분산 투자', '장기 관점 유지']
        };
      case InvestmentType.realEstate:
        return {
          'regions': ['강남', '강북', '경기', '인천', '지방'],
          'scores': [85, 70, 75, 65, 60],
          'trends': '안정적 상승세',
          'recommendations': ['청약 기회 주목', '대출 규제 확인', '실거주 목적 우선']
        };
      case InvestmentType.lottery:
        return {
          'luckyNumbers': [7, 14, 23, 31, 38, 42],
          'bestTime': '오후 3-5시',
          'probability': 15,
          'recommendations': ['소액만 투자', '오락 목적으로만', '과도한 기대 금물']
        };
      case InvestmentType.sidejob:
        return {
          'opportunities': ['온라인 강의', '프리랜서', '투잡', '창업'],
          'scores': [80, 75, 70, 65],
          'potential': 'high',
          'recommendations': ['본업 소홀 주의', '세금 신고 필수', '계약서 작성 중요']
        };
      default:
        return {
          'overallScore': 75,
          'bestSector': '기술주',
          'risk': 'medium',
          'recommendations': ['분산 투자', '장기 투자', '손절선 설정']
        };
    }
  }

  @override
  Widget buildContent(BuildContext context, Fortune fortune) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type Selector
          _buildTypeSelector(),
          const SizedBox(height: 20),
          
          // Main Fortune Card
          _buildMainFortuneCard(fortune),
          const SizedBox(height: 20),
          
          // Investment-specific content
          ..._buildTypeSpecificContent(fortune)]));
  }

  Widget _buildTypeSelector() {
    return Container(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: InvestmentType.values.length,
        itemBuilder: (context, index) {
          final type = InvestmentType.values[index];
          final isSelected = type == _selectedType;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              avatar: Icon(
                type.icon,
                size: 18,
                color: isSelected ? Colors.white : AppTheme.primaryColor),
              label: Text(type.label),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedType = type;
                  });
                  _onGenerateFortune();
                }
              },
              selectedColor: AppTheme.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal));
        }));
  }

  Widget _buildMainFortuneCard(Fortune fortune) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getInvestmentColor(_selectedType).withOpacity(0.1),
              _getInvestmentColor(_selectedType).withOpacity(0.05)]),
          borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _selectedType.icon,
                      color: _getInvestmentColor(_selectedType),
                      size: 28),
                    const SizedBox(width: 8),
                    Text(
                      '${_selectedType.label} 운세',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold))]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getScoreColor(fortune.score),
                    borderRadius: BorderRadius.circular(20),
                  child: Text(
                    '${fortune.score}점',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold))]),
            const SizedBox(height: 16),
            Text(
              fortune.message,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppTheme.textColor)),
            if (_selectedType != InvestmentType.general) ...[
              const SizedBox(height: 16),
              _buildRiskIndicator(fortune.score)]])).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildRiskIndicator(int score) {
    final risk = score >= 80 ? '낮음' : score >= 60 ? '중간' : '높음';
    final riskColor = score >= 80 ? Colors.green : score >= 60 ? Colors.orange : Colors.red;
    
    return Row(
      children: [
        Icon(Icons.warning_amber, size: 20, color: riskColor),
        const SizedBox(width: 8),
        Text(
          '위험도: ',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor)),
        Text(
          risk,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: riskColor))]);
  }

  List<Widget> _buildTypeSpecificContent(Fortune fortune) {
    switch (_selectedType) {
      case InvestmentType.stock:
        return [_buildStockContent()];
      case InvestmentType.crypto:
        return [_buildCryptoContent()];
      case InvestmentType.realEstate:
        return [_buildRealEstateContent()];
      case InvestmentType.lottery:
        return [_buildLotteryContent()];
      case InvestmentType.sidejob:
        return [_buildSidejobContent()];
      default:
        return [_buildGeneralContent()];
    }
  }

  Widget _buildStockContent() {
    final sectors = _investmentData?['sectors'] ?? [];
    final scores = _investmentData?['scores'] ?? [];
    final recommendations = _investmentData?['recommendations'] ?? [];
    
    return Column(
      children: [
        _buildSectorChart(sectors, scores),
        const SizedBox(height: 16),
        _buildRecommendationCard('오늘의 투자 전략'),
        const SizedBox(height: 16),
        _buildStockTips()]);
  }

  Widget _buildSectorChart(List<String> sectors, List<int> scores) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '섹터별 투자 운세',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < sectors.length) {
                            return Text(
                              sectors[value.toInt()],
                              style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        })),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: scores.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: _getScoreColor(entry.value),
                          width: 25,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4))]);
                  }).toList()
                )
              )
            )
          ]
        )
      )
    );
  }

  Widget _buildCryptoContent() {
    final coins = _investmentData?['coins'] ?? [];
    final scores = _investmentData?['scores'] ?? [];
    final recommendations = _investmentData?['recommendations'] ?? [];
    
    return Column(
      children: [
        _buildCoinList(coins, scores),
        const SizedBox(height: 16),
        _buildVolatilityWarning(),
        const SizedBox(height: 16),
        _buildRecommendationCard('암호화폐 투자 가이드')]);
  }

  Widget _buildCoinList(List<String> coins, List<int> scores) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '코인별 투자 운세',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...coins.asMap().entries.map((entry) {
              final index = entry.key;
              final coin = entry.value;
              final score = index < scores.length ? scores[index] : 50;
              
              return _buildCoinItem(coin, score);
            }).toList(),);
  }

  Widget _buildCoinItem(String coin, int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            child: Center(
              child: Text(
                coin,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coin,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: score / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(score)]),
          const SizedBox(width: 12),
          Text(
            '$score점',
            style: TextStyle(
              color: _getScoreColor(score),
              fontWeight: FontWeight.bold,
              fontSize: 16
            )
          ]
        )
      ]
    );
  }

  Widget _buildVolatilityWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '높은 변동성 주의',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  '암호화폐 시장은 변동성이 매우 높습니다. 투자금 전액 손실 가능성을 항상 염두에 두세요.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor
                  )
                ]
              )
            )
          ]
        )
      ]
    );
  }

  Widget _buildRealEstateContent() {
    final regions = _investmentData?['regions'] ?? [];
    final scores = _investmentData?['scores'] ?? [];
    final recommendations = _investmentData?['recommendations'] ?? [];
    
    return Column(
      children: [
        _buildRegionMap(regions, scores),
        const SizedBox(height: 16),
        _buildMarketTrend(),
        const SizedBox(height: 16),
        _buildRecommendationCard('부동산 투자 전략')]);
  }

  Widget _buildRegionMap(List<String> regions, List<int> scores) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '지역별 투자 매력도',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...regions.asMap().entries.map((entry) {
              final index = entry.key;
              final region = entry.value;
              final score = index < scores.length ? scores[index] : 50;
              
              return _buildRegionItem(region, score);
            }).toList(),);
  }

  Widget _buildRegionItem(String region, int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.location_on, color: AppTheme.primaryColor, size: 24),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(
              region,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14)),
          const SizedBox(width: 12),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                FractionallySizedBox(
                  widthFactor: score / 100,
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getScoreColor(score),
                      borderRadius: BorderRadius.circular(12),])),
          const SizedBox(width: 12),
          Text(
            '$score점',
            style: TextStyle(
              color: _getScoreColor(score),
              fontWeight: FontWeight.bold,
              fontSize: 14
            )
          ]
        )
      ]
    );
  }

  Widget _buildMarketTrend() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green, size: 24),
                const SizedBox(width: 8),
                const Text(
                  '시장 동향',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold))]),
            const SizedBox(height: 12),
            Text(
              _investmentData?['trends'] ?? '안정적 상승세',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(
              '전반적으로 부동산 시장은 안정적인 흐름을 보이고 있으나, 지역별 편차가 존재합니다.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor
              )
            )
          ]
        )
      )
    );
  }

  Widget _buildLotteryContent() {
    final luckyNumbers = _investmentData?['luckyNumbers'] ?? [];
    final bestTime = _investmentData?['bestTime'] ?? '';
    final recommendations = _investmentData?['recommendations'] ?? [];
    
    return Column(
      children: [
        _buildLuckyNumbers(luckyNumbers),
        const SizedBox(height: 16),
        _buildBestTimeCard(bestTime),
        const SizedBox(height: 16),
        _buildLotteryWarning(),
        const SizedBox(height: 16),
        _buildRecommendationCard('복권 구매 가이드')]);
  }

  Widget _buildLuckyNumbers(List<int> numbers) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.withOpacity(0.1),
              Colors.blue.withOpacity(0.1)]),
          borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            const Text(
              '오늘의 행운 번호',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: numbers.map((number) {
                return Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple, Colors.blue]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4))]),
                  child: Center(
                    child: Text(
                      '$number',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)));
              }).toList(),);
  }

  Widget _buildBestTimeCard(String bestTime) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.access_time, color: AppTheme.primaryColor, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '최적 구매 시간',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  bestTime,
                  style: TextStyle(
                    fontSize: 18,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold))])]));
  }

  Widget _buildLotteryWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.red, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '복권은 확률이 매우 낮은 게임입니다. 오락 목적으로만 소액을 사용하세요.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red[700]
              )
            )
          )
        ]
      )
    );
  }

  Widget _buildSidejobContent() {
    final opportunities = _investmentData?['opportunities'] ?? [];
    final scores = _investmentData?['scores'] ?? [];
    final recommendations = _investmentData?['recommendations'] ?? [];
    
    return Column(
      children: [
        _buildOpportunityList(opportunities, scores),
        const SizedBox(height: 16),
        _buildIncomeProjection(),
        const SizedBox(height: 16),
        _buildRecommendationCard('부업 시작 가이드')]);
  }

  Widget _buildOpportunityList(List<String> opportunities, List<int> scores) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '추천 부업 기회',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...opportunities.asMap().entries.map((entry) {
              final index = entry.key;
              final opportunity = entry.value;
              final score = index < scores.length ? scores[index] : 50;
              
              return _buildOpportunityItem(opportunity, score);
            }).toList(),);
  }

  Widget _buildOpportunityItem(String opportunity, int score) {
    IconData icon;
    switch (opportunity) {
      case '온라인 강의': icon = Icons.school;
        break;
      case '프리랜서':
        icon = Icons.laptop_mac;
        break;
      case '투잡':
        icon = Icons.work_outline;
        break;
      case , '창업': icon = Icons.business;
        break;
      default:
        icon = Icons.work;}
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.isDarkMode ? Colors.grey[900] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opportunity,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < (score ~/ 20) ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16);
                      }),
                      const SizedBox(width: 8),
                      Text(
                        '추천도 $score%',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryColor
                        )
                      )
                    ]
                  )
                ]
              )
            )
          )
        ]
      )
    );
  }

  Widget _buildIncomeProjection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '예상 수익 전망',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildIncomeColumn('1개월': '50-100만원',
                _buildIncomeColumn('3개월': '200-400만원',
                _buildIncomeColumn('6개월': '500-1000만원'])]));
  }

  Widget _buildIncomeColumn(String period, String amount) {
    return Column(
      children: [
        Text(
          period,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor)),
        const SizedBox(height: 8),
        Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor))]);
  }

  Widget _buildGeneralContent() {
    return Column(
      children: [
        _buildPortfolioSuggestion(),
        const SizedBox(height: 16),
        _buildInvestmentTips(),
        const SizedBox(height: 16),
        _buildMarketOverview()]);
  }

  Widget _buildPortfolioSuggestion() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '추천 포트폴리오',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      color: Colors.blue,
                      value: 40,
                      title: '주식\n40%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                    PieChartSectionData(
                      color: Colors.orange,
                      value: 30,
                      title: '채권\n30%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                    PieChartSectionData(
                      color: Colors.green,
                      value: 20,
                      title: '부동산\n20%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                    PieChartSectionData(
                      color: Colors.purple,
                      value: 10,
                      title: '현금\n10%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      )
                    )
                  ]
                )
              )
            )
          ]
        )
      )
    );
  }

  Widget _buildInvestmentTips() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '오늘의 투자 팁',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTipItem('분산 투자로 리스크를 줄이세요'),
            _buildTipItem('장기 투자 관점을 유지하세요'),
            _buildTipItem('감정적 판단을 피하세요'),
            _buildTipItem('손절선을 미리 정하세요')]));
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 20,
            color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(fontSize: 14)
            )
          )
        ]
      )
    );
  }

  Widget _buildMarketOverview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '시장 전망',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMarketIndicator('단기': null,
                _buildMarketIndicator('중기': null,
                _buildMarketIndicator('장기')])]));
  }

  Widget _buildMarketIndicator(String period, int score, Color color) {
    return Column(
      children: [
        CircularProgressIndicator(
          value: score / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          strokeWidth: 8),
        const SizedBox(height: 8),
        Text(
          period,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14)),
        Text(
          '$score점',
          style: TextStyle(
            color: color,
            fontSize: 12))]);
  }

  Widget _buildStockTips() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tips_and_updates, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                const Text(
                  '주식 투자 팁',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold))]),
            const SizedBox(height: 16),
            _buildTipItem('오전 장 초반 급등주는 피하세요'),
            _buildTipItem('손절선은 -3%로 설정하세요'),
            _buildTipItem('분할 매수로 평단가를 낮추세요'),
            _buildTipItem('뉴스와 공시를 꼭 확인하세요')]));
  }

  Widget _buildRecommendationCard(String title, List<String> recommendations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...recommendations.map((rec) => _buildRecommendationItem(rec)).toList()
          ]
        )
      )
    );
  }

  Widget _buildRecommendationItem(String recommendation) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              recommendation,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4
              )
            )
          )
        ]
      )
    );
  }

  Color _getInvestmentColor(InvestmentType type) {
    switch (type) {
      case InvestmentType.stock:
        return Colors.blue;
      case InvestmentType.crypto:
        return Colors.orange;
      case InvestmentType.realEstate:
        return Colors.green;
      case InvestmentType.lottery:
        return Colors.purple;
      case InvestmentType.sidejob:
        return Colors.teal;
      default:
        return AppTheme.primaryColor;
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}