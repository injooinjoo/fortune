import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/fortune_result.dart';
import 'base_fortune_page_v2.dart';

class StartupFortunePage extends ConsumerWidget {
  static const String routeName = '/fortune/startup';

  const StartupFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '창업 운세',
      fortuneType: 'startup',
      headerGradient: const LinearGradient(
        colors: [Color(0xFF6B46C1), Color(0xFF9333EA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      inputBuilder: (context, onSubmit) => _buildInputSection(context, onSubmit),
      resultBuilder: (context, result, onShare) => _buildResultSection(context, result, onShare),
    );
  }

  Widget _buildInputSection(BuildContext context, Function(Map<String, dynamic>) onSubmit) {
    final businessTypeController = TextEditingController();
    final experienceController = TextEditingController();
    final motivationController = TextEditingController();

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '창업 계획을 입력해주세요',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: businessTypeController,
              decoration: InputDecoration(
                labelText: '창업 분야',
                hintText: '예: IT, 요식업, 교육, 온라인 쇼핑몰',
                prefixIcon: const Icon(Icons.business_center),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: experienceController,
              decoration: InputDecoration(
                labelText: '관련 경험',
                hintText: '예: 5년 실무 경험, 관련 자격증 보유',
                prefixIcon: const Icon(Icons.workspace_premium),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: motivationController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: '창업 동기',
                hintText: '창업을 하려는 이유를 간단히 적어주세요',
                prefixIcon: const Icon(Icons.lightbulb),
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
                  if (businessTypeController.text.isNotEmpty &&
                      experienceController.text.isNotEmpty &&
                      motivationController.text.isNotEmpty) {
                    onSubmit({
                      'businessType': businessTypeController.text,
                      'experience': experienceController.text,
                      'motivation': motivationController.text,
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
                  backgroundColor: const Color(0xFF6B46C1),
                ),
                child: const Text(
                  '창업 운세 확인하기',
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
          _buildSummaryCard(result.summary ?? '창업 성공을 위한 운세입니다.'),
          const SizedBox(height: 16),
          _buildMainResultCard(
            title: '창업 타이밍',
            content: sections['timing'] ?? '최적의 창업 시기를 분석 중입니다.',
            icon: Icons.schedule,
            color: Colors.purple,
          ),
          const SizedBox(height: 16),
          _buildMainResultCard(
            title: '성공 가능성',
            content: sections['success_potential'] ?? '창업 성공 가능성을 평가 중입니다.',
            icon: Icons.rocket_launch,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildMainResultCard(
            title: '핵심 전략',
            content: sections['key_strategy'] ?? '성공을 위한 전략을 준비 중입니다.',
            icon: Icons.psychology,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildMainResultCard(
            title: '주의사항',
            content: sections['warnings'] ?? '창업 시 주의할 점을 확인 중입니다.',
            icon: Icons.warning,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildFundingForecast(sections['funding_forecast']),
          const SizedBox(height: 16),
          _buildGrowthTimeline(sections['growth_timeline']),
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
            colors: [Colors.purple.shade50, Colors.indigo.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.rocket, size: 48, color: Colors.purple.shade700),
            const SizedBox(height: 16),
            Text(
              '창업 운세 요약',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade800,
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

  Widget _buildFundingForecast(String? forecast) {
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
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.attach_money, color: Colors.amber, size: 28),
                ),
                const SizedBox(width: 16),
                const Text(
                  '자금 조달 전망',
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

  Widget _buildGrowthTimeline(String? timeline) {
    if (timeline == null) return const SizedBox.shrink();

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
                  child: const Icon(Icons.timeline, color: Colors.teal, size: 28),
                ),
                const SizedBox(width: 16),
                const Text(
                  '성장 타임라인',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              timeline,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}