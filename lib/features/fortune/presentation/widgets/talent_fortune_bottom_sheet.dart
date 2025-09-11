import 'package:flutter/material.dart';
import '../../../../shared/components/toss_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../presentation/providers/navigation_visibility_provider.dart';

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
      backgroundColor: Colors.transparent,
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
    {'icon': Icons.palette, 'title': '예술과 창작', 'color': Colors.purple},
    {'icon': Icons.business, 'title': '비즈니스', 'color': Colors.blue},
    {'icon': Icons.psychology, 'title': '사람과 소통', 'color': Colors.pink},
    {'icon': Icons.science, 'title': '과학과 기술', 'color': Colors.green},
    {'icon': Icons.sports, 'title': '운동과 활동', 'color': Colors.orange},
    {'icon': Icons.book, 'title': '학습과 연구', 'color': Colors.indigo},
  ];

  final List<Map<String, dynamic>> _strengths = [
    {'icon': Icons.lightbulb, 'title': '창의적 사고', 'color': Colors.amber},
    {'icon': Icons.speed, 'title': '빠른 실행력', 'color': Colors.red},
    {'icon': Icons.groups, 'title': '리더십', 'color': Colors.blue},
    {'icon': Icons.analytics, 'title': '분석적 사고', 'color': Colors.teal},
    {'icon': Icons.favorite, 'title': '공감 능력', 'color': Colors.pink},
    {'icon': Icons.build, 'title': '문제 해결', 'color': Colors.grey},
  ];

  final List<Map<String, dynamic>> _goals = [
    {'icon': Icons.work, 'title': '직업 찾기', 'color': Colors.blue},
    {'icon': Icons.school, 'title': '학습 방향', 'color': Colors.green},
    {'icon': Icons.favorite, 'title': '취미 발견', 'color': Colors.red},
    {'icon': Icons.trending_up, 'title': '성장 방향', 'color': Colors.purple},
    {'icon': Icons.star, 'title': '숨은 재능', 'color': Colors.orange},
    {'icon': Icons.psychology, 'title': '성격 분석', 'color': Colors.cyan},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      height: screenHeight * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
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
              color: Colors.grey[300],
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
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: TossButton(
                text: _canGenerate() ? '재능 분석하기' : '모든 질문에 답해주세요',
                onPressed: _canGenerate() ? _generateFortune : null,
                style: TossButtonStyle.primary,
                size: TossButtonSize.large,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
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
                      ? option['color'].withOpacity(0.1)
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? option['color']
                        : Colors.grey[300]!,
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
                          : Colors.grey[600],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      option['title'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected 
                            ? option['color']
                            : Colors.grey[700],
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

  void _generateFortune() {
    // 바텀시트 닫기
    Navigator.of(context).pop();
    
    // 바로 재능 발견 페이지로 이동 (광고 없음)
    context.go('/talent', extra: {
      'autoGenerate': true,
      'fortuneParams': {
        'interest': _selectedInterest,
        'strength': _selectedStrength,
        'goal': _selectedGoal,
      },
    });
  }
}