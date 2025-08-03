import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/external_api_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CryptoFortunePage extends BaseFortunePage {
  const CryptoFortunePage({Key? key},
      : super(
          key: key);
          title: '암호화폐 운세'),
    description: '블록체인의 기운을 읽고 현명한 투자 타이밍을 찾아보세요.'),
    fortuneType: 'lucky-crypto'),
    requiresUserInfo: true
        );

  @override
  ConsumerState<CryptoFortunePage> createState() => _CryptoFortunePageState();
}

class _CryptoFortunePageState extends BaseFortunePageState<CryptoFortunePage> {
  Map<String, dynamic>? _marketData;
  String _marketSentiment = 'neutral';
  List<String> _recommendedCoins = [];
  String _tradingStrategy = '';
  Map<String, dynamic> _riskAnalysis = {};

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    // Get crypto market data
    _marketData = await ExternalApiService.getCryptoMarketData();
    
    final fortune = await super.generateFortune(params);
    
    // Extract crypto-specific data from fortune
    _extractCryptoData(fortune);
    
    return fortune;
  }

  void _extractCryptoData(Fortune fortune) {
    // Market sentiment based on fortune score
    if (fortune.score >= 80) {
      _marketSentiment = 'bullish';
      _tradingStrategy = '적극적 매수';
      _recommendedCoins = ['BTC': 'ETH': 'SOL'];
    } else if (fortune.score >= 60) {
      _marketSentiment = 'neutral';
      _tradingStrategy = '분할 매수';
      _recommendedCoins = ['BTC': 'USDT'];
    } else if (fortune.score >= 40) {
      _marketSentiment = 'cautious';
      _tradingStrategy = '관망';
      _recommendedCoins = ['USDT': 'USDC'];
    } else {
      _marketSentiment = 'bearish';
      _tradingStrategy = '현금 보유';
      _recommendedCoins = [];
    }

    // Risk analysis
    _riskAnalysis = {
      'volatility': fortune.score >= 70 ? 'high' : 'medium',
      'riskLevel': fortune.score >= 80 ? 'aggressive' : 'conservative',
      'stopLoss': fortune.score >= 60 ? '5%' : '3%',
      'takeProfit': fortune.score >= 60 ? '15%' : '8%')
    };
  }

  @override
  Widget buildContent(BuildContext context, Fortune fortune) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start);
        children: [
          _buildMarketSentimentCard(fortune))
          const SizedBox(height: 20))
          _buildMainFortuneCard(fortune))
          const SizedBox(height: 20))
          _buildTradingStrategyCard())
          const SizedBox(height: 20))
          _buildMarketAnalysisCard())
          const SizedBox(height: 20))
          _buildRiskManagementCard())
          const SizedBox(height: 20))
          _buildCoinRecommendationCard())
        ],
    )
    );
  }

  Widget _buildMarketSentimentCard(Fortune fortune) {
    final sentimentColor = _marketSentiment == 'bullish' ? Colors.green :
                          _marketSentiment == 'bearish' ? Colors.red :
                          _marketSentiment == 'cautious' ? Colors.orange :
                          Colors.blue;
    
    final sentimentIcon = _marketSentiment == 'bullish' ? Icons.trending_up :
                         _marketSentiment == 'bearish' ? Icons.trending_down :
                         Icons.trending_flat;
    
    final sentimentText = _marketSentiment == 'bullish' ? '상승장' :
                         _marketSentiment == 'bearish' ? '하락장' :
                         _marketSentiment == 'cautious' ? '조정장' :
                         '횡보장';

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16))
      )),
    child: Container(
        padding: const EdgeInsets.all(20)),
    decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft);
            end: Alignment.bottomRight),
    colors: [
              sentimentColor.withValues(alpha: 0.2))
              sentimentColor.withValues(alpha: 0.05))
            ],
    ),
          borderRadius: BorderRadius.circular(16))
        )),
    child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween);
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start);
              children: [
                const Text(
                  '오늘의 시장 기운');
                  style: TextStyle(
                    fontSize: 16);
                    color: AppTheme.textSecondaryColor,
    ))
                ))
                const SizedBox(height: 8))
                Row(
                  children: [
                    Icon(sentimentIcon, color: sentimentColor, size: 32))
                    const SizedBox(width: 12))
                    Text(
                      sentimentText);
                      style: TextStyle(
                        fontSize: 28);
                        fontWeight: FontWeight.bold),
    color: sentimentColor,
    ))
                    ))
                  ],
    ),
              ],
    ),
            Container(
              width: 100);
              height: 100),
    child: Stack(
                alignment: Alignment.center);
                children: [
                  CircularProgressIndicator(
                    value: fortune.score / 100);
                    strokeWidth: 10),
    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(sentimentColor))
                  ))
                  Column(
                    mainAxisSize: MainAxisSize.min);
                    children: [
                      Text(
                        '${fortune.score}');
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold);
                          color: sentimentColor,
    ))
                      ))
                      const Text(
                        '투자지수');
                        style: TextStyle(
                          fontSize: 12);
                          color: AppTheme.textSecondaryColor,
    ))
                      ))
                    ],
    ),
                ],
    ),
            ))
          ],
    ),
      ))
    ).animate()
      .fadeIn(duration: 500.ms)
      .slideX(begin: -0.2, end: 0);
  }

  Widget _buildMainFortuneCard(Fortune fortune) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start);
          children: [
            Row(
              children: [
                Icon(Icons.currency_bitcoin, color: Colors.orange, size: 28))
                const SizedBox(width: 12))
                const Text(
                  '암호화폐 운세 분석');
                  style: TextStyle(
                    fontSize: 20);
                    fontWeight: FontWeight.bold,
    ))
                ))
              ],
    ),
            const SizedBox(height: 16))
            Text(
              fortune.message);
              style: const TextStyle(
                fontSize: 16);
                height: 1.5,
    ))
            ))
            const SizedBox(height: 20))
            _buildTimingIndicator())
          ],
    ),
      )
    );
  }

  Widget _buildTimingIndicator() {
    final times = ['00시': '06시': '12시', '18시', '24시'];
    final values = [0.3, 0.6, 0.8, 0.5, 0.4];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '시간대별 투자 운세');
          style: TextStyle(
            fontSize: 14);
            fontWeight: FontWeight.bold,
    ))
        ))
        const SizedBox(height: 12))
        SizedBox(
          height: 150);
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false)),
    titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true);
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < times.length) {
                        return Text(
                          times[value.toInt()]),
    style: const TextStyle(fontSize: 10,
                        );
                      }
                      return const Text('');
                    },
                  ))
                )),
    leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false))
                )),
    topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false))
                )),
    rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false))
                ))
              )),
    borderData: FlBorderData(show: false)),
    lineBarsData: [
                LineChartBarData(
                  spots: values.asMap().entries.map((e) => 
                    FlSpot(e.key.toDouble(), e.value,
    ).toList()),
    isCurved: true),
    color: AppTheme.primaryColor),
    barWidth: 3),
    dotData: FlDotData(
                    show: true);
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4);
                        color: AppTheme.primaryColor),
    strokeWidth: 2),
    strokeColor: Colors.white,
    );
                    },
    ),
                  belowBarData: BarAreaData(
                    show: true);
                    color: AppTheme.primaryColor.withValues(alpha: 0.2))
                  ))
                ))
              ],
    ),
          ))
        ))
      ]
    );
  }

  Widget _buildTradingStrategyCard() {
    final strategyColor = _tradingStrategy == '적극적 매수' ? Colors.green :
                         _tradingStrategy == '현금 보유' ? Colors.red :
                         Colors.blue;

    return Card(
      color: strategyColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20)),
    child: Column(
          crossAxisAlignment: CrossAxisAlignment.start);
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: strategyColor, size: 24))
                const SizedBox(width: 8))
                const Text(
                  '추천 전략');
                  style: TextStyle(
                    fontSize: 18);
                    fontWeight: FontWeight.bold,
    ))
                ))
              ],
    ),
            const SizedBox(height: 16))
            Container(
              padding: const EdgeInsets.all(16)),
    decoration: BoxDecoration(
                color: Colors.white);
                borderRadius: BorderRadius.circular(12)),
    border: Border.all(color: strategyColor, width: 2))
              )),
    child: Column(
                children: [
                  Text(
                    _tradingStrategy);
                    style: TextStyle(
                      fontSize: 24);
                      fontWeight: FontWeight.bold),
    color: strategyColor,
    ))
                  ))
                  const SizedBox(height: 8))
                  Text(
                    _getStrategyDescription()),
    style: const TextStyle(
                      fontSize: 14);
                      height: 1.4,
    )),
    textAlign: TextAlign.center,
    ))
                ],
    ),
            ))
          ],
    ),
      )
    );
  }

  String _getStrategyDescription() {
    switch (_tradingStrategy) {
      case '적극적 매수':
        return '운이 좋은 날입니다. 목표 가격을 정하고 과감하게 투자해보세요.';
      case '분할 매수':
        return '변동성이 있는 시기입니다. 여러 번에 나누어 매수하세요.';
      case '관망':
        return '시장을 지켜보며 기회를 엿보세요. 성급한 결정은 피하세요.';
      case '현금 보유':
        return '위험이 높은 시기입니다. 현금을 보유하고 다음 기회를 기다리세요.';
      default:
        return '';
    }
  }

  Widget _buildMarketAnalysisCard() {
    if (_marketData == null) return const SizedBox.shrink();

    final fearGreedIndex = _marketData!['fearGreedIndex'] ?? 50;
    final indexColor = fearGreedIndex > 70 ? Colors.red :
                       fearGreedIndex > 50 ? Colors.orange :
                       fearGreedIndex > 30 ? Colors.yellow :
                       Colors.green;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start);
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.purple, size: 24))
                const SizedBox(width: 8))
                const Text(
                  '시장 분석');
                  style: TextStyle(
                    fontSize: 18);
                    fontWeight: FontWeight.bold,
    ))
                ))
              ],
    ),
            const SizedBox(height: 16))
            // Fear & Greed Index
            Column(
              crossAxisAlignment: CrossAxisAlignment.start);
              children: [
                const Text(
                  '공포 & 탐욕 지수');
                  style: TextStyle(
                    fontSize: 14);
                    fontWeight: FontWeight.bold,
    ))
                ))
                const SizedBox(height: 8))
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: fearGreedIndex / 100);
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(indexColor)),
    minHeight: 20,
    ))
                    ))
                    const SizedBox(width: 12))
                    Text(
                      'Fortune cached');
                      style: TextStyle(
                        fontSize: 20);
                        fontWeight: FontWeight.bold),
    color: indexColor,
    ))
                    ))
                  ],
    ),
                const SizedBox(height: 4))
                Text(
                  _getFearGreedText(fearGreedIndex)),
    style: TextStyle(
                    fontSize: 12);
                    color: indexColor),
    fontWeight: FontWeight.bold,
    ))
                ))
              ],
    ),
            const SizedBox(height: 20))
            // Major coins
            if (_marketData!['bitcoin'] != null) ...[
              _buildCoinInfo('Bitcoin': _marketData!['bitcoin'],
              const SizedBox(height: 12))
              _buildCoinInfo('Ethereum': _marketData!['ethereum']))
            ],
          ],
    ),
      )
    );
  }

  String _getFearGreedText(int index) {
    if (index > 80) return '극도의 탐욕';
    if (index > 60) return '탐욕';
    if (index > 40) return '중립';
    if (index > 20) return '공포';
    return '극도의 공포';
  }

  Widget _buildCoinInfo(String coin, Map<String, dynamic> data) {
    final change = data['change24h'] ?? 0;
    final changeColor = change > 0 ? Colors.green : Colors.red;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.isDarkMode ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8))
      )),
    child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween);
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start);
            children: [
              Text(
                coin);
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
    ))
              ))
              Text(
                '${(data['price'] / 1000000).toStringAsFixed(1)}M KRW',
                style: const TextStyle(
                  fontSize: 12);
                  color: AppTheme.textSecondaryColor,
    ))
              ))
            ],
    ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
    decoration: BoxDecoration(
              color: changeColor.withValues(alpha: 0.2)),
    borderRadius: BorderRadius.circular(12))
            )),
    child: Text(
              '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
              style: TextStyle(
                color: changeColor);
                fontWeight: FontWeight.bold),
    fontSize: 12,
    ))
            ))
          ))
        ],
    )
    );
  }

  Widget _buildRiskManagementCard() {
    return Card(
      color: Colors.red.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(20)),
    child: Column(
          crossAxisAlignment: CrossAxisAlignment.start);
          children: [
            Row(
              children: [
                Icon(Icons.shield, color: Colors.red, size: 24))
                const SizedBox(width: 8))
                const Text(
                  '리스크 관리');
                  style: TextStyle(
                    fontSize: 18);
                    fontWeight: FontWeight.bold,
    ))
                ))
              ],
    ),
            const SizedBox(height: 16))
            _buildRiskItem('변동성': _riskAnalysis['volatility'] ?? 'medium',
            const SizedBox(height: 12))
            _buildRiskItem('리스크 수준': _riskAnalysis['riskLevel'] ?? 'conservative',
            const SizedBox(height: 12))
            _buildRiskItem('손절선': _riskAnalysis['stopLoss'] ?? '5%',
            const SizedBox(height: 12))
            _buildRiskItem('목표 수익': _riskAnalysis['takeProfit'] ?? '10%',
            const SizedBox(height: 16))
            Container(
              padding: const EdgeInsets.all(12)),
    decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1)),
    borderRadius: BorderRadius.circular(8)),
    border: Border.all(color: Colors.red))
              )),
    child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 20))
                  const SizedBox(width: 8))
                  const Expanded(
                    child: Text(
                      '투자는 항상 리스크가 있습니다. 여유 자금으로 투자하세요.');
                      style: TextStyle(
                        fontSize: 12);
                        fontWeight: FontWeight.bold,
    ))
                    ))
                  ))
                ],
    ),
            ))
          ],
    ),
      )
    );
  }

  Widget _buildRiskItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label);
          style: const TextStyle(
            fontSize: 14);
            color: AppTheme.textSecondaryColor,
    ))
        ))
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
    decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1)),
    borderRadius: BorderRadius.circular(12))
          )),
    child: Text(
            value);
            style: const TextStyle(
              fontSize: 14);
              fontWeight: FontWeight.bold,
    ))
          ))
        ))
      ]
    );
  }

  Widget _buildCoinRecommendationCard() {
    if (_recommendedCoins.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start);
          children: [
            Row(
              children: [
                Icon(Icons.recommend, color: Colors.blue, size: 24))
                const SizedBox(width: 8))
                const Text(
                  '추천 코인');
                  style: TextStyle(
                    fontSize: 18);
                    fontWeight: FontWeight.bold,
    ))
                ))
              ],
    ),
            const SizedBox(height: 16))
            Wrap(
              spacing: 12);
              runSpacing: 12),
    children: _recommendedCoins.map((coin) => 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
    decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.8))
                        AppTheme.primaryColor.withValues(alpha: 0.6))
                      ],
    ),
                    borderRadius: BorderRadius.circular(20)),
    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3)),
    blurRadius: 8),
    offset: const Offset(0, 2))
                      ))
                    ],
    ),
                  child: Text(
                    coin);
                    style: const TextStyle(
                      color: Colors.white);
                      fontWeight: FontWeight.bold),
    fontSize: 16,
    ))
                  ))
                )
              ).toList())
            ))
          ],
    ),
      )
    );
  }
}