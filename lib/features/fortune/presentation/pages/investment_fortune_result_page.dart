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
import '../../../../core/utils/subscription_snackbar.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../core/widgets/gpt_style_typing_text.dart';

/// 투자운세 결과 페이지 v2 (리서치 기반 새 구조)
///
/// **무료 공개**:
/// - 메인 점수, 종목 정보, 요약, 행운 아이템
///
/// **프리미엄 (블러)**:
/// - timing: 타이밍 운세
/// - outlook: 전망 운세
/// - risks: 리스크 경고
/// - marketMood: 시장 기운
/// - advice, psychologyTip: 투자 조언
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
  int _currentTypingSection = 0;

  @override
  void initState() {
    super.initState();
    _fortuneResult = widget.fortuneResult;
    Logger.info('[투자운 v2] 결과 페이지 초기화 - isBlurred: ${_fortuneResult.isBlurred}');
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
                  // 1. 메인 점수 (공개)
                  _buildMainScoreCard(),
                  const SizedBox(height: 24),

                  // 2. 종목 정보 (공개)
                  _buildTickerInfoSection(),
                  const SizedBox(height: 16),

                  // 3. 요약 (공개)
                  _buildContentSection(),

                  // 4. 행운 아이템 (공개)
                  _buildLuckyItemsSection(),

                  // 5. 타이밍 운세 (블러) - NEW
                  _buildTimingSection(),

                  // 6. 전망 운세 (블러) - NEW
                  _buildOutlookSection(),

                  // 7. 리스크 경고 (블러) - NEW
                  _buildRisksSection(),

                  // 8. 시장 기운 (블러) - NEW
                  _buildMarketMoodSection(),

                  // 9. 투자 조언 (블러)
                  _buildAdviceSection(),

                  const SizedBox(height: 80),
                ],
              ),
            ),

            // Floating Button
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

  // ===== 공개 섹션 =====

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
          const Icon(Icons.trending_up_rounded, color: TossDesignSystem.white, size: 48),
          const SizedBox(height: 16),
          Text(
            '투자 운세 점수',
            style: context.bodyMedium.copyWith(color: TossDesignSystem.white.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 8),
          Text(
            '$score점',
            style: context.displayLarge.copyWith(color: TossDesignSystem.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(_getScoreEmoji(score), style: context.bodyLarge.copyWith(color: TossDesignSystem.white)),
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
                style: context.bodySmall.copyWith(color: TossDesignSystem.white, fontWeight: FontWeight.w600),
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
    final tickerName = ticker['name'] as String? ?? '종목';
    final tickerSymbol = ticker['symbol'] as String? ?? '';
    final category = ticker['category'] as String? ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: TossDesignSystem.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                tickerSymbol.isNotEmpty ? tickerSymbol.substring(0, tickerSymbol.length > 2 ? 2 : tickerSymbol.length) : '📈',
                style: context.heading4.copyWith(color: TossDesignSystem.primaryBlue),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tickerName, style: context.heading4.copyWith(color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack)),
                const SizedBox(height: 4),
                Text('${_getCategoryLabel(category)} • $tickerSymbol', style: context.bodySmall.copyWith(color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildContentSection() {
    final data = _fortuneResult.data;
    final content = FortuneTextCleaner.clean(data['content'] as String? ?? '투자 분석 결과입니다.');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildSectionCard(
      title: '투자 요약',
      icon: Icons.summarize_rounded,
      color: TossDesignSystem.primaryBlue,
      child: GptStyleTypingText(
        text: content,
        style: context.bodyMedium.copyWith(
          color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
          height: 1.6,
        ),
        startTyping: _currentTypingSection >= 0,
        showGhostText: true,
        onComplete: () {
          if (mounted) setState(() => _currentTypingSection = 1);
        },
      ),
    );
  }

  Widget _buildLuckyItemsSection() {
    final data = _fortuneResult.data;
    final luckyItems = data['luckyItems'] as Map<String, dynamic>? ?? data['lucky_items'] as Map<String, dynamic>? ?? {};
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (luckyItems.isEmpty) return const SizedBox.shrink();

    return _buildSectionCard(
      title: '행운 요소',
      icon: Icons.auto_awesome_rounded,
      color: const Color(0xFFFFB300),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (luckyItems['color'] != null) _buildLuckyChip('🎨', '색상', luckyItems['color'].toString(), isDark),
          if (luckyItems['number'] != null) _buildLuckyChip('🔢', '숫자', luckyItems['number'].toString(), isDark),
          if (luckyItems['direction'] != null) _buildLuckyChip('🧭', '방향', luckyItems['direction'].toString(), isDark),
          if (luckyItems['timing'] != null) _buildLuckyChip('⏰', '시간', luckyItems['timing'].toString(), isDark),
        ],
      ),
    );
  }

  Widget _buildLuckyChip(String emoji, String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB300).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(value, style: context.bodySmall.copyWith(fontWeight: FontWeight.w600, color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack)),
        ],
      ),
    );
  }

  // ===== 프리미엄 섹션 (블러) =====

  Widget _buildTimingSection() {
    final data = _fortuneResult.data;
    final timing = data['timing'] as Map<String, dynamic>? ?? {};
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildBlurredSectionCard(
      title: '🎯 타이밍 운세',
      icon: Icons.access_time_rounded,
      color: const Color(0xFF00BCD4),
      sectionKey: 'timing',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 매수 시그널
          _buildSignalBadge(timing['buySignal'] as String? ?? 'moderate', isDark),
          const SizedBox(height: 12),
          Text(
            timing['buySignalText'] as String? ?? '매수 타이밍을 분석 중입니다.',
            style: context.bodyMedium.copyWith(color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600, height: 1.5),
          ),
          const SizedBox(height: 16),

          // 최적 시간대
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 18, color: Color(0xFF00BCD4)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '최적 시간: ${timing['bestTimeSlotText'] ?? '오후 시간대'}',
                  style: context.bodySmall.copyWith(color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 홀딩 조언
          Row(
            children: [
              const Icon(Icons.pause_circle_outline_rounded, size: 18, color: Color(0xFF00BCD4)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  timing['holdAdvice'] as String? ?? '상황을 지켜보세요.',
                  style: context.bodySmall.copyWith(color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignalBadge(String signal, bool isDark) {
    final config = {
      'strong': {'label': '매수 추천', 'color': const Color(0xFF4CAF50), 'icon': Icons.arrow_upward_rounded},
      'moderate': {'label': '관망 추천', 'color': const Color(0xFF2196F3), 'icon': Icons.remove_rounded},
      'weak': {'label': '신중히', 'color': const Color(0xFFFF9800), 'icon': Icons.priority_high_rounded},
      'avoid': {'label': '매수 자제', 'color': const Color(0xFFF44336), 'icon': Icons.close_rounded},
    };
    final c = config[signal] ?? config['moderate']!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: (c['color'] as Color).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(c['icon'] as IconData, color: c['color'] as Color, size: 20),
          const SizedBox(width: 8),
          Text(c['label'] as String, style: context.bodyMedium.copyWith(color: c['color'] as Color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildOutlookSection() {
    final data = _fortuneResult.data;
    final outlook = data['outlook'] as Map<String, dynamic>? ?? {};
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildBlurredSectionCard(
      title: '📈 전망 운세',
      icon: Icons.trending_up_rounded,
      color: const Color(0xFF9C27B0),
      sectionKey: 'outlook',
      child: Column(
        children: [
          _buildOutlookRow('1주일', outlook['shortTerm'] as Map<String, dynamic>? ?? {}, isDark),
          const SizedBox(height: 12),
          _buildOutlookRow('1개월', outlook['midTerm'] as Map<String, dynamic>? ?? {}, isDark),
          const SizedBox(height: 12),
          _buildOutlookRow('3개월+', outlook['longTerm'] as Map<String, dynamic>? ?? {}, isDark),
        ],
      ),
    );
  }

  Widget _buildOutlookRow(String label, Map<String, dynamic> data, bool isDark) {
    final score = (data['score'] as num?)?.toInt() ?? 50;
    final trend = data['trend'] as String? ?? 'neutral';
    final text = data['text'] as String? ?? '분석 중...';

    final trendIcon = trend == 'up' ? Icons.arrow_upward_rounded : (trend == 'down' ? Icons.arrow_downward_rounded : Icons.remove_rounded);
    final trendColor = trend == 'up' ? const Color(0xFF4CAF50) : (trend == 'down' ? const Color(0xFFF44336) : const Color(0xFF9E9E9E));

    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label, style: context.bodySmall.copyWith(color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600, fontWeight: FontWeight.w600)),
        ),
        Icon(trendIcon, size: 18, color: trendColor),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: trendColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Text('$score점', style: context.bodySmall.copyWith(color: trendColor, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: context.bodySmall.copyWith(color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600), overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildRisksSection() {
    final data = _fortuneResult.data;
    final risks = data['risks'] as Map<String, dynamic>? ?? {};
    final warnings = risks['warnings'] as List? ?? [];
    final avoidActions = risks['avoidActions'] as List? ?? [];
    final volatilityLevel = risks['volatilityLevel'] as String? ?? 'medium';
    final volatilityText = risks['volatilityText'] as String? ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildBlurredSectionCard(
      title: '⚠️ 리스크 경고',
      icon: Icons.warning_rounded,
      color: const Color(0xFFF44336),
      sectionKey: 'risks',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 변동성 수준
          _buildVolatilityBadge(volatilityLevel, volatilityText, isDark),
          const SizedBox(height: 16),

          // 주의사항
          if (warnings.isNotEmpty) ...[
            Text('주의사항', style: context.bodySmall.copyWith(color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...warnings.map((w) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Color(0xFFF44336))),
                  Expanded(child: Text(w.toString(), style: context.bodySmall.copyWith(color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600, height: 1.4))),
                ],
              ),
            )),
          ],

          // 피해야 할 행동
          if (avoidActions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('피해야 할 행동', style: context.bodySmall.copyWith(color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...avoidActions.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('❌ '),
                  Expanded(child: Text(a.toString(), style: context.bodySmall.copyWith(color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600, height: 1.4))),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildVolatilityBadge(String level, String text, bool isDark) {
    final config = {
      'low': {'label': '낮음', 'color': const Color(0xFF4CAF50)},
      'medium': {'label': '보통', 'color': const Color(0xFFFF9800)},
      'high': {'label': '높음', 'color': const Color(0xFFF44336)},
      'extreme': {'label': '매우 높음', 'color': const Color(0xFF9C27B0)},
    };
    final c = config[level] ?? config['medium']!;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: (c['color'] as Color).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.show_chart_rounded, size: 16, color: Color(0xFFF44336)),
              const SizedBox(width: 6),
              Text('변동성 ${c['label']}', style: context.bodySmall.copyWith(color: c['color'] as Color, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        if (text.isNotEmpty) ...[
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: context.bodySmall.copyWith(color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600))),
        ],
      ],
    );
  }

  Widget _buildMarketMoodSection() {
    final data = _fortuneResult.data;
    final marketMood = data['marketMood'] as Map<String, dynamic>? ?? {};
    final categoryMood = marketMood['categoryMood'] as String? ?? 'neutral';
    final categoryMoodText = marketMood['categoryMoodText'] as String? ?? '';
    final investorSentiment = marketMood['investorSentiment'] as String? ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildBlurredSectionCard(
      title: '🌊 시장 기운',
      icon: Icons.waves_rounded,
      color: const Color(0xFF3F51B5),
      sectionKey: 'marketMood',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMoodBadge(categoryMood),
          const SizedBox(height: 12),
          if (categoryMoodText.isNotEmpty)
            Text(categoryMoodText, style: context.bodyMedium.copyWith(color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600, height: 1.5)),
          if (investorSentiment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.people_outline_rounded, size: 18, color: Color(0xFF3F51B5)),
                const SizedBox(width: 8),
                Expanded(child: Text(investorSentiment, style: context.bodySmall.copyWith(color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMoodBadge(String mood) {
    final config = {
      'bullish': {'label': '📈 상승 기운', 'color': const Color(0xFF4CAF50)},
      'neutral': {'label': '➡️ 보합 기운', 'color': const Color(0xFF9E9E9E)},
      'bearish': {'label': '📉 하락 기운', 'color': const Color(0xFFF44336)},
    };
    final c = config[mood] ?? config['neutral']!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: (c['color'] as Color).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
      child: Text(c['label'] as String, style: context.bodyMedium.copyWith(color: c['color'] as Color, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildAdviceSection() {
    final data = _fortuneResult.data;
    final advice = data['advice'] as String? ?? '';
    final psychologyTip = data['psychologyTip'] as String? ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (advice.isEmpty && psychologyTip.isEmpty) return const SizedBox.shrink();

    return _buildBlurredSectionCard(
      title: '💡 투자 조언',
      icon: Icons.lightbulb_rounded,
      color: const Color(0xFF4CAF50),
      sectionKey: 'advice',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (advice.isNotEmpty) ...[
            Text(FortuneTextCleaner.clean(advice), style: context.bodyMedium.copyWith(color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600, height: 1.6)),
          ],
          if (psychologyTip.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF9C27B0).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.psychology_rounded, size: 20, color: Color(0xFF9C27B0)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(FortuneTextCleaner.clean(psychologyTip), style: context.bodySmall.copyWith(color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ===== 공통 빌더 =====

  Widget _buildSectionCard({required String title, required IconData icon, required Color color, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Text(title, style: context.heading4.copyWith(color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildBlurredSectionCard({required String title, required IconData icon, required Color color, required String sectionKey, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Text(title, style: context.heading4.copyWith(color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack)),
            ],
          ),
          const SizedBox(height: 16),
          UnifiedBlurWrapper(
            isBlurred: _fortuneResult.isBlurred,
            blurredSections: _fortuneResult.blurredSections,
            sectionKey: sectionKey,
            child: ConstrainedBox(constraints: const BoxConstraints(minHeight: 60), child: child),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  // ===== 헬퍼 =====

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
    return {'crypto': '암호화폐', 'krStock': '국내주식', 'usStock': '해외주식', 'etf': 'ETF', 'commodity': '원자재', 'realEstate': '부동산'}[category] ?? category;
  }

  // ===== 광고 =====

  Future<void> _showAdAndUnblur() async {
    Logger.info('[투자운 v2] 광고 시청 시작');

    try {
      final adService = AdService.instance;

      if (!adService.isRewardedAdReady) {
        await adService.loadRewardedAd();
        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

        if (!adService.isRewardedAdReady) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('광고를 불러올 수 없습니다. 잠시 후 다시 시도해주세요.'), backgroundColor: TossDesignSystem.errorRed),
            );
          }
          return;
        }
      }

      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) {
          Logger.info('[투자운 v2] ✅ 광고 시청 완료, 블러 해제');
          if (mounted) {
            setState(() {
              _fortuneResult = _fortuneResult.copyWith(isBlurred: false, blurredSections: []);
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
      Logger.error('[투자운 v2] 광고 표시 실패', e, stackTrace);
      if (mounted) {
        setState(() {
          _fortuneResult = _fortuneResult.copyWith(isBlurred: false, blurredSections: []);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('광고 표시 중 오류가 발생했지만, 콘텐츠를 확인하실 수 있습니다.'), backgroundColor: TossDesignSystem.warningOrange),
        );
      }
    }
  }
}
