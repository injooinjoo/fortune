import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../shared/components/toss_floating_progress_button.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/models/fortune_result.dart';
import '../../domain/models/conditions/compatibility_fortune_conditions.dart';
import '../../../../core/widgets/unified_date_picker.dart';
import '../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../shared/components/floating_bottom_button.dart';
import '../../../../services/ad_service.dart';

class CompatibilityPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialParams;
  
  const CompatibilityPage({
    super.key,
    this.initialParams,
  });

  @override
  ConsumerState<CompatibilityPage> createState() => _CompatibilityPageState();
}

class _CompatibilityPageState extends ConsumerState<CompatibilityPage> {
  final _formKey = GlobalKey<FormState>();
  final _person1NameController = TextEditingController();
  final _person2NameController = TextEditingController();
  DateTime? _person1BirthDate;
  DateTime? _person2BirthDate;

  Map<String, dynamic>? _compatibilityData;
  bool _isLoading = false;

  // ✅ 블러 상태 관리 (로컬)
  bool _isBlurred = false;
  List<String> _blurredSections = [];

  @override
  void initState() {
    super.initState();

    // 사용자 프로필 정보로 미리 채우기
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProfileAsync = ref.read(userProfileProvider);
      userProfileAsync.when(
        data: (userProfile) {
          if (userProfile != null) {
            setState(() {
              _person1NameController.text = userProfile.name ?? '';
              _person1BirthDate = userProfile.birthDate;
            });
          }
        },
        loading: () {},
        error: (_, __) {},
      );
    });
  }

  @override
  void dispose() {
    _person1NameController.dispose();
    _person2NameController.dispose();
    super.dispose();
  }

  Future<void> _analyzeCompatibility() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('이름을 입력해주세요'),
          backgroundColor: TossTheme.warning,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (_person1BirthDate == null || _person2BirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('생년월일을 선택해주세요'),
          backgroundColor: TossTheme.warning,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // ✅ InterstitialAd 제거: 바로 API 호출
    await _performCompatibilityAnalysis();
  }

  Future<void> _performCompatibilityAnalysis() async {
    try {
      // ⚠️ 궁합 테스트용: Debug Premium 무시, 실제 토큰만 체크
      final tokenState = ref.read(tokenProvider);
      final realPremium = (tokenState.balance?.remainingTokens ?? 0) > 0;
      final isPremium = realPremium;  // Debug Premium 무시

      debugPrint('💎 [CompatibilityPage] Premium 상태: $isPremium (real: $realPremium)');

      // UnifiedFortuneService 사용
      final fortuneService = UnifiedFortuneService(Supabase.instance.client);

      // input_conditions 정규화
      final inputConditions = {
        'person1': {
          'name': _person1NameController.text,
          'birth_date': _person1BirthDate!.toIso8601String(),
        },
        'person2': {
          'name': _person2NameController.text,
          'birth_date': _person2BirthDate!.toIso8601String(),
        },
        'isPremium': isPremium, // ✅ isPremium 추가
      };

      // Optimization conditions 생성
      final conditions = CompatibilityFortuneConditions(
        person1Name: _person1NameController.text,
        person1BirthDate: _person1BirthDate!,
        person2Name: _person2NameController.text,
        person2BirthDate: _person2BirthDate!,
      );

      final fortuneResult = await fortuneService.getFortune(
        fortuneType: 'compatibility',
        dataSource: FortuneDataSource.api,
        inputConditions: inputConditions,
        conditions: conditions,
      );

      // FortuneResult → Fortune 엔티티 변환 (블러 로직 포함)
      final fortune = _convertToFortune(fortuneResult, isPremium);

      debugPrint('📊 [CompatibilityPage] Fortune 변환 완료');
      debugPrint('  ├─ isBlurred: ${fortune.isBlurred}');
      debugPrint('  ├─ blurredSections: ${fortune.blurredSections}');
      debugPrint('  ├─ content 길이: ${fortune.content.length}자');
      debugPrint('  ├─ content 미리보기: ${fortune.content.substring(0, fortune.content.length > 50 ? 50 : fortune.content.length)}...');
      debugPrint('  ├─ advice 길이: ${fortune.advice?.length ?? 0}자');
      debugPrint('  └─ metadata keys: ${fortune.metadata?.keys.toList()}');

      // Parse scores from fortune response
      Map<String, double> scores = {};

      // Extract overall score
      double overallScore = (fortune.overallScore ?? 75) / 100.0;
      scores['전체 궁합'] = overallScore;

      // Parse detailed scores from fortune content or metadata
      if (fortune.metadata != null && fortune.metadata!['scores'] != null) {
        final detailedScores = fortune.metadata!['scores'] as Map<String, dynamic>;
        scores['사랑 궁합'] = (detailedScores['love'] ?? 80) / 100.0;
        scores['결혼 궁합'] = (detailedScores['marriage'] ?? 75) / 100.0;
        scores['일상 궁합'] = (detailedScores['daily'] ?? 70) / 100.0;
        scores['소통 궁합'] = (detailedScores['communication'] ?? 78) / 100.0;
      } else {
        // Calculate based on overall score with slight variations
        scores['사랑 궁합'] = (overallScore + 0.05).clamp(0.0, 1.0);
        scores['결혼 궁합'] = (overallScore - 0.03).clamp(0.0, 1.0);
        scores['일상 궁합'] = (overallScore - 0.07).clamp(0.0, 1.0);
        scores['소통 궁합'] = overallScore;
      }

      setState(() {
        _compatibilityData = {
          'fortune': fortune,
          'scores': scores,
        };
        _isLoading = false;
        // ✅ 로컬 블러 상태 설정
        _isBlurred = fortune.isBlurred;
        _blurredSections = fortune.blurredSections;
      });

      debugPrint('🔐 [CompatibilityPage] 로컬 블러 상태 설정');
      debugPrint('  ├─ _isBlurred: $_isBlurred');
      debugPrint('  └─ _blurredSections: $_blurredSections');

      HapticFeedback.mediumImpact();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        String errorMessage = '궁합 분석 중 오류가 발생했습니다';
        if (e.toString().contains('404')) {
          errorMessage = '궁합 분석 서비스를 사용할 수 없습니다';
        } else if (e.toString().contains('network')) {
          errorMessage = '네트워크 연결을 확인해주세요';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: TossTheme.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isResultView = _compatibilityData != null;

    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossTheme.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        // ✅ 결과 페이지에서는 뒤로가기 버튼 숨김
        leading: isResultView ? const SizedBox.shrink() : IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '궁합 분석',
          style: TextStyle(
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        // ✅ 결과 페이지에서만 X 버튼 표시
        actions: isResultView ? [
          IconButton(
            icon: Icon(
              Icons.close,
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            ),
            onPressed: () => context.pop(),
          ),
        ] : null,
      ),
      body: isResultView ? _buildResultView() : _buildInputView(),
    );
  }

  Widget _buildInputView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더 카드
                TossCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFEC4899),
                              Color(0xFF8B5CF6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEC4899).withValues(alpha:0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: TossDesignSystem.white,
                          size: 36,
                        ),
                      ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                      SizedBox(height: 24),

                      Text(
                        '두 사람의 궁합',
                        style: TossTheme.heading2.copyWith(
                          color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 12),

                      Text(
                        '이름과 생년월일을 입력하면\n두 사람의 궁합을 자세히 분석해드릴게요',
                        style: TossTheme.body2.copyWith(
                          color: isDark ? TossDesignSystem.grayDark400 : TossTheme.textGray600,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),

                const SizedBox(height: 24),

                // 첫 번째 사람 정보 - 컴팩트 스타일
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: TossTheme.primaryBlue.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person,
                            size: 14,
                            color: TossTheme.primaryBlue,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '나',
                            style: TossTheme.caption.copyWith(
                              color: TossTheme.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                TossCard(
                  padding: const EdgeInsets.all(16),
                  style: TossCardStyle.outlined,
                  child: Column(
                    children: [
                      TextField(
                        controller: _person1NameController,
                        decoration: InputDecoration(
                          labelText: '이름',
                          hintText: '이름을 입력해주세요',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: TossTheme.borderGray300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: TossTheme.primaryBlue,
                              width: 1.5,
                            ),
                          ),
                        ),
                        style: TossTheme.body2.copyWith(
                          color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                        ),
                      ),

                      const SizedBox(height: 12),

                      UnifiedDatePicker(
                        mode: UnifiedDatePickerMode.numeric,
                        selectedDate: _person1BirthDate,
                        onDateChanged: (date) {
                          setState(() {
                            _person1BirthDate = date;
                          });
                          HapticFeedback.mediumImpact();
                        },
                        label: '생년월일',
                        minDate: DateTime(1900),
                        maxDate: DateTime.now(),
                        showAge: false,
                      ),
                    ],
                  ),
                ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.3),

                const SizedBox(height: 20),

                // 두 번째 사람 정보 - 강조된 스타일
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFEC4899),
                            Color(0xFF8B5CF6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.favorite,
                            size: 16,
                            color: TossDesignSystem.white,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '상대방',
                            style: TossTheme.body2.copyWith(
                              color: TossDesignSystem.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                TossCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: _person2NameController,
                        decoration: InputDecoration(
                          labelText: '이름',
                          hintText: '상대방 이름을 입력해주세요',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? TossDesignSystem.grayDark400 : TossTheme.borderGray300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: TossTheme.primaryBlue,
                            ),
                          ),
                        ),
                        style: TossTheme.body1.copyWith(
                          color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                        ),
                      ),

                      const SizedBox(height: 16),

                      UnifiedDatePicker(
                        mode: UnifiedDatePickerMode.numeric,
                        selectedDate: _person2BirthDate,
                        onDateChanged: (date) {
                          setState(() {
                            _person2BirthDate = date;
                          });
                          HapticFeedback.mediumImpact();
                        },
                        label: '상대방 생년월일',
                        minDate: DateTime(1900),
                        maxDate: DateTime.now(),
                        showAge: false,
                      ),
                    ],
                  ),
                ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3),

                SizedBox(height: 16),

                Center(
                  child: Text(
                    '분석 결과는 참고용으로만 활용해 주세요',
                    style: TossTheme.caption.copyWith(
                      color: isDark ? TossDesignSystem.grayDark400 : TossTheme.textGray600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),

        // Floating 버튼 - 조건 미달성 시 숨김
        TossFloatingProgressButtonPositioned(
          text: '궁합 분석하기',
          onPressed: _canAnalyze() ? _analyzeCompatibility : null,
          isEnabled: _canAnalyze(),
          isVisible: _canAnalyze(),
          showProgress: false,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  bool _canAnalyze() {
    return _person1NameController.text.isNotEmpty &&
           _person2NameController.text.isNotEmpty &&
           _person1BirthDate != null &&
           _person2BirthDate != null;
  }

  Widget _buildResultView() {
    final fortune = _compatibilityData!['fortune'] as Fortune;
    final scores = _compatibilityData!['scores'] as Map<String, double>;
    final overallScore = scores['전체 궁합'] ?? 0.85;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
          // 전체 궁합 점수
          TossCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_person1NameController.text} ❤️ ${_person2NameController.text}',
                      style: TossTheme.heading3.copyWith(
                        color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (fortune.metadata?['name_compatibility'] != null) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '이름 ${fortune.metadata!['name_compatibility']}%',
                          style: TossTheme.caption.copyWith(
                            color: const Color(0xFFF59E0B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 24),

                CircularPercentIndicator(
                  radius: 80.0,
                  lineWidth: 12.0,
                  percent: overallScore,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(overallScore * 100).round()}점',
                        style: TossTheme.heading1.copyWith(
                          color: _getScoreColor(overallScore),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        _getScoreText(overallScore),
                        style: TossTheme.caption.copyWith(
                          color: isDark ? TossDesignSystem.grayDark400 : TossTheme.textGray600,
                        ),
                      ),
                    ],
                  ),
                  progressColor: _getScoreColor(overallScore),
                  backgroundColor: isDark ? TossDesignSystem.grayDark600 : TossTheme.borderGray200,
                  circularStrokeCap: CircularStrokeCap.round,
                  animation: true,
                  animationDuration: 1200,
                ),
                
                SizedBox(height: 16),
                
                Text(
                  fortune.summary ?? '궁합 분석 결과',
                  style: TossTheme.body1.copyWith(
                    color: _getScoreColor(overallScore),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.3),

          const SizedBox(height: 24),

          // 세부 궁합 점수 (블러 처리)
          UnifiedBlurWrapper(
            isBlurred: _isBlurred,
            blurredSections: _blurredSections,
            sectionKey: 'detailed_scores',
            child: TossCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: TossTheme.primaryBlue.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.analytics,
                          color: TossTheme.primaryBlue,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '세부 궁합 분석',
                        style: TossTheme.heading4.copyWith(
                          color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  ...scores.entries.where((e) => e.key != '전체 궁합').map((entry) {
                    final index = scores.keys.toList().indexOf(entry.key);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: TossTheme.body2.copyWith(
                                  color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${(entry.value * 100).round()}점',
                                style: TossTheme.body2.copyWith(
                                  color: _getScoreColor(entry.value),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: entry.value,
                            backgroundColor: isDark ? TossDesignSystem.grayDark600 : TossTheme.borderGray200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getScoreColor(entry.value),
                            ),
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ],
                      ).animate(delay: (index * 100).ms)
                       .fadeIn(duration: 600.ms)
                       .slideX(begin: 0.3),
                    );
                  }),
                ],
              ),
            ),
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3),

          const SizedBox(height: 16),

          // 🆕 전통 궁합 (띠 + 별자리)
          if (fortune.metadata?['zodiac_animal'] != null || fortune.metadata?['star_sign'] != null)
            TossCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.brightness_5,
                          color: Color(0xFF8B5CF6),
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '전통 궁합',
                        style: TossTheme.heading4.copyWith(
                          color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // 띠 궁합
                  if (fortune.metadata?['zodiac_animal'] != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '띠 궁합',
                                style: TossTheme.caption.copyWith(
                                  color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${fortune.metadata!['zodiac_animal']['person1']} × ${fortune.metadata!['zodiac_animal']['person2']}',
                                style: TossTheme.body2.copyWith(
                                  color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getScoreColor(fortune.metadata!['zodiac_animal']['score'] / 100).withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${fortune.metadata!['zodiac_animal']['score']}점',
                            style: TossTheme.caption.copyWith(
                              color: _getScoreColor(fortune.metadata!['zodiac_animal']['score'] / 100),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      fortune.metadata!['zodiac_animal']['message'],
                      style: TossTheme.body2.copyWith(
                        color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                        height: 1.5,
                      ),
                    ),
                  ],

                  // 별자리 궁합
                  if (fortune.metadata?['star_sign'] != null) ...[
                    SizedBox(height: 16),
                    Divider(color: isDark ? TossDesignSystem.grayDark600 : TossTheme.borderGray200),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '별자리 궁합',
                                style: TossTheme.caption.copyWith(
                                  color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${fortune.metadata!['star_sign']['person1']} × ${fortune.metadata!['star_sign']['person2']}',
                                style: TossTheme.body2.copyWith(
                                  color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getScoreColor(fortune.metadata!['star_sign']['score'] / 100).withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${fortune.metadata!['star_sign']['score']}점',
                            style: TossTheme.caption.copyWith(
                              color: _getScoreColor(fortune.metadata!['star_sign']['score'] / 100),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      fortune.metadata!['star_sign']['message'],
                      style: TossTheme.body2.copyWith(
                        color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3),

          const SizedBox(height: 16),

          // 🆕 숫자 궁합 (이름 + 운명수)
          if (fortune.metadata?['name_compatibility'] != null || fortune.metadata?['destiny_number'] != null)
            TossCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.calculate,
                          color: Color(0xFFF59E0B),
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '숫자 궁합',
                        style: TossTheme.heading4.copyWith(
                          color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // 이름 궁합
                  if (fortune.metadata?['name_compatibility'] != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '이름 궁합',
                              style: TossTheme.caption.copyWith(
                                color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${_person1NameController.text} ♥ ${_person2NameController.text}',
                              style: TossTheme.body2.copyWith(
                                color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${fortune.metadata!['name_compatibility']}%',
                            style: TossTheme.heading4.copyWith(
                              color: const Color(0xFFF59E0B),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // 운명수
                  if (fortune.metadata?['destiny_number'] != null) ...[
                    SizedBox(height: 16),
                    Divider(color: isDark ? TossDesignSystem.grayDark600 : TossTheme.borderGray200),
                    SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '두 사람의 운명수',
                          style: TossTheme.caption.copyWith(
                            color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(alpha:0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${fortune.metadata!['destiny_number']['number']}',
                                  style: TossTheme.heading3.copyWith(
                                    color: const Color(0xFFF59E0B),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                fortune.metadata!['destiny_number']['meaning'],
                                style: TossTheme.body2.copyWith(
                                  color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.3),

          const SizedBox(height: 16),

          // 🆕 감성 궁합 (계절 + 나이차)
          if (fortune.metadata?['season'] != null || fortune.metadata?['age_difference'] != null)
            TossCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF06B6D4).withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.spa,
                          color: Color(0xFF06B6D4),
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '감성 궁합',
                        style: TossTheme.heading4.copyWith(
                          color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // 계절 궁합
                  if (fortune.metadata?['season'] != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '계절 궁합',
                              style: TossTheme.caption.copyWith(
                                color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${fortune.metadata!['season']['person1']} × ${fortune.metadata!['season']['person2']}',
                              style: TossTheme.body2.copyWith(
                                color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      fortune.metadata!['season']['message'],
                      style: TossTheme.body2.copyWith(
                        color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                        height: 1.5,
                      ),
                    ),
                  ],

                  // 나이차 분석
                  if (fortune.metadata?['age_difference'] != null) ...[
                    SizedBox(height: 16),
                    Divider(color: isDark ? TossDesignSystem.grayDark600 : TossTheme.borderGray200),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '나이 차이',
                              style: TossTheme.caption.copyWith(
                                color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              fortune.metadata!['age_difference']['years'] == 0
                                ? '동갑'
                                : '${fortune.metadata!['age_difference']['years'].abs()}살 차이',
                              style: TossTheme.body2.copyWith(
                                color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      fortune.metadata!['age_difference']['message'],
                      style: TossTheme.body2.copyWith(
                        color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.3),

          const SizedBox(height: 16),

          // 궁합 분석 결과 (블러 처리)
          UnifiedBlurWrapper(
            isBlurred: _isBlurred,
            blurredSections: _blurredSections,
            sectionKey: 'analysis',
            child: TossCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEC4899).withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.psychology,
                          color: Color(0xFFEC4899),
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '궁합 분석 결과',
                        style: TossTheme.heading4.copyWith(
                          color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  Text(
                    fortune.content,
                    style: TossTheme.body2.copyWith(
                      color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ).animate(delay: 450.ms).fadeIn().slideY(begin: 0.3),

          if (fortune.advice?.isNotEmpty == true) ...[
            const SizedBox(height: 16),

            // 관계 개선 조언 (블러 처리)
            UnifiedBlurWrapper(
              isBlurred: _isBlurred,
              blurredSections: _blurredSections,
              sectionKey: 'advice',
              child: TossCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: TossTheme.success.withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.lightbulb,
                            color: TossTheme.success,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          '관계 개선 조언',
                          style: TossTheme.heading4.copyWith(
                            color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    Text(
                      fortune.advice!,
                      style: TossTheme.body2.copyWith(
                        color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.3),
            ],

            const SizedBox(height: 120), // 버튼 공간 확보
          ],
        ),
      ),

        // ✅ 블러 해제 버튼 (블러 상태일 때만 표시)
        if (_isBlurred)
          FloatingBottomButton(
            text: '🎁 광고 보고 전체 내용 보기',
            onPressed: _showAdAndUnblur,
            isEnabled: true,
          ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 0.9) return const Color(0xFF10B981); // 매우 좋음 - 초록
    if (score >= 0.8) return const Color(0xFF3B82F6); // 좋음 - 파랑
    if (score >= 0.7) return const Color(0xFFF59E0B); // 보통 - 노랑
    if (score >= 0.6) return const Color(0xFFEF4444); // 나쁨 - 빨강
    return TossTheme.textGray600; // 매우 나쁨 - 회색
  }

  /// 광고 시청 후 블러 해제
  Future<void> _showAdAndUnblur() async {
    debugPrint('');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🎁 [광고] 블러 해제 프로세스 시작');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('');

    try {
      final adService = AdService();

      debugPrint('1️⃣ 광고 준비 상태 확인');
      debugPrint('   - 광고 준비 상태: ${adService.isRewardedAdReady}');

      if (!adService.isRewardedAdReady) {
        debugPrint('   ⚠️ 광고가 아직 준비되지 않음');
        debugPrint('   → 광고 로드 시작...');
        await adService.loadRewardedAd();
        debugPrint('   ✅ 광고 로드 완료');
      } else {
        debugPrint('   ✅ 광고가 이미 준비됨');
      }

      debugPrint('');
      debugPrint('2️⃣ 리워드 광고 표시');
      debugPrint('   - 현재 블러 상태: isBlurred=$_isBlurred');
      debugPrint('   - 블러된 섹션: $_blurredSections');
      debugPrint('   - 광고 준비 상태: ${adService.isRewardedAdReady}');
      debugPrint('   → 광고 표시 중...');

      // 리워드 광고 표시 및 완료 대기
      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) {
          debugPrint('');
          debugPrint('3️⃣ 광고 시청 완료!');
          debugPrint('   - reward.type: ${reward.type}');
          debugPrint('   - reward.amount: ${reward.amount}');

          // ✅ 광고 시청 완료 시 블러만 해제 (로컬 상태 변경)
          if (mounted) {
            debugPrint('   → 블러 해제 중...');

            setState(() {
              _isBlurred = false;
              _blurredSections = [];
            });

            debugPrint('   ✅ 블러 해제 완료!');
            debugPrint('      - 새 상태: _isBlurred=false');
            debugPrint('      - 새 상태: _blurredSections=[]');

            // 성공 메시지 표시
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('궁합 운세가 잠금 해제되었습니다!')),
            );

            debugPrint('');
            debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            debugPrint('✅ [광고] 블러 해제 프로세스 완료!');
            debugPrint('   → 사용자는 이제 전체 운세 내용을 볼 수 있습니다');
            debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            debugPrint('');
          } else {
            debugPrint('   ⚠️ Widget이 이미 dispose됨. 블러 해제 취소.');
          }
        },
      );
    } catch (e) {
      debugPrint('');
      debugPrint('❌ [광고] 에러 발생: $e');
      debugPrint('   → 사용자 경험 우선: 블러 해제 진행');

      // 에러 발생 시에도 블러 해제 (사용자 경험 우선)
      if (mounted) {
        setState(() {
          _isBlurred = false;
          _blurredSections = [];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('광고 표시에 실패했지만 운세를 확인할 수 있습니다.'),
          ),
        );

        debugPrint('   ✅ 블러 해제 완료 (에러 처리)');
      }
      debugPrint('');
    }
  }

  String _getScoreText(double score) {
    if (score >= 0.9) return '매우 좋음';
    if (score >= 0.8) return '좋음';
    if (score >= 0.7) return '보통';
    if (score >= 0.6) return '나쁨';
    return '매우 나쁨';
  }

  /// FortuneResult를 Fortune 엔티티로 변환 (블러 로직 포함)
  Fortune _convertToFortune(FortuneResult result, bool isPremium) {
    // ✅ 블러 처리 로직
    final isBlurred = !isPremium;
    final blurredSections = isBlurred
        ? ['detailed_scores', 'analysis', 'advice']  // 세부 궁합, 분석 결과, 조언 블러
        : <String>[];

    debugPrint('🔒 [CompatibilityPage] isBlurred: $isBlurred, blurredSections: $blurredSections');

    return Fortune(
      id: result.id ?? '',
      userId: ref.read(userProvider).value?.id ?? '',
      type: result.type,
      content: result.data['content'] as String? ?? result.summary.toString(),
      createdAt: DateTime.now(),
      overallScore: result.score,
      summary: result.summary['message'] as String?,
      metadata: result.data,
      isBlurred: isBlurred,  // ✅ 블러 상태
      blurredSections: blurredSections,  // ✅ 블러 섹션
    );
  }
}