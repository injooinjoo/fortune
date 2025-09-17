import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/toss_theme.dart';
import '../../../../../shared/components/toss_button.dart';
import '../../../../../core/theme/toss_design_system.dart';

class LoveFortuneResultPage extends StatelessWidget {
  final Map<String, dynamic> fortuneData;

  const LoveFortuneResultPage({
    super.key,
    required this.fortuneData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossTheme.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: TossTheme.backgroundPrimary,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            // Pop back to fortune list
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          icon: Icon(
            Icons.close,
            color: TossTheme.textBlack,
          ),
        ),
        title: Text(
          '연애운세 결과',
          style: TossTheme.heading3.copyWith(
            color: TossTheme.textBlack,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main score card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFF6B6B),
                    const Color(0xFFFF8CC8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    color: TossDesignSystem.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '오늘의 연애운',
                    style: TossTheme.body2.copyWith(
                      color: TossDesignSystem.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_calculateScore()}점',
                    style: TossTheme.heading1.copyWith(
                      color: TossDesignSystem.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getMainMessage(),
                    style: TossTheme.body1.copyWith(
                      color: TossDesignSystem.white,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 24),

            // Detail sections
            _buildDetailSection(
              '연애 성향',
              _getLoveStyle(),
              Icons.psychology_rounded,
              TossTheme.primaryBlue,
            ),

            _buildDetailSection(
              '매력 포인트',
              _getCharmPoints(),
              Icons.star_rounded,
              TossTheme.warning,
            ),

            _buildDetailSection(
              '개선 포인트',
              _getImprovementPoints(),
              Icons.trending_up_rounded,
              TossTheme.success,
            ),

            _buildDetailSection(
              '오늘의 조언',
              _getAdvice(),
              Icons.lightbulb_rounded,
              TossTheme.primaryBlue,
            ),

            const SizedBox(height: 32),

            // Action buttons
            TossButton(
              text: '결과 공유하기',
              onPressed: () {
                // TODO: Implement share
              },
              style: TossButtonStyle.secondary,
              icon: const Icon(Icons.share, size: 20),
            ),

            const SizedBox(height: 12),

            TossButton(
              text: '다시 분석하기',
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.refresh, size: 20),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String content, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TossDesignSystem.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TossTheme.borderGray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TossTheme.body1.copyWith(
                  fontWeight: FontWeight.w600,
                  color: TossTheme.textBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TossTheme.body2.copyWith(
              color: TossTheme.textGray600,
              height: 1.6,
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: 200.ms, duration: 500.ms)
      .slideX(begin: -0.1, end: 0);
  }

  int _calculateScore() {
    // Calculate score based on input data
    int score = 70; // Base score

    // Adjust based on relationship status
    if (fortuneData['relationshipStatus'] == 'single') {
      score += 5;
    } else if (fortuneData['relationshipStatus'] == 'dating') {
      score += 10;
    }

    // Adjust based on experience
    if (fortuneData['loveExperience'] == 'experienced') {
      score += 5;
    }

    // Adjust based on communication
    if (fortuneData['communicationFrequency'] == 'daily') {
      score += 10;
    }

    return score.clamp(0, 100);
  }

  String _getMainMessage() {
    final score = _calculateScore();
    if (score >= 80) {
      return '사랑이 꽃피는 최고의 날이에요!\n특별한 인연을 만날 수 있을 거예요.';
    } else if (score >= 60) {
      return '좋은 기운이 감도는 날이에요.\n마음을 열고 다가가보세요.';
    } else if (score >= 40) {
      return '평온한 하루가 될 거예요.\n자신을 돌아보는 시간을 가져보세요.';
    } else {
      return '조금 더 기다려보세요.\n좋은 인연은 곧 찾아올 거예요.';
    }
  }

  String _getLoveStyle() {
    final style = fortuneData['loveStyle'];
    if (style == 'passionate') {
      return '열정적이고 적극적인 연애 스타일을 가지고 있어요. 감정 표현이 풍부하고 상대방에게 헌신적입니다.';
    } else if (style == 'careful') {
      return '신중하고 진지한 연애 스타일을 가지고 있어요. 천천히 관계를 발전시키며 안정적인 관계를 추구합니다.';
    } else if (style == 'friendly') {
      return '친구 같은 편안한 연애 스타일을 가지고 있어요. 소통을 중시하고 함께 성장하는 관계를 추구합니다.';
    } else {
      return '자유롭고 독립적인 연애 스타일을 가지고 있어요. 서로의 공간을 존중하며 성숙한 관계를 추구합니다.';
    }
  }

  String _getCharmPoints() {
    final charmPoints = fortuneData['charmPoints'] as List<dynamic>? ?? [];
    if (charmPoints.isEmpty) {
      return '당신만의 특별한 매력을 찾아보세요. 자신감이 가장 큰 매력이 될 수 있어요.';
    }
    final charmList = charmPoints.map((e) => e.toString()).toList();
    return '${charmList.join(', ')} 등이 당신의 매력 포인트에요. 이런 장점들을 자신있게 어필해보세요!';
  }

  String _getImprovementPoints() {
    final relationshipStatus = fortuneData['relationshipStatus'];
    if (relationshipStatus == 'single') {
      return '새로운 만남에 더 적극적으로 나서보세요. 다양한 활동에 참여하면 좋은 인연을 만날 수 있을 거예요.';
    } else if (relationshipStatus == 'dating') {
      return '상대방과의 소통을 더 늘려보세요. 작은 관심과 배려가 관계를 더욱 돈독하게 만들어줄 거예요.';
    } else {
      return '자신의 감정을 솔직하게 표현해보세요. 진정성 있는 모습이 더 좋은 관계로 이어질 거예요.';
    }
  }

  String _getAdvice() {
    final score = _calculateScore();
    if (score >= 80) {
      return '오늘은 특별한 날이 될 거예요. 평소와 다른 스타일을 시도해보거나 새로운 장소를 방문해보세요. 운명적인 만남이 기다리고 있을지도 몰라요.';
    } else if (score >= 60) {
      return '긍정적인 에너지가 가득한 날이에요. 밝은 미소와 친절한 태도로 주변 사람들과 소통해보세요. 예상치 못한 좋은 일이 생길 수 있어요.';
    } else {
      return '오늘은 자신을 돌보는 시간을 가져보세요. 좋아하는 취미 활동을 하거나 편안한 휴식을 취하면서 내면의 평화를 찾아보세요.';
    }
  }
}