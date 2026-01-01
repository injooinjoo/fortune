import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/typography_unified.dart';
import '../../../../../core/models/fortune_result.dart';
import '../../../../../core/widgets/blurred_fortune_content.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/utils/fortune_text_cleaner.dart';
import '../../../../../core/widgets/unified_button.dart';
import '../../../../../services/ad_service.dart'; // ✅ RewardedAd용
import '../../../../../core/utils/subscription_snackbar.dart';
import '../../../../../presentation/providers/token_provider.dart';
import '../../../../../core/utils/logger.dart'; // ✅ 로그용
import '../../../../../core/services/fortune_haptic_service.dart';
import '../../../../../core/utils/fortune_completion_helper.dart';
import '../../../../../core/widgets/today_result_label.dart';

/// 연애운 결과 페이지 (프리미엄/블러 시스템 적용)
///
/// **블러 섹션** (4개):
/// - compatibilityInsights: 궁합 인사이트
/// - predictions: 미래 예측
/// - actionPlan: 실천 계획
/// - warningArea: 주의사항
///
/// **Floating Button**: "연애 조언 모두 보기"
class LoveFortuneResultPage extends ConsumerStatefulWidget {
  final FortuneResult fortuneResult;

  const LoveFortuneResultPage({
    super.key,
    required this.fortuneResult,
  });

  @override
  ConsumerState<LoveFortuneResultPage> createState() => _LoveFortuneResultPageState();
}

class _LoveFortuneResultPageState extends ConsumerState<LoveFortuneResultPage> {
  late FortuneResult _fortuneResult;
  bool _hapticTriggered = false;

  @override
  void initState() {
    super.initState();
    _fortuneResult = widget.fortuneResult;
    debugPrint('[연애운] 결과 페이지 초기화 - isBlurred: ${_fortuneResult.isBlurred}');

    // 연애운 결과 공개 햅틱 (하트비트 + 점수)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hapticTriggered) {
        _hapticTriggered = true;

        // ✅ 프리미엄 사용자는 블러 해제 (테스트계정, 무제한토큰 포함)
        final tokenState = ref.read(tokenProvider);
        final isPremium = tokenState.hasUnlimitedAccess;
        if (isPremium && _fortuneResult.isBlurred) {
          setState(() {
            _fortuneResult = _fortuneResult.copyWith(
              isBlurred: false,
              blurredSections: [],
            );
          });
          debugPrint('[연애운] 프리미엄 사용자 - 블러 자동 해제');
        }

        final haptic = ref.read(fortuneHapticServiceProvider);
        final loveScore = _fortuneResult.data['loveScore'] as int? ?? 70;
        // 하트비트 패턴으로 두근두근 느낌
        haptic.loveHeartbeat();
        // 점수에 따른 차별화 햅틱
        Future.delayed(const Duration(milliseconds: 300), () {
          haptic.scoreReveal(loveScore);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false, // 백버튼 제거
          title: Text(
            '연애운세 결과',
            style: context.heading2.copyWith(
              color: colors.textPrimary,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.close,
                color: colors.textPrimary,
              ),
              onPressed: () => context.go('/fortune'),
            ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              // 1. 메인 점수 카드 (공개)
              _buildMainScoreCard(colors),
              const SizedBox(height: 24),

              // 2. 연애 성향 (공개)
              _buildLoveStyleSection(colors),

              // 3. 매력 포인트 (공개)
              _buildCharmPointsSection(colors),

              // 4. 개선 포인트 (공개)
              _buildImprovementSection(colors),

              // 5. 추천 장소 (메인만 공개, 대안은 블러)
              _buildDateSpotSection(colors),

              // 6. 스타일 추천 (블러)
              _buildBlurredSection(
                title: '스타일 추천',
                icon: Icons.checkroom_rounded,
                color: const Color(0xFF6B5CE7),
                contentBuilder: () => _buildFashionContent(colors),
                colors: colors,
              ),

              // 7. 악세서리 추천 (블러)
              _buildBlurredSection(
                title: '악세서리 추천',
                icon: Icons.watch_rounded,
                color: const Color(0xFFE67E22),
                contentBuilder: () => _buildAccessoriesContent(colors),
                colors: colors,
              ),

              // 8. 향수 추천 (블러)
              _buildBlurredSection(
                title: '향수 추천',
                icon: Icons.spa_rounded,
                color: const Color(0xFFE91E63),
                contentBuilder: () => _buildFragranceContent(colors),
                colors: colors,
              ),

              // 9. 대화 팁 (블러)
              _buildBlurredSection(
                title: '대화 팁',
                icon: Icons.chat_bubble_outline_rounded,
                color: const Color(0xFF00BCD4),
                contentBuilder: () => _buildConversationContent(colors),
                colors: colors,
              ),

              // 10. 궁합 인사이트 (블러)
              _buildBlurredSection(
                title: '궁합 인사이트',
                icon: Icons.people_rounded,
                color: const Color(0xFF9C27B0),
                contentBuilder: () => _buildCompatibilityInsightsContent(colors),
                colors: colors,
              ),

              // 6. 미래 예측 (블러)
              _buildBlurredSection(
                title: '미래 예측',
                icon: Icons.calendar_today_rounded,
                color: colors.accent,
                contentBuilder: () => _buildPredictionsContent(colors),
                colors: colors,
              ),

              // 7. 실천 계획 (블러)
              _buildBlurredSection(
                title: '실천 계획',
                icon: Icons.checklist_rounded,
                color: DSColors.success,
                contentBuilder: () => _buildActionPlanContent(colors),
                colors: colors,
              ),

              // 8. 주의사항 (블러)
              _buildBlurredSection(
                title: '⚠️ 주의사항',
                icon: Icons.warning_rounded,
                color: DSColors.error,
                contentBuilder: () => _buildWarningContent(colors),
                colors: colors,
              ),

              const SizedBox(height: 80), // Floating Button 공간
                ],
              ),
            ),

            // 🎯 Floating Button (블러 상태 + 비구독자만 표시)
            if (_fortuneResult.isBlurred && !ref.watch(tokenProvider).hasUnlimitedAccess)
              UnifiedButton.floating(
                text: '연애 조언 모두 보기',
                onPressed: _showAdAndUnblur,
                isLoading: false,
                isEnabled: true,
              ),
          ],
        ),
      ),
    );
  }

  // ===== 공개 섹션 빌더 =====

  Widget _buildMainScoreCard(DSColorScheme colors) {
    final data = _fortuneResult.data;
    final loveScore = data['loveScore'] as int? ?? 70;
    final mainMessage = FortuneTextCleaner.clean(data['mainMessage'] as String? ?? '');

    // 세부 점수 (API에서 제공하거나 기본값 사용)
    final subScores = data['subScores'] as Map<String, dynamic>? ?? {};
    final passionScore = subScores['passion'] as int? ?? (loveScore + 5).clamp(0, 100);
    final emotionScore = subScores['emotion'] as int? ?? (loveScore - 3).clamp(0, 100);
    final trustScore = subScores['trust'] as int? ?? loveScore;
    final communicationScore = subScores['communication'] as int? ?? (loveScore + 2).clamp(0, 100);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6B6B),
            Color(0xFFFF8CC8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // 오늘 날짜 라벨 + 재방문 유도
          const TodayResultLabel(
            useLightTheme: true,
            showRevisitHint: true,
          ),
          const SizedBox(height: 12),
          const Icon(
            Icons.favorite_rounded,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            '연애운',
            style: context.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
          // ✅ 점수 표시 개선 (/ 100 추가)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '❤️ $loveScore',
                style: context.displayLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '/ 100',
                style: context.bodyLarge.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ✅ 프로그레스 바 추가
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: loveScore / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            mainMessage,
            style: context.bodyLarge.copyWith(
              color: Colors.white,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // ✅ 세부 점수 태그
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildSubScoreTag('💘 열정', passionScore),
              _buildSubScoreTag('💕 감성', emotionScore),
              _buildSubScoreTag('🤝 신뢰', trustScore),
              _buildSubScoreTag('💬 소통', communicationScore),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms);
  }

  /// 세부 점수 태그 위젯
  Widget _buildSubScoreTag(String label, int score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        '$label $score',
        style: context.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLoveStyleSection(DSColorScheme colors) {
    final data = _fortuneResult.data;
    final detailedAnalysis = data['detailedAnalysis'] as Map<String, dynamic>? ?? {};
    final loveStyle = detailedAnalysis['loveStyle'] as Map<String, dynamic>? ?? {};
    final description = FortuneTextCleaner.clean(loveStyle['description'] as String? ?? '당신만의 특별한 연애 스타일을 가지고 있어요.');

    // ✅ 연애 타입 추출 (API에서 제공하거나 기본값)
    final loveType = loveStyle['type'] as String? ??
        data['loveType'] as String? ??
        _extractLoveType(description);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.psychology_rounded, color: colors.accent, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                '연애 성향',
                style: context.heading3.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ✅ 타입 배지 추가
          _buildLoveTypeBadge(loveType),
          const SizedBox(height: 12),
          Text(
            description,
            style: context.bodyMedium.copyWith(
              color: colors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    ).animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .slideX(begin: -0.1, end: 0);
  }

  /// 연애 타입 배지 위젯
  Widget _buildLoveTypeBadge(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B9D), Color(0xFFFFA8C5)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B9D).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            type,
            style: context.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// 설명에서 연애 타입 추출 (기본값 생성)
  String _extractLoveType(String description) {
    if (description.contains('로맨틱') || description.contains('감성')) {
      return '로맨티스트';
    } else if (description.contains('열정') || description.contains('적극')) {
      return '열정파';
    } else if (description.contains('신중') || description.contains('조심')) {
      return '신중파';
    } else if (description.contains('자유') || description.contains('독립')) {
      return '자유영혼';
    } else if (description.contains('배려') || description.contains('따뜻')) {
      return '따뜻한 배려파';
    } else {
      return '매력적인 연애러';
    }
  }

  Widget _buildCharmPointsSection(DSColorScheme colors) {
    final data = _fortuneResult.data;
    final detailedAnalysis = data['detailedAnalysis'] as Map<String, dynamic>? ?? {};
    final charmPoints = detailedAnalysis['charmPoints'] as Map<String, dynamic>? ?? {};
    final primary = FortuneTextCleaner.clean(charmPoints['primary'] as String? ?? '');
    final details = List<String>.from(charmPoints['details'] ?? []).map((d) => FortuneTextCleaner.clean(d.toString())).toList();

    // ✅ 태그용 매력 키워드 추출
    final charmTags = data['charms'] as List<dynamic>? ??
        charmPoints['tags'] as List<dynamic>? ??
        _extractCharmTags(primary, details);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DSColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.star_rounded, color: DSColors.warning, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                '매력 포인트',
                style: context.heading3.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ✅ 태그 형태로 매력 표시
          _buildCharmTags(charmTags.map((e) => e.toString()).toList()),
          if (primary.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              primary,
              style: context.bodyMedium.copyWith(
                color: colors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    ).animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .slideX(begin: -0.1, end: 0);
  }

  /// 매력 태그 위젯
  Widget _buildCharmTags(List<String> charms) {
    if (charms.isEmpty) {
      return _buildCharmTags(['유머 감각', '배려심', '센스']);
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: charms.map((charm) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0F5), // 연한 핑크색 배경
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFF6B9D).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✨', style: TextStyle(fontSize: 12)), // 예외: 이모지
            const SizedBox(width: 4),
            Text(
              charm,
              style: context.labelMedium.copyWith(
                color: const Color(0xFFFF6B9D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  /// 설명에서 매력 키워드 추출
  List<String> _extractCharmTags(String primary, List<String> details) {
    final keywords = <String>[];
    final combined = '$primary ${details.join(' ')}';

    // 일반적인 매력 키워드 매핑
    final keywordMap = {
      '유머': '유머 감각',
      '웃음': '유머 감각',
      '배려': '배려심',
      '따뜻': '따뜻한 마음',
      '센스': '센스',
      '진실': '진실된 모습',
      '솔직': '솔직함',
      '자신감': '자신감',
      '열정': '열정',
      '긍정': '긍정적 에너지',
      '지적': '지적 매력',
      '친절': '친절함',
      '다정': '다정함',
      '사려': '사려 깊음',
      '경청': '경청 능력',
      '공감': '공감 능력',
      '표현': '표현력',
    };

    for (final entry in keywordMap.entries) {
      if (combined.contains(entry.key) && keywords.length < 4) {
        keywords.add(entry.value);
      }
    }

    // 키워드가 없으면 기본값
    if (keywords.isEmpty) {
      return ['매력적인 눈빛', '따뜻한 미소', '진심 어린 대화'];
    }

    return keywords;
  }

  Widget _buildImprovementSection(DSColorScheme colors) {
    final data = _fortuneResult.data;
    final detailedAnalysis = data['detailedAnalysis'] as Map<String, dynamic>? ?? {};
    final improvementAreas = detailedAnalysis['improvementAreas'] as Map<String, dynamic>? ?? {};
    final main = FortuneTextCleaner.clean(improvementAreas['main'] as String? ?? '');
    final specific = List<String>.from(improvementAreas['specific'] ?? []).map((s) => FortuneTextCleaner.clean(s.toString())).toList();

    final content = specific.isNotEmpty
        ? '$main\n\n• ${specific.join('\n• ')}'
        : main;

    return _buildDetailSection(
      context,
      '개선 포인트',
      content.isEmpty ? '자신의 감정을 솔직하게 표현해보세요.' : content,
      Icons.trending_up_rounded,
      DSColors.success,
      colors,
    );
  }

  // ===== 블러 섹션 빌더 (제목 블러 해제) =====

  /// 블러 처리된 섹션 (제목은 공개, 내용만 블러)
  Widget _buildBlurredSection({
    required String title,
    required IconData icon,
    required Color color,
    required Widget Function() contentBuilder,
    required DSColorScheme colors,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 (항상 공개)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: context.heading3.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 내용 (블러 처리)
          BlurredFortuneContent(
            fortuneResult: _fortuneResult,
            child: contentBuilder(),
          ),
        ],
      ),
    ).animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .slideX(begin: -0.1, end: 0);
  }

  // 블러 섹션 내용 빌더들

  Widget _buildCompatibilityInsightsContent(DSColorScheme colors) {
    final data = _fortuneResult.data;
    final detailedAnalysis = data['detailedAnalysis'] as Map<String, dynamic>? ?? {};
    final compatibilityInsights = detailedAnalysis['compatibilityInsights'] as Map<String, dynamic>? ?? {};

    final bestMatch = FortuneTextCleaner.clean(compatibilityInsights['bestMatch'] as String? ?? '');
    final goodMatch = FortuneTextCleaner.clean(compatibilityInsights['goodMatch'] as String? ?? '');
    final challengingMatch = FortuneTextCleaner.clean(compatibilityInsights['challengingMatch'] as String? ?? '');
    final avoidTypes = FortuneTextCleaner.clean(compatibilityInsights['avoidTypes'] as String? ?? '');
    final tips = List<String>.from(compatibilityInsights['relationshipTips'] ?? []).map((t) => FortuneTextCleaner.clean(t.toString())).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInsightItem(
          '💖',
          '최고 궁합',
          bestMatch.isNotEmpty ? bestMatch : '진실하고 따뜻한 마음을 가진 파트너가 잘 맞습니다.',
          colors,
        ),
        const SizedBox(height: 12),
        _buildInsightItem(
          '💕',
          '좋은 궁합',
          goodMatch.isNotEmpty ? goodMatch : '서로를 존중하고 이해하는 관계가 좋습니다.',
          colors,
        ),
        const SizedBox(height: 12),
        _buildInsightItem(
          '⚡',
          '도전적 궁합',
          challengingMatch.isNotEmpty ? challengingMatch : '서로 다른 가치관에 대한 열린 대화가 필요합니다.',
          colors,
        ),
        const SizedBox(height: 12),
        _buildInsightItem(
          '🚫',
          '피해야 할 유형',
          avoidTypes.isNotEmpty ? avoidTypes : '진실하지 못하거나 감정 기복이 심한 사람',
          colors,
        ),
        const SizedBox(height: 16),
        Text(
          '💡 관계 팁',
          style: context.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...tips.isEmpty
            ? [_buildTipItem('서로를 존중하고 이해하는 관계를 만들어가세요.', colors)]
            : tips.map((tip) => _buildTipItem(tip, colors)),
      ],
    );
  }

  /// 궁합 인사이트 항목 위젯
  Widget _buildInsightItem(String emoji, String label, String content, DSColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$emoji $label',
          style: context.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: context.bodyMedium.copyWith(
            color: colors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  /// 관계 팁 항목 위젯
  Widget _buildTipItem(String tip, DSColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: context.bodyMedium.copyWith(color: colors.textSecondary),
          ),
          Expanded(
            child: Text(
              tip,
              style: context.bodyMedium.copyWith(
                color: colors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionsContent(DSColorScheme colors) {
    final data = _fortuneResult.data;
    final predictions = data['predictions'] as Map<String, dynamic>? ?? {};

    final thisWeek = FortuneTextCleaner.clean(predictions['thisWeek'] as String? ?? '');
    final thisMonth = FortuneTextCleaner.clean(predictions['thisMonth'] as String? ?? '');
    final nextThreeMonths = FortuneTextCleaner.clean(predictions['nextThreeMonths'] as String? ?? '');
    final keyDates = List<String>.from(predictions['keyDates'] ?? [])
        .map((d) => FortuneTextCleaner.clean(d.toString()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPredictionItem(
          '📅',
          '이번 주',
          thisWeek.isNotEmpty ? thisWeek : '새로운 만남의 기회가 있을 수 있습니다.',
          colors,
        ),
        const SizedBox(height: 12),
        _buildPredictionItem(
          '📆',
          '이번 달',
          thisMonth.isNotEmpty ? thisMonth : '연애운이 상승하는 시기입니다.',
          colors,
        ),
        const SizedBox(height: 12),
        _buildPredictionItem(
          '🔮',
          '앞으로 3개월',
          nextThreeMonths.isNotEmpty ? nextThreeMonths : '좋은 인연을 만날 가능성이 높습니다.',
          colors,
        ),
        if (keyDates.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            '📌 주목할 날짜',
            style: context.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: keyDates.map((date) => _buildDateChip(date, colors)).toList(),
          ),
        ],
      ],
    );
  }

  /// 미래 예측 항목 위젯
  Widget _buildPredictionItem(String emoji, String label, String content, DSColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$emoji $label',
          style: context.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: context.bodyMedium.copyWith(
            color: colors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  /// 중요 날짜 칩 위젯
  Widget _buildDateChip(String date, DSColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.accent.withValues(alpha: 0.3)),
      ),
      child: Text(
        date,
        style: context.labelMedium.copyWith(
          color: colors.accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionPlanContent(DSColorScheme colors) {
    final data = _fortuneResult.data;
    final actionPlan = data['actionPlan'] as Map<String, dynamic>? ?? {};

    final immediate = List<String>.from(actionPlan['immediate'] ?? []).map((i) => FortuneTextCleaner.clean(i.toString())).toList();
    final shortTerm = List<String>.from(actionPlan['shortTerm'] ?? []).map((s) => FortuneTextCleaner.clean(s.toString())).toList();
    final longTerm = List<String>.from(actionPlan['longTerm'] ?? []).map((l) => FortuneTextCleaner.clean(l.toString())).toList();

    final content = '''
⚡ 즉시 실천:
${immediate.isNotEmpty ? '• ${immediate.join('\n• ')}' : '자신의 감정을 정리해보세요.'}

📆 단기 계획:
${shortTerm.isNotEmpty ? '• ${shortTerm.join('\n• ')}' : '상대방과의 소통을 늘려보세요.'}

🎯 장기 계획:
${longTerm.isNotEmpty ? '• ${longTerm.join('\n• ')}' : '서로의 미래를 함께 그려보세요.'}
''';

    return Text(
      content,
      style: context.bodyMedium.copyWith(
        color: colors.textSecondary,
        height: 1.6,
      ),
    );
  }

  Widget _buildWarningContent(DSColorScheme colors) {
    final data = _fortuneResult.data;
    final todaysAdvice = data['todaysAdvice'] as Map<String, dynamic>? ?? {};
    final warningArea = FortuneTextCleaner.clean(todaysAdvice['warningArea'] as String? ?? '과도한 기대는 실망으로 이어질 수 있으니 주의하세요.');

    return Text(
      warningArea,
      style: context.bodySmall.copyWith(
        color: colors.textSecondary,
        height: 1.6,
      ),
    );
  }

  // ===== 공통 빌더 =====

  Widget _buildDetailSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
    Color color,
    DSColorScheme colors,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: context.heading3.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: context.bodyMedium.copyWith(
              color: colors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    ).animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .slideX(begin: -0.1, end: 0);
  }

  // ===== 추천 섹션 빌더 (NEW) =====

  /// 추천 장소 섹션 (메인 장소만 공개, 대안은 블러)
  Widget _buildDateSpotSection(DSColorScheme colors) {
    final data = _fortuneResult.data;
    final recommendations = data['recommendations'] as Map<String, dynamic>? ?? {};
    final dateSpots = recommendations['dateSpots'] as Map<String, dynamic>? ?? {};

    final primary = FortuneTextCleaner.clean(
      dateSpots['primary'] as String? ?? '분위기 좋은 카페에서 깊은 대화를 나눠보세요'
    );
    final alternatives = List<String>.from(dateSpots['alternatives'] ?? [])
        .map((a) => FortuneTextCleaner.clean(a.toString()))
        .toList();
    final reason = FortuneTextCleaner.clean(
      dateSpots['reason'] as String? ?? '차분한 분위기에서 서로를 알아가기 좋아요'
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.place_rounded, color: Color(0xFF4CAF50), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                '추천 데이트 장소',
                style: context.heading3.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 메인 추천 (공개)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  const Color(0xFF8BC34A).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFF4CAF50), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '베스트 픽',
                      style: context.labelMedium.copyWith(
                        color: const Color(0xFF4CAF50),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  primary,
                  style: context.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '💡 $reason',
                  style: context.bodySmall.copyWith(
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // 대안 장소 (블러)
          if (alternatives.isNotEmpty) ...[
            const SizedBox(height: 12),
            BlurredFortuneContent(
              fortuneResult: _fortuneResult,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📍 다른 추천 장소',
                    style: context.labelMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: alternatives.map((alt) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.border),
                      ),
                      child: Text(
                        alt,
                        style: context.labelMedium.copyWith(color: colors.textSecondary),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .slideX(begin: -0.1, end: 0);
  }

  /// 패션 스타일 추천 콘텐츠
  Widget _buildFashionContent(DSColorScheme colors) {
    final data = _fortuneResult.data;
    final recommendations = data['recommendations'] as Map<String, dynamic>? ?? {};
    final fashion = recommendations['fashion'] as Map<String, dynamic>? ?? {};

    final style = fashion['style'] as String? ?? '캐주얼 시크';
    final colorsList = List<String>.from(fashion['colors'] ?? ['베이지', '화이트', '네이비']);
    final items = List<String>.from(fashion['items'] ?? ['깔끔한 니트', '슬랙스', '화이트 스니커즈']);
    final reason = FortuneTextCleaner.clean(fashion['reason'] as String? ?? '첫인상에서 신뢰감을 줄 수 있어요');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 스타일 배지
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6B5CE7), Color(0xFF9B8CF7)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '👔 $style',
            style: context.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 추천 색상
        Text(
          '🎨 추천 색상',
          style: context.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colorsList.map((color) => _buildColorChip(color, colors)).toList(),
        ),
        const SizedBox(height: 16),

        // 추천 아이템
        Text(
          '👕 추천 아이템',
          style: context.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF6B5CE7), size: 16),
              const SizedBox(width: 8),
              Text(
                item,
                style: context.bodyMedium.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        )),
        const SizedBox(height: 12),

        // 추천 이유
        Text(
          '💡 $reason',
          style: context.bodySmall.copyWith(
            color: colors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  /// 색상 칩 위젯
  Widget _buildColorChip(String colorName, DSColorScheme colors) {
    // 색상 이름에서 실제 색상 매핑
    final colorMap = {
      '베이지': const Color(0xFFF5DEB3),
      '화이트': Colors.white,
      '네이비': const Color(0xFF1E3A5F),
      '블랙': Colors.black,
      '그레이': Colors.grey,
      '브라운': const Color(0xFF8B4513),
      '핑크': const Color(0xFFFFB6C1),
      '블루': Colors.blue,
      '그린': Colors.green,
    };

    final chipColor = colorMap[colorName] ?? colors.accent;
    final isDark = chipColor.computeLuminance() < 0.5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: chipColor.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        colorName,
        style: context.labelMedium.copyWith(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 악세서리 추천 콘텐츠
  Widget _buildAccessoriesContent(DSColorScheme colors) {
    final data = _fortuneResult.data;
    final recommendations = data['recommendations'] as Map<String, dynamic>? ?? {};
    final accessories = recommendations['accessories'] as Map<String, dynamic>? ?? {};

    final recommended = List<String>.from(accessories['recommended'] ?? ['미니멀 시계', '실버 반지', '가죽 백']);
    final avoid = List<String>.from(accessories['avoid'] ?? ['과한 금장식']);
    final reason = FortuneTextCleaner.clean(accessories['reason'] as String? ?? '센스있고 세련된 이미지 연출');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '✨ 추천 악세서리',
          style: context.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recommended.map((item) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE67E22).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE67E22).withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check, color: Color(0xFFE67E22), size: 14),
                const SizedBox(width: 4),
                Text(
                  item,
                  style: context.labelMedium.copyWith(color: const Color(0xFFE67E22)),
                ),
              ],
            ),
          )).toList(),
        ),
        const SizedBox(height: 16),

        // 피해야 할 악세서리
        if (avoid.isNotEmpty) ...[
          Text(
            '⚠️ 피할 것',
            style: context.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...avoid.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.close, color: DSColors.error, size: 14),
                const SizedBox(width: 6),
                Text(
                  item,
                  style: context.bodySmall.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          )),
          const SizedBox(height: 12),
        ],

        Text(
          '💡 $reason',
          style: context.bodySmall.copyWith(
            color: colors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  /// 향수 추천 콘텐츠
  Widget _buildFragranceContent(DSColorScheme colors) {
    final data = _fortuneResult.data;
    final recommendations = data['recommendations'] as Map<String, dynamic>? ?? {};
    final fragrance = recommendations['fragrance'] as Map<String, dynamic>? ?? {};

    final notes = List<String>.from(fragrance['notes'] ?? ['우디', '머스크']);
    final mood = fragrance['mood'] as String? ?? '차분하면서 깊이있는';
    final timing = fragrance['timing'] as String? ?? '저녁 데이트에 특히 어울려요';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 향 노트
        Text(
          '🌸 추천 향 노트',
          style: context.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: notes.map((note) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFE91E63).withValues(alpha: 0.1),
                  const Color(0xFFF48FB1).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE91E63).withValues(alpha: 0.3)),
            ),
            child: Text(
              note,
              style: context.labelMedium.copyWith(
                color: const Color(0xFFE91E63),
                fontWeight: FontWeight.w600,
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 16),

        // 무드
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('✨', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '분위기',
                    style: context.labelSmall.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    mood,
                    style: context.bodyMedium.copyWith(color: colors.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 타이밍
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('⏰', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '추천 상황',
                    style: context.labelSmall.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    timing,
                    style: context.bodyMedium.copyWith(color: colors.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 대화 팁 콘텐츠
  Widget _buildConversationContent(DSColorScheme colors) {
    final data = _fortuneResult.data;
    final recommendations = data['recommendations'] as Map<String, dynamic>? ?? {};
    final conversation = recommendations['conversation'] as Map<String, dynamic>? ?? {};

    final topics = List<String>.from(conversation['topics'] ?? ['여행 이야기', '취미 공유', '미래 꿈']);
    final avoid = List<String>.from(conversation['avoid'] ?? ['전 애인 이야기', '급한 결혼 언급']);
    final tip = FortuneTextCleaner.clean(conversation['tip'] as String? ?? '상대방 이야기를 먼저 들어주세요');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 추천 대화 주제
        Text(
          '💬 추천 대화 주제',
          style: context.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...topics.map((topic) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              const Icon(Icons.chat_bubble, color: Color(0xFF00BCD4), size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  topic,
                  style: context.bodyMedium.copyWith(color: colors.textSecondary),
                ),
              ),
            ],
          ),
        )),
        const SizedBox(height: 16),

        // 피해야 할 주제
        if (avoid.isNotEmpty) ...[
          Text(
            '🚫 피할 주제',
            style: context.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...avoid.map((topic) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.remove_circle_outline, color: DSColors.error, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    topic,
                    style: context.bodySmall.copyWith(color: colors.textSecondary),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 12),
        ],

        // 대화 팁
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF00BCD4).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF00BCD4).withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tip,
                  style: context.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===== 광고 & 블러 해제 =====

  // ✅ RewardedAd 패턴으로 교체
  Future<void> _showAdAndUnblur() async {
    debugPrint('[연애운] 광고 시청 후 블러 해제 시작');

    try {
      final adService = AdService.instance;

      // 광고가 준비 안됐으면 로드
      if (!adService.isRewardedAdReady) {
        debugPrint('[연애운] ⏳ RewardedAd 로드 중...');
        await adService.loadRewardedAd();

        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

        if (!adService.isRewardedAdReady) {
          debugPrint('[연애운] ❌ RewardedAd 로드 타임아웃');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('광고를 불러올 수 없습니다. 잠시 후 다시 시도해주세요.'),
                backgroundColor: DSColors.error,
              ),
            );
          }
          return;
        }
      }

      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) async {
          debugPrint('[연애운] ✅ 광고 시청 완료, 블러 해제');

          // ✅ 블러 해제 햅틱 (5단계 상승 패턴)
          await ref.read(fortuneHapticServiceProvider).premiumUnlock();

          // NEW: 게이지 증가 호출
          if (mounted) {
            FortuneCompletionHelper.onFortuneViewed(context, ref, 'love');
          }

          if (mounted) {
            setState(() {
              _fortuneResult = _fortuneResult.copyWith(
                isBlurred: false,
                blurredSections: [],
              );
            });
            // 구독 유도 스낵바 표시 (구독자가 아닌 경우만)
            final tokenState = ref.read(tokenProvider);
            SubscriptionSnackbar.showAfterAd(
              context,
              hasUnlimitedAccess: tokenState.hasUnlimitedAccess,
            );
          }
        },
      );
    } catch (e, stackTrace) {
      Logger.error('[연애운] 광고 표시 실패', e, stackTrace);

      // UX 개선: 에러 발생해도 블러 해제
      if (mounted) {
        setState(() {
          _fortuneResult = _fortuneResult.copyWith(
            isBlurred: false,
            blurredSections: [],
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('광고 표시 중 오류가 발생했지만, 콘텐츠를 확인하실 수 있습니다.'),
            backgroundColor: DSColors.warning,
          ),
        );
      }
    }
  }
}
