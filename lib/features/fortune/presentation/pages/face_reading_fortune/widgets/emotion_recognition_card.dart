import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/components/app_card.dart';
import '../../../../domain/models/emotion_analysis.dart';

/// 감정 인식 카드
/// 표정에서 읽어낸 감정 비율을 시각화합니다.
/// (미소, 긴장, 무표정, 편안함 등)
class EmotionRecognitionCard extends StatelessWidget {
  /// 감정 분석 데이터
  final EmotionAnalysis emotionAnalysis;

  /// 다크모드 여부
  final bool isDark;

  /// 성별 (콘텐츠 차별화)
  final String? gender;

  const EmotionRecognitionCard({
    super.key,
    required this.emotionAnalysis,
    required this.isDark,
    this.gender,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      style: AppCardStyle.filled,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          _buildHeader(context),
          const SizedBox(height: 20),

          // 주요 감정 (가장 높은 감정)
          _buildDominantEmotion(context),
          const SizedBox(height: 20),

          // 감정 비율 바
          _buildEmotionBars(context),

          // 인상 분석 (있는 경우)
          if (emotionAnalysis.impressionAnalysis != null) ...[
            const SizedBox(height: 16),
            _buildImpressionAnalysis(context),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.withValues(alpha: 0.15),
                Colors.indigo.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.mood,
            color: Colors.purple,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '표정 감정 분석',
                style: context.heading2.copyWith(
                  color: isDark
                      ? DSColors.textPrimaryDark
                      : DSColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _getSubtitleByGender(),
                style: context.labelSmall.copyWith(
                  color: isDark
                      ? DSColors.textSecondaryDark
                      : DSColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getSubtitleByGender() {
    if (gender == 'female') {
      return '당신의 표정에서 느껴지는 감정이에요';
    } else if (gender == 'male') {
      return '표정에서 읽히는 인상 분석';
    }
    return '사진에서 읽어낸 감정 비율';
  }

  Widget _buildDominantEmotion(BuildContext context) {
    final dominant = _getDominantEmotion();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            dominant.color.withValues(alpha: 0.15),
            dominant.color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: dominant.color.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          // 이모지
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: dominant.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                dominant.emoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // 설명
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      dominant.label,
                      style: context.heading3.copyWith(
                        color: dominant.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: dominant.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${dominant.percentage}%',
                        style: context.labelSmall.copyWith(
                          color: dominant.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  dominant.description,
                  style: context.bodySmall.copyWith(
                    color: isDark
                        ? DSColors.textSecondaryDark
                        : DSColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionBars(BuildContext context) {
    final emotions = [
      _EmotionData(
        label: '미소',
        emoji: '😊',
        percentage: emotionAnalysis.smilePercentage,
        color: Colors.amber,
        description: '밝고 친근한 인상',
      ),
      _EmotionData(
        label: '편안함',
        emoji: '😌',
        percentage: emotionAnalysis.relaxedPercentage,
        color: DSColors.success,
        description: '차분하고 안정적인 느낌',
      ),
      _EmotionData(
        label: '무표정',
        emoji: '😐',
        percentage: emotionAnalysis.neutralPercentage,
        color: DSColors.textTertiary,
        description: '신비롭고 깊이 있는 인상',
      ),
      _EmotionData(
        label: '긴장',
        emoji: '😰',
        percentage: emotionAnalysis.tensionPercentage,
        color: Colors.orange,
        description: '집중하고 있는 모습',
      ),
    ];

    // 비율순 정렬
    emotions.sort((a, b) => b.percentage.compareTo(a.percentage));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '감정 분포',
          style: context.labelLarge.copyWith(
            color: isDark
                ? DSColors.textPrimaryDark
                : DSColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...emotions.map((emotion) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _EmotionBar(
                emotion: emotion,
                isDark: isDark,
              ),
            )),
      ],
    );
  }

  Widget _buildImpressionAnalysis(BuildContext context) {
    final impression = emotionAnalysis.impressionAnalysis!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.indigo.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.indigo.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.visibility, color: Colors.indigo, size: 18),
              const SizedBox(width: 8),
              Text(
                '타인에게 주는 인상',
                style: context.labelLarge.copyWith(
                  color: Colors.indigo,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 인상 점수들
          Row(
            children: [
              Expanded(
                child: _ImpressionScore(
                  label: '신뢰감',
                  score: impression.trustScore,
                  icon: Icons.handshake,
                  color: Colors.blue,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ImpressionScore(
                  label: '친근감',
                  score: impression.approachabilityScore,
                  icon: Icons.favorite,
                  color: Colors.pink,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ImpressionScore(
                  label: '카리스마',
                  score: impression.charismaScore,
                  icon: Icons.flash_on,
                  color: Colors.amber,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          // 종합 인상 코멘트
          if (impression.overallImpression != null) ...[
            const SizedBox(height: 14),
            Text(
              impression.overallImpression!,
              style: context.bodySmall.copyWith(
                color: isDark
                    ? DSColors.textPrimaryDark
                    : DSColors.textPrimary,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  _EmotionData _getDominantEmotion() {
    final emotions = [
      _EmotionData(
        label: '미소',
        emoji: '😊',
        percentage: emotionAnalysis.smilePercentage,
        color: Colors.amber,
        description: '밝고 따뜻한 인상을 주고 있어요. 사람들이 편하게 다가올 수 있어요.',
      ),
      _EmotionData(
        label: '편안함',
        emoji: '😌',
        percentage: emotionAnalysis.relaxedPercentage,
        color: DSColors.success,
        description: '차분하고 안정적인 느낌이에요. 신뢰감을 주는 표정이에요.',
      ),
      _EmotionData(
        label: '무표정',
        emoji: '😐',
        percentage: emotionAnalysis.neutralPercentage,
        color: DSColors.textTertiary,
        description: '신비롭고 깊이 있어 보여요. 카리스마 있는 인상이에요.',
      ),
      _EmotionData(
        label: '긴장',
        emoji: '😰',
        percentage: emotionAnalysis.tensionPercentage,
        color: Colors.orange,
        description: '집중력이 높아 보여요. 진지한 인상을 줄 수 있어요.',
      ),
    ];

    emotions.sort((a, b) => b.percentage.compareTo(a.percentage));
    return emotions.first;
  }
}

/// 감정 데이터 모델
class _EmotionData {
  final String label;
  final String emoji;
  final double percentage;
  final Color color;
  final String description;

  const _EmotionData({
    required this.label,
    required this.emoji,
    required this.percentage,
    required this.color,
    required this.description,
  });
}

/// 감정 비율 바
class _EmotionBar extends StatelessWidget {
  final _EmotionData emotion;
  final bool isDark;

  const _EmotionBar({
    required this.emotion,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 이모지
        Text(emotion.emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),

        // 라벨
        SizedBox(
          width: 50,
          child: Text(
            emotion.label,
            style: context.labelSmall.copyWith(
              color: isDark
                  ? DSColors.textSecondaryDark
                  : DSColors.textSecondary,
            ),
          ),
        ),

        // 바
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: emotion.percentage / 100,
              minHeight: 10,
              backgroundColor: emotion.color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(emotion.color),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // 퍼센트
        SizedBox(
          width: 40,
          child: Text(
            '${emotion.percentage.round()}%',
            style: context.labelSmall.copyWith(
              color: emotion.color,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

/// 인상 점수 위젯
class _ImpressionScore extends StatelessWidget {
  final String label;
  final int score;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _ImpressionScore({
    required this.label,
    required this.score,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            label,
            style: context.labelSmall.copyWith(
              color: isDark
                  ? DSColors.textSecondaryDark
                  : DSColors.textSecondary,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$score',
            style: context.labelLarge.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
