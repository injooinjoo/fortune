import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/fortune_result.dart';
import 'base_fortune_page_v2.dart';

class LuckyCryptoFortunePage extends ConsumerWidget {
  static const String routeName = '/fortune/lucky-crypto';

  const LuckyCryptoFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '코인 운세',
      fortuneType: 'lucky-crypto',
      headerGradient: const LinearGradient(
        colors: [Color(0xFFF7931A), Color(0xFFFFD700)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      inputBuilder: (context, onSubmit) => _buildInputSection(context, onSubmit),
      resultBuilder: (context, result, onShare) => _buildResultSection(context, result, onShare),
    );
  }

  Widget _buildInputSection(BuildContext context, Function(Map<String, dynamic>) onSubmit) {
    final tradingExperienceController = TextEditingController();
    final favoriteCoinsController = TextEditingController();
    final investmentGoalController = TextEditingController();

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '코인 투자 정보를 입력해주세요',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: tradingExperienceController,
              decoration: InputDecoration(
                labelText: '코인 투자 경력',
                hintText: '예: 초보자, 1년, 3년 이상',
                prefixIcon: const Icon(Icons.timeline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: favoriteCoinsController,
              decoration: InputDecoration(
                labelText: '관심 코인',
                hintText: '예: 비트코인, 이더리움, 알트코인',
                prefixIcon: const Icon(Icons.currency_bitcoin),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: investmentGoalController,
              decoration: InputDecoration(
                labelText: '투자 목표',
                hintText: '예: 단기 수익, 장기 보유, 분산 투자',
                prefixIcon: const Icon(Icons.flag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (tradingExperienceController.text.isNotEmpty &&
                      favoriteCoinsController.text.isNotEmpty &&
                      investmentGoalController.text.isNotEmpty) {
                    onSubmit({
                      'tradingExperience': tradingExperienceController.text,
                      'favoriteCoins': favoriteCoinsController.text,
                      'investmentGoal': investmentGoalController.text,
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('모든 정보를 입력해주세요'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: const Color(0xFFF7931A),
                ),
                child: const Text(
                  '코인 운세 확인하기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection(BuildContext context, FortuneResult result, VoidCallback onShare) {
    final sections = result.sections ?? {};
    
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSummaryCard(result.summary ?? '오늘의 암호화폐 투자 운세입니다.'),
          const SizedBox(height: 16),
          _buildMainResultCard(
            title: '시장 분위기',
            content: sections['market_sentiment'] ?? '암호화폐 시장 분위기를 분석 중입니다.',
            icon: Icons.bubble_chart,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildMainResultCard(
            title: '매수/매도 타이밍',
            content: sections['trading_timing'] ?? '최적의 거래 타이밍을 찾고 있습니다.',
            icon: Icons.schedule,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildMainResultCard(
            title: '추천 코인',
            content: sections['recommended_coins'] ?? '오늘의 추천 코인을 분석 중입니다.',
            icon: Icons.stars,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildMainResultCard(
            title: '위험 관리',
            content: sections['risk_alert'] ?? '투자 위험 요소를 확인 중입니다.',
            icon: Icons.warning_amber,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          _buildVolatilityAnalysis(sections['volatility_analysis']),
          const SizedBox(height: 16),
          _buildWeeklyTrend(sections['weekly_trend']),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.share),
            label: const Text('운세 공유하기'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String summary) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.orange.shade50, Colors.yellow.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.currency_bitcoin, size: 48, color: Colors.orange.shade700),
            const SizedBox(height: 16),
            Text(
              '코인 운세 요약',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade800,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              summary,
              style: const TextStyle(fontSize: 16, height: 1.6),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainResultCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolatilityAnalysis(String? analysis) {
    if (analysis == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.show_chart, color: Colors.purple, size: 28),
                ),
                const SizedBox(width: 16),
                const Text(
                  '변동성 분석',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              analysis,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyTrend(String? trend) {
    if (trend == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.trending_up, color: Colors.teal, size: 28),
                ),
                const SizedBox(width: 16),
                const Text(
                  '주간 트렌드 전망',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              trend,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}