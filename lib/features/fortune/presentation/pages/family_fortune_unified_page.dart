import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../shared/components/toss_floating_progress_button.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../widgets/standard_fortune_app_bar.dart';

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
  Set<String> _selectedQuestions = {};

  // Step 3: 가족 구성원 정보
  int _familyMemberCount = 1;
  String _relationship = 'self'; // self, parent, child, spouse

  // Step 4: 특별히 궁금한 점 (선택)
  final TextEditingController _questionController = TextEditingController();

  bool _isLoading = false;
  Fortune? _fortune;

  @override
  void dispose() {
    _pageController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossTheme.backgroundSecondary,
      appBar: const StandardFortuneAppBar(
        title: '가족 운세',
      ),
      body: _fortune != null
          ? _buildResultScreen()
          : _buildInputScreen(),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '가장 궁금한\n가족 운세를 선택해주세요',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '가족의 행복과 안녕을 위한 맞춤 운세를 제공해드려요',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
            ),
          ),
          const SizedBox(height: 32),

          ...FamilyConcern.values.map((concern) {
            final isSelected = _selectedConcern == concern;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => setState(() => _selectedConcern = concern),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? concern.gradientColors[0].withValues(alpha: 0.05)
                        : (isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.backgroundPrimary),
                    border: Border.all(
                      color: isSelected
                          ? concern.gradientColors[0]
                          : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: concern.gradientColors[0].withValues(alpha: isSelected ? 1.0 : 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          concern.icon,
                          color: isSelected ? TossDesignSystem.white : concern.gradientColors[0],
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              concern.label,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              concern.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final questions = concernQuestions[_selectedConcern]!;
    final concernColor = _selectedConcern!.gradientColors[0];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
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
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${_selectedConcern!.label}에서\n궁금한 점을 선택해주세요',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '최대 3개까지 선택할 수 있어요',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
            ),
          ),
          const SizedBox(height: 32),

          ...questions.map((question) {
            final questionId = question['id']!;
            final isSelected = _selectedQuestions.contains(questionId);
            final canSelect = _selectedQuestions.length < 3 || isSelected;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
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
                        : (isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.backgroundPrimary),
                    border: Border.all(
                      color: isSelected
                          ? concernColor
                          : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isSelected ? concernColor : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? concernColor : (isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray400),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: isSelected
                            ? Icon(Icons.check, color: TossDesignSystem.white, size: 16)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          question['label']!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: canSelect
                                ? (isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack)
                                : (isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray400),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '가족 구성원에 대해\n알려주세요',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '더 정확한 운세를 위한 정보예요',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
            ),
          ),
          const SizedBox(height: 32),

          // 가족 구성원 수
          TossCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '함께 사는 가족 구성원',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, color: TossTheme.primaryBlue),
                        onPressed: () {
                          if (_familyMemberCount > 1) setState(() => _familyMemberCount--);
                        },
                      ),
                      Expanded(
                        child: Text(
                          '$_familyMemberCount명',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: TossTheme.primaryBlue),
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
          const SizedBox(height: 16),

          // 나와의 관계
          TossCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '운세를 보고 싶은 대상',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                  ),
                ),
                const SizedBox(height: 12),
                ...[
                  {'value': 'self', 'label': '나 자신', 'icon': Icons.person},
                  {'value': 'parent', 'label': '부모님', 'icon': Icons.elderly},
                  {'value': 'child', 'label': '자녀', 'icon': Icons.child_care},
                  {'value': 'spouse', 'label': '배우자', 'icon': Icons.favorite},
                ].map((rel) {
                  final isSelected = _relationship == rel['value'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _relationship = rel['value'] as String),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? TossTheme.primaryBlue.withValues(alpha: 0.1) : null,
                          border: Border.all(
                            color: isSelected
                                ? TossTheme.primaryBlue
                                : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              rel['icon'] as IconData,
                              color: isSelected
                                  ? TossTheme.primaryBlue
                                  : (isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              rel['label'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? TossTheme.primaryBlue
                                    : (isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack),
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: TossTheme.primaryBlue,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '특별히 궁금한 점이\n있으신가요?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '선택사항이에요. 운세에 반영해드릴게요',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
            ),
          ),
          const SizedBox(height: 32),

          TossCard(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _questionController,
              style: TextStyle(
                color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                fontSize: 16,
              ),
              maxLines: 6,
              decoration: InputDecoration(
                hintText: '예: 올해 가족 여행 가기 좋은 시기는 언제인가요?\n예: 아이 학원을 바꾸려고 하는데 괜찮을까요?',
                hintStyle: TextStyle(
                  color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray500,
                  fontSize: 15,
                ),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TossTheme.primaryBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: TossTheme.primaryBlue.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: TossTheme.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '질문을 남기지 않아도 운세를 볼 수 있어요',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
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

    return TossFloatingProgressButtonPositioned(
      text: buttonText,
      currentStep: _currentStep + 1,
      totalSteps: 4,
      onPressed: _canProceed() ? _handleNext : null,
      isEnabled: _canProceed(),
      isVisible: true,
      showProgress: true,
      isLoading: _isLoading,
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
    setState(() => _isLoading = true);

    try {
      final user = ref.read(userProvider).value;
      if (user == null) {
        throw Exception('로그인이 필요합니다');
      }

      final params = {
        'concern': _selectedConcern!.name,
        'concern_label': _selectedConcern!.label,
        'detailed_questions': _selectedQuestions.toList(),
        'family_member_count': _familyMemberCount,
        'relationship': _relationship,
        if (_questionController.text.isNotEmpty)
          'special_question': _questionController.text,
      };

      final fortuneService = ref.read(fortuneServiceProvider);
      final fortune = await fortuneService.getFortune(
        fortuneType: 'family-${_selectedConcern!.name}',
        userId: user.id,
        params: params,
      );

      setState(() => _fortune = fortune);
    } catch (e) {
      Logger.error('가족 운세 생성 실패', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('운세 생성에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildResultScreen() {
    if (_fortune == null || _selectedConcern == null) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final concernColor = _selectedConcern!.gradientColors[0];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Concern header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _selectedConcern!.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
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
                    color: TossDesignSystem.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _selectedConcern!.icon,
                    color: TossDesignSystem.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedConcern!.label,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: TossDesignSystem.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedConcern!.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: TossDesignSystem.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Fortune content
          TossCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: concernColor, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '오늘의 운세',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _fortune!.content,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: TossButton(
                  text: '다시 해보기',
                  style: TossButtonStyle.secondary,
                  onPressed: () => setState(() {
                    _fortune = null;
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
              const SizedBox(width: 12),
              Expanded(
                child: TossButton(
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
    ).animate().fadeIn(duration: 600.ms);
  }
}