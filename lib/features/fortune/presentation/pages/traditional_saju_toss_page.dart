import 'dart:ui'; // ✅ Phase 19-1: ImageFilter.blur용
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../shared/components/toss_floating_progress_button.dart';
import '../../../../shared/components/floating_bottom_button.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/models/fortune_result.dart';
import '../../../../core/services/debug_premium_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../providers/saju_provider.dart';
import '../widgets/saju_element_chart.dart';
import '../widgets/manseryeok_display.dart';
import '../widgets/standard_fortune_app_bar.dart';
import '../../../../services/ad_service.dart';
import '../../../../presentation/providers/ad_provider.dart'; // ✅ Phase 19-2

/// 토스 스타일 전통 사주팔자 페이지
class TraditionalSajuTossPage extends ConsumerStatefulWidget {
  const TraditionalSajuTossPage({super.key});

  @override
  ConsumerState<TraditionalSajuTossPage> createState() => _TraditionalSajuTossPageState();
}

class _TraditionalSajuTossPageState extends ConsumerState<TraditionalSajuTossPage> 
    with TickerProviderStateMixin {
  // 애니메이션 컨트롤러
  late AnimationController _resultAnimationController;
  
  // 질문 선택 및 운세보기 상태 관리
  String? _selectedQuestion;
  final TextEditingController _customQuestionController = TextEditingController();
  bool _isFortuneLoading = false;
  bool _showResults = false;

  // ✅ Phase 19-3: Blur 상태 관리
  bool _isBlurred = false;
  List<String> _blurredSections = [];

  // API 응답 저장
  FortuneResult? _fortuneResult;
  
  @override
  void initState() {
    super.initState();
    _resultAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // 애니메이션 즉시 시작 - 오행 차트 표시를 위해
    _resultAnimationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 바로 사주 데이터 로드
      ref.read(sajuProvider.notifier).fetchUserSaju();
    });
  }
  
  @override
  void dispose() {
    // 애니메이션 컨트롤러 먼저 해제
    _resultAnimationController.dispose();
    _customQuestionController.dispose();
    super.dispose();
  }
  
  
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sajuState = ref.watch(sajuProvider);

    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
      appBar: StandardFortuneAppBar(
        title: '전통 사주팔자',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: _buildBody(sajuState),
    );
  }
  
  Widget _buildBody(SajuState sajuState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (sajuState.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              '사주 데이터를 불러오는 중...',
              style: TextStyle(
                color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
              ),
            ),
          ],
        ),
      );
    }

    if (sajuState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: TossTheme.error),
            const SizedBox(height: 16),
            Text(
              sajuState.error!,
              textAlign: TextAlign.center,
              style: TossTheme.body3.copyWith(
                color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 24),
            TossButton(
              text: '다시 시도',
              onPressed: () {
                ref.read(sajuProvider.notifier).fetchUserSaju();
              },
              style: TossButtonStyle.primary,
            ),
          ],
        ),
      );
    }

    if (sajuState.sajuData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 48,
              color: isDark ? TossDesignSystem.textTertiaryDark : TossDesignSystem.textTertiaryLight,
            ),
            const SizedBox(height: 16),
            Text(
              '사주 데이터가 없습니다.\n먼저 사주 계산을 완료해주세요.',
              textAlign: TextAlign.center,
              style: TossTheme.body3.copyWith(
                color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
              ),
            ),
          ],
        ),
      );
    }

    // 사주 데이터가 있으면 메인 화면 표시
    return _buildMainScreen(sajuState.sajuData!);
  }
  
  Widget _buildMainScreen(Map<String, dynamic> sajuData) {
    if (_showResults) {
      return _buildResultScreen(sajuData);
    }

    final hasQuestion = _selectedQuestion != null && _selectedQuestion!.isNotEmpty;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(TossTheme.spacingM),
          child: Column(
            children: [
              // 기본 사주 정보만 표시
              _buildBasicSajuInfo(sajuData),
              const SizedBox(height: TossTheme.spacingL),

              // 질문 선택 섹션
              _buildQuestionSelectionSection(),
              const SizedBox(height: TossTheme.spacingL),

              const BottomButtonSpacing(),
            ],
          ),
        ),
        TossFloatingProgressButtonPositioned(
          text: _isFortuneLoading ? '운세를 보고 있어요' : '📿 하늘이 정한 나의 운명',
          onPressed: hasQuestion && !_isFortuneLoading ? _onFortuneButtonPressed : null,
          isEnabled: hasQuestion && !_isFortuneLoading,
          showProgress: false,
          isLoading: _isFortuneLoading,
          isVisible: hasQuestion,
        ),
      ],
    );
  }

  Widget _buildResultScreen(Map<String, dynamic> sajuData) {
    _resultAnimationController.forward();
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(TossTheme.spacingM),
          child: Column(
            children: [
              // 운세 결과
              _buildFortuneResult(sajuData),
              const SizedBox(height: TossTheme.spacingL),

              const BottomButtonSpacing(),
            ],
          ),
        ),
        // 블러 상태일 때만 광고 버튼 표시
        if (_isBlurred)
          TossFloatingProgressButtonPositioned(
            text: '🎁 광고 보고 전체 운세 보기',
            onPressed: _showAdAndUnblur,
            isEnabled: true,
            showProgress: false,
            isVisible: true,
            isLoading: false,
          ),
      ],
    );
  }

  Widget _buildBasicSajuInfo(Map<String, dynamic> sajuData) {
    // 오행 균형 데이터 생성 - sajuProvider에서 가져오기
    final sajuState = ref.watch(sajuProvider);
    final providerElements = sajuState.sajuData?['elements'] as Map<String, dynamic>?;
    
    final elementBalance = {
      '목': providerElements?['목'] ?? sajuData['elementBalance']?['목'] ?? 0,
      '화': providerElements?['화'] ?? sajuData['elementBalance']?['화'] ?? 0,
      '토': providerElements?['토'] ?? sajuData['elementBalance']?['토'] ?? 0,
      '금': providerElements?['금'] ?? sajuData['elementBalance']?['금'] ?? 0,
      '수': providerElements?['수'] ?? sajuData['elementBalance']?['수'] ?? 0,
    };
    
    return Column(
      children: [
        // 사주 명식 표시 (만세력 스타일)
        ManseryeokDisplay(sajuData: sajuData),
        const SizedBox(height: TossTheme.spacingL),
        
        // 오행 차트
        SajuElementChart(
          elementBalance: elementBalance,
          animationController: _resultAnimationController,
        ),
      ],
    );
  }

  Widget _buildQuestionSelectionSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final predefinedQuestions = [
      '언제 돈이 들어올까요?',
      '어떤 일이 나에게 맞을까요?',
      '언제 결혼하면 좋을까요?',
      '건강 주의사항이 있나요?',
      '어느 방향으로 가면 좋을까요?',
    ];

    return TossCard(
      padding: const EdgeInsets.all(TossTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '궁금한 질문을 선택하세요',
            style: TossTheme.heading3.copyWith(
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            ),
          ),
          const SizedBox(height: TossTheme.spacingM),
          
          // 미리 정의된 질문들
          ...predefinedQuestions.map((question) => 
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: TossTheme.spacingS),
              child: TossButton(
                text: question,
                onPressed: () {
                  setState(() {
                    _selectedQuestion = question;
                    _customQuestionController.clear();
                  });
                },
                style: _selectedQuestion == question 
                    ? TossButtonStyle.primary 
                    : TossButtonStyle.secondary,
              ),
            ),
          ),
          
          const SizedBox(height: TossTheme.spacingL),

          // 직접 질문 입력
          Text(
            '또는 직접 질문을 작성해주세요',
            style: TossTheme.body3.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            ),
          ),
          const SizedBox(height: TossTheme.spacingM),

          TextField(
            controller: _customQuestionController,
            onChanged: (value) {
              setState(() {
                if (value.isNotEmpty) {
                  _selectedQuestion = value;
                } else if (_selectedQuestion != null && !predefinedQuestions.contains(_selectedQuestion)) {
                  _selectedQuestion = null;
                }
              });
            },
            decoration: InputDecoration(
              hintText: '예: 언제 직장을 옮겨야 할까요?',
              hintStyle: TossTheme.hintStyle.copyWith(
                color: isDark ? TossDesignSystem.textTertiaryDark : TossDesignSystem.textTertiaryLight,
              ),
              fillColor: isDark ? TossDesignSystem.surfaceBackgroundDark : TossDesignSystem.surfaceBackgroundLight,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TossTheme.radiusM),
                borderSide: BorderSide(
                  color: isDark ? TossDesignSystem.borderDark : TossDesignSystem.borderLight,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TossTheme.radiusM),
                borderSide: BorderSide(color: TossTheme.brandBlue, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TossTheme.radiusM),
                borderSide: BorderSide(
                  color: isDark ? TossDesignSystem.borderDark : TossDesignSystem.borderLight,
                ),
              ),
              contentPadding: const EdgeInsets.all(TossTheme.spacingM),
            ),
            style: TossTheme.body3.copyWith(
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }


  Future<void> _onFortuneButtonPressed() async {
    setState(() {
      _isFortuneLoading = true;
    });

    try {
      // 1. 프리미엄 상태 확인
      final tokenState = ref.read(tokenProvider);
      final premiumOverride = await DebugPremiumService.getOverrideValue();
      final isPremium = premiumOverride ?? tokenState.hasUnlimitedAccess;

      // 2. 사주 데이터 가져오기
      final sajuState = ref.read(sajuProvider);
      final sajuData = sajuState.sajuData;

      if (sajuData == null) {
        throw Exception('사주 데이터가 없습니다');
      }

      // 3. UnifiedFortuneService 호출
      final fortuneService = UnifiedFortuneService(Supabase.instance.client);

      final result = await fortuneService.getFortune(
        fortuneType: 'traditional_saju',
        dataSource: FortuneDataSource.api,
        inputConditions: {
          'question': _selectedQuestion,
          'sajuData': sajuData,  // LLM에는 전체 데이터 전달
          'isPremium': isPremium,
          // DB 저장용 간소화된 데이터
          'simplified_for_db': {
            'dominantElement': sajuData['dominantElement'],
            'lackingElement': sajuData['lackingElement'],
            'elements': sajuData['elements'],
          },
        },
        isPremium: isPremium,
      );

      if (!mounted) return;

      setState(() {
        _fortuneResult = result;
        _isBlurred = result.isBlurred ?? false;
        _blurredSections = result.blurredSections ?? [];
        _isFortuneLoading = false;
        _showResults = true;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isFortuneLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('운세를 불러오는데 실패했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildFortuneResult(Map<String, dynamic> sajuData) {
    if (_fortuneResult == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final question = _fortuneResult!.data['question'] as String? ?? _selectedQuestion ?? '';
    final sections = _fortuneResult!.data['sections'] as Map<String, dynamic>? ?? {};

    final analysis = sections['analysis'] as String? ?? '';
    final answer = sections['answer'] as String? ?? '';
    final advice = sections['advice'] as String? ?? '';
    final supplement = sections['supplement'] as String? ?? '';

    return Column(
      children: [
        // 질문 카드
        TossCard(
          padding: const EdgeInsets.all(TossTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: TossTheme.brandBlue, size: 24),
                  const SizedBox(width: TossTheme.spacingS),
                  Text(
                    '질문',
                    style: TossTheme.heading3.copyWith(
                      color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TossTheme.spacingM),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(TossTheme.spacingM),
                decoration: BoxDecoration(
                  color: TossTheme.brandBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(TossTheme.radiusM),
                  border: Border.all(color: TossTheme.brandBlue.withValues(alpha: 0.3)),
                ),
                child: Text(
                  question,
                  style: TossTheme.body3.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: TossTheme.spacingM),

        // 사주 분석 (항상 표시)
        _buildSection(
          title: '📊 사주 분석',
          content: analysis,
          isDark: isDark,
          sectionKey: 'analysis',
        ),

        const SizedBox(height: TossTheme.spacingM),

        // 답변 (블러)
        _buildSection(
          title: '💬 답변',
          content: answer,
          isDark: isDark,
          sectionKey: 'answer',
        ),

        const SizedBox(height: TossTheme.spacingM),

        // 조언 (블러)
        _buildSection(
          title: '💡 조언',
          content: advice,
          isDark: isDark,
          sectionKey: 'advice',
        ),

        const SizedBox(height: TossTheme.spacingM),

        // 오행 보완 (블러)
        _buildSection(
          title: '🌿 오행 보완',
          content: supplement,
          isDark: isDark,
          sectionKey: 'supplement',
        ),
      ],
    );
  }

  /// 섹션 빌더 (제목은 항상 표시, 내용만 블러)
  Widget _buildSection({
    required String title,
    required String content,
    required bool isDark,
    required String sectionKey,
  }) {
    return TossCard(
      padding: const EdgeInsets.all(TossTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목은 항상 표시 (블러 없음)
          Text(
            title,
            style: TossTheme.heading4.copyWith(
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            ),
          ),
          const SizedBox(height: TossTheme.spacingM),

          // 내용만 블러 처리
          _buildBlurWrapper(
            child: Text(
              content,
              style: TossTheme.body3.copyWith(
                height: 1.6,
                color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
              ),
            ),
            sectionKey: sectionKey,
          ),
        ],
      ),
    );
  }

  /// 블러 래퍼 위젯 (내용만 블러 처리)
  Widget _buildBlurWrapper({
    required Widget child,
    required String sectionKey,
  }) {
    if (!_isBlurred || !_blurredSections.contains(sectionKey)) {
      return child;
    }

    return Stack(
      children: [
        // 블러 처리된 텍스트
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
        // 반투명 오버레이
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(TossTheme.radiusS),
            ),
          ),
        ),
        // 잠금 아이콘 (중앙 배치)
        Positioned.fill(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline,
                size: 32,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 광고 시청 후 블러 해제
  Future<void> _showAdAndUnblur() async {
    if (_fortuneResult == null) return;

    try {
      final adService = AdService.instance;

      // 광고가 준비되지 않았다면 백그라운드에서 로드
      if (!adService.isRewardedAdReady) {
        // 광고 로드 시작
        await adService.loadRewardedAd();

        // 로딩 완료 대기 (최대 5초)
        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

        // 여전히 준비되지 않았다면 에러 메시지
        if (!adService.isRewardedAdReady) {
          Logger.warning('[Traditional-Saju] ⚠️ Rewarded ad still not ready after loading');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('광고를 준비할 수 없습니다. 잠시 후 다시 시도해주세요.'),
                duration: Duration(seconds: 3),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
      }

      Logger.info('[Traditional-Saju] 광고 시청 후 블러 해제 시작');

      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) {
          Logger.info('[Traditional-Saju] ✅ User earned reward: ${reward.amount} ${reward.type}');
          if (mounted) {
            setState(() {
              _isBlurred = false;
              _blurredSections = [];
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('운세가 잠금 해제되었습니다!'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      );
    } catch (e) {
      Logger.error('[Traditional-Saju] ❌ Failed to show rewarded ad: $e', e);
      if (mounted) {
        // 광고 실패 시 에러 메시지만 표시 (잠금 해제 안함)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('광고를 표시할 수 없습니다. 잠시 후 다시 시도해주세요.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

}