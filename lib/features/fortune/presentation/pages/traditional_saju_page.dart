import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/components/app_card.dart';
import '../../../../core/widgets/gpt_style_typing_text.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/theme/font_config.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/design_system/tokens/ds_fortune_colors.dart';
import '../../../../core/design_system/components/traditional/traditional_button.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/models/fortune_result.dart';
import '../../../../core/services/debug_premium_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/fortune_completion_helper.dart';
import '../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../presentation/providers/subscription_provider.dart';
import '../providers/saju_provider.dart';
import '../widgets/saju_element_chart.dart';
import '../widgets/fortune_loading_skeleton.dart';
// 전문가 사주 위젯들
import '../widgets/saju/saju_widgets.dart';
import '../../../../../data/saju_explanations.dart';
import '../../../../services/ad_service.dart';
import '../../../../core/utils/fortune_text_cleaner.dart';
import '../../../../core/utils/subscription_snackbar.dart';
import '../../../../core/services/fortune_haptic_service.dart';
// ✅ Phase 19-2

/// 토스 스타일 전통 사주팔자 페이지
class TraditionalSajuPage extends ConsumerStatefulWidget {
  const TraditionalSajuPage({super.key});

  @override
  ConsumerState<TraditionalSajuPage> createState() => _TraditionalSajuPageState();
}

class _TraditionalSajuPageState extends ConsumerState<TraditionalSajuPage>
    with TickerProviderStateMixin {
  // 애니메이션 컨트롤러
  late AnimationController _resultAnimationController;

  // 탭 컨트롤러 (세그먼트 네비게이션)
  late TabController _tabController;
  static const List<String> _tabNames = ['명식', '오행', '지장간', '12운성', '신살', '합충', '질문'];

  // 질문 선택 및 운세보기 상태 관리
  String? _selectedQuestion;
  final TextEditingController _customQuestionController = TextEditingController();
  bool _isFortuneLoading = false;
  bool _showResults = false;

  // ✅ Phase 19-3: Blur 상태 관리
  bool _isBlurred = false;
  List<String> _blurredSections = [];

  // GPT 스타일 타이핑 효과 섹션 관리
  int _currentTypingSection = 0;

  // API 응답 저장
  FortuneResult? _fortuneResult;

  // 사주 자동 계산 상태
  bool _isAutoCalculating = false;
  bool _needsBirthDate = false;
  
  @override
  void initState() {
    super.initState();
    _resultAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // 탭 컨트롤러 초기화
    _tabController = TabController(
      length: _tabNames.length,
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
    _tabController.dispose();
    _customQuestionController.dispose();
    super.dispose();
  }
  
  
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hanjiBackground = DSFortuneColors.getHanjiBackground(isDark);
    final inkColor = isDark ? const Color(0xFFD4D0C8) : const Color(0xFF2C2C2C);
    final sajuState = ref.watch(sajuProvider);

    return Scaffold(
      backgroundColor: hanjiBackground,
      appBar: AppBar(
        backgroundColor: hanjiBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            _showResults ? Icons.close : Icons.arrow_back_ios_new,
            color: inkColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '四柱命理',
              style: context.labelMedium.copyWith(
                fontFamily: FontConfig.primary,
                color: inkColor.withValues(alpha: 0.6),
                letterSpacing: 2,
              ),
            ),
            Text(
              '사주 명리',
              style: context.heading3.copyWith(
                fontFamily: FontConfig.primary,
                color: inkColor,
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(sajuState),
    );
  }
  
  Widget _buildBody(SajuState sajuState) {
    final colors = context.colors;

    if (sajuState.isLoading) {
      return FortuneLoadingSkeleton(
        itemCount: 3,
        showHeader: true,
        loadingMessages: const [
          '사주 데이터를 불러오는 중...',
          '오행의 균형을 분석하고 있어요',
          '팔자를 해석하고 있어요...',
        ],
      );
    }

    if (sajuState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: colors.error),
            const SizedBox(height: DSSpacing.md),
            Text(
              sajuState.error!,
              textAlign: TextAlign.center,
              style: context.bodyLarge.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: DSSpacing.lg),
            TraditionalButton(
              text: '다시 시도',
              hanja: '再試',
              style: TraditionalButtonStyle.filled,
              colorScheme: TraditionalButtonColorScheme.fortune,
              onPressed: () {
                ref.read(sajuProvider.notifier).fetchUserSaju();
              },
            ),
          ],
        ),
      );
    }

    if (sajuState.sajuData == null) {
      // 사주 데이터가 없으면 자동 계산 시도
      if (!_isAutoCalculating && !_needsBirthDate) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _tryAutoCalculateSaju();
        });
      }

      // 자동 계산 중
      if (_isAutoCalculating) {
        return FortuneLoadingSkeleton(
          itemCount: 3,
          showHeader: true,
          loadingMessages: const [
            '사주를 계산하고 있어요...',
            '만세력을 분석하는 중...',
            '팔자를 정리하고 있어요...',
          ],
        );
      }

      // 생년월일이 없어서 계산 불가
      if (_needsBirthDate) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 48,
                color: colors.textTertiary,
              ),
              const SizedBox(height: DSSpacing.md),
              Text(
                '생년월일 정보가 필요해요.\n프로필에서 생년월일을 입력해주세요.',
                textAlign: TextAlign.center,
                style: context.bodyLarge.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: DSSpacing.lg),
              TraditionalButton(
                text: '프로필 편집하기',
                hanja: '編輯',
                style: TraditionalButtonStyle.filled,
                colorScheme: TraditionalButtonColorScheme.fortune,
                onPressed: () {
                  Navigator.pop(context);
                  // 프로필 편집 페이지로 이동
                  Navigator.pushNamed(context, '/profile-edit');
                },
              ),
            ],
          ),
        );
      }

      // 기본 로딩 상태
      return FortuneLoadingSkeleton(
        itemCount: 3,
        showHeader: true,
        loadingMessages: const [
          '사주 데이터를 확인하고 있어요...',
        ],
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
    final colors = context.colors;

    // 오행 균형 데이터 생성
    final sajuState = ref.watch(sajuProvider);
    final providerElements = sajuState.sajuData?['elements'] as Map<String, dynamic>?;
    final elementBalance = {
      '목': providerElements?['목'] ?? sajuData['elementBalance']?['목'] ?? 0,
      '화': providerElements?['화'] ?? sajuData['elementBalance']?['화'] ?? 0,
      '토': providerElements?['토'] ?? sajuData['elementBalance']?['토'] ?? 0,
      '금': providerElements?['금'] ?? sajuData['elementBalance']?['금'] ?? 0,
      '수': providerElements?['수'] ?? sajuData['elementBalance']?['수'] ?? 0,
    };

    return Stack(
      children: [
        Column(
          children: [
            // 탭바
            _buildTabBar(colors),
            // 탭뷰
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 1. 사주 명식
                  _buildTabContent(_buildMyungsikTab(sajuData)),
                  // 2. 오행 차트
                  _buildTabContent(_buildOhangTab(elementBalance)),
                  // 3. 지장간 분석
                  _buildTabContent(_buildJijangganTab(sajuData)),
                  // 4. 12운성 분석
                  _buildTabContent(_buildTwelveStagesTab(sajuData)),
                  // 5. 신살 분석
                  _buildTabContent(_buildSinsalTab(sajuData)),
                  // 6. 합충형파해 분석
                  _buildTabContent(_buildHapchungTab(sajuData)),
                  // 7. 질문 선택 섹션
                  _buildTabContent(_buildQuestionSelectionSection()),
                ],
              ),
            ),
          ],
        ),
        if (hasQuestion)
          Positioned(
            left: 20,
            right: 20,
            bottom: 32,
            child: TraditionalButton(
              text: _isFortuneLoading ? '운세를 보고 있어요' : '하늘이 정한 나의 운명',
              hanja: '運命',
              style: TraditionalButtonStyle.filled,
              colorScheme: TraditionalButtonColorScheme.fortune,
              isExpanded: true,
              height: 56,
              isLoading: _isFortuneLoading,
              onPressed: hasQuestion && !_isFortuneLoading ? _onFortuneButtonPressed : null,
            ),
          ),
      ],
    );
  }

  /// 탭 컨텐츠 래퍼
  Widget _buildTabContent(Widget child) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DSSpacing.md),
      physics: const ClampingScrollPhysics(),
      child: child,
    );
  }

  /// 탭바 (전통 스타일)
  Widget _buildTabBar(DSColorScheme colors) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hanjiBackground = DSFortuneColors.getHanjiBackground(isDark);
    final sealColor = DSFortuneColors.getSealColor(isDark);

    return Container(
      decoration: BoxDecoration(
        color: hanjiBackground,
        border: Border(
          bottom: BorderSide(
            color: colors.border.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: sealColor,
        unselectedLabelColor: colors.textSecondary,
        labelStyle: context.bodySmall.copyWith(
          fontWeight: FontWeight.bold,
          fontFamily: FontConfig.primary,
        ),
        unselectedLabelStyle: context.bodySmall.copyWith(
          fontWeight: FontWeight.w500,
          fontFamily: FontConfig.primary,
        ),
        indicatorColor: sealColor,
        indicatorWeight: 2,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm),
        labelPadding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
        tabs: _tabNames.map((name) => Tab(text: name)).toList(),
      ),
    );
  }

  Widget _buildResultScreen(Map<String, dynamic> sajuData) {
    _resultAnimationController.forward();
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(DSSpacing.md),
          child: Column(
            children: [
              // 운세 결과
              _buildFortuneResult(sajuData),
              const SizedBox(height: DSSpacing.lg),

              const SizedBox(height: 100), // 버튼 공간 확보
            ],
          ),
        ),
        // 블러 상태일 때만 광고 버튼 표시 (구독자 제외)
        if (_isBlurred && !ref.watch(isPremiumProvider))
          Positioned(
            left: 20,
            right: 20,
            bottom: 32,
            child: TraditionalButton(
              text: '광고 보고 전체 운세 보기',
              hanja: '解禁',
              style: TraditionalButtonStyle.filled,
              colorScheme: TraditionalButtonColorScheme.fortune,
              isExpanded: true,
              height: 56,
              onPressed: _showAdAndUnblur,
            ),
          ),
      ],
    );
  }

  // ignore: unused_element - 대체 UI로 미사용 중
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
        // 사주 명식 표시 (전문가 스타일 4주 테이블)
        SajuPillarTablePro(sajuData: sajuData),
        const SizedBox(height: DSSpacing.lg),

        // 오행 차트
        SajuElementChart(
          elementBalance: elementBalance,
          animationController: _resultAnimationController,
        ),
        const SizedBox(height: DSSpacing.lg),

        // 지장간 분석
        SajuJijangganWidget(sajuData: sajuData),
        const SizedBox(height: DSSpacing.lg),

        // 12운성 분석
        SajuTwelveStagesWidget(sajuData: sajuData),
        const SizedBox(height: DSSpacing.lg),

        // 신살 분석
        SajuSinsalWidget(sajuData: sajuData),
        const SizedBox(height: DSSpacing.lg),

        // 합충형파해 분석
        SajuHapchungWidget(sajuData: sajuData),
      ],
    );
  }

  Widget _buildQuestionSelectionSection() {
    final colors = context.colors;
    final predefinedQuestions = [
      '언제 돈이 들어올까요?',
      '어떤 일이 나에게 맞을까요?',
      '언제 결혼하면 좋을까요?',
      '건강 주의사항이 있나요?',
      '어느 방향으로 가면 좋을까요?',
    ];

    return AppCard(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '궁금한 질문을 선택하세요',
            style: context.heading3.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: DSSpacing.md),

          // 미리 정의된 질문들
          ...predefinedQuestions.map((question) =>
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: DSSpacing.sm),
              child: TraditionalButton(
                text: question,
                style: _selectedQuestion == question
                    ? TraditionalButtonStyle.filled
                    : TraditionalButtonStyle.outlined,
                colorScheme: TraditionalButtonColorScheme.fortune,
                isExpanded: true,
                onPressed: () {
                  setState(() {
                    _selectedQuestion = question;
                    _customQuestionController.clear();
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: DSSpacing.lg),

          // 직접 질문 입력
          Text(
            '또는 직접 질문을 작성해주세요',
            style: context.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: DSSpacing.md),

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
              hintStyle: context.labelSmall.copyWith(
                color: colors.textTertiary,
              ),
              fillColor: colors.backgroundSecondary,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DSRadius.md),
                borderSide: BorderSide(
                  color: colors.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DSRadius.md),
                borderSide: BorderSide(color: colors.accent, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DSRadius.md),
                borderSide: BorderSide(
                  color: colors.border,
                ),
              ),
              contentPadding: const EdgeInsets.all(DSSpacing.md),
            ),
            style: context.bodyLarge.copyWith(
              color: colors.textPrimary,
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

      // ✅ 전통 사주 결과 공개 시 햅틱 피드백
      ref.read(fortuneHapticServiceProvider).mysticalReveal();

      setState(() {
        _fortuneResult = result;
        _isBlurred = result.isBlurred;
        _blurredSections = result.blurredSections;
        _isFortuneLoading = false;
        _showResults = true;
        _currentTypingSection = 0; // 타이핑 효과 리셋
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

    final colors = context.colors;
    final question = _fortuneResult!.data['question'] as String? ?? _selectedQuestion ?? '';
    final sections = _fortuneResult!.data['sections'] as Map<String, dynamic>? ?? {};

    final analysis = FortuneTextCleaner.cleanNullable(sections['analysis'] as String?);
    final answer = FortuneTextCleaner.cleanNullable(sections['answer'] as String?);
    final advice = FortuneTextCleaner.cleanNullable(sections['advice'] as String?);
    final supplement = FortuneTextCleaner.cleanNullable(sections['supplement'] as String?);

    return Column(
      children: [
        // 질문 카드
        AppCard(
          padding: const EdgeInsets.all(DSSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: colors.accent, size: 24),
                  const SizedBox(width: DSSpacing.sm),
                  Text(
                    '질문',
                    style: context.heading3.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DSSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(DSSpacing.md),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DSRadius.md),
                  border: Border.all(color: colors.accent.withValues(alpha: 0.3)),
                ),
                child: Text(
                  question,
                  style: context.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: DSSpacing.lg),

        // 사주 명식 (전문가 스타일)
        SajuPillarTablePro(sajuData: sajuData, showTitle: false),
        const SizedBox(height: DSSpacing.md),

        // 합충형파해 (간결 버전)
        SajuHapchungWidget(sajuData: sajuData, showTitle: false),
        const SizedBox(height: DSSpacing.lg),

        // 사주 분석 (항상 표시)
        _buildSection(
          title: '📊 사주 분석',
          content: analysis,
          colors: colors,
          sectionKey: 'analysis',
          sectionIndex: 0,
        ),

        const SizedBox(height: DSSpacing.md),

        // 답변 (블러)
        _buildSection(
          title: '💬 답변',
          content: answer,
          colors: colors,
          sectionKey: 'answer',
          sectionIndex: 1,
        ),

        const SizedBox(height: DSSpacing.md),

        // 조언 (블러)
        _buildSection(
          title: '💡 조언',
          content: advice,
          colors: colors,
          sectionKey: 'advice',
          sectionIndex: 2,
        ),

        const SizedBox(height: DSSpacing.md),

        // 오행 보완 (블러)
        _buildSection(
          title: '🌿 오행 보완',
          content: supplement,
          colors: colors,
          sectionKey: 'supplement',
          sectionIndex: 3,
        ),
      ],
    );
  }

  /// 섹션 빌더 (제목은 항상 표시, 내용만 블러)
  Widget _buildSection({
    required String title,
    required String content,
    required DSColorScheme colors,
    required String sectionKey,
    required int sectionIndex,
  }) {
    final isLastSection = sectionIndex == 3; // supplement가 마지막

    return AppCard(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목은 항상 표시 (블러 없음)
          Text(
            title,
            style: context.labelLarge.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: DSSpacing.md),

          // 내용만 블러 처리
          UnifiedBlurWrapper(
            isBlurred: _isBlurred,
            blurredSections: _blurredSections,
            sectionKey: sectionKey,
            child: GptStyleTypingText(
              text: content,
              style: context.bodyLarge.copyWith(
                height: 1.6,
                color: colors.textPrimary,
              ),
              startTyping: _currentTypingSection >= sectionIndex,
              showGhostText: true,
              onComplete: () {
                if (!isLastSection && mounted) {
                  setState(() => _currentTypingSection = sectionIndex + 1);
                }
              },
            ),
          ),
        ],
      ),
    );
  }



  /// 사주 자동 계산 시도
  Future<void> _tryAutoCalculateSaju() async {
    if (_isAutoCalculating) return;

    setState(() {
      _isAutoCalculating = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        setState(() {
          _isAutoCalculating = false;
          _needsBirthDate = true;
        });
        return;
      }

      // 프로필에서 생년월일 확인
      final profile = await supabase
          .from('user_profiles')
          .select('birth_date, birth_time')
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null || profile['birth_date'] == null) {
        setState(() {
          _isAutoCalculating = false;
          _needsBirthDate = true;
        });
        return;
      }

      // 생년월일이 있으면 사주 계산
      final birthDate = DateTime.parse(profile['birth_date']);
      final birthTime = _convertBirthTimeToHHmm(profile['birth_time']);

      Logger.info('[Traditional-Saju] 사주 자동 계산 시작: $birthDate, $birthTime');

      await ref.read(sajuProvider.notifier).calculateAndSaveSaju(
        birthDate: birthDate,
        birthTime: birthTime,
        isLunar: false,
      );

      if (mounted) {
        setState(() {
          _isAutoCalculating = false;
        });
      }
    } catch (e) {
      Logger.error('[Traditional-Saju] 사주 자동 계산 실패: $e', e);
      if (mounted) {
        setState(() {
          _isAutoCalculating = false;
        });
      }
    }
  }

  /// 한국식 시간 형식을 HH:mm으로 변환
  String _convertBirthTimeToHHmm(String? birthTime) {
    if (birthTime == null || birthTime.isEmpty) return '12:00';

    // 이미 HH:mm 형식인 경우
    final simpleTimeRegex = RegExp(r'^(\d{1,2}):(\d{2})$');
    if (simpleTimeRegex.hasMatch(birthTime)) {
      return birthTime;
    }

    // "축시 (01:00 - 03:00)" 형식에서 중간 시간 추출
    final rangeRegex = RegExp(r'(\d{1,2}):(\d{2})\s*-\s*(\d{1,2}):(\d{2})');
    final match = rangeRegex.firstMatch(birthTime);
    if (match != null) {
      final startHour = int.parse(match.group(1)!);
      final endHour = int.parse(match.group(3)!);
      final middleHour = ((startHour + endHour) / 2).floor();
      return '${middleHour.toString().padLeft(2, '0')}:00';
    }

    // 시간대 이름으로 매핑
    final timeMap = {
      '자시': '00:00', '축시': '02:00', '인시': '04:00', '묘시': '06:00',
      '진시': '08:00', '사시': '10:00', '오시': '12:00', '미시': '14:00',
      '신시': '16:00', '유시': '18:00', '술시': '20:00', '해시': '22:00',
    };

    for (final entry in timeMap.entries) {
      if (birthTime.contains(entry.key)) {
        return entry.value;
      }
    }

    return '12:00';
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
        onUserEarnedReward: (ad, reward) async {
          Logger.info('[Traditional-Saju] ✅ User earned reward: ${reward.amount} ${reward.type}');

          // ✅ 블러 해제 햅틱 (5단계 상승 패턴)
          await ref.read(fortuneHapticServiceProvider).premiumUnlock();

          // ✅ 게이지 증가 호출
          if (mounted) {
            FortuneCompletionHelper.onFortuneViewed(context, ref, 'saju');
          }

          if (mounted) {
            setState(() {
              _isBlurred = false;
              _blurredSections = [];
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

  // =========================================================================
  // 탭별 개념 설명 카드 포함 빌더
  // =========================================================================

  /// 1. 명식 탭 (개념 설명 카드 + 사주 테이블)
  Widget _buildMyungsikTab(Map<String, dynamic> sajuData) {
    final concept = SajuExplanations.tabConcepts['myungsik']!;
    return Column(
      children: [
        SajuConceptCard(
          title: concept['title']!,
          shortDescription: concept['short']!,
          fullDescription: concept['full']!,
          icon: Icons.grid_view_rounded,
          realLife: concept['realLife'],
          tips: concept['tips'],
        ),
        const SizedBox(height: DSSpacing.lg),
        SajuPillarTablePro(sajuData: sajuData),
      ],
    );
  }

  /// 2. 오행 탭 (개념 설명 카드 + 오행 차트)
  Widget _buildOhangTab(Map<String, dynamic> elementBalance) {
    final concept = SajuExplanations.tabConcepts['ohang']!;
    // dynamic을 int로 변환
    final intBalance = elementBalance.map(
      (key, value) => MapEntry(key, (value as num).toInt()),
    );
    return Column(
      children: [
        SajuConceptCard(
          title: concept['title']!,
          shortDescription: concept['short']!,
          fullDescription: concept['full']!,
          icon: Icons.donut_large_rounded,
          realLife: concept['realLife'],
          tips: concept['tips'],
        ),
        const SizedBox(height: DSSpacing.lg),
        SajuElementChart(
          elementBalance: intBalance,
          animationController: _resultAnimationController,
        ),
      ],
    );
  }

  /// 3. 지장간 탭 (개념 설명 카드 + 지장간 위젯)
  Widget _buildJijangganTab(Map<String, dynamic> sajuData) {
    final concept = SajuExplanations.tabConcepts['jijanggan']!;
    return Column(
      children: [
        SajuConceptCard(
          title: concept['title']!,
          shortDescription: concept['short']!,
          fullDescription: concept['full']!,
          icon: Icons.layers_rounded,
          realLife: concept['realLife'],
          tips: concept['tips'],
        ),
        const SizedBox(height: DSSpacing.lg),
        SajuJijangganWidget(sajuData: sajuData),
      ],
    );
  }

  /// 4. 12운성 탭 (개념 설명 카드 + 12운성 위젯)
  Widget _buildTwelveStagesTab(Map<String, dynamic> sajuData) {
    final concept = SajuExplanations.tabConcepts['twelve_fortune']!;
    return Column(
      children: [
        SajuConceptCard(
          title: concept['title']!,
          shortDescription: concept['short']!,
          fullDescription: concept['full']!,
          icon: Icons.loop_rounded,
          realLife: concept['realLife'],
          tips: concept['tips'],
        ),
        const SizedBox(height: DSSpacing.lg),
        SajuTwelveStagesWidget(sajuData: sajuData),
      ],
    );
  }

  /// 5. 신살 탭 (개념 설명 카드 + 신살 위젯)
  Widget _buildSinsalTab(Map<String, dynamic> sajuData) {
    final concept = SajuExplanations.tabConcepts['sinsal']!;
    return Column(
      children: [
        SajuConceptCard(
          title: concept['title']!,
          shortDescription: concept['short']!,
          fullDescription: concept['full']!,
          icon: Icons.stars_rounded,
          realLife: concept['realLife'],
          tips: concept['tips'],
        ),
        const SizedBox(height: DSSpacing.lg),
        SajuSinsalWidget(sajuData: sajuData),
      ],
    );
  }

  /// 6. 합충 탭 (개념 설명 카드 + 합충 위젯)
  Widget _buildHapchungTab(Map<String, dynamic> sajuData) {
    final concept = SajuExplanations.tabConcepts['hapchung']!;
    return Column(
      children: [
        SajuConceptCard(
          title: concept['title']!,
          shortDescription: concept['short']!,
          fullDescription: concept['full']!,
          icon: Icons.compare_arrows_rounded,
          realLife: concept['realLife'],
          tips: concept['tips'],
        ),
        const SizedBox(height: DSSpacing.lg),
        SajuHapchungWidget(sajuData: sajuData),
      ],
    );
  }
}