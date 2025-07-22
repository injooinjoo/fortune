import 'package:flutter/material.dart';
import '../../shared/components/fortune_snap_scroll.dart';
import '../../shared/glassmorphism/glass_container.dart';
import '../../core/constants/fortune_card_images.dart';
import '../../shared/components/app_header.dart';

/// Demo page showing the snap scroll effect for fortune cards
class FortuneSnapScrollDemo extends StatelessWidget {
  const FortuneSnapScrollDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Sample fortune data
    final fortunes = [
      _FortuneData(
        title: '오늘의 운세',
        description: '하루를 시작하는 긍정적인 에너지',
        content: '오늘은 새로운 기회가 찾아오는 날입니다. 평소보다 더 적극적으로 행동하면 좋은 결과를 얻을 수 있을 것입니다.',
        imageType: 'daily',
        score: 85,
        luckyColor: Colors.blue,
        luckyNumber: 7,
      ),
      _FortuneData(
        title: '연애운',
        description: '사랑과 인연의 흐름',
        content: '감정적인 교류가 활발한 시기입니다. 솔직한 대화를 통해 상대방과의 관계가 더욱 깊어질 수 있습니다.',
        imageType: 'love',
        score: 92,
        luckyColor: Colors.pink,
        luckyNumber: 2,
      ),
      _FortuneData(
        title: '재물운',
        description: '금전과 재산의 흐름',
        content: '투자보다는 저축에 집중하는 것이 좋은 시기입니다. 작은 금액이라도 꾸준히 모으면 큰 도움이 될 것입니다.',
        imageType: 'money',
        score: 78,
        luckyColor: Colors.green,
        luckyNumber: 8,
      ),
      _FortuneData(
        title: '건강운',
        description: '몸과 마음의 균형',
        content: '충분한 휴식이 필요한 때입니다. 무리하지 말고 자신의 페이스를 유지하며 건강을 관리하세요.',
        imageType: 'health',
        score: 70,
        luckyColor: Colors.teal,
        luckyNumber: 3,
      ),
      _FortuneData(
        title: '직업운',
        description: '커리어와 성공의 길',
        content: '새로운 프로젝트나 업무에서 당신의 능력을 발휘할 기회가 옵니다. 자신감을 가지고 도전하세요.',
        imageType: 'career',
        score: 88,
        luckyColor: Colors.indigo,
        luckyNumber: 9,
      ),
    ];

    // Create snap cards
    final snapCards = fortunes.map((fortune) {
      return FortuneSnapCard(
        imagePath: FortuneCardImages.getImagePath(fortune.imageType),
        title: fortune.title,
        description: fortune.description,
        content: _buildFortuneContent(context, fortune),
      );
    }).toList();

    return Scaffold(
      appBar: const AppHeader(
        title: '운세 스냅 스크롤',
        showBackButton: true,
      ),
      body: FortuneSnapScrollView(
        cards: snapCards,
        imageHeight: 350,
        snapDistance: 80,
        velocityThreshold: 150,
      ),
    );
  }

  Widget _buildFortuneContent(BuildContext context, _FortuneData fortune) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Score Section
        GlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      fortune.luckyColor.withValues(alpha: 0.3),
                      fortune.luckyColor.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(
                    color: fortune.luckyColor,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${fortune.score}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: fortune.luckyColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '오늘의 점수',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getScoreMessage(fortune.score),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Fortune Description
        GlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '상세 운세',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                fortune.content,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Lucky Items
        Row(
          children: [
            Expanded(
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: fortune.luckyColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.palette,
                        color: fortune.luckyColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '행운의 색',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${fortune.luckyNumber}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '행운의 숫자',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getScoreMessage(int score) {
    if (score >= 90) return '최고의 운세입니다!';
    if (score >= 80) return '매우 좋은 운세입니다';
    if (score >= 70) return '좋은 운세입니다';
    if (score >= 60) return '평범한 운세입니다';
    return '조심이 필요한 날입니다';
  }
}

class _FortuneData {
  final String title;
  final String description;
  final String content;
  final String imageType;
  final int score;
  final Color luckyColor;
  final int luckyNumber;

  _FortuneData({
    required this.title,
    required this.description,
    required this.content,
    required this.imageType,
    required this.score,
    required this.luckyColor,
    required this.luckyNumber,
  });
}