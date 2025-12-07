import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

import '../../../../../core/theme/toss_design_system.dart';
import '../../../../../core/components/app_card.dart';
import '../../../../../core/utils/fortune_text_cleaner.dart';
import '../../../../../core/utils/subscription_snackbar.dart';
import '../../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../../core/widgets/unified_button.dart';
import '../../../../../core/services/unified_fortune_service.dart';
import '../../../../../core/models/fortune_result.dart';
import '../../../../../presentation/providers/ad_provider.dart';
import '../../../../../presentation/providers/token_provider.dart';
import '../../../../../domain/entities/fortune.dart';
import '../../../../../services/ad_service.dart';
import '../../widgets/standard_fortune_app_bar.dart';
import '../../widgets/standard_fortune_page_layout.dart';
import '../../../domain/models/conditions/lucky_exam_fortune_conditions.dart';

import 'widgets/exam_header_card.dart';
import 'widgets/exam_category_selection.dart';
import 'widgets/exam_details_card.dart';
import 'widgets/exam_preparation_status.dart';
import 'widgets/circular_score_painter.dart';
import 'widgets/exam_result_sections.dart';

class LuckyExamFortunePage extends ConsumerStatefulWidget {
  const LuckyExamFortunePage({super.key});

  @override
  ConsumerState<LuckyExamFortunePage> createState() => _LuckyExamFortunePageState();
}

class _LuckyExamFortunePageState extends ConsumerState<LuckyExamFortunePage> {
  Fortune? _fortuneResult;
  bool _isLoading = false;

  // Blur 상태 관리
  bool _isBlurred = false;
  List<String> _blurredSections = [];

  // 리뉴얼된 입력 필드
  String _selectedCategory = '';
  String? _selectedSubType;
  String _examDate = '';
  DateTime? _selectedExamDate;
  String? _targetScore;
  String _preparationStatus = '준비중';
  String _timePoint = 'preparation';

  // 기존 필드 (하위 호환)
  String _examType = '';
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
              automaticallyImplyLeading: false,
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
      final examDate = DateTime.tryParse(_examDate) ?? DateTime.now();
      _timePoint = LuckyExamFortuneConditions.calculateTimePoint(examDate);
      _examType = _selectedSubType ?? _selectedCategory;

      final inputConditions = {
        'exam_type': _examType,
        'exam_category': _selectedCategory,
        if (_selectedSubType != null) 'exam_sub_type': _selectedSubType,
        'exam_date': _examDate,
        if (_targetScore != null && _targetScore!.isNotEmpty) 'target_score': _targetScore,
        'preparation_status': _preparationStatus,
        'time_point': _timePoint,
        'study_period': _studyPeriod,
        'confidence': _confidence,
        'difficulty': _difficulty,
      };

      final prepLevel = _confidenceLevels.indexOf(_confidence) + 1;
      final anxietyLevel = 6 - prepLevel;

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
            _analyzeExam();
          },
        );
      },
      isLoading: _isLoading,
      buttonIcon: const Icon(Icons.auto_awesome),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ExamHeaderCard(),
          const SizedBox(height: 32),
          ExamCategorySelection(
            selectedCategory: _selectedCategory,
            selectedSubType: _selectedSubType,
            onCategoryChanged: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
            onSubTypeChanged: (subType) {
              setState(() {
                _selectedSubType = subType;
              });
            },
          ),
          const SizedBox(height: 24),
          ExamDetailsCard(
            selectedExamDate: _selectedExamDate,
            targetScore: _targetScore,
            preparationStatus: _preparationStatus,
            onDateChanged: (date) {
              setState(() {
                _selectedExamDate = date;
                _examDate = date.toIso8601String().split('T')[0];
              });
            },
            onTargetScoreChanged: (score) {
              setState(() {
                _targetScore = score;
              });
            },
            onPreparationStatusChanged: (status) {
              setState(() {
                _preparationStatus = status;
              });
            },
          ),
          const SizedBox(height: 24),
          ExamPreparationStatus(
            studyPeriod: _studyPeriod,
            confidence: _confidence,
            difficulty: _difficulty,
            studyPeriods: _studyPeriods,
            confidenceLevels: _confidenceLevels,
            difficultyLevels: _difficultyLevels,
            onStudyPeriodChanged: (period) {
              setState(() {
                _studyPeriod = period;
              });
            },
            onConfidenceChanged: (level) {
              setState(() {
                _confidence = level;
              });
            },
            onDifficultyChanged: (level) {
              setState(() {
                _difficulty = level;
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showAdAndUnblur() async {
    final adService = ref.read(adServiceProvider);

    await adService.showRewardedAdWithCallback(
      onUserEarnedReward: () {
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
      },
      onAdNotReady: () {
        if (mounted) {
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

  Widget _buildResultView(bool isDark) {
    if (_fortuneResult == null) return const SizedBox.shrink();

    final fortune = _fortuneResult!;
    final score = fortune.overallScore ?? 75;
    final data = fortune.metadata ?? {};

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

    return Stack(
      fit: StackFit.expand,
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, _isBlurred ? 120 : 40),
          child: Column(
            children: [
              _buildMainResultCard(fortune, score, data, isDark),
              const SizedBox(height: 20),
              ..._buildResultSections(data, isDark),
              ..._buildScoreBreakdown(fortune, isDark),
              ..._buildRecommendations(fortune, isDark),
              ..._buildLuckyItems(fortune, isDark),
              const SizedBox(height: 40),
            ],
          ),
        ),
        if (_isBlurred)
          UnifiedButton.floating(
            text: '광고 보고 전체 내용 확인하기',
            onPressed: _showAdAndUnblur,
            isEnabled: true,
          ),
      ],
    );
  }

  Widget _buildMainResultCard(Fortune fortune, int score, Map<String, dynamic> data, bool isDark) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
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
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3);
  }

  List<Widget> _buildResultSections(Map<String, dynamic> data, bool isDark) {
    final sections = <Widget>[];

    if (_shouldShowSection(data['pass_possibility'])) {
      sections.add(PassPossibilitySection(
        passPossibility: data['pass_possibility'] as String,
        isBlurred: _isBlurred,
        blurredSections: _blurredSections,
      ));
      sections.add(const SizedBox(height: 20));
    }

    if (_shouldShowSection(data['focus_subject'])) {
      sections.add(FocusSubjectSection(
        focusSubject: data['focus_subject'] as String,
        isBlurred: _isBlurred,
        blurredSections: _blurredSections,
      ));
      sections.add(const SizedBox(height: 20));
    }

    if (_shouldShowListSection(data['study_methods'])) {
      sections.add(StudyMethodsSection(
        studyMethods: List<String>.from(data['study_methods'] as List),
        isBlurred: _isBlurred,
        blurredSections: _blurredSections,
      ));
      sections.add(const SizedBox(height: 20));
    }

    if (_shouldShowListSection(data['cautions'])) {
      sections.add(CautionsSection(
        cautions: List<String>.from(data['cautions'] as List),
        isBlurred: _isBlurred,
        blurredSections: _blurredSections,
      ));
      sections.add(const SizedBox(height: 20));
    }

    if (_shouldShowSection(data['dday_advice'])) {
      sections.add(DdayAdviceSection(
        ddayAdvice: data['dday_advice'] as String,
        isBlurred: _isBlurred,
        blurredSections: _blurredSections,
      ));
      sections.add(const SizedBox(height: 20));
    }

    if (_shouldShowSection(data['lucky_hours'])) {
      sections.add(LuckyHoursSection(
        luckyHours: data['lucky_hours'] as String,
        isBlurred: _isBlurred,
        blurredSections: _blurredSections,
      ));
      sections.add(const SizedBox(height: 20));
    }

    if (_shouldShowListSection(data['strengths'])) {
      sections.add(StrengthsSection(
        strengths: List<String>.from(data['strengths'] as List),
        isBlurred: _isBlurred,
        blurredSections: _blurredSections,
      ));
      sections.add(const SizedBox(height: 20));
    }

    if (_shouldShowSection(data['positive_message'])) {
      sections.add(PositiveMessageSection(
        positiveMessage: data['positive_message'] as String,
        isBlurred: _isBlurred,
        blurredSections: _blurredSections,
      ));
      sections.add(const SizedBox(height: 20));
    }

    return sections;
  }

  bool _shouldShowSection(dynamic value) {
    return value != null && value is String && value != '🔒 프리미엄 결제 후 확인 가능합니다';
  }

  bool _shouldShowListSection(dynamic value) {
    return value != null &&
           value is List &&
           value.isNotEmpty &&
           value.first != '🔒 프리미엄 결제 후 확인 가능합니다';
  }

  List<Widget> _buildScoreBreakdown(Fortune fortune, bool isDark) {
    if (fortune.scoreBreakdown == null) return [];

    return [
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
                  Icon(Icons.analytics, color: TossDesignSystem.tossBlue, size: 24),
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
    ];
  }

  List<Widget> _buildRecommendations(Fortune fortune, bool isDark) {
    if (fortune.recommendations == null || fortune.recommendations!.isEmpty) return [];

    return [
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
                  Icon(Icons.tips_and_updates, color: TossDesignSystem.warningOrange, size: 24),
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
    ];
  }

  List<Widget> _buildLuckyItems(Fortune fortune, bool isDark) {
    if (fortune.luckyItems == null || fortune.luckyItems!.isEmpty) return [];

    return [
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
                  Icon(Icons.star, color: TossDesignSystem.warningOrange, size: 24),
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
    ];
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return TossDesignSystem.successGreen;
    if (score >= 60) return TossDesignSystem.tossBlue;
    if (score >= 40) return TossDesignSystem.warningOrange;
    return TossDesignSystem.errorRed;
  }

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
