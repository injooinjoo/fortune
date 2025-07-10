import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/fortune_result.dart';
import 'base_fortune_page_v2.dart';

class LuckyStockFortunePage extends ConsumerWidget {
  static const String routeName = '/fortune/lucky-stock';

  const LuckyStockFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '주식 운세',
      fortuneType: 'lucky-stock',
      headerGradient: const LinearGradient(
        colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      inputBuilder: (context, onSubmit) => _buildInputSection(context, onSubmit),
      resultBuilder: (context, result, onShare) => _buildResultSection(context, result, onShare),
    );
  }

  Widget _buildInputSection(BuildContext context, Function(Map<String, dynamic>) onSubmit) {
    final investmentStyleController = TextEditingController();
    final portfolioSizeController = TextEditingController();
    final riskToleranceController = TextEditingController();

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '투자 스타일을 입력해주세요',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: investmentStyleController,
              decoration: InputDecoration(
                labelText: '투자 스타일',
                hintText: '예: 장기투자, 단타, 스윙',
                prefixIcon: const Icon(Icons.trending_up),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: portfolioSizeController,
              decoration: InputDecoration(
                labelText: '포트폴리오 규모',
                hintText: '예: 1000만원, 5000만원',
                prefixIcon: const Icon(Icons.account_balance_wallet),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: riskToleranceController,
              decoration: InputDecoration(
                labelText: '위험 감수 성향',
                hintText: '예: 보수적, 중립적, 공격적',
                prefixIcon: const Icon(Icons.speed),
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
                  if (investmentStyleController.text.isNotEmpty &&
                      portfolioSizeController.text.isNotEmpty &&
                      riskToleranceController.text.isNotEmpty) {
                    onSubmit({
                      'investmentStyle': investmentStyleController.text,
                      'portfolioSize': portfolioSizeController.text,
                      'riskTolerance': riskToleranceController.text,
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
                  backgroundColor: const Color(0xFF1976D2),
                ),
                child: const Text(
                  '주식 운세 확인하기',
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
          _buildSummaryCard(result.summary ?? '오늘의 주식 투자 운세입니다.'),
          const SizedBox(height: 16),
          _buildMainResultCard(
            title: '오늘의 시장 전망',
            content: sections['market_outlook'] ?? '시장 전망을 분석 중입니다.',
            icon: Icons.analytics,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildMainResultCard(
            title: '투자 타이밍',
            content: sections['timing'] ?? '최적의 투자 타이밍을 찾고 있습니다.',
            icon: Icons.access_time,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildMainResultCard(
            title: '추천 섹터',
            content: sections['recommended_sectors'] ?? '유망한 섹터를 분석 중입니다.',
            icon: Icons.business,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildMainResultCard(
            title: '리스크 관리',
            content: sections['risk_management'] ?? '리스크 관리 전략을 준비 중입니다.',
            icon: Icons.shield,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          _buildTradingStrategy(sections['trading_strategy']),
          const SizedBox(height: 16),
          _buildWeeklyForecast(sections['weekly_forecast']),
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
            colors: [Colors.blue.shade50, Colors.cyan.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.show_chart, size: 48, color: Colors.blue.shade700),
            const SizedBox(height: 16),
            Text(
              '주식 운세 요약',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
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

  Widget _buildTradingStrategy(String? strategy) {
    if (strategy == null) return const SizedBox.shrink();

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
                  child: const Icon(Icons.psychology, color: Colors.purple, size: 28),
                ),
                const SizedBox(width: 16),
                const Text(
                  '오늘의 매매 전략',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              strategy,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyForecast(String? forecast) {
    if (forecast == null) return const SizedBox.shrink();

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
                  child: const Icon(Icons.calendar_view_week, color: Colors.teal, size: 28),
                ),
                const SizedBox(width: 16),
                const Text(
                  '주간 투자 전망',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              forecast,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}