import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/fortune_result.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/utils/fortune_text_cleaner.dart';
import '../../../../services/ad_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../core/widgets/gpt_style_typing_text.dart';

/// 투자운세 결과 페이지 (프리미엄/블러 시스템 적용)
///
/// **블러 섹션** (4개):
/// - description: 상세 분석
/// - recommendations: 추천사항
/// - warnings: 주의사항
/// - detailed_analysis: 심층 분석
///
/// **Floating Button**: "투자 분석 모두 보기"
class InvestmentFortuneResultPage extends ConsumerStatefulWidget {
  final FortuneResult fortuneResult;

  const InvestmentFortuneResultPage({
    super.key,
    required this.fortuneResult,
  });

  @override
  ConsumerState<InvestmentFortuneResultPage> createState() => _InvestmentFortuneResultPageState();
}

class _InvestmentFortuneResultPageState extends ConsumerState<InvestmentFortuneResultPage> {
  late FortuneResult _fortuneResult;

  // 타이핑 효과 상태
  int _currentTypingSection = 0;

  @override
  void initState() {
    super.initState();
    _fortuneResult = widget.fortuneResult;
    Logger.info('[투자운] 결과 페이지 초기화 - isBlurred: ${_fortuneResult.isBlurred}');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossTheme.backgroundPrimary,
        appBar: AppBar(
          backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossTheme.backgroundPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            '투자 운세 결과',
            style: context.heading3.copyWith(
              color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.close,
                color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
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
                  _buildMainScoreCard(),
                  const SizedBox(height: 24),

                  // 2. 종목 정보 (공개)
                  _buildTickerInfoSection(),
                  const SizedBox(height: 16),

                  // 3. 투자 요약 (공개)
                  _buildContentSection(),

                  // 4. 행운 아이템 (블러)
                  _buildBlurredSection(
                    title: '행운 아이템',
                    icon: Icons.auto_awesome_rounded,
                    color: const Color(0xFFFFB300),
                    contentBuilder: () => _buildLuckyItemsContent(),
                    sectionKey: 'lucky_items',
                  ),

                  // 5. 상세 분석 (블러)
                  _buildBlurredSection(
                    title: '상세 분석',
                    icon: Icons.analytics_rounded,
                    color: const Color(0xFF2196F3),
                    contentBuilder: () => _buildDescriptionContent(),
                    sectionKey: 'description',
                  ),

                  // 6. 추천사항 (블러)
                  _buildBlurredSection(
                    title: '추천사항',
                    icon: Icons.lightbulb_rounded,
                    color: const Color(0xFF4CAF50),
                    contentBuilder: () => _buildRecommendationsContent(),
                    sectionKey: 'recommendations',
                  ),

                  // 7. 주의사항 (블러)
                  _buildBlurredSection(
                    title: '⚠️ 주의사항',
                    icon: Icons.warning_rounded,
                    color: TossTheme.error,
                    contentBuilder: () => _buildWarningsContent(),
                    sectionKey: 'warnings',
                  ),

                  // 8. 육각형 점수 (블러)
                  _buildBlurredSection(
                    title: '투자 분석 차트',
                    icon: Icons.hexagon_rounded,
                    color: const Color(0xFF9C27B0),
                    contentBuilder: () => _buildHexagonScoresContent(),
                    sectionKey: 'detailed_analysis',
                  ),

                  const SizedBox(height: 80), // Floating Button 공간
                ],
              ),
            ),

            // Floating Button (프리미엄 사용자는 자동 숨김)
            if (_fortuneResult.isBlurred)
              UnifiedAdUnlockButton(
                onPressed: _showAdAndUnblur,
                customText: '📊 투자 분석 모두 보기',
              ),
          ],
        ),
      ),
    );
  }

  // ===== 공개 섹션 빌더 =====

  Widget _buildMainScoreCard() {
    final data = _fortuneResult.data;
    final score = data['overallScore'] as int? ?? data['overall_score'] as int? ?? 50;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getScoreGradient(score),
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getScoreColor(score).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.trending_up_rounded,
            color: TossDesignSystem.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            '투자 운세 점수',
            style: context.bodyMedium.copyWith(
              color: TossDesignSystem.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$score점',
            style: context.displayLarge.copyWith(
              color: TossDesignSystem.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getScoreEmoji(score),
            style: context.bodyLarge.copyWith(
              color: TossDesignSystem.white,
            ),
          ),
          if (_fortuneResult.percentile != null && _fortuneResult.isPercentileValid) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: TossDesignSystem.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '상위 ${_fortuneResult.percentile}%',
                style: context.bodySmall.copyWith(
                  color: TossDesignSystem.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildTickerInfoSection() {
    final data = _fortuneResult.data;
    final ticker = data['ticker'] as Map<String, dynamic>? ?? {};
    final tickerName = ticker['name'] as String? ?? data['targetName'] as String? ?? '종목';
    final tickerSymbol = ticker['symbol'] as String? ?? '';
    final category = ticker['category'] as String? ?? data['investmentType'] as String? ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: TossDesignSystem.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                tickerSymbol.isNotEmpty ? tickerSymbol.substring(0, tickerSymbol.length > 2 ? 2 : tickerSymbol.length) : '📈',
                style: context.heading4.copyWith(
                  color: TossDesignSystem.primaryBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tickerName,
                  style: context.heading4.copyWith(
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_getCategoryLabel(category)} • $tickerSymbol',
                  style: context.bodySmall.copyWith(
                    color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildContentSection() {
    final data = _fortuneResult.data;
    final contentRaw = data['content'];
    final content = FortuneTextCleaner.clean(
      contentRaw is String ? contentRaw : '투자 분석 결과입니다.',
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200,
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
                  color: TossDesignSystem.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.summarize_rounded,
                  color: TossDesignSystem.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '투자 요약',
                style: context.heading4.copyWith(
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GptStyleTypingText(
            text: content,
            style: context.bodyMedium.copyWith(
              color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
              height: 1.6,
            ),
            startTyping: _currentTypingSection >= 0,
            showGhostText: true,
            onComplete: () {
              if (mounted) {
                setState(() => _currentTypingSection = 1);
              }
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  // ===== 블러 섹션 빌더 =====

  Widget _buildBlurredSection({
    required String title,
    required IconData icon,
    required Color color,
    required Widget Function() contentBuilder,
    required String sectionKey,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200,
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
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: context.heading4.copyWith(
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          UnifiedBlurWrapper(
            isBlurred: _fortuneResult.isBlurred,
            blurredSections: _fortuneResult.blurredSections,
            sectionKey: sectionKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 80),
              child: contentBuilder(),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildLuckyItemsContent() {
    final data = _fortuneResult.data;
    final luckyItems = data['luckyItems'] as Map<String, dynamic>? ??
                       data['lucky_items'] as Map<String, dynamic>? ?? {};
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (luckyItems.isEmpty) {
      return Text(
        '행운 아이템 정보가 없습니다.',
        style: context.bodyMedium.copyWith(
          color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
        ),
      );
    }

    final items = <Widget>[];
    final iconMap = {
      'color': Icons.palette_rounded,
      'number': Icons.numbers_rounded,
      'direction': Icons.explore_rounded,
      'timing': Icons.schedule_rounded,
    };
    final labelMap = {
      'color': '행운의 색',
      'number': '행운의 숫자',
      'direction': '행운의 방향',
      'timing': '행운의 시간',
    };

    luckyItems.forEach((key, value) {
      if (value != null) {
        items.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB300).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  iconMap[key] ?? Icons.star_rounded,
                  color: const Color(0xFFFFB300),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      labelMap[key] ?? key,
                      style: context.bodySmall.copyWith(
                        color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                      ),
                    ),
                    Text(
                      value.toString(),
                      style: context.bodyMedium.copyWith(
                        color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    });

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items,
    );
  }

  Widget _buildDescriptionContent() {
    final data = _fortuneResult.data;
    final descriptionRaw = data['description'];
    final description = FortuneTextCleaner.clean(
      descriptionRaw is String ? descriptionRaw : '상세 분석 정보가 없습니다.',
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      description,
      style: context.bodyMedium.copyWith(
        color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
        height: 1.6,
      ),
    );
  }

  Widget _buildRecommendationsContent() {
    final data = _fortuneResult.data;
    final recommendations = data['recommendations'] as List? ??
                           data['advice'] as List? ??
                           ['분산 투자를 권장합니다.', '장기적 관점에서 접근하세요.'];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // String인 경우 처리
    if (data['recommendations'] is String || data['advice'] is String) {
      final text = (data['recommendations'] ?? data['advice']) as String;
      return Text(
        FortuneTextCleaner.clean(text),
        style: context.bodyMedium.copyWith(
          color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
          height: 1.6,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: recommendations.map((rec) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💡 '),
              Expanded(
                child: Text(
                  FortuneTextCleaner.clean(rec.toString()),
                  style: context.bodyMedium.copyWith(
                    color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWarningsContent() {
    final data = _fortuneResult.data;
    final warnings = data['warnings'] as List? ??
                    ['투자에는 항상 위험이 따릅니다.', '본 결과는 참고용이며 투자 결정은 본인의 판단에 따라야 합니다.'];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // String인 경우 처리
    if (data['warnings'] is String) {
      return Text(
        FortuneTextCleaner.clean(data['warnings'] as String),
        style: context.bodyMedium.copyWith(
          color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
          height: 1.6,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: warnings.map((warning) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('⚠️ '),
              Expanded(
                child: Text(
                  FortuneTextCleaner.clean(warning.toString()),
                  style: context.bodyMedium.copyWith(
                    color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHexagonScoresContent() {
    final data = _fortuneResult.data;
    final hexagonScores = data['hexagonScores'] as Map<String, dynamic>? ??
                         data['hexagon_scores'] as Map<String, dynamic>? ?? {};
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (hexagonScores.isEmpty) {
      return Text(
        '분석 차트 정보가 없습니다.',
        style: context.bodyMedium.copyWith(
          color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
        ),
      );
    }

    final labelMap = {
      'timing': '타이밍',
      'value': '가치',
      'risk': '리스크',
      'trend': '트렌드',
      'emotion': '심리',
      'knowledge': '정보력',
    };

    return Column(
      children: hexagonScores.entries.map((entry) {
        final score = (entry.value as num?)?.toDouble() ?? 0.0;
        final normalizedScore = score > 100 ? score / 100 : score;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 70,
                child: Text(
                  labelMap[entry.key] ?? entry.key,
                  style: context.bodySmall.copyWith(
                    color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: normalizedScore / 100,
                    backgroundColor: isDark
                        ? TossDesignSystem.borderDark
                        : TossTheme.borderGray200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(normalizedScore),
                    ),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 40,
                child: Text(
                  '${normalizedScore.toInt()}',
                  style: context.bodySmall.copyWith(
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ===== 헬퍼 메서드 =====

  List<Color> _getScoreGradient(int score) {
    if (score >= 80) return [const Color(0xFF4CAF50), const Color(0xFF81C784)];
    if (score >= 60) return [const Color(0xFF2196F3), const Color(0xFF64B5F6)];
    if (score >= 40) return [const Color(0xFFFF9800), const Color(0xFFFFB74D)];
    return [const Color(0xFFF44336), const Color(0xFFE57373)];
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF4CAF50);
    if (score >= 60) return const Color(0xFF2196F3);
    if (score >= 40) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  String _getScoreEmoji(int score) {
    if (score >= 80) return '🚀 매우 좋음';
    if (score >= 60) return '📈 좋음';
    if (score >= 40) return '📊 보통';
    return '📉 주의 필요';
  }

  String _getCategoryLabel(String category) {
    final labelMap = {
      'crypto': '암호화폐',
      'krStock': '국내주식',
      'usStock': '해외주식',
      'etf': 'ETF',
      'commodity': '원자재',
      'realEstate': '부동산',
    };
    return labelMap[category] ?? category;
  }

  Color _getProgressColor(double score) {
    if (score >= 80) return const Color(0xFF4CAF50);
    if (score >= 60) return const Color(0xFF2196F3);
    if (score >= 40) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  // ===== 광고 & 블러 해제 =====

  Future<void> _showAdAndUnblur() async {
    Logger.info('[투자운] 광고 시청 시작');

    try {
      final adService = AdService.instance;

      // RewardedAd 로딩 확인 (최대 5초 대기)
      if (!adService.isRewardedAdReady) {
        Logger.info('[투자운] RewardedAd 로딩 시작');
        await adService.loadRewardedAd();

        // 최대 5초 대기 (500ms × 10회 폴링)
        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

        if (!adService.isRewardedAdReady) {
          Logger.warning('[투자운] ❌ RewardedAd 로드 타임아웃');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('광고를 불러올 수 없습니다. 잠시 후 다시 시도해주세요.'),
                backgroundColor: TossDesignSystem.errorRed,
              ),
            );
          }
          return;
        }
      }

      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) {
          Logger.info('[투자운] ✅ 광고 시청 완료, 블러 해제');
          if (mounted) {
            setState(() {
              _fortuneResult = _fortuneResult.copyWith(
                isBlurred: false,
                blurredSections: [],
              );
            });
          }
        },
      );
    } catch (e, stackTrace) {
      Logger.error('[투자운] 광고 표시 실패', e, stackTrace);

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
            backgroundColor: TossDesignSystem.warningOrange,
          ),
        );
      }
    }
  }
}
