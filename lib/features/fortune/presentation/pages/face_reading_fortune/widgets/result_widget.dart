import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/components/app_card.dart';
import '../../../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../../../core/widgets/gpt_style_typing_text.dart';
import '../../../../../../core/utils/fortune_text_cleaner.dart';
import '../../../../../../core/utils/logger.dart';
import '../../../../domain/models/fortune_result.dart';
import '../../../widgets/face_reading/interactive_face_map.dart';
import '../../../widgets/face_reading/celebrity_match_carousel.dart';
import 'fortune_section_widget.dart';
import 'ogwan_section_widget.dart';

class ResultWidget extends StatefulWidget {
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
  State<ResultWidget> createState() => _ResultWidgetState();
}

class _ResultWidgetState extends State<ResultWidget> {
  // GPT 스타일 타이핑 효과 섹션 관리
  int _currentTypingSection = 0;

  @override
  void didUpdateWidget(covariant ResultWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // result가 변경되면 타이핑 섹션 리셋
    if (widget.result != oldWidget.result) {
      setState(() => _currentTypingSection = 0);
    }
  }

  bool get isDark => widget.isDark;
  FortuneResult get result => widget.result;

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
            onUnlockRequested: result.isBlurred ? widget.onUnlockRequested : null,
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

        // ⭐ NEW: 연예인 싱크로율 하이라이트 섹션 (오관 분석 다음)
        if (data['similar_celebrities'] != null &&
            (data['similar_celebrities'] as List).isNotEmpty) ...[
          _buildCelebritySyncSection(data),
          const SizedBox(height: 24),
        ],

        // ⭐ NEW: 첫인상 점수 섹션
        if (data['first_impression_preview'] != null) ...[
          _buildFirstImpressionSection(data),
          const SizedBox(height: 24),
        ],

        // ⭐ NEW: 궁합운 (이상형 관상) 섹션
        if (data['compatibility_preview'] != null) ...[
          _buildCompatibilitySection(data),
          const SizedBox(height: 24),
        ],

        // ⭐ NEW: 결혼 적령기 예측 섹션
        if (data['marriage_prediction_preview'] != null) ...[
          _buildMarriagePredictionSection(data),
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
            color: DSColors.accent,
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
            color: DSColors.accent,
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
            DSColors.accent.withValues(alpha: 0.15),
            DSColors.accent.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: DSColors.accent.withValues(alpha: 0.1),
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
                colors: [DSColors.accent, DSColors.accent],
              ),
              boxShadow: [
                BoxShadow(
                  color: DSColors.accent.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.face,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          // 관상 타입
          Text(
            data['face_type'] ?? '관상 분석 완료',
            style: context.heading1.copyWith(
              color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
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
                style: context.displayLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  foreground: Paint()
                    ..shader = LinearGradient(
                      colors: [DSColors.accent, DSColors.accent],
                    ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '점',
                style: context.heading2.copyWith(
                  color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
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
                  ? DSColors.border.withValues(alpha: 0.3)
                  : DSColors.border.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation(
                luckScore >= 80 ? DSColors.accent : DSColors.accent,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 전체적인 인상
          if (data['overall_fortune'] != null)
            Center(
              child: GptStyleTypingText(
                text: FortuneTextCleaner.clean(data['overall_fortune']),
                style: context.bodyLarge.copyWith(
                  color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                  height: 1.6,
                ),
                startTyping: _currentTypingSection >= 0,
                showGhostText: true,
                onComplete: () {
                  if (mounted) setState(() => _currentTypingSection = 1);
                },
              ),
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
          color: DSColors.accent,
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
                    Icon(Icons.linear_scale, color: DSColors.accent, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      '삼정(三停) 분석',
                      style: context.heading2.copyWith(
                        color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '상정(초년운), 중정(중년운), 하정(말년운)',
                  style: context.labelSmall.copyWith(
                    color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                GptStyleTypingText(
                  text: FortuneTextCleaner.clean(data['samjeong'].toString()),
                  style: context.bodyLarge.copyWith(
                    color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                    height: 1.7,
                  ),
                  startTyping: _currentTypingSection >= 1,
                  showGhostText: true,
                  onComplete: () {
                    if (mounted) setState(() => _currentTypingSection = 2);
                  },
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
                    Icon(Icons.grid_view, color: DSColors.accent, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      '십이궁(十二宮) 분석',
                      style: context.heading2.copyWith(
                        color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '얼굴 12개 영역의 상세 분석',
                  style: context.labelSmall.copyWith(
                    color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                GptStyleTypingText(
                  text: FortuneTextCleaner.clean(data['sibigung'].toString()),
                  style: context.bodyLarge.copyWith(
                    color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                    height: 1.7,
                  ),
                  startTyping: _currentTypingSection >= 2,
                  showGhostText: true,
                  onComplete: () {
                    if (mounted) setState(() => _currentTypingSection = 3);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// ⭐ 연예인 싱크로율 하이라이트 섹션
  Widget _buildCelebritySyncSection(Map<String, dynamic> data) {
    final celebrities = (data['similar_celebrities'] as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();

    if (celebrities.isEmpty) return const SizedBox.shrink();

    // 상위 3명만 표시
    final topCelebrities = celebrities.take(3).toList();
    final firstCeleb = topCelebrities.isNotEmpty ? topCelebrities[0] : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFD700).withValues(alpha: 0.15), // Gold
            const Color(0xFFFF8C00).withValues(alpha: 0.15), // Orange
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.star,
                  color: Color(0xFFFFD700),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '당신과 닮은 유명인',
                style: context.heading2.copyWith(
                  color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 1위 연예인 (큰 카드)
          if (firstCeleb != null) _buildTopCelebrityCard(firstCeleb),

          // 2위, 3위 연예인 (작은 카드)
          if (topCelebrities.length > 1) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (topCelebrities.length > 1)
                  Expanded(child: _buildSmallCelebrityCard(topCelebrities[1], 2)),
                if (topCelebrities.length > 2) ...[
                  const SizedBox(width: 12),
                  Expanded(child: _buildSmallCelebrityCard(topCelebrities[2], 3)),
                ],
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  /// 1위 연예인 큰 카드
  Widget _buildTopCelebrityCard(Map<String, dynamic> celebrity) {
    final name = celebrity['name'] ?? '알 수 없음';
    final score = ((celebrity['similarity_score'] ?? 0) as num).toInt();
    final characterImageUrl = celebrity['character_image_url'] as String?;
    final matchedFeatures = (celebrity['matched_features'] as List?)?.cast<String>() ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? DSColors.backgroundSecondary.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 캐릭터 이미지 + 1위 배지
          Stack(
            children: [
              _buildCelebrityAvatar(characterImageUrl, name, 56),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '1위',
                    style: context.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 10, // 예외: 초소형 랭킹 배지
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: context.heading2.copyWith(
                    color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                // 매칭된 부위 태그
                if (matchedFeatures.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: matchedFeatures.take(4).map((feature) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: DSColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        feature,
                        style: context.labelSmall.copyWith(
                          color: DSColors.accent,
                          fontSize: 11, // 예외: 초소형 특징 태그
                        ),
                      ),
                    )).toList(),
                  ),
              ],
            ),
          ),

          // 원형 프로그레스 (싱크로율)
          _buildCircularProgress(score, 50),
        ],
      ),
    );
  }

  /// 2위, 3위 연예인 작은 카드
  Widget _buildSmallCelebrityCard(Map<String, dynamic> celebrity, int rank) {
    final name = celebrity['name'] ?? '알 수 없음';
    final score = ((celebrity['similarity_score'] ?? 0) as num).toInt();
    final characterImageUrl = celebrity['character_image_url'] as String?;

    final rankColors = {
      2: [const Color(0xFFC0C0C0), const Color(0xFFA8A8A8)], // Silver
      3: [const Color(0xFFCD7F32), const Color(0xFFB87333)], // Bronze
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? DSColors.backgroundSecondary.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              _buildCelebrityAvatar(characterImageUrl, name, 40),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: rankColors[rank]!),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$rank위',
                    style: context.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 9, // 예외: 초소형 랭킹 배지
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: context.labelSmall.copyWith(
                color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _buildCircularProgress(score, 36),
        ],
      ),
    );
  }

  /// 연예인 아바타 (캐릭터 이미지 또는 이니셜)
  Widget _buildCelebrityAvatar(String? imageUrl, String name, double size) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFFFD700).withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildInitialAvatar(name, size);
            },
          ),
        ),
      );
    }
    return _buildInitialAvatar(name, size);
  }

  /// 이니셜 아바타 (이미지 없을 때)
  Widget _buildInitialAvatar(String name, double size) {
    final initial = name.isNotEmpty ? name[0] : '?';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [DSColors.accent, DSColors.accent],
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: context.heading2.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.4, // 예외: 동적 아바타 이니셜 크기
          ),
        ),
      ),
    );
  }

  /// 원형 프로그레스 (싱크로율 표시)
  Widget _buildCircularProgress(int score, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // 배경 원
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 4,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(
                isDark
                    ? DSColors.border.withValues(alpha: 0.3)
                    : DSColors.border.withValues(alpha: 0.3),
              ),
            ),
          ),
          // 진행 원
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 4,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(
                score >= 80
                    ? const Color(0xFFFFD700)
                    : score >= 60
                        ? DSColors.accent
                        : DSColors.textTertiary,
              ),
            ),
          ),
          // 점수 텍스트
          Center(
            child: Text(
              '$score%',
              style: context.labelSmall.copyWith(
                color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: size * 0.24, // 예외: 동적 프로그레스 퍼센트 크기
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ⭐ 첫인상 점수 섹션
  Widget _buildFirstImpressionSection(Map<String, dynamic> data) {
    final firstImpression = data['first_impression_preview'] as Map<String, dynamic>?;
    if (firstImpression == null) return const SizedBox.shrink();

    final trustScore = ((firstImpression['trustScore'] ?? 0) as num).toInt();
    final approachScore = ((firstImpression['approachabilityScore'] ?? 0) as num).toInt();
    final charismaScore = ((firstImpression['charismaScore'] ?? 0) as num).toInt();

    return UnifiedBlurWrapper(
      isBlurred: result.isBlurred,
      blurredSections: result.blurredSections,
      sectionKey: 'first_impression',
      child: AppCard(
        style: AppCardStyle.filled,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DSColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.visibility,
                    color: DSColors.accent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '첫인상 분석',
                        style: context.heading2.copyWith(
                          color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '타인이 당신을 처음 볼 때 느끼는 인상',
                        style: context.labelSmall.copyWith(
                          color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 3가지 첫인상 점수
            Row(
              children: [
                Expanded(
                  child: _buildImpressionScoreCard(
                    icon: Icons.handshake,
                    label: '신뢰감',
                    score: trustScore,
                    color: DSColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildImpressionScoreCard(
                    icon: Icons.sentiment_satisfied,
                    label: '친근감',
                    score: approachScore,
                    color: DSColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildImpressionScoreCard(
                    icon: Icons.flash_on,
                    label: '카리스마',
                    score: charismaScore,
                    color: DSColors.accent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  /// 첫인상 개별 점수 카드
  Widget _buildImpressionScoreCard({
    required IconData icon,
    required String label,
    required int score,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: context.labelSmall.copyWith(
              color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$score점',
            style: context.heading2.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// ⭐ 궁합운 (이상형 관상) 섹션
  Widget _buildCompatibilitySection(Map<String, dynamic> data) {
    final compatibility = data['compatibility_preview'] as Map<String, dynamic>?;
    if (compatibility == null) return const SizedBox.shrink();

    final idealPartnerType = compatibility['idealPartnerType']?.toString() ?? '';
    final idealPartnerDescription = compatibility['idealPartnerDescription']?.toString() ?? '';
    final compatibilityScore = ((compatibility['compatibilityScore'] ?? 0) as num).toInt();

    return UnifiedBlurWrapper(
      isBlurred: result.isBlurred,
      blurredSections: result.blurredSections,
      sectionKey: 'compatibility',
      child: AppCard(
        style: AppCardStyle.filled,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.pink.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.pink,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '궁합운 - 이상형 관상',
                        style: context.heading2.copyWith(
                          color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '당신과 어울리는 상대의 관상 특징',
                        style: context.labelSmall.copyWith(
                          color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // 궁합 점수
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.pink, Colors.pinkAccent],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$compatibilityScore점',
                    style: context.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 이상형 관상 타입
            if (idealPartnerType.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.pink.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.pink.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.face, color: Colors.pink, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '이상형 관상',
                          style: context.labelSmall.copyWith(
                            color: Colors.pink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      idealPartnerType,
                      style: context.bodyMedium.copyWith(
                        color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // 이상형 상세 설명
            if (idealPartnerDescription.isNotEmpty)
              Text(
                idealPartnerDescription,
                style: context.bodyMedium.copyWith(
                  color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                  height: 1.6,
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  /// ⭐ 결혼 적령기 예측 섹션
  Widget _buildMarriagePredictionSection(Map<String, dynamic> data) {
    final marriage = data['marriage_prediction_preview'] as Map<String, dynamic>?;
    if (marriage == null) return const SizedBox.shrink();

    final earlyAge = marriage['earlyAge']?.toString() ?? '';
    final optimalAge = marriage['optimalAge']?.toString() ?? '';
    final lateAge = marriage['lateAge']?.toString() ?? '';
    final prediction = marriage['prediction']?.toString() ?? '';

    return UnifiedBlurWrapper(
      isBlurred: result.isBlurred,
      blurredSections: result.blurredSections,
      sectionKey: 'marriage_prediction',
      child: AppCard(
        style: AppCardStyle.filled,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.ring_volume,
                    color: Colors.amber,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '결혼 적령기 예측',
                        style: context.heading2.copyWith(
                          color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '삼정(三停) 균형 기반 분석',
                        style: context.labelSmall.copyWith(
                          color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 결혼 나이 타임라인
            Row(
              children: [
                Expanded(
                  child: _buildAgeCard(
                    label: '이른 결혼',
                    age: earlyAge,
                    color: DSColors.accent,
                    icon: Icons.flight_takeoff,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildAgeCard(
                    label: '최적 시기',
                    age: optimalAge,
                    color: DSColors.success,
                    icon: Icons.star,
                    isHighlighted: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildAgeCard(
                    label: '늦은 결혼',
                    age: lateAge,
                    color: DSColors.accent,
                    icon: Icons.hourglass_empty,
                  ),
                ),
              ],
            ),

            // 상세 예측
            if (prediction.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        prediction,
                        style: context.labelSmall.copyWith(
                          color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  /// 결혼 나이 카드
  Widget _buildAgeCard({
    required String label,
    required String age,
    required Color color,
    required IconData icon,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlighted
            ? color.withValues(alpha: 0.15)
            : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted
              ? color.withValues(alpha: 0.5)
              : color.withValues(alpha: 0.15),
          width: isHighlighted ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: isHighlighted ? 24 : 20,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: context.labelSmall.copyWith(
              color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
              fontSize: 10, // 예외: 초소형 나이 라벨
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            age.isNotEmpty ? age : '-',
            style: context.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: isHighlighted ? 13 : 12, // 예외: 결혼 나이 강조 표시
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
                      style: context.heading2.copyWith(
                        color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
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
                            style: context.labelSmall.copyWith(
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
                  style: context.bodyLarge.copyWith(
                    color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
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
                    Icon(Icons.description, color: DSColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      '전체 분석',
                      style: context.heading2.copyWith(
                        color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: DSColors.textSecondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lock, size: 12, color: DSColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '프리미엄',
                            style: context.labelSmall.copyWith(
                              color: DSColors.textSecondary,
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
                  style: context.bodyLarge.copyWith(
                    color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
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
                  Icon(Icons.psychology, color: DSColors.warning),
                  const SizedBox(width: 8),
                  Text(
                    '성격 분석',
                    style: context.heading2.copyWith(
                      color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
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
                            color: DSColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: DSColors.warning.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            trait.toString(),
                            style: context.labelSmall.copyWith(
                              color: DSColors.warning,
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
            DSColors.success.withValues(alpha: 0.1),
            DSColors.accent.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates, color: DSColors.success),
              const SizedBox(width: 8),
              Text(
                '운세 개선 조언',
                style: context.heading2.copyWith(
                  color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
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
                      color: DSColors.success,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rec,
                        style: context.bodyMedium.copyWith(
                          color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
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
