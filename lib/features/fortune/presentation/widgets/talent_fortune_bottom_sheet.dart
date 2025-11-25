import 'package:flutter/material.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/unified_button_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../presentation/providers/navigation_visibility_provider.dart';
import '../../../../services/ad_service.dart';

class TalentFortuneBottomSheet extends ConsumerStatefulWidget {
  const TalentFortuneBottomSheet({super.key});

  static Future<void> show(BuildContext context) async {
    // Riverpod container에서 provider 읽기
    final container = ProviderScope.containerOf(context);
    
    // 네비게이션 바 숨기기
    container.read(navigationVisibilityProvider.notifier).hide();
    
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: TossDesignSystem.white.withValues(alpha: 0.0),
      builder: (context) => const TalentFortuneBottomSheet(),
    ).whenComplete(() {
      // Bottom Sheet가 닫힐 때 네비게이션 바 다시 표시
      container.read(navigationVisibilityProvider.notifier).show();
    });
  }

  @override
  ConsumerState<TalentFortuneBottomSheet> createState() => _TalentFortuneBottomSheetState();
}

class _TalentFortuneBottomSheetState extends ConsumerState<TalentFortuneBottomSheet> {
  String? _selectedInterest;
  String? _selectedStrength;
  String? _selectedGoal;

  final List<Map<String, dynamic>> _interests = [
    {'icon': Icons.palette, 'title': '예술과 창작', 'color': TossDesignSystem.tossBlue},
    {'icon': Icons.business, 'title': '비즈니스', 'color': TossDesignSystem.tossBlue},
    {'icon': Icons.psychology, 'title': '사람과 소통', 'color': TossDesignSystem.errorRed},
    {'icon': Icons.science, 'title': '과학과 기술', 'color': TossDesignSystem.successGreen},
    {'icon': Icons.sports, 'title': '운동과 활동', 'color': TossDesignSystem.warningOrange},
    {'icon': Icons.book, 'title': '학습과 연구', 'color': TossDesignSystem.tossBlue},
  ];

  final List<Map<String, dynamic>> _strengths = [
    {'icon': Icons.lightbulb, 'title': '창의적 사고', 'color': TossDesignSystem.warningOrange},
    {'icon': Icons.speed, 'title': '빠른 실행력', 'color': TossDesignSystem.errorRed},
    {'icon': Icons.groups, 'title': '리더십', 'color': TossDesignSystem.tossBlue},
    {'icon': Icons.analytics, 'title': '분석적 사고', 'color': TossDesignSystem.successGreen},
    {'icon': Icons.favorite, 'title': '공감 능력', 'color': TossDesignSystem.errorRed},
    {'icon': Icons.build, 'title': '문제 해결', 'color': TossDesignSystem.gray500},
  ];

  final List<Map<String, dynamic>> _goals = [
    {'icon': Icons.work, 'title': '직업 찾기', 'color': TossDesignSystem.tossBlue},
    {'icon': Icons.school, 'title': '학습 방향', 'color': TossDesignSystem.successGreen},
    {'icon': Icons.favorite, 'title': '취미 발견', 'color': TossDesignSystem.errorRed},
    {'icon': Icons.trending_up, 'title': '성장 방향', 'color': TossDesignSystem.tossBlue},
    {'icon': Icons.star, 'title': '숨은 재능', 'color': TossDesignSystem.warningOrange},
    {'icon': Icons.psychology, 'title': '성격 분석', 'color': TossDesignSystem.tossBlue},
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: screenHeight * 0.9,
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuestionSection(
                    '1. 가장 관심 있는 분야는?',
                    _interests,
                    _selectedInterest,
                    (value) => setState(() => _selectedInterest = value),
                  ),
                  const SizedBox(height: 24),
                  _buildQuestionSection(
                    '2. 나의 가장 큰 강점은?',
                    _strengths,
                    _selectedStrength,
                    (value) => setState(() => _selectedStrength = value),
                  ),
                  const SizedBox(height: 24),
                  _buildQuestionSection(
                    '3. 무엇을 알고 싶나요?',
                    _goals,
                    _selectedGoal,
                    (value) => setState(() => _selectedGoal = value),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Bottom Button
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              12, // 상단 패딩 추가
              20,
              16 + MediaQuery.of(context).padding.bottom, // 하단 패딩 조정
            ),
            decoration: BoxDecoration(
              color: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.white,
              boxShadow: [
                BoxShadow(
                  color: (isDark ? TossDesignSystem.black : TossDesignSystem.black).withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: UnifiedButton(
                text: _canGenerate() ? '✨ 나의 숨겨진 재능 발견하기' : '모든 질문에 답해주세요',
                onPressed: _canGenerate() ? _generateFortune : null,
                style: UnifiedButtonStyle.primary,
                size: UnifiedButtonSize.large,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSection(
    String question,
    List<Map<String, dynamic>> options,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          childAspectRatio: 0.9,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValue == option['title'];
            return GestureDetector(
              onTap: () => onChanged(option['title']),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? option['color'].withValues(alpha: 0.1)
                      : (isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.cardBackgroundLight),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? option['color']
                        : (isDark ? TossDesignSystem.borderDark : TossDesignSystem.borderLight),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      option['icon'],
                      size: 28,
                      color: isSelected
                          ? option['color']
                          : (isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.gray600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      option['title'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? option['color']
                            : (isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.gray700),
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  bool _canGenerate() {
    return _selectedInterest != null && 
           _selectedStrength != null && 
           _selectedGoal != null;
  }

  void _generateFortune() async {
    // Context 저장
    if (!mounted) return;
    final navigator = Navigator.of(context);
    final routerContext = context;

    // 파라미터 저장
    final params = {
      'autoGenerate': true,
      'fortuneParams': {
        'interest': _selectedInterest,
        'strength': _selectedStrength,
        'goal': _selectedGoal,
      },
    };

    // 바텀시트 닫기
    navigator.pop();

    // 광고 표시 후 재능 발견 페이지로 이동
    await AdService.instance.showInterstitialAdWithCallback(
      onAdCompleted: () async {
        routerContext.push('/talent', extra: params);
      },
      onAdFailed: () async {
        // 광고 실패해도 페이지로 이동
        routerContext.push('/talent', extra: params);
      },
    );
  }
}