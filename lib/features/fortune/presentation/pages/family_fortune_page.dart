import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../core/components/app_card.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/unified_button_enums.dart';
import '../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../presentation/providers/ad_provider.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../presentation/providers/subscription_provider.dart';
import '../../../../core/utils/subscription_snackbar.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/models/fortune_result.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/utils/logger.dart';
import '../widgets/standard_fortune_app_bar.dart';
import '../widgets/fortune_loading_skeleton.dart';
import '../../domain/models/conditions/family_fortune_conditions.dart';
import '../../../../core/services/fortune_haptic_service.dart';

// 5가지 가족 운세 관심사
enum FamilyConcern {
  health('건강운', '가족의 안녕과 건강', Icons.favorite, [Color(0xFFEF4444), Color(0xFFDC2626)]),
  wealth('재물운', '경제적 안정과 성장', Icons.account_balance_wallet, [Color(0xFF10B981), Color(0xFF059669)]),
  children('자녀운', '자녀의 미래와 성공', Icons.child_care, [Color(0xFFF59E0B), Color(0xFFEAB308)]),
  relationship('관계운', '가족 화목과 조화', Icons.groups, [Color(0xFF6366F1), Color(0xFF4F46E5)]),
  change('변화운', '이사, 변화 대응', Icons.change_circle, [Color(0xFF8B5CF6), Color(0xFF7C3AED)]);

  final String label;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;

  const FamilyConcern(this.label, this.description, this.icon, this.gradientColors);
}

// 관심사별 세부 질문
final Map<FamilyConcern, List<Map<String, String>>> concernQuestions = {
  FamilyConcern.health: [
    {'id': 'family_health', 'label': '가족 건강 전반'},
    {'id': 'elderly_health', 'label': '어르신 건강'},
    {'id': 'children_health', 'label': '자녀 건강'},
    {'id': 'pregnancy', 'label': '임신/출산'},
    {'id': 'surgery', 'label': '수술/치료'},
  ],
  FamilyConcern.wealth: [
    {'id': 'income', 'label': '소득 증대'},
    {'id': 'investment', 'label': '재테크/투자'},
    {'id': 'debt', 'label': '빚/대출 문제'},
    {'id': 'property', 'label': '부동산/자산'},
    {'id': 'business', 'label': '사업/창업'},
  ],
  FamilyConcern.children: [
    {'id': 'education', 'label': '학업/성적'},
    {'id': 'exam', 'label': '입시/시험'},
    {'id': 'career', 'label': '진로/적성'},
    {'id': 'marriage', 'label': '결혼/인연'},
    {'id': 'character', 'label': '성격/품성'},
  ],
  FamilyConcern.relationship: [
    {'id': 'couple', 'label': '부부 관계'},
    {'id': 'parent_child', 'label': '부모-자녀'},
    {'id': 'siblings', 'label': '형제자매'},
    {'id': 'in_laws', 'label': '시댁/친정'},
    {'id': 'conflict', 'label': '갈등 해결'},
  ],
  FamilyConcern.change: [
    {'id': 'moving', 'label': '이사/이주'},
    {'id': 'job_change', 'label': '직장 변화'},
    {'id': 'family_change', 'label': '가족 구성 변화'},
    {'id': 'lifestyle', 'label': '생활 방식 변화'},
    {'id': 'timing', 'label': '변화 시기'},
  ],
};

class FamilyFortuneUnifiedPage extends ConsumerStatefulWidget {
  const FamilyFortuneUnifiedPage({super.key});

  @override
  ConsumerState<FamilyFortuneUnifiedPage> createState() => _FamilyFortuneUnifiedPageState();
}

class _FamilyFortuneUnifiedPageState extends ConsumerState<FamilyFortuneUnifiedPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1: 주요 관심사
  FamilyConcern? _selectedConcern;

  // Step 2: 세부 질문 (다중 선택)
  final Set<String> _selectedQuestions = {};

  // Step 3: 가족 구성원 정보
  int _familyMemberCount = 1;
  String _relationship = 'self'; // self, parent, child, spouse

  // Step 4: 특별히 궁금한 점 (선택)
  final TextEditingController _questionController = TextEditingController();

  // ✅ 화면 상태 관리
  bool _showResult = false;  // 결과 화면 전환 여부
  bool _isLoading = false;   // 스켈레톤 표시 여부
  FortuneResult? _fortuneResult;  // Fortune → FortuneResult

  @override
  void dispose() {
    _pageController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: const StandardFortuneAppBar(
        title: '가족',
      ),
      body: _showResult
          ? (_isLoading ? _buildLoadingSkeleton() : _buildResultScreen())
          : _buildInputScreen(),
    );
  }

  /// 스켈레톤 로딩 화면
  Widget _buildLoadingSkeleton() {
    return FortuneLoadingSkeleton(
      itemCount: 3,
      showHeader: true,
      loadingMessages: const [
        '가족 운세를 분석하고 있어요...',
        '사주 데이터를 확인하고 있어요...',
        '맞춤 조언을 준비하고 있어요...',
      ],
    );
  }

  Widget _buildInputScreen() {
    return Stack(
      children: [
        PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: [
            _buildStep1ConcernSelection(),
            _buildStep2DetailedQuestions(),
            _buildStep3FamilyInfo(),
            _buildStep4SpecialQuestion(),
          ],
        ),
        _buildBottomButton(),
      ],
    );
  }


  // Step 1: 주요 관심사 선택
  Widget _buildStep1ConcernSelection() {
    final colors = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '가장 궁금한\n가족 운세를 선택해주세요',
            style: context.displaySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            '가족의 행복과 안녕을 위한 맞춤 운세를 제공해드려요',
            style: context.labelLarge.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: DSSpacing.xxl),

          ...FamilyConcern.values.map((concern) {
            final isSelected = _selectedConcern == concern;
            return Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.md),
              child: GestureDetector(
                onTap: () => setState(() => _selectedConcern = concern),
                child: Container(
                  padding: const EdgeInsets.all(DSSpacing.lg),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? concern.gradientColors[0].withValues(alpha: 0.05)
                        : colors.surface,
                    border: Border.all(
                      color: isSelected
                          ? concern.gradientColors[0]
                          : colors.border,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(DSRadius.md),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: concern.gradientColors[0].withValues(alpha: isSelected ? 1.0 : 0.1),
                          borderRadius: BorderRadius.circular(DSRadius.md),
                        ),
                        child: Icon(
                          concern.icon,
                          color: isSelected ? Colors.white : concern.gradientColors[0],
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: DSSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              concern.label,
                              style: context.labelLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: DSSpacing.xs),
                            Text(
                              concern.description,
                              style: context.labelSmall.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: concern.gradientColors[0],
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 100),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.1);
  }

  // Step 2: 세부 질문 선택 (다중 선택)
  Widget _buildStep2DetailedQuestions() {
    if (_selectedConcern == null) return const SizedBox.shrink();

    final colors = context.colors;
    final questions = concernQuestions[_selectedConcern]!;
    final concernColor = _selectedConcern!.gradientColors[0];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: concernColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_selectedConcern!.icon, color: concernColor, size: 22),
              ),
              const SizedBox(width: DSSpacing.md),
              Expanded(
                child: Text(
                  '${_selectedConcern!.label}에서\n궁금한 점을 선택해주세요',
                  style: context.heading3.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            '최대 3개까지 선택할 수 있어요',
            style: context.labelLarge.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: DSSpacing.xxl),

          ...questions.map((question) {
            final questionId = question['id']!;
            final isSelected = _selectedQuestions.contains(questionId);
            final canSelect = _selectedQuestions.length < 3 || isSelected;

            return Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.md),
              child: GestureDetector(
                onTap: canSelect
                    ? () {
                        setState(() {
                          if (isSelected) {
                            _selectedQuestions.remove(questionId);
                          } else {
                            _selectedQuestions.add(questionId);
                          }
                        });
                      }
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? concernColor.withValues(alpha: 0.05)
                        : colors.surface,
                    border: Border.all(
                      color: isSelected
                          ? concernColor
                          : colors.border,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(DSRadius.md),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isSelected ? concernColor : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? concernColor : colors.textTertiary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : null,
                      ),
                      const SizedBox(width: DSSpacing.md),
                      Expanded(
                        child: Text(
                          question['label']!,
                          style: context.labelLarge.copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: canSelect
                                ? colors.textPrimary
                                : colors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 100),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.1);
  }

  // Step 3: 가족 구성원 정보
  Widget _buildStep3FamilyInfo() {
    final colors = context.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '가족 구성원에 대해\n알려주세요',
            style: context.displaySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            '더 정확한 운세를 위한 정보예요',
            style: context.labelLarge.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: DSSpacing.xxl),

          // 가족 구성원 수
          AppCard(
            padding: const EdgeInsets.all(DSSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '함께 사는 가족 구성원',
                  style: context.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: DSSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.border),
                    borderRadius: BorderRadius.circular(DSRadius.md),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, color: colors.accent),
                        onPressed: () {
                          if (_familyMemberCount > 1) setState(() => _familyMemberCount--);
                        },
                      ),
                      Expanded(
                        child: Text(
                          '$_familyMemberCount명',
                          style: context.labelLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: colors.accent),
                        onPressed: () {
                          if (_familyMemberCount < 10) setState(() => _familyMemberCount++);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.md),

          // 나와의 관계
          AppCard(
            padding: const EdgeInsets.all(DSSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '운세를 보고 싶은 대상',
                  style: context.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: DSSpacing.md),
                ...[
                  {'value': 'self', 'label': '나 자신', 'icon': Icons.person},
                  {'value': 'parent', 'label': '부모님', 'icon': Icons.elderly},
                  {'value': 'child', 'label': '자녀', 'icon': Icons.child_care},
                  {'value': 'spouse', 'label': '배우자', 'icon': Icons.favorite},
                ].map((rel) {
                  final isSelected = _relationship == rel['value'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: DSSpacing.sm),
                    child: GestureDetector(
                      onTap: () => setState(() => _relationship = rel['value'] as String),
                      child: Container(
                        padding: const EdgeInsets.all(DSSpacing.md),
                        decoration: BoxDecoration(
                          color: isSelected ? colors.accent.withValues(alpha: 0.1) : null,
                          border: Border.all(
                            color: isSelected
                                ? colors.accent
                                : colors.border,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(DSRadius.md),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              rel['icon'] as IconData,
                              color: isSelected
                                  ? colors.accent
                                  : colors.textSecondary,
                            ),
                            const SizedBox(width: DSSpacing.md),
                            Text(
                              rel['label'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? colors.accent
                                    : colors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: colors.accent,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.1);
  }

  // Step 4: 특별히 궁금한 점 (선택사항)
  Widget _buildStep4SpecialQuestion() {
    final colors = context.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '특별히 궁금한 점이\n있으신가요?',
            style: context.displaySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            '선택사항이에요. 운세에 반영해드릴게요',
            style: context.labelLarge.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: DSSpacing.xxl),

          AppCard(
            padding: const EdgeInsets.all(DSSpacing.lg),
            child: TextField(
              controller: _questionController,
              style: TextStyle(
                color: colors.textPrimary,
              ),
              maxLines: 6,
              decoration: InputDecoration(
                hintText: '예: 올해 가족 여행 가기 좋은 시기는 언제인가요?\n예: 아이 학원을 바꾸려고 하는데 괜찮을까요?',
                hintStyle: context.labelSmall.copyWith(
                  color: colors.textTertiary,
                ),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: DSSpacing.md),

          Container(
            padding: const EdgeInsets.all(DSSpacing.md),
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(DSRadius.md),
              border: Border.all(
                color: colors.accent.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: colors.accent,
                  size: 20,
                ),
                const SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Text(
                    '질문을 남기지 않아도 운세를 볼 수 있어요',
                    style: context.labelSmall.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.1);
  }

  Widget _buildBottomButton() {
    String buttonText;
    if (_currentStep == 3) {
      buttonText = '가족 운세 보기';
    } else {
      buttonText = '다음';
    }

    return UnifiedButton.progress(
      text: buttonText,
      currentStep: _currentStep + 1,
      totalSteps: 4,
      onPressed: _canProceed() ? _handleNext : null,
      isEnabled: _canProceed(),
      isFloating: true,
      // ✅ 버튼 로딩 제거 - 스켈레톤으로 대체
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedConcern != null;
      case 1:
        return _selectedQuestions.isNotEmpty;
      case 2:
        return true; // Family info is always valid
      case 3:
        return true; // Special question is optional
      default:
        return false;
    }
  }

  void _handleNext() async {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      await _generateFortune();
    }
  }

  Future<void> _generateFortune() async {
    // 1. 결과 화면 전환 + 스켈레톤 시작
    setState(() {
      _showResult = true;
      _isLoading = true;
    });

    try {
      final user = ref.read(userProvider).value;
      if (user == null) {
        throw Exception('로그인이 필요합니다');
      }

      // 2. FamilyFortuneConditions 생성
      final conditions = FamilyFortuneConditions(
        concern: _selectedConcern!.name,
        concernLabel: _selectedConcern!.label,
        detailedQuestions: _selectedQuestions.toList(),
        familyMemberCount: _familyMemberCount,
        relationship: _relationship,
        specialQuestion: _questionController.text.isNotEmpty
            ? _questionController.text
            : null,
      );

      // 3. UnifiedFortuneService 호출 (6단계 최적화 시스템)
      final fortuneService = UnifiedFortuneService(
        Supabase.instance.client,
        enableOptimization: true,
      );

      final tokenState = ref.read(tokenProvider);
      final isPremium = tokenState.hasUnlimitedAccess;

      final result = await fortuneService.getFortune(
        fortuneType: 'family-${_selectedConcern!.name}',
        dataSource: FortuneDataSource.api,
        inputConditions: conditions.toJson(),
        conditions: conditions,
        isPremium: isPremium,
        onBlurredResult: (blurredResult) {
          // 블러 상태로 즉시 UI 업데이트 (스켈레톤 종료)
          if (mounted) {
            // ✅ 가족 운세 결과 공개 시 햅틱 피드백
            final score = blurredResult.score ?? 70;
            ref.read(fortuneHapticServiceProvider).scoreReveal(score);

            setState(() {
              _fortuneResult = blurredResult;
              _isLoading = false;
            });
          }
        },
      );

      // Premium 사용자: 즉시 전체 표시
      if (isPremium && mounted) {
        // ✅ 가족 운세 결과 공개 시 햅틱 피드백
        final score = result.score ?? 70;
        ref.read(fortuneHapticServiceProvider).scoreReveal(score);

        setState(() {
          _fortuneResult = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      Logger.error('가족 운세 생성 실패', e);
      if (mounted) {
        setState(() {
          _showResult = false;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('운세 생성에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    }
  }

  /// 광고 보고 블러 제거
  Future<void> _showAdAndUnblur() async {
    final adService = ref.read(adServiceProvider);

    await adService.showRewardedAd(
      onUserEarnedReward: (ad, reward) async {
        // ✅ 블러 해제 햅틱 (5단계 상승 패턴)
        await ref.read(fortuneHapticServiceProvider).premiumUnlock();

        setState(() {
          // FortuneResult의 블러 상태 해제
          _fortuneResult = _fortuneResult?.copyWith(
            isBlurred: false,
            blurredSections: [],
          );
        });
        // 구독 유도 스낵바 표시 (구독자가 아닌 경우만)
        final tokenState = ref.read(tokenProvider);
        SubscriptionSnackbar.showAfterAd(
          context,
          hasUnlimitedAccess: tokenState.hasUnlimitedAccess,
        );
      },
    );
  }

  // ✅ UnifiedBlurWrapper로 마이그레이션 완료 (2024-12-07)

  Widget _buildResultScreen() {
    if (_fortuneResult == null || _selectedConcern == null) return const SizedBox.shrink();
    final colors = context.colors;
    final concernColor = _selectedConcern!.gradientColors[0];

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(DSSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Concern header
          Container(
            padding: const EdgeInsets.all(DSSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _selectedConcern!.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(DSRadius.lg),
              boxShadow: [
                BoxShadow(
                  color: concernColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(DSRadius.lg),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedConcern!.label,
                        style: context.heading3.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: DSSpacing.xs),
                      Text(
                        _selectedConcern!.description,
                        style: context.labelLarge.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // Fortune content
          UnifiedBlurWrapper(
            isBlurred: _fortuneResult!.isBlurred,
            blurredSections: _fortuneResult!.blurredSections,
            sectionKey: 'fortune_content',
            child: AppCard(
              padding: const EdgeInsets.all(DSSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: concernColor, size: 24),
                      const SizedBox(width: DSSpacing.sm),
                      Text(
                        '오늘의 운세',
                        style: context.heading3.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DSSpacing.md),
                  Text(
                    _fortuneResult!.data['content'] as String? ?? '',
                    style: context.labelLarge.copyWith(
                      color: colors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: UnifiedButton(
                  text: '다시 해보기',
                  style: UnifiedButtonStyle.secondary,
                  onPressed: () => setState(() {
                    _fortuneResult = null;
                    _showResult = false;
                    _currentStep = 0;
                    _selectedConcern = null;
                    _selectedQuestions.clear();
                    _familyMemberCount = 1;
                    _relationship = 'self';
                    _questionController.clear();
                    _pageController.jumpToPage(0);
                  }),
                ),
              ),
              const SizedBox(width: DSSpacing.md),
              Expanded(
                child: UnifiedButton(
                  text: '공유하기',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('공유 기능이 곧 추가될 예정입니다')),
                    );
                  },
                ),
              ),
            ],
          ),
            ],
          ),
        ).animate().fadeIn(duration: 600.ms),

        // ✅ FloatingBottomButton (구독자 제외)
        if (_fortuneResult!.isBlurred && !ref.watch(isPremiumProvider))
          UnifiedButton.floating(
            text: '광고 보고 전체 내용 확인하기',
            onPressed: _showAdAndUnblur,
            isEnabled: true,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 116), // bottom: 100 효과
          ),
      ],
    );
  }
}