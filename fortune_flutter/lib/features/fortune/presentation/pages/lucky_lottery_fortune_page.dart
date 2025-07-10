import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/fortune_result.dart';
import 'base_fortune_page_v2.dart';

class LuckyLotteryFortunePage extends ConsumerWidget {
  static const String routeName = '/fortune/lucky-lottery';

  const LuckyLotteryFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '로또 운세',
      fortuneType: 'lucky-lottery',
      headerGradient: const LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFFFFD700)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      inputBuilder: (context, onSubmit) => _buildInputSection(context, onSubmit),
      resultBuilder: (context, result, onShare) => _buildResultSection(context, result, onShare),
    );
  }

  Widget _buildInputSection(BuildContext context, Function(Map<String, dynamic>) onSubmit) {
    final frequencyController = TextEditingController();
    final methodController = TextEditingController();
    final dreamController = TextEditingController();

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '로또 구매 정보를 입력해주세요',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: frequencyController,
              decoration: InputDecoration(
                labelText: '구매 빈도',
                hintText: '예: 매주, 가끔, 특별한 날',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: methodController,
              decoration: InputDecoration(
                labelText: '번호 선택 방법',
                hintText: '예: 자동, 수동, 반자동',
                prefixIcon: const Icon(Icons.casino),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dreamController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: '최근 꿈이나 느낌',
                hintText: '행운과 관련된 꿈이나 느낌을 적어주세요',
                prefixIcon: const Icon(Icons.bedtime),
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
                  if (frequencyController.text.isNotEmpty &&
                      methodController.text.isNotEmpty) {
                    onSubmit({
                      'frequency': frequencyController.text,
                      'method': methodController.text,
                      'dream': dreamController.text.isEmpty ? '없음' : dreamController.text,
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('구매 빈도와 선택 방법을 입력해주세요'),
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
                  backgroundColor: const Color(0xFF4CAF50),
                ),
                child: const Text(
                  '로또 운세 확인하기',
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
          _buildSummaryCard(result.summary ?? '오늘의 로또 행운 운세입니다.'),
          const SizedBox(height: 16),
          _buildLuckyNumbers(sections['lucky_numbers']),
          const SizedBox(height: 16),
          _buildMainResultCard(
            title: '구매 타이밍',
            content: sections['purchase_timing'] ?? '최적의 구매 시간을 분석 중입니다.',
            icon: Icons.access_time,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildMainResultCard(
            title: '구매 장소',
            content: sections['purchase_location'] ?? '행운의 구매 장소를 찾고 있습니다.',
            icon: Icons.store,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildMainResultCard(
            title: '행운의 징조',
            content: sections['lucky_signs'] ?? '행운의 신호를 해석 중입니다.',
            icon: Icons.auto_awesome,
            color: Colors.purple,
          ),
          const SizedBox(height: 16),
          _buildMainResultCard(
            title: '당첨 확률 높이기',
            content: sections['tips'] ?? '당첨 확률을 높이는 팁을 준비 중입니다.',
            icon: Icons.tips_and_updates,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildDreamInterpretation(sections['dream_interpretation']),
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
            colors: [Colors.green.shade50, Colors.yellow.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.stars, size: 48, color: Colors.green.shade700),
            const SizedBox(height: 16),
            Text(
              '로또 운세 요약',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
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

  Widget _buildLuckyNumbers(String? numbers) {
    if (numbers == null) return const SizedBox.shrink();

    // Parse numbers from string (assuming format like "7, 14, 23, 31, 38, 42")
    final numberList = numbers.split(',').map((n) => n.trim()).toList();

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.yellow.shade100, Colors.orange.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const Text(
              '오늘의 행운 번호',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: numberList.map((number) => Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.yellow.shade400, Colors.orange.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              '※ 참고용이며, 실제 당첨을 보장하지 않습니다',
              style: TextStyle(fontSize: 12, color: Colors.grey),
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

  Widget _buildDreamInterpretation(String? interpretation) {
    if (interpretation == null) return const SizedBox.shrink();

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
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bedtime, color: Colors.indigo, size: 28),
                ),
                const SizedBox(width: 16),
                const Text(
                  '꿈 해석',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              interpretation,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}