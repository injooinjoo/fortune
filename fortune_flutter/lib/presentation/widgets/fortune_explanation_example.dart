import 'package:flutter/material.dart';
import 'fortune_explanation_bottom_sheet.dart';
import 'fortune_card_with_info.dart';

/// Example of how to use FortuneExplanationBottomSheet
class FortuneExplanationExample extends StatelessWidget {
  const FortuneExplanationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('운세 설명 예시'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Example 1: Direct button to show bottom sheet
            ElevatedButton.icon(
              onPressed: () {
                FortuneExplanationBottomSheet.show(
                  context,
                  fortuneType: 'daily',
                  onFortuneButtonPressed: () {
                    // Navigate to daily fortune
                    Navigator.pushNamed(context, '/fortune/daily');
                  },
                );
              },
              icon: const Icon(Icons.info_outline),
              label: const Text('오늘의 운세 설명 보기'),
            ),
            
            const SizedBox(height: 20),
            
            // Example 2: Fortune card with info button
            FortuneCardWithInfo(
              icon: Icons.favorite,
              title: '연애운',
              description: '연애와 관련된 운세를 상세히 분석합니다',
              fortuneType: 'love',
              gradient: const [
                Color(0xFFFF6B6B),
                Color(0xFFFF8787),
              ],
              onTap: () {
                Navigator.pushNamed(context, '/fortune/love');
              },
            ),
            
            const SizedBox(height: 20),
            
            // Example 3: Grid of fortune cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  FortuneCardWithInfo(
                    icon: Icons.work,
                    title: '직업운',
                    description: '업무와 경력 발전',
                    fortuneType: 'career',
                    gradient: const [
                      Color(0xFF4ECDC4),
                      Color(0xFF44A08D),
                    ],
                    onTap: () => Navigator.pushNamed(context, '/fortune/career'),
                  ),
                  FortuneCardWithInfo(
                    icon: Icons.attach_money,
                    title: '금전운',
                    description: '재물운과 투자운',
                    fortuneType: 'wealth',
                    gradient: const [
                      Color(0xFFFFD93D),
                      Color(0xFFF6A623),
                    ],
                    onTap: () => Navigator.pushNamed(context, '/fortune/wealth'),
                  ),
                  FortuneCardWithInfo(
                    icon: Icons.health_and_safety,
                    title: '건강운',
                    description: '신체와 정신 건강',
                    fortuneType: 'health',
                    gradient: const [
                      Color(0xFF6FCF97),
                      Color(0xFF27AE60),
                    ],
                    onTap: () => Navigator.pushNamed(context, '/fortune/health'),
                  ),
                  FortuneCardWithInfo(
                    emoji: '🔮',
                    icon: Icons.auto_awesome,
                    title: '사주팔자',
                    description: '전통적인 운세 분석',
                    fortuneType: 'saju',
                    gradient: const [
                      Color(0xFF667EEA),
                      Color(0xFF764BA2),
                    ],
                    onTap: () => Navigator.pushNamed(context, '/fortune/saju'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}