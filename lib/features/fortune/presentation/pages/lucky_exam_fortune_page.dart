import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../widgets/standard_fortune_app_bar.dart';
import '../widgets/standard_fortune_page_layout.dart';
import '../../../../core/components/app_card.dart';
import '../../../../presentation/providers/ad_provider.dart';
import '../../../../domain/entities/fortune.dart';
import 'dart:math' as math;
import '../../../../services/ad_service.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/models/fortune_result.dart';
import '../../../../core/utils/fortune_text_cleaner.dart';
import '../../../../core/widgets/unified_blur_wrapper.dart';
import '../../domain/models/conditions/lucky_exam_fortune_conditions.dart';
import '../../../../core/widgets/date_picker/numeric_date_input.dart';

import '../../../../core/widgets/unified_button.dart';
class LuckyExamFortunePage extends ConsumerStatefulWidget {
  const LuckyExamFortunePage({super.key});

  @override
  ConsumerState<LuckyExamFortunePage> createState() => _LuckyExamFortunePageState();
}

class _LuckyExamFortunePageState extends ConsumerState<LuckyExamFortunePage> {
  Fortune? _fortuneResult;
  bool _isLoading = false;

  // ✅ Blur 상태 관리
  bool _isBlurred = false;
  List<String> _blurredSections = [];

  // 리뉴얼된 입력 필드
  String _selectedCategory = ''; // 시험 카테고리
  String? _selectedSubType; // 세부 시험 종류
  String _examDate = ''; // 시험 날짜
  DateTime? _selectedExamDate; // 시험 날짜 DateTime
  String? _targetScore; // 목표 점수
  String _preparationStatus = '준비중'; // 준비 상태
  String _timePoint = 'preparation'; // 자동 계산됨

  // 기존 필드 (하위 호환)
  String _examType = ''; // deprecated
  String _studyPeriod = '1개월';
  String _confidence = '보통';
  String _difficulty = '보통';

  final List<String> _studyPeriods = ['1주일', '2주일', '1개월', '3개월', '6개월', '1년 이상'];
  final List<String> _confidenceLevels = ['매우 불안', '불안', '보통', '자신있음', '매우 자신있음'];
  final List<String> _difficultyLevels = ['매우 쉬움', '쉬움', '보통', '어려움', '매우 어려움'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.gray50,
      appBar: _fortuneResult != null
          ? AppBar(
              backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false, // 백버튼 제거
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                  ),
                  onPressed: () => context.pop(),
                ),
              ],
              title: Text(
                '시험 운세',
                style: TextStyle(
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            )
          : const StandardFortuneAppBar(
              title: '시험 운세',
            ),
      body: _fortuneResult != null
          ? _buildResultView(isDark)
          : _buildInputView(isDark),
    );
  }

  Future<void> _analyzeExam() async {
    // 유효성 검사
    if (_selectedCategory.isEmpty || _examDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('시험 카테고리와 예정일을 선택해주세요'),
          backgroundColor: TossDesignSystem.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final fortuneService = UnifiedFortuneService(Supabase.instance.client);

      // 시험 날짜 파싱
      final examDate = DateTime.tryParse(_examDate) ?? DateTime.now();

      // timePoint 자동 계산
      _timePoint = LuckyExamFortuneConditions.calculateTimePoint(examDate);

      // examType 설정 (하위 호환)
      _examType = _selectedSubType ?? _selectedCategory;

      // UnifiedFortuneService용 input_conditions 구성 (snake_case)
      final inputConditions = {
        'exam_type': _examType,
        'exam_category': _selectedCategory,
        if (_selectedSubType != null) 'exam_sub_type': _selectedSubType,
        'exam_date': _examDate,
        if (_targetScore != null && _targetScore!.isNotEmpty) 'target_score': _targetScore,
        'preparation_status': _preparationStatus,
        'time_point': _timePoint,
        // 기존 필드 (하위 호환)
        'study_period': _studyPeriod,
        'confidence': _confidence,
        'difficulty': _difficulty,
      };

      // Optimization conditions 생성
      final prepLevel = _confidenceLevels.indexOf(_confidence) + 1;
      final anxietyLevel = 6 - prepLevel; // 자신감과 반비례

      final conditions = LuckyExamFortuneConditions(
        examType: _examType,
        examDate: examDate,
        subject: null,
        preparationLevel: prepLevel,
        anxietyLevel: anxietyLevel,
        examCategory: _selectedCategory,
        examSubType: _selectedSubType,
        targetScore: _targetScore,
        preparationStatus: _preparationStatus,
        timePoint: _timePoint,
      );

      final fortuneResult = await fortuneService.getFortune(
        fortuneType: 'exam',
        dataSource: FortuneDataSource.api,
        inputConditions: inputConditions,
        conditions: conditions,
      );

      final fortune = _convertToFortune(fortuneResult);

      setState(() {
        _fortuneResult = fortune;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Generate mock data on error
      _generateMockResult();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('서버 연결 중 오류가 발생했습니다. 샘플 데이터를 표시합니다.'),
            backgroundColor: TossDesignSystem.warningOrange,
          ),
        );
      }
    }
  }

  void _generateMockResult() {
    // Generate mock fortune result for testing
    final random = math.Random();
    final overallScore = 70 + random.nextInt(25);
    
    setState(() {
      _fortuneResult = Fortune(
        id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'user',
        type: 'lucky-exam',
        content: _generateMockContent(overallScore),
        overallScore: overallScore,
        scoreBreakdown: {
          '합격 가능성': overallScore,
          '준비도': 65 + random.nextInt(30),
          '시험 당일 운': 60 + random.nextInt(35),
          '집중력': 70 + random.nextInt(25),
        },
        recommendations: _generateMockRecommendations(),
        luckyItems: {
          'color': ['파란색', '흰색'],
          'number': ['7', '3'],
          'item': ['샤프펜슬', '시계'],
          'food': ['초콜릿', '바나나'],
        },
        createdAt: DateTime.now(),
      );
      _isLoading = false;
    });
  }

  String _generateMockContent(int score) {
    if (score >= 85) {
      return '$_examType 시험에서 좋은 결과가 예상됩니다! 지금까지의 노력이 빛을 발할 때입니다. 자신감을 가지고 차분하게 준비하세요. 시험 당일 컨디션 관리가 중요합니다.';
    } else if (score >= 70) {
      return '$_examType 시험 준비가 순조롭게 진행되고 있습니다. 남은 기간 동안 약점 보완에 집중하면 좋은 결과를 얻을 수 있을 것입니다. 긍정적인 마음가짐을 유지하세요.';
    } else {
      return '$_examType 시험을 위해 조금 더 집중이 필요한 시기입니다. 기본기를 다시 한번 점검하고, 실전 연습을 늘려보세요. 포기하지 않는다면 충분히 좋은 결과를 얻을 수 있습니다.';
    }
  }

  List<String> _generateMockRecommendations() {
    return [
      '오전 시간을 활용한 집중 학습을 추천합니다',
      '시험 일주일 전부터는 새로운 내용보다 복습에 집중하세요',
      '충분한 수면과 규칙적인 생활 패턴을 유지하세요',
      '시험장에 일찍 도착하여 마음을 안정시키세요',
      '자신감을 갖되 겸손한 마음으로 임하세요',
    ];
  }

  Widget _buildInputView(bool isDark) {
    return StandardFortunePageLayout(
      buttonText: '운세 분석하기',
      onButtonPressed: () async {
        await AdService.instance.showInterstitialAdWithCallback(
          onAdCompleted: () async {
            _analyzeExam();
          },
          onAdFailed: () async {
            // Still allow fortune generation even if ad fails
            _analyzeExam();
          },
        );
      },
      isLoading: _isLoading,
      buttonIcon: const Icon(Icons.auto_awesome),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 카드
          _buildHeaderCard(isDark),

          const SizedBox(height: 32),

          // 🆕 시험 카테고리 선택
          _buildCategorySelection(isDark),

          const SizedBox(height: 24),

          // 🆕 시험 세부 정보
          _buildExamDetails(isDark),

          const SizedBox(height: 24),

          // 준비 상황 (기존 유지)
          _buildPreparationStatus(isDark),
        ],
      ),
    );
  }

  // 헤더 카드 (기존 유지)
  Widget _buildHeaderCard(bool isDark) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TossDesignSystem.successGreen,
                  TossDesignSystem.successGreen.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_rounded,
              color: TossDesignSystem.white,
              size: 40,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

          const SizedBox(height: 24),

          Text(
            '시험 운세 리뉴얼',
            style: TossDesignSystem.heading2.copyWith(
              color: isDark ? TossDesignSystem.textPrimaryDark : null,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          Text(
            '시험 종류를 선택하고\n맞춤형 합격 운세를 확인하세요!',
            style: TossDesignSystem.body2.copyWith(
              color: isDark
                  ? TossDesignSystem.textSecondaryDark
                  : TossDesignSystem.gray600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3);
  }

  // 🆕 시험 카테고리 선택
  Widget _buildCategorySelection(bool isDark) {
    final categories = LuckyExamFortuneConditions.getCategoryList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '시험 카테고리 선택',
          style: TossDesignSystem.body1.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? TossDesignSystem.textPrimaryDark : null,
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '어떤 시험을 준비하시나요?',
                style: TossDesignSystem.caption.copyWith(
                  color: isDark
                      ? TossDesignSystem.textSecondaryDark
                      : TossDesignSystem.gray600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                        _selectedSubType = null; // 카테고리 변경 시 초기화
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? TossDesignSystem.tossBlue
                            : (isDark
                                ? TossDesignSystem.cardBackgroundDark
                                : TossDesignSystem.gray100),
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected
                            ? Border.all(
                                color: TossDesignSystem.tossBlue, width: 2)
                            : null,
                      ),
                      child: Text(
                        category,
                        style: TossDesignSystem.caption.copyWith(
                          color: isSelected
                              ? TossDesignSystem.white
                              : (isDark
                                  ? TossDesignSystem.textPrimaryDark
                                  : TossDesignSystem.gray700),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // 세부 시험 선택 (카테고리 선택 시 표시)
              if (_selectedCategory.isNotEmpty) ...[
                const SizedBox(height: 20),
                Divider(
                    color: isDark
                        ? TossDesignSystem.gray700
                        : TossDesignSystem.gray300),
                const SizedBox(height: 16),
                Text(
                  '세부 시험 선택',
                  style: TossDesignSystem.caption.copyWith(
                    color: isDark
                        ? TossDesignSystem.textSecondaryDark
                        : TossDesignSystem.gray600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: LuckyExamFortuneConditions.getSubTypeList(
                          _selectedCategory)
                      .map((subType) {
                    final isSelected = _selectedSubType == subType;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSubType = subType;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? TossDesignSystem.successGreen
                              : (isDark
                                  ? TossDesignSystem.cardBackgroundDark
                                  : TossDesignSystem.gray100),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          subType,
                          style: TossDesignSystem.caption.copyWith(
                            color: isSelected
                                ? TossDesignSystem.white
                                : (isDark
                                    ? TossDesignSystem.textPrimaryDark
                                    : TossDesignSystem.gray700),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.3),
      ],
    );
  }

  // 🆕 시험 세부 정보
  Widget _buildExamDetails(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '시험 정보',
          style: TossDesignSystem.body1.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? TossDesignSystem.textPrimaryDark : null,
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 시험 예정일
              NumericDateInput(
                label: '시험 예정일',
                selectedDate: _selectedExamDate,
                onDateChanged: (date) {
                  setState(() {
                    _selectedExamDate = date;
                    _examDate = date.toIso8601String().split('T')[0];
                  });
                },
                minDate: DateTime(1900),
                maxDate: DateTime(2300),
              ),

              const SizedBox(height: 20),

              // 🆕 목표 점수/등급 (선택사항)
              Text(
                '목표 점수/등급 (선택사항)',
                style: TossDesignSystem.caption.copyWith(
                  color: isDark
                      ? TossDesignSystem.textSecondaryDark
                      : TossDesignSystem.gray600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                onChanged: (value) => _targetScore = value,
                decoration: InputDecoration(
                  hintText: '예: 1등급, 900점, 70점 이상',
                  hintStyle: TossDesignSystem.body2.copyWith(
                    color: TossDesignSystem.gray400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: isDark
                            ? TossDesignSystem.gray600
                            : TossDesignSystem.gray300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: TossDesignSystem.tossBlue),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🆕 준비 상태
              Text(
                '현재 준비 상태',
                style: TossDesignSystem.caption.copyWith(
                  color: isDark
                      ? TossDesignSystem.textSecondaryDark
                      : TossDesignSystem.gray600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: LuckyExamFortuneConditions.preparationStatusOptions
                    .map((status) {
                  final isSelected = _preparationStatus == status;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _preparationStatus = status;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? TossDesignSystem.warningOrange
                            : (isDark
                                ? TossDesignSystem.cardBackgroundDark
                                : TossDesignSystem.gray100),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TossDesignSystem.caption.copyWith(
                          color: isSelected
                              ? TossDesignSystem.white
                              : (isDark
                                  ? TossDesignSystem.textPrimaryDark
                                  : TossDesignSystem.gray700),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3),
      ],
    );
  }

  // 준비 상황 (기존 유지 - 하위 호환)
  Widget _buildPreparationStatus(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '추가 정보 (선택사항)',
          style: TossDesignSystem.body1.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? TossDesignSystem.textPrimaryDark : null,
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 공부 기간
              Text(
                '공부 기간',
                style: TossDesignSystem.caption.copyWith(
                  color: isDark
                      ? TossDesignSystem.textSecondaryDark
                      : TossDesignSystem.gray600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _studyPeriods.map((period) {
                  final isSelected = _studyPeriod == period;
                  return GestureDetector(
                    onTap: () => setState(() => _studyPeriod = period),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? TossDesignSystem.tossBlue.withValues(alpha: 0.2)
                            : (isDark
                                ? TossDesignSystem.cardBackgroundDark
                                : TossDesignSystem.gray100),
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(color: TossDesignSystem.tossBlue)
                            : null,
                      ),
                      child: Text(
                        period,
                        style: TossDesignSystem.caption.copyWith(
                          color: isSelected
                              ? TossDesignSystem.tossBlue
                              : (isDark
                                  ? TossDesignSystem.textPrimaryDark
                                  : TossDesignSystem.gray700),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // 자신감
              Text(
                '자신감',
                style: TossDesignSystem.caption.copyWith(
                  color: isDark
                      ? TossDesignSystem.textSecondaryDark
                      : TossDesignSystem.gray600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _confidenceLevels.map((level) {
                  final isSelected = _confidence == level;
                  return GestureDetector(
                    onTap: () => setState(() => _confidence = level),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? TossDesignSystem.successGreen
                                .withValues(alpha: 0.2)
                            : (isDark
                                ? TossDesignSystem.cardBackgroundDark
                                : TossDesignSystem.gray100),
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(color: TossDesignSystem.successGreen)
                            : null,
                      ),
                      child: Text(
                        level,
                        style: TossDesignSystem.caption.copyWith(
                          color: isSelected
                              ? TossDesignSystem.successGreen
                              : (isDark
                                  ? TossDesignSystem.textPrimaryDark
                                  : TossDesignSystem.gray700),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // 난이도
              Text(
                '예상 난이도',
                style: TossDesignSystem.caption.copyWith(
                  color: isDark
                      ? TossDesignSystem.textSecondaryDark
                      : TossDesignSystem.gray600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _difficultyLevels.map((level) {
                  final isSelected = _difficulty == level;
                  return GestureDetector(
                    onTap: () => setState(() => _difficulty = level),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? TossDesignSystem.warningOrange
                                .withValues(alpha: 0.2)
                            : (isDark
                                ? TossDesignSystem.cardBackgroundDark
                                : TossDesignSystem.gray100),
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(color: TossDesignSystem.warningOrange)
                            : null,
                      ),
                      child: Text(
                        level,
                        style: TossDesignSystem.caption.copyWith(
                          color: isSelected
                              ? TossDesignSystem.warningOrange
                              : (isDark
                                  ? TossDesignSystem.textPrimaryDark
                                  : TossDesignSystem.gray700),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3),
      ],
    );
  }

  // ✅ Phase 15-5: 광고 보고 블러 제거 로직
  Future<void> _showAdAndUnblur() async {
    final adService = ref.read(adServiceProvider);

    await adService.showRewardedAdWithCallback(
      onUserEarnedReward: () {
        setState(() {
          _isBlurred = false;
          _blurredSections = [];
        });
      },
      onAdNotReady: () {
        // 광고가 준비되지 않은 경우 - 로딩 시도 후 안내
        if (mounted) {
          // 광고 다시 로드 시도
          adService.loadRewardedAd();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('광고를 불러오는 중입니다. 잠시 후 다시 시도해주세요.'),
              backgroundColor: TossDesignSystem.warningOrange,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: '무료로 보기',
                textColor: TossDesignSystem.white,
                onPressed: () {
                  setState(() {
                    _isBlurred = false;
                    _blurredSections = [];
                  });
                },
              ),
            ),
          );
        }
      },
      onAdFailedToShow: () {
        // 광고 표시 실패 시 무료로 전체 보기 허용
        if (mounted) {
          setState(() {
            _isBlurred = false;
            _blurredSections = [];
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('광고 로드에 실패했습니다. 전체 내용을 확인하세요.'),
              backgroundColor: TossDesignSystem.successGreen,
            ),
          );
        }
      },
    );
  }

  // ✅ Phase 15-5: 블러 처리 헬퍼 (UnifiedBlurWrapper로 대체)
  // _buildBlurWrapper 제거됨


  Widget _buildResultView(bool isDark) {
    if (_fortuneResult == null) return const SizedBox.shrink();

    final fortune = _fortuneResult!;
    final score = fortune.overallScore ?? 75;
    final data = fortune.metadata ?? {};

    // ✅ Phase 15-4: result.isBlurred 동기화
    if (_isBlurred != fortune.isBlurred || _blurredSections.length != fortune.blurredSections.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isBlurred = fortune.isBlurred;
            _blurredSections = List<String>.from(fortune.blurredSections);
          });
        }
      });
    }

    // ✅ 수정: Stack을 바깥에 두고 SingleChildScrollView와 버튼을 형제 관계로 배치
    // ✅ fit: StackFit.expand 추가 - 전체 화면을 채워서 버튼이 하단에 고정되도록 함
    return Stack(
      fit: StackFit.expand,
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, _isBlurred ? 120 : 40), // 블러 버튼 공간 확보
          child: Column(
            children: [
          // 메인 결과 카드
          AppCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // 점수 시각화
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(150, 150),
                        painter: CircularScorePainter(
                          score: score,
                          gradientColors: [
                            TossDesignSystem.successGreen,
                            TossDesignSystem.tossBlue,
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$score',
                            style: TossDesignSystem.heading1.copyWith(
                              fontWeight: FontWeight.bold,
                              color: TossDesignSystem.successGreen,
                            ),
                          ),
                          Text(
                            data['exam_keyword'] as String? ?? '합격',
                            style: TossDesignSystem.caption.copyWith(
                              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.gray600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                const SizedBox(height: 24),

                Text(
                  data['title'] as String? ?? _examType,
                  style: TossDesignSystem.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? TossDesignSystem.textPrimaryDark : null,
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TossDesignSystem.successGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    FortuneTextCleaner.clean(data['overall_fortune'] as String? ?? fortune.content),
                    style: TossDesignSystem.body2.copyWith(
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),

          const SizedBox(height: 20),

          // 합격 가능성
          if (data['pass_possibility'] != null && data['pass_possibility'] is String && data['pass_possibility'] != '🔒 프리미엄 결제 후 확인 가능합니다') ...[
            UnifiedBlurWrapper(
              isBlurred: _isBlurred,
              blurredSections: _blurredSections,
              sectionKey: 'pass_possibility',
              child: AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: TossDesignSystem.successGreen, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          '합격 가능성',
                          style: TossDesignSystem.body1.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? TossDesignSystem.textPrimaryDark : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      FortuneTextCleaner.clean(data['pass_possibility'] as String),
                      style: TossDesignSystem.body2.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.3),
            const SizedBox(height: 20),
          ],

          // 집중 과목
          if (data['focus_subject'] != null && data['focus_subject'] is String && data['focus_subject'] != '🔒 프리미엄 결제 후 확인 가능합니다') ...[
            UnifiedBlurWrapper(
              isBlurred: _isBlurred,
              blurredSections: _blurredSections,
              sectionKey: 'focus_subject',
              child: AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.school, color: TossDesignSystem.tossBlue, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          '집중 과목/영역',
                          style: TossDesignSystem.body1.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? TossDesignSystem.textPrimaryDark : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      FortuneTextCleaner.clean(data['focus_subject'] as String),
                      style: TossDesignSystem.body2.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.3),
            const SizedBox(height: 20),
          ],

          // 추천 학습법
          if (data['study_methods'] != null && data['study_methods'] is List && (data['study_methods'] as List).isNotEmpty && (data['study_methods'] as List).first != '🔒 프리미엄 결제 후 확인 가능합니다') ...[
            UnifiedBlurWrapper(
              isBlurred: _isBlurred,
              blurredSections: _blurredSections,
              sectionKey: 'study_methods',
              child: AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_stories, color: TossDesignSystem.warningOrange, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          '추천 학습법',
                          style: TossDesignSystem.body1.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? TossDesignSystem.textPrimaryDark : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...(data['study_methods'] as List).map((method) =>
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(top: 8, right: 12),
                              decoration: BoxDecoration(
                                color: TossDesignSystem.warningOrange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                FortuneTextCleaner.clean(method as String),
                                style: TossDesignSystem.body2.copyWith(height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3),
            const SizedBox(height: 20),
          ],

          // 주의사항
          if (data['cautions'] != null && data['cautions'] is List && (data['cautions'] as List).isNotEmpty && (data['cautions'] as List).first != '🔒 프리미엄 결제 후 확인 가능합니다') ...[
            UnifiedBlurWrapper(
              isBlurred: _isBlurred,
              blurredSections: _blurredSections,
              sectionKey: 'cautions',
              child: AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber, color: TossDesignSystem.errorRed, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          '주의사항',
                          style: TossDesignSystem.body1.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? TossDesignSystem.textPrimaryDark : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...(data['cautions'] as List).map((caution) =>
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(top: 8, right: 12),
                              decoration: BoxDecoration(
                                color: TossDesignSystem.errorRed,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                FortuneTextCleaner.clean(caution as String),
                                style: TossDesignSystem.body2.copyWith(height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.3),
            const SizedBox(height: 20),
          ],

          // 🆕 디데이 조언
          if (data['dday_advice'] != null && data['dday_advice'] is String && data['dday_advice'] != '🔒 프리미엄 결제 후 확인 가능합니다') ...[
            UnifiedBlurWrapper(
              isBlurred: _isBlurred,
              blurredSections: _blurredSections,
              sectionKey: 'dday_advice',
              child: AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: TossDesignSystem.tossBlue, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          '시험 당일 조언',
                          style: TossDesignSystem.body1.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? TossDesignSystem.textPrimaryDark : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      FortuneTextCleaner.clean(data['dday_advice'] as String),
                      style: TossDesignSystem.body2.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ).animate(delay: 275.ms).fadeIn().slideY(begin: 0.3),
            const SizedBox(height: 20),
          ],

          // 🆕 행운의 시간
          if (data['lucky_hours'] != null && data['lucky_hours'] is String && data['lucky_hours'] != '🔒 프리미엄 결제 후 확인 가능합니다') ...[
            UnifiedBlurWrapper(
              isBlurred: _isBlurred,
              blurredSections: _blurredSections,
              sectionKey: 'lucky_hours',
              child: AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time, color: TossDesignSystem.warningOrange, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          '행운의 시간',
                          style: TossDesignSystem.body1.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? TossDesignSystem.textPrimaryDark : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      FortuneTextCleaner.clean(data['lucky_hours'] as String),
                      style: TossDesignSystem.body2.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3),
            const SizedBox(height: 20),
          ],

          // 🆕 당신의 강점
          if (data['strengths'] != null && data['strengths'] is List && (data['strengths'] as List).isNotEmpty && (data['strengths'] as List).first != '🔒 프리미엄 결제 후 확인 가능합니다') ...[
            UnifiedBlurWrapper(
              isBlurred: _isBlurred,
              blurredSections: _blurredSections,
              sectionKey: 'strengths',
              child: AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.stars, color: TossDesignSystem.successGreen, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          '당신의 강점',
                          style: TossDesignSystem.body1.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? TossDesignSystem.textPrimaryDark : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (data['strengths'] as List).map((strength) =>
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: TossDesignSystem.successGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: TossDesignSystem.successGreen.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            FortuneTextCleaner.clean(strength as String),
                            style: TossDesignSystem.caption.copyWith(
                              color: TossDesignSystem.successGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ).toList(),
                    ),
                  ],
                ),
              ),
            ).animate(delay: 325.ms).fadeIn().slideY(begin: 0.3),
            const SizedBox(height: 20),
          ],

          // 🆕 응원 메시지
          if (data['positive_message'] != null && data['positive_message'] is String && data['positive_message'] != '🔒 프리미엄 결제 후 확인 가능합니다') ...[
            UnifiedBlurWrapper(
              isBlurred: _isBlurred,
              blurredSections: _blurredSections,
              sectionKey: 'positive_message',
              child: AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.favorite, color: TossDesignSystem.errorRed, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          '응원 메시지',
                          style: TossDesignSystem.body1.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? TossDesignSystem.textPrimaryDark : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                            TossDesignSystem.successGreen.withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        FortuneTextCleaner.clean(data['positive_message'] as String),
                        style: TossDesignSystem.body2.copyWith(
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.3),
            const SizedBox(height: 20),
          ],

          // 세부 점수 (기존 코드 유지 - scoreBreakdown이 있는 경우)
          if (fortune.scoreBreakdown != null) ...[
            UnifiedBlurWrapper(
              isBlurred: _isBlurred,
              blurredSections: _blurredSections,
              sectionKey: 'score_breakdown',
              child: AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.analytics, 
                        color: TossDesignSystem.tossBlue, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '세부 분석',
                        style: TossDesignSystem.body1.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? TossDesignSystem.textPrimaryDark : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  ...fortune.scoreBreakdown!.entries.map((entry) => 
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: TossDesignSystem.body2.copyWith(
                                  color: TossDesignSystem.gray700,
                                ),
                              ),
                              Text(
                                '${entry.value}점',
                                style: TossDesignSystem.body2.copyWith(
                                  color: TossDesignSystem.tossBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: entry.value / 100,
                            backgroundColor: TossDesignSystem.gray200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getScoreColor(entry.value),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.3),

            const SizedBox(height: 20),
          ],

          // 추천 사항
          if (fortune.recommendations != null && fortune.recommendations!.isNotEmpty) ...[
            UnifiedBlurWrapper(
              isBlurred: _isBlurred,
              blurredSections: _blurredSections,
              sectionKey: 'recommendations',
              child: AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates, 
                        color: TossDesignSystem.warningOrange, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '합격 전략',
                        style: TossDesignSystem.body1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  ...fortune.recommendations!.map((rec) => 
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 8, right: 12),
                            decoration: BoxDecoration(
                              color: TossDesignSystem.warningOrange,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              rec,
                              style: TossDesignSystem.body2.copyWith(
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3),

            const SizedBox(height: 20),
          ],

          // 행운 아이템
          if (fortune.luckyItems != null && fortune.luckyItems!.isNotEmpty) ...[
            UnifiedBlurWrapper(
              isBlurred: _isBlurred,
              blurredSections: _blurredSections,
              sectionKey: 'lucky_items',
              child: AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, 
                        color: TossDesignSystem.warningOrange, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '행운 아이템',
                        style: TossDesignSystem.body1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      if (fortune.luckyItems!['color'] != null)
                        ...fortune.luckyItems!['color']!.map((color) => 
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: TossDesignSystem.warningOrange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: TossDesignSystem.warningOrange.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.palette, size: 16, color: TossDesignSystem.warningOrange),
                                const SizedBox(width: 4),
                                Text(
                                  color,
                                  style: TossDesignSystem.caption.copyWith(
                                    color: TossDesignSystem.warningOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).toList(),
                      if (fortune.luckyItems!['number'] != null)
                        ...fortune.luckyItems!['number']!.map((number) => 
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: TossDesignSystem.tossBlue.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.tag, size: 16, color: TossDesignSystem.tossBlue),
                                const SizedBox(width: 4),
                                Text(
                                  number,
                                  style: TossDesignSystem.caption.copyWith(
                                    color: TossDesignSystem.tossBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).toList(),
                    ],
                  ),
                ],
              ),
            ),
          ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3),
          ],

          const SizedBox(height: 40),
            ],
          ),
        ),  // SingleChildScrollView 닫기

        // ✅ Phase 15-7: 광고 보고 전체보기 버튼 (Stack 바로 아래 배치)
        if (_isBlurred)
          UnifiedButton.floating(
            text: '광고 보고 전체 내용 확인하기',
            onPressed: _showAdAndUnblur,
            isEnabled: true,
          ),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return TossDesignSystem.successGreen;
    if (score >= 60) return TossDesignSystem.tossBlue;
    if (score >= 40) return TossDesignSystem.warningOrange;
    return TossDesignSystem.errorRed;
  }
}

// Custom Painter for Circular Score
class CircularScorePainter extends CustomPainter {
  final int score;
  final List<Color> gradientColors;

  CircularScorePainter({
    required this.score,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = TossDesignSystem.gray200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawCircle(center, radius - 6, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: gradientColors,
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + (2 * math.pi * score / 100),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      -math.pi / 2,
      2 * math.pi * score / 100,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

extension on _LuckyExamFortunePageState {
  /// FortuneResult를 Fortune 엔티티로 변환
  Fortune _convertToFortune(FortuneResult fortuneResult) {
    final data = fortuneResult.data;

    return Fortune(
      id: fortuneResult.id ?? '',
      userId: Supabase.instance.client.auth.currentUser?.id ?? '',
      type: fortuneResult.type,
      content: data['overall_fortune'] as String? ?? data['content'] as String? ?? '',
      createdAt: fortuneResult.createdAt ?? DateTime.now(),
      overallScore: fortuneResult.score ?? data['score'] as int? ?? 75,
      summary: data['overall_fortune'] as String?,
      metadata: data,
      isBlurred: fortuneResult.isBlurred,
      blurredSections: fortuneResult.blurredSections,
    );
  }
}