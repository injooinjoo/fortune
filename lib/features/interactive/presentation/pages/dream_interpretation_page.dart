import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/fortune_result.dart';
import '../../../fortune/domain/models/conditions/dream_fortune_conditions.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/components/toast.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../core/widgets/blurred_fortune_content.dart';
import '../../../../core/services/debug_premium_service.dart';
import '../../../../core/utils/fortune_text_cleaner.dart';
import '../../../../core/widgets/floating_dream_bubbles.dart';
import '../../../../data/popular_dream_topics.dart';

/// 꿈 해몽 페이지 (UnifiedFortuneService 버전)
///
/// **개선 사항**:
/// - ✅ UnifiedFortuneService 사용 (72% API 비용 절감)
/// - ✅ BlurredFortuneContent 사용 (자동 블러/광고 처리)
/// - ✅ FortuneResult 모델 사용 (일관성)
class DreamInterpretationPage extends ConsumerStatefulWidget {
  const DreamInterpretationPage({super.key});

  @override
  ConsumerState<DreamInterpretationPage> createState() =>
      _DreamInterpretationPageState();
}

class _DreamInterpretationPageState
    extends ConsumerState<DreamInterpretationPage> {
  // ==================== State ====================

  // 운세 결과 관련 상태
  FortuneResult? _fortuneResult;
  bool _isLoading = false;
  bool _showResult = false;
  DreamTopic? _selectedTopic;

  // ==================== Build ====================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? TossDesignSystem.backgroundDark
          : TossDesignSystem.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark
            ? TossDesignSystem.backgroundDark
            : TossDesignSystem.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: !_showResult,
        leading: _showResult
            ? null
            : IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: isDark
                      ? TossDesignSystem.textPrimaryDark
                      : TossDesignSystem.textPrimaryLight,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
        title: Text(
          _showResult ? '꿈 해몽 결과' : '꿈 해몽',
          style: TypographyUnified.heading4.copyWith(
            color: isDark
                ? TossDesignSystem.textPrimaryDark
                : TossDesignSystem.textPrimaryLight,
          ),
        ),
        centerTitle: true,
        actions: _showResult
            ? [
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDark
                        ? TossDesignSystem.textPrimaryDark
                        : TossDesignSystem.textPrimaryLight,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ]
            : null,
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // 메인 콘텐츠
            if (_showResult && _fortuneResult != null)
              _buildResultView(_fortuneResult!)
            else if (_isLoading)
              _buildLoadingView()
            else
              _buildBubbleSelectionView(),

            // 결과 화면에서 다시하기 버튼
            if (_showResult && _fortuneResult != null)
              UnifiedButton.floating(
                text: '다른 꿈 해몽하기',
                onPressed: _resetForm,
              ),
          ],
        ),
      ),
    );
  }

  /// 버블 선택 화면
  Widget _buildBubbleSelectionView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // 플로팅 버블들
        FloatingDreamBubbles(
          onTopicSelected: _onTopicSelected,
          bubbleCount: 15,
        ),

        // 상단 안내 문구
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isDark
                      ? TossDesignSystem.surfaceBackgroundDark
                      : TossDesignSystem.white)
                  .withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '🌙 어떤 꿈을 꾸셨나요?',
                  style: TypographyUnified.heading4.copyWith(
                    color: isDark
                        ? TossDesignSystem.textPrimaryDark
                        : TossDesignSystem.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '꿈 버블을 터치하면 AI가 해몽해드려요',
                  style: TypographyUnified.bodySmall.copyWith(
                    color: isDark
                        ? TossDesignSystem.textSecondaryDark
                        : TossDesignSystem.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 로딩 화면
  Widget _buildLoadingView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 선택된 꿈 표시
          if (_selectedTopic != null) ...[
            Text(
              _selectedTopic!.emoji,
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 16),
            Text(
              '${_selectedTopic!.title} 해몽 중...',
              style: TypographyUnified.heading4.copyWith(
                color: isDark
                    ? TossDesignSystem.textPrimaryDark
                    : TossDesignSystem.textPrimaryLight,
              ),
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                TossDesignSystem.tossBlue,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'AI가 꿈을 분석하고 있어요',
            style: TypographyUnified.bodyMedium.copyWith(
              color: isDark
                  ? TossDesignSystem.textSecondaryDark
                  : TossDesignSystem.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  /// 꿈 주제 선택 핸들러
  void _onTopicSelected(DreamTopic topic) {
    setState(() {
      _selectedTopic = topic;
    });
    _handleSubmit(topic);
  }


  // ==================== Result View ====================

  Widget _buildResultView(FortuneResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 종합 운세 카드
          _buildOverallCard(result),
          const SizedBox(height: 16),

          // 꿈 상징 (블러 대상)
          BlurredFortuneContent(
            fortuneResult: result,
            child: _buildSymbolsCard(result),
          ),
          const SizedBox(height: 16),

          // 해석 (블러 대상)
          BlurredFortuneContent(
            fortuneResult: result,
            child: _buildInterpretationCard(result),
          ),
          const SizedBox(height: 16),

          // 조언 (블러 대상)
          BlurredFortuneContent(
            fortuneResult: result,
            child: _buildAdviceCard(result),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildOverallCard(FortuneResult result) {
    final score = result.score ?? 75;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B5CF6),
            const Color(0xFF6366F1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '${result.data['dreamType'] ?? '길몽'} 📖',
            style: TypographyUnified.heading2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '행운 점수',
            style: TypographyUnified.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$score점',
            style: TypographyUnified.displayMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolsCard(FortuneResult result) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final symbols = (result.data['relatedSymbols'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? TossDesignSystem.surfaceBackgroundDark
            : TossDesignSystem.surfaceBackgroundLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔮 주요 상징',
            style: TypographyUnified.heading4.copyWith(
              color: isDark
                  ? TossDesignSystem.textPrimaryDark
                  : TossDesignSystem.textPrimaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: symbols.map((symbol) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  symbol,
                  style: TypographyUnified.bodySmall.copyWith(
                    color: const Color(0xFF8B5CF6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInterpretationCard(FortuneResult result) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final interpretation = FortuneTextCleaner.clean(result.data['interpretation'] as String? ?? '해석 정보가 없습니다.');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? TossDesignSystem.surfaceBackgroundDark
            : TossDesignSystem.surfaceBackgroundLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📖 꿈 해석',
            style: TypographyUnified.heading4.copyWith(
              color: isDark
                  ? TossDesignSystem.textPrimaryDark
                  : TossDesignSystem.textPrimaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            interpretation,
            style: TypographyUnified.bodyMedium.copyWith(
              color: isDark
                  ? TossDesignSystem.textSecondaryDark
                  : TossDesignSystem.textSecondaryLight,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard(FortuneResult result) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final advice = FortuneTextCleaner.clean(result.data['todayGuidance'] as String? ?? '조언 정보가 없습니다.');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? TossDesignSystem.surfaceBackgroundDark
            : TossDesignSystem.surfaceBackgroundLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 조언',
            style: TypographyUnified.heading4.copyWith(
              color: isDark
                  ? TossDesignSystem.textPrimaryDark
                  : TossDesignSystem.textPrimaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            advice,
            style: TypographyUnified.bodyMedium.copyWith(
              color: isDark
                  ? TossDesignSystem.textSecondaryDark
                  : TossDesignSystem.textSecondaryLight,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Actions ====================

  Future<void> _handleSubmit(DreamTopic topic) async {
    setState(() => _isLoading = true);

    try {
      // 프리미엄 상태 확인
      final tokenState = ref.read(tokenProvider);
      final premiumOverride = await DebugPremiumService.getOverrideValue();
      final isPremium = premiumOverride ?? tokenState.hasUnlimitedAccess;

      // Conditions 생성 (선택된 꿈 주제 기반)
      final conditions = DreamFortuneConditions(
        dreamContent: topic.dreamContentForApi,
        dreamDate: DateTime.now(),
        dreamEmotion: null, // 버블 선택에서는 감정 없음
      );

      // UnifiedFortuneService 호출
      final supabase = Supabase.instance.client;
      final fortuneService = UnifiedFortuneService(supabase);
      var result = await fortuneService.getFortune(
        fortuneType: 'dream',
        dataSource: FortuneDataSource.api,
        inputConditions: {
          'dream_topic_id': topic.id,
          'dream_topic_title': topic.title,
          'dream_topic_category': topic.category,
          'dream_content': topic.dreamContentForApi,
        },
        conditions: conditions,
        isPremium: isPremium,
      );

      // 일반 사용자는 블러 적용
      if (!isPremium) {
        result = result.copyWith(
          isBlurred: true,
          blurredSections: ['relatedSymbols', 'interpretation', 'todayGuidance'],
        );
      }

      if (mounted) {
        setState(() {
          _fortuneResult = result;
          _showResult = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      Logger.error('[DreamInterpretationPage] Error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        Toast.show(
          context,
          message: '꿈 해석에 실패했습니다',
          type: ToastType.error,
        );
      }
    }
  }

  void _resetForm() {
    setState(() {
      _showResult = false;
      _fortuneResult = null;
      _selectedTopic = null;
    });
  }
}
