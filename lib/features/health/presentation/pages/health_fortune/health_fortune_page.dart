import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/widgets.dart';
import '../../widgets/body_part_selector.dart';
import '../../widgets/body_part_grid_selector.dart';
import '../../widgets/health_score_card.dart';
import '../../widgets/health_timeline_chart.dart';
import '../../../domain/models/health_fortune_model.dart';
import '../../../data/services/health_fortune_service.dart';
import '../../../../../core/theme/obangseok_colors.dart';
import '../../../../../core/widgets/unified_button.dart' show UnifiedButton, BottomButtonSpacing;
import '../../../../../core/widgets/unified_button_enums.dart';
import '../../../../../shared/components/toast.dart';
import '../../../../../presentation/providers/providers.dart';
import '../../../../../core/services/unified_fortune_service.dart';
import '../../../../../services/health_data_service.dart';

class HealthFortunePage extends ConsumerStatefulWidget {
  const HealthFortunePage({super.key});

  @override
  ConsumerState<HealthFortunePage> createState() => _HealthFortunePageState();
}

class _HealthFortunePageState extends ConsumerState<HealthFortunePage> {
  final PageController _pageController = PageController();
  final HealthFortuneService _healthService = HealthFortuneService();
  final HealthDataService _healthDataService = HealthDataService();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _healthService.setApiService(ref.read(fortuneServiceProvider));
  }

  int _currentStep = 1;
  bool _isLoading = false;
  bool _useGridSelector = true;

  // Input data
  ConditionState? _currentCondition;
  List<BodyPart> _selectedBodyParts = [];

  // Result data
  HealthFortuneResult? _fortuneResult;

  // Premium health data
  bool _isLoadingHealthData = false;
  HealthSummary? _healthSummary;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? ObangseokColors.hanjiBackgroundDark
          : ObangseokColors.hanjiBackground,
      appBar: _buildAppBar(isDark),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildConditionSelectionPage(isDark),
                      _buildBodyPartSelectionPage(),
                      _buildResultPage(),
                    ],
                  ),
                ),
              ],
            ),
            _buildFloatingButtons(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark
          ? ObangseokColors.hanjiBackgroundDark
          : ObangseokColors.hanjiBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(
          Icons.arrow_back_ios,
          color: ObangseokColors.getMeok(context),
          size: 20,
        ),
      ),
      title: Text(
        '건강운세',
        style: TextStyle(
          fontFamily: 'NanumMyeongjo',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ObangseokColors.getMeok(context),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildConditionSelectionPage(bool isDark) {
    final tokenState = ref.watch(tokenProvider);
    final isPremium = tokenState.hasUnlimitedAccess;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          Text(
            '오늘 몸 상태는\n어떠신가요?',
            style: TextStyle(
              fontFamily: 'NanumMyeongjo',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: ObangseokColors.getMeok(context),
              height: 1.3,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            '현재 컨디션을 선택해주세요',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: isDark
                  ? ObangseokColors.baekMuted
                  : ObangseokColors.meokFaded,
            ),
          ),

          const SizedBox(height: 24),

          HealthAppConnectionSection(
            isDark: isDark,
            isPremium: isPremium,
            isLoadingHealthData: _isLoadingHealthData,
            healthSummary: _healthSummary,
            onConnect: _connectHealthApp,
            onRefresh: _refreshHealthData,
          ),

          const SizedBox(height: 16),

          // 전문 진단 서류 업로드 섹션
          MedicalDocumentUploadSection(
            isDark: isDark,
            tokenCost: 3,
            onTap: _showDocumentUploadSheet,
          ),

          const SizedBox(height: 24),

          ...ConditionState.values.map((condition) {
            final index = ConditionState.values.indexOf(condition);
            return ConditionOption(
              condition: condition,
              index: index,
              isDark: isDark,
              isSelected: _currentCondition == condition,
              onTap: () {
                setState(() {
                  _currentCondition = condition;
                });
              },
            );
          }),

          const BottomButtonSpacing(),
        ],
      ),
    );
  }

  Future<void> _connectHealthApp() async {
    setState(() {
      _isLoadingHealthData = true;
    });

    try {
      final authorized = await _healthDataService.requestAuthorization();

      if (!authorized) {
        if (mounted) {
          Toast.warning(context, '건강앱 접근 권한이 필요합니다');
        }
        return;
      }

      final summary = await _healthDataService.getHealthSummary();

      if (mounted) {
        setState(() {
          _healthSummary = summary;
        });

        if (summary != null && summary.hasData) {
          Toast.success(context, '건강 데이터를 성공적으로 불러왔습니다');
        } else {
          Toast.info(context, '건강앱에 저장된 데이터가 없습니다');
        }
      }
    } catch (e) {
      if (mounted) {
        Toast.error(context, '건강 데이터를 불러오는 중 오류가 발생했습니다');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingHealthData = false;
        });
      }
    }
  }

  Future<void> _refreshHealthData() async {
    HapticFeedback.lightImpact();
    await _connectHealthApp();
  }

  void _showDocumentUploadSheet() {
    HapticFeedback.mediumImpact();
    DocumentUploadBottomSheet.show(
      context,
      onDocumentSelected: (result) {
        // 문서 분석 결과 페이지로 이동
        context.push('/medical-document-result', extra: result);
      },
    );
  }

  Widget _buildBodyPartSelectionPage() {
    return Column(
      children: [
        SelectorModeToggle(
          useGridSelector: _useGridSelector,
          onChanged: (useGrid) {
            setState(() {
              _useGridSelector = useGrid;
            });
          },
        ),

        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _useGridSelector
                ? BodyPartGridSelector(
                    key: const ValueKey('grid'),
                    selectedParts: _selectedBodyParts,
                    onSelectionChanged: (parts) {
                      setState(() {
                        _selectedBodyParts = parts;
                      });
                    },
                  )
                : BodyPartSelector(
                    key: const ValueKey('silhouette'),
                    selectedParts: _selectedBodyParts,
                    onSelectionChanged: (parts) {
                      setState(() {
                        _selectedBodyParts = parts;
                      });
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultPage() {
    if (_fortuneResult == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        children: [
          HealthScoreCard(
            score: _fortuneResult!.overallScore,
            mainMessage: _fortuneResult!.mainMessage,
          ),

          if (_selectedBodyParts.isNotEmpty) ...[
            BodyPartHealthSection(
              bodyPartHealthList: _fortuneResult!.bodyPartHealthList,
              selectedBodyParts: _selectedBodyParts,
              isDark: isDark,
            ),
            const SizedBox(height: 20),
          ],

          RecommendationsSection(
            recommendations: _fortuneResult!.recommendations,
            isDark: isDark,
          ),

          const SizedBox(height: 20),

          HealthTimelineChart(timeline: _fortuneResult!.timeline),

          const SizedBox(height: 20),

          AvoidanceSection(avoidanceList: _fortuneResult!.avoidanceList),

          const SizedBox(height: 20),

          if (_fortuneResult!.tomorrowPreview != null)
            TomorrowPreviewSection(tomorrowPreview: _fortuneResult!.tomorrowPreview!),

          const SizedBox(height: 40),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: UnifiedButton(
                    text: '결과 공유하기',
                    onPressed: _shareResult,
                    style: UnifiedButtonStyle.secondary,
                    icon: const Icon(Icons.share, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: UnifiedButton(
                    text: '다시 분석하기',
                    onPressed: _restartAnalysis,
                    icon: const Icon(Icons.refresh, size: 20),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _goToNextStep() {
    if (_currentStep < 2) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _generateHealthFortune() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _generateHealthFortuneInternal();
    } catch (e) {
      if (!mounted) return;
      Toast.error(context, '건강운세 생성 중 오류가 발생했습니다.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _shareResult() {
    Toast.info(context, '공유 기능은 준비 중입니다');
  }

  void _restartAnalysis() {
    setState(() {
      _currentStep = 1;
      _currentCondition = null;
      _selectedBodyParts.clear();
      _fortuneResult = null;
    });

    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _generateHealthFortuneInternal() async {
    final fortuneService = UnifiedFortuneService(Supabase.instance.client);

    final tokenState = ref.read(tokenProvider);
    final isPremium = tokenState.hasUnlimitedAccess;

    final inputConditions = <String, dynamic>{
      'current_condition': _currentCondition?.name ?? 'good',
      'concerned_body_parts': _selectedBodyParts.isNotEmpty
          ? _selectedBodyParts.map((part) => part.name).toList()
          : <String>[],
      'isPremium': isPremium,
    };

    if (isPremium && _healthSummary != null && _healthSummary!.hasData) {
      inputConditions['health_app_data'] = _healthSummary!.toJson();
    }

    final fortuneResult = await fortuneService.getFortune(
      fortuneType: 'health',
      dataSource: FortuneDataSource.api,
      inputConditions: inputConditions,
    );

    if (mounted) {
      context.push('/health-fortune-result', extra: fortuneResult);
    }
  }

  Widget _buildFloatingButtons() {
    if (_currentStep == 2) {
      return const SizedBox.shrink();
    }

    if (_currentStep == 0) {
      return UnifiedButton.floating(
        text: _currentCondition != null ? '다음 단계로' : '건너뛰기',
        onPressed: _goToNextStep,
        isEnabled: true,
      );
    }

    if (_currentStep == 1) {
      return UnifiedButton.floating(
        text: '건강 분석하기',
        onPressed: _generateHealthFortune,
        isEnabled: !_isLoading,
        isLoading: _isLoading,
        icon: _isLoading ? null : const Icon(Icons.auto_awesome_rounded, size: 20, color: Colors.white),
      );
    }

    return const SizedBox.shrink();
  }
}
