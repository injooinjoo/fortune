import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/fortune_explanation_bottom_sheet.dart';

/// Example screen demonstrating the fortune explanation bottom sheet
class FortuneExplanationExample extends ConsumerWidget {
  const FortuneExplanationExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fortuneTypes = [
      {'id': 'daily', 'title': '오늘의 운세', 'icon': Icons.wb_sunny},
      {'id': 'love', 'title': '연애운', 'icon': Icons.favorite},
      {'id': 'career', 'title': '직업운', 'icon': Icons.work},
      {'id': 'wealth', 'title': '금전운', 'icon': Icons.attach_money},
      {'id': 'health', 'title': '건강운', 'icon': Icons.health_and_safety},
      {'id': 'saju', 'title': '사주팔자', 'icon': Icons.auto_awesome},
      {'id': 'mbti', 'title': 'MBTI 운세', 'icon': Icons.psychology},
      {'id': 'zodiac', 'title': '별자리 운세', 'icon': Icons.star},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('운세 해석 가이드 예제'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '운세 타입을 선택하면 해석 가이드를 볼 수 있습니다',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: fortuneTypes.length,
                itemBuilder: (context, index) {
                  final fortune = fortuneTypes[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        FortuneExplanationBottomSheet.show(
                          context,
                          fortuneType: fortune['id'] as String,
                          fortuneData: {
                            'score': 85,
                            'luckyItems': {
                              'color': '파란색',
                              'number': '7',
                              'direction': '동쪽',
                              'time': '오후 3시',
                            },
                          },
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            fortune['icon'] as IconData,
                            size: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            fortune['title'] as String,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}