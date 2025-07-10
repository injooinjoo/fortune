import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/fortune_result.dart';
import 'base_fortune_page_v2.dart';

class PastLifeFortunePage extends ConsumerWidget {
  static const String routeName = '/fortune/past-life';

  const PastLifeFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '전생 운세',
      fortuneType: 'past-life',
      headerGradient: const LinearGradient(
        colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      inputBuilder: (context, onSubmit) => _buildInputSection(context, onSubmit),
      resultBuilder: (context, result, onShare) => _buildResultSection(context, result, onShare),
    );
  }

  Widget _buildInputSection(BuildContext context, Function(Map<String, dynamic>) onSubmit) {
    final personalityController = TextEditingController();
    final fearsController = TextEditingController();
    final talentsController = TextEditingController();

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '현생의 특징을 입력해주세요',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: personalityController,
              decoration: InputDecoration(
                labelText: '성격 특징',
                hintText: '예: 내향적, 리더십, 예술적 감각',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: fearsController,
              decoration: InputDecoration(
                labelText: '무서워하는 것',
                hintText: '예: 높은 곳, 물, 어둠, 혼자 있는 것',
                prefixIcon: const Icon(Icons.psychology_alt),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: talentsController,
              decoration: InputDecoration(
                labelText: '타고난 재능',
                hintText: '예: 음악, 언어, 손재주, 직감',
                prefixIcon: const Icon(Icons.star),
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
                  if (personalityController.text.isNotEmpty &&
                      fearsController.text.isNotEmpty &&
                      talentsController.text.isNotEmpty) {
                    onSubmit({
                      'personality': personalityController.text,
                      'fears': fearsController.text,
                      'talents': talentsController.text,
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
                  backgroundColor: const Color(0xFF7C3AED),
                ),
                child: const Text(
                  '전생 운세 확인하기',
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
          _buildSummaryCard(result.summary ?? '당신의 전생 이야기입니다.'),
          const SizedBox(height: 16),
          _buildMainResultCard(
            title: '전생의 신분',
            content: sections['past_identity'] ?? '전생의 신분을 탐색 중입니다.',
            icon: Icons.person_pin,
            color: Colors.purple,
          ),
          const SizedBox(height: 16),
          _buildMainResultCard(
            title: '전생의 직업',
            content: sections['past_occupation'] ?? '전생의 직업을 확인 중입니다.',
            icon: Icons.work_history,
            color: Colors.indigo,
          ),
          const SizedBox(height: 16),
          _buildMainResultCard(
            title: '전생의 장소',
            content: sections['past_location'] ?? '전생이 살았던 곳을 찾고 있습니다.',
            icon: Icons.public,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildMainResultCard(
            title: '전생의 교훈',
            content: sections['past_lessons'] ?? '전생에서 배운 교훈을 해석 중입니다.',
            icon: Icons.auto_stories,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildKarmicConnection(sections['karmic_connection']),
          const SizedBox(height: 16),
          _buildSoulMission(sections['soul_mission']),
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
            Icon(Icons.all_inclusive, size: 48, color: Colors.purple.shade700),
            const SizedBox(height: 16),
            Text(
              '전생 운세 요약',
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

  Widget _buildKarmicConnection(String? connection) {
    if (connection == null) return const SizedBox.shrink();

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
                    color: Colors.pink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.favorite, color: Colors.pink, size: 28),
                ),
                const SizedBox(width: 16),
                const Text(
                  '인연의 실',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              connection,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoulMission(String? mission) {
    if (mission == null) return const SizedBox.shrink();

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
                  child: const Icon(Icons.flare, color: Colors.amber, size: 28),
                ),
                const SizedBox(width: 16),
                const Text(
                  '영혼의 사명',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              mission,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}