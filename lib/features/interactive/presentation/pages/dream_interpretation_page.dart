import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/fortune_result.dart';
import '../../../fortune/domain/models/conditions/dream_fortune_conditions.dart';
import '../../../../core/theme/font_config.dart';
import '../../../../core/theme/fortune_design_system.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/components/toast.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../core/widgets/blurred_fortune_content.dart';
import '../../../../core/services/debug_premium_service.dart';
import '../../../../core/utils/fortune_text_cleaner.dart';
import '../../../../core/widgets/floating_dream_bubbles.dart';
import '../../../../core/widgets/unified_voice_text_field.dart';
import '../../../../data/popular_dream_topics.dart';
import '../../../../data/dream_interpretations_data.dart';
import '../../../../services/storage_service.dart';

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
  bool _isLoadingSavedResult = true; // F15: 저장된 결과 로딩 상태

  // F14: 미리 로드된 버블 토픽
  late List<DreamTopic> _preloadedBubbleTopics;

  // 텍스트 입력 컨트롤러
  final TextEditingController _dreamTextController = TextEditingController();

  // Storage service for F15
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    // F14: 버블 토픽 미리 로드 (UI 렌더링 전에 준비)
    _preloadedBubbleTopics = PopularDreamTopics.getRandomTopics(15);
    _loadSavedResult();
  }

  /// F15: 저장된 꿈 해몽 결과 로드 (오늘 결과가 있으면 바로 표시)
  Future<void> _loadSavedResult() async {
    try {
      final savedData = await _storageService.getDreamResult();
      if (savedData != null && mounted) {
        debugPrint('🌙 [DreamPage] 저장된 결과 발견, 복원 중...');

        // FortuneResult 복원 (fromJson 사용)
        final resultData = savedData['fortuneResult'] as Map<String, dynamic>?;
        if (resultData != null) {
          final result = FortuneResult.fromJson(resultData);

          // 저장된 topic 복원
          final topicData = savedData['selectedTopic'] as Map<String, dynamic>?;
          DreamTopic? topic;
          if (topicData != null) {
            topic = DreamTopic(
              id: topicData['id'] as String? ?? 'custom',
              emoji: topicData['emoji'] as String? ?? '✨',
              title: topicData['title'] as String? ?? '저장된 꿈',
              category: topicData['category'] as String? ?? '기타',
              customContent: topicData['customContent'] as String?,
            );
          }

          setState(() {
            _fortuneResult = result;
            _selectedTopic = topic;
            _showResult = true;
            _isLoadingSavedResult = false;
          });
          debugPrint('🌙 [DreamPage] ✅ 저장된 결과 복원 완료');
          return;
        }
      }
    } catch (e) {
      debugPrint('🌙 [DreamPage] 저장된 결과 로드 실패: $e');
    }

    if (mounted) {
      setState(() {
        _isLoadingSavedResult = false;
      });
    }
  }

  @override
  void dispose() {
    _dreamTextController.dispose();
    super.dispose();
  }

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
          style: DSTypography.headingSmall.copyWith(
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
            if (_isLoadingSavedResult)
              _buildInitialLoadingView() // F15: 저장된 결과 확인 중
            else if (_showResult && _fortuneResult != null)
              _buildResultView(_fortuneResult!)
            else if (_isLoading)
              _buildLoadingView()
            else
              _buildBubbleSelectionView(),

            // 결과 화면에서 다시하기 버튼
            if (_showResult && _fortuneResult != null && !_isLoadingSavedResult)
              UnifiedButton.floating(
                text: '다른 꿈 해몽하기',
                onPressed: _resetForm,
              ),
          ],
        ),
      ),
    );
  }

  /// F15: 초기 로딩 화면 (저장된 결과 확인 중)
  Widget _buildInitialLoadingView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '🌙',
            style: TextStyle(fontSize: FontConfig.emojiMedium),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF8B5CF6),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '꿈 해몽 준비 중...',
            style: DSTypography.bodyMedium.copyWith(
              color: isDark
                  ? TossDesignSystem.textSecondaryDark
                  : TossDesignSystem.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  /// 버블 선택 화면
  Widget _buildBubbleSelectionView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // 플로팅 버블들 (상단 입력 영역 공간 확보)
        Padding(
          padding: const EdgeInsets.only(top: 220),
          child: FloatingDreamBubbles(
            onTopicSelected: _onTopicSelected,
            bubbleCount: 15,
            preloadedTopics: _preloadedBubbleTopics, // F14: 미리 로드된 토픽 전달
          ),
        ),

        // 상단 안내 문구 + 텍스트 입력바 통합
        Positioned(
          top: 20,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: (isDark
                      ? TossDesignSystem.surfaceBackgroundDark
                      : TossDesignSystem.white)
                  .withValues(alpha: 0.98),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                // 기본 그림자
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                // 글로우 효과
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                  blurRadius: 30,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Column(
              children: [
                // 안내 문구
                Text(
                  '🌙 어떤 꿈을 꾸셨나요?',
                  style: DSTypography.headingSmall.copyWith(
                    color: isDark
                        ? TossDesignSystem.textPrimaryDark
                        : TossDesignSystem.textPrimaryLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '꿈 내용을 입력하거나 아래 버블을 선택하세요',
                  style: DSTypography.bodySmall.copyWith(
                    color: isDark
                        ? TossDesignSystem.textSecondaryDark
                        : TossDesignSystem.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 16),

                // 텍스트 입력바 (그라데이션 테두리)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF8B5CF6).withValues(alpha: 0.6),
                        const Color(0xFF6366F1).withValues(alpha: 0.6),
                        const Color(0xFF8B5CF6).withValues(alpha: 0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                        blurRadius: 12,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(2), // 테두리 두께
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? TossDesignSystem.backgroundDark
                          : TossDesignSystem.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: UnifiedVoiceTextField(
                      controller: _dreamTextController,
                      onSubmit: _onTextSubmit,
                      hintText: '예: 하늘을 나는 꿈, 이빨 빠지는 꿈...',
                      transcribingText: '듣고 있어요...',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 텍스트 입력 제출 핸들러
  void _onTextSubmit(String text) {
    if (text.trim().isEmpty) return;

    // 커스텀 DreamTopic 생성
    final customTopic = DreamTopic.custom(text.trim());

    // 입력 필드 초기화
    _dreamTextController.clear();

    // 해몽 시작
    _onTopicSelected(customTopic);
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
              style: TextStyle(fontSize: FontConfig.emojiXLarge),
            ),
            const SizedBox(height: 16),
            Text(
              '${_selectedTopic!.title} 해몽 중...',
              style: DSTypography.headingSmall.copyWith(
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
            '신령이 꿈을 풀이하고 있어요',
            style: DSTypography.bodyMedium.copyWith(
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
            style: DSTypography.headingMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '행운 점수',
            style: DSTypography.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$score점',
            style: DSTypography.displayMedium.copyWith(
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
            style: DSTypography.headingSmall.copyWith(
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
                  style: DSTypography.bodySmall.copyWith(
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
            style: DSTypography.headingSmall.copyWith(
              color: isDark
                  ? TossDesignSystem.textPrimaryDark
                  : TossDesignSystem.textPrimaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            interpretation,
            style: DSTypography.bodyMedium.copyWith(
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
            style: DSTypography.headingSmall.copyWith(
              color: isDark
                  ? TossDesignSystem.textPrimaryDark
                  : TossDesignSystem.textPrimaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            advice,
            style: DSTypography.bodyMedium.copyWith(
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
    debugPrint('🌙 [DreamPage] _handleSubmit 시작: ${topic.title}');

    try {
      // 프리미엄 상태 확인
      final tokenState = ref.read(tokenProvider);
      final premiumOverride = await DebugPremiumService.getOverrideValue();
      final isPremium = premiumOverride ?? tokenState.hasUnlimitedAccess;
      debugPrint('🌙 [DreamPage] isPremium: $isPremium');

      FortuneResult result;

      // ✅ 분기 처리: 버블 선택 vs 직접 입력
      if (!topic.isCustom) {
        // 버블 선택 → 하드코딩 데이터 사용 (API 호출 X)
        final hardcodedData = DreamInterpretations.getById(topic.id);
        if (hardcodedData != null) {
          debugPrint('🌙 [DreamPage] 하드코딩 데이터 사용: ${topic.id}');
          result = hardcodedData.toFortuneResult(
            isPremium: isPremium,
            dreamTitle: topic.title,
          );
        } else {
          // fallback: 하드코딩 데이터 없으면 API 호출
          debugPrint('🌙 [DreamPage] 하드코딩 데이터 없음, API 호출: ${topic.id}');
          result = await _callDreamApi(topic, isPremium);
        }
      } else {
        // 직접 입력 → API 호출
        debugPrint('🌙 [DreamPage] 직접 입력, API 호출');
        result = await _callDreamApi(topic, isPremium);
      }

      // 일반 사용자는 블러 적용
      if (!isPremium) {
        result = result.copyWith(
          isBlurred: true,
          blurredSections: ['relatedSymbols', 'interpretation', 'todayGuidance'],
        );
      }

      if (mounted) {
        debugPrint('🌙 [DreamPage] 결과 설정 중: isBlurred=${result.isBlurred}, data keys=${result.data.keys.toList()}');
        setState(() {
          _fortuneResult = result;
          _showResult = true;
          _isLoading = false;
        });

        // F15: 결과 저장 (다음날까지 유지)
        await _saveDreamResult(result, topic);

        debugPrint('🌙 [DreamPage] ✅ 결과 화면 전환 완료');
      }
    } catch (e, stackTrace) {
      Logger.error('[DreamInterpretationPage] Error: $e');
      debugPrint('🌙 [DreamPage] ❌ 에러 발생: $e');
      debugPrint('🌙 [DreamPage] 스택: $stackTrace');
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

  /// 꿈 해몽 API 호출 (직접 입력 또는 하드코딩 데이터 없을 때)
  Future<FortuneResult> _callDreamApi(DreamTopic topic, bool isPremium) async {
    // Conditions 생성 (선택된 꿈 주제 기반)
    final conditions = DreamFortuneConditions(
      dreamContent: topic.dreamContentForApi,
      dreamDate: DateTime.now(),
      dreamEmotion: null,
    );

    // UnifiedFortuneService 호출
    debugPrint('🌙 [DreamPage] API 호출 시작...');
    final supabase = Supabase.instance.client;
    final fortuneService = UnifiedFortuneService(supabase);
    final result = await fortuneService.getFortune(
      fortuneType: 'dream',
      dataSource: FortuneDataSource.api,
      inputConditions: {
        'dream': topic.dreamContentForApi,
        'dream_topic_id': topic.id,
        'dream_topic_title': topic.title,
        'dream_topic_category': topic.category,
        'isPremium': isPremium,
      },
      conditions: conditions,
      isPremium: isPremium,
    );
    debugPrint('🌙 [DreamPage] API 응답 받음: ${result.type}, score=${result.score}');
    return result;
  }

  /// F15: 꿈 해몽 결과 저장
  Future<void> _saveDreamResult(FortuneResult result, DreamTopic topic) async {
    try {
      final dataToSave = {
        'fortuneResult': result.toJson(),
        'selectedTopic': {
          'id': topic.id,
          'emoji': topic.emoji,
          'title': topic.title,
          'category': topic.category,
          'customContent': topic.customContent,
        },
      };
      await _storageService.saveDreamResult(dataToSave);
      debugPrint('🌙 [DreamPage] 결과 저장 완료');
    } catch (e) {
      debugPrint('🌙 [DreamPage] 결과 저장 실패: $e');
    }
  }

  void _resetForm() {
    // F15: 저장된 결과도 삭제 (다른 꿈 해몽하기)
    _storageService.clearDreamResult();

    setState(() {
      _showResult = false;
      _fortuneResult = null;
      _selectedTopic = null;
    });
  }
}
