import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/fortune_result.dart';
import 'base_fortune_page_v2.dart';

class LuckySideJobFortunePage extends ConsumerWidget {
  static const String routeName = '/fortune/lucky-sidejob';

  const LuckySideJobFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '부업 운세',
      fortuneType: 'lucky-sidejob',
      headerGradient: const LinearGradient(
        colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight),
      inputBuilder: (context, onSubmit) => _buildInputSection(context, onSubmit),
      resultBuilder: (context, result, onShare) => _buildResultSection(context, result, onShare));
  }

  Widget _buildInputSection(BuildContext context, Function(Map<String, dynamic>) onSubmit) {
    final currentJobController = TextEditingController();
    final availableTimeController = TextEditingController();
    final skillsController = TextEditingController();

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '부업 정보를 입력해주세요',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: currentJobController,
              decoration: InputDecoration(
                labelText: '현재 직업',
                hintText: '예: 회사원, 프리랜서, 학생',
                prefixIcon: const Icon(Icons.work),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: availableTimeController,
              decoration: InputDecoration(
                labelText: '부업 가능 시간',
                hintText: '예: 평일 저녁, 주말, 새벽',
                prefixIcon: const Icon(Icons.access_time),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: skillsController,
              decoration: InputDecoration(
                labelText: '보유 기술/관심사',
                hintText: '예: 디자인, 번역, 글쓰기, 코딩',
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
                  if (currentJobController.text.isNotEmpty &&
                      availableTimeController.text.isNotEmpty &&
                      skillsController.text.isNotEmpty) {
                    onSubmit({
                      'currentJob': currentJobController.text,
                      'availableTime': availableTimeController.text,
                      'skills': skillsController.text
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('모든 정보를 입력해주세요'),
                        backgroundColor: Colors.orange))
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                  backgroundColor: const Color(0xFFFF6B6B)),
                child: const Text(
                  '부업 운세 확인하기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))))]))
    );
  }

  Widget _buildResultSection(BuildContext context, FortuneResult result, VoidCallback onShare) {
    final sections = result.sections ?? {};
    
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSummaryCard(result.summary ?? '부업 성공을 위한 운세입니다.'),
          const SizedBox(height: 16),
          _buildMainResultCard(
            title: '추천 부업',
            content: sections['recommended_sidejobs'] ?? '맞춤 부업을 추천 중입니다.',
            icon: Icons.recommend,
            color: Colors.red),
          const SizedBox(height: 16),
          _buildMainResultCard(
            title: '시작 시기',
            content: sections['timing'] ?? '최적의 시작 시기를 분석 중입니다.',
            icon: Icons.calendar_today,
            color: Colors.blue),
          const SizedBox(height: 16),
          _buildMainResultCard(
            title: '예상 수익',
            content: sections['income_forecast'] ?? '예상 수익을 계산 중입니다.',
            icon: Icons.attach_money,
            color: Colors.green),
          const SizedBox(height: 16),
          _buildMainResultCard(
            title: '성공 전략',
            content: sections['success_strategy'] ?? '부업 성공 전략을 준비 중입니다.',
            icon: Icons.trending_up,
            color: Colors.orange),
          const SizedBox(height: 16),
          _buildWorkLifeBalance(sections['work_life_balance']),
          const SizedBox(height: 16),
          _buildGrowthPotential(sections['growth_potential']),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.share),
            label: const Text('운세 공유하기'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 24)])
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
            colors: [Colors.red.shade50, Colors.yellow.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight)),
        child: Column(
          children: [
            Icon(Icons.work_outline, size: 48, color: Colors.red.shade700),
            const SizedBox(height: 16),
            Text(
              '부업 운세 요약',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800)),
            const SizedBox(height: 16),
            Text(
              summary,
              style: const TextStyle(fontSize: 16, height: 1.6),
              textAlign: TextAlign.center)])))
    );
  }

  Widget _buildMainResultCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color}) {
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
                    borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 28)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold)))]),
            const SizedBox(height: 16),
            Text(
              content,
              style: const TextStyle(fontSize: 16, height: 1.6))]))))
    );
  }

  Widget _buildWorkLifeBalance(String? balance) {
    if (balance == null) return const SizedBox.shrink();

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
                    borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.balance, color: Colors.purple, size: 28)),
                const SizedBox(width: 16),
                const Text(
                  '일과 삶의 균형',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold))]),
            const SizedBox(height: 16),
            Text(
              balance,
              style: const TextStyle(fontSize: 16, height: 1.6))]))))
    );
  }

  Widget _buildGrowthPotential(String? potential) {
    if (potential == null) return const SizedBox.shrink();

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
                    borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.trending_up, color: Colors.teal, size: 28)),
                const SizedBox(width: 16),
                const Text(
                  '성장 가능성',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold))]),
            const SizedBox(height: 16),
            Text(
              potential,
              style: const TextStyle(fontSize: 16, height: 1.6))]))))
    );
  }
}