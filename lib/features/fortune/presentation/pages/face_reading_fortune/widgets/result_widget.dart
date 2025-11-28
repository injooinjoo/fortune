import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/components/app_card.dart';
import '../../../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../../../core/utils/fortune_text_cleaner.dart';
import '../../../../../../core/utils/logger.dart';
import '../../../../domain/models/fortune_result.dart';
import '../../../widgets/face_reading/interactive_face_map.dart';
import '../../../widgets/face_reading/celebrity_match_carousel.dart';
import 'fortune_section_widget.dart';
import 'ogwan_section_widget.dart';

class ResultWidget extends StatelessWidget {
  final FortuneResult result;
  final bool isDark;
  final VoidCallback? onUnlockRequested;

  const ResultWidget({
    super.key,
    required this.result,
    required this.isDark,
    this.onUnlockRequested,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ 실제 데이터는 result.details.details에 있음!
    final rawData = result.details ?? {};
    final data = (rawData['details'] as Map<String, dynamic>?) ?? rawData;
    final luckScore = ((rawData['luckScore'] ?? result.overallScore) ?? 75).toInt();

    // 🔍 디버그: 데이터 구조 확인
    Logger.debug('[FaceReading] rawData keys: ${rawData.keys.toList()}');
    Logger.debug('[FaceReading] data keys: ${data.keys.toList()}');
    Logger.debug('[FaceReading] ogwan: ${data['ogwan']}');
    Logger.debug('[FaceReading] wealth_fortune: ${data['wealth_fortune']}');
    Logger.debug('[FaceReading] overall_fortune: ${data['overall_fortune']}');

    return Column(
      children: [
        // 🎯 관상 점수 게이지
        _buildScoreGauge(data, luckScore),

        const SizedBox(height: 24),

        // 🌟 닮은꼴 유명인 섹션 (무료 공개 - 바이럴 효과)
        if (data['similar_celebrities'] != null &&
            (data['similar_celebrities'] as List).isNotEmpty) ...[
          CelebrityMatchCarousel(
            celebrities: (data['similar_celebrities'] as List)
                .map((e) => e as Map<String, dynamic>)
                .toList(),
            isBlurred: false, // 무료 공개
          ),
          const SizedBox(height: 24),
        ],

        // 🎯 Interactive Face Map (오관 시각화)
        if (data['ogwan'] != null) ...[
          InteractiveFaceMap(
            ogwanData: data['ogwan'] as Map<String, dynamic>?,
            isBlurred: result.isBlurred,
            onUnlockRequested: result.isBlurred ? onUnlockRequested : null,
          ),
          const SizedBox(height: 24),
        ],

        // 🌟 전통 관상학: 오관(五官) 분석 (텍스트 상세)
        if (data['ogwan'] != null) ...[
          OgwanSectionWidget(
            data: data,
            result: result,
            isDark: isDark,
          ),
          const SizedBox(height: 24),
        ],

        // 🌟 구버전 하위 호환: 4대 운세 (기존 DB 데이터용)
        if (data['ogwan'] == null && data['wealth_fortune'] != null) ...[
          _buildLegacyFortuneSections(data),
        ],

        // 🌟 전통 관상학: 삼정(三停) 분석
        if (data['samjeong'] != null) ...[
          _buildSamjeongSection(data),
        ],

        // 🌟 전통 관상학: 십이궁(十二宮) 분석
        if (data['sibigung'] != null) ...[
          _buildSibigungSection(data),
        ],

        // 🧠 성격과 기질 (🔒 프리미엄)
        if (data['personality'] != null) ...[
          _buildPremiumSection(
            data: data,
            key: 'personality',
            icon: Icons.psychology,
            title: '성격과 기질',
            color: TossDesignSystem.purple,
            delay: 500,
          ),
        ],

        // ✨ 특별한 관상 특징 (🔒 프리미엄)
        if (data['special_features'] != null) ...[
          _buildPremiumSection(
            data: data,
            key: 'special_features',
            icon: Icons.auto_awesome,
            title: '특별한 관상 특징',
            color: TossDesignSystem.tossBlue,
            delay: 600,
          ),
        ],

        // 💡 조언과 개운법 (🔒 프리미엄)
        if (data['advice'] != null) ...[
          _buildPremiumSection(
            data: data,
            key: 'advice',
            icon: Icons.lightbulb,
            title: '조언과 개운법',
            color: Colors.amber,
            delay: 700,
          ),
        ],

        // 📖 전체 분석 (🔒 프리미엄)
        if (data['full_analysis'] != null) ...[
          _buildFullAnalysisSection(data),
        ],

        // Character Analysis
        if (data['character_traits'] != null) ...[
          _buildCharacterAnalysisSection(data),
        ],

        // Recommendations
        if (result.recommendations != null && result.recommendations!.isNotEmpty) ...[
          _buildRecommendationsSection(),
        ],
      ],
    );
  }

  Widget _buildScoreGauge(Map<String, dynamic> data, int luckScore) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TossDesignSystem.purple.withValues(alpha: 0.15),
            TossDesignSystem.tossBlue.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.purple.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 얼굴 아이콘
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [TossDesignSystem.purple, TossDesignSystem.tossBlue],
              ),
              boxShadow: [
                BoxShadow(
                  color: TossDesignSystem.purple.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.face,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          // 관상 타입
          Text(
            data['face_type'] ?? '관상 분석 완료',
            style: TossDesignSystem.heading2.copyWith(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          // 점수 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$luckScore',
                style: TypographyUnified.displayLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  foreground: Paint()
                    ..shader = LinearGradient(
                      colors: [TossDesignSystem.purple, TossDesignSystem.tossBlue],
                    ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '점',
                style: TossDesignSystem.heading4.copyWith(
                  color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 점수 게이지 바
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: luckScore / 100,
              minHeight: 12,
              backgroundColor: isDark
                  ? TossDesignSystem.grayDark300.withValues(alpha: 0.3)
                  : TossDesignSystem.gray300.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation(
                luckScore >= 80 ? TossDesignSystem.purple : TossDesignSystem.tossBlue,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 전체적인 인상
          if (data['overall_fortune'] != null)
            Text(
              FortuneTextCleaner.clean(data['overall_fortune']),
              style: TossDesignSystem.body1.copyWith(
                color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildLegacyFortuneSections(Map<String, dynamic> data) {
    return Column(
      children: [
        FortuneSectionWidget(
          icon: Icons.monetization_on,
          title: '재물운',
          content: FortuneTextCleaner.clean(data['wealth_fortune']?.toString() ?? '재물운이 상승하는 시기입니다.'),
          score: 85,
          color: Colors.amber,
          isDark: isDark,
          result: result,
          sectionKey: 'wealth_fortune',
          delay: 100,
        ),
        const SizedBox(height: 16),
        FortuneSectionWidget(
          icon: Icons.favorite,
          title: '애정운',
          content: FortuneTextCleaner.clean(data['love_fortune']?.toString() ?? '인연이 다가오고 있습니다.'),
          score: 78,
          color: Colors.pink,
          isDark: isDark,
          result: result,
          sectionKey: 'love_fortune',
          delay: 200,
        ),
        const SizedBox(height: 16),
        FortuneSectionWidget(
          icon: Icons.health_and_safety,
          title: '건강운',
          content: FortuneTextCleaner.clean(data['health_fortune']?.toString() ?? '건강 관리에 신경쓰면 좋은 결과가 있을 것입니다.'),
          score: 72,
          color: Colors.green,
          isDark: isDark,
          result: result,
          sectionKey: 'health_fortune',
          delay: 300,
        ),
        const SizedBox(height: 16),
        FortuneSectionWidget(
          icon: Icons.work,
          title: '직업운',
          content: FortuneTextCleaner.clean(data['career_fortune']?.toString() ?? '새로운 기회가 찾아올 것입니다.'),
          score: 80,
          color: TossDesignSystem.tossBlue,
          isDark: isDark,
          result: result,
          sectionKey: 'career_fortune',
          delay: 400,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSamjeongSection(Map<String, dynamic> data) {
    return Column(
      children: [
        UnifiedBlurWrapper(
          isBlurred: result.isBlurred,
          blurredSections: result.blurredSections,
          sectionKey: 'samjeong',
          child: AppCard(
            style: AppCardStyle.filled,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.linear_scale, color: TossDesignSystem.tossBlue, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      '삼정(三停) 분석',
                      style: TossDesignSystem.heading3.copyWith(
                        color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '상정(초년운), 중정(중년운), 하정(말년운)',
                  style: TossDesignSystem.caption.copyWith(
                    color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  FortuneTextCleaner.clean(data['samjeong'].toString()),
                  style: TossDesignSystem.body1.copyWith(
                    color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSibigungSection(Map<String, dynamic> data) {
    return Column(
      children: [
        UnifiedBlurWrapper(
          isBlurred: result.isBlurred,
          blurredSections: result.blurredSections,
          sectionKey: 'sibigung',
          child: AppCard(
            style: AppCardStyle.filled,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.grid_view, color: TossDesignSystem.purple, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      '십이궁(十二宮) 분석',
                      style: TossDesignSystem.heading3.copyWith(
                        color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '얼굴 12개 영역의 상세 분석',
                  style: TossDesignSystem.caption.copyWith(
                    color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  FortuneTextCleaner.clean(data['sibigung'].toString()),
                  style: TossDesignSystem.body1.copyWith(
                    color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPremiumSection({
    required Map<String, dynamic> data,
    required String key,
    required IconData icon,
    required String title,
    required Color color,
    required int delay,
  }) {
    return Column(
      children: [
        UnifiedBlurWrapper(
          isBlurred: result.isBlurred,
          blurredSections: result.blurredSections,
          sectionKey: key,
          child: AppCard(
            style: AppCardStyle.filled,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TossDesignSystem.heading4.copyWith(
                        color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lock, size: 12, color: color),
                          const SizedBox(width: 4),
                          Text(
                            '프리미엄',
                            style: TossDesignSystem.caption.copyWith(
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  FortuneTextCleaner.clean(data[key].toString()),
                  style: TossDesignSystem.body1.copyWith(
                    color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 500.ms, delay: delay.ms),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFullAnalysisSection(Map<String, dynamic> data) {
    return Column(
      children: [
        UnifiedBlurWrapper(
          isBlurred: result.isBlurred,
          blurredSections: result.blurredSections,
          sectionKey: 'full_analysis',
          child: AppCard(
            style: AppCardStyle.filled,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.description, color: TossDesignSystem.gray700),
                    const SizedBox(width: 8),
                    Text(
                      '전체 분석',
                      style: TossDesignSystem.heading4.copyWith(
                        color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: TossDesignSystem.gray700.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lock, size: 12, color: TossDesignSystem.gray700),
                          const SizedBox(width: 4),
                          Text(
                            '프리미엄',
                            style: TossDesignSystem.caption.copyWith(
                              color: TossDesignSystem.gray700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  data['full_analysis'].toString(),
                  style: TossDesignSystem.body1.copyWith(
                    color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 800.ms),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCharacterAnalysisSection(Map<String, dynamic> data) {
    return Column(
      children: [
        AppCard(
          style: AppCardStyle.filled,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology, color: TossDesignSystem.warningOrange),
                  const SizedBox(width: 8),
                  Text(
                    '성격 분석',
                    style: TossDesignSystem.heading4.copyWith(
                      color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (data['character_traits'] as List<dynamic>)
                    .map((trait) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: TossDesignSystem.warningOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: TossDesignSystem.warningOrange.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            trait.toString(),
                            style: TossDesignSystem.body3.copyWith(
                              color: TossDesignSystem.warningOrange,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRecommendationsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TossDesignSystem.successGreen.withValues(alpha: 0.1),
            TossDesignSystem.tossBlue.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates, color: TossDesignSystem.successGreen),
              const SizedBox(width: 8),
              Text(
                '운세 개선 조언',
                style: TossDesignSystem.heading4.copyWith(
                  color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...result.recommendations!.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 20,
                      color: TossDesignSystem.successGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rec,
                        style: TossDesignSystem.body2.copyWith(
                          color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 400.ms);
  }
}
